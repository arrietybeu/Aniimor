-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotographyStudioEdit\\Component\\StudioPlacePetUIComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local StudioPlacePetUIComponent = Class.LightClass("StudioPlacePetUIComponent", UIComponent)
local AddressDataConst = require("Const.AddressDataConst")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local PetData = require("Data.pet_data")
local AppearanceVariableData = require("Data.appearance_variable_data")
local EModelUtils = require("Entities.Utils.EModelUtils")
local HotkeyConst = require("Const.HotkeyConst")
local Time = require("Core.Common.Time")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local GAMEPAD_MOVE_SPEED = 800
local GAMEPAD_ROTATE_SPEED = 120
local GAMEPAD_STICK_DEADZONE = 0.15
local SELECTED_CONTENT_VISIBLE_DURATION = 3
local DEFAULT_SELECTION_RADIUS = 0.4
local MIN_ORNAMENT_SELECTION_SIZE = 0.1

StudioPlacePetUIComponent.DEFAULT_BODY_HEIGHT = 2

function StudioPlacePetUIComponent:onCtor()
	self.curSelectedEntity = nil
	self.rotationMap = {}
	self.quaternion = Quaternion.Euler(0, 0, 0)
	self.isDragging = false
	self.selectionColliderEntities = {}
	self.gamepadStick = Vector2(0, 0)
	self.gamepadDPadLeftHeld = false
	self.gamepadDPadRightHeld = false
	self.gamepadRotateDir = 0
	self.gamepadVirtualCursor = nil
	self.gamepadMoved = false
	self.gamepadRotated = false
end

function StudioPlacePetUIComponent:initView()
	self:ensureUI()
end

function StudioPlacePetUIComponent:ensureUI()
	if self.resObj or self.loadingUI then
		return
	end

	local root = self.ctrl.getPlacePetUIRoot and self.ctrl:getPlacePetUIRoot()

	if IsNil(root) then
		return
	end

	self.loadingUI = true
	self.taskId = self.view:addPrefabWithPathAsync(root, AddressDataConst.PHOTO_PLACE_PET_PREFAB, function(obj)
		self.loadingUI = false

		if IsNil(obj) or IsNil(obj.gameObject) then
			return
		end

		self.resObj = obj.gameObject
		self.resObjRef = self.resObj:GetComponent("ObjectReference")
		self.btnWorldPet = self.resObjRef:GetRefValue("btnWorldPet")
		self.selectedPetUIFollowTrans = self.resObjRef:GetRefValue("selectedPetUIFollowTrans")
		self.objectEditRoot = self.resObjRef:GetRefValue("objectEditRoot")
		self.selectedPetUContainer = self.resObjRef:GetRefValue("selectedPetUContainer")

		local dragAreaUWidget = self.resObjRef:GetRefValue("dragAreaUWidget")

		dragAreaUWidget:SetActive(false)

		local objectReference = self.btnWorldPet:GetComponent("ObjectReference")
		local sliderObjectReference = objectReference:GetRefValue("sliderObjectReference")

		self.rotationSlider = sliderObjectReference:GetRefValue("rotationSlider")

		local btnAntiClock = sliderObjectReference:GetRefValue("btnAntiClock")
		local btnClock = sliderObjectReference:GetRefValue("btnClock")

		function self.rotationSlider.luaValueChanged(value)
			self:onRotate(value)
		end

		function btnClock.luaClick()
			self.rotationSlider.value = self.rotationSlider.value + 90
		end

		function btnAntiClock.luaClick()
			self.rotationSlider.value = self.rotationSlider.value - 90
		end

		self:initGamepad()
		self:initOrnamentEditingModalHotkeys()
		self:updateUIAttach()
		self:restartSelectedContentHideTimer()
		self:setOrnamentEditingModalActive(self.ctrl:isOrnamentEditing())
	end)
end

