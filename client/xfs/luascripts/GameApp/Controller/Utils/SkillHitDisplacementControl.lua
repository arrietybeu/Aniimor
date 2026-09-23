-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Controller\\Utils\\SkillHitDisplacementControl.lua

local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local Mathf = require("Common.Math.Mathf")
local CombatActionTool = require("Common.Ability.CombatActionTool")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local EModelUtils = require("Entities.Utils.EModelUtils")
local AbilityConst = require("Common.Const.AbilityConst")
local Const = require("Common.Const.Const")
local hitDisplacementData = require("Data.skill_hit_displacement_data")
local SkillHitDisplacementControl = Class.LightClass("SkillHitDisplacementControl")
local Vector3 = Vector3

function SkillHitDisplacementControl:ctor(owner)
	self.owner = owner

	self:resetAll()
end

function SkillHitDisplacementControl:setOwner(owner)
	EModelUtils.clearDisplacementVelocitySource(self.owner, Const.DisplacementVelocitySource.SkillHitDisplacement)

	self.owner = owner
end

function SkillHitDisplacementControl:setupDisplacementData(hitDisplacementId, targetEnt, combatContext, dir)
	EModelUtils.clearDisplacementVelocitySource(self.owner, Const.DisplacementVelocitySource.SkillHitDisplacement)

	self.curControlData = hitDisplacementData[hitDisplacementId]
	self.targetActorId = targetEnt.actorId
	self.combatContext = combatContext
	self.time = 0
	self.isValid = true
	self.dir = dir
	self.startPos = Vector3.Clone(self.owner:getPosition())
end

function SkillHitDisplacementControl:resetAll()
	EModelUtils.clearDisplacementVelocitySource(self.owner, Const.DisplacementVelocitySource.SkillHitDisplacement)

	self.curControlData = {}
	self.time = 0
	self.targetPos = nil
	self.isValid = false
	self.combatContext = nil
end

function SkillHitDisplacementControl:updateTargetPos()
	local targetEntity = self.owner
	local lockedEnt = pg.getEntityByActorId(self.targetActorId)

	if not lockedEnt then
		return false
	end

	local combatContext = self.combatContext

	if not combatContext then
		return false
	end

	local skillHitDisplacementData = self.curControlData
	local lockedEntRadius = lockedEnt.bodySize or 0

	if not lockedEnt.getLockPartPosition then
		return false
	end

	local lockedEntPos = Vector3.Clone(lockedEnt:getLockPartPosition(pg.me.lockedPartId))
	local targetEntityPos = targetEntity:getPosition()
	local ability = combatContext:ability()
	local abilityObject = ability and ability:getAbilityObject()
	local overridePos = abilityObject and abilityObject.cacheValMap[AbilityConst.COMBAT_EVENT_PUPPET_SKILL_HIT_DISTANCE]

	if overridePos then
		CombatActionTool.parsePosition(combatContext, overridePos, lockedEntPos)
	end

	self.lockedEntPos = lockedEntPos

	local distance = Vector3.Distance(lockedEntPos, targetEntityPos)
	local dir = Vector3.SetNormalize(lockedEntPos - targetEntityPos)

	dir.y = 0

	Vector3.SetNormalize(dir)

	local curDisplacementOffset = distance - lockedEntRadius
	local reqDistance = 0

	if curDisplacementOffset < 0 then
		reqDistance = curDisplacementOffset - skillHitDisplacementData.colliderOffsetMin
	elseif curDisplacementOffset > skillHitDisplacementData.colliderOffsetMax then
		reqDistance = curDisplacementOffset - skillHitDisplacementData.colliderOffsetMax
	elseif curDisplacementOffset < skillHitDisplacementData.colliderOffsetMin then
		reqDistance = curDisplacementOffset - skillHitDisplacementData.colliderOffsetMin
	end

	local maxDisplacement = skillHitDisplacementData.maxDisplacement

	if reqDistance ~= 0 then
		local reqDisplacementOffset = 0

		if reqDistance < 0 and not skillHitDisplacementData.notBack then
			reqDisplacementOffset = -math.min(math.abs(reqDistance), maxDisplacement)
		elseif reqDistance > 0 and not skillHitDisplacementData.notForward then
			reqDisplacementOffset = math.min(reqDistance, maxDisplacement)
		end

		if reqDisplacementOffset ~= 0 then
			if Vector3.Angle(dir, self.dir) > 30 then
				return false
			end

			self.targetPos = targetEntityPos + dir * reqDisplacementOffset

			return true
		end
	end

	return false
end

function SkillHitDisplacementControl:update(deltaSeconds)
	if not self.isValid or not self.curControlData then
		return
	end

	local time = self.time

	self.time = self.time + deltaSeconds

	local duration = self.curControlData.duration
	local curTargetDisplacement, finalOffset

	if duration <= time then
		self:resetAll()

		return
	else
		if Vector3.HoriDistance(self.owner:getPosition(), self.startPos) > self.curControlData.maxDisplacement then
			self:resetAll()

			return
		end

		if not self:updateTargetPos() then
			EModelUtils.clearDisplacementVelocitySource(self.owner, Const.DisplacementVelocitySource.SkillHitDisplacement)

			return
		end

		local offset = self.targetPos - self.owner:getPosition()

		offset.y = 0
		curTargetDisplacement = offset * math.min(1, deltaSeconds / (duration - time))

		local forwardOffset = self.lockedEntPos - self.owner:getPosition()
		local cos = Vector3.Magnitude(Vector3(forwardOffset.x, 0, forwardOffset.z)) / Vector3.Magnitude(forwardOffset)
		local forwardDir = Vector3.Normalize(forwardOffset)

		finalOffset = forwardDir * (Vector3.Magnitude(curTargetDisplacement) / cos)

		if finalOffset.y < 0 and -finalOffset.y > self.owner.eModel.stepHeightDown then
			local finalPos = PhysicsUtils.getGroundPos(self.owner:getPosition() + finalOffset)

			finalOffset = finalPos - self.owner:getPosition()
		end
	end

	if Vector3.Dot(Vector3.SetNormalize(Vector3.Clone(curTargetDisplacement)), self.dir) < 0 then
		self:resetAll()

		return
	end

	if finalOffset and finalOffset.y < 0 then
		curTargetDisplacement = finalOffset
	end

	self:changeEntDisplacement(curTargetDisplacement, deltaSeconds)
end

function SkillHitDisplacementControl:changeEntDisplacement(targetDisplacement, deltaSeconds)
	if self.owner and self.owner.eModel then
		EModelUtils.setDisplacementVelocitySourceByOffset(self.owner, Const.DisplacementVelocitySource.SkillHitDisplacement, targetDisplacement, deltaSeconds, true, true)
	end
end

return SkillHitDisplacementControl
