-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\CameraMode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local CameraConst = require("GameApp.Camera.CameraConst")
local logger = LoggerManager.getLogger("CameraMode")
local CameraMode = Class.OldLightClass("CameraMode")

function CameraMode:ctor()
	self.parent = nil
	self.handleId = 0
	self.cameraMode = self:getModeClass()()

	self.cameraMode:SetOwnerLua(self)
	self:setCameraName(self:getCameraName())

	self.configData = self:getConfigData()

	self:onCtor()
end

function CameraMode:onCtor()
	return
end

function CameraMode:onDestroy()
	return
end

function CameraMode:onParentChange()
	return
end

function CameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_DEFAULT
end

function CameraMode:getConfigData()
	return {}
end

function CameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.VirtualCameraMode
end

function CameraMode:dispose()
	if self.cameraMode ~= nil then
		local cameraMode = self.cameraMode

		self:pullFromParent()
		self:onDestroy()
		cameraMode:SetOwnerLua(nil)

		self.cameraMode = nil
	end
end

function CameraMode:setActive(isActive)
	if self.cameraMode == nil then
		return
	end

	self.cameraMode.isActive = isActive
end

function CameraMode:isValid()
	return self.handleId ~= 0
end

function CameraMode:isActive()
	if self.cameraMode == nil then
		return false
	end

	return self.cameraMode.isActive
end

function CameraMode:isActivated()
	if self.cameraMode == nil then
		return false
	end

	return self.cameraMode.isActivated
end

function CameraMode:isTop()
	if self.cameraMode == nil then
		return false
	end

	return self.cameraMode.isOnTop
end

function CameraMode:isBlending()
	if self.cameraMode == nil then
		return false
	end

	return self.cameraMode.isBlending
end

function CameraMode:getCameraPriority()
	return CameraConst.PRIORITY_DEFAULT
end

function CameraMode:pushToParent(parent, customPriority)
	if self.handleId ~= 0 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("Camera Mode: camera has been added to stack")
		end

		return
	end

	self.parent = parent or pg.global.cameraMgr.vcManager.rootCameraGroup

	local priority = customPriority or self:getCameraPriority()

	if EnableBotTest then
		return
	end

	if Class.isInstanceOf(self.parent, CameraMode) then
		self.handleId = self.parent:_pushCameraMode(self, priority)
	else
		self.handleId = self.parent:PushCameraMode(self.cameraMode, priority)
	end

	self:onParentChange()
end

function CameraMode:pullFromParent()
	if self.handleId == 0 then
		return
	end

	if Class.isInstanceOf(self.parent, CameraMode) then
		self.parent:_pullCameraMode(self)
	else
		self.parent:PullCameraModeById(self.handleId)
	end

	self.parent = nil
	self.handleId = 0
end

function CameraMode:setCameraPriority(priority)
	if self.handleId == 0 then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("Camera Mode: camera mode has already been removed")
		end

		return
	end

	if self.parent == nil then
		if self.rootGroup ~= nil then
			self.rootGroup:SetCameraModePriorityById(self.handleId, priority)
		else
			pg.global.cameraMgr.vcManager.rootGroup:SetCameraModePriorityById(self.handleId, priority)
		end
	else
		self.parent.cameraMode.cameraGroup:SetCameraModePriorityById(self.handleId, priority)
	end
end

function CameraMode:setCameraName(cameraName)
	if self.cameraMode then
		self.cameraMode.cameraName = cameraName
	end
end

function CameraMode:addCameraModifier(modifier, priority)
	modifier.priority = priority

	return self.cameraMode:AddCameraModifier(modifier)
end

function CameraMode:removeCameraModifier(modifier)
	return self.cameraMode:RemoveCameraModifier(modifier)
end

return CameraMode
