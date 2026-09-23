-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\Buff\\Buff.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local EventBus = require("Common.Ability.Buff.EventBus")
local AbilityConst = require("Common.Const.AbilityConst")
local CombatContext = require("Common.Ability.CombatContext")
local Time = require("Core.Common.Time")
local AttributeConst = require("Common.Const.AttributeConst")
local AttributeProcessCustomData = require("Common.Ability.Attribute.AttributeProcessCustomData")
local AbilityObject = require("Common.Ability.AbilityObject")
local BuffConfigData = require("Data.buff_config_data")
local Const = require("Common.Const.Const")
local LoggerManager = require("Core.Log.LoggerManager")
local CombatLogger = require("Common.Ability.CombatLogger")
local Buff = Class.LiteClass("Buff", AbilityObject)
local pg = pg
local ToBool = ToBool

function Buff:ctor(buffData)
	AbilityObject.ctor(self)

	self.buffData = buffData
	self.srcCombatContext = nil
	self.overrideData = nil
end

function Buff:init(owner)
	self.owner = owner
	self.isDestroyed = false
	self.isThinking = false
	self.thinkCount = 0
	self.tickInterval = 0
	self.nextTickTime = 0
	self.buffTemplate = nil
	self.damageAvatarMap = nil

	self:setOwner(owner)
end

function Buff:setup()
	local buffData = self.buffData

	self.buffTemplate = pg.global.abilityMgr:getBuffTemplate(buffData.templateId)

	if self.buffTemplate == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj buffTemplate not found", buffData.templateId)
		end

		return false
	end

	if buffData.level <= 0 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj buffData level error", buffData.level)
		end

		return false
	end

	if buffData.expiredTime == 0 then
		self.buffData.expiredTime = buffData.duration + self.owner:getGameTime()
	end

	return true
end

function Buff:clear()
	self.buffData = nil
end

function Buff:start()
	self:initCombatContext()
	self:onStart()
end

function Buff:refresh()
	self:onRefresh()
end

function Buff:think()
	self:onThink()
end

function Buff:destroy(reason)
	reason = reason or AbilityConst.BUFF_DESTROY_REASON_NONE

	if self.buffData.instanceId <= 0 or self.isDestroyed then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj isvalid buff", self.buffData.instanceId, self.isDestroyed)
		end

		return
	end

	self.isDestroyed = true

	if self.isThinking then
		self:stopThink()
	end

	self:onDestroy()
end

function Buff:notifyBuffLifeEvent(eventType)
	if not self.owner or not self.owner.subject then
		return
	end

	self.owner.subject:notify(AbilityConst.COMBAT_EVENT_ON_BUFF_LIFE, eventType, self.buffData.templateId)
end

function Buff:startThink(delay, interval)
	if self.isThinking then
		return
	end

	self.isThinking = true
	self.thinkCount = 0
	self.tickInterval = interval
	self.nextTickTime = self.owner:getGameTime() + delay

	if self.buffData.freezeBuffStartTime ~= 0 then
		return
	end

	self.owner:addAbilityTickReason(AbilityConst.ABILITY_TICK_REASONS.BUFF_THINK)

	self.owner.actorBuff.buffThinkMap[self.buffData.instanceId] = self
end

function Buff:ignoreRemoveByTag()
	if BuffConfigData[self.buffData.templateId] and BuffConfigData[self.buffData.templateId].ignoreRemoveByTag then
		return true
	end

	return self.buffTemplate.ignoreRemoveByTag == true
end

function Buff:stopThink()
	if not self.isThinking then
		return
	end

	self.isThinking = false

	if self.buffData.freezeBuffStartTime ~= 0 then
		return
	end

	self.owner:removeAbilityTickReason(AbilityConst.ABILITY_TICK_REASONS.BUFF_THINK)

	self.owner.actorBuff.buffThinkMap[self.buffData.instanceId] = nil
end

function Buff:freezeThink()
	if not self.isThinking then
		return
	end

	self.owner:removeAbilityTickReason(AbilityConst.ABILITY_TICK_REASONS.BUFF_THINK)

	self.owner.actorBuff.buffThinkMap[self.buffData.instanceId] = nil
