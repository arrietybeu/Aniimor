-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\PlayerCamera\\PlayerPeepCameraMode.lua

local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local CameraConst = require("GameApp.Camera.CameraConst")
local SimpleControlCameraMode = require("GameApp.Camera.CameraMode.SimpleControlCameraMode")
local PlayerPeepCameraMode = Class.OldLightClass("PlayerPeepCameraMode", SimpleControlCameraMode)

function PlayerPeepCameraMode:onCtor()
	SimpleControlCameraMode.onCtor(self)

	self.cameraMode.fieldOfView = 65
	self.cameraMode.springArm.targetArmLength = 0
	self.cameraMode.minPitch = -45
	self.cameraMode.maxPitch = 45
	self.cameraMode.minYaw = 90
	self.cameraMode.maxYaw = 270
end

function PlayerPeepCameraMode:setCameraParams(fieldOfView, minPitch, maxPitch, minYaw, maxYaw, targetPos, targetRot)
	self.cameraMode.fieldOfView = fieldOfView
	self.cameraMode.minPitch = minPitch
	self.cameraMode.maxPitch = maxPitch
	self.cameraMode.minYaw = minYaw
	self.cameraMode.maxYaw = maxYaw
	self.cameraMode.targetPos = targetPos
	self.cameraMode.targetRot = targetRot
end

function PlayerPeepCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.PeepCameraMode
end

function PlayerPeepCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_PEEP
end

return PlayerPeepCameraMode
