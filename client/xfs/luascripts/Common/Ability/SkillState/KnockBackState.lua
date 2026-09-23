-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\SkillState\\KnockBackState.lua

local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local SkillState = require("Common.Ability.SkillState.SkillState")
local LoggerManager = require("Core.Log.LoggerManager")
local CombatLogger = require("Common.Ability.CombatLogger")
local PlayableConst = require("Common.Const.PlayableConst")
local AbilityConst = require("Common.Const.AbilityConst")
local Const = require("Common.Const.Const")
local AiConst = require("Common.Const.AiConst")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local NotNil = NotNil
local Quaternion = Quaternion
local Vector3 = Vector3
local KnockBackState = Class.LiteClass("KnockBackState", SkillState)

function KnockBackState:ctor(owner)
	SkillState.ctor(self, owner)
end

function KnockBackState:enter(impulseH, dir)
	SkillState.enter(self)
	self:clearDisplacementVelocitySource(Const.DisplacementVelocitySource.KnockBack)

	if self.owner.authority == Const.AUTHORITY_MASTER then
		self.accelerateTime = 0

		self.owner:cancelAbility()

		local observer = self:getObserver()

		self.owner:startListenStunOnCollision(observer, function(tag)
			if pg.component == "client" then
				self.owner:serverMsgNoGC("RPC_SC_StunOnCollision", tag, 0)
			end

			self.owner.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)
		end)

		self.impulseH = impulseH
		self.dir = dir

		if self.impulseH == nil then
			self.owner.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)

			return
		end

		self:setKnockDirection(self.dir)
		self:setState(AbilityConst.KNOCK_STATE_UP_START)
	end

	self:playSkillSkateAnimation(PlayableConst.Hit_Back)

	if self.owner.pauseBt then
		self.owner:pauseBt(AiConst.PauseBtReason.KnockBack)
	end
end

function KnockBackState:tick(deltaSeconds)
	if self.owner:inBreak() or self.owner:isDead() then
		self.owner.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)
		self.owner.skillStateMgr:checkState()

		return
	end

	SkillState.tick(self, deltaSeconds)

	if self.owner.authority ~= Const.AUTHORITY_MASTER then
		if self.owner:STUN_ST() then
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				CombatLogger.debug("exit knockUp state by stone state", self.owner.actorId)
			end

			self.owner.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)

			return
		end

		if self.owner.knockState ~= AbilityConst.KNOCK_STATE_BACK then
			self.owner.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)
		end

		return
	end

	if self.accelerateTime < AbilityConst.KNOCK_ACCELERATE_TIME then
		local aveImpulseH = self.impulseH / AbilityConst.KNOCK_ACCELERATE_TIME * (self.accelerateTime * 2 + deltaSeconds) / 2
		local offset = self.dir * aveImpulseH * deltaSeconds

		self:setDisplacementVelocitySource(Const.DisplacementVelocitySource.KnockBack, offset, deltaSeconds, true)

		self.accelerateTime = self.accelerateTime + deltaSeconds

		return
	end

	local curImpulseH = self.impulseH - AbilitySettingGlobalConstData.friction * AbilitySettingGlobalConstData.gravity * deltaSeconds

	if curImpulseH < 0 then
		curImpulseH = 0
		deltaSeconds = self.impulseH / (AbilitySettingGlobalConstData.friction * AbilitySettingGlobalConstData.gravity)
	end

	local offset = self.dir * (self.impulseH + curImpulseH) * 0.5 * deltaSeconds

	self.impulseH = curImpulseH

	if self.impulseH <= 0 then
		self:clearDisplacementVelocitySource(Const.DisplacementVelocitySource.KnockBack)
		self:addDisplacementOffset(offset, true)
		self.owner.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)
	else
		self:setDisplacementVelocitySource(Const.DisplacementVelocitySource.KnockBack, offset, deltaSeconds, true)
	end
end

function KnockBackState:leave()
	self:clearDisplacementVelocitySource(Const.DisplacementVelocitySource.KnockBack)
	SkillState.leave(self)
	self:stopSkillStateAnimation(PlayableConst.Hit_Back)
	self:setState(AbilityConst.KNOCK_STATE_NONE)

	if self.owner.resumeBt then
		self.owner:resumeBt(AiConst.PauseBtReason.KnockBack)
	end
end

function KnockBackState:setState(state)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("setState", self.owner.actorId, state)
	end

	if self.owner.authority == Const.AUTHORITY_MASTER then
		self.owner.knockState = state

		if self.owner.refreshKnockGroup then
			self.owner:refreshKnockGroup(state)
		end

		if pg.component == "client" then
			self.owner:serverMsgNoGC("RPC_CS_SetKnockState", state)
		end
	end
end

return KnockBackState
