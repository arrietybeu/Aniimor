-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\SkillState\\BreakFallState.lua

local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local SkillState = require("Common.Ability.SkillState.SkillState")
local PlayableConst = require("Common.Const.PlayableConst")
local AbilityConst = require("Common.Const.AbilityConst")
local Time = require("Core.Common.Time")
local LoggerManager = require("Core.Log.LoggerManager")
local CombatLogger = require("Common.Ability.CombatLogger")
local ConflictTypes = require("Common.ConflictTypes")
local AiConst = require("Common.Const.AiConst")
local Utils = require("Common.Utils.Utils")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local BreakFallState = Class.LiteClass("BreakFallState", SkillState)

function BreakFallState:enter()
	SkillState.enter(self)

	if not self.owner:checkStatus(ConflictTypes.CT_BREAK) then
		self.owner.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)

		return
	end

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("breakFallEnter", self.owner.actorId)
	end

	if self.owner.pauseBt then
		self.owner:pauseBt(AiConst.PauseBtReason.BreakFall)
	end

	self.isInAir = self.owner:isInAir()

	self:playBreakFallHit()

	if not self.playableState then
		self.owner.skillStateMgr:switchState(AbilityConst.SKILL_STATE_BREAK)

		return
	end

	self.isPlayEnd = false
	self.aniFallEndLength = AnimationUtils.getPlayableClipLength(self.owner, PlayableConst.Fly_LieEnd, 0)
end

function BreakFallState:playBreakFallHit()
	if Utils.checkClient() then
		self.playableState = self.owner:playAnimation(PlayableConst.Fly_DropStart)

		if self.playableState then
			self.playableState:AddAutoTransition(0)
			self.playableState:RemoveEndCallback()
			self.playableState:AddEndCallback(function(reason)
				if reason == PlayableConst.END_REASON.PLAYBACK then
					self:playBreakFallLoop()
				end
			end)
		else
			self.owner.logger:error("BreakFallHit state not found", self.owner.actorId)
		end
	elseif self.owner.serverPlayAnimation then
		local dropStartAnimLen = AnimationUtils.getPlayableClipLength(self.owner, PlayableConst.Fly_DropStart, 0)

		if dropStartAnimLen == 0 then
			self:playBreakFallLoop()
		else
			self.playableState = self.owner:serverPlayAnimation(PlayableConst.Fly_DropStart, false, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
			self.startBreakFallLoopTimer = self.owner:addTimer(dropStartAnimLen, function()
				self:playBreakFallLoop()
			end)
		end
	end
end

function BreakFallState:playBreakFallLoop()
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("playBreakFallLoop", self.owner.actorId)
	end

	if Utils.checkClient() then
		self.playableState = self.owner:playAnimation(PlayableConst.Fly_DropLoop)
	elseif self.owner.serverPlayAnimation then
		self.playableState = self.owner:serverPlayAnimation(PlayableConst.Fly_DropLoop, true, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
	end
end

function BreakFallState:playBreakFallLand()
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("playBreakFallLand", self.owner.actorId)
	end

	if Utils.checkClient() then
		self.playableState = self.owner:playAnimation(PlayableConst.Fly_DropEnd)

		self.owner:stopFly()

		if self.playableState then
			self.playableState:AddAutoTransition(0)
			self.playableState:RemoveEndCallback()
			self.playableState:AddEndCallback(function(reason)
				if reason == PlayableConst.END_REASON.PLAYBACK then
					self:playBreakFallDownLoop()
				end
			end)
		end
	elseif self.owner.serverPlayAnimation then
		local dropEndAnimLen = AnimationUtils.getPlayableClipLength(self.owner, PlayableConst.Fly_DropEnd, 0)

		if dropEndAnimLen == 0 then
			self:playBreakFallDownLoop()
		else
			self.playableState = self.owner:serverPlayAnimation(PlayableConst.Fly_DropEnd, false, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
			self.startFallDownLoopTimer = self.owner:addTimer(dropEndAnimLen, function()
				self:playBreakFallDownLoop()
			end)
		end
	end
end

function BreakFallState:playBreakFallDownLoop()
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("playBreakFallDownLoop", self.owner.actorId)
	end

	if Utils.checkClient() then
		self.playableState = self.owner:playAnimation(PlayableConst.Fly_LieLoop)
	elseif self.owner.serverPlayAnimation then
		self.playableState = self.owner:serverPlayAnimation(PlayableConst.Fly_LieLoop, true, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
	end
end

function BreakFallState:tick(deltaSeconds)
	if not self.owner:inBreakFall() then
		self.owner.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)

		return
	end

	local isInAir = self.owner:isInAir()

	if not isInAir and self.isInAir then
		self:playBreakFallLand()

		if self.owner.stopFly then
			self.owner:stopFly()
		end

		self.isInAir = false
	end

	if not self.isPlayEnd and self.owner.breakEndTime - self.owner:getGameTime() < self.aniFallEndLength then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("playBreakFallEnd", self.owner.actorId, self.owner.breakRecoverTime - self.owner:getGameTime(), self.aniFallEndLength)
		end

		if Utils.checkClient() then
			if self.playableState then
				self.playableState:RemoveEndCallback()
			end

			self.playableState = self.owner:playAnimation(PlayableConst.Fly_LieEnd)
		elseif self.owner.serverPlayAnimation then
			self.playableState = self.owner:serverPlayAnimation(PlayableConst.Fly_LieEnd, false, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
		end

		self.isPlayEnd = true
	end
end

function BreakFallState:leave()
	SkillState.leave(self)

	if self.owner.stopFly then
		self.owner:stopFly()
	end

	if self.owner.resumeBt then
		self.owner:resumeBt(AiConst.PauseBtReason.BreakFall)
	end

	if Utils.checkClient() then
		if self.playableState then
			self.playableState:RemoveEndCallback()
			self.owner:stopAnimation(self.playableState.Key)
		end
	else
		self.playableState = nil

		self:stopAllServerAnimation()
	end
end

function BreakFallState:stopAllServerAnimation()
	if self.owner.serverStopAnimation then
		self.owner:serverStopAnimation(PlayableConst.Fly_LieEnd, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
		self.owner:serverStopAnimation(PlayableConst.Fly_DropStart, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
		self.owner:serverStopAnimation(PlayableConst.Fly_DropLoop, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
		self.owner:serverStopAnimation(PlayableConst.Fly_DropEnd, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
		self.owner:serverStopAnimation(PlayableConst.Fly_LieLoop, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
	end

	if self.startBreakFallLoopTimer then
		self.owner:removeTimer(self.startBreakFallLoopTimer)

		self.startBreakFallLoopTimer = nil
	end

	if self.startFallDownLoopTimer then
		self.owner:removeTimer(self.startFallDownLoopTimer)

		self.startFallDownLoopTimer = nil
	end
end

return BreakFallState
