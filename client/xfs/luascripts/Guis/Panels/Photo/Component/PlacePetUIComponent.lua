-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Photo\\Component\\PlacePetUIComponent.lua

local ClientUtils = require("Utils.ClientUtils")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PlacePetUIComponent = Class.LightClass("PlacePetUIComponent", UIComponent)
local AddressDataConst = require("Const.AddressDataConst")
local ClientVirtualEntityUtils = require("Utils.ClientVirtualEntityUtils")
local PetData = require("Data.pet_data")
local Utils = require("Common.Utils.Utils")
local ClientConst = require("Const.ClientConst")
local HotkeyConst = require("Const.HotkeyConst")
local Time = require("Core.Common.Time")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local EModelUtils = require("Entities.Utils.EModelUtils")
local GAMEPAD_MOVE_SPEED = 800
local GAMEPAD_ROTATE_SPEED = 120
local GAMEPAD_STICK_DEADZONE = 0.15

function PlacePetUIComponent:ctor(ctrl, trans)
	UIComponent.ctor(self, ctrl, trans)

	self.petEntity = {}
	self.entityMap = {}
	self.virtualToRealIdMap = {}
	self.visibleMap = {}
	self.rotationMap = {}
	self.curPet = pg.me:getCurPetEntity()
	self.quaternion = Quaternion.Euler(0, 0, 0)
	self.longPressTime = 0
	self.gamepadStick = Vector2(0, 0)
	self.gamepadDPadLeftHeld = false
	self.gamepadDPadRightHeld = false
	self.gamepadRotateDir = 0
	self.gamepadVirtualCursor = nil

	if self.curPet then
		self.petEntity[self.curPet.id] = self.curPet
		self.entityMap[self.curPet.id] = self.curPet
		self.visibleMap[self.curPet.id] = true
		self.virtualToRealIdMap[self.curPet.id] = self.curPet.id
	end

	self:initGamepad()
end

function PlacePetUIComponent:selectPetEntity(petId, showUI)
	if showUI == nil then
		showUI = true
	end

	if self.resObj == nil then
		if self.taskId then
			self.view:cancelUIAsyncTask(self.taskId)
		end

		self.taskId = self.view:addPrefabWithPathAsync(self.ctrl.petUIRoot, AddressDataConst.PHOTO_PLACE_PET_PREFAB, function(obj)
			self.resObj = obj.gameObject
			self.resObjRef = self.resObj:GetComponent("ObjectReference")
			self.btnWorldPet = self.resObjRef:GetRefValue("btnWorldPet")
			self.selectedPetUIFollowTrans = self.resObjRef:GetRefValue("selectedPetUIFollowTrans")
			self.objectEditRoot = self.resObjRef:GetRefValue("objectEditRoot")

			local objectReference = self.btnWorldPet:GetComponent("ObjectReference")
			local dragArea = objectReference:GetRefValue("dragArea")
			local sliderObjectReference = objectReference:GetRefValue("sliderObjectReference")

			self.rotationSlider = sliderObjectReference:GetRefValue("rotationSlider")

			local btnAntiClock = sliderObjectReference:GetRefValue("btnAntiClock")
			local btnClock = sliderObjectReference:GetRefValue("btnClock")

			function dragArea.luaBeginDrag(screenPos)
				self:onDragPetStart(screenPos)
			end

			function dragArea.luaDrag(screenPos)
				self:onDragPetUpdate(screenPos)
			end

			function dragArea.luaEndDrag(screenPos)
				self:onDragPetEnd(screenPos)
			end

			function self.rotationSlider.luaValueChanged(value)
				self:onRotatePet(value)
			end

			function btnClock.luaClick()
				if self.longPressTime and self.longPressTime > 0 then
					return
				end

				self.rotationSlider.value = self.rotationSlider.value + 90
			end

			function btnAntiClock.luaClick()
				if self.longPressTime and self.longPressTime > 0 then
					return
				end

				self.rotationSlider.value = self.rotationSlider.value - 90
			end

			if showUI then
				self:updateUIAttach()
			else
				self:showUI(false)
			end
		end)
	end

	self.curSelectedPetEntity = self:createPet(petId)
	self.curSelectedPetId = petId

	if self.resObj and self.rotationSlider then
		self.rotationSlider.value = self.rotationMap[self.curSelectedPetEntity.id] or 0
	end

	self:updateUIAttach()
	self:refreshCanMovePetState()

	return self.curSelectedPetEntity
