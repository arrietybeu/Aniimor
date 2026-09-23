-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Photo\\Component\\LockModelUIComponent.lua

local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local CombatActionTool = require("Common.Ability.CombatActionTool")
local UIConst = require("Const.UIConst")
local SysConfigData = require("Data.sys_config_data")
local PuppetData = require("Data.puppet_data")
local UIComponent = require("Guis.Helper.UIComponent")
local LockModelUIComponent = Class.LightClass("LockModelUIComponent", UIComponent)
local lshift = bit.lshift
local bor = bit.bor
local ClientConst = require("Const.ClientConst")
local EventConst = require("Const.EventConst")
local LuaUIUtils = require("Utils.LuaUIUtils")

LockModelUIComponent.LockState = {
	None = 0,
	Lock = 2,
	AutoLock = 1
}

function LockModelUIComponent:findObjects()
	self.objectReference = self.view.focusTransform:GetComponent("ObjectReference")
	self.photographAimUComponent = self.objectReference:GetRefValue("photographAimUComponent")
	self.lockWidgetAnimation = self.objectReference:GetRefValue("lockWidgetAnimation")
end

function LockModelUIComponent:initView()
	self.showTopLogoEntitys = {}
	self.openLock = false
	self.maxLockDist = SysConfigData.PHOTO_LOCK_DISTANCE
	self.checkHeight = self.ctrl.photoMode == self.ctrl.ModeType.PHOTO_IDENTIFY and 0.8 or 0.2
	self.lockLayerMask = bor(lshift(1, ClientConst.LayerDefine.LAYER_GROUND), lshift(1, ClientConst.LayerDefine.LAYER_WALL), lshift(1, ClientConst.LayerDefine.LAYER_DEFAULT))
	self.curLockedEntity = nil
	self.startTriggerPressTime = 0.25
	self.longPressDuration = 0.55
	self.lockEntityInAni = "VX_Node_Photograph_CameraAim_In"
	self.lockEntityLoopAni = "VX_Node_Photograph_CameraAim_Loop"
	self.lockEntityOutAni = "VX_Node_Photograph_CameraAim_Out"

	self.view.rootComponent:TryChangePage("Locking", 1)

	function self.view.btnUnLockedUButton.luaClick()
		self:openLockModel()
	end

	function self.view.btnLockedUButton.luaClick()
		self:closeLockModel()
	end

	function self.view.btnSwitchUButton.luaClick()
		self:switchLockTarget()
	end

	function self.view.btnScanUButton.luaClick()
		self:tryIdentifyLockEntity()
	end

	self.ctrl:bindHotKey("Photo/SwitchLockModel", function()
		self:openLockModel()
	end, function(timer)
		if timer >= self.longPressDuration then
			self:closeLockModel()
		end
	end, nil, {
		startTriggerPressTime = self.startTriggerPressTime
	})
	self:bindHotKey("Photo/Space", function()
		self.view.btnScanUButton.luaClick()
	end, nil, self.view.btnScanUButton.gameObject)

	if self.ctrl.photoMode == self.ctrl.ModeType.PHOTO_IDENTIFY then
		pg.game.camera.photoCameraMode.cameraMode.boundRect = CS.UnityEngine.Rect(0.2, 0.2, 0.6, 0.6)
	else
		pg.game.camera.photoCameraMode.cameraMode.boundRect = CS.UnityEngine.Rect(0.21, 0.25, 0.58, 0.5)
	end

	self:startTimer(function()
		self:update()
	end, 1, true)
	self:update()
end

function LockModelUIComponent:update()
	if self.curLockedEntity then
		local cameraPos = self.ctrl:checkIsNormalOrSelfie() and pg.game.camera.photoCameraMode.cameraMode:GetPivotLocation() or pg.game.camera.playerCameraMode.cameraMode:GetPivotLocation()
		local entPos = self.curLockedEntity:getPosition()
		local dist = Utils.distance(entPos, cameraPos)

		if dist > self.maxLockDist or pgUtils.IsBlocked(cameraPos, Vector3(entPos.x, entPos.y + self.checkHeight, entPos.z), dist, self.lockLayerMask) then
			self.curLockedEntity = nil

			pg.game.camera.photoCameraMode:setTarget(nil, Vector3.zero)
			self:forceRemoveLockState()
			pg.global.ui.tips:showTextTip(pg.getGameString("PHOTO_UNLOCK_TARGET"))
		end
	end

	if self.ctrl.photoMode == self.ctrl.ModeType.PHOTO_IDENTIFY then
		local allEntitys = pg.getEntities()

		for id, entity in pairs(allEntitys) do
			if Utils.isPuppet(entity) and self:isSpecialEntity(entity) and pg.game.camera:checkInViewportFull(entity:getPosition()) and not table.contains(self.showTopLogoEntitys, entity.id) and (not self.curLockedEntity or self.curLockedEntity.id ~= entity.id) then
				local puppetName = pg.getLocalizationText(PuppetData[entity.templateId].name)

				if entity.ensureTopLogoItem and entity:ensureTopLogoItem("photo") and entity.ensureToplogoComponent and entity:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.PHOTO, "photo_identify") then
					entity.eventEmitter:emit(EventConst.TOPLOGO_PHOTO, UIConst.PHOTO_TYPE.IDENTIFY, true, puppetName, 0)
					table.insert(self.showTopLogoEntitys, entity.id)
				end
			end
		end
	end
