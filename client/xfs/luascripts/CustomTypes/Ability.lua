-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\Ability.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local CustomDict = require("Core.PropertySync.CustomDict")
local AbilityConst = require("Common.Const.AbilityConst")
local CombatCasterInfo = require("Common.Ability.CombatCasterInfo")
local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")
local CombatLogger = require("Common.Ability.CombatLogger")
local CombatHitTargetInfo = require("Common.Ability.CombatHitTargetInfo")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local AbilityObject = require("Common.Ability.AbilityObject")
local Bitset = require("Common.Bitset")
local Utils = require("Common.Utils.Utils")
local AttributeConst = require("Common.Const.AttributeConst")
local lume = require("Core.Common.lume")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local pg = pg
local ToBool = ToBool
local bit = bit
local Ability = Class.LiteClass("Ability", CustomDict)

function Ability:ctor(initDict)
	Ability.super.ctor(self, initDict)
end

function Ability:isStolenAbility()
	return ToBool(self.srcAbilityIdBySteal)
end

function Ability:getCastingInfo()
	local entity = pg.getEntityByActorId(self.actorId)

	return entity.castingMap[self.abilityId]
end

function Ability:getAbilityTemplate()
	return pg.global.abilityMgr:getAbilityTemplate(self.abilityId, self.abilityLevel)
end

function Ability:initAbility(actorId)
	self.actorId = actorId

	local abilityParamData = pg.global.abilityMgr:getAbilityParamData(self.abilityId)

	self:initAbilityTag(abilityParamData)

	local entity = pg.getEntityByActorId(self.actorId)

	entity.castingMap[self.abilityId] = CombatCasterInfo(self.actorId)
	self.epCost = AbilityUtils.getAbilityParamEpCost(abilityParamData, entity)
	self.spCost = abilityParamData.spCost or 0
end

function Ability:initAbilityTag(abilityParamData)
	self.abilityTag = 0

	local abilityParamTags = abilityParamData.tags

	if ToBool(abilityParamTags) then
		for _, paramTagId in ipairs(abilityParamTags) do
			local tagId = AbilityConst.PARAM_TAG_2_ABILITY_TAG[paramTagId]

			if tagId ~= nil then
				self.abilityTag = bit.bor(self.abilityTag, bit.lshift(1, tagId - 1))
			end
		end
	end

	local abilityTags = self:getAbilityTemplate().tags

	if ToBool(abilityTags) then
		for _, tagId in ipairs(abilityTags) do
			self.abilityTag = bit.bor(self.abilityTag, bit.lshift(1, tagId - 1))
		end
	end
end

function Ability:isChargeAbility()
	return ToBool(self:getAbilityTemplate().isCharge)
end

function Ability:isSwitchAbility()
	return ToBool(self:getAbilityTemplate().isSwitch)
end

function Ability:getSwitchAbilitySafeTime()
	return self:getAbilityTemplate().switchSafeTime or 0
end

function Ability:isAbilityDelayStartCd()
	return ToBool(self:getAbilityTemplate().delayStartCd)
end

function Ability:hasTag(tagId)
	if tagId >= 0 and tagId <= AbilityConst.ABILITY_TAG_MAX then
		return ToBool(Bitset.band(self.abilityTag, Bitset.lshift(1, tagId - 1)))
	end

	return false
end

function Ability:registerCastingInfo()
	local entity = pg.getEntityByActorId(self.actorId)

	if entity then
		local combatCasterInfo = CombatCasterInfo(self.actorId)

		if Utils.isPuppet(entity) and entity.masterActorId then
			combatCasterInfo.srcActorId = entity.masterActorId
		end

		entity.castingMap[self.abilityId] = combatCasterInfo
	end
end

function Ability:clearCastingInfo()
	local entity = pg.getEntityByActorId(self.actorId)

	if not entity then
		return
	end

	local constCasterInfo = entity.castingMap[self.abilityId]

	if constCasterInfo then
		pg.global.abilityMgr.constCasterInfoPool:returnObject(constCasterInfo)

		entity.castingMap[self.abilityId] = nil
	end
end

