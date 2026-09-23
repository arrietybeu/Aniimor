-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\PhotoCamera\\PhotoFaceToCameraMode.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local CameraConst = require("GameApp.Camera.CameraConst")
local CameraMode = require("GameApp.Camera.CameraMode.CameraMode")
local PhotoFaceToCameraMode = Class.OldLightClass("PhotoFaceToCameraMode", CameraMode)

function PhotoFaceToCameraMode:onCtor()
	CameraMode.onCtor(self)
end

function PhotoFaceToCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.PhotoFaceToCameraMode
end

function PhotoFaceToCameraMode:setTargetTransform(transform, offset, rotation, distance)
	if self.cameraMode then
		self.cameraMode.followTransform = transform
		self.cameraMode.pivotOffset = offset
		self.cameraMode.springArm.targetArmLength = distance
		self.cameraMode.rotation = rotation
	end
end

function PhotoFaceToCameraMode:getCameraName()
	return CameraConst.QUICK_PHOTO_FACE_TO_CAMERA_NAME
end

function PhotoFaceToCameraMode:setFinishBlendCb(cb)
	if self.cameraMode then
		self.cameraMode.luaOnFinishBlend = cb
	end
end

return PhotoFaceToCameraMode