function StudioPlacePetUIComponent:selectEntity(entity)
	if entity and self.ctrl.canOperateStudioEntity and not self.ctrl:canOperateStudioEntity(entity) then
		return
	end

	self:resetGamepadInput(true)

	self.curSelectedEntity = entity

	if entity then
		self:ensureUI()

		if self.rotationMap[entity.id] == nil and entity.eModel then
			local _, rotationY = entity.eModel:GetPositionAgentLocalEulerEx()

			self.rotationMap[entity.id] = rotationY
		end

		if self.rotationSlider and NotNil(self.rotationSlider) then
			self.rotationSlider:SetValueWithoutCallback(self.rotationMap[entity.id] or 0)
		end
	end

	self:updateUIAttach()
	self:restartSelectedContentHideTimer()
end

function StudioPlacePetUIComponent:stopSelectedContentHideTimer()
	if self.selectedContentHideTimer then
		self:killTimer(self.selectedContentHideTimer)

		self.selectedContentHideTimer = nil
	end
end

function StudioPlacePetUIComponent:restartSelectedContentHideTimer()
	self:stopSelectedContentHideTimer()

	if not self.curSelectedEntity or not self.resObj then
		return
	end

	if not self.selectedPetUContainer:CheckURLLoaded() then
		if self.selectedContentLoading then
			return
		end

		self.selectedContentLoading = true

		self.selectedPetUContainer:LoadDefaultUrlManually(function(content)
			self.selectedContentLoading = false

			if IsNil(content) or not self.curSelectedEntity or not self.resObj then
				return
			end

			self:restartSelectedContentHideTimer()
		end)

		return
	end

	local content = self.selectedPetUContainer.content

	content:SetActive(true)

	local timerId

	timerId = self:startTimer(function()
		if self.selectedContentHideTimer ~= timerId then
			return
		end

		self.selectedContentHideTimer = nil

		if self.curSelectedEntity then
			content:SetActive(false)
		end
	end, SELECTED_CONTENT_VISIBLE_DURATION)
	self.selectedContentHideTimer = timerId
end

function StudioPlacePetUIComponent:refreshHotspots()
	local entities = self.ctrl.getStudioSelectableEntities and self.ctrl:getStudioSelectableEntities()
	local alive = {}

	if entities then
		for _, entity in ipairs(entities) do
			local operable = self.ctrl.canOperateStudioEntity and self.ctrl:canOperateStudioEntity(entity)

			if operable and entity.eModel and entity.actorId then
				alive[entity.id] = true
				self.selectionColliderEntities[entity.id] = entity

				self:ensureSelectionCollider(entity)
			end
		end
	end

	for entityId, entity in pairs(self.selectionColliderEntities) do
		if not alive[entityId] then
			self:removeSelectionCollider(entity)

			self.selectionColliderEntities[entityId] = nil
		end
	end
end

function StudioPlacePetUIComponent:ensureSelectionCollider(entity)
	if not entity:hasEModelComponent(Const.COMPONENT_IDX_PHYSX) then
		return false
	end

	entity.eModel:SetTag(Const.COMPONENT_IDX_PHYSX, Const.TAG_ACTOR, entity.actorId, 0)

	if entity.studioOrnamentId then
		entity.studioSelectionEnabled = true

		if entity.eModel.isModelLoaded ~= true then
			return false
		end

		return entity.eModel:EnsureStudioSelectionBoxFromModelBounds(Const.COMPONENT_IDX_PHYSX, MIN_ORNAMENT_SELECTION_SIZE)
	end

	local configData = entity.getConfigData and entity:getConfigData()
	local height = self:getBodyHeight(entity)
	local radius = configData and tonumber(configData.bodySize) or DEFAULT_SELECTION_RADIUS

	radius = math.min(radius, height * 0.5)

	entity.eModel:EnsureStudioSelectionCapsule(Const.COMPONENT_IDX_PHYSX, radius, height, Vector3(0, height * 0.5, 0))

	return true
end

function StudioPlacePetUIComponent:removeSelectionCollider(entity)
	if entity then
		entity.studioSelectionEnabled = false
	end

	if entity and entity.eModel and entity:hasEModelComponent(Const.COMPONENT_IDX_PHYSX) then
		entity.eModel:RemoveStudioSelectionCollider(Const.COMPONENT_IDX_PHYSX)
	end
