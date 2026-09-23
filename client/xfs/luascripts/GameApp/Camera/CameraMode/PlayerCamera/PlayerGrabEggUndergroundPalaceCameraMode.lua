-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\PlayerCamera\\PlayerGrabEggUndergroundPalaceCameraMode.lua

local ThirdPersonCameraMode = require("GameApp.Camera.CameraMode.ThirdPersonCameraMode")
local ClientConst = require("Const.ClientConst")
local CameraConst = require("GameApp.Camera.CameraConst")
local CameraData = require("Data.camera_data")
local Class = require("Core.Framework.Class")
local Vector3 = Vector3
local PlayerGrabEggUndergroundPalaceCameraMode = Class.OldLightClass("PlayerGrabEggUndergroundPalaceCameraMode", ThirdPersonCameraMode)

function PlayerGrabEggUndergroundPalaceCameraMode:onCtor()
	ThirdPersonCameraMode.onCtor(self)

	self.cameraMode.fieldOfView = self.configData.fieldOfView or 30
	self.defaultShoulderHeight = 1.3
	self.aimParam = {}

	self:setDefaultCameraParam()
end

function PlayerGrabEggUndergroundPalaceCameraMode:setDefaultCameraParam()
	self.cameraMode.defaultBlendTime = 0.5
	self.defaultArmLength = self.configData.defaultArmLength or 4.5
	self.cameraMode.springArm.targetArmLength = self.defaultArmLength
end

function PlayerGrabEggUndergroundPalaceCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_GRAB_EGG_UD_PALACE
end

function PlayerGrabEggUndergroundPalaceCameraMode:getConfigData()
	return CameraData[CameraConst.CAMERA_NAME_GRAB_EGG_UD_PALACE] or {}
end

function PlayerGrabEggUndergroundPalaceCameraMode:getMinMaxPitch()
	local minPitch = self.configData.minPitch or -60
	local maxPitch = self.configData.maxPitch or 60

	if self.aimParam.minPitch then
		minPitch = self.aimParam.minPitch
	end

	if self.aimParam.maxPitch then
		maxPitch = self.aimParam.maxPitch
	end

	return minPitch, maxPitch
end

function PlayerGrabEggUndergroundPalaceCameraMode:setTargetHeight(nearHeight, farHeight, shoulderHeight)
	local pivotY = math.clamp(nearHeight, 0.3, 2)

	self.cameraMode.pivotOffset = Vector3(0, pivotY, 0)

	local armLength = math.clamp(self.defaultArmLength + nearHeight * nearHeight + 1, 7, 8)

	self.cameraMode.springArm.targetArmLength = armLength
	shoulderHeight = shoulderHeight or 0
	self.cameraMode.shoulder = Vector3(0, shoulderHeight, 0)
end

return PlayerGrabEggUndergroundPalaceCameraMode
