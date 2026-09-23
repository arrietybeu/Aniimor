-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\PlayerCamera\\NormalAttackLockOnCameraMode.lua

local CameraMode = require("GameApp.Camera.CameraMode.CameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local Utils = require("Common.Utils.Utils")
local MANUAL_INPUT_COOLDOWN_DEFAULT = 1
local HORIZONTAL_RANGE_MODE_MELEE = 0
local HORIZONTAL_RANGE_MODE_RANGED = 1
local HORIZONTAL_RANGE_MODE_BOSS = 2
local NormalAttackLockOnCameraMode = Class.OldLightClass("NormalAttackLockOnCameraMode", CameraMode)

function NormalAttackLockOnCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.NormalAttackLockOnCameraMode
end

function NormalAttackLockOnCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_NORMAL_ATTACK_LOCK_ON_CAMERA
end

function NormalAttackLockOnCameraMode:getCameraPriority()
	return CameraConst.SUB_PRIORITY_PLAYER_NORMAL_ATTACK_LOCK_ON
end

function NormalAttackLockOnCameraMode:onCtor()
	NormalAttackLockOnCameraMode.super.onCtor(self)

	self.activeTimer = nil
	self.manualOverrideUntil = 0

	self:applyConfig()
end

function NormalAttackLockOnCameraMode:applyConfig()
	self.activeDuration = 5
	self.autoRotationDuration = 1
	self.autoRotationFadeOutDuration = 0.2
	self.zoomDamp = 3
	self.exitBlendTime = 1.5
	self.manualExitBlendTime = 0
	self.manualInputCooldown = MANUAL_INPUT_COOLDOWN_DEFAULT
	self.cameraMode.fieldOfView = 46
	self.cameraMode.minHorizontalAngle = 30
	self.cameraMode.maxHorizontalAngle = 45
	self.cameraMode.targetPitchAngle = 10
	self.cameraMode.lookAtTargetRatio = 0.2
	self.cameraMode.maxLookAtDistance = 1.5
	self.cameraMode.horizontalAngleDamp = 2
	self.cameraMode.maxHorizontalRotationSpeed = 25
	self.cameraMode.pitchAngleDamp = 2
	self.cameraMode.maxPitchRotationSpeed = 25
	self.cameraMode.positionDamp = 2
	self.cameraMode.mouseExitMovementThreshold = 50
	self.cameraMode.mouseExitTimeThreshold = 0.3
end

local function getHorizontalRangeMode(targetEnt)
	if Utils.isSemanticallyBoss(targetEnt) then
		return HORIZONTAL_RANGE_MODE_BOSS
	end

	if pg.pawn == pg.me or AbilityUtils.isRangePet(pg.pawn) then
		return HORIZONTAL_RANGE_MODE_RANGED
	end

	return HORIZONTAL_RANGE_MODE_MELEE
end

function NormalAttackLockOnCameraMode:activateForTarget(targetEnt)
	if not targetEnt or not targetEnt.eModel or not targetEnt.eModel:CheckPositionAgent() then
		self:deactivate()

		return false
	end

	if self:isManualOverrideActive() then
		return false
	end

	self:applyConfig()
	self.cameraMode:ConfigureHorizontalRangeMode(getHorizontalRangeMode(targetEnt))

	local wasActive = self:isActive()

	self.cameraMode:ConfigureAutoRotation(self.autoRotationDuration, self.autoRotationFadeOutDuration)

	if not wasActive and self.parent then
		self.parent:OnCameraCancelZooming()
		self.parent.cameraMode.cameraZoom:SetBlendTo(self.parent:getMaxZoomValue(), self.zoomDamp)
	end

	self.cameraMode.followHeight = pg.me.eModel.height * 0.5

	self.cameraMode:SetFollowByActorId(pg.me.actorId)
	self.cameraMode:SetLockTargetByActorId(targetEnt.actorId, targetEnt.eModel.height)
	self:restartActiveTimer()

	if not wasActive then
		self:setActive(true)
	end

	return true
end

function NormalAttackLockOnCameraMode:restartActiveTimer()
	self:clearActiveTimer()
	self.cameraMode:ResetMouseExitTimer()

	self.activeTimer = TimerManager.addTimer(self.activeDuration, function()
		self.activeTimer = nil

		if self:isActive() then
			self:setActive(false)
		end
	end)
end

function NormalAttackLockOnCameraMode:shouldExitOnMouseInput(mouseDelta)
	return self.cameraMode:ShouldExitOnMouseInput(mouseDelta)
end

function NormalAttackLockOnCameraMode:interruptByManualInput()
	if not self:isActive() then
		return false
	end

	local cooldown = self.manualInputCooldown or MANUAL_INPUT_COOLDOWN_DEFAULT

	self.manualOverrideUntil = Time.realtimeSinceStartup + math.max(0, cooldown)

	self:deactivate(self.manualExitBlendTime)

	return true
end

function NormalAttackLockOnCameraMode:isManualOverrideActive()
	return Time.realtimeSinceStartup < (self.manualOverrideUntil or 0)
end

function NormalAttackLockOnCameraMode:deactivate(exitBlendTimeOverride)
	self:applyConfig()

	if exitBlendTimeOverride ~= nil then
		self.exitBlendTime = math.max(0, exitBlendTimeOverride)
	end

	self:clearActiveTimer()

	if self:isActive() then
		self:setActive(false)
	end
end

function NormalAttackLockOnCameraMode:clearActiveTimer()
	if self.activeTimer then
		TimerManager.removeTimer(self.activeTimer)

		self.activeTimer = nil
	end
end

function NormalAttackLockOnCameraMode:onDestroy()
	self:clearActiveTimer()
	NormalAttackLockOnCameraMode.super.onDestroy(self)
end

return NormalAttackLockOnCameraMode
