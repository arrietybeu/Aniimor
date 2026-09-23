-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\HomeCamera\\HomeCameraGroupMode.lua

local Class = require("Core.Framework.Class")
local CameraGroupMode = require("GameApp.Camera.CameraMode.CameraGroupMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local HomeCameraMode = require("GameApp.Camera.CameraMode.HomeCamera.HomeCameraMode")
local HomeCameraGroupMode = Class.OldLightClass("HomeCameraGroupMode", CameraGroupMode)

function HomeCameraGroupMode:onCtor()
	HomeCameraGroupMode.super.onCtor(self)
	self:initBaseInfo()
end

function HomeCameraGroupMode:getCameraName()
	return CameraConst.CAMERA_NAME_HOME_GROUP
end

function HomeCameraGroupMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.VirtualCameraGroupMode
end

function HomeCameraGroupMode:initBaseInfo()
	self:initSubCameraModes()
end

function HomeCameraGroupMode:initSubCameraModes()
	self.editorCamera = HomeCameraMode.new()

	self.editorCamera:pushToParent(self, CameraConst.SUB_PRIORITY_HOME_BASE)
end

return HomeCameraGroupMode
