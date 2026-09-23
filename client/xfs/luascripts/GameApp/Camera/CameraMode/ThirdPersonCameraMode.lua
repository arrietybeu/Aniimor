-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\ThirdPersonCameraMode.lua

local CameraMode = require("GameApp.Camera.CameraMode.CameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local Class = require("Core.Framework.Class")
local ThirdPersonCameraMode = Class.OldLightClass("ThirdPersonCameraMode", CameraMode)

function ThirdPersonCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.ThirdPersonCameraMode
end

function ThirdPersonCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_THIRD_PERSON
end

return ThirdPersonCameraMode
