-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\KillBossCameraMode.lua

local CameraMode = require("GameApp.Camera.CameraMode.CameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local CameraData = require("Data.camera_data")
local Class = require("Core.Framework.Class")
local KillBossCameraMode = Class.OldLightClass("KillBossCameraMode", CameraMode)

function KillBossCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.KillBossCameraMode
end

function KillBossCameraMode:getCameraPriority()
	return CameraConst.PRIORITY_KILL_BOSS
end

function KillBossCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_KILL_BOSS
end

function KillBossCameraMode:getConfigData()
	return CameraData[CameraConst.CAMERA_NAME_KILL_BOSS] or {}
end

function KillBossCameraMode:enableCamera(enable, focusPos, initRot, distance, duration)
	self.cameraMode:SetupCameraConfig(focusPos, initRot, distance, duration)

	self.cameraMode.defaultBlendTime = 0

	self:setActive(enable)
end

function KillBossCameraMode:addEndCallback(callback)
	self.cameraMode:AddEndCallback(callback)
end

return KillBossCameraMode
