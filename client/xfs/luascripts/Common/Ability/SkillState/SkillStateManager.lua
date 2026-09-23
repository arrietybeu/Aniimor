-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\SkillState\\SkillStateManager.lua

local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local AbilityConst = require("Common.Const.AbilityConst")
local BreakFallState = require("Common.Ability.SkillState.BreakFallState")
local BreakState = require("Common.Ability.SkillState.BreakState")
local CharmState = require("Common.Ability.SkillState.CharmState")
local KnockBackState = require("Common.Ability.SkillState.KnockBackState")
local KnockUpState = require("Common.Ability.SkillState.KnockUpState")
local BossSpecialBreakFallState = require("Common.Ability.SkillState.BossSpecialBreakFallState")
local AppearDashState = require("Common.Ability.SkillState.AppearDashState")
local BossSpecialLandState = require("Common.Ability.SkillState.BossSpecialLandState")
local LoggerManager = require("Core.Log.LoggerManager")
local CombatLogger = require("Common.Ability.CombatLogger")
local SkillStateManager = Class.LiteClass("SkillStateManager")

function SkillStateManager:ctor(owner)
	self.owner = owner
	self.currentState = AbilityConst.SKILL_STATE_NONE
	self.states = {}
	self.states[AbilityConst.SKILL_STATE_BREAK_FALL] = BreakFallState(self.owner)
	self.states[AbilityConst.SKILL_STATE_BREAK] = BreakState(self.owner)
	self.states[AbilityConst.SKILL_STATE_CHARM] = CharmState(self.owner)
	self.states[AbilityConst.SKILL_STATE_KNOCK_BACK] = KnockBackState(self.owner)
	self.states[AbilityConst.SKILL_STATE_KNOCK_UP] = KnockUpState(self.owner)
	self.states[AbilityConst.SKILL_STATE_BOSS_SPECIAL_BREAK_FALL] = BossSpecialBreakFallState(self.owner)
	self.states[AbilityConst.SKILL_STATE_APPEAR_DASH] = AppearDashState(self.owner)
	self.states[AbilityConst.SKILL_STATE_BOSS_SPECIAL_LAND] = BossSpecialLandState(self.owner)
end

function SkillStateManager:tick(deltaSeconds)
	self:checkState()

	if self.currentState ~= AbilityConst.SKILL_STATE_NONE then
		if self.owner.hitFrameFreezeTimer then
			deltaSeconds = deltaSeconds * self.owner.hitFrameFreezeScale
		end

		self.states[self.currentState]:tick(deltaSeconds)
	end
end

function SkillStateManager:checkState()
	if self.currentState == AbilityConst.SKILL_STATE_NONE then
		if self.owner:inBreak() then
			if self.owner:inBreakFall() then
				if self.owner.isBossSpecialBreakFall then
					self:switchState(AbilityConst.SKILL_STATE_BOSS_SPECIAL_BREAK_FALL)
				else
					self:switchState(AbilityConst.SKILL_STATE_BREAK_FALL)
				end
			else
				self:switchState(AbilityConst.SKILL_STATE_BREAK)
			end
		elseif self.owner.knockState == AbilityConst.KNOCK_STATE_BACK then
			self:switchState(AbilityConst.SKILL_STATE_KNOCK_BACK)
		elseif self.owner.knockState > AbilityConst.KNOCK_STATE_BACK and self.currentState ~= AbilityConst.SKILL_STATE_KNOCK_UP then
			self:switchState(AbilityConst.SKILL_STATE_KNOCK_UP)
		elseif self.owner:inCharm() then
			self:switchState(AbilityConst.SKILL_STATE_CHARM)
		end
	end
end

function SkillStateManager:switchState(newState, ...)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("switchState", self.currentState, newState)
	end

	local oldState = self.currentState

	self.currentState = newState

	if oldState ~= AbilityConst.SKILL_STATE_NONE and oldState ~= newState then
		self.states[oldState]:leave()
	end

	if newState ~= AbilityConst.SKILL_STATE_NONE then
		if newState == oldState then
			self.states[self.currentState]:refresh(...)
		else
			self.states[self.currentState]:enter(...)
		end
	end
end

return SkillStateManager