function Ability:refresh(abilityId, abilityLevel, isSubAbility, cdEndTime)
	self.abilityId = abilityId
	self.abilityLevel = abilityLevel
	self.isSubAbility = isSubAbility
	self.cdEndTime = cdEndTime
end

function Ability:destroy()
	self.isDestroyed = true

	self:onDestroy()
	self:clearCastingInfo()
end

function Ability:onDestroy()
	local entity = pg.getEntityByActorId(self.actorId)

	if entity then
		local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(self.abilityId)
		local triggerActions = abilityTemplate[AbilityConst.TRIGGER_ON_ABILITY_REMOVED]

		if ToBool(triggerActions) and self:getAbilityObject().combatContext then
			lume.clear(self:getAbilityObject().combatContext.nodeStack)
			entity.combatAction:doActionIds(triggerActions, self:getAbilityObject().combatContext)
		end

		if not self:isStolenAbility() then
			if entity.abilityObjectMap[self.abilityId] then
				entity.abilityObjectMap[self.abilityId]:clearObject()

				entity.abilityObjectMap[self.abilityId] = nil
			end
		elseif entity.stolenAbilityObjectMap[self.abilityId] then
			entity.stolenAbilityObjectMap[self.abilityId]:clearObject()

			entity.stolenAbilityObjectMap[self.abilityId] = nil
		end

		entity:onAbilityDestroy(self)
	end
end

function Ability:isInCd()
	local owner = pg.getEntityByActorId(self.actorId)

	return owner:getGameTime() <= self.cdEndTime or owner.abilityFreezeMap[self.abilityId] ~= nil
end

function Ability:getObserver()
	local owner = pg.getEntityByActorId(self.actorId)

	return owner.abilityObjectMap[self.abilityId]:getObserver()
end

function Ability:getAbilityObject()
	local owner = pg.getEntityByActorId(self.actorId)

	if self:isStolenAbility() then
		if not owner.stolenAbilityObjectMap[self.abilityId] then
			owner.stolenAbilityObjectMap[self.abilityId] = AbilityObject()

			owner.stolenAbilityObjectMap[self.abilityId]:setOwner(owner)
		end

		return owner.stolenAbilityObjectMap[self.abilityId]
	else
		if not owner.abilityObjectMap[self.abilityId] then
			owner.abilityObjectMap[self.abilityId] = AbilityObject()

			owner.abilityObjectMap[self.abilityId]:setOwner(owner)
		end

		return owner.abilityObjectMap[self.abilityId]
	end
end

function Ability:startCoolDown(cdEndTime)
	self.cdEndTime = cdEndTime
end

function Ability:consumeCost()
	local entity = pg.getEntityByActorId(self.actorId)

	if not entity then
		return
	end

	if entity.gmMode ~= Const.NO_COST_MODE then
		local masterEntity = Utils.isPlayer(entity) and entity or Utils.isPet(entity) and entity:getMasterEntity()
		local castSkillFreeEpCnt = masterEntity and masterEntity.castSkillFreeEpCnt or 0
		local castSkillFreeSpCnt = masterEntity and masterEntity.castSkillFreeSpCnt or 0
		local curEpCost = self:getCurEpCost(entity)

		if curEpCost ~= 0 then
			if castSkillFreeEpCnt <= 0 then
				entity:costEp(curEpCost)

				if entity.lastAbilityConsume then
					entity.lastAbilityConsume.ep = curEpCost
				end

				local combatContext = self:getAbilityObject().combatContext

				combatContext.curEpCost = curEpCost
			else
				masterEntity.castSkillFreeEpCnt = masterEntity.castSkillFreeEpCnt - 1
			end
		end

		if self.spCost ~= 0 then
			if castSkillFreeSpCnt <= 0 then
				entity.actorCombatAttribute:changeSp(-self.spCost)
			else
				masterEntity.castSkillFreeSpCnt = masterEntity.castSkillFreeSpCnt - 1
			end
		end

		local rogueEpCost = AbilityUtils.getRogueEpCost(pg.global.abilityMgr:getAbilityParamData(self.abilityId), masterEntity)

		if rogueEpCost then
			local cacheEp = masterEntity.rogueCombatData[AbilityConst.ROGUE_BATTLE_DATA_KEY.SKILL_EP]
			local curEp = masterEntity.rogueCombatData[AbilityConst.ROGUE_BATTLE_DATA_KEY.SKILL_EP] - rogueEpCost

			curEp = math.max(0, curEp)

			if entity.lastAbilityConsume then
				entity.lastAbilityConsume.skillEp = cacheEp - curEp
			end

			masterEntity.rogueCombatData[AbilityConst.ROGUE_BATTLE_DATA_KEY.SKILL_EP] = curEp
		end
	end

	return true
