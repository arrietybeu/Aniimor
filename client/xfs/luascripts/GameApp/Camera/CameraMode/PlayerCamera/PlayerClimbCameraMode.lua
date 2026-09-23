-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\PlayerCamera\\PlayerClimbCameraMode.lua

local CameraConst = require("GameApp.Camera.CameraConst")
local Class = require("Core.Framework.Class")
local ThirdPersonCameraMode = require("GameApp.Camera.CameraMode.ThirdPersonCameraMode")
local CLIMB_CAMERA_RADIUS = 0.08
local PlayerClimbCameraMode = Class.OldLightClass("PlayerClimbCameraMode", ThirdPersonCameraMode)

function PlayerClimbCameraMode:onCtor()
	self.cameraMode.pivotOffset = Vector3(0, 0, 0)
	self.cameraMode.springArm.cameraRadius = CLIMB_CAMERA_RADIUS
end

function PlayerClimbCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_CLIMB
end

function PlayerClimbCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.PlayerClimbCameraMode
end

function PlayerClimbCameraMode:setActive(isActive)
	if isActive == self:isActive() then
		return
	end

	if isActive and not self:isActive() and self.parent and self.parent.defaultCamera then
		self.cameraMode:PrepareTransitionFromDefault(self.parent.defaultCamera.cameraMode)
	end

	ThirdPersonCameraMode.setActive(self, isActive)
end

return PlayerClimbCameraMode
