-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\SkillState\\SkillState.lua

local Class = require("Core.Framework.Class")
local EventBus = require("Common.Ability.Buff.EventBus")
local Const = require("Common.Const.Const")
local SkillState = Class.LiteClass("SkillState")
local AbilityConst = require("Common.Const.AbilityConst")
local PlayableConst = require("Common.Const.PlayableConst")
local Utils = require("Common.Utils.Utils")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local NotNil = NotNil
local Vector3 = Vector3
local Quaternion = Quaternion

function SkillState:ctor(owner)
	self.owner = owner
	self.observer = nil
end

function SkillState:enter()
	self.owner:addAbilityTickReason(AbilityConst.ABILITY_TICK_REASONS.SKILL_STATE)
end

function SkillState:refresh()
	return
end

function SkillState:tick(deltaSeconds)
	return
end

function SkillState:leave()
	if self.observer then
		self.observer:unlistenAll()
	end

	self.owner:removeAbilityTickReason(AbilityConst.ABILITY_TICK_REASONS.SKILL_STATE)
end

function SkillState:getObserver()
	if not self.observer then
		self.observer = EventBus.EventObserver()
	end

	return self.observer
end

function SkillState:openKccFullSimulation()
	if Utils.checkClient() then
		self.owner.eModel:EnableKccFullSimulation(Const.COMPONENT_MOTION, true, Const.KccControlType.SkillControl)
	end
end

function SkillState:restoreKccFullSimulation()
	if Utils.checkClient() then
		self.owner.eModel:EnableKccFullSimulation(Const.COMPONENT_MOTION, false, Const.KccControlType.SkillControl)
	end
end

function SkillState:forceUngrounded(enable)
	if Utils.checkClient() then
		self.owner:forceUngrounded(enable)
	elseif self.owner.serverSetStick then
		self.owner:serverSetStick(not enable, Const.ForceUnGroundReasons.Ability)
	end
end

function SkillState:addDisplacementOffset(offset, clearVelocity)
	if Utils.checkClient() then
		if self.owner.eModel then
			self.owner.eModel:AddDisplacementOffset(Const.COMPONENT_MOTION, offset, true, clearVelocity)
		end
	elseif self.owner.serverAddDisplacementOffset then
		self.owner:serverAddDisplacementOffset(offset, true, clearVelocity)
	end
end

function SkillState:setDisplacementVelocitySource(source, offset, deltaSeconds, clearVelocity)
	if Utils.checkClient() then
		if self.owner.eModel then
			local EModelUtils = require("Entities.Utils.EModelUtils")

			EModelUtils.setDisplacementVelocitySourceByOffset(self.owner, source, offset, deltaSeconds, true, clearVelocity)
		end
	elseif self.owner.serverAddDisplacementOffset then
		self.owner:serverAddDisplacementOffset(offset, true, clearVelocity)
	end
end

function SkillState:clearDisplacementVelocitySource(source)
	if Utils.checkClient() and self.owner.eModel then
		local EModelUtils = require("Entities.Utils.EModelUtils")

		EModelUtils.clearDisplacementVelocitySource(self.owner, source)
	end
end

function SkillState:setKnockDirection(dir)
	if not dir then
		return
	end

	if not self:isAuthorityMaster() then
		return
	end

	if Utils.checkClient() then
		local forwardDir = Quaternion.MulVec3(Quaternion.AngleAxis(180, Vector3.up), dir)
		local EModelUtils = require("Entities.Utils.EModelUtils")

		EModelUtils.setMotionDirection(self.owner, forwardDir)
	else
		local forwardDir = Quaternion.MulVec3(Quaternion.AngleAxis(180, Vector3.up), dir)
		local targetRotation = Quaternion.LookRotation(forwardDir, Vector3.up)

		self.owner:faceToRotation(targetRotation)
	end
end

function SkillState:isAuthorityMaster()
	return self.owner.authority == Const.AUTHORITY_MASTER
end

function SkillState:playSkillSkateAnimation(key, isLoop)
	if Utils.checkClient() then
		if self.owner.playAnimation then
			self.playableState = self.owner:playAnimation(key)
		end
	else
		self.serverAnimState = nil

		if self.owner.serverPlayAnimation then
			self.owner:serverPlayAnimation(key, isLoop, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)

			self.serverAnimState = key
		end
	end
end

function SkillState:addCurAnimStateEndCallback(cb)
	if Utils.checkClient() then
		if self.playableState then
			self.playableState:AddEndCallback(cb)
		end
	else
		if self.curAnimEndTimer then
			self.owner:removeTimer(self.curAnimEndTimer)

			self.curAnimEndTimer = nil
		end

		if self.owner.serverPlayAnimation and self.serverAnimState then
			local curAnimLen = AnimationUtils.getPlayableClipLength(self.owner, self.serverAnimState, 0)

			if curAnimLen == 0 then
				cb(PlayableConst.END_REASON.PLAYBACK)
			else
				self.curAnimEndTimer = self.owner:addTimer(curAnimLen, function()
					cb(PlayableConst.END_REASON.PLAYBACK)
				end)
			end
		end
	end
end

function SkillState:stopSkillStateAnimation()
	if Utils.checkClient() then
		if self.playableState then
			self.playableState:RemoveEndCallback()
		end

		if self.playableState and self.owner.stopAnimation then
			self.owner:stopAnimation(self.playableState.Key)
		end

		self.playableState = nil
	else
		if self.owner.serverStopAnimation and self.serverAnimState then
			self.owner:serverStopAnimation(self.serverAnimState, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
		end

		self.serverAnimState = nil

		if self.curAnimEndTimer then
			self.owner:removeTimer(self.curAnimEndTimer)

			self.curAnimEndTimer = nil
		end
	end
end

return SkillState