end

function Ability:getCurEpCost(entity)
	local epCost = self.overrideEpCost >= 0 and self.overrideEpCost or self.epCost
	local epCostReduceRatio = math.max(1 - entity.actorCombatAttribute:getRawAttribValue(AttributeConst.ep_cost_reduce_ratio), 0)
	local epCostReduceFix = entity.actorCombatAttribute:getRawAttribValue(AttributeConst.ep_cost_reduce_fix)
	local shinyEpCostRatio = 1 + entity.actorCombatAttribute:getRawAttribValue(AttributeConst.shining_ep_cost_inc_ratio)

	epCost = math.max((epCost - epCostReduceFix) * epCostReduceRatio * shinyEpCostRatio, 0)

	return epCost
end

function Ability:setOverrideEpCost(overrideEpCost, epCostRatio, epCostFix)
	local curOverrideEpCost = overrideEpCost or self.overrideEpCost >= 0 and self.overrideEpCost or self.epCost

	curOverrideEpCost = curOverrideEpCost * epCostRatio + epCostFix
	self.overrideEpCost = math.max(curOverrideEpCost, 0)
end

function Ability:clearOverrideEpCost()
	self.overrideEpCost = -1
end

function Ability:cast(combatCasterInfo, castSource, extraInfo)
	local entity = pg.getEntityByActorId(self.actorId)

	if not entity then
		return
	end

	if pg.component == "game" then
		entity.forceSetCDMap[self.abilityId] = nil

		local cd = 0

		if castSource == AbilityConst.CAST_SOURCE.CALL_FRIENDS then
			cd = AbilitySettingGlobalConstData.callFriendsCD or 2
		else
			cd = AbilityUtils.getAbilityParamCd(self.abilityId, entity)
		end

		local isAbilityDelayStartCd = self:isAbilityDelayStartCd()

		if isAbilityDelayStartCd then
			self.markAbilityDelayCd = true
		end

		if castSource ~= AbilityConst.CAST_SOURCE.APPEAR and castSource ~= AbilityConst.CAST_SOURCE.CALL_FRIENDS and not self:isSwitchAbility() and not isAbilityDelayStartCd and not entity.isDummyClone then
			self:startCoolDown(entity:getGameTime() + cd)
		end

		entity.lastAbilityConsume.cd = 0
		entity.lastAbilityConsume.ep = 0
		entity.lastAbilityConsume.skillEp = 0

		if castSource ~= AbilityConst.CAST_SOURCE.CALL_FRIENDS and not entity.isDummyClone then
			self:consumeCost()

			local abilityParamData = pg.global.abilityMgr:getAbilityParamData(self.abilityId)

			if abilityParamData.costItemId and entity.delItemById then
				entity:delItemById(abilityParamData.costItemId, abilityParamData.costItemCnt)
			end

			entity.lastAbilityConsume.cd = cd
		end
	end

	self:onAbilityCast()
end

