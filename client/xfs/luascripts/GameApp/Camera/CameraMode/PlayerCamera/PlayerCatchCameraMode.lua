-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\PlayerCamera\\PlayerCatchCameraMode.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local CameraConst = require("GameApp.Camera.CameraConst")
local ThirdPersonCameraMode = require("GameApp.Camera.CameraMode.ThirdPersonCameraMode")
local ClientUtils = require("Utils.ClientUtils")
local Utils = require("Common.Utils.Utils")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local Const = require("Common.Const.Const")
local sysConfigData = require("Data.sys_config_data")
local CastItemData = require("Data.cast_item_data")
local ItemEffectData = require("Data.item_effect_data")
local EventConst = require("Const.EventConst")
local Vector3 = Vector3
local CameraData = require("Data.camera_data")
local ClientSettingUtils = require("Utils.ClientSettingUtils")
local catch_absorb_data = require("Data.catch_absorb_data")
local MANUAL_VIEW_INPUT_THRESHOLD_SQR = 0.0001
local PlayerCatchCameraMode = Class.OldLightClass("PlayerCatchCameraMode", ThirdPersonCameraMode)
local WaterDetectMode = CS.FunPlus.WorldX.VirtualCamera.WaterDetectMode

function PlayerCatchCameraMode:onCtor()
	ThirdPersonCameraMode.onCtor(self)

	self.lastUpdateState = nil
	self.cameraMode.fieldOfView = 40

	function self.onLockEntityMsg(msg, entity)
		if msg == "trapped" then
			self:_cancelFocus()
		elseif msg == "switch" then
			if self.target == nil then
				self:_forceFocus()
			else
				self:_switchFocus()
			end
		elseif msg == "cancel" then
			self:_cancelFocus()
		end
	end

	pg.global.eventEmitter:addEventListener(EventConst.LOCK_ENITY_MSG, self.onLockEntityMsg)

	self.cameraMode.shoulder = Vector3(0.5, 0.5, 0)
	self.cameraMode.pivotOffset = Vector3(0, 1, 0)
	self.cameraMode.springArm.waterDetectMode = WaterDetectMode.BeyondWater
	self.distance = 0
	self._lockHelper = pg.game.controller.lockHelper
	self._configuredAbsorbSpeed = 0

	self:onInputDeviceChange()
	self:onBallChanged()
end

function PlayerCatchCameraMode:_forceFocus()
	if self._lockHelper.forceLockActorId == 0 then
		self._lockHelper:tryForceLockTarget()
	end

	if self._lockHelper.forceLockActorId ~= 0 then
		local target = pg.getEntityByActorId(self._lockHelper.forceLockActorId)

		self:setTarget(target)
	end
end

function PlayerCatchCameraMode:_switchFocus()
	if self._lockHelper.forceLockActorId ~= 0 then
		self._lockHelper:tryLockNextTarget()
	else
		self._lockHelper:tryForceLockTarget()
	end

	local target = pg.getEntityByActorId(self._lockHelper.forceLockActorId)

	self:setTarget(target)
end

function PlayerCatchCameraMode:_cancelFocus()
	pg.game.controller:unlockTarget()
	self:setTarget(nil)
end

function PlayerCatchCameraMode:setActive(isActive, init)
	ThirdPersonCameraMode.setActive(self, isActive)

	if isActive then
		self:resetRotateSpeed()
	end

	self:_refreshAbsorbSpeed()

	self.cameraMode.offset = Vector3.zero

	if isActive then
		self._skipDistCheckOnActive = true

		self:onBallChanged()

		if self._lockHelper.forceLockActorId ~= 0 then
			local target = pg.getEntityByActorId(self._lockHelper.forceLockActorId)

			self:setTarget(target)
		end
	else
		self._skipDistCheckOnActive = nil

		self:setTarget(nil)
	end
end

function PlayerCatchCameraMode:_isManualViewInputActive()
	local input = pg.game.input
	local cameraProcessor = input and input.cameraProcessor

	if not cameraProcessor or not cameraProcessor.isManualViewInputActive then
		return false
	end

	return cameraProcessor:isManualViewInputActive(MANUAL_VIEW_INPUT_THRESHOLD_SQR)
end

