-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\CameraGroupMode.lua

local CameraMode = require("GameApp.Camera.CameraMode.CameraMode")
local lume = require("Core.Common.lume")
local CameraConst = require("GameApp.Camera.CameraConst")
local Class = require("Core.Framework.Class")
local CameraGroupMode = Class.OldLightClass("CameraGroupMode", CameraMode)

function CameraGroupMode:ctor()
	self.subModes = {}

	CameraMode.ctor(self)
end

function CameraGroupMode:getCameraName()
	return CameraConst.CAMERA_NAME_GROUP_DEFAULT
end

function CameraGroupMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.VirtualCameraGroupMode
end

function CameraGroupMode:getTopCamera()
	local topCameraMode = self.cameraMode.cameraGroup:GetTopCameraMode()

	return topCameraMode
end

function CameraGroupMode:_pushCameraMode(subCameraMode, priority)
	if self.cameraMode ~= nil then
		self.subModes[#self.subModes + 1] = subCameraMode

		return self.cameraMode.cameraGroup:PushCameraMode(subCameraMode.cameraMode, priority)
	end

	return 0
end

function CameraGroupMode:_pullCameraMode(subCameraMode)
	if subCameraMode then
		local subIndex = lume.find(self.subModes, subCameraMode)

		if subIndex then
			table.remove(self.subModes, subIndex)
		end

		self.cameraMode.cameraGroup:PullCameraModeById(subCameraMode.handleId)
	end
end

function CameraGroupMode:dispose()
	for i = #self.subModes, 1, -1 do
		local subMode = self.subModes[i]

		subMode:dispose()
	end

	self.subModes = {}

	CameraMode.dispose(self)
end

return CameraGroupMode
