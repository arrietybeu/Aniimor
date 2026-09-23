-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\PlayerCamera\\PlayerFaceToCameraMode.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local CameraConst = require("GameApp.Camera.CameraConst")
local ThirdPersonCameraMode = require("GameApp.Camera.CameraMode.ThirdPersonCameraMode")
local CameraData = require("Data.camera_data")
local PlayerFaceToCameraMode = Class.OldLightClass("PlayerFaceToCameraMode", ThirdPersonCameraMode)

function PlayerFaceToCameraMode:onCtor()
	PlayerFaceToCameraMode.super.onCtor(self)

	self.cameraMode.pitchBlender.dampTime = 0.3
	self.cameraMode.yawBlender.dampTime = 0.3
	self.cameraMode.defaultBlendTime = 1
	self.cameraMode.heightDelta = 0.2
	self.cameraMode.springArm.targetArmLength = 5
	self.markDefaultArmLength = self.cameraMode.springArm.targetArmLength
	self.markDefaultFov = self.cameraMode.fieldOfView
end

function PlayerFaceToCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.FaceToCameraMode
end

function PlayerFaceToCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_FACE_TO
end

function PlayerFaceToCameraMode:onTransitionFromMode(fromCameraMode)
	if not fromCameraMode then
		return
	end

	if self.inheritArmLength then
		self.cameraMode.springArm.targetArmLength = fromCameraMode.springArm.targetArmLength
	else
		self.cameraMode.springArm.targetArmLength = self.markDefaultArmLength
	end

	if self.inheritFov then
		self.cameraMode.fieldOfView = fromCameraMode.fieldOfView
	else
		self.cameraMode.fieldOfView = self.markDefaultFov
	end
end

function PlayerFaceToCameraMode:getConfigData()
	return CameraData[CameraConst.CAMERA_NAME_FACE_TO] or {}
end

function PlayerFaceToCameraMode:setTargetPosition(targetPosition, heightDelta)
	self.cameraMode.minPitch = -40
	self.cameraMode.maxPitch = 40
	self.cameraMode.heightDelta = heightDelta or 0.2

	self.cameraMode:SetTargetPosition(targetPosition)
end

function PlayerFaceToCameraMode:setTargetTransform(targetTransform, heightDelta, shoulder)
	self.cameraMode.heightDelta = heightDelta or 0.2

	if shoulder ~= nil then
		self.cameraMode.targetShoulder = Vector3.zero
		self.cameraMode.shoulder = shoulder
	end

	self.cameraMode:SetTarget(targetTransform)
end

function PlayerFaceToCameraMode:setTargetTransformWithTargetShoulder(targetTransform, heightDelta, targetShoulder, transitionSpeed, rotSpeedCurve)
	self.inheritFov = true
	self.inheritArmLength = true
	self.cameraMode.heightDelta = heightDelta or 0.2

	if targetShoulder ~= nil then
		self.cameraMode.targetShoulder = targetShoulder
		self.cameraMode.transitionSpeed = transitionSpeed or 1
	end

	self.cameraMode:SetTarget(targetTransform)

	if rotSpeedCurve ~= nil then
		self.cameraMode:SetRotationSpeedCurve(rotSpeedCurve)
	end
end

function PlayerFaceToCameraMode:cancelFaceToTarget()
	self.inheritFov = nil
	self.inheritArmLength = nil
end

return PlayerFaceToCameraMode
