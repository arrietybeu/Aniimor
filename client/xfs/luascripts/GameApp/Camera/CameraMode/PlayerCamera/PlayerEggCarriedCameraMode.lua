-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\PlayerCamera\\PlayerEggCarriedCameraMode.lua

local ThirdPersonCameraMode = require("GameApp.Camera.CameraMode.ThirdPersonCameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local CameraData = require("Data.camera_data")
local Class = require("Core.Framework.Class")
local Vector3 = Vector3
local PlayerEggCarriedCameraMode = Class.OldLightClass("PlayerEggCarriedCameraMode", ThirdPersonCameraMode)

function PlayerEggCarriedCameraMode:onCtor()
	ThirdPersonCameraMode.onCtor(self)

	self.cameraMode.springArm.targetArmLength = self.configData.defaultArmLength or 0
	self.cameraMode.shoulder = Vector3(0, 0, 0)
	self.cameraMode.offset = Vector3(0, 0, 0)
	self.cameraMode.pivotOffset = Vector3(0, 0, 0)
	self.cameraMode.useFollowTransformRotation = false
	self.cameraMode.fieldOfView = self.configData.fieldOfView or 60
end

function PlayerEggCarriedCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_EGG_CARRIED
end

function PlayerEggCarriedCameraMode:getConfigData()
	return CameraData[CameraConst.CAMERA_NAME_EGG_CARRIED] or {}
end

function PlayerEggCarriedCameraMode:getMinMaxPitch()
	local minPitch = self.configData.minPitch or -80
	local maxPitch = self.configData.maxPitch or 80

	return minPitch, maxPitch
end

function PlayerEggCarriedCameraMode:setFollowTarget(transform)
	self.cameraMode.followTransform = transform
end

return PlayerEggCarriedCameraMode
