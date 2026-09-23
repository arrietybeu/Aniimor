-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\PetBallCameraMode.lua

local CameraMode = require("GameApp.Camera.CameraMode.CameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local Class = require("Core.Framework.Class")
local PetBallCameraMode = Class.OldLightClass("PetBallCameraMode", CameraMode)

function PetBallCameraMode:onCtor()
	if self.cameraMode then
		self.cameraMode.offset = Vector3(0, 0, 0)
		self.cameraMode.zoomSpeed = 6.4
		self.cameraMode.springArm.enableCollision = false
		self.cameraMode.cameraController.maxYaw = 45
		self.cameraMode.cameraController.minYaw = -45
		self.cameraMode.cameraController.minPitch = 0
		self.cameraMode.cameraController.maxPitch = 40
		self.cameraMode.cameraController.yawSpeed = 0.5
		self.cameraMode.cameraController.pitchSpeed = 0.5
	end
end

function PetBallCameraMode:setActive(isActive)
	CameraMode.setActive(self, isActive)
end

function PetBallCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.PetBallCameraMode
end

function PetBallCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_PET_BALL
end

function PetBallCameraMode:setOffset(x, y, z)
	if self.cameraMode then
		self.cameraMode.offset = Vector3(x, y, z)
	end
end

function PetBallCameraMode:setRotation(rotation)
	if self.cameraMode then
		self.cameraMode:SetRotation(rotation)
	end
end

function PetBallCameraMode:getRotation()
	if self.cameraMode then
		return self.cameraMode:GetControlRotation()
	end
end

function PetBallCameraMode:setFollowTransform(transform)
	if self.cameraMode then
		self.cameraMode.followTransform = transform
	end
end

function PetBallCameraMode:setSpringArmLen(armLen)
	if self.cameraMode then
		self.cameraMode.springArm.targetArmLength = armLen
	end
end

function PetBallCameraMode:getSpringArmLen()
	if self.cameraMode then
		return self.cameraMode.springArm.targetArmLength
	end
end

return PetBallCameraMode