end

function StudioPlacePetUIComponent:selectEntityAtScreenPosition(screenPosition)
	local camera = self.ctrl.getStudioCamera and self.ctrl:getStudioCamera()

	if IsNil(camera) then
		return false
	end

	local selectionLayerMask = bit.lshift(1, ClientConst.LayerDefine.LAYER_NO_COLLISION)
	local csEntity = pg.global.physicsMgr:GetRaycastEntityFromScreenPoint(camera, screenPosition, selectionLayerMask)

	if IsNil(csEntity) then
		return false
	end

	local entity = self.selectionColliderEntities[csEntity.id]

	if not entity then
		return false
	end

	if self.ctrl.canOperateStudioEntity and not self.ctrl:canOperateStudioEntity(entity) then
		return false
	end

	if self.ctrl.selectStudioEntity then
		self.ctrl:selectStudioEntity(entity)
	else
		self:selectEntity(entity)
	end

	if NotNil(self.resObj) then
		self.resObj.transform:SetAsLastSibling()
	end

	return true
end

function StudioPlacePetUIComponent:getSelectedEntity()
	return self.curSelectedEntity
end

function StudioPlacePetUIComponent:canGamepadEditEntity()
	if not pg.game.input:isUsingGamepad() or not self.ctrl.cameraControlEnabled then
		return false
	end

	local menu = self.ctrl.funcMenu

	if not menu or not menu:isMenuRaised() then
		return false
	end

	local entity = self.curSelectedEntity

	if not entity or not entity.eModel then
		return false
	end

	if self.ctrl.canOperateStudioEntity and not self.ctrl:canOperateStudioEntity(entity) then
		return false
	end

	if entity.studioOrnamentId then
		return menu.curSelectTab == menu.Funcs.Ornament and self.ctrl.isOrnamentEditing and self.ctrl:isOrnamentEditing()
	end

	if entity.isPet and entity:isPet() then
		return menu.curSelectTab == menu.Funcs.PetPose
	end

	return menu.curSelectTab == menu.Funcs.PlayerPose
end

function StudioPlacePetUIComponent:initGamepad()
	if self.gamepadBindings then
		return
	end

	self.gamepadBindings = {}
	self.defaultGamepadBindings = {}
	self.ornamentGamepadBindings = {}

	local function bindEditingInput(root, nameSuffix, isOrnamentModal)
		local stateBindings = isOrnamentModal and self.ornamentGamepadBindings or self.defaultGamepadBindings
		local stickBind = KeyBindingPro.GetOrAddKeyBindingByName(root, "StudioEntityRightStick" .. nameSuffix)

		stickBind.isVirtual = true
		stickBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRightStickMove
		stickBind.enabled = not isOrnamentModal

		function stickBind.luaTrigger(inputInfo)
			if self.ctrl:isOrnamentEditing() ~= isOrnamentModal then
				return
			end

			if not self:canGamepadEditEntity() then
				self:resetGamepadInput(true)

				return
			end

			if inputInfo.phase == "Performed" then
				self.gamepadStick = Vector2(inputInfo.valueVec2.x, inputInfo.valueVec2.y)
			else
				self.gamepadStick = Vector2(0, 0)
			end
		end

		table.insert(self.gamepadBindings, stickBind)
		table.insert(stateBindings, stickBind)

		local dpadLeftBind = KeyBindingPro.GetOrAddKeyBindingByName(root, "StudioEntityDPadLeft" .. nameSuffix)

		dpadLeftBind.isVirtual = true
		dpadLeftBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadDPadLeft
		dpadLeftBind.enabled = not isOrnamentModal

		function dpadLeftBind.luaTrigger(inputInfo)
			if self.ctrl:isOrnamentEditing() ~= isOrnamentModal then
				return
			end

			if not self:canGamepadEditEntity() then
				self:resetGamepadInput(true)

				return
			end

			self.gamepadDPadLeftHeld = inputInfo.phase == "Performed" and inputInfo.isPressed == true

			self:refreshGamepadRotateDir()
		end

		table.insert(self.gamepadBindings, dpadLeftBind)
		table.insert(stateBindings, dpadLeftBind)

		local dpadRightBind = KeyBindingPro.GetOrAddKeyBindingByName(root, "StudioEntityDPadRight" .. nameSuffix)

		dpadRightBind.isVirtual = true
		dpadRightBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadDPadRight
		dpadRightBind.enabled = not isOrnamentModal

		function dpadRightBind.luaTrigger(inputInfo)
			if self.ctrl:isOrnamentEditing() ~= isOrnamentModal then
				return
			end

			if not self:canGamepadEditEntity() then
				self:resetGamepadInput(true)

				return
			end

			self.gamepadDPadRightHeld = inputInfo.phase == "Performed" and inputInfo.isPressed == true

			self:refreshGamepadRotateDir()
		end

		table.insert(self.gamepadBindings, dpadRightBind)
		table.insert(stateBindings, dpadRightBind)
	end

	bindEditingInput(self.ctrl.view.transform.gameObject, "", false)
	bindEditingInput(self.btnWorldPet.gameObject, "OrnamentModal", true)

	self.gamepadTickTimer = self:startTimer(function()
		self:gamepadTick()
	end, 0, true)