end

function LockModelUIComponent:tryGetLockedEntity()
	local curEntityDist = self.curLockedEntity and self.curEntityDist or 100000
	local curEntityStaticId = self.curLockedEntity and self.curLockedEntity.staticId or -1
	local firstUpperCurDist = curEntityDist + 100000
	local firstUpperCurEntity
	local minDist = 100000
	local minDistEntity
	local allEntitys = pg.getEntities()
	local cameraPos = self.ctrl:checkIsNormalOrSelfie() and pg.game.camera.photoCameraMode.cameraMode:GetPivotLocation() or pg.game.camera.playerCameraMode.cameraMode:GetPivotLocation()

	for id, entity in pairs(allEntitys) do
		if Utils.isPuppet(entity) and self:isSpecialEntity(entity) and entity.staticId ~= curEntityStaticId then
			local entPos = entity:getPosition()
			local entityCheckPos = Vector3(entPos.x, entPos.y + self.checkHeight, entPos.z)
			local dist = Utils.distance(entityCheckPos, cameraPos)

			if dist < self.maxLockDist and pg.game.camera:checkInViewportFull(entityCheckPos) and not pgUtils.IsBlocked(cameraPos, entityCheckPos, dist, self.lockLayerMask) then
				if dist < minDist then
					minDist = dist
					minDistEntity = entity
				end

				if curEntityDist < dist and dist < firstUpperCurDist then
					firstUpperCurDist = dist
					firstUpperCurEntity = entity
				end
			end
		end
	end

	if firstUpperCurEntity then
		self.curEntityDist = firstUpperCurDist

		return firstUpperCurEntity
	end

	self.curEntityDist = minDist

	return minDistEntity or self.curLockedEntity
end

function LockModelUIComponent:isSpecialEntity(entity)
	if self.ctrl.photoMode == self.ctrl.ModeType.PHOTO_IDENTIFY then
		local cfg = PuppetData[entity.templateId]

		return cfg and cfg.identification == 1
	end

	return true
end

function LockModelUIComponent:switchLockModel()
	self.openLock = not self.openLock

	if self.openLock then
		self:openLockModel()
	else
		self:closeLockModel()
	end
end

function LockModelUIComponent:openLockModel()
	self.openLock = true

	self.view.rootComponent:TryChangePage("Locking", 2)

	if self.ctrl.photoMode == self.ctrl.ModeType.PHOTO_IDENTIFY then
		self.view.btnScanUButton.visualInteractable = true
	end

	self:switchLockTarget()
end

function LockModelUIComponent:switchLockTarget()
	if self.curLockedEntity and self.ctrl.photoMode == self.ctrl.ModeType.PHOTO_IDENTIFY then
		local puppetName = pg.getLocalizationText(PuppetData[self.curLockedEntity.templateId].name)

		if self.curLockedEntity.ensureTopLogoItem and self.curLockedEntity:ensureTopLogoItem("photo") and self.curLockedEntity.ensureToplogoComponent and self.curLockedEntity:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.PHOTO, "photo_identify") then
			self.curLockedEntity.eventEmitter:emit(EventConst.TOPLOGO_PHOTO, UIConst.PHOTO_TYPE.IDENTIFY, true, puppetName, 0)
		end
	end

	self.curLockedEntity = self:tryGetLockedEntity()

	if self.curLockedEntity and self.ctrl.photoMode == self.ctrl.ModeType.PHOTO_IDENTIFY then
		local puppetName = pg.getLocalizationText(PuppetData[self.curLockedEntity.templateId].name)

		if self.curLockedEntity.ensureTopLogoItem and self.curLockedEntity:ensureTopLogoItem("photo") and self.curLockedEntity.ensureToplogoComponent and self.curLockedEntity:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.PHOTO, "photo_identify") then
			self.curLockedEntity.eventEmitter:emit(EventConst.TOPLOGO_PHOTO, UIConst.PHOTO_TYPE.IDENTIFY, true, puppetName, 1)
		end
	end

	if self.curLockedEntity then
		self:forceSetLockState(self.curLockedEntity, 0)

		local targetHeight = self.curLockedEntity:getHeight() * 0.5

		pg.game.camera.photoCameraMode.cameraMode.needRotationDamper = true

		pg.game.camera.photoCameraMode:setTargetByActorId(self.curLockedEntity.actorId, 0, targetHeight, 0)
	else
		pg.global.ui.tips:showTextTip(pg.getGameString("PHOTO_LOCK_NO_TARGET"))
		self:closeLockModel()
	end
