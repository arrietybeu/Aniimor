-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\AnimCameraMode.lua

local CameraMode = require("GameApp.Camera.CameraMode.CameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local ClientConst = require("Const.ClientConst")
local Class = require("Core.Framework.Class")
local bit = require("bit")
local AnimCameraMode = Class.OldLightClass("AnimCameraMode", CameraMode)
local CameraShakeModifier = CS.FunPlus.WorldX.VirtualCamera.CameraShakeModifier

function AnimCameraMode:onCtor()
	self:initModifiers()
end

function AnimCameraMode:initModifiers()
	local cameraShakeModifier = CameraShakeModifier()

	cameraShakeModifier.filterFlag = CS.FunPlus.WorldX.VirtualCamera.CameraShakeFlag.AffectCameraAim

	self:addCameraModifier(cameraShakeModifier, 11)
end

function AnimCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_ANIM
end

function AnimCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.AnimClipCameraMode
end

function AnimCameraMode:playCameraAnimByPosRot(pos, rot, entity, animResId, blendInTime, blendOutTime, inheritDir, cameraOffset, pivotOffset, checkStartCollide, checkCollide, modelScale, endCb, forceSync)
	if not string.isNilOrEmpty(animResId) then
		if self.refEntity then
			self.refEntity.refCameraAnim = nil
			self.refEntity = nil
		end

		if entity then
			self.refEntity = entity
			entity.refCameraAnim = self
		end

		forceSync = forceSync or false
		blendInTime = blendInTime or 0
		blendOutTime = blendOutTime or 1
		inheritDir = inheritDir or false

		local entityEModel = entity and entity.eModel or nil

		self:refreshAnimSpeed()
		self.cameraMode:PlayCameraAnimByPosRotWithSettings(pos, rot, entityEModel, animResId, blendInTime, blendOutTime, inheritDir, cameraOffset or Vector3.zero, pivotOffset or Vector3.zero, checkStartCollide or false, checkCollide or false, modelScale and modelScale or 1, endCb, forceSync)
	else
		if entity then
			entity.logger:error("animResId not valid", animResId)
		end

		if endCb then
			endCb()
		end
	end
end

function AnimCameraMode:playCameraAnimByActorId(baseActorId, animResId, blendInTime, blendOutTime, inheritDir, cameraOffset, pivotOffset, checkStartCollide, checkCollide, modelScale, endCb, forceSync)
	if not string.isNilOrEmpty(animResId) then
		if self.refEntity then
			self.refEntity.refCameraAnim = nil
			self.refEntity = nil
		end

		forceSync = forceSync or false
		blendInTime = blendInTime or 0
		blendOutTime = blendOutTime or 1
		inheritDir = inheritDir or false

		self:refreshAnimSpeed()
		self.cameraMode:PlayCameraAnimByActorIdWithSettings(baseActorId, animResId, blendInTime, blendOutTime, inheritDir, cameraOffset or Vector3.zero, pivotOffset or Vector3.zero, checkStartCollide or false, checkCollide or false, modelScale and modelScale or 1, endCb, forceSync)
	else
		local entity = pg.getEntityByActorId(baseActorId)

		if entity then
			entity.logger:error("animResId not valid", animResId)
		end

		if endCb then
			endCb()
		end
	end
end

function AnimCameraMode:playCameraAnim(baseTransform, entity, animResId, blendInTime, blendOutTime, inheritDir, cameraOffset, pivotOffset, checkStartCollide, checkCollide, modelScale, endCb, forceSync)
	if not string.isNilOrEmpty(animResId) then
		if self.refEntity then
			self.refEntity.refCameraAnim = nil
			self.refEntity = nil
		end

		if entity then
			self.refEntity = entity
			entity.refCameraAnim = self
		end

		forceSync = forceSync or false
		blendInTime = blendInTime or 0
		blendOutTime = blendOutTime or 1
		inheritDir = inheritDir or false

		local entityEModel = entity and entity.eModel or nil

		self:refreshAnimSpeed()
		self.cameraMode:PlayCameraAnimWithSettings(baseTransform, entityEModel, animResId, blendInTime, blendOutTime, inheritDir, cameraOffset or Vector3.zero, pivotOffset or Vector3.zero, checkStartCollide or false, checkCollide or false, modelScale and modelScale or 1, endCb, forceSync)
	else
		if entity then
			entity.logger:error("animResId not valid", animResId)
		end

		if endCb then
			endCb()
		end
	end
end

function AnimCameraMode:setTime(time)
	self.cameraMode:SetTime(time)
end

function AnimCameraMode:setAnimSpeed(speed)
	self.cameraMode:SetAnimSpeed(speed)
end

function AnimCameraMode:getCameraAnimSpeed()
	if self.refEntity and self.refEntity.getCameraAnimSpeed then
		return self.refEntity:getCameraAnimSpeed()
	end

	return 1
end

function AnimCameraMode:refreshAnimSpeed()
	local speed = self:getCameraAnimSpeed()

	self.cameraMode:SetAnimSpeed(speed)
end

function AnimCameraMode:stopCameraAnim()
	self.cameraMode:StopCameraAnim()
end

function AnimCameraMode:setCameraOffset(cameraOffset)
	self.cameraMode.cameraOffset = cameraOffset
end

function AnimCameraMode:getCameraPriority()
	return CameraConst.PRIORITY_SKILL_ANIM
end

function AnimCameraMode:fastForward(time)
	self.cameraMode:FastForward(time)
end

return AnimCameraMode