end

function StudioPlacePetUIComponent:initOrnamentEditingModalHotkeys()
	if self.ornamentEditingModalHotkeysBound then
		return
	end

	self.ornamentEditingModalHotkeysBound = true

	local root = self.btnWorldPet.gameObject

	self.ctrl:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadCancel, function()
		if not pg.game.input:isUsingGamepad() or not self.ctrl:isOrnamentEditing() then
			return false
		end

		self.ctrl:exitOrnamentEdit(true)

		return true
	end, root, "StudioOrnamentModalCancel")
end

function StudioPlacePetUIComponent:setOrnamentEditingModalActive(active)
	self.ornamentEditingModalActive = active == true

	self:resetGamepadInput(true)

	for _, binding in ipairs(self.defaultGamepadBindings or EMPTY_TABLE) do
		binding.enabled = not self.ornamentEditingModalActive
	end

	for _, binding in ipairs(self.ornamentGamepadBindings or EMPTY_TABLE) do
		binding.enabled = self.ornamentEditingModalActive
	end

	if IsNil(self.btnWorldPet) then
		return
	end

	if self.ornamentEditingModalActive then
		pg.global.navMgr:FocusItem(self.btnWorldPet)
	elseif self.btnWorldPet.isNavFocused then
		pg.global.navMgr:ClearFocus()
	end
end

function StudioPlacePetUIComponent:refreshGamepadRotateDir()
	self.gamepadRotateDir = (self.gamepadDPadLeftHeld and 1 or 0) - (self.gamepadDPadRightHeld and 1 or 0)

	if self.gamepadRotateDir == 0 then
		self:finishGamepadRotate()
	end
end

function StudioPlacePetUIComponent:finishGamepadMove()
	if self.gamepadMoved and self.ctrl.recordStudioHistoryStep then
		self.ctrl:recordStudioHistoryStep("entity_move")
	end

	self.gamepadMoved = false
end

function StudioPlacePetUIComponent:finishGamepadRotate()
	if self.gamepadRotated and self.ctrl.flushPendingHistoryStep then
		self.ctrl:flushPendingHistoryStep()
	end

	self.gamepadRotated = false
end

function StudioPlacePetUIComponent:resetGamepadInput(recordHistory)
	if recordHistory then
		self:finishGamepadMove()
		self:finishGamepadRotate()
	else
		self.gamepadMoved = false
		self.gamepadRotated = false
	end

	self.gamepadStick = Vector2(0, 0)
	self.gamepadDPadLeftHeld = false
	self.gamepadDPadRightHeld = false
	self.gamepadRotateDir = 0
	self.gamepadVirtualCursor = nil
	self.gamepadPlaneY = nil
	self.gamepadLocalY = nil
