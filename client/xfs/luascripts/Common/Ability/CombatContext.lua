-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\CombatContext.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local AbilityConst = require("Common.Const.AbilityConst")
local CombatCasterInfo = require("Common.Ability.CombatCasterInfo")
local CombatHitTargetInfo = require("Common.Ability.CombatHitTargetInfo")
local lume = require("Core.Common.lume")
local CombatLogger = require("Common.Ability.CombatLogger")
local Utils = require("Common.Utils.Utils")
local ChainAttackBP = require("Common.Data.SkillBPData.chain_attack_BP")
local ReactionBP = require("Common.Data.SkillBPData.tag_reaction_BP")
local Vector3 = Vector3
local pg = pg
local CombatContext = Class.LiteClass("CombatContext")

function CombatContext:init(actorId)
	self.actorId = actorId
	self.constCasterInfo = nil
	self.runtimeTargetInfo = nil
	self.srcType = AbilityConst.SRC_TYPE_NONE
	self.ctxType = nil
	self.chargeTime = nil
	self.abilityId = nil
	self.abilityStoreType = nil
	self.timelineId = nil
	self.isCutSceneFastForwarding = nil
	self.buffTemplateId = nil
	self.chainAttackCnt = nil
	self.tagReactionTags = nil
	self.projectileTemplateId = nil
	self.damageData = nil
	self.randomPointPos = nil
	self.lvModifyData = nil
	self.damageUITags = nil
	self.ignoreMiss = nil
	self.eventData = nil
	self.coroutineIns = nil
	self.isImmuteDamage = nil
	self.BPName = nil
	self.overrideAtk = nil
	self.nodeMap = nil

	if self.nodeStack then
		lume.clear(self.nodeStack)
	else
		self.nodeStack = {}
	end

	self.id = nil
	self.srcCombatContextId = nil
	self.refCnt = 0
	self.isDead = false
	self.isDying = false
	self.castingCombatContextId = 0
	self.srcCastingCombatContextId = nil
end

function CombatContext:setConstCasterInfo(source, fallbackActorId)
	if not self.constCasterInfo then
		self.constCasterInfo = pg.global.abilityMgr.constCasterInfoPool:get(true)
	end

	local constCasterInfo = self.constCasterInfo

	if source ~= nil and source == constCasterInfo then
		constCasterInfo.actorId = constCasterInfo.actorId or fallbackActorId
		constCasterInfo.srcActorId = constCasterInfo.srcActorId or fallbackActorId

		return constCasterInfo
	end

	if source then
		constCasterInfo:copyFrom(source)

		constCasterInfo.actorId = constCasterInfo.actorId or fallbackActorId
		constCasterInfo.srcActorId = constCasterInfo.srcActorId or fallbackActorId
	else
		constCasterInfo:clear()

		constCasterInfo.actorId = fallbackActorId
		constCasterInfo.srcActorId = fallbackActorId
	end

	return constCasterInfo
end

function CombatContext:ability()
	if self.abilityId == 0 or self.abilityId == nil then
		return nil
	end

	local ownerEntity = pg.getEntityByActorId(self.actorId)

	if not ownerEntity or not ownerEntity.getRawAbility then
		return nil
	end

	if Utils.isCreation(ownerEntity) or Utils.isSpellField(ownerEntity) then
		local masterEntity = pg.getEntityByActorId(ownerEntity.masterActorId)

		return masterEntity and masterEntity:getRawAbility(self.abilityId, self.abilityStoreType)
	end

	return ownerEntity:getRawAbility(self.abilityId, self.abilityStoreType)
end

function CombatContext:getAbilityTemplate()
	return pg.global.abilityMgr:getAbilityTemplate(self.abilityId)
end

function CombatContext:timeline()
	if self.ctxType ~= AbilityConst.COMBAT_CONTEXT_TYPE_TIMELINE then
		return
	end

	local ownerEntity = pg.getEntityByActorId(self.actorId)

	return ownerEntity and ownerEntity.actorTimeline:getTimelineInstance(self.timelineId)
end

function CombatContext:projectile()
	if self.ctxType ~= AbilityConst.COMBAT_CONTEXT_TYPE_PROJECTILE then
		return
	end

	local ownerEntity = pg.getEntityByActorId(self.actorId)

	return ownerEntity and ownerEntity.space and ownerEntity.space.projectileMgr:getProjectile(self.id)
end