end

function PlacePetUIComponent:createPet(petId)
	if self.petEntity[petId] == nil then
		local entity = ClientVirtualEntityUtils.createPhotoPetVirtualEntityWithPetId(petId)

		self.petEntity[petId] = entity
		self.entityMap[entity.id] = entity
		self.visibleMap[petId] = true

		EModelUtils.setAgentPositionAndRotation(entity, self:getOriPetPos(), Quaternion.identity)

		self.rotationMap[entity.id] = 0
		self.virtualToRealIdMap[entity.id] = petId
	end

	return self.petEntity[petId]
end

function PlacePetUIComponent:updateUIAttach()
	if self.resObj and self.curSelectedPetEntity and self.visibleMap[self.curSelectedPetId] then
		self.resObj:SetActiveEx(true)
		self.objectEditRoot:AttachToTransByActorId(self.curSelectedPetEntity.actorId)

		local petInfo = pg.me:getPetInfo(self.curSelectedPetId)
		local templateId = petInfo.templateId
		local petData = PetData[templateId]

		self.selectedPetUIFollowTrans:AttachToTransByActorId(self.curSelectedPetEntity.actorId)
		self.selectedPetUIFollowTrans:SmoothHeightTo(petData.bodyHeight, 0)
	elseif self.resObj then
		self.resObj:SetActiveEx(false)
	end
end

function PlacePetUIComponent:onDragPetStart(screenPos)
	if not self.curSelectedPetEntity then
		return
	end

	self.isDragging = true

	local startDragTemplatePos = self.curSelectedPetEntity:getPosition()
	local templateScreenPosVec3 = UIUtils.GetPositionScreenPoint(startDragTemplatePos)
	local templateScreenPos = Vector2(templateScreenPosVec3.x, templateScreenPosVec3.y)

	self.dragPositionDiff = screenPos - templateScreenPos

	self.ctrl:setPetEditMap(self.curSelectedPetEntity.id)
end

function PlacePetUIComponent:onDragPetUpdate(screenPos)
	if not self.curSelectedPetEntity then
		return
	end

	if self.isDragging then
		screenPos = screenPos - self.dragPositionDiff

		local valid, newWorldPos, layer = pg.game.camera.photoCameraMode.cameraMode:GetPlacePetPos(screenPos)

		if not Utils.checkCanSwim(self.curSelectedPetEntity) and layer == ClientConst.LayerDefine.LAYER_WATER then
			print("can not place this pet in water")
		end

		if valid then
			EModelUtils.setAgentPosition(self.curSelectedPetEntity, newWorldPos)
		end
	end
end

function PlacePetUIComponent:onDragPetEnd(screenPos)
	self.dragPositionDiff = nil
	self.isDragging = false
end

function PlacePetUIComponent:onRotatePet(value)
	if self.curSelectedPetEntity then
		self.quaternion:SetEuler(0, value, 0)
		EModelUtils.setAgentRotation(self.curSelectedPetEntity, self.quaternion)

		self.rotationMap[self.curSelectedPetEntity.id] = value

		self.ctrl:setPetEditMap(self.curSelectedPetEntity.id)
	end
end

