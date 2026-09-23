-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Photo\\Component\\PhotoFuncGazeComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("PhotoFuncGazeComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PhotoFuncGazeComponent = Class.LightClass("PhotoFuncGazeComponent", UIComponent)
local Const = require("Common.Const.Const")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local PetData = require("Data.pet_data")
local EModelUtils = require("Entities.Utils.EModelUtils")
local Time = require("Core.Common.Time")
local HotkeyConst = require("Const.HotkeyConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local PhotographyStudioUtils = require("Utils.PhotographyStudioUtils")
local GAMEPAD_MOVE_SPEED = 800
local GAMEPAD_STICK_DEADZONE = 0.15
local GAZE_DRAG_FOCUSED_STATE = "PhotoGazeDragFocused"
local BUTTON_CONTROLLER = "button"
local BUTTON_PRESSED_PAGE = 1
local BUTTON_FOCUS_PAGE = 3
local BUTTON_NORMAL_PAGE = 0
local TabType = {
	Player = 1,
	Npc = 3,
	Pet = 2
}
local GazeType = {
	Normal = 1,
	Manual = 3,
	Camera = 2
}
local TabList = {
	{
		name = "PHOTO_PLAYER_GAZE",
		tabType = TabType.Player
	},
	{
		name = "PHOTO_PET_GAZE",
		tabType = TabType.Pet
	},
	{
		name = "PHOTO_NPC_GAZE",
		tabType = TabType.Npc
	}
}
local TabListWithoutNpc = {
	TabList[1],
	TabList[2]
}
local GazeList = {
	{
		name = "PHOTO_NORMAL_GAZE",
		gazeType = GazeType.Normal
	},
	{
		name = "PHOTO_CAMERA_GAZE",
		gazeType = GazeType.Camera
	},
	{
		name = "PHOTO_MANUAL_GAZE",
		gazeType = GazeType.Manual
	}
}

function PhotoFuncGazeComponent:onCtor(info)
	if not info then
		return
	end

	self.preset = info.preset
	self.hideNpcGaze = info.hideNpcGaze == true
end

function PhotoFuncGazeComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.listFirstUList = self.objectReference:GetRefValue("listFirstUList")
	self.listCharacterUList = self.objectReference:GetRefValue("listCharacterUList")
	self.listPetUList = self.objectReference:GetRefValue("listPetUList")
	self.btnDragUButton = self.objectReference:GetRefValue("btnDragUButton")
	self.btnAllSelectedUButton = self.objectReference:GetRefValue("btnAllSelectedUButton")
	self.btnDragUButton.dragBounds = self.view.transform
end

function PhotoFuncGazeComponent:initView()
	self:initGaze()
	self:initGamepad()
end

function PhotoFuncGazeComponent:onDestroy()
	self:setGamepadDragVisual(false)
	self:setDragFocusConsoleState(false)

	if self.focusDragButtonTimer then
		self:killTimer(self.focusDragButtonTimer)

		self.focusDragButtonTimer = nil
	end

	if self.gamepadTickTimer then
		self:killTimer(self.gamepadTickTimer)

		self.gamepadTickTimer = nil
	end

	local selfEntity = self.ctrl:getSelfEntity()

	if selfEntity then
		selfEntity:cancelLookAtRole(0.5)
	end

	local myCurPet = pg.me:getCurPetEntity()

	if myCurPet then
		self:petNormalGazeOnClick(myCurPet)
	end

	for _, entity in ipairs(self.npcEntities) do
		entity:cancelLookAtRole()
	end

	UIComponent.onDestroy(self)
end

function PhotoFuncGazeComponent:initGaze()
	self.curTabType = TabType.Player
	self.curPlayerGazeType = GazeType.Camera
	self.curNpcGazeType = GazeType.Camera
	self.petGazeType = {}
	self.petGazePos = {}
	self.petLookAtPos = {}
	self.mulPetGazePos = nil
	self.manualCount = 0
	self.manualPetId = 0
	self.playerGazePos = Vector3.New(self.btnDragUButton.transform.position.x, self.btnDragUButton.transform.position.y, self.btnDragUButton.transform.position.z)
	self.playerLookAtPos = nil
	self.npcGazePos = Vector3.New(self.playerGazePos.x, self.playerGazePos.y, self.playerGazePos.z)
	self.npcEntities = {}
	self.firstPetGaze = GazeType.Camera

	self:updateNpcEntities()

	self.defaultPlayerGazeTimer = self:startTimer(function()
		self.defaultPlayerGazeTimer = nil

		if not self.hasAppliedPreset then
			self:playerCameraGazeOnClick()
		end
	end, 0.1)

	self:petCameraGazeOnClick(pg.me:getCurPetEntity())
	self:npcCameraGazeOnClick()

	function self.listFirstUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

		ClientTextUtils.setText(txtNameUBaseText, pg.getGameString(data.name))

		function button.luaSelectChanged(isSelect)
			if not isSelect then
				return
			end

			self.curTabType = data.tabType

			if data.tabType == TabType.Player then
				self.ctrl.gazeUComponent:TryChangePage("type", 0)
				self.listCharacterUList:SelectItem(self.curPlayerGazeType - 1)
			elseif data.tabType == TabType.Pet then
				self.ctrl.gazeUComponent:TryChangePage("type", 1)
			elseif data.tabType == TabType.Npc then
				self.ctrl.gazeUComponent:TryChangePage("type", 0)
				self.listCharacterUList:SelectItem(self.curNpcGazeType - 1)
			end

			self:refreshDragBtn()
		end

		local targetList = data.tabType == TabType.Pet and self.listPetUList or self.listCharacterUList

		PhotographyStudioUtils.bindTabEnterFirstItem(button, targetList)
	end

	function self.listCharacterUList.luaRenderItem(button, index, data)
		button:TryChangePage("sight", index)

		local objectReference = button:GetComponent("ObjectReference")
		local textUBaseText = objectReference:GetRefValue("textUBaseText")

		ClientTextUtils.setText(textUBaseText, pg.getGameString(data.name))

		if data.gazeType == GazeType.Normal then
			function button.luaSelectChanged(isSelect)
				if not isSelect then
					return
				end

				if self.curTabType == TabType.Player then
					self:playerNormalGazeOnClick()
				elseif self.curTabType == TabType.Npc then
					self:npcNormalGazeOnClick()
				end

				if self.ctrl.recordHistoryStep then
					self.ctrl:recordHistoryStep("gaze_type")
				end
			end
		elseif data.gazeType == GazeType.Camera then
			function button.luaSelectChanged(isSelect)
				if not isSelect then
					return
				end

				if self.curTabType == TabType.Player then
					self:playerCameraGazeOnClick()
				elseif self.curTabType == TabType.Npc then
					self:npcCameraGazeOnClick()
				end

				if self.ctrl.recordHistoryStep then
					self.ctrl:recordHistoryStep("gaze_type")
				end
			end
		elseif data.gazeType == GazeType.Manual then
			function button.luaSelectChanged(isSelect)
				if not isSelect then
					return
				end

				local wasManual = self.curTabType == TabType.Player and self.curPlayerGazeType == GazeType.Manual or self.curTabType == TabType.Npc and self.curNpcGazeType == GazeType.Manual

				if self.curTabType == TabType.Player then
					self:playerManualGazeOnClick()
				elseif self.curTabType == TabType.Npc then
					self:npcManualGazeOnClick()
				end

				self:refreshDragBtn()

				if not wasManual then
					self:focusDragButton()
				end

				if self.ctrl.recordHistoryStep then
					self.ctrl:recordHistoryStep("gaze_type")
				end
			end

			function button.luaClick()
				self:focusDragButton()
			end
		end

		self:refreshDragBtn()
	end

	function self.listPetUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local petUImage = objectReference:GetRefValue("petUImage")
		local config = data.petData

		petUImage.url = LuaUIUtils.getPetIcon(config.iconName, LuaUIUtils.PET_ICON, Const.PET_LABEL_MASK.NORMAL)

		local entity = data.entity

		if index == 0 then
			self.firstPetGaze = self.petGazeType[entity.id] or GazeType.Camera
		end

		if not self.petGazeType[entity.id] then
			self.petGazeType[entity.id] = self.btnAllSelectedUButton.isSelected and self.firstPetGaze or GazeType.Camera
		end

		if not self.petGazePos[entity.id] then
			self.petGazePos[entity.id] = Vector3.New(self.playerGazePos.x, self.playerGazePos.y, self.playerGazePos.z)
		end

		if not self.mulPetGazePos then
			self.mulPetGazePos = Vector3.New(self.playerGazePos.x, self.playerGazePos.y, self.playerGazePos.z)
		end

		local gazeType = self.petGazeType[entity.id]

		button:TryChangePage("sight", gazeType - 1)

		function button.luaClick()
			local gazeType = self.petGazeType[entity.id] % 3 + 1

			if index == 0 then
				self.firstPetGaze = gazeType
			end

			local changeFunc

			if gazeType == GazeType.Normal then
				function changeFunc(button)
					self:petNormalGazeOnClick(button.dataFromUList.entity)
					button:TryChangePage("sight", 0)
					self.ctrl:showParamTip(1, pg.getGameString("PHOTO_PET_GAZE"), pg.getGameString("PHOTO_NORMAL_GAZE"))
				end
			elseif gazeType == GazeType.Camera then
				function changeFunc(button)
					self:petCameraGazeOnClick(button.dataFromUList.entity)
					button:TryChangePage("sight", 1)
					self.ctrl:showParamTip(1, pg.getGameString("PHOTO_PET_GAZE"), pg.getGameString("PHOTO_CAMERA_GAZE"))
				end
			elseif gazeType == GazeType.Manual then
				function changeFunc(button)
					self:petManualGazeOnClick(button.dataFromUList.entity)
					button:TryChangePage("sight", 2)
					self.ctrl:showParamTip(1, pg.getGameString("PHOTO_PET_GAZE"), pg.getGameString("PHOTO_MANUAL_GAZE"))
				end
			end

			if not changeFunc then
				return
			end

			if not self.btnAllSelectedUButton.isSelected then
				changeFunc(button)
			else
				local buttons = self.listPetUList:GetAllButtons()

				for i = 0, buttons.Length - 1 do
					changeFunc(buttons[i])
				end
			end

			self:refreshDragBtn()

			if gazeType == GazeType.Manual then
				pg.global.navMgr:PushFocusItem(self.btnDragUButton)
			end

			if self.ctrl.recordHistoryStep then
				self.ctrl:recordHistoryStep("pet_gaze_type")
			end
		end
	end

	function self.btnAllSelectedUButton.luaSelectChanged(isSelected)
		if not isSelected then
			return
		end

		local buttons = self.listPetUList:GetAllButtons()

		if buttons.Length <= 0 then
			return
		end

		local button = buttons[0]
		local gazeType = self.firstPetGaze

		gazeType = (gazeType - 1) % 3

		for id in pairs(self.petGazeType) do
			local entity = self.ctrl:getPetEntity(id)

			if self:canControlPetGaze(entity) then
				self.petGazeType[id] = gazeType
			end
		end

		button.luaClick()
	end

	function self.btnDragUButton.luaDrag()
		local btnX = self.btnDragUButton.transform.position.x
		local btnY = self.btnDragUButton.transform.position.y
		local btnZ = self.btnDragUButton.transform.position.z

		if self.curTabType == TabType.Player then
			self.playerGazePos.x = btnX
			self.playerGazePos.y = btnY
			self.playerGazePos.z = btnZ
		elseif self.curTabType == TabType.Pet then
			self.mulPetGazePos.x = btnX
			self.mulPetGazePos.y = btnY
			self.mulPetGazePos.z = btnZ

			for id, type in pairs(self.petGazeType) do
				local entity = self.ctrl:getPetEntity(id)

				if type == GazeType.Manual and self:canControlPetGaze(entity) then
					self.petGazePos[id].x = btnX
					self.petGazePos[id].y = btnY
					self.petGazePos[id].z = btnZ
				end
			end
		elseif self.curTabType == TabType.Npc then
			self.npcGazePos.x = btnX
			self.npcGazePos.y = btnY
			self.npcGazePos.z = btnZ
		end

		self:updateLookAt()
	end

	function self.btnDragUButton.luaEndDrag()
		if self.ctrl.recordHistoryStep then
			self.ctrl:recordHistoryStep("gaze_manual")
		end
	end

	function self.btnDragUButton.luaNavFocused()
		self:setDragFocusConsoleState(true)
	end

	function self.btnDragUButton.luaNavUnfocused()
		self:setGamepadDragVisual(false)
		self:setDragFocusConsoleState(false)
	end

	self:setDragFocusConsoleState(false)

	if self.preset then
		self:applyPreset(self.preset)
	end
end

function PhotoFuncGazeComponent:canControlPetGaze(entity)
	if not entity then
		return false
	end

	if not self.ctrl or type(self.ctrl.isMaster) ~= "function" or self.ctrl:isMaster() then
		return true
	end

	local ownerUid = entity.getOwnerUid and entity:getOwnerUid()

	return ownerUid ~= nil and tostring(ownerUid) == tostring(pg.me.uid)
end

function PhotoFuncGazeComponent:refreshUI()
	if not self.haveRefreshed then
		self.listFirstUList:SetList(self.hideNpcGaze and TabListWithoutNpc or TabList)
		self.listFirstUList:DeselectAll()
		self.listFirstUList:SelectItem(0)
		self.listCharacterUList:SetList(GazeList)
		self.listCharacterUList:DeselectAll()

		if self.curTabType == TabType.Player and self.defaultPlayerGazeType then
			self.listCharacterUList:SelectItem(self.defaultPlayerGazeType - 1)
		elseif self.curTabType == TabType.Npc and self.defaultNpcGazeType then
			self.listCharacterUList:SelectItem(self.defaultPlayerGazeType - 1)
		else
			self.listCharacterUList:SelectItem(1)
		end

		self.haveRefreshed = true
	end

	local entities = self.ctrl:getCreatedPets()
	local listData = {}

	for k, entity in pairs(entities) do
		if self:canControlPetGaze(entity) then
			local pData = PetData[entity.templateId] or {}

			listData[#listData + 1] = {
				petData = pData,
				entity = entity
			}
		end
	end

	self.listPetUList:SetList(listData)
end

function PhotoFuncGazeComponent:applyPreset(preset)
	self.hasAppliedPreset = true

	if self.defaultPlayerGazeTimer then
		self:killTimer(self.defaultPlayerGazeTimer)

		self.defaultPlayerGazeTimer = nil
	end

	if type(preset.gazeType) == "userdata" then
		if preset.gazeType then
			self.defaultPlayerGazeType = preset.gazeType:GetHashCode()
		end

		if preset.npcGazeType then
			self.defaultNpcGazeType = preset.npcGazeType:GetHashCode()
		end
	else
		self.defaultPlayerGazeType = tonumber(preset.gazeType)
		self.defaultNpcGazeType = tonumber(preset.npcGazeType)
	end

	if self.defaultPlayerGazeType == GazeType.Normal then
		self:playerNormalGazeOnClick()
	elseif self.defaultPlayerGazeType == GazeType.Camera then
		self:playerCameraGazeOnClick()
	elseif self.defaultPlayerGazeType == GazeType.Manual then
		self:playerManualGazeOnClick()

		local gazePos = preset.gazePos

		if gazePos then
			self.playerLookAtPos = Vector3.New(gazePos.x, gazePos.y, gazePos.z)

			self.ctrl:getSelfEntity():lookAtPos(self.playerLookAtPos, false)

			local camera = self.ctrl:getPhotoCameraMode().cameraMode:GetPhotoCamera()

			if not IsNil(camera) then
				local screenPos = camera:WorldToScreenPoint(self.playerLookAtPos)
				local uiPos = UIUtils.ScreenPointToUIPoint(self.btnDragUButton.transform, screenPos)

				self.btnDragUButton.transform.position = uiPos

				Vector3.Copy(self.playerGazePos, uiPos)
			end
		end
	end

	if self.defaultNpcGazeType == GazeType.Normal then
		self:npcNormalGazeOnClick()
	elseif self.defaultNpcGazeType == GazeType.Camera then
		self:npcCameraGazeOnClick()
	elseif self.defaultNpcGazeType == GazeType.Manual then
		self:npcManualGazeOnClick()
	end

	local petInfoList = preset.petInfo

	if IsNil(petInfoList) then
		return
	end

	self.ctrl:createPresetPets(preset)

	local handlerSet = {}
	local entities = self.ctrl:getCreatedPets()

	local function handlerEntity(entity, data, index)
		local playerPos = self.ctrl:getSelfEntity():getPosition()
		local position = Vector3(playerPos.x + data.position.x, playerPos.y + data.position.y, playerPos.z + data.position.z)
		local quaternion = Quaternion.Euler(data.rotation.x, data.rotation.y, data.rotation.z)

		EModelUtils.setAgentPositionAndRotation(entity, position, quaternion)

		local gazeType

		if type(data.gazeType) == "userdata" then
			gazeType = data.gazeType:GetHashCode()
		else
			gazeType = tonumber(data.gazeType)
		end

		if gazeType == GazeType.Normal then
			self:petNormalGazeOnClick(entity)
		elseif gazeType == GazeType.Camera then
			self:petCameraGazeOnClick(entity)
		elseif gazeType == GazeType.Manual then
			self:petManualGazeOnClick(entity)
		end

		handlerSet[entity] = true
		handlerSet[index] = true
	end

	if type(petInfoList) == "userdata" then
		for i = 0, petInfoList.Count - 1 do
			local data = petInfoList[i]

			for k, entity in pairs(entities) do
				if entity.templateId == data.id and not handlerSet[entity] and not handlerSet[i] then
					handlerEntity(entity, data, i)
				end
			end
		end

		for i = 0, petInfoList.Count - 1 do
			local data = petInfoList[i]

			for k, entity in pairs(entities) do
				if not handlerSet[entity] and not handlerSet[i] then
					handlerEntity(entity, data, i)
				end
			end
		end
	else
		for i = 1, #petInfoList do
			local data = petInfoList[i]

			for k, entity in pairs(entities) do
				if entity.templateId == data.id and not handlerSet[entity] and not handlerSet[i] then
					handlerEntity(entity, data, i)
				end
			end
		end

		for i = 1, #petInfoList do
			local data = petInfoList[i]

			for k, entity in pairs(entities) do
				if not handlerSet[entity] and not handlerSet[i] then
					handlerEntity(entity, data, i)
				end
			end
		end
	end
end

function PhotoFuncGazeComponent:savePlayerToPreset(preset)
	preset.gazeType = self.curPlayerGazeType

	if self.curPlayerGazeType == GazeType.Manual and self.playerLookAtPos then
		preset.gazePos = {
			x = self.playerLookAtPos.x,
			y = self.playerLookAtPos.y,
			z = self.playerLookAtPos.z
		}
	else
		preset.gazePos = nil
	end
end

function PhotoFuncGazeComponent:saveToPreset(preset)
	self:savePlayerToPreset(preset)

	preset.npcGazeType = self.curNpcGazeType

	local petInfo = preset.petInfo or {}
	local entities = self.ctrl:getCreatedPets()

	for k, ent in pairs(entities) do
		if preset.petInfo then
			for k, v in ipairs(petInfo) do
				if v.entityId == ent.id then
					v.gazeType = self.petGazeType[ent.id]
					v.entityId = nil

					break
				end
			end
		else
			petInfo[#petInfo + 1] = {
				id = ent.templateId,
				entityId = ent.id,
				gazeType = self.petGazeType[ent.id]
			}
		end
	end

	preset.petInfo = petInfo
end

function PhotoFuncGazeComponent:update()
	return
end

function PhotoFuncGazeComponent:updateLookAt()
	if self.curTabType == TabType.Player then
		if self.curPlayerGazeType == GazeType.Manual then
			local selfEntity = self.ctrl:getSelfEntity()
			local screenPos = UIUtils.WorldToScreenPoint(self.playerGazePos)
			local worldPos = self.ctrl:getPhotoCameraMode():getLookAtPos(screenPos.x, screenPos.y, selfEntity)

			if worldPos then
				self.playerLookAtPos = Vector3.New(worldPos.x, worldPos.y, worldPos.z)

				selfEntity:lookAtPos(worldPos, false)
			end
		end
	elseif self.curTabType == TabType.Pet then
		for id, type in pairs(self.petGazeType) do
			if type == GazeType.Manual then
				local entity = self.ctrl:getPetEntity(id)
				local pos = self.petGazePos[id]

				if self:canControlPetGaze(entity) and pos then
					local screenPos = UIUtils.WorldToScreenPoint(pos)
					local worldPos = self.ctrl:getPhotoCameraMode():getLookAtPos(screenPos.x, screenPos.y, entity)

					if worldPos then
						self.petLookAtPos[id] = Vector3.New(worldPos.x, worldPos.y, worldPos.z)

						entity:lookAtPos(worldPos, false)
					end
				end
			end
		end
	elseif self.curNpcGazeType == GazeType.Manual then
		for k, entity in ipairs(self.npcEntities) do
			local screenPos = UIUtils.WorldToScreenPoint(self.npcGazePos)
			local worldPos = self.ctrl:getPhotoCameraMode():getLookAtPos(screenPos.x, screenPos.y, entity)

			entity:lookAtPos(worldPos, false)
		end
	end
end

function PhotoFuncGazeComponent:playerNormalGazeOnClick()
	self.curPlayerGazeType = GazeType.Normal

	self.btnDragUButton:SetActive(false)
	self.ctrl:getPhotoCameraMode():setEnableCameraLookAt(false, self.ctrl:getSelfEntity())
	self.ctrl:getSelfEntity():cancelLookAtRole(0.5)
end

function PhotoFuncGazeComponent:playerCameraGazeOnClick()
	self.curPlayerGazeType = GazeType.Camera

	self.btnDragUButton:SetActive(false)
	self.ctrl:getSelfEntity():cancelLookAtRole()
	self.ctrl:getPhotoCameraMode():setEnableCameraLookAt(true, self.ctrl:getSelfEntity())
end

function PhotoFuncGazeComponent:playerManualGazeOnClick()
	self.curPlayerGazeType = GazeType.Manual

	self.btnDragUButton:SetActive(true)
	self.ctrl:getSelfEntity():cancelLookAtRole()
end

function PhotoFuncGazeComponent:petNormalGazeOnClick(entity)
	if not entity then
		return
	end

	if self.petGazeType[entity.id] == GazeType.Normal then
		return
	end

	self.petGazeType[entity.id] = GazeType.Normal

	local photoCameraMode = self.ctrl:getPhotoCameraMode()

	if photoCameraMode then
		photoCameraMode:setEnableCameraLookAt(false, entity)
	end

	entity:cancelLookAtRole(0.5)
end

function PhotoFuncGazeComponent:petCameraGazeOnClick(entity)
	if not entity then
		return
	end

	if self.petGazeType[entity.id] == GazeType.Camera then
		return
	end

	self.petGazeType[entity.id] = GazeType.Camera

	entity:cancelLookAtRole()
	self.ctrl:getPhotoCameraMode():setEnableCameraLookAt(true, entity)
	entity:addEModelComponent(Const.COMPONENT_INDEX_IK)

	local lookAtComponent = entity.eModel.ikLookAtComponent

	if IsNil(lookAtComponent) then
		return
	end

	entity.eModel:EnableRigComponent(Const.COMPONENT_INDEX_IK, lookAtComponent, true)
end

function PhotoFuncGazeComponent:petManualGazeOnClick(entity)
	if not entity then
		return
	end

	if self.petGazeType[entity.id] == GazeType.Manual then
		return
	end

	self.petGazeType[entity.id] = GazeType.Manual

	self.btnDragUButton:SetActive(true)
	entity:cancelLookAtRole()
end

function PhotoFuncGazeComponent:getStudioPetGazeData(entity)
	if not entity then
		return nil
	end

	local gazeType = self.petGazeType[entity.id] or GazeType.Camera
	local result = {
		gazeType = gazeType
	}
	local gazePos = self.petLookAtPos[entity.id]

	if gazeType == GazeType.Manual and gazePos then
		result.gazePos = {
			x = gazePos.x,
			y = gazePos.y,
			z = gazePos.z
		}
	end

	return result
end

function PhotoFuncGazeComponent:applyStudioPetGaze(entity, gazeType, gazePos)
	if not entity then
		return
	end

	if type(gazeType) == "userdata" then
		gazeType = gazeType:GetHashCode()
	else
		gazeType = tonumber(gazeType)
	end

	gazeType = gazeType or GazeType.Camera
	self.petGazeType[entity.id] = nil

	if gazeType == GazeType.Normal then
		self:petNormalGazeOnClick(entity)
	elseif gazeType == GazeType.Camera then
		self:petCameraGazeOnClick(entity)
	elseif gazeType == GazeType.Manual then
		self:petManualGazeOnClick(entity)

		if gazePos then
			local worldPos = Vector3.New(gazePos.x, gazePos.y, gazePos.z)

			self.petLookAtPos[entity.id] = worldPos

			entity:lookAtPos(worldPos, false)

			local camera = self.ctrl:getPhotoCameraMode().cameraMode:GetPhotoCamera()

			if not IsNil(camera) then
				local screenPos = camera:WorldToScreenPoint(worldPos)
				local uiPos = UIUtils.ScreenPointToUIPoint(self.btnDragUButton.transform, screenPos)

				self.petGazePos[entity.id] = Vector3.New(uiPos.x, uiPos.y, uiPos.z)
			end
		end
	end
end

function PhotoFuncGazeComponent:npcNormalGazeOnClick()
	self.curNpcGazeType = GazeType.Normal

	self.btnDragUButton:SetActive(false)

	for _, entity in ipairs(self.npcEntities) do
		entity:cancelLookAtRole(0.5)
	end
end

function PhotoFuncGazeComponent:npcCameraGazeOnClick()
	self.curNpcGazeType = GazeType.Camera

	self.btnDragUButton:SetActive(false)

	for _, entity in ipairs(self.npcEntities) do
		entity:lookAtCamera(self.ctrl:getPhotoCameraMode().cameraMode:GetPhotoCamera(), false)
	end
end

function PhotoFuncGazeComponent:npcManualGazeOnClick()
	self.curNpcGazeType = GazeType.Manual

	self.btnDragUButton:SetActive(true)

	for _, entity in ipairs(self.npcEntities) do
		entity:cancelLookAtRole(0.5)
	end
end

function PhotoFuncGazeComponent:updateNpcEntities()
	table.clear(self.npcEntities)

	local actorIds = pg.me:entitiesInRange(10, Const.SEARCH_USR_TYPE_ACTOR)

	for _, actorId in ipairs(actorIds) do
		local entity = pg.getEntityByActorId(actorId)

		if Utils.isPeopleNpc(entity) or Utils.isPetNpc(entity) then
			self.npcEntities[#self.npcEntities + 1] = entity
		end
	end
end

function PhotoFuncGazeComponent:isDragBtnFocused()
	if IsNil(self.btnDragUButton) then
		return false
	end

	return pg.global.navMgr.CurrentFocusedUContent == self.btnDragUButton
end

function PhotoFuncGazeComponent:setDragFocusConsoleState(focused)
	if pg.global.navMgr then
		pg.global.navMgr:SetConsoleBarState(GAZE_DRAG_FOCUSED_STATE, focused == true)
	end
end

function PhotoFuncGazeComponent:setGamepadDragVisual(dragging)
	dragging = dragging == true

	if self.isGamepadDragVisual == dragging then
		return
	end

	self.isGamepadDragVisual = dragging

	if IsNil(self.btnDragUButton) then
		return
	end

	local page = BUTTON_NORMAL_PAGE

	if dragging then
		page = BUTTON_PRESSED_PAGE
	elseif self:isDragBtnFocused() then
		page = BUTTON_FOCUS_PAGE
	end

	self.btnDragUButton:TryChangePage(BUTTON_CONTROLLER, page)
end

function PhotoFuncGazeComponent:focusDragButton()
	if not pg.game.input:isUsingGamepad() then
		return
	end

	if self.focusDragButtonTimer then
		self:killTimer(self.focusDragButtonTimer)
	end

	local timerId

	timerId = self:startTimer(function()
		if self.focusDragButtonTimer ~= timerId then
			return
		end

		self.focusDragButtonTimer = nil

		if NotNil(self.btnDragUButton) and self.btnDragUButton.gameObject.activeInHierarchy then
			pg.global.navMgr:PushFocusItem(self.btnDragUButton)
		end
	end, 0)
	self.focusDragButtonTimer = timerId
end

function PhotoFuncGazeComponent:initGamepad()
	self.gamepadStick = Vector2(0, 0)

	local root = self.transform.gameObject
	local stickBind = KeyBindingPro.GetOrAddKeyBindingByName(root, "PhotoGaze_RightStick")

	stickBind.isVirtual = true
	stickBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRightStickMove

	function stickBind.luaTrigger(inputInfo)
		if not self:isDragBtnFocused() then
			self.gamepadStick = Vector2(0, 0)

			return true
		end

		if inputInfo.phase == "Performed" then
			self.gamepadStick = Vector2(inputInfo.valueVec2.x, inputInfo.valueVec2.y)
		else
			self.gamepadStick = Vector2(0, 0)
		end
	end

	self.gamepadTickTimer = self:startTimer(function()
		self:gamepadTick()
	end, 0, true)
end

function PhotoFuncGazeComponent:gamepadTick()
	if not self:isDragBtnFocused() then
		self:setGamepadDragVisual(false)

		return
	end

	local sx, sy = self.gamepadStick.x, self.gamepadStick.y

	if math.abs(sx) <= GAMEPAD_STICK_DEADZONE and math.abs(sy) <= GAMEPAD_STICK_DEADZONE then
		self:setGamepadDragVisual(false)

		return
	end

	self:setGamepadDragVisual(true)

	local dt = Time.deltaTime
	local rect = self.btnDragUButton:GetComponent("RectTransform")
	local cur = rect.anchoredPosition

	rect.anchoredPosition = Vector2(cur.x + sx * GAMEPAD_MOVE_SPEED * dt, cur.y + sy * GAMEPAD_MOVE_SPEED * dt)

	if self.btnDragUButton.luaDrag then
		self.btnDragUButton.luaDrag()
	end
end

function PhotoFuncGazeComponent:refreshDragBtn()
	if self.curTabType == TabType.Player then
		self.btnDragUButton.transform.position = self.playerGazePos

		self.btnDragUButton:SetActive(self.curPlayerGazeType == GazeType.Manual)
	elseif self.curTabType == TabType.Pet then
		self.manualCount = 0
		self.manualPetId = nil

		for id, type in pairs(self.petGazeType) do
			local entity = self.ctrl:getPetEntity(id)

			if type == GazeType.Manual and self:canControlPetGaze(entity) then
				self.manualCount = self.manualCount + 1
				self.manualPetId = id
			end
		end

		self.btnDragUButton:SetActive(self.manualCount > 0)

		if self.manualCount > 1 then
			self.btnDragUButton.transform.position = self.mulPetGazePos
		elseif self.manualCount == 1 then
			self.btnDragUButton.transform.position = self.petGazePos[self.manualPetId]
		end
	elseif self.curTabType == TabType.Npc then
		self.btnDragUButton.transform.position = self.npcGazePos

		self.btnDragUButton:SetActive(self.curNpcGazeType == GazeType.Manual)
	end

	self:updateLookAt()
end

return PhotoFuncGazeComponent