function CombatContext:buff()
	if self.ctxType ~= AbilityConst.COMBAT_CONTEXT_TYPE_BUFF then
		return
	end

	local ownerEntity = pg.getEntityByActorId(self.actorId)

	return ownerEntity and ownerEntity.actorBuff and ownerEntity.actorBuff:findBuff(self.id)
end

function CombatContext:getBuffTemplate()
	return pg.global.abilityMgr:getBuffTemplate(self.buffTemplateId)
end

function CombatContext:clear()
	if rawget(self, "isClone") then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			CombatLogger.warn("CombatContext:clear on clone, rejected", self.id, self.BPName, debug.traceback())
		end

		return
	end

	if self.runtimeTargetInfo then
		pg.global.abilityMgr.runtimeTargetInfoPool:returnObject(self.runtimeTargetInfo)
	end

	if self.constCasterInfo then
		pg.global.abilityMgr.constCasterInfoPool:returnObject(self.constCasterInfo)
	end

	local nodeStack = self.nodeStack

	if nodeStack then
		lume.clear(nodeStack)
	end

	lume.clear(self)

	self.nodeStack = nodeStack
	self.refCnt = 0
	self.isDead = true
end

function CombatContext:addDamageUITag(tag)
	if self.damageUITags == nil then
		self.damageUITags = {}
	end

	if not lume.find(self.damageUITags, tag) then
		self.damageUITags[#self.damageUITags + 1] = tag
	end
end

function CombatContext:pushNodeIdToStack(nodeId)
	table.insert(self.nodeStack, nodeId)
end

function CombatContext:popNodeIdFromStack()
	if self.nodeStack then
		self.nodeStack[#self.nodeStack] = nil
	end
end

function CombatContext:setEventData(eventId, eventData)
	if self.eventData == nil then
		self.eventData = {}
	end

	self.eventData[eventId] = eventData
end

function CombatContext:clearEventData(eventId)
	if self.eventData == nil then
		self.eventData = {}
	end

	self.eventData[eventId] = nil
end

function CombatContext:getTemplateId()
	if self.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_ABILITY then
		return self.abilityId
	elseif self.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_TIMELINE then
		return self.timelineId
	elseif self.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_BUFF then
		return self.buffTemplateId
	elseif self.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_PROJECTILE then
		return self.projectileTemplateId
	elseif self.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_TAG_REACTION then
		return self.id
	elseif self.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_CHAIN_ATTACK then
		return self.chainAttackCnt
	end
end

function CombatContext:getDynamicInfo(dynamicInfo, runtimeTargetInfo, damageData, isSetMetatable)
	local dynamicInfo = dynamicInfo or {}

	dynamicInfo.runtimeTargetInfo = self.runtimeTargetInfo and self.runtimeTargetInfo:getRawTable(runtimeTargetInfo)
	dynamicInfo.randomPointPos = self.randomPointPos and self.randomPointPos:getRawTable()
	dynamicInfo.id = self.id
	dynamicInfo.chainAttackCnt = self.chainAttackCnt
	dynamicInfo.chargeTime = self.chargeTime
	dynamicInfo.nodeStack = Utils.deepCopyTable(self.nodeStack, dynamicInfo.nodeStack)
	dynamicInfo.eventData = self.eventData and self:deepCopyEventData(self.eventData, isSetMetatable)
	dynamicInfo.iterNumber = self.iterNumber
	dynamicInfo.waterAbsorbCount = self.waterAbsorbCount
	dynamicInfo.beAttackActorId = self.beAttackActorId
	dynamicInfo.overrideGameTime = self.overrideGameTime
	dynamicInfo.inActOnTargets = self.inActOnTargets
	dynamicInfo.followPhantomActorId = self.followPhantomActorId

	return dynamicInfo
end

local dynamicInfoCache = {}
local runtimeTargetInfoCache = {}
local damageDataCache = {}

function CombatContext:getRPCDynamicInfo()
	lume.clear(dynamicInfoCache)
	lume.clear(runtimeTargetInfoCache)
	lume.clear(damageDataCache)
	lume.clear(dynamicInfoCache.nodeStack)

	return self:getDynamicInfo(dynamicInfoCache, runtimeTargetInfoCache, damageDataCache, false)
end

function CombatContext:getStaticInfo()
	return {
		constCasterInfo = self.constCasterInfo and self.constCasterInfo:getRawTable(),
		abilityId = self.abilityId,
		abilityStoreType = self.abilityStoreType,
		srcType = self.srcType,
		castingCombatContextId = self.castingCombatContextId
	}
end

function CombatContext:deepCopyEventData(eventData, isSetMetatable)
	if type(eventData) ~= "table" then
		return eventData
	end

	if eventData.className == "CombatContext" then
		return eventData:clone(isSetMetatable)
	end

	local ret = {}

	for k, v in pairs(eventData) do
		if type(v) == "table" and v ~= self then
			ret[k] = self:deepCopyEventData(v, isSetMetatable)
		else
			ret[k] = v
		end
	end

	return ret
end

function CombatContext.getActorIdByCtxId(combatContextId)
	local lowRange = 32768

	return (combatContextId - combatContextId % lowRange) / lowRange
end

function CombatContext.convert(ownerEntity, dynamicInfo)
	local combatContext = ownerEntity:getCombatContext(dynamicInfo.id)

	if not combatContext then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("combatContext not found", ownerEntity.className, ownerEntity.actorId, dynamicInfo.id)
		end

		return
	end

	if dynamicInfo.eventData and dynamicInfo.eventData[AbilityConst.COMBAT_EVENT_RECEIVE_DAMAGE] then
		local eventDynamicInfo = dynamicInfo.eventData[AbilityConst.COMBAT_EVENT_RECEIVE_DAMAGE]
		local actorId = CombatContext.getActorIdByCtxId(eventDynamicInfo.id)
		local ent = pg.getEntityByActorId(actorId)

		if ent then
			local eventCombatContext = CombatContext.convert(ent, eventDynamicInfo)

			if eventCombatContext then
				dynamicInfo.eventData[AbilityConst.COMBAT_EVENT_RECEIVE_DAMAGE] = eventCombatContext
			end
		end
	end

	CombatHitTargetInfo.convert(dynamicInfo.runtimeTargetInfo)

	dynamicInfo.randomPointPos = Vector3.Convert(dynamicInfo.randomPointPos)
	dynamicInfo.__index = combatContext
	dynamicInfo.isClone = true

	setmetatable(dynamicInfo, dynamicInfo)

	return dynamicInfo
end

function CombatContext:clone(isSetMetatable)
	local combatContext = self
	local dynamicInfo = self:getDynamicInfo(nil, nil, nil, isSetMetatable)

	dynamicInfo.constCasterInfo = self.constCasterInfo and CombatCasterInfo.clone(self.constCasterInfo)
	dynamicInfo.isClone = true

	CombatHitTargetInfo.convert(dynamicInfo.runtimeTargetInfo)

	dynamicInfo.randomPointPos = Vector3.Convert(dynamicInfo.randomPointPos)
	dynamicInfo.nodeMap = self.nodeMap
	dynamicInfo.timelineEventStr = self.timelineEventStr

	if isSetMetatable ~= false then
		dynamicInfo.__index = combatContext

		setmetatable(dynamicInfo, dynamicInfo)
	end

	return dynamicInfo
end

function CombatContext:initNodeMap()
	if self.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_ABILITY then
		local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(self.abilityId)

		self.nodeMap = abilityTemplate and abilityTemplate.nodeMap
	elseif self.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_TIMELINE then
		local timelineTemplate = pg.global.abilityMgr:getTimelineTemplate(self:getTemplateId())

		self.nodeMap = timelineTemplate and timelineTemplate.nodeMap
	elseif self.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_PROJECTILE then
		local projectileTemplate = pg.global.abilityMgr:getProjectileTemplate(self:getTemplateId())

		self.nodeMap = projectileTemplate and projectileTemplate.nodeMap
	elseif self.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_BUFF then
		local buffTemplate = pg.global.abilityMgr:getBuffTemplate(self.buffTemplateId)

		self.nodeMap = buffTemplate and buffTemplate.nodeMap
	elseif self.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_CHAIN_ATTACK then
		self.nodeMap = ChainAttackBP[self.chainAttackCnt].nodeMap
	elseif self.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_TAG_REACTION then
		self.nodeMap = ReactionBP[self.tagReactionTags[1]][self.tagReactionTags[2]].nodeMap
	end
end

function CombatContext:getHitActionTimelineParam()
	local timeline = self:timeline()

	if timeline ~= nil and timeline.timelineParams.timelineKind == AbilityConst.TIMELINE_HIT then
		return timeline.timelineParams.hitParams
	end

	return nil
end

return CombatContext