function PlacePetUIComponent:canMovePet()
	local petPose = self.ctrl

	if not petPose or not petPose.selected then
		return false
	end

	if petPose.curViewMode ~= petPose.ViewMode.Pet then
		return false
	end

	if not self.curSelectedPetEntity then
		return false
	end

	if not self.visibleMap[self.curSelectedPetId] then
		return false
	end

	return true
end

function PlacePetUIComponent:refreshCanMovePetState()
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("CanMovePet", self:canMovePet())
end

function PlacePetUIComponent:initGamepad()
	local root = self.ctrl.transform.gameObject
	local stickBind = KeyBindingPro.GetOrAddKeyBindingByName(root, "PhotoPet_RightStick")

	stickBind.isVirtual = true
	stickBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRightStickMove

	function stickBind.luaTrigger(inputInfo)
		if not self:canMovePet() then
			self.gamepadStick = Vector2(0, 0)

			return
		end

		if inputInfo.phase == "Performed" then
			self.gamepadStick = Vector2(inputInfo.valueVec2.x, inputInfo.valueVec2.y)
		else
			self.gamepadStick = Vector2(0, 0)
		end
	end

	local dpadLeftBind = KeyBindingPro.GetOrAddKeyBindingByName(root, "PhotoPet_DPadLeft")

	dpadLeftBind.isVirtual = true
	dpadLeftBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadDPadLeft

	function dpadLeftBind.luaTrigger(inputInfo)
		if not self:canMovePet() then
			self.gamepadDPadLeftHeld = false
			self.gamepadRotateDir = (self.gamepadDPadLeftHeld and 1 or 0) - (self.gamepadDPadRightHeld and 1 or 0)

			return
		end

		self.gamepadDPadLeftHeld = inputInfo.phase == "Performed" and inputInfo.isPressed == true
		self.gamepadRotateDir = (self.gamepadDPadLeftHeld and 1 or 0) - (self.gamepadDPadRightHeld and 1 or 0)
	end

	local dpadRightBind = KeyBindingPro.GetOrAddKeyBindingByName(root, "PhotoPet_DPadRight")

	dpadRightBind.isVirtual = true
	dpadRightBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadDPadRight

	function dpadRightBind.luaTrigger(inputInfo)
		if not self:canMovePet() then
			self.gamepadDPadRightHeld = false
			self.gamepadRotateDir = (self.gamepadDPadLeftHeld and 1 or 0) - (self.gamepadDPadRightHeld and 1 or 0)

			return
		end

		self.gamepadDPadRightHeld = inputInfo.phase == "Performed" and inputInfo.isPressed == true
		self.gamepadRotateDir = (self.gamepadDPadLeftHeld and 1 or 0) - (self.gamepadDPadRightHeld and 1 or 0)
	end

	self.gamepadTickTimer = self:startTimer(function()
		self:gamepadTick()
	end, 0, true)

	self:refreshCanMovePetState()
end

function PlacePetUIComponent:gamepadTick()
	if not self:canMovePet() then
		self.gamepadVirtualCursor = nil

		return
	end

	local dt = Time.deltaTime
	local ent = self.curSelectedPetEntity
	local sx, sy = self.gamepadStick.x, self.gamepadStick.y

	if math.abs(sx) > GAMEPAD_STICK_DEADZONE or math.abs(sy) > GAMEPAD_STICK_DEADZONE then
		if not self.gamepadVirtualCursor then
			local curScreen = UIUtils.GetPositionScreenPoint(ent:getPosition())

			self.gamepadVirtualCursor = Vector2(curScreen.x, curScreen.y)
		end

		self.gamepadVirtualCursor = Vector2(self.gamepadVirtualCursor.x + sx * GAMEPAD_MOVE_SPEED * dt, self.gamepadVirtualCursor.y + sy * GAMEPAD_MOVE_SPEED * dt)

		local valid, newWorldPos, layer = pg.game.camera.photoCameraMode.cameraMode:GetPlacePetPos(self.gamepadVirtualCursor)
		local swimBlocked = not Utils.checkCanSwim(ent) and layer == ClientConst.LayerDefine.LAYER_WATER

		if valid and not swimBlocked then
			EModelUtils.setAgentPosition(ent, newWorldPos)
			self.ctrl:setPetEditMap(ent.id)
		end
	else
		self.gamepadVirtualCursor = nil
	end

	if self.gamepadRotateDir ~= 0 then
		local cur = self.rotationMap[ent.id] or 0
		local newValue = (cur + self.gamepadRotateDir * GAMEPAD_ROTATE_SPEED * dt) % 360

		self.quaternion:SetEuler(0, newValue, 0)
		EModelUtils.setAgentRotation(ent, self.quaternion)

		self.rotationMap[ent.id] = newValue

		if self.rotationSlider and NotNil(self.rotationSlider) then
			self.rotationSlider:SetValueWithoutCallback(newValue)
		end

		self.ctrl:setPetEditMap(ent.id)
	end
