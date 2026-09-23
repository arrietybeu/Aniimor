-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\GameModeCamera\\PVPRewardCameraMode.lua

local CameraMode = require("GameApp.Camera.CameraMode.CameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local ClientConst = require("Const.ClientConst")
local HotkeyConst = require("Const.HotkeyConst")
local UIConst = require("Const.UIConst")
local CameraData = require("Data.camera_data")
local Class = require("Core.Framework.Class")
local ToBool = ToBool
local PVPRewardCameraMode = Class.OldLightClass("PVPRewardCameraMode", CameraMode)

PVPRewardCameraMode.MIN_DISTANCE = 2
PVPRewardCameraMode.MAX_DISTANCE = 12

function PVPRewardCameraMode:onCtor()
	CameraMode.onCtor(self)

	self.cameraMode.cameraController.maxPitch = self:getConfigData().maxPitch or 60
	self.cameraMode.cameraController.minPitch = self:getConfigData().minPitch or -60
	self.cameraMode.shoulder = Vector3(0, 0.5, 0)
	self.cameraMode.pivotOffset = Vector3(0, 1.2, 0)
	self.cameraMode.springArm.targetArmLength = 5
	self.defaultDistance = 5
end

function PVPRewardCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.PVPRewardCameraMode
end

function PVPRewardCameraMode:getCameraPriority()
	return CameraConst.PRIORITY_PVP_REWARD
end

function PVPRewardCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_PVP_REWARD
end

function PVPRewardCameraMode:getConfigData()
	return CameraData[CameraConst.CAMERA_NAME_PVP_REWARD] or {}
end

function PVPRewardCameraMode:enableCamera(active, entity)
	if active then
		self:setCameraDistance(4)
		self:setCameraOffset(0, 0.5)

		self.cameraMode.cameraController.maxPitch = 15
		self.cameraMode.cameraController.minPitch = 10

		self.cameraMode:SetTargetEntityByActorId(entity.actorId)
		entity:faceToPosition(self.cameraMode:GetCameraView().location)
		self:setActive(true)
	else
		self:setActive(false)
		self.cameraMode:SetTargetEntityByActorId(0)
	end
end

function PVPRewardCameraMode:setCameraDistance(distance)
	if not distance then
		self.cameraMode.springArm.targetArmLength = self.defaultDistance

		return
	end

	if distance < self.MIN_DISTANCE then
		distance = self.MIN_DISTANCE
	elseif distance > self.MAX_DISTANCE then
		distance = self.MAX_DISTANCE
	end

	self.cameraMode.springArm.targetArmLength = distance
end

function PVPRewardCameraMode:setCameraOffset(x, y)
	self.cameraMode.offset = Vector3(x or 0, y or 0, 0)
end

function PVPRewardCameraMode:setPosition(pos)
	if self.cameraMode then
		self.cameraMode:SetPosition(pos)
	end
end

function PVPRewardCameraMode:setRotation(rotation)
	if self.cameraMode then
		self.cameraMode:SetRotation(rotation)
	end
end

function PVPRewardCameraMode:setFov(fov)
	fov = fov or 45

	if self.cameraMode then
		self.cameraMode:SetFov(fov)
	end
end

return PVPRewardCameraMode
