-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Controller\\Utils\\SkillFollowTarget.lua

local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local Mathf = require("Common.Math.Mathf")
local EModelUtils = require("Entities.Utils.EModelUtils")
local Const = require("Common.Const.Const")
local Vector3 = Vector3
local Quaternion = Quaternion
local SkillFollowTarget = Class.LightClass("SkillFollowTarget")

function SkillFollowTarget:ctor(owner)
	self.owner = owner
	self.isValid = false
end

function SkillFollowTarget:setOwner(owner)
	EModelUtils.clearDisplacementVelocitySource(self.owner, Const.DisplacementVelocitySource.ControllerFollowTarget)

	self.owner = owner
end

function SkillFollowTarget:setFollowTarget(ownerEntity, targetId, followSpeed, stopDistance, keepFollow, followAnimation)
	EModelUtils.clearDisplacementVelocitySource(self.owner, Const.DisplacementVelocitySource.ControllerFollowTarget)

	self.owner = ownerEntity
	self.followAnimation = followAnimation
	self.keepFollow = keepFollow or false
	self.targetEntity = pg.getEntityByActorId(targetId)
	self.followSpeed = followSpeed
	self.stopDistance = stopDistance or 1
	self.lastTickTime = Time.realSecondCache
	self.isValid = self.targetEntity ~= nil and not self.targetEntity.isDestroyed and self.followSpeed ~= nil
end

function SkillFollowTarget:stopFollowTarget()
	EModelUtils.clearDisplacementVelocitySource(self.owner, Const.DisplacementVelocitySource.ControllerFollowTarget)

	self.isValid = false

	if self.followAnimation ~= nil then
		self.owner:stopAnimation(self.followAnimation)
	end

	self.isPlayAnimation = false
end

function SkillFollowTarget:update()
	if not self.isValid then
		return
	end

	if self.targetEntity == nil or self.targetEntity.isDestroyed then
		self:stopFollowTarget()

		return
	end

	local targetPosition = self.targetEntity:getPosition()
	local ownerPosition = self.owner:getPosition()
	local deltaX = targetPosition[1] - ownerPosition[1]
	local deltaY = targetPosition[2] - ownerPosition[2]
	local deltaZ = targetPosition[3] - ownerPosition[3]
	local sqrDistance = deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ

	if sqrDistance < self.stopDistance * self.stopDistance then
		EModelUtils.clearDisplacementVelocitySource(self.owner, Const.DisplacementVelocitySource.ControllerFollowTarget)

		if not self.keepFollow then
			self:stopFollowTarget()
		end

		if self.followAnimation then
			self.isPlayAnimation = false

			self.owner:stopAnimation(self.followAnimation)
		end

		return
	elseif self.followAnimation and not self.isPlayAnimation then
		self.owner:playAnimation(self.followAnimation)

		self.isPlayAnimation = true
	end

	local now = Time.realSecondCache
	local deltaTime = now - self.lastTickTime

	self.lastTickTime = now

	if self.owner then
		Vector3.enableCreateFromCache()

		local deltaPosition = Vector3.New(deltaX, deltaY, deltaZ)
		local qua = Quaternion.LookRotation(deltaPosition, Vector3.constUp)

		EModelUtils.setMotionRotation(self.owner, qua, false)

		local displacementOffset = deltaPosition:SetNormalize() * self.followSpeed * deltaTime

		EModelUtils.setDisplacementVelocitySourceByOffset(self.owner, Const.DisplacementVelocitySource.ControllerFollowTarget, displacementOffset, deltaTime, true, false)
		Vector3.disableCreateFromCache()
	end
end

return SkillFollowTarget