end

function Buff:recoverFreezeThink(freezeTime)
	if not self.isThinking then
		return
	end

	self.nextTickTime = self.nextTickTime + freezeTime

	self.owner:addAbilityTickReason(AbilityConst.ABILITY_TICK_REASONS.BUFF_THINK)

	self.owner.actorBuff.buffThinkMap[self.buffData.instanceId] = self
end

function Buff:stopAllEffects()
	if self.bindEffects then
		for _, effInsId in ipairs(self.bindEffects) do
			self.owner:stopEffectById(effInsId)
		end

		self.bindEffects = nil
	end
end

function Buff:onStart()
	if self.owner.playEffect then
		if self.buffTemplate.inheritGroupEffect then
			local effectInheritData = pg.global.abilityMgr.effectInheritMap[self.buffData.srcCombatContextId] or {}

			for _, effectData in pairs(self.buffTemplate.inheritGroupEffect) do
				local effectId = effectData.effectId or effectData
				local playTime = effectInheritData[effectId] or 0

				if LoggerManager.checkLogger(LoggerConst.DEBUG) then
					CombatLogger.debug("get InheritGroupEffect playTime", self.buffData.instanceId, effectId, playTime)
				end

				local effectInsId

				if ToBool(playTime) then
					effectInsId = self.owner:playEffect(effectId, {
						startTime = playTime
					}, effectData.forceSync)
				else
					effectInsId = self.owner:playEffect(effectId, nil, effectData.forceSync)
				end

				if effectInsId then
					self.owner.eModel:ChangeToPermanent(Const.COMPONENT_INDEX_EFFECT, effectInsId)
				end

				effectInheritData[effectId] = nil
			end
		end

		self:stopAllEffects()

		if self.buffTemplate.bindEffects then
			self.bindEffects = {}

			for _, effectId in ipairs(self.buffTemplate.bindEffects) do
				local effInsId = self.owner:playEffect(effectId, {
					manualSetProgress = true,
					duration = -1,
					customUpdateCallback = function(effectItem)
						local buffDuration = self.buffData.duration or 0
						local progress = 0

						if buffDuration > 0 and not self.buffData.isPermanent then
							local remainingTime = self:getRemainingTime()

							progress = math.clamp(1 - remainingTime / buffDuration, 0, 1)
						end

						effectItem:SetEffectProgress(progress)
					end
				})

				table.insert(self.bindEffects, effInsId)
			end
		end
	end

	if self.buffTemplate.inheritGroupSound and self.owner.playSoundEvent then
		for _, soundId in pairs(self.buffTemplate.inheritGroupSound) do
			self.owner:stopSoundEvent(soundId)
			self.owner:playSoundEvent(soundId)
		end
	end

	if not self.buffData:isInherit() then
		self:executeTriggers(AbilityConst.TRIGGER_ON_BUFF_START)
		self:notifyBuffLifeEvent(AbilityConst.BUFF_LIFE_EVENT_TYPE.START)
	else
		self:executeTriggers(AbilityConst.TRIGGER_ON_BUFF_INHERIT)
	end

	self.owner:postComponentMethod("addBuffEvent", self.buffData.templateId)
end

function Buff:onThink()
	self.thinkCount = self.thinkCount + 1

	self:executeTriggers(AbilityConst.TRIGGER_ON_BUFF_THINK)
end

function Buff:onRefresh()
	self:executeTriggers(AbilityConst.TRIGGER_ON_BUFF_REFRESH)
end

