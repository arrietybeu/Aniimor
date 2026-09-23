-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\PlayerCamera\\PlayerFlyCameraMode.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local CameraConst = require("GameApp.Camera.CameraConst")
local ThirdPersonCameraMode = require("GameApp.Camera.CameraMode.ThirdPersonCameraMode")
local PlayerFlyCameraMode = Class.OldLightClass("PlayerFlyCameraMode", ThirdPersonCameraMode)

function PlayerFlyCameraMode:onCtor()
	ThirdPersonCameraMode.onCtor(self)

	self.cameraMode.fieldOfView = 65
	self.cameraMode.springArm.targetArmLength = 7.5
	self.cameraMode.shoulder = Vector3(0, 0, 0)
	self.cameraMode.pivotOffset = Vector3(0, 1.5, 0)
end

function PlayerFlyCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_FLY
end

function PlayerFlyCameraMode:onCatchEnable(enable)
	self.catching = enable

	self:refreshActive()
end

function PlayerFlyCameraMode:onMoveStateChange(oldState, oldSubState, newState, newSubState)
	self.lastState = newState

	self:refreshActive()
end

function PlayerFlyCameraMode:refreshActive()
	if self.catching then
		self:setActive(false)
	end
end

return PlayerFlyCameraMode
