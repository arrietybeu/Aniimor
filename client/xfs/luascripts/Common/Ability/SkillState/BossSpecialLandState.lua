-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\SkillState\\BossSpecialLandState.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local SkillState = require("Common.Ability.SkillState.SkillState")
local AbilityConst = require("Common.Const.AbilityConst")
local PlayableConst = require("Common.Const.PlayableConst")
local CombatLogger = require("Common.Ability.CombatLogger")
local ConflictTypes = require("Common.ConflictTypes")
local AiConst = require("Common.Const.AiConst")
local BossSpecialLandState = Class.LiteClass("BossSpecialLandState", SkillState)

function BossSpecialLandState:enter(animKey)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("bossSpecialLandStateEnter", self.owner.actorId)
	end

	SkillState.enter(self)

	if self.owner.pauseBt then
		self.owner:pauseBt(AiConst.PauseBtReason.CombatControl)
	end

	self.owner:cancelAbility()

	self.isInAir = self.owner:isInAir()
	self.playableState = self.owner:playRawAnimation(animKey, 0, 0, 1)

	self.playableState:AddEndCallback(function(reason)
		if reason == PlayableConst.END_REASON.PLAYBACK then
			self.owner.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)
		end
	end)
end

function BossSpecialLandState:tick(deltaSeconds)
	if self.isInAir then
		local isInAir = self.owner:isInAir()

		if not isInAir then
			self.owner:stopFly()

			self.isInAir = false
		end
	end
end

function BossSpecialLandState:leave()
	SkillState.leave(self)
	self.owner:stopFly()

	if self.owner.resumeBt then
		self.owner:resumeBt(AiConst.PauseBtReason.CombatControl)
	end

	if self.playableState then
		self.owner:stopAnimation(self.playableState.Key)
	end
end

return BossSpecialLandState
