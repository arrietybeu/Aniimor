-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\PlayerCamera\\PlayerScrollCameraMode.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local CameraConst = require("GameApp.Camera.CameraConst")
local ThirdPersonCameraMode = require("GameApp.Camera.CameraMode.ThirdPersonCameraMode")
local ClientUtils = require("Utils.ClientUtils")
local Utils = require("Common.Utils.Utils")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local Const = require("Common.Const.Const")
local sysConfigData = require("Data.sys_config_data")
local EventConst = require("Const.EventConst")
local PlayerScrollCameraMode = Class.OldLightClass("PlayerScrollCameraMode", ThirdPersonCameraMode)

function PlayerScrollCameraMode:onCtor()
	ThirdPersonCameraMode.onCtor(self)

	self.lastUpdateState = nil
	self.cameraMode.fieldOfView = 40
	self.cameraMode.offsetRange = 0
	self.cameraMode.shoulder = Vector3(0, 0.5, 0)
	self.cameraMode.pivotOffset = Vector3(0, 1, 0)
end

function PlayerScrollCameraMode:setActive(isActive, init)
	ThirdPersonCameraMode.setActive(self, isActive)
end

function PlayerScrollCameraMode:enableScrollCameraMode(enable)
	if enable then
		self.cameraMode:SetFollowEntity(pg.pawn.eModel, "")
	end

	self:setActive(enable)
end

function PlayerScrollCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.ScrollCameraMode
end

function PlayerScrollCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_SCROLL
end

function PlayerScrollCameraMode:update(player)
	return
end

return PlayerScrollCameraMode
