-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\BallDriveCameraMode.lua

local CameraConst = require("GameApp.Camera.CameraConst")
local Class = require("Core.Framework.Class")
local ThirdPersonCameraMode = require("GameApp.Camera.CameraMode.ThirdPersonCameraMode")
local BallDriveCameraMode = Class.OldLightClass("BallDriveCameraMode", ThirdPersonCameraMode)

function BallDriveCameraMode:onCtor()
	ThirdPersonCameraMode.onCtor(self)

	self.cameraMode.shoulder = Vector3(0, 0.5, 0)
	self.cameraMode.fieldOfView = 50
	self.cameraMode.springArm.targetArmLength = 6
end

function BallDriveCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.BallDriveCameraMode
end

function BallDriveCameraMode:getCameraPriority()
	return CameraConst.PRIORITY_BALL_DRIVE
end

function BallDriveCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_BALL_DRIVE
end

return BallDriveCameraMode