end

function StudioPlacePetUIComponent:hasGamepadInput()
	return self.gamepadStick.x ~= 0 or self.gamepadStick.y ~= 0 or self.gamepadDPadLeftHeld or self.gamepadDPadRightHeld or self.gamepadMoved or self.gamepadRotated or self.gamepadVirtualCursor ~= nil
end

function StudioPlacePetUIComponent:gamepadTick()
	if not self:canGamepadEditEntity() then
		if self:hasGamepadInput() then
			self:resetGamepadInput(true)
		end

		return
	end

	local entity = self.curSelectedEntity
	local deltaTime = Time.unscaledDeltaTime
	local stickX, stickY = self.gamepadStick.x, self.gamepadStick.y

	if math.abs(stickX) > GAMEPAD_STICK_DEADZONE or math.abs(stickY) > GAMEPAD_STICK_DEADZONE then
		if not self.gamepadVirtualCursor then
			local x, y, z = entity.eModel:GetPositionAgentPosEx()
			local screenPos = UIUtils.GetPositionScreenPoint(Vector3(x, y, z))

			self.gamepadVirtualCursor = Vector2(screenPos.x, screenPos.y)
			self.gamepadPlaneY = y

			local root = self.ctrl:getStudioEntityRoot()
			local localPos = root:InverseTransformPoint(Vector3(x, y, z))

			self.gamepadLocalY = localPos.y
		end

		self.gamepadVirtualCursor = Vector2(self.gamepadVirtualCursor.x + stickX * GAMEPAD_MOVE_SPEED * deltaTime, self.gamepadVirtualCursor.y + stickY * GAMEPAD_MOVE_SPEED * deltaTime)

		if self:moveSelectedEntityToScreenPos(self.gamepadVirtualCursor, self.gamepadPlaneY, self.gamepadLocalY) then
			self.gamepadMoved = true
		end
	else
		self:finishGamepadMove()

		self.gamepadVirtualCursor = nil
		self.gamepadPlaneY = nil
		self.gamepadLocalY = nil
	end

	if self.gamepadRotateDir ~= 0 then
		local value = (self.rotationMap[entity.id] or 0) + self.gamepadRotateDir * GAMEPAD_ROTATE_SPEED * deltaTime

		value = value % 360

		self:onRotate(value)

		self.gamepadRotated = true

		if self.rotationSlider and NotNil(self.rotationSlider) then
			self.rotationSlider:SetValueWithoutCallback(value)
		end
	end
end

function StudioPlacePetUIComponent:updateUIAttach()
	if IsNil(self.resObj) then
		return
	end

	local entity = self.curSelectedEntity

	if not entity or not entity.eModel or not entity.actorId then
		self.resObj:SetActiveEx(false)

		return
	end

	if pg.game.input:isUsingGamepad() and entity.studioOrnamentId and self.ctrl.isOrnamentEditing and not self.ctrl:isOrnamentEditing() then
		self.resObj:SetActiveEx(false)

		return
	end

	self.resObj:SetActiveEx(true)
	self.objectEditRoot:AttachToTransByActorId(entity.actorId)
	self.selectedPetUIFollowTrans:AttachToTransByActorId(entity.actorId)
	self.selectedPetUIFollowTrans:SmoothHeightTo(self:getBodyHeight(entity), 0)
end

function StudioPlacePetUIComponent:refreshSelectedEntityUI()
	self:resetGamepadInput(true)
	self:updateUIAttach()
	self:restartSelectedContentHideTimer()
end

function StudioPlacePetUIComponent:getBodyHeight(entity)
	if entity.isPet and entity:isPet() and entity.templateId then
		local petData = PetData[entity.templateId]

		if petData and petData.bodyHeight then
			return petData.bodyHeight
		end
	end

	return self.DEFAULT_BODY_HEIGHT
end

