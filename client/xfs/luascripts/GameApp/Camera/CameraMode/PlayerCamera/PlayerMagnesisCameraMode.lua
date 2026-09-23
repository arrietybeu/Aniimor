-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\PlayerCamera\\PlayerMagnesisCameraMode.lua

local Class = require("Core.Framework.Class")
local CameraConst = require("GameApp.Camera.CameraConst")
local CameraData = require("Data.camera_data")
local ThirdPersonCameraMode = require("GameApp.Camera.CameraMode.ThirdPersonCameraMode")
local PlayerMagnesisCameraMode = Class.OldLightClass("PlayerMagnesisCameraMode", ThirdPersonCameraMode)
local WaterDetectMode = CS.FunPlus.WorldX.VirtualCamera.WaterDetectMode

function PlayerMagnesisCameraMode:onCtor()
	ThirdPersonCameraMode.onCtor(self)

	self.cameraMode.fieldOfView = self.configData.fieldOfView or 50
	self.cameraMode.shoulder = Vector3(0.5, 0.5, 0)
	self.cameraMode.pivotOffset = Vector3(0, 1, 0)
	self.cameraMode.springArm.targetArmLength = 2.4
	self.cameraMode.targetShoulder = Vector3(0.45, 0.22, -0.15)
	self.cameraMode.targetPivotOffset = Vector3(0, 1.43, 0)
	self.cameraMode.springArm.waterDetectMode = WaterDetectMode.BeyondWater

	local minPitch, maxPitch = self:getMinMaxPitch()

	self.cameraMode.minPitch = minPitch
	self.cameraMode.maxPitch = maxPitch
end

function PlayerMagnesisCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.MagnesisCameraMode
end

function PlayerMagnesisCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_MAGNESIS
end

function PlayerMagnesisCameraMode:getConfigData()
	return CameraData[CameraConst.CAMERA_NAME_MAGNESIS] or {}
end

function PlayerMagnesisCameraMode:getMinMaxPitch()
	local minPitch = self.configData.minPitch or -45
	local maxPitch = self.configData.maxPitch or 45

	return minPitch, maxPitch
end

return PlayerMagnesisCameraMode
