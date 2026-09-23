-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\PlayerCamera\\PlayerPaintAreaCameraMode.lua

local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local CameraConst = require("GameApp.Camera.CameraConst")
local ThirdPersonCameraMode = require("GameApp.Camera.CameraMode.ThirdPersonCameraMode")
local PlayerPaintAreaCameraMode = Class.OldLightClass("PlayerPaintAreaCameraMode", ThirdPersonCameraMode)

function PlayerPaintAreaCameraMode:onCtor()
	ThirdPersonCameraMode.onCtor(self)

	self.cameraMode.fieldOfView = 65
	self.cameraMode.pivotOffset = Vector3(0, 1.3, 0)
end

function PlayerPaintAreaCameraMode:setCameraParams(fieldOfView, targetArmLength, blendTime)
	self.cameraMode.fieldOfView = fieldOfView
	self.cameraMode.springArm.targetArmLength = targetArmLength
	self.cameraMode.defaultBlendTime = blendTime
end

function PlayerPaintAreaCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.ThirdPersonCameraMode
end

function PlayerPaintAreaCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_PAINT_AREA
end

function PlayerPaintAreaCameraMode:onTransitionFromMode(fromCameraMode)
	if fromCameraMode then
		local fromCameraView = fromCameraMode:GetCameraView()
		local fromRotation = fromCameraView.rotation

		self.cameraMode.cameraController:SetControlRotation(fromRotation)

		return true
	end

	return false
end

return PlayerPaintAreaCameraMode
