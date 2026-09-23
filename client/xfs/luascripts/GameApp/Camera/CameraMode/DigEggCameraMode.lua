-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\DigEggCameraMode.lua

local CameraMode = require("GameApp.Camera.CameraMode.CameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local CameraData = require("Data.camera_data")
local Class = require("Core.Framework.Class")
local CinemachineImpulseModifier = CS.FunPlus.WorldX.VirtualCamera.CinemachineImpulseModifier
local CameraShakeModifier = CS.FunPlus.WorldX.VirtualCamera.CameraShakeModifier
local VirtualCameraBlendFunction = CS.FunPlus.WorldX.VirtualCamera.VirtualCameraBlendFunction
local DigEggCameraMode = Class.OldLightClass("DigEggCameraMode", CameraMode)

function DigEggCameraMode:onCtor()
	self:initModifiers()
end

function DigEggCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.DigEggCameraMode
end

function DigEggCameraMode:getCameraPriority()
	return CameraConst.PRIORITY_DIG_EGG
end

function DigEggCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_DIG_EGG
end

function DigEggCameraMode:getConfigData()
	return CameraData[CameraConst.CAMERA_NAME_DIG_EGG] or {}
end

function DigEggCameraMode:enableCamera(enable, blendTime, lookTarget, offsetPos, offsetRotEuler, fov)
	self:setActive(enable)

	if enable then
		self.cameraMode.defaultBlendTime = blendTime or 0
		self.cameraMode.blendFunction = VirtualCameraBlendFunction.EaseOut

		self.cameraMode:SetCameraInfo(offsetPos, offsetRotEuler, fov, lookTarget)
	else
		self.cameraMode.defaultBlendTime = blendTime or 0
		self.cameraMode.blendFunction = VirtualCameraBlendFunction.EaseIn
	end
end

function DigEggCameraMode:enableCameraByActorId(enable, blendTime, actorId, offsetPos, offsetRotEuler, fov)
	local lookTarget = CSEntityManager:GetPositionAgentByActorId(actorId)

	self:enableCamera(enable, blendTime, lookTarget, offsetPos, offsetRotEuler, fov)
end

function DigEggCameraMode:initModifiers()
	local cinemachineImpulseModifier = CinemachineImpulseModifier()

	self:addCameraModifier(cinemachineImpulseModifier, 10)

	local cameraShakeModifier = CameraShakeModifier()

	self:addCameraModifier(cameraShakeModifier, 11)
end

return DigEggCameraMode
