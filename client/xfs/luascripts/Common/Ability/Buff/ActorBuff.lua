-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\Buff\\ActorBuff.lua

local Class = require("Core.Framework.Class")
local AbilityConst = require("Common.Const.AbilityConst")
local Bitset = require("Common.Bitset")
local Utils = require("Common.Utils.Utils")
local AttributeConst = require("Common.Const.AttributeConst")
local PuppetData = require("Data.puppet_data")
local SysConfigData = require("Data.sys_config_data")
local ActorBuff = Class.LiteClass("ActorBuff")
local ToBool = ToBool
local pg = pg

function ActorBuff:ctor(owner, abilityMgr)
	self.owner = owner

	self:initActorBuff()

	self.abilityMgr = abilityMgr
	self.unSummonBuffFreezeTime = 0
end

function ActorBuff:initActorBuff()
	self.buffMap = {}
	self.buffThinkMap = {}
end

function ActorBuff:activate(deltaSeconds)
	local curTime = self.owner:getGameTime()

	for _, buff in pairs(self.buffThinkMap) do
		if self.unSummonBuffFreezeTime ~= 0 and buff.buffTemplate.isUnSummonFreeze then
			-- block empty
		elseif self.owner.breakBuffFreezeTime ~= 0 and AbilityConst.BUFF_BREAK_ID_SET[buff.buffData.templateId] then
			-- block empty
		elseif curTime >= buff.nextTickTime then
			buff.nextTickTime = buff.nextTickTime + buff.tickInterval

			buff:think()
		end
	end
end

function ActorBuff:clear()
	self.buffMap = {}
	self.buffThinkMap = {}
end

function ActorBuff:addBuff(buffData, registerDataToEntity, combatContext)
	return AbilityConst.BUFF_ADD_FAILED_NONE, self:addBuffInternal(buffData, registerDataToEntity, combatContext)
end

function ActorBuff:findOneBuffByTemplateId(templateId, casterId, abilityId)
	for _, buff in pairs(self.buffMap) do
		if buff.buffData.templateId == templateId and (not ToBool(casterId) or buff.buffData.srcEntityId == casterId) and (not ToBool(abilityId) or buff.buffData.srcAbilityId == abilityId) and not buff.isDestroyed then
			return buff
		end
	end
end

function ActorBuff:findBuffByTemplateId(templateId, casterId)
	local buffList = {}

	for _, buff in pairs(self.buffMap) do
		if buff.buffData.templateId == templateId and (not ToBool(casterId) or buff.buffData.srcEntityId == casterId) then
			table.insert(buffList, buff)
		end
	end

	return buffList
end

function ActorBuff:getBuffTemplateMap()
	local templateIdMap = {}

	for _, buff in pairs(self.buffMap) do
		if not templateIdMap[buff.buffData.templateId] then
			templateIdMap[buff.buffData.templateId] = true
		end
	end

	return templateIdMap
end

function ActorBuff:findBuff(instanceId)
	return self.buffMap[instanceId]
end

function ActorBuff:addBuffInternal(buffData, registerDataToEntity, combatContext)
	local newBuff = pg.global.abilityMgr:createBuff(buffData)

	newBuff:init(self.owner)

	if not newBuff:setup() then
		return false
	else
		self.buffMap[buffData.instanceId] = newBuff

		newBuff:start()
	end

	self.owner.subject:notify(AbilityConst.COMBAT_EVENT_ON_ADD_NEW_BUFF, newBuff.combatContext)

	local srcEntity = pg.getEntity(buffData.srcEntityId)

	if srcEntity then
		srcEntity.subject:notify(AbilityConst.COMBAT_EVENT_ON_ADD_BUFF_ON_TARGET, combatContext, self.owner.actorId, buffData.templateId, true)
	end

	return newBuff
end

function ActorBuff:hasTag(tagId)
	local buffTag = self.owner.buffTag or 0

	return buffTag ~= 0 and tagId and tagId >= 0 and tagId <= AbilityConst.BUFF_TAG_MAX and Bitset.band(buffTag, Bitset.lshift(1, tagId - 1)) ~= 0
end

function ActorBuff:hasSourceTag(tagId, actorId)
	if tagId then
		for _, buff in pairs(self.buffMap) do
			local srcEntity = pg.getEntity(buff.buffData.srcEntityId)

			if srcEntity and srcEntity.actorId == actorId and not buff.isDestroyed then
				for _, tag in ipairs(buff.buffTemplate.tags or AbilityConst.DEFAULT_NULL_TABLE) do
					if tag == tagId then
						return true
					end
				end
			end
		end
	end

	return false
end

function ActorBuff:getBuffByTag(tagId)
	local buffInstanceIds = self.buffTagArray[tagId]

	if ToBool(buffInstanceIds) then
		return self:findBuff(buffInstanceIds[1])
	end

	return nil
end

function ActorBuff:checkImmune(tagIds)
	if not ToBool(tagIds) then
		return false
	end

	for _, tagId in ipairs(tagIds) do
		if tagId >= 0 and tagId <= AbilityConst.BUFF_TAG_MAX then
			if tagId == AbilityConst.BUFF_TAG_CHARM and self:hasTag(AbilityConst.BUFF_TAG_SUPER_ARMOR) then
				return true
			end

			if Bitset.band(self.owner.buffImmuneTag, Bitset.lshift(1, tagId - 1)) ~= 0 then
				return true
			end
		end
	end

	return false
end

function ActorBuff:getBreakTime()
	local breakTime = self.owner.actorCombatAttribute:getRawAttribValue(AttributeConst.break_time)

	if breakTime == 0 then
		breakTime = SysConfigData.defaultBattleBreakTime
	end

	return breakTime
end

function ActorBuff:getBreakRecoverTime()
	local breakRecoverTime = self.owner.actorCombatAttribute:getRawAttribValue(AttributeConst.break_recover_time)

	if breakRecoverTime == 0 then
		breakRecoverTime = SysConfigData.defaultBattleBreakRecoverTime
	end

	return math.max(0.1, breakRecoverTime)
end

function ActorBuff:endUnsummonBuffFreeze()
	if self.unSummonBuffFreezeTime ~= 0 then
		local freezeTime = self.owner:getGameTime() - self.unSummonBuffFreezeTime

		for _, buff in pairs(self.buffMap) do
			if buff.buffTemplate.isUnSummonFreeze then
				buff.nextTickTime = buff.nextTickTime + freezeTime
			end
		end

		self.unSummonBuffFreezeTime = 0
	end
end

function ActorBuff:destroy()
	if self.defaultCombatContext then
		local defaultCombatContext = self.defaultCombatContext

		self.defaultCombatContext = nil

		pg.global.abilityMgr:returnCombatContextToPool(defaultCombatContext)
	end
end

function ActorBuff:getDefaultCombatContext(buffTemplateId)
	if not self.defaultCombatContext then
		self.defaultCombatContext = pg.global.abilityMgr.combatContextPool:getWithCtor(true, self.owner.actorId)

		self.defaultCombatContext:init(self.owner.actorId)

		self.defaultCombatContext.id = self.owner:genCombatContextId()

		self.defaultCombatContext:setConstCasterInfo(nil, self.owner.actorId)
	end

	local buffData = pg.global.abilityMgr:getBuffTemplate(buffTemplateId)

	self.defaultCombatContext.nodeMap = buffData.nodeMap

	return self.defaultCombatContext
end

return ActorBuff
