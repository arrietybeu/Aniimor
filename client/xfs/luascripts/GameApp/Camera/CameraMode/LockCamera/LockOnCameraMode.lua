-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\LockCamera\\LockOnCameraMode.lua

local CameraMode = require("GameApp.Camera.CameraMode.CameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local Class = require("Core.Framework.Class")
local CameraData = require("Data.camera_data")
local LockOnCameraMode = Class.OldLightClass("LockOnCameraMode", CameraMode)

function LockOnCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.LockOnCameraMode
end

function LockOnCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_LOCK_ON
end

function LockOnCameraMode:getCameraPriority()
	return CameraConst.PRIORITY_LOCK_ON
end

function LockOnCameraMode:getConfigData()
	return CameraData[CameraConst.CAMERA_NAME_LOCK_ON] or {}
end

function LockOnCameraMode:onCtor()
	LockOnCameraMode.super.onCtor(self)

	self.cameraMode.lookAtRatio = self.configData.lookAtRatio or 0.5
	self.cameraMode.maxPitch = self.configData.maxPitch or 45
	self.cameraMode.minPitch = self.configData.minPitch or -60
	self.cameraMode.defaultLockYaw = self.configData.defaultLockYaw or -10
	self.cameraMode.defaultLockPitch = self.configData.defaultLockPitch or 10
	self.cameraMode.baseArmLen = self.configData.baseArmLen or 5
	self.cameraMode.yawOffsetCurve = pg.game.camera:getCameraCurve(self.configData.yawOffsetCurve or "defaultLockYawOffset")
	self.cameraMode.pitchOffsetCurve = pg.game.camera:getCameraCurve(self.configData.pitchOffsetCurve or "defaultLockPitchOffset")
	self.cameraMode.armLenOffsetCurve = pg.game.camera:getCameraCurve(self.configData.armLenOffsetCurve or "defaultLockArmLenOffset")
end

function LockOnCameraMode:setLockEnt(targetEnt)
	if targetEnt then
		local targetHeight = targetEnt:getHeight() * 0.5

		self.cameraMode:SetTargetByActorId(targetEnt.actorId, 0, targetHeight, 0)
	else
		self.cameraMode:SetTargetByActorId(0)
	end
end

return LockOnCameraMode
