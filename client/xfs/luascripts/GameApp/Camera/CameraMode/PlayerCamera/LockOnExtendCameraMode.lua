-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\PlayerCamera\\LockOnExtendCameraMode.lua

local CameraMode = require("GameApp.Camera.CameraMode.CameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local Class = require("Core.Framework.Class")
local CameraData = require("Data.camera_data")
local TimerManager = require("Core.Timer.TimerManager")
local LockOnExtendCameraMode = Class.OldLightClass("LockOnExtendCameraMode", CameraMode)

function LockOnExtendCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.LockOnExtendCameraMode
end

function LockOnExtendCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_LOCK_ON_EXTEND_CAMERA
end

function LockOnExtendCameraMode:getCameraPriority()
	return CameraConst.SUB_PRIORITY_PLAYER_LOCK_ON_EXTEND
end

function LockOnExtendCameraMode:getConfigData()
	return CameraData[CameraConst.CAMERA_NAME_LOCK_ON_EXTEND_CAMERA] or {}
end

function LockOnExtendCameraMode:onCtor()
	LockOnExtendCameraMode.super.onCtor(self)

	local configData = self:getConfigData()

	self.cameraMode:Init()

	self.cameraMode.initPosDamp = configData.initPosDamp or 0.5
	self.cameraMode.deadZonePosDamp = configData.deadZonePosDamp or 0.1
	self.cameraMode.deadZoneX = configData.deadZoneX or 0.3
	self.cameraMode.lockFollowFixAngle = configData.lockFollowFixAngle or 15
	self.cameraMode.lockFollowFixDamp = configData.lockFollowFixDamp or 1.5
	self.cameraMode.leaveDeadZoneMaxTime = configData.leaveDeadZoneMaxTime or 3
	self.cameraMode.posDampDamp = configData.posDampDamp or 0.5
	self.cameraMode.xLockOnDampDamp = configData.xLockOnDampDamp or 0.5
	self.cameraMode.inputViewRatio = self.configData.inputViewRatio or 0.6
	self.cameraMode.initXLockOnDamp = configData.initXLockOnDamp or 1.5
	self.cameraMode.deadZoneXLockOnDamp = configData.deadZoneXLockOnDamp or 0.1
end

function LockOnExtendCameraMode:onTransitionToMode(fromMode)
	self:onLockOnExtendCameraModeInvalid()
end

function LockOnExtendCameraMode:onLockOnExtendCameraModeInvalid()
	self.parent.cameraMode.cameraController:SetControlRotation(self.cameraMode:GetCameraRotation())
end

function LockOnExtendCameraMode:onDestroy()
	LockOnExtendCameraMode.super.onDestroy(self)
	self:resetTargetExtraAngle()
end

function LockOnExtendCameraMode:lerpToDeadZoneTriangle()
	if self:isActivated() then
		self.cameraMode:LerpToDeadZoneTriangle()
	end
end

function LockOnExtendCameraMode:setTargetExtraAngle(extraYAngle, maxTime)
	self.cameraMode:SetTargetExtraYAngle(extraYAngle)

	if self.restoreAngleTimer then
		TimerManager.removeTimer(self.restoreAngleTimer)

		self.restoreAngleTimer = nil
	end

	if maxTime and maxTime > 0 then
		self.restoreAngleTimer = TimerManager.addTimer(maxTime, function()
			self:resetTargetExtraAngle()
		end)
	end
end

function LockOnExtendCameraMode:resetTargetExtraAngle()
	self.cameraMode:SetTargetExtraYAngle(0)

	if self.restoreAngleTimer then
		TimerManager.removeTimer(self.restoreAngleTimer)

		self.restoreAngleTimer = nil
	end
end

return LockOnExtendCameraMode
