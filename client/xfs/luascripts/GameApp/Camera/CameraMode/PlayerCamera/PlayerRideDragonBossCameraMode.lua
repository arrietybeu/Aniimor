-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\PlayerCamera\\PlayerRideDragonBossCameraMode.lua

local Class = require("Core.Framework.Class")
local CameraConst = require("GameApp.Camera.CameraConst")
local CameraData = require("Data.camera_data")
local ThirdPersonCameraMode = require("GameApp.Camera.CameraMode.ThirdPersonCameraMode")
local PlayerRideDragonBossCameraMode = Class.OldLightClass("PlayerRideDragonBossCameraMode", ThirdPersonCameraMode)
local WaterDetectMode = CS.FunPlus.WorldX.VirtualCamera.WaterDetectMode

function PlayerRideDragonBossCameraMode:onCtor()
	ThirdPersonCameraMode.onCtor(self)

	self.cameraMode.fieldOfView = self.configData.fieldOfView or 50
	self.cameraMode.targetPivotOffset = Vector3(0, 3, 0.6)
	self.cameraMode.rotationOffset = Vector3(25, 0, 0)
	self.cameraMode.springArm.waterDetectMode = WaterDetectMode.None

	local minPitch, maxPitch = self:getMinMaxPitch()

	self.cameraMode.minPitch = minPitch
	self.cameraMode.maxPitch = maxPitch
end

function PlayerRideDragonBossCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.RideDragonBossCameraMode
end

function PlayerRideDragonBossCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_RIDE_DRAGON_BOSS
end

function PlayerRideDragonBossCameraMode:getConfigData()
	return CameraData[CameraConst.CAMERA_NAME_RIDE_DRAGON_BOSS] or {}
end

function PlayerRideDragonBossCameraMode:getMinMaxPitch()
	local minPitch = self.configData.minPitch or -10
	local maxPitch = self.configData.maxPitch or 30

	return minPitch, maxPitch
end

return PlayerRideDragonBossCameraMode