function Buff:onDestroy()
	self:stopAllEffects()

	if not self.buffData:isInherit() then
		self:executeTriggers(AbilityConst.TRIGGER_ON_BUFF_DESTROY)
		self:notifyBuffLifeEvent(AbilityConst.BUFF_LIFE_EVENT_TYPE.DESTROY)
	end

	if self.buffTemplate.inheritGroupEffect and self.owner.getEffectPlayTime then
		for _, effectData in pairs(self.buffTemplate.inheritGroupEffect) do
			local effectId = effectData.effectId or effectData
			local playTime = self.owner:getEffectPlayTime(effectId)

			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				CombatLogger.debug("set inheritGroupEffect playTime", self.buffData.instanceId, effectId, playTime)
			end

			if not pg.global.abilityMgr.effectInheritMap[self.buffData.srcCombatContextId] then
				pg.global.abilityMgr.effectInheritMap[self.buffData.srcCombatContextId] = {}
			end

			pg.global.abilityMgr.effectInheritMap[self.buffData.srcCombatContextId][effectId] = playTime

			self.owner:stopEffect(effectId, nil, nil, true)
		end
	end

	if self.buffTemplate.inheritGroupSound and self.owner.stopSoundEvent then
		for _, soundId in pairs(self.buffTemplate.inheritGroupEffect) do
			self.owner:stopSoundEvent(soundId)
		end
	end

	AbilityObject.clearObject(self)

	local srcCombatContextId = self.combatContext.srcCombatContextId
	local srcEntity = pg.getEntity(self.buffData.srcEntityId) or self.owner
	local srcCombatContext = srcEntity and srcEntity.getCombatContext and srcEntity:getCombatContext(srcCombatContextId)

	if srcCombatContext then
		srcEntity:returnCombatContext(srcCombatContext)
	end

	self.owner:postComponentMethod("removeBuffEvent", self.buffData.templateId)
end

function Buff:initCombatContext()
	self.combatContext = self.owner:getCombatContextFromCache(AbilityConst.COMBAT_CONTEXT_TYPE_BUFF, self.buffData.instanceId)
	self.combatContext.BPName = self.buffTemplate.BPName

	local srcAbility = self:getSrcAbility()

	self.combatContext.abilityId = srcAbility and srcAbility.abilityId
	self.combatContext.abilityStoreType = srcAbility and srcAbility.abilityStoreType or 0
	self.combatContext.buffTemplateId = self.buffData.templateId

	local srcCombatContextId = self.buffData.srcCombatContextId

	self.combatContext.srcCombatContextId = srcCombatContextId
	self.combatContext.castingCombatContextId = self.buffData.castingCombatContextId

	local srcEntity = pg.getEntity(self.buffData.srcEntityId) or self.owner

	self.combatContext:setConstCasterInfo(nil, srcEntity.actorId)

	self.combatContext.runtimeTargetInfo = nil

	self.combatContext:initNodeMap()

	local srcCombatContext = srcEntity and srcEntity.getCombatContext and srcEntity:getCombatContext(srcCombatContextId)

	if srcCombatContext then
		self.combatContext.srcCastingCombatContextId = srcCombatContext.srcCastingCombatContextId

		srcEntity:addCombatContextRefCnt(srcCombatContext)
	end
end

function Buff:onBuffLayerChange(oldLayer, newLayer)
	self:executeTriggers(AbilityConst.TRIGGER_ON_BUFF_LAYER_CHANGE)

	if oldLayer == nil or newLayer == nil then
		return
	end

	if oldLayer < newLayer then
		self:notifyBuffLifeEvent(AbilityConst.BUFF_LIFE_EVENT_TYPE.LAYER_INCREASE)
	elseif newLayer < oldLayer then
		self:notifyBuffLifeEvent(AbilityConst.BUFF_LIFE_EVENT_TYPE.LAYER_DECREASE)
	end
end

function Buff:getSrcEntity()
	return pg.getEntity(self.buffData.srcEntityId)
end

function Buff:getSrcAbility()
	local srcEntity = self:getSrcEntity()

	if not srcEntity or not srcEntity.getAbility then
		return nil
	end

	return srcEntity:getAbility(self.buffData.srcAbilityId, self.buffData.srcAbilityStoreType)
end

function Buff:getRemainingTime()
	if self.buffData.isPermanent then
		return math.maxFloat
	end

	return self.buffData.expiredTime - self.owner:getGameTime()
end

function Buff:executeTriggers(triggerName)
	if not self.combatContext then
		return
	end

	local triggerActions = self.buffTemplate[triggerName]

	if not ToBool(triggerActions) then
		return
	end

	pg.global.abilityMgr.combatAction:doActionIds(triggerActions, self.combatContext)
end

return Buff
