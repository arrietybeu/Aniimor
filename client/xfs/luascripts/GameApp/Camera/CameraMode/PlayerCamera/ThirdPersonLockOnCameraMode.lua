-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\PlayerCamera\\ThirdPersonLockOnCameraMode.lua

local CameraMode = require("GameApp.Camera.CameraMode.CameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local Class = require("Core.Framework.Class")
local CameraData = require("Data.camera_data")
local ThirdPersonLockOnCameraMode = Class.OldLightClass("ThirdPersonLockOnCameraMode", CameraMode)

function ThirdPersonLockOnCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.ThirdPersonLockOnCameraMode
end

function ThirdPersonLockOnCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_THIRD_PERSON_LOCK_ON
end

function ThirdPersonLockOnCameraMode:getCameraPriority()
	return CameraConst.PRIORITY_LOCK_ON_THIRD_PERSON
end

function ThirdPersonLockOnCameraMode:getConfigData()
	return CameraData[CameraConst.CAMERA_NAME_THIRD_PERSON_LOCK_ON] or {}
end

function ThirdPersonLockOnCameraMode:onCtor()
	ThirdPersonLockOnCameraMode.super.onCtor(self)

	self.cameraMode.maxPitch = self.configData.maxPitch or 45
	self.cameraMode.minPitch = self.configData.minPitch or -60
	self.cameraMode.springArm.targetArmLength = self.configData.targetArmLength or 3
	self.cameraMode.pitchDamper.dampTime = self.configData.pitchDamp or 0.5
	self.cameraMode.pitchDamper.maxSpeed = self.configData.pitchSpeed or 45
	self.cameraMode.yawDamper.dampTime = self.configData.yawDamp or 0.3
	self.cameraMode.yawDamper.maxSpeed = self.configData.yawSpeed or 90
	self.cameraMode.shoulder = Vector3(self.configData.shoulderX or 0.5, 0, 0)
	self.cameraMode.pivotOffset = Vector3(0, self.configData.pivotHeight or 1.5, 0)
end

function ThirdPersonLockOnCameraMode:setLockEnt(targetEnt, shoulder, pitch)
	if targetEnt then
		local targetHeight = targetEnt:getHeight() * 0.5

		self.cameraMode.shoulder = shoulder or Vector3(self.configData.shoulderX or 0.5, 0, 0)
		self.cameraMode.minPitch = pitch and pitch[2] or self.configData.minPitch or -60
		self.cameraMode.maxPitch = pitch and pitch[1] or self.configData.maxPitch or 45

		self.cameraMode:SetTargetByActorId(targetEnt.actorId, 0, targetHeight, 0)
	else
		self.cameraMode.minPitch = self.configData.minPitch or -60
		self.cameraMode.maxPitch = self.configData.maxPitch or 45
		self.cameraMode.shoulder = Vector3(self.configData.shoulderX or 0.5, 0, 0)

		self.cameraMode:SetTarget(nil, Vector3.zero)
	end
end

return ThirdPersonLockOnCameraMode