end

function LockModelUIComponent:closeLockModel()
	self.openLock = false
	self.curLockedEntity = nil

	pg.game.camera.photoCameraMode:setTarget(nil, Vector3.zero)
	self.view.rootComponent:TryChangePage("Locking", 1)

	if self.ctrl.photoMode == self.ctrl.ModeType.PHOTO_IDENTIFY then
		self.view.btnScanUButton.visualInteractable = false
	end

	self:forceRemoveLockState()
end

function LockModelUIComponent:forceSetLockState(lockedEntity, lockedPartId)
	self.photographAimUComponent:SetActive(true)
	self.photographAimUComponent:TryChangePage("CameraAim", 1)

	self.lockedEntity = lockedEntity
	self.lockedPartId = lockedPartId

	self:onEnterLockMode()
end

function LockModelUIComponent:forceRemoveLockState()
	self.lockedEntity = nil
	self.lockedPartId = 0

	self:onLeaveLockMode()
end

function LockModelUIComponent:onEnterLockMode()
	if self.lockInTimer then
		self.ctrl:killTimer(self.lockInTimer)
	end

	self.lockWidgetAnimation:Play(self.lockEntityInAni)

	local inLength = self.lockWidgetAnimation:GetClip(self.lockEntityInAni).length

	self.lockInTimer = self.ctrl:startTimer(function()
		self.lockWidgetAnimation:Play(self.lockEntityLoopAni)

		self.lockInTimer = nil
	end, inLength)

	if self.lockTimer ~= nil then
		pg.game.camera:removeLateUpdateTimer(self.lockTimer)

		self.lockTimer = nil
	end

	self.lockTimer = pg.game.camera:addLateUpdateTimer(function()
		self:startLockTick()
	end)
end

function LockModelUIComponent:onLeaveLockMode()
	self.lockWidgetAnimation:Play(self.lockEntityOutAni)

	local outLength = self.lockWidgetAnimation:GetClip(self.lockEntityOutAni).length

	self.ctrl:startTimer(function()
		self.photographAimUComponent:SetActive(false)
		self.photographAimUComponent:TryChangePage("CameraAim", 0)
	end, outLength)

	if self.lockTimer then
		pg.game.camera:removeLateUpdateTimer(self.lockTimer)
	end

	self.lockTimer = nil
end

function LockModelUIComponent:startLockTick()
	local cameraMgr = pg.global.cameraMgr
	local worldPos = CombatActionTool.getHitPosition(self.lockedEntity, 0.5, self.lockedPartId)
	local lookAtCamera = cameraMgr.uiSceneCameraInst or cameraMgr.worldCameraInst
	local uiCamera = pg.global.uiMgr.orthographicCamera
	local uiPos = UIUtils.WorldToUI(worldPos, lookAtCamera, uiCamera)

	uiPos = Vector4(uiPos.x / uiPos.w, uiPos.y / uiPos.w, uiPos.z / uiPos.w, 1)
	uiPos.z = 0
	self.view.focusTransform.position = uiPos

	local localPos = self.view.focusTransform.localPosition

	self.view.focusTransform.localPosition = Vector3(localPos.x, localPos.y, 0)
end

function LockModelUIComponent:tryIdentifyLockEntity()
	if self.curLockedEntity then
		pg.global.ui:open(UIConst.UI_ID_PHOTO_IDENTIFY, {
			curLockedEntity = self.curLockedEntity
		})
	elseif not self.openLock then
		pg.global.ui.tips:showTextTip(pg.getGameString("PHOTO_NEED_ENTER_LOCK_MODE"))
	end
end

function LockModelUIComponent:onDestroy()
	if self.lockTimer ~= nil then
		pg.game.camera:removeLateUpdateTimer(self.lockTimer)

		self.lockTimer = nil
	end

	pg.game.camera.photoCameraMode:setTarget(nil, Vector3.zero)

	for _, entId in ipairs(self.showTopLogoEntitys) do
		local entity = pg.getEntity(entId)

		if entity then
			entity.eventEmitter:emit(EventConst.TOPLOGO_PHOTO, UIConst.PHOTO_TYPE.IDENTIFY, false, "", 0)
		end
	end

	self.showTopLogoEntitys = {}
end

return LockModelUIComponent
