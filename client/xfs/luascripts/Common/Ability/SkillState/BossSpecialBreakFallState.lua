-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\SkillState\\BossSpecialBreakFallState.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local SkillState = require("Common.Ability.SkillState.SkillState")
local PlayableConst = require("Common.Const.PlayableConst")
local AbilityConst = require("Common.Const.AbilityConst")
local CombatLogger = require("Common.Ability.CombatLogger")
local ConflictTypes = require("Common.ConflictTypes")
local AiConst = require("Common.Const.AiConst")
local BossSpecialBreakFallState = Class.LiteClass("BossSpecialBreakFallState", SkillState)

function BossSpecialBreakFallState:enter()
	SkillState.enter(self)

	if not self.owner:checkStatus(ConflictTypes.CT_BREAK) then
		self.owner.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)

		return
	end

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("bossSpecialBreakFallStateEnter", self.owner.actorId)
	end

	if self.owner.pauseBt then
		self.owner:pauseBt(AiConst.PauseBtReason.BreakFall)
	end

	self.owner:cancelAbility()

	self.isInAir = self.owner:isInAir()
	self.playableState = self.owner:playRawAnimation(PlayableConst.Break_Success, 0, 0, 1)
	self.isPlayEnd = false

	local endClipConfig = self.owner:getPlayableClipConfig(PlayableConst.Fly_LieEnd)

	self.aniFallEndLength = endClipConfig.clipLength
end

function BossSpecialBreakFallState:tick(deltaSeconds)
	if not self.owner:inBreakFall() then
		self.owner.isBossSpecialBreakFall = nil

		self.owner.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)

		return
	end

	local isInAir = self.owner:isInAir()

	if not isInAir and self.isInAir then
		self.owner:stopFly()

		self.isInAir = false
	end

	if not self.isPlayEnd and self.owner.breakRecoverTime - self.owner:getGameTime() < self.aniFallEndLength then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("playBreakFallEnd", self.owner.actorId, self.owner.breakRecoverTime - self.owner:getGameTime(), self.aniFallEndLength)
		end

		self.playableState = self.owner:playAnimation(PlayableConst.Fly_LieEnd)
		self.isPlayEnd = true
	end
end

function BossSpecialBreakFallState:leave()
	SkillState.leave(self)
	self.owner:stopFly()

	if self.owner.resumeBt then
		self.owner:resumeBt(AiConst.PauseBtReason.BreakFall)
	end

	if self.playableState then
		self.owner:stopAnimation(self.playableState.Key)
	end
end

return BossSpecialBreakFallState
