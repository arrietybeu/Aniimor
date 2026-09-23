-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\SimpleControlCameraMode.lua

local CameraMode = require("GameApp.Camera.CameraMode.CameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local ClientConst = require("Const.ClientConst")
local Class = require("Core.Framework.Class")
local SimpleControlCameraMode = Class.OldLightClass("SimpleControlCameraMode", CameraMode)

function SimpleControlCameraMode:onCtor()
	self.cameraMode.pivotOffset = Vector3(0, 1.3, 0)
	self.cameraMode.zoomSpeed = 0
	self.cameraMode.minZoom = 0.5
	self.cameraMode.maxZoom = 6
end

function SimpleControlCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.SimpleControlCameraMode
end

function SimpleControlCameraMode:getCameraPriority()
	return CameraConst.PRIORITY_DEBUG
end

function SimpleControlCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_SIMPLE_CONTROL
end

function SimpleControlCameraMode:setCameraTarget(targetTrans)
	self.cameraMode.followTransform = targetTrans
end

return SimpleControlCameraMode