end

function PlacePetUIComponent:setPetVisible(entityId, isVisible)
	local entity = self.petEntity[entityId] or self.entityMap[entityId]

	if entity then
		entity:setVisible(ClientConst.MODEL_VISIBLE_KEY.DEFAULT, isVisible)
	end

	if isVisible then
		if self.curSelectedPetEntity == nil then
			self.curSelectedPetEntity = entity

			EModelUtils.setAgentPositionAndRotation(entity, self:getOriPetPos(), Quaternion.identity)
		end
	elseif self.curSelectedPetEntity == entity then
		self.curSelectedPetEntity = nil
	end

	self.visibleMap[entityId] = isVisible

	self:updateUIAttach()
	self:refreshCanMovePetState()
end

function PlacePetUIComponent:getOriPetPos()
	local screenCenter = Vector2(Screen.width * 0.5, Screen.height * 0.5)
	local valid, pos = pg.game.camera.photoCameraMode.cameraMode:GetPlacePetPos(screenCenter)

	if not valid then
		local screenBottom = Vector2(Screen.width * 0.5, 0)

		valid, pos = pg.game.camera.photoCameraMode.cameraMode:GetPlacePetPos(screenBottom)

		if not valid then
			valid, pos = pg.game.camera.photoCameraMode.cameraMode:GetCameraBottomPos()

			if not valid then
				pos = pg.me:getPosition() + Vector3.forward
			end
		end
	end

	return pos
end

function PlacePetUIComponent:getPetEntity(petId)
	return self.petEntity[petId] or self.entityMap[petId]
end

function PlacePetUIComponent:onPageChange(enter)
	if enter then
		self:updateUIAttach()
	elseif NotNil(self.resObj) then
		self.resObj:SetActiveEx(false)
	end

	self:refreshCanMovePetState()
end

function PlacePetUIComponent:showUI(show)
	if NotNil(self.resObj) then
		self.resObj:SetActiveEx(show)
	end
end

function PlacePetUIComponent:getRealEntityId(virtualId)
	return self.virtualToRealIdMap[virtualId]
end

function PlacePetUIComponent:destroy()
	if self.gamepadTickTimer then
		self:killTimer(self.gamepadTickTimer)

		self.gamepadTickTimer = nil
	end

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("CanMovePet", false)

	if self.taskId then
		self.view:cancelUIAsyncTask(self.taskId)
	end

	if self.resObj and self.view:checkInstanceExists(self.resObj) then
		self.view:destroyInstance(self.resObj)
	end

	for k, v in pairs(self.petEntity) do
		if self.curPet ~= v then
			ClientUtils.safeDestroy(v)
		end
	end

	if self.curPet then
		self.curPet:setVisible(ClientConst.MODEL_VISIBLE_KEY.DEFAULT, true)
	end

	self.petEntity = {}
	self.visibleMap = {}
	self.mapAreaUImages = nil
	self.resObj = nil
	self.rotationSlider = nil
end

return PlacePetUIComponent
