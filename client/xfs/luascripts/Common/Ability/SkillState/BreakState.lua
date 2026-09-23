-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\SkillState\\BreakState.lua

local Class = require("Core.Framework.Class")
local SkillState = require("Common.Ability.SkillState.SkillState")
local PlayableConst = require("Common.Const.PlayableConst")
local LoggerManager = require("Core.Log.LoggerManager")
local CombatLogger = require("Common.Ability.CombatLogger")
local AbilityConst = require("Common.Const.AbilityConst")
local ConflictTypes = require("Common.ConflictTypes")
local Utils = require("Common.Utils.Utils")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local Const = require("Common.Const.Const")
local Time = require("Core.Common.Time")
local AiConst = require("Common.Const.AiConst")
local BreakState = Class.LiteClass("BreakState", SkillState)

function BreakState:enter()
	SkillState.enter(self)

	if not self.owner:checkStatus(ConflictTypes.CT_BREAK) then
		self.owner.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)

		return
	end

	self.isPlayEnd = false
	self.stunStartAni = PlayableConst.StunStart
	self.stunLoopAni = PlayableConst.StunLoop
	self.stunEndAni = PlayableConst.StunEnd
	self.aniStunEndLength = AnimationUtils.getPlayableClipLength(self.owner, self.stunEndAni, 0)

	if self.owner.pauseBt then
		self.owner:pauseBt(AiConst.PauseBtReason.Break)
	end

	self:playStunStartAnimation()
end

function BreakState:tick(deltaSeconds)
	if not self.owner:inBreak() or self.owner:isDead() then
		self.owner.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)

		return
	end

	if self.owner.breakEndTime - self.owner:getGameTime() < self.aniStunEndLength and not ToBool(self.owner.breakBuffFreezeTime) and not self.isPlayEnd then
		self.isPlayEnd = true

		self:playStunEndAnimation()
	end
end

function BreakState:leave()
	if self.owner.resumeBt then
		self.owner:resumeBt(AiConst.PauseBtReason.Break)
	end

	SkillState.leave(self)
	self:stopAllStunAnimation()
end

function BreakState:playStunStartAnimation()
	if Utils.checkClient() then
		local state = self.owner:playAnimation(self.stunStartAni)

		if state then
			state:AddAutoTransition(0)
			state:RemoveEndCallback()
			state:AddEndCallback(function(reason)
				if reason == PlayableConst.END_REASON.PLAYBACK and self.owner:inBreak() then
					self.owner:playAnimation(self.stunLoopAni)
				end
			end)
		else
			self.owner:playAnimation(self.stunLoopAni)
		end
	elseif self.owner.serverPlayAnimation then
		local loopStartAnimLen = AnimationUtils.getPlayableClipLength(self.owner, self.stunStartAni, 0)

		if loopStartAnimLen == 0 then
			self.owner:serverPlayAnimation(self.stunLoopAni, true, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
		else
			self.owner:serverPlayAnimation(self.stunStartAni, false, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)

			self.startStunLoopTimer = self.owner:addTimer(loopStartAnimLen, function()
				self.owner:serverPlayAnimation(self.stunLoopAni, true, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
			end)
		end
	end
end

function BreakState:playStunEndAnimation()
	if Utils.checkClient() then
		self.owner:playAnimation(self.stunEndAni)
	elseif self.owner.serverPlayAnimation then
		return self.owner:serverPlayAnimation(self.stunEndAni, false, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
	end
end

function BreakState:stopAllStunAnimation()
	if Utils.checkClient() then
		self.owner:stopAnimation(self.stunStartAni)
		self.owner:stopAnimation(self.stunLoopAni)
		self.owner:stopAnimation(self.stunEndAni)
	else
		if self.owner.serverStopAnimation then
			self.owner:serverStopAnimation(self.stunStartAni, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
			self.owner:serverStopAnimation(self.stunLoopAni, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
			self.owner:serverStopAnimation(self.stunEndAni, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
		end

		if self.startStunLoopTimer then
			self.owner:removeTimer(self.startStunLoopTimer)

			self.startStunLoopTimer = nil
		end
	end
end

return BreakState