function PlayerCatchCameraMode:_refreshAbsorbSpeed()
	local absorbSpeed = self._configuredAbsorbSpeed or 0

	if self:isActive() and self:_isManualViewInputActive() then
		absorbSpeed = 0
	end

	self.cameraMode.absorbSpeed = absorbSpeed
end

function PlayerCatchCameraMode:onBallChanged()
	self.distance = self:getAimDistance()
	self.cameraMode.distance = self.distance
end

function PlayerCatchCameraMode:getAimDistance()
	local currentContext = pg.me and pg.me.currentContext
	local castBallId = currentContext and currentContext.itemId
	local hudV2 = pg.global.ui and pg.global.ui.hudV2

	if not castBallId and hudV2 then
		castBallId = hudV2:getCurSelectPropId()
	end

	if ItemEffectData[castBallId] and ItemEffectData[castBallId].castItemId and CastItemData[ItemEffectData[castBallId].castItemId] and CastItemData[ItemEffectData[castBallId].castItemId].aimSwitchDistance then
		return CastItemData[ItemEffectData[castBallId].castItemId].aimSwitchDistance
	end

	return sysConfigData.CATCHCAMERALOCK_MAX_DISTANCE
end

function PlayerCatchCameraMode:setTarget(target)
	self.target = target

	if target then
		self.cameraMode:SetTarget(target.eModel)

		if pg.me:isInBossCatch() then
			self:refreshBossCatchInfo()
		end
	else
		self.cameraMode:SetTarget(nil)
	end

	facade:SendMessageCommand(MessageName.CATCH_LOCK_PUPPET_MSG, self.target ~= nil, self.isInField)
end

function PlayerCatchCameraMode:refreshBossCatchInfo()
	self.cameraMode.fieldOfView = 30
	self.cameraMode.springArm.targetArmLength = sysConfigData.CATCH_CAMERA_TARGETARMLENGTH_BOSS
	self.cameraMode.targetShoulder = Vector3(sysConfigData.CATCH_CAMERA_TARGETSHOULDER_BOSS[1], sysConfigData.CATCH_CAMERA_TARGETSHOULDER_BOSS[2], sysConfigData.CATCH_CAMERA_TARGETSHOULDER_BOSS[3])
	self.cameraMode.targetPivotOffset = Vector3(sysConfigData.CATCH_CAMERA_TARGETPIVOTOFFSET_BOSS[1], sysConfigData.CATCH_CAMERA_TARGETPIVOTOFFSET_BOSS[2], sysConfigData.CATCH_CAMERA_TARGETPIVOTOFFSET_BOSS[3])

	local distance = Vector3.Distance(pg.me:getPosition(), self.target:getPosition())
	local focusDistance = sysConfigData.CATCH_CAMERA_FOCUSDISTANCE_BOSS or 10
	local oriRightDis = sysConfigData.CATCH_CAMERA_CAMRIGHTDIS_BOSS or 1.1

	if focusDistance < distance then
		self.cameraMode.offset = Vector3(0, 0, distance - focusDistance)
		self.cameraMode.bossCaptureCamRightDis = oriRightDis
	else
		self.cameraMode.offset = Vector3.zero
		self.cameraMode.bossCaptureCamRightDis = distance / focusDistance * oriRightDis
	end
end

function PlayerCatchCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.CatchCameraMode
end

function PlayerCatchCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_CATCH
end

function PlayerCatchCameraMode:getConfigData()
	return CameraData[CameraConst.CAMERA_NAME_CATCH] or {}
end

function PlayerCatchCameraMode:resetRotateSpeed()
	local yawSpeed = self.configData.yawSpeed or 2.5
	local pitchSpeed = self.configData.pitchSpeed or 2.5
	local yawSpeedTable = self.configData.yawSpeedTable
	local pitchSpeedTable = self.configData.pitchSpeedTable

	yawSpeed = yawSpeedTable and yawSpeedTable[ClientSettingUtils.get_catchCameraYawRotateRate()] or yawSpeed
	pitchSpeed = pitchSpeedTable and pitchSpeedTable[ClientSettingUtils.get_catchCameraPitchRotateRate()] or pitchSpeed

	self.cameraMode:SetRotateSpeed(yawSpeed, pitchSpeed)
end

