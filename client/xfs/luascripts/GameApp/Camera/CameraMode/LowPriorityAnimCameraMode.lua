-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\LowPriorityAnimCameraMode.lua

local CameraMode = require("GameApp.Camera.CameraMode.CameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local ClientConst = require("Const.ClientConst")
local Class = require("Core.Framework.Class")
local bit = require("bit")
local LowPriorityAnimCameraMode = Class.OldLightClass("LowPriorityAnimCameraMode", CameraMode)
local CameraShakeModifier = CS.FunPlus.WorldX.VirtualCamera.CameraShakeModifier

function LowPriorityAnimCameraMode:onCtor()
	self:initModifiers()
end

function LowPriorityAnimCameraMode:initModifiers()
	local cameraShakeModifier = CameraShakeModifier()

	cameraShakeModifier.filterFlag = CS.FunPlus.WorldX.VirtualCamera.CameraShakeFlag.AffectCameraAim

	self:addCameraModifier(cameraShakeModifier, 11)
end

function LowPriorityAnimCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_LOW_PRIORITY_ANIM
end

function LowPriorityAnimCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.LowPriorityAnimClipCameraMode
end

function LowPriorityAnimCameraMode:playCameraAnimByActorId(baseActorId, animResId, blendInTime, blendOutTime, inheritDir, cameraOffset, pivotOffset, checkStartCollide, checkCollide, modelScale, onlyUpdateBaseOnce, collideOffset, cb, forceSync)
	self.cameraMode:SetUpdateBaseMatrixStatus(onlyUpdateBaseOnce or false)

	self.cameraMode.collideOffset = collideOffset

	self.cameraMode:PlayCameraAnimByActorIdWithSettings(baseActorId, animResId, blendInTime, blendOutTime, inheritDir, cameraOffset or Vector3.zero, pivotOffset or Vector3.zero, checkStartCollide or false, checkCollide or false, modelScale and modelScale or 1, cb, forceSync)
end

function LowPriorityAnimCameraMode:playCameraAnim(baseTransform, entity, animResId, blendInTime, blendOutTime, inheritDir, cameraOffset, pivotOffset, checkStartCollide, checkCollide, modelScale, onlyUpdateBaseOnce, collideOffset, cb, forceSync)
	if not string.isNilOrEmpty(animResId) then
		local entityEModel = entity and entity.eModel

		self.cameraMode:PlayCameraAnimWithLowPrioritySettings(baseTransform, entityEModel, animResId, blendInTime, blendOutTime, inheritDir, cameraOffset or Vector3.zero, pivotOffset or Vector3.zero, checkStartCollide or false, checkCollide or false, modelScale and modelScale or 1, onlyUpdateBaseOnce or false, collideOffset, cb, forceSync or false)
	end
end

function LowPriorityAnimCameraMode:stopCameraAnim()
	self.cameraMode:StopCameraAnim()
end

function LowPriorityAnimCameraMode:setCameraOffset(cameraOffset)
	self.cameraMode.cameraOffset = cameraOffset
end

function LowPriorityAnimCameraMode:getCameraPriority()
	return CameraConst.PRIORITY_NORMAL_ANIM
end

return LowPriorityAnimCameraMode
