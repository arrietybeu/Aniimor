-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\PlayerCamera\\PlayerAnimCameraMode.lua

local CameraMode = require("GameApp.Camera.CameraMode.CameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local Class = require("Core.Framework.Class")
local PlayerAnimCameraMode = Class.OldLightClass("PlayerAnimCameraMode", CameraMode)

function PlayerAnimCameraMode:onCtor()
	CameraMode.onCtor(self)

	self.alignCamera = nil
end

function PlayerAnimCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_LOCAL_ANIM
end

function PlayerAnimCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.PlayerLocalAnimCameraMode
end

function PlayerAnimCameraMode:playCurveAnim(curveName, fromZoom, toZoom, duration)
	if self.alignCamera == nil then
		return
	end

	if not fromZoom or fromZoom < 0 then
		fromZoom = self.alignCamera.cameraMode.cameraZoom.zoomValue
	end

	if not toZoom or toZoom < 0 then
		toZoom = self.alignCamera.cameraMode.cameraZoom.zoomValue
	end

	local from = self.alignCamera.cameraMode:CalcSpringArmLength(fromZoom)
	local to = self.alignCamera.cameraMode:CalcSpringArmLength(toZoom)

	self.cameraMode:PlayCurveAnim(curveName, from, to, duration)
end

function PlayerAnimCameraMode:setAlignCamera(alignCamera)
	self.alignCamera = alignCamera
	self.cameraMode.alignCamera = alignCamera.cameraMode
end

return PlayerAnimCameraMode
