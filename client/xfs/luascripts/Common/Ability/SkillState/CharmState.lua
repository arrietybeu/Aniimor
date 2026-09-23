-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\SkillState\\CharmState.lua

local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local SkillState = require("Common.Ability.SkillState.SkillState")
local AbilityConst = require("Common.Const.AbilityConst")
local PlayableConst = require("Common.Const.PlayableConst")
local LoggerManager = require("Core.Log.LoggerManager")
local CombatLogger = require("Common.Ability.CombatLogger")
local Const = require("Common.Const.Const")
local ConflictTypes = require("Common.ConflictTypes")
local lume = require("Core.Common.lume")
local AiConst = require("Common.Const.AiConst")
local Utils = require("Common.Utils.Utils")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local pg = pg
local CharmState = Class.LiteClass("CharmState", SkillState)

function CharmState:enter()
	SkillState.enter(self)

	if not self.owner:checkStatus(ConflictTypes.CT_CHARM, true) then
		self.owner.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)

		return
	end

	if self.owner.pauseBt then
		self.owner:pauseBt(AiConst.PauseBtReason.Charm)
	end

	local buff

	for _, buffData in ipairs(self.owner.buffDataList) do
		local buffTemplate = pg.global.abilityMgr:getBuffTemplate(buffData.templateId, buffData.level)

		if buffTemplate and lume.find(buffTemplate.tags or {}, AbilityConst.BUFF_TAG_CHARM) then
			buff = self.owner.actorBuff:findBuff(buffData.instanceId)

			break
		end
	end

	if buff == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("buff not found, exit charm")
		end

		self.owner.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)

		return
	end

	self.srcEntityId = buff.buffData.srcEntityId
	self.isFollow = true

	self:setRotation()
	self:playCharmWalk()
end

function CharmState:playCharmWalk()
	if Utils.checkClient() then
		self.owner:playAnimation(PlayableConst.SkillCharmWalk)
	else
		AnimationUtils.playAnimation(self.owner, PlayableConst.SkillCharmWalk, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY, true, nil, true)
	end
end

function CharmState:stopPlayCharmWalk()
	AnimationUtils.stopAnimation(self.owner, PlayableConst.SkillCharmWalk, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
end

function CharmState:setRotation()
	if self.owner.authority ~= Const.AUTHORITY_MASTER then
		return
	end

	local srcEntity = pg.getEntity(self.srcEntityId)

	self.owner:faceToTarget(srcEntity)
end

function CharmState:tick(delatSeconds)
	if not self.owner:inCharm() then
		self.owner.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)

		return
	end

	local srcEntity = pg.getEntity(self.srcEntityId)
	local isInSwim = self.owner:SWIM_ST()

	if srcEntity == nil or srcEntity.isDestroyed then
		if self.isFollow and isInSwim then
			self.isFollow = false

			self:stopPlayCharmWalk()
		elseif not self.isFollow and not isInSwim then
			self:playCharmWalk()

			self.isFollow = true
		end

		return
	end

	local stopDistance = self.owner.bodySize + srcEntity.bodySize + 0.3
	local deltaPosition = srcEntity:getPosition() - self.owner:getPosition()

	deltaPosition.y = 0

	if self.isFollow and (deltaPosition:SqrMagnitude() < stopDistance * stopDistance or isInSwim) then
		self.isFollow = false

		self:stopPlayCharmWalk()
	elseif not self.isFollow and not isInSwim and deltaPosition:SqrMagnitude() > stopDistance * stopDistance then
		self:playCharmWalk()

		self.isFollow = true
	end

	if self.isFollow then
		self:setRotation()
	end
end

function CharmState:leave()
	SkillState.leave(self)

	if self.owner.resumeBt then
		self.owner:resumeBt(AiConst.PauseBtReason.Charm)
	end

	self:stopPlayCharmWalk()
end

return CharmState
