-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Photo\\Component\\PhotoFuncPetPoseUIComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("PhotoFuncPetPoseUIComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PhotoFuncPetPoseUIComponent = Class.LightClass("PhotoFuncPetPoseUIComponent", UIComponent)
local PhotographyStudioUtils = require("Utils.PhotographyStudioUtils")
local ClientConst = require("Const.ClientConst")
local AiConst = require("Common.Const.AiConst")
local Time = require("Core.Common.Time")
local PlayableConst = require("Common.Const.PlayableConst")
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local AIUtils = require("Common.Utils.AIUtils")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local EModelUtils = require("Entities.Utils.EModelUtils")
local PlacePetUIComponent = require("Guis.Panels.Photo.Component.PlacePetUIComponent")
local UIConst = require("Const.UIConst")
local AppearanceAction = require("Data.appearance_action_data")
local PetAppearanceAction = require("Data.pet_appearance_action_data")
local PetTalentData = require("Data.pet_talent_data")
local PhotoPetAction = require("Guis.Panels.Photo.Component.PhotoPetAction")
local SysConfigData = require("Data.sys_config_data")
local EventConst = require("Const.EventConst")
local PetPhotoReactionData = require("Data.pet_photo_reaction_data")
local defaultAnim = PlayableConst.Idle

PhotoFuncPetPoseUIComponent.CameraPoseType = {
	Dynamic = 2,
	Static = 1
}
PhotoFuncPetPoseUIComponent.CameraPoseTabs = {
	{
		label = "PHOTO_POSE_STATIC",
		id = PhotoFuncPetPoseUIComponent.CameraPoseType.Static
	},
	{
		label = "PHOTO_POSE_DYNAMIC",
		id = PhotoFuncPetPoseUIComponent.CameraPoseType.Dynamic
	}
}
PhotoFuncPetPoseUIComponent.ViewMode = {
	Player = 3,
	Pet = 2,
	Camera = 1
}
PhotoFuncPetPoseUIComponent.ViewModeConfig = {
	{
		id = PhotoFuncPetPoseUIComponent.ViewMode.Camera
	},
	{
		id = PhotoFuncPetPoseUIComponent.ViewMode.Pet
	}
}

function PhotoFuncPetPoseUIComponent:onCtor(info)
	if not info then
		return
	end
end

function PhotoFuncPetPoseUIComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.selectedPetUWidget = self.objectReference:GetRefValue("selectedPetUWidget")
	self.tabUWidget = self.objectReference:GetRefValue("tabUWidget")
	self.listTabUList = self.objectReference:GetRefValue("listTabUList")
	self.listPoseUList = self.objectReference:GetRefValue("listPoseUList")
	self.btnJumpUButton = self.objectReference:GetRefValue("btnJumpUButton")
	self.listPetModeUList = self.objectReference:GetRefValue("listPetModeUList")
	self.listPetUList = self.objectReference:GetRefValue("listPetUList")
	self.focalLengthSliderUWidget = self.objectReference:GetRefValue("focalLengthSliderUWidget")
	self.btnPlayOrStopUButton = self.objectReference:GetRefValue("btnPlayOrStopUButton")
	self.dynamicPoseUSlider = self.objectReference:GetRefValue("dynamicPoseUSlider")
end

function PhotoFuncPetPoseUIComponent:initView()
	self:initPhotoAction()

	self.frameUpdateTimer = self:startTimer(function()
		self:frameUpdate()
	end, 0.033, true)
end

function PhotoFuncPetPoseUIComponent:onDestroy()
	self.isDestroying = true

	local keepPetActionOnExit = self.ctrl:shouldKeepPetActionOnExit()

	if self.frameUpdateTimer then
		self:killTimer(self.frameUpdateTimer)

		self.frameUpdateTimer = nil
	end

	self:setAllPetAITimePaused(false)

	local curPet = pg.me and pg.me:getCurPetEntity()

	if curPet and not keepPetActionOnExit then
		self:resetPetAction(curPet)
	end

	self.placePetComp:destroy()

	self.petEntities = {}

	for index, ent in pairs(self.needResumeBtEnt) do
		AIUtils.resumeBt(ent, AiConst.PauseBtReason.Photo)

		if not keepPetActionOnExit then
			ent:stopCfgAnimation()
		end

		if ent.eventEmitter then
			ent.eventEmitter:emit(EventConst.TOPLOGO_BUBBLE, false)
		end
	end

	UIComponent.onDestroy(self)
end

function PhotoFuncPetPoseUIComponent:onDeselected()
	self:onChangeToCameraMode()

	self.curViewMode = self.ViewMode.Camera

	self.listPetModeUList:SelectItem(0)

	self.selected = false

	self.placePetComp:refreshCanMovePetState()
end

function PhotoFuncPetPoseUIComponent:createPlacePetComp()
	return PlacePetUIComponent.new(self)
end

function PhotoFuncPetPoseUIComponent:setupPetListRender()
	function self.listPetUList.luaRenderItem(button, index, data)
		button:TryChangePage("Empty", 0)

		local objectReference = button:GetComponent("ObjectReference")
		local btnRetrieveUButton = objectReference:GetRefValue("btnRetrieveUButton")
		local btnReleaseUButton = objectReference:GetRefValue("btnReleaseUButton")
		local petUImage = objectReference:GetRefValue("petUImage")

		index = index + 1

		local havePutInScene = self.petVisible[index]

		button:TryChangePage("state", havePutInScene and 0 or 1)

		local config = data.config

		petUImage.url = LuaUIUtils.getPetIcon(config.iconName, LuaUIUtils.PET_ICON, Const.PET_LABEL_MASK.NORMAL)

		if not button.isSelected then
			LuaUIUtils.setUIVisible(btnRetrieveUButton, false)
			LuaUIUtils.setUIVisible(btnReleaseUButton, false)
		else
			button:TryChangePage("type", havePutInScene and 1 or 0)
		end

		function button.luaSelectChanged(isSelected)
			LuaUIUtils.setUIVisible(btnRetrieveUButton, isSelected)
			LuaUIUtils.setUIVisible(btnReleaseUButton, isSelected)

			if not isSelected then
				return
			end

			button:TryChangePage("type", havePutInScene and 1 or 0)

			local entity = self.petEntities[index]

			if entity then
				self.placePetComp:selectPetEntity(data.entityId, self.ctrl:checkCanPetChangePos())
				self:onChangePetSelect(entity.id)
			end
		end

		function btnRetrieveUButton.luaClick()
			local entity = self.petEntities[index]

			if entity then
				self.placePetComp:setPetVisible(data.entityId, false)
			end

			self.petVisible[index] = false

			self.listPetUList:RefreshElement(index - 1)
			self:refreshListVisible()
		end

		function btnReleaseUButton.luaClick()
			local entity = self.petEntities[index]

			if entity then
				self.placePetComp:setPetVisible(data.entityId, true)
				entity:lookAtCamera(pg.game.camera.photoCameraMode.cameraMode:GetPhotoCamera(), false)
			else
				self.petEntities[index] = self.placePetComp:selectPetEntity(data.entityId)

				self:startTimer(function()
					self.petEntities[index]:lookAtCamera(pg.game.camera.photoCameraMode.cameraMode:GetPhotoCamera(), false)
				end, 0.1)
			end

			if self.ctrl:checkTimePause() then
				AIUtils.pauseBt(self.petEntities[index], AiConst.PauseBtReason.PhotoTimePause)
				self.petEntities[index]:setPhotoTimePauseAnimPlaying(false)
			end

			self:onChangePetSelect(self.petEntities[index].id)

			self.petVisible[index] = true

			self.listPetUList:RefreshElement(index - 1)
			self:refreshListVisible()
		end
	end
end

function PhotoFuncPetPoseUIComponent:initDefaultPets()
	local curPet = pg.me:getCurPetEntity()

	if curPet then
		local curPetIndex = self.model:getCurPetIndex()

		self.petEntities[curPetIndex] = curPet
		self.petVisible[curPetIndex] = true
	end
end

function PhotoFuncPetPoseUIComponent:initPhotoAction()
	self.changePoseTime = 0
	self.changeDynamicPoseInterval = 100
	self.curViewMode = nil
	self.petKeepSelected = false
	self.placePetComp = self:createPlacePetComp()
	self.petEntities = {}
	self.petVisible = {}
	self.curPlayPetPoseAni = {}
	self.curPlayPetPoseId = {}
	self.curPetDynamicPoseState = {}
	self.curDynamicPoseState = {}
	self.dynamicPoseEntityMap = {}
	self.curPlayPoseAni = {}
	self.needResumeBtEnt = {}
	self.resumeBtTimer = {}
	self.delayTimer = {}
	self.nextPetAction = {}
	self.lastPetAction = {}
	self.petEditMap = {}
	self.petUIRoot = self.ctrl.petPoseRootRectTransform
	self.selected = false

	self:initDefaultPets()
	self:setupPetListRender()

	function self.listPetModeUList.luaRenderItem(button, index, data)
		button:TryChangePage("type", data.id - 1)

		function button.luaSelectChanged(isSelected)
			if not isSelected then
				return
			end

			if data.id == self.ViewMode.Pet and not self.ctrl:checkCanPetChangePos() then
				self.listPetModeUList:SelectItem(0)
				pg.global.showBubbleMessageRaw(pg.getGameString("FUNCTION_CANT_STATE"))

				return
			end

			if self.curViewMode == data.id then
				return
			end

			self.curViewMode = data.id

			if data.id == self.ViewMode.Camera then
				self:onChangeToCameraMode()
			elseif data.id == self.ViewMode.Pet then
				self:onChangeToPetMode()
			end
		end
	end

	function self.listTabUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

		ClientTextUtils.setText(txtNameUBaseText, pg.getGameString(data.label))

		function button.luaSelectChanged(isSelected)
			if not isSelected then
				return
			end

			self:refreshPoseFunc(data.id)
		end

		PhotographyStudioUtils.bindTabEnterFirstItem(button, self.listPoseUList)
	end

	function self.listPoseUList.luaRenderItem(button, index, data)
		if data.empty then
			local objectReference = button:GetComponent("ObjectReference")
			local iconUImage = objectReference:GetRefValue("iconUImage")

			iconUImage.url = nil
			button.interactable = false

			return
		end

		button.interactable = true

		if not data.id then
			return
		end

		if data.params.icon then
			local objectReference = button:GetComponent("ObjectReference")
			local iconUImage = objectReference:GetRefValue("iconUImage")

			iconUImage.url = data.params.icon
		end

		if self.poseTypeId == self.CameraPoseType.Dynamic and data.selected then
			self.focalLengthSliderUWidget:SetActive(true)

			if self.curPetDynamicPoseState[self.curSelectPetId] then
				self.curDynamicPoseState[self.curSelectPetId] = self.curPetDynamicPoseState[self.curSelectPetId]
				self.curPlayPoseEnt = self:getPetEntity(self.curSelectPetId)
				self.curPlayPoseAni[self.curSelectPetId] = self.curPlayPetPoseAni[self.curSelectPetId]

				self:setDynamicPoseUSliderMaxValue(self.curDynamicPoseState[self.curSelectPetId].Length)
			end
		end
	end

	function self.listPoseUList.luaClick(button, data)
		local ent = self:getPetEntity(self.curSelectPetId)

		if not ent then
			return
		end

		self:setPetEditMap(ent.id)
		self:clearCurPlayingPetAni(ent)

		self.curPlayPetPoseId[ent.id] = data.id

		if self.ctrl.recordHistoryStep then
			ent.studioPetPoseId = data.id
		end

		local config = data.params

		self:playActionInner(config, ent)
		self:recordPlayingAni(ent)

		if config and config.name then
			self.ctrl:showParamTip(1, pg.getGameString("PHOTO_PET_POSE"), pg.getLocalizationText(config.name))
		end

		if self.ctrl.recordHistoryStep then
			self.ctrl:recordHistoryStep("pet_pose")
		end
	end

	function self.dynamicPoseUSlider.luaValueChanged(newValue)
		if self.curDynamicPoseState[self.curSelectPetId] then
			if self.changePoseTime > 0 and self.changePoseTime + self.changeDynamicPoseInterval > Time.realSecondCache * 1000 then
				return
			end

			self.changePoseTime = Time.realSecondCache * 1000
			self.curDynamicPoseState[self.curSelectPetId] = self.curPlayPoseEnt:playRawAnimation(self.curPlayPoseAni[self.curSelectPetId], 0, newValue, 1, nil, self:getAnimLayer(self.curSelectPetId))

			if not self.autoPlayDynamicPose then
				self.curDynamicPoseState[self.curSelectPetId]:SetSpeed(0)
			end
		end
	end

	function self.dynamicPoseUSlider.luaWidgetBeginDrag()
		self.sliderDragging = true

		for k, poseState in pairs(self.curDynamicPoseState) do
			poseState:SetSpeed(0)
		end

		if self.ctrl:checkTimePause() then
			self:setDynamicPoseEntitiesPlaying(false)
		end
	end

	function self.dynamicPoseUSlider.luaWidgetEndDrag()
		self.sliderDragging = false

		if not self.autoPlayDynamicPose then
			return
		end

		self.btnPlayOrStopUButton:TryChangePage("IsPlay", 1)

		for k, poseState in pairs(self.curDynamicPoseState) do
			poseState:SetSpeed(1)
		end

		if self.ctrl:checkTimePause() then
			self:setDynamicPoseEntitiesPlaying(true)
		end
	end

	function self.btnPlayOrStopUButton.luaClick()
		self.autoPlayDynamicPose = not self.autoPlayDynamicPose
		self.resumeDynamicPoseAfterTimePause = false

		self.btnPlayOrStopUButton:TryChangePage("IsPlay", self.autoPlayDynamicPose and 1 or 0)

		for k, poseState in pairs(self.curDynamicPoseState) do
			poseState:SetSpeed(self.autoPlayDynamicPose and 1 or 0)
		end

		if self.ctrl:checkTimePause() then
			self:setDynamicPoseEntitiesPlaying(self.autoPlayDynamicPose)
		end
	end

	if self.preset then
		self:applyPreset(self.preset)
	end

	if pg.game.input:isUsingGamepad() and self.listPetModeUList then
		self.listPetModeUList:SetForceInactive(CS.XGUI.ForceInactiveSource.Business, true)
	end
end

function PhotoFuncPetPoseUIComponent:getAvailablePoseTabs()
	local actionData = self:getPhotoActionData(PetAppearanceAction, self.curPlayPetPoseId[self.curSelectPetId])
	local poseTabs = {}

	for _, tabData in ipairs(self.CameraPoseTabs) do
		local poseList = actionData[tabData.id]

		if poseList and #poseList > 0 then
			poseTabs[#poseTabs + 1] = tabData
		end
	end

	return poseTabs
end

function PhotoFuncPetPoseUIComponent:refreshPoseTabs()
	local poseTabs = self:getAvailablePoseTabs()

	self.listTabUList:SetList(poseTabs)
	self.listTabUList:DeselectAll()

	if #poseTabs > 0 then
		local currentPoseId = self.curPlayPetPoseId[self.curSelectPetId]
		local currentPoseConfig = currentPoseId and PetAppearanceAction[currentPoseId]
		local preferredPoseType = currentPoseConfig and currentPoseConfig.photo or self.poseTypeId
		local selectedIndex = 0

		for index, tabData in ipairs(poseTabs) do
			if tabData.id == preferredPoseType then
				selectedIndex = index - 1

				break
			end
		end

		self.listTabUList:SelectItem(selectedIndex)
	else
		self.poseTypeId = nil

		self.listPoseUList:SetList({})
	end

	self.tabUWidget:SetActive(#poseTabs > 1)
end

function PhotoFuncPetPoseUIComponent:refreshUI()
	if not self.haveRefreshed then
		self:refreshGuide()
		self:refreshPoseTabs()

		local petList = self.model:getPreparePetList()

		self.listPetUList:SetList(petList)
		self.listPetUList:DeselectAll()

		for i = 1, #petList do
			if petList[i].isCurPet then
				local entity = self.petEntities[i]

				if entity then
					self.placePetComp:selectPetEntity(petList[i].entityId, false)
					self:onChangePetSelect(entity.id)
				end

				break
			end
		end

		self.haveRefreshed = true
	end

	self.view.widget:TryChangePage("PetMode", 0)
	self.placePetComp:onPageChange(true)
	self.listPetModeUList:SetList(self.ViewModeConfig)

	local lastIndex = math.max(0, self.listPetModeUList.selectedIndex)

	self.listPetModeUList:DeselectAll()

	if self.ctrl:checkCanPetChangePos() and pg.game.input:isUsingGamepad() then
		self:switchViewMode(self.ViewMode.Pet)
	elseif self.ctrl:checkCanPetChangePos() then
		self.listPetModeUList:SelectItem(0)
	else
		self.placePetComp:showUI(false)
		self.listPetModeUList:SelectItem(0)
	end

	self.selected = true
end

function PhotoFuncPetPoseUIComponent:applyPreset(preset)
	local petInfoList = preset.petInfo

	if IsNil(petInfoList) then
		return
	end

	self:createPresetPets(preset)

	local handlerSet = {}
	local entities = self.ctrl:getCreatedPets()

	local function handlerEntity(entity, data, index)
		local playerPos = pg.me:getPosition()
		local position = Vector3(playerPos.x + data.position.x, playerPos.y + data.position.y, playerPos.z + data.position.z)
		local quaternion = Quaternion.Euler(data.rotation.x, data.rotation.y, data.rotation.z)

		EModelUtils.setAgentPositionAndRotation(entity, position, quaternion)
		self:setPetEditMap(entity.id)
		AIUtils.pauseBt(entity, AiConst.PauseBtReason.Photo)

		if entity.eventEmitter then
			entity.eventEmitter:emit(EventConst.TOPLOGO_BUBBLE, false)
		end

		entity:stopCfgAnimation()
		self:applyPetPose(entity.id, data.petPoseId)

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

function PhotoFuncPetPoseUIComponent:saveToPreset(preset)
	local petInfo = preset.petInfo or {}

	for k, ent in pairs(self.petEntities) do
		local pos = ent:getPosition()
		local playerPos = pg.me:getPosition()
		local position = {
			x = pos.x - playerPos.x,
			y = pos.y - playerPos.y,
			z = pos.z - playerPos.z
		}
		local rotation = ent:getRotation():ToEulerAngles()

		if preset.petInfo then
			for k, v in ipairs(petInfo) do
				if v.entityId == ent.id then
					v.position = {
						x = tonumber(string.format("%.2f", position.x)),
						y = tonumber(string.format("%.2f", position.y)),
						z = tonumber(string.format("%.2f", position.z))
					}
					v.rotation = {
						x = tonumber(string.format("%.2f", rotation.x)),
						y = tonumber(string.format("%.2f", rotation.y)),
						z = tonumber(string.format("%.2f", rotation.z))
					}
					v.petPoseId = self.curPlayPetPoseId[ent.id]
					v.entityId = nil

					break
				end
			end
		else
			petInfo[#petInfo + 1] = {
				id = ent.templateId,
				entityId = ent.id,
				position = {
					x = tonumber(string.format("%.2f", position.x)),
					y = tonumber(string.format("%.2f", position.y)),
					z = tonumber(string.format("%.2f", position.z))
				},
				rotation = {
					x = tonumber(string.format("%.2f", rotation.x)),
					y = tonumber(string.format("%.2f", rotation.y)),
					z = tonumber(string.format("%.2f", rotation.z))
				},
				petPoseId = self.curPlayPetPoseId[ent.id]
			}
		end
	end

	preset.petInfo = petInfo
end

function PhotoFuncPetPoseUIComponent:applyPetPose(petId, petPoseId)
	local config = PetAppearanceAction[petPoseId]

	if not config then
		return
	end

	self.curPlayPetPoseId[petId] = petPoseId
	self.curPlayPetPoseAni[petId] = self:playActionInner(config, self:getPetEntity(petId))
end

function PhotoFuncPetPoseUIComponent:refreshListVisible()
	local visibleCount = 0

	for k, v in pairs(self.petVisible) do
		if v then
			visibleCount = visibleCount + 1
		end
	end

	self.listTabUList:SetActive(visibleCount > 0)
	self.listPoseUList:SetActive(visibleCount > 0)
	self.listPetModeUList:SetActive(visibleCount > 0)
end

function PhotoFuncPetPoseUIComponent:refreshGuide()
	local needShow = pg.global.prefsCacheUtils:getBool(ClientConst.PrefKey.PhotoPetPutGuide .. pg.me.uid, true)
	local helpId

	if needShow and helpId then
		pg.global.prefsCacheUtils:setBool(ClientConst.PrefKey.EventTypeShowGuide .. pg.me.uid, false)
		pg.global.ui:open(UIConst.UI_ID_FUNC_MENU_UNLOCK, {
			helpId = helpId
		})
	end
end

function PhotoFuncPetPoseUIComponent:onChangePetSelect(entityId)
	self.curSelectPetId = entityId

	self:refreshPoseTabs()

	local showSlider = self.curDynamicPoseState[self.curSelectPetId] ~= nil

	self.focalLengthSliderUWidget:SetActive(showSlider)
end

function PhotoFuncPetPoseUIComponent:frameUpdate()
	if self.isDestroying or not self.dynamicPoseUSlider or IsNil(self.dynamicPoseUSlider) then
		return
	end

	if not self.curDynamicPoseState or not self.curSelectPetId then
		return
	end

	local curDynamicPoseState = self.curDynamicPoseState[self.curSelectPetId]

	if self.autoPlayDynamicPose and curDynamicPoseState and not self.sliderDragging then
		if not curDynamicPoseState.IsPlaying then
			if not self.curPlayPoseEnt or not self.curPlayPoseAni or not self.curPlayPoseAni[self.curSelectPetId] then
				return
			end

			self.curDynamicPoseState[self.curSelectPetId] = self.curPlayPoseEnt:playRawAnimation(self.curPlayPoseAni[self.curSelectPetId], nil, 0, 1, nil, self:getAnimLayer(self.curSelectPetId))

			self.curDynamicPoseState[self.curSelectPetId]:SetLogicLoop(true)

			self.curPetDynamicPoseState[self.curSelectPetId] = self.curDynamicPoseState[self.curSelectPetId]

			self.dynamicPoseUSlider:SetValueWithoutCallback(0)
		else
			self.dynamicPoseUSlider:SetValueWithoutCallback(curDynamicPoseState.Time % curDynamicPoseState.Length)
		end
	end
end

function PhotoFuncPetPoseUIComponent:setDynamicPoseEntitiesPlaying(playing)
	for _, ent in pairs(self.petEntities) do
		if self.dynamicPoseEntityMap[ent.id] and self.curDynamicPoseState[ent.id] then
			ent:setPhotoTimePauseAnimPlaying(playing)
		end
	end
end

function PhotoFuncPetPoseUIComponent:setAllPetAITimePaused(paused)
	for _, ent in pairs(self.petEntities) do
		if paused then
			AIUtils.pauseBt(ent, AiConst.PauseBtReason.PhotoTimePause)
		else
			AIUtils.resumeBt(ent, AiConst.PauseBtReason.PhotoTimePause)
		end
	end
end

function PhotoFuncPetPoseUIComponent:pausePhotoSubjects(resumeDynamicPose)
	if resumeDynamicPose == nil then
		resumeDynamicPose = self.autoPlayDynamicPose and next(self.dynamicPoseEntityMap) ~= nil
	end

	self.resumeDynamicPoseAfterTimePause = resumeDynamicPose == true
	self.autoPlayDynamicPose = false

	self.btnPlayOrStopUButton:TryChangePage("IsPlay", 0)

	for _, poseState in pairs(self.curDynamicPoseState) do
		poseState:SetSpeed(0)
	end

	self:setAllPetAITimePaused(true)

	for _, ent in pairs(self.petEntities) do
		ent:setPhotoTimePauseAnimPlaying(false)
	end
end

function PhotoFuncPetPoseUIComponent:resumePhotoSubjects()
	self:setAllPetAITimePaused(false)

	for _, ent in pairs(self.petEntities) do
		ent:setPhotoTimePauseAnimPlaying(nil)
	end

	if self.resumeDynamicPoseAfterTimePause and next(self.dynamicPoseEntityMap) ~= nil then
		self.autoPlayDynamicPose = true

		self.btnPlayOrStopUButton:TryChangePage("IsPlay", 1)

		for entityId, poseState in pairs(self.curDynamicPoseState) do
			if self.dynamicPoseEntityMap[entityId] then
				poseState:SetSpeed(1)
			end
		end
	end

	self.resumeDynamicPoseAfterTimePause = false
end

function PhotoFuncPetPoseUIComponent:clearCurPlayingPetAni(ent, skipPlayDefault)
	if not ent then
		return
	end

	if not skipPlayDefault then
		ent:playAnimation(defaultAnim, nil, nil, nil, self:getAnimLayer(ent.id))
	end

	if self.curPetDynamicPoseState[ent.id] then
		self.curPetDynamicPoseState[ent.id]:SetLogicLoop(false)
	end

	self.curPlayPetPoseAni[ent.id] = nil

	if self.curDynamicPoseState[ent.id] == self.curPetDynamicPoseState[ent.id] then
		self.curDynamicPoseState[ent.id] = nil
		self.curPlayPoseEnt = nil
	end

	self.curPetDynamicPoseState[ent.id] = nil
	self.dynamicPoseEntityMap[ent.id] = nil

	self.focalLengthSliderUWidget:SetActive(false)
end

function PhotoFuncPetPoseUIComponent:playActionInner(config, ent)
	if not config then
		return
	end

	if config.photo == self.CameraPoseType.Dynamic then
		local ani = config.resLoop and PlayableConst[config.resLoop] or PlayableConst[config.res]

		self:playDynamicAnim(ent, ani)

		return ani
	elseif config.photo == self.CameraPoseType.Static then
		local ani = PlayableConst[config.res]
		local aniLoop = config.resLoop and PlayableConst[config.resLoop]

		self:playStaticAnim(ent, ani, aniLoop)

		local res = aniLoop or ani

		return res
	end
end

function PhotoFuncPetPoseUIComponent:playStaticAnim(ent, ani, aniLoop)
	if not ent or not ani then
		return
	end

	self.focalLengthSliderUWidget:SetActive(false)

	local state = ent:playAnimation(ani, true, nil, false, self:getAnimLayer(ent.id))

	if not state then
		return
	end

	self.curPlayPoseAni[ent.id] = ani
	self.dynamicPoseEntityMap[ent.id] = nil

	if next(self.dynamicPoseEntityMap) == nil then
		self.resumeDynamicPoseAfterTimePause = false
	end

	if self.ctrl:checkTimePause() then
		ent:setPhotoTimePauseAnimPlaying(false)
	end

	if aniLoop then
		ent:setAnimationSequence(state, state.Length - 0.2, function(stateTime)
			if stateTime > 0 then
				local loopState = ent:playAnimation(aniLoop, true, nil, false, self:getAnimLayer(ent.id))

				loopState:SetLogicLoop(true)

				self.curPlayPoseAni[ent.id] = aniLoop
				self.curPlayPetPoseAni[ent.id] = self.curPlayPoseAni[ent.id]
			end

			return true
		end)
	end
end

function PhotoFuncPetPoseUIComponent:playDynamicAnim(ent, ani)
	if not ent or not ani then
		return
	end

	self.curPlayPoseEnt = ent
	self.curDynamicPoseState[ent.id] = ent:playRawAnimation(ani, nil, 0, 1, nil, self:getAnimLayer(ent.id))

	if not self.curDynamicPoseState[ent.id] then
		return
	end

	self.curDynamicPoseState[ent.id]:SetLogicLoop(true)

	self.dynamicPoseEntityMap[ent.id] = true
	self.curPlayPoseAni[ent.id] = ani

	self:setDynamicPoseUSliderMaxValue(self.curDynamicPoseState[ent.id].Length)
	self.dynamicPoseUSlider:SetValueWithoutCallback(0)

	if self.ctrl:checkTimePause() then
		self:pausePhotoSubjects(true)
	else
		self.resumeDynamicPoseAfterTimePause = false
		self.autoPlayDynamicPose = true

		self.btnPlayOrStopUButton:TryChangePage("IsPlay", 1)
	end

	self.focalLengthSliderUWidget:SetActive(true)
end

function PhotoFuncPetPoseUIComponent:setDynamicPoseUSliderMaxValue(length)
	self.dynamicPoseUSlider.enableValueChangedCallback = false
	self.dynamicPoseUSlider.maxValue = length
	self.dynamicPoseUSlider.enableValueChangedCallback = true
end

function PhotoFuncPetPoseUIComponent:recordPlayingAni(ent)
	self.curPlayPetPoseAni[ent.id] = self.curPlayPoseAni[ent.id]

	if self.poseTypeId == self.CameraPoseType.Dynamic then
		self.curPetDynamicPoseState[ent.id] = self.curDynamicPoseState[ent.id]
	end
end

function PhotoFuncPetPoseUIComponent:refreshPoseFunc(typeId)
	self.poseTypeId = typeId

	local dataList = self:getCurShowPoseData(typeId)

	table.insert(dataList, 1, {
		tIndex = 1,
		selected = self.curPlayPetPoseId[self.curSelectPetId] == nil
	})

	local offset = 7 - #dataList

	for i = 1, offset do
		dataList[#dataList + 1] = {
			empty = true
		}
	end

	self.listPoseUList:SetList(dataList)
end

function PhotoFuncPetPoseUIComponent:getCurShowPoseData(typeId)
	local poseData = {
		{},
		{}
	}

	poseData = self:getPhotoActionData(PetAppearanceAction, self.curPlayPetPoseId[self.curSelectPetId])

	return poseData[typeId]
end

function PhotoFuncPetPoseUIComponent:getPhotoActionData(tableData, curId)
	local actionData = {
		{},
		{}
	}

	for id, value in pairs(tableData) do
		if value.photo and value.photo > 0 then
			table.insert(actionData[value.photo], {
				id = id,
				params = value,
				selected = id == curId
			})
		end
	end

	return actionData
end

function PhotoFuncPetPoseUIComponent:switchViewMode(modeId)
	if modeId == self.ViewMode.Pet and not self.ctrl:checkCanPetChangePos() then
		return
	end

	if self.curViewMode == modeId then
		return
	end

	self.curViewMode = modeId

	if modeId == self.ViewMode.Camera then
		self:onChangeToCameraMode()
	elseif modeId == self.ViewMode.Pet then
		self:onChangeToPetMode()
	end
end

function PhotoFuncPetPoseUIComponent:saveCameraTransform()
	self.oriCameraPos = pg.game.camera.photoCameraMode:getFollowPosition()
	self.oriCameraRotate = pg.game.camera.photoCameraMode:getFollowEulerAngles()
end

function PhotoFuncPetPoseUIComponent:restoreCameraTransform()
	if self.oriCameraPos and self.oriCameraRotate then
		pg.game.camera.photoCameraMode:AsyncTrans(self.oriCameraPos.x, self.oriCameraPos.y, self.oriCameraPos.z, self.oriCameraRotate.x, self.oriCameraRotate.y, self.oriCameraRotate.z)

		self.oriCameraPos = nil
		self.oriCameraRotate = nil
	end
end

function PhotoFuncPetPoseUIComponent:onChangeToCameraMode()
	self.view.widget:TryChangePage("PetMode", 0)
	self.placePetComp:onPageChange(false)
	self:restoreCameraTransform()
	self.listPetUList:SetActive(false)
	self.view.widget:TryChangePage("PCSettingWidgetShow", 1)

	for k, ent in pairs(self.petEntities) do
		if not self.petEditMap[ent.id] then
			AIUtils.resumeBt(ent, AiConst.PauseBtReason.Photo)
		end
	end

	self:tryTriggerAllPetsAction()
	self.placePetComp:refreshCanMovePetState()
end

function PhotoFuncPetPoseUIComponent:onChangeToPetMode()
	self.view.widget:TryChangePage("PetMode", 1)
	self.placePetComp:onPageChange(true)
	self:saveCameraTransform()
	self.listPetUList:SetActive(true)
	self.view.widget:TryChangePage("PCSettingWidgetShow", 0)
	self:stopAllPetAction(true)
	self.placePetComp:refreshCanMovePetState()
end

function PhotoFuncPetPoseUIComponent:tryTriggerAllPetsAction()
	for k, entity in pairs(self.petEntities) do
		self:tryTriggerPetAction(entity)
	end
end

function PhotoFuncPetPoseUIComponent:tryTriggerPetAction(ent)
	if not ent then
		return
	end

	if self.resumeBtTimer[ent.id] then
		self.nextPetAction[ent.id] = true

		return
	end

	if not self:canTriggerPetAction(ent.id) then
		return
	end

	self.nextPetAction[ent.id] = false

	local realId = self.placePetComp:getRealEntityId(ent.id)
	local petInfo = pg.me:getPetInfo(realId)
	local natures = {}

	for index, value in ipairs(petInfo.talentList) do
		local talentTemplateId = value.templateId

		if talentTemplateId then
			local cfg = PetTalentData[talentTemplateId]

			if cfg and cfg.mbti then
				table.insert(natures, cfg.mbti)
			end
		end
	end

	local areaIds = {}

	pg.game.map:getCurBlockAreaIds(areaIds)

	local curPlayPlayerPoseAni = self.ctrl:getPlayerCurAnimName()
	local index, petAction = PhotoPetAction.calcPetAction(natures, pg.me.sceneId, areaIds, curPlayPlayerPoseAni, ent.id)

	if petAction and ent then
		local delayCfg = math.random(SysConfigData.PHOTO_ACTION_TIME_RANGE[2] - SysConfigData.PHOTO_ACTION_TIME_RANGE[1]) + SysConfigData.PHOTO_ACTION_TIME_RANGE[1]
		local delay = (self.lastPetAction[ent.id] == nil or self.lastPetAction[ent.id] == PhotoPetAction.ResultKey[6] and self.lastPetAction[ent.id] == petAction) and 0 or delayCfg

		if self.delayTimer[ent.id] then
			self:killTimer(self.delayTimer[ent.id])
		end

		self.delayTimer[ent.id] = self:startTimer(function()
			self.delayTimer[ent.id] = nil

			self:triggerPetAction(ent, natures, index, petAction)
		end, delay)
	end
end

function PhotoFuncPetPoseUIComponent:triggerPetAction(ent, natures, actionIndex, petAction)
	if not ent then
		return
	end

	if not self:canTriggerPetAction(ent.id) then
		return
	end

	self.lastPetAction[ent.id] = petAction

	local durationCfg = table.contains(natures, "I") and SysConfigData.PHOTO_ACTION_DURATION_I or SysConfigData.PHOTO_ACTION_DURATION_E
	local duration = durationCfg[actionIndex] or 5

	AIUtils.pauseBt(ent, AiConst.PauseBtReason.Photo)
	table.insert(self.needResumeBtEnt, ent)

	if ent.eventEmitter then
		ent.eventEmitter:emit(EventConst.TOPLOGO_BUBBLE, true, string.gsub(petAction, "^%l", string.upper), duration)
	end

	local aniAction = PetPhotoReactionData[actionIndex]

	if aniAction then
		ent:playSleAnimation(PlayableConst[aniAction.actStart], PlayableConst[aniAction.actLoop], PlayableConst[aniAction.actEnd], false, duration, nil, self:getAnimLayer(ent.id))
	end

	if self.resumeBtTimer[ent.id] then
		self:killTimer(self.resumeBtTimer[ent.id])
	end

	self.resumeBtTimer[ent.id] = self:startTimer(function()
		self.resumeBtTimer[ent.id] = nil

		ent:stopCfgAnimation()
		ent:playAnimation(defaultAnim, nil, nil, nil, self:getAnimLayer(ent.id))
		self:entResumeBt(ent)

		if self.nextPetAction[ent.id] then
			self:startNextPetAction(ent)
		else
			self.lastPetAction[ent.id] = nil
		end
	end, duration)
end

function PhotoFuncPetPoseUIComponent:entResumeBt(ent)
	if self:isPetEditing(ent.id) then
		return
	end

	AIUtils.resumeBt(ent, AiConst.PauseBtReason.Photo)
	ent:playAnimation(defaultAnim, nil, nil, nil, self:getAnimLayer(ent.id))

	local removeIndex = -1

	for index, value in ipairs(self.needResumeBtEnt) do
		if value.id == ent.id then
			removeIndex = index

			break
		end
	end

	if removeIndex ~= -1 then
		table.remove(self.needResumeBtEnt, removeIndex)
	end
end

function PhotoFuncPetPoseUIComponent:startNextPetAction(ent)
	if self.nextPetAction[ent.id] then
		self.nextPetAction[ent.id] = nil

		self:tryTriggerPetAction(ent)
	end
end

function PhotoFuncPetPoseUIComponent:showAllPets(show)
	for k, ent in pairs(self.petEntities) do
		ent:setVisible(ClientConst.MODEL_VISIBLE_KEY.PHOTO, show)
	end
end

function PhotoFuncPetPoseUIComponent:getPetEntity(entityId)
	return self.placePetComp:getPetEntity(entityId)
end

function PhotoFuncPetPoseUIComponent:createPresetPets(preset)
	local petInfoList = preset.petInfo

	if IsNil(petInfoList) then
		return
	end

	local petList = self.model:getPreparePetList()
	local prepareMap = {}

	for k, v in ipairs(petList) do
		prepareMap[v.entityId] = v.templateId
	end

	local templateIdMap = {}
	local needLoadEntityIdMap = {}
	local needCount = 0

	if type(petInfoList) == "userdata" then
		needCount = petInfoList.Count

		for i = 0, needCount - 1 do
			local data = petInfoList[i]

			if not templateIdMap[data.id] then
				templateIdMap[data.id] = 1
			else
				templateIdMap[data.id] = templateIdMap[data.id] + 1
			end
		end
	else
		needCount = #petInfoList

		for i = 1, needCount do
			local data = petInfoList[i]

			if not templateIdMap[data.id] then
				templateIdMap[data.id] = 1
			else
				templateIdMap[data.id] = templateIdMap[data.id] + 1
			end
		end
	end

	local generateCount = 0

	for entityId, templateId in pairs(prepareMap) do
		if templateIdMap[templateId] and templateIdMap[templateId] > 0 then
			templateIdMap[templateId] = templateIdMap[templateId] - 1
			needLoadEntityIdMap[entityId] = true
			generateCount = generateCount + 1
		else
			needLoadEntityIdMap[entityId] = false
		end
	end

	if generateCount < needCount then
		for id, v in pairs(needLoadEntityIdMap) do
			if not v then
				needLoadEntityIdMap[id] = true
				generateCount = generateCount + 1

				if generateCount == needCount then
					break
				end
			end
		end
	end

	for id, flag in pairs(needLoadEntityIdMap) do
		if flag then
			local ent = self.placePetComp:createPet(id)

			if self.ctrl:checkTimePause() then
				AIUtils.pauseBt(ent, AiConst.PauseBtReason.PhotoTimePause)
				ent:setPhotoTimePauseAnimPlaying(false)
			end

			for i = 1, #petList do
				if petList[i].entityId == id then
					self.petEntities[i] = ent
					self.petVisible[i] = true
				end
			end

			self.placePetComp:setPetVisible(id, true)
		else
			local ent = self:getPetEntity(id)

			if ent then
				for i = 1, #petList do
					if petList[i].entityId == id then
						self.petVisible[i] = false
					end
				end

				self.placePetComp:setPetVisible(id, false)
			end
		end
	end

	if not self.selected then
		self.placePetComp:showUI(false)
	end

	self.listPetUList:RefreshList()
end

function PhotoFuncPetPoseUIComponent:setPetEditMap(id)
	self.petEditMap[id] = true
end

function PhotoFuncPetPoseUIComponent:isPetEditing(id)
	return self.petEditMap[id] == true or self.curViewMode == self.ViewMode.Pet
end

function PhotoFuncPetPoseUIComponent:canTriggerPetAction(id)
	local controllingPet = pg.me and pg.me:getControllingPet()

	if controllingPet and controllingPet.id == id then
		return false
	end

	return self.curViewMode ~= self.ViewMode.Pet and self.curPlayPetPoseId[id] == nil
end

function PhotoFuncPetPoseUIComponent:resumePetBehavior(ent)
	self.petEditMap[ent.id] = false

	AIUtils.resumeBt(ent, AiConst.PauseBtReason.Photo)
end

function PhotoFuncPetPoseUIComponent:getCreatedPets()
	local ret = {}

	for k, entity in pairs(self.petEntities) do
		if self.petVisible[k] then
			ret[#ret + 1] = entity
		end
	end

	return ret
end

function PhotoFuncPetPoseUIComponent:stopPetAction(ent, stopBt)
	if not ent then
		return
	end

	if stopBt then
		AIUtils.pauseBt(ent, AiConst.PauseBtReason.Photo)
	end

	if ent.characterState ~= CharacterStateConst.IDLE then
		return
	end

	if self.curPlayPetPoseId[ent.id] then
		return
	end

	if self.resumeBtTimer[ent.id] then
		self:killTimer(self.resumeBtTimer[ent.id])

		self.resumeBtTimer[ent.id] = nil
	end

	if self.delayTimer[ent.id] then
		self:killTimer(self.delayTimer[ent.id])

		self.delayTimer[ent.id] = nil
	end

	if not stopBt and not self:isPetEditing(ent.id) then
		AIUtils.resumeBt(ent, AiConst.PauseBtReason.Photo)
	end

	ent:stopCfgAnimation()
	ent:playAnimation(defaultAnim, nil, nil, nil, self:getAnimLayer(ent.id))

	if ent.eventEmitter then
		ent.eventEmitter:emit(EventConst.TOPLOGO_BUBBLE, false)
	end
end

function PhotoFuncPetPoseUIComponent:stopAllPetAction(stopBt)
	for k, ent in pairs(self.petEntities) do
		self:stopPetAction(ent, stopBt)
	end
end

function PhotoFuncPetPoseUIComponent:resetPetAction(ent)
	if not ent then
		return
	end

	if self.resumeBtTimer[ent.id] then
		self:killTimer(self.resumeBtTimer[ent.id])

		self.resumeBtTimer[ent.id] = nil
	end

	if self.delayTimer[ent.id] then
		self:killTimer(self.delayTimer[ent.id])

		self.delayTimer[ent.id] = nil
	end

	local hasPhotoPose = self.curPlayPetPoseAni[ent.id] ~= nil or self.curPlayPetPoseId[ent.id] ~= nil

	self:resumePetBehavior(ent)

	if hasPhotoPose then
		ent:stopAllAnimation()
	end

	if hasPhotoPose or ent.characterState == CharacterStateConst.IDLE then
		ent:stopCfgAnimation()
		ent:playAnimation(defaultAnim, nil, nil, nil, self:getAnimLayer(ent.id))
	end

	self:clearCurPlayingPetAni(ent, true)

	self.curPlayPetPoseId[ent.id] = nil
	self.curPlayPoseAni[ent.id] = nil
	self.nextPetAction[ent.id] = nil
	self.lastPetAction[ent.id] = nil

	for index = #self.needResumeBtEnt, 1, -1 do
		if self.needResumeBtEnt[index].id == ent.id then
			table.remove(self.needResumeBtEnt, index)
		end
	end

	if ent.eventEmitter then
		ent.eventEmitter:emit(EventConst.TOPLOGO_BUBBLE, false)
	end
end

function PhotoFuncPetPoseUIComponent:resetAllPetAction()
	for _, ent in pairs(self.petEntities) do
		self:resetPetAction(ent)
	end
end

function PhotoFuncPetPoseUIComponent:onInputDeviceChanged(deviceType)
	if pg.game.input:isUsingGamepad() then
		if self.listPetModeUList then
			self.listPetModeUList:SetForceInactive(CS.XGUI.ForceInactiveSource.Business, true)
		end
	else
		if self.listPetModeUList then
			self.listPetModeUList:SetForceInactive(CS.XGUI.ForceInactiveSource.Business, false)
		end

		self.listPetModeUList:SelectItem(0)
	end

	if not self.selected then
		return
	end

	if pg.game.input:isUsingGamepad() then
		self:switchViewMode(self.ViewMode.Pet)
	else
		self:switchViewMode(self.ViewMode.Camera)
		self.listPetModeUList:SelectItem(0)
	end
end

function PhotoFuncPetPoseUIComponent:getAnimLayer(id)
	local curPet = pg.me:getCurPetEntity()

	if curPet and curPet.id == id then
		return PlayableConst.AnimationLayer.HUMAN_LAYER_BASE
	end

	return PlayableConst.AnimationLayer.LAYER_FULLBODY
end

return PhotoFuncPetPoseUIComponent
