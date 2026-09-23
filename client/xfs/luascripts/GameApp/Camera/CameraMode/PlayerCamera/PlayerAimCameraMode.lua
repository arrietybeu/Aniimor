-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\PlayerCamera\\PlayerAimCameraMode.lua

local ThirdPersonCameraMode = require("GameApp.Camera.CameraMode.ThirdPersonCameraMode")
local ClientConst = require("Const.ClientConst")
local CameraConst = require("GameApp.Camera.CameraConst")
local CameraData = require("Data.camera_data")
local Class = require("Core.Framework.Class")
local PlayerAimCameraMode = Class.OldLightClass("PlayerAimCameraMode", ThirdPersonCameraMode)

function PlayerAimCameraMode:onCtor()
	ThirdPersonCameraMode.onCtor(self)

	self.cameraMode.fieldOfView = self.configData.fieldOfView or 50
	self.defaultShoulderHeight = 1.3
	self.aimParam = {}

	self:setCameraParam()
end

function PlayerAimCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_AIM
end

function PlayerAimCameraMode:getConfigData()
	return CameraData[CameraConst.CAMERA_NAME_AIM] or {}
end

function PlayerAimCameraMode:getMinMaxPitch()
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

function PlayerAimCameraMode:setCameraParam(aimParam)
	aimParam = aimParam or {}
	self.aimParam = aimParam
	self.cameraMode.defaultBlendTime = aimParam.blendTime or 0.5
	self.cameraMode.rotationOffset = Vector3(aimParam.cameraPitchOffset or 0, aimParam.cameraYawOffset or 0, 0)

	local shoulderX = aimParam.shoulderX or self.configData.shoulderX or 0.6
	local shoulderY = aimParam.shoulderY or 0
	local shoulderZ = aimParam.shoulderZ or 0

	self.cameraMode.shoulder = Vector3(shoulderX, shoulderY, shoulderZ)
	self.cameraMode.springArm.targetArmLength = aimParam.targetAimLength or self.configData.targetArmLength or 1.5

	local pivotOffsetX = aimParam.cameraPivotOffsetXOverride or 0
	local pivotOffsetZ = aimParam.cameraPivotOffsetZOverride or 0

	self.cameraMode.pivotOffset = Vector3(pivotOffsetX, aimParam.cameraPivotHeightOverride or self.defaultShoulderHeight, pivotOffsetZ)
end

function PlayerAimCameraMode:setTargetHeight(nearHeight, farHeight)
	self.defaultShoulderHeight = farHeight + (nearHeight - farHeight) * (self.configData.pivotOffsetYRate or 1)
	self.cameraMode.pivotOffset = Vector3(0, self.defaultShoulderHeight, 0)
end

return PlayerAimCameraMode