function StudioPlacePetUIComponent:onDragStart(screenPos)
	if not self.curSelectedEntity or not self.curSelectedEntity.eModel then
		return false
	end

	self.isDragging = true

	local x, y, z = self.curSelectedEntity.eModel:GetPositionAgentPosEx()
	local unitScreen = UIUtils.GetPositionScreenPoint(Vector3(x, y, z))

	self.dragPositionDiff = screenPos - Vector2(unitScreen.x, unitScreen.y)
	self.dragPlaneY = y

	local root = self.ctrl.getStudioEntityRoot and self.ctrl:getStudioEntityRoot()

	if NotNil(root) then
		local localStart = root:InverseTransformPoint(Vector3(x, y, z))

		self.dragLocalY = localStart.y
	end

	return true
end

function StudioPlacePetUIComponent:onDragUpdate(screenPos)
	if not self.isDragging or not self.curSelectedEntity then
		return
	end

	local target = screenPos - self.dragPositionDiff

	self:moveSelectedEntityToScreenPos(target, self.dragPlaneY, self.dragLocalY)
end

function StudioPlacePetUIComponent:moveSelectedEntityToScreenPos(screenPos, planeY, localY)
	local camera = self.ctrl.getStudioCamera and self.ctrl:getStudioCamera()
	local mode = self.ctrl.getStudioFreeCameraMode and self.ctrl:getStudioFreeCameraMode()
	local root = self.ctrl.getStudioEntityRoot and self.ctrl:getStudioEntityRoot()

	if IsNil(camera) or not mode or IsNil(root) then
		return false
	end

	local valid, worldPos = mode:getPlanePos(camera, screenPos, planeY)

	if not valid then
		return false
	end

	local targetLocalPos = root:InverseTransformPoint(Vector3(worldPos.x, planeY, worldPos.z))
	local lx, lz = targetLocalPos.x, targetLocalPos.z
	local distSq = lx * lx + lz * lz
	local r = AppearanceVariableData.STUDIO_CHARACTER_ADJUST

	if distSq > r * r then
		local s = r / math.sqrt(distSq)

		lx, lz = lx * s, lz * s
	end

	self.curSelectedEntity:setPositionAgentLocalPos(lx, localY or targetLocalPos.y, lz)

	return true
end

function StudioPlacePetUIComponent:onDragEnd(_)
	self.dragPositionDiff = nil
	self.isDragging = false

	if self.ctrl and self.ctrl.recordStudioHistoryStep then
		self.ctrl:recordStudioHistoryStep("entity_move")
	end
end

function StudioPlacePetUIComponent:onRotate(value)
	if not self.curSelectedEntity then
		return
	end

	self.quaternion:SetEuler(0, value, 0)
	EModelUtils.setAgentRotation(self.curSelectedEntity, self.quaternion)

	self.rotationMap[self.curSelectedEntity.id] = value

	if self.ctrl and self.ctrl.scheduleStudioHistoryStep then
		self.ctrl:scheduleStudioHistoryStep("entity_rotate", 0.2)
	end
end

function StudioPlacePetUIComponent:showUI(show)
	if NotNil(self.resObj) then
		self.resObj:SetActiveEx(show)
	end
end

function StudioPlacePetUIComponent:onDestroy()
	self:resetGamepadInput(false)
	self:stopSelectedContentHideTimer()

	if self.gamepadBindings then
		for _, binding in ipairs(self.gamepadBindings) do
			binding.luaTrigger = nil
		end

		self.gamepadBindings = nil
		self.defaultGamepadBindings = nil
		self.ornamentGamepadBindings = nil
	end

	if self.taskId then
		self.view:cancelUIAsyncTask(self.taskId)

		self.taskId = nil
	end

	if self.resObj and self.view:checkInstanceExists(self.resObj) then
		self.view:destroyInstance(self.resObj)
	end

	for entityId, entity in pairs(self.selectionColliderEntities) do
		self:removeSelectionCollider(entity)

		self.selectionColliderEntities[entityId] = nil
	end

	self.selectionColliderEntities = {}
	self.resObj = nil
	self.rotationSlider = nil
	self.curSelectedEntity = nil
	self.rotationMap = {}
end

return StudioPlacePetUIComponent
