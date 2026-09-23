-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\FixedWithTargetCameraMode.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local CameraCommonModifier = CS.FunPlus.WorldX.VirtualCamera.CameraCommonModifier
local CameraConst = require("GameApp.Camera.CameraConst")
local CameraMode = require("GameApp.Camera.CameraMode.CameraMode")
local UIConst = require("Const.UIConst")
local FixedWithTargetCameraMode = Class.OldLightClass("FixedWithTargetCameraMode", CameraMode)

function FixedWithTargetCameraMode:onCtor()
	return
end

function FixedWithTargetCameraMode:initCommonModifier()
	if not self.commonModifier then
		self.commonModifier = CameraCommonModifier()

		self:addCameraModifier(self.commonModifier, 12)
	end
end

function FixedWithTargetCameraMode:removeCommonModifier()
	if self.commonModifier then
		self:removeCameraModifier(self.commonModifier)
	end

	self.commonModifier = nil
end

function FixedWithTargetCameraMode:blendToDistance(targetDistance, blendTime, ease, needResolveCollisions)
	self:initCommonModifier()
	self.commonModifier:BlendToDistance(targetDistance, blendTime, ease, needResolveCollisions)
end

function FixedWithTargetCameraMode:blendOut(blendTime)
	if self.commonModifier then
		self.commonModifier:BlendOut(blendTime)
	end
end

function FixedWithTargetCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_FIXED_WITH_TARGET
end

function FixedWithTargetCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.FixedWithTargetCameraMode
end

function FixedWithTargetCameraMode:setCameraInfo(pos, rot, fov, target)
	if self.cameraMode then
		self.cameraMode:SetCameraInfo(pos, rot, fov, target)
	end
end

function FixedWithTargetCameraMode:setCameraInfoByActorId(pos, rot, fov, actorId)
	if self.cameraMode then
		local target = CSEntityManager:GetPositionAgentByActorId(actorId)

		self.cameraMode:SetCameraInfo(pos, rot, fov, target)
	end
end

function FixedWithTargetCameraMode:setFinishBlendCb(cb)
	if self.cameraMode then
		self.cameraMode.luaOnFinishBlend = cb
	end
end

function FixedWithTargetCameraMode:refreshCameraView()
	if pg.global.ui:checkUIVisible(UIConst.UI_ID_FUNC_MENU) then
		pg.global.ui.funcMenu:resetCameraInfo()
	end
end

return FixedWithTargetCameraMode