function Ability:onAbilityCast()
	local owner = pg.getEntityByActorId(self.actorId)

	if owner.clearSweepData then
		owner:clearSweepData(self.abilityId)
	end

	owner:clearHitBox(self.abilityId)
	owner:clearHitTargetCd(self.abilityId)

	local triggerActionData = self:getAbilityTemplate(self.abilityId)[AbilityConst.TRIGGER_ON_ABILITY_CAST]
	local combatContext = self:getAbilityObject().combatContext

	combatContext.attackSpeed = 1

	if self:isNormalAttack() and owner.actorCombatAttribute then
		combatContext.attackSpeed = owner.actorCombatAttribute:getAttribRatioValue(AttributeConst.normal_attack_speed_add_ratio)
	end

	local runtimeTargetInfo

	if ToBool(triggerActionData) then
		local castingInfo = self:getCastingInfo()

		if castingInfo.targetActorId then
			runtimeTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:getWithCtor(true, castingInfo.targetActorId)
			combatContext.runtimeTargetInfo = runtimeTargetInfo
		else
			combatContext.runtimeTargetInfo = nil
		end

		lume.clear(combatContext.nodeStack)
		owner.combatAction:doActionIds(triggerActionData, combatContext)
	end

	if owner.setOverrideSteeringTime then
		owner:setOverrideSteeringTime(owner.eModel.steeringTimeDefault)
	end

	owner.subject:notify(AbilityConst.COMBAT_EVENT_CAST_ABILITY, combatContext)

	if runtimeTargetInfo then
		pg.global.abilityMgr.runtimeTargetInfoPool:returnObject(runtimeTargetInfo)
	end

	combatContext.runtimeTargetInfo = nil
end

function Ability:onAbilityEnd()
	local owner = pg.getEntityByActorId(self.actorId)

	if not owner then
		return
	end

	if self.markAbilityDelayCd then
		local cd = AbilityUtils.getAbilityParamCd(self.abilityId, owner)

		self:startCoolDown(owner:getGameTime() + cd)

		self.markAbilityDelayCd = false
	end

	if owner.setOverrideSteeringTime then
		owner:setOverrideSteeringTime(-1)
	end

	local abilityObject = self:getAbilityObject()

	if abilityObject then
		local combatContext = abilityObject.combatContext

		if combatContext == nil then
			CombatLogger.error("combatContext not found", self.abilityId)

			return
		end

		lume.clear(combatContext.nodeStack)

		local triggerActionData = self:getAbilityTemplate(self.abilityId)[AbilityConst.TRIGGER_ON_ABILITY_END]

		if ToBool(triggerActionData) then
			owner.combatAction:doActionIds(triggerActionData, combatContext)
		end

		owner.subject:notify(AbilityConst.COMBAT_EVENT_ON_ABILITY_END, combatContext)
		lume.clear(abilityObject.cacheValMap)
	end
end

function Ability:initCombatContext()
	local owner = pg.getEntityByActorId(self.actorId)
	local combatContext = owner:getCombatContextFromCache(AbilityConst.COMBAT_CONTEXT_TYPE_ABILITY, self.combatContextId)

	if combatContext == nil and LoggerManager.checkLogger(LoggerConst.ERROR) then
		CombatLogger.error("gen combatContext failed", self.abilityId, self.storeType)
	end

	self:getAbilityObject().combatContext = combatContext

	local castingInfo = self:getCastingInfo()

	combatContext:setConstCasterInfo(castingInfo, self.actorId)

	combatContext.abilityId = self.abilityId
	combatContext.abilityStoreType = self.storeType
	combatContext.srcType = AbilityConst.SRC_TYPE_ABILITY
	combatContext.BPName = pg.global.abilityMgr:getAbilityTemplate(self.abilityId).BPName

	combatContext:initNodeMap()
end

function Ability:onAbilityAdded(doTriggers)
	local owner = pg.getEntityByActorId(self.actorId)

	self:initCombatContext()

	if doTriggers ~= false then
		local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(self.abilityId)
		local triggerActions = abilityTemplate[AbilityConst.TRIGGER_ON_ABILITY_ADDED]

		if not ToBool(triggerActions) then
			return false
		end

		lume.clear(self:getAbilityObject().combatContext.nodeStack)
		owner.combatAction:doActionIds(triggerActions, self:getAbilityObject().combatContext)
	end
end

function Ability:onLeaveCombat()
	local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(self.abilityId)

	if abilityTemplate.isLeaveCombatClearCD == true then
		self.cdEndTime = 0
	end
end

function Ability:isNormalAttack()
	local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(self.abilityId)

	return abilityTemplate and abilityTemplate.abilityType == AbilityConst.EnumAbilityType.Attack
end

return Ability
