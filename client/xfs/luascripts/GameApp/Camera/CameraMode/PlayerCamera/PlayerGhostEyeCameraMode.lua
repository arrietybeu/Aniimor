-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\PlayerCamera\\PlayerGhostEyeCameraMode.lua

local Class = require("Core.Framework.Class")
local CameraConst = require("GameApp.Camera.CameraConst")
local ThirdPersonCameraMode = require("GameApp.Camera.CameraMode.ThirdPersonCameraMode")
local PlayerGhostEyeCameraMode = Class.OldLightClass("PlayerGhostEyeCameraMode", ThirdPersonCameraMode)

function PlayerGhostEyeCameraMode:onCtor()
	PlayerGhostEyeCameraMode.super.onCtor(self)

	self.cameraMode.pivotOffset = Vector3(0, 1.1, 0)
	self.cameraMode.springArm.targetArmLength = 0
end

function PlayerGhostEyeCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.GhostEyeCameraMode
end

function PlayerGhostEyeCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_GHOST_EYE
end

return PlayerGhostEyeCameraMode