function PlayerCatchCameraMode:update(player)
	if not self:isActive() then
		return
	end

	self:_refreshAbsorbSpeed()

	if self.target and not pg.me:isInBossCatch() then
		if self._skipDistCheckOnActive then
			self._skipDistCheckOnActive = nil
			self.isInField = true

			if self.target.isDestroyed then
				self:_cancelFocus()
			end
		else
			self.isInField = self:checkDistance(self.target)

			if not self.isInField or self.target.isDestroyed then
				self:_cancelFocus()
			end
		end
	end

	if self.lastUpdateState == player.characterState then
		return
	end

	self.lastUpdateState = player.characterState

	if player:CROUCH_ST() then
		self.cameraMode.springArm.targetArmLength = sysConfigData.CATCH_CAMERA_TARGETARMLENGTH_CROUCH
		self.cameraMode.targetShoulder = Vector3(sysConfigData.CATCH_CAMERA_TARGETSHOULDER_CROUCH[1], sysConfigData.CATCH_CAMERA_TARGETSHOULDER_CROUCH[2], sysConfigData.CATCH_CAMERA_TARGETSHOULDER_CROUCH[3])
		self.cameraMode.targetPivotOffset = Vector3(sysConfigData.CATCH_CAMERA_TARGETPIVOTOFFSET_CROUCH[1], sysConfigData.CATCH_CAMERA_TARGETPIVOTOFFSET_CROUCH[2], sysConfigData.CATCH_CAMERA_TARGETPIVOTOFFSET_CROUCH[3])
		self.cameraMode.bossCaptureCamRightDis = 0
	elseif pg.me:isInBossCatch() then
		-- block empty
	else
		self.cameraMode.fieldOfView = 40
		self.cameraMode.bossCaptureCamRightDis = 0
		self.cameraMode.springArm.targetArmLength = sysConfigData.CATCH_CAMERA_TARGETARMLENGTH
		self.cameraMode.targetShoulder = Vector3(sysConfigData.CATCH_CAMERA_TARGETSHOULDER[1], sysConfigData.CATCH_CAMERA_TARGETSHOULDER[2], sysConfigData.CATCH_CAMERA_TARGETSHOULDER[3])
		self.cameraMode.targetPivotOffset = Vector3(sysConfigData.CATCH_CAMERA_TARGETPIVOTOFFSET[1], sysConfigData.CATCH_CAMERA_TARGETPIVOTOFFSET[2], sysConfigData.CATCH_CAMERA_TARGETPIVOTOFFSET[3])
	end
end

function PlayerCatchCameraMode:checkDistance(entity)
	if not entity or entity.isDestroyed then
		return false
	end

	local position = entity:getPosition()

	if not position then
		return false
	end

	local distance = self.cameraMode:GetDistanceToCameraView(position)

	return distance < self.distance
end

function PlayerCatchCameraMode:onInputDeviceChange()
	local isGamePad = pg.game.input:isUsingGamepad()
	local isMobile = pg.global.ui:runPlatformByMobile()
	local key

	key = isMobile and "mobile" or isGamePad and "gamePad" or "mouseKeyBoard"

	local data = catch_absorb_data[key] or {}

	self._configuredAbsorbSpeed = pg.game.setting:getCatchAbsorbSpeed(key) * (data.absorbSpeedMultiplier or 1)

	self:_refreshAbsorbSpeed()

	self.cameraMode.absorbRayRadius = data.absorbRayRadius or 0.1
	self.cameraMode.dampingFactor = pg.game.setting:getCatchDampingRate(key) * (data.dampingFactorMultiplier or 1)
	self.cameraMode.dampingRayRadius = data.dampingRayRadius or 0.1
	self.cameraMode.moveAbsorbSpeed = data.moveAbsorbSpeed or 0.1
	self.cameraMode.moveAbsorbRayRadius = data.moveAbsorbRayRadius or 0.1
	self.cameraMode.absorbRayRadiusStart = data.absorbRayRadiusStart or 0.5
end

function PlayerCatchCameraMode:dispose()
	pg.global.eventEmitter:removeEventListener(EventConst.LOCK_ENITY_MSG, self.onLockEntityMsg)
	ThirdPersonCameraMode.dispose(self)
end

return PlayerCatchCameraMode
