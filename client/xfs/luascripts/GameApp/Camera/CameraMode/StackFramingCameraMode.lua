-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\StackFramingCameraMode.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local CameraConst = require("GameApp.Camera.CameraConst")
local CameraMode = require("GameApp.Camera.CameraMode.CameraMode")
local StackFramingCameraMode = Class.OldLightClass("StackFramingCameraMode", CameraMode)

function StackFramingCameraMode:onCtor()
	return
end

function StackFramingCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_FIXED
end

function StackFramingCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.StackFramingCameraMode
end

function StackFramingCameraMode:setTarget(transform)
	if self.cameraMode ~= nil then
		self.cameraMode.followTransform = transform
	end
end

return StackFramingCameraMode
