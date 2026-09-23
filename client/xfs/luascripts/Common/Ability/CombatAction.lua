-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\CombatAction.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local CombatActionTool = require("Common.Ability.CombatActionTool")
local Lume = require("Core.Common.lume")
local AbilityConst = require("Common.Const.AbilityConst")
local CombatContext = require("Common.Ability.CombatContext")
local CombatLogger = require("Common.Ability.CombatLogger")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local AttributeConst = require("Common.Const.AttributeConst")
local GuardValue = require("Common.Ability.GuardValue")
local Switch = require("Core.Common.Switch")
local AttributeProcessCustomData = require("Common.Ability.Attribute.AttributeProcessCustomData")
local HitFrameFreezeData = require("Data.hit_frame_freeze_data")
local VoxelReactionData = require("Common.Data.voxel_reaction_data")
local VoxelUtils = require("Common.Utils.VoxelUtils")
local VoxelConst = require("Common.Const.VoxelConst")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local AIUtils = require("Common.Utils.AIUtils")
local EventBus = require("Common.Ability.Buff.EventBus")
local EntityCacheValueUtils = require("Common.Utils.EntityCacheValueUtils")
local ItemConst = require("Common.Const.ItemConst")
local ListPool = require("Common.Container.ListPool")
local ProjectileConst = require("Common.Const.ProjectileConst")
local AiConst = require("Common.Const.AiConst")
local EventConst = require("Const.EventConst")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local ProjectileParams = require("Common.Ability.Projectile.ProjectileParams")
local BuffTagGroupData = require("Common.Data.SkillBPData.buff_tag_group_data")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local FormulaData = require("Data.formula_data")
local ElementPropData = require("Data.element_prop_data")
local pg = pg
local ToBool = ToBool
local Vector3 = Vector3
local Vector2 = Vector2
local Quaternion = Quaternion
local unpack = unpack
local VEC3_CONST_UP = Vector3.constUp
local VEC3_CONST_LEFT = Vector3.constLeft
local VEC3_CONST_FORWARD = Vector3.constForward
local CombatAction = Class.LiteClass("CombatAction")

function CombatAction:ctor()
	if jit then
		local table_new = require("table.new")

		self.tempCacheCenterData = table_new(3, 0)
		self.tempCacheRotData = table_new(3, 0)
	else
		self.tempCacheCenterData = {}
		self.tempCacheRotData = {}
	end
end

function CombatAction:calcAttributeResult(targetEntity, abilityLevelAttribute, combatContext)
	if not targetEntity.actorCombatAttribute then
		return false
	end

	local customData = AttributeProcessCustomData(abilityLevelAttribute, combatContext)
	local actorAttributeModifier = pg.global.abilityMgr.actorAttributeModifier

	for attributeName, value in pairs(abilityLevelAttribute) do
		local attributeId = AttributeConst[attributeName]

		if attributeId then
			actorAttributeModifier:modifyAttrib(targetEntity.actorCombatAttribute, attributeId, value, customData)
		elseif LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("@jqj attributeName not valid", attributeName)
		end
	end
end

function CombatAction:doAction(actionData, combatContext)
	if combatContext.isDead ~= false then
		CombatActionTool.logError(combatContext, Utils.isTable(actionData) and actionData or {}, "combatContext is dead")

		return false
	end

	if not Utils.isTable(actionData) then
		CombatActionTool.logError(combatContext, nil, "actionData not found")

		return false
	end

	local nodeId = actionData.NodeID
	local actionFun = self[actionData.name]

	if actionFun then
		if combatContext.actorId == pg.debugAbilityActorId and LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("doAction", actionData.name, actionData.NodeID, combatContext.BPName, inspect(actionData))
		end

		combatContext:pushNodeIdToStack(nodeId)

		local isOk, result = xpcall(actionFun, debug.traceback, self, actionData, combatContext)

		combatContext:popNodeIdFromStack()

		if not isOk then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				CombatLogger.logException("do action error", combatContext.BPName, actionData.name, actionData.NodeID, result)
			end

			return false
		end

		return result
	end

	return false
end

function CombatAction:doActionById(nodeId, combatContext)
	if combatContext.nodeMap == nil then
		CombatActionTool.logError(combatContext, {
			NodeID = nodeId
		}, "combatContext.nodeMap not found")

		return false
	end

	local actionData = combatContext.nodeMap[nodeId]

	if not actionData then
		CombatActionTool.logError(combatContext, {
			NodeID = nodeId
		}, "actionData not found")

		return false
	end

	local result = self:doAction(actionData, combatContext)

	return result
end

function CombatAction:setMask(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))
	local maskParser = AbilityConst.ACTION_MASK_PARSER

	if targetEntity ~= nil then
		for k, v in pairs(actionData.mask) do
			if maskParser[k] == nil then
				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					CombatLogger.error("mask not exist", k)
				end
			else
				local maskKey = maskParser[k]

				if maskKey ~= AbilityConst.ACTION_MASK_IN_SKILL and maskKey ~= AbilityConst.ACTION_MASK_IN_ATTACK and targetEntity.setActionMask then
					targetEntity:setActionMask(maskKey, v, combatContext.abilityId)
				end
			end
		end

		return true
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj CombatAction:setMask failed, targetEntity is nil", actionData.target, inspect(actionData.mask))
		end

		return false
	end
end

function CombatAction:setNextComboAbilityId(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity ~= nil then
		if targetEntity.setNextComboAbility then
			targetEntity:setNextComboAbility(actionData.abilityId)
		end

		return true
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("CombatAction:setNextComboAbilityId failed, targetEntity is nil", targetActorId, actionData.target)
		end

		return false
	end
end

function CombatAction:applyHitFrameFreeze(actionData, combatContext)
	local hitParams = combatContext:getHitActionTimelineParam()

	if not hitParams then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj hit params not found")
		end

		return false
	end

	local attackData = hitParams.attackData

	if not attackData then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj attackData not found")
		end

		return false
	end

	local hitFrameFreezeId = AbilityUtils.getAttackDataHitFrameFreezeId(attackData)
	local attackFrameFreeze
	local attackTimeScale = 0.01
	local hitFrameFreezeData = HitFrameFreezeData[hitFrameFreezeId]

	if hitFrameFreezeData ~= nil then
		attackFrameFreeze = hitFrameFreezeData.frameFreeze
		attackTimeScale = hitFrameFreezeData.timeScale or 0.01
	end

	if attackFrameFreeze == nil then
		return false
	end

	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_TARGET))
	local casterEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_CASTER))

	if not casterEntity then
		return false
	end

	local canFrameFreeze = false

	if Utils.isPlayer(casterEntity) then
		canFrameFreeze = true
	elseif Utils.isPet(casterEntity) then
		canFrameFreeze = casterEntity:getMasterEntity():isPetInControl(casterEntity.id)
	end

	if not canFrameFreeze then
		return false
	end

	if targetEntity ~= nil then
		if combatContext:timeline() == nil then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				CombatLogger.error("@jqj ctx type errot, not COMBAT_CONTEXT_CLASS_FLAG_ActionTimelineBase")
			end

			return false
		end

		if targetEntity.startFrameFreeze then
			targetEntity:startFrameFreeze(AbilityConst.FRAME_FREEZE_KEY_HIT, attackTimeScale, attackFrameFreeze)
		end

		if casterEntity.startFrameFreeze then
			casterEntity:startFrameFreeze(AbilityConst.FRAME_FREEZE_KEY_HIT, attackTimeScale, attackFrameFreeze)
		end

		return true
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("CombatAction:applyHitFrameFreeze failed, targetEntity is nil", targetEntity.actorId, actionData.target)
		end

		return false
	end
end

function CombatAction:print(actionData, combatContext)
	local value = self:getVal(actionData.value, combatContext)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("print value", value)
	end

	return true
end

function CombatAction:isType(actionData, combatContext)
	local targetType = actionData.type
	local isNot = actionData["not"]
	local targetEntity = pg.getEntityByActorId(combatContext.runtimeTargetInfo.actorId)
	local isType = false

	if targetType == AbilityConst.EFFECT_TARGET_ELEMENT then
		if Utils.isCreation(targetEntity) then
			isType = true
		end
	else
		isType = true
	end

	return isNot and not isType or isType
end

function CombatAction:frameFreeze(actionData, combatContext, force)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj targetEntity not found", actionData.target)
		end

		return false
	end

	local timeScale = actionData.timeScale or 0.01
	local duration = actionData.duration

	if timeScale and duration then
		if targetEntity.startFrameFreeze then
			targetEntity:startFrameFreeze(AbilityConst.FRAME_FREEZE_KEY_NORMAL, timeScale, duration, force)
		end

		local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

		if not abilityObject then
			return false
		end

		abilityObject:addExitCallback(function()
			if targetEntity.stopFrameFreeze then
				targetEntity:stopFrameFreeze(AbilityConst.FRAME_FREEZE_KEY_NORMAL)
			end
		end)
	end

	return true
end

function CombatAction:doActionIds(actionIds, combatContext)
	if not actionIds then
		return false
	end

	local result = true

	for idx, nodeId in ipairs(actionIds) do
		result = ToBool(self:doActionById(nodeId, combatContext)) and result
	end

	return result
end

function CombatAction:doActions(actionData, combatContext)
	if not actionData or not actionData.actionIds then
		return false
	end

	local result = true

	for idx, nodeId in ipairs(actionData.actionIds or EMPTY_TABLE) do
		result = ToBool(self:doActionById(nodeId, combatContext)) and result
	end

	return result
end

function CombatAction:doActionsByConditions(actionData, combatContext)
	local conditionActionIds = actionData.conditionActionIds or {}
	local actionIds = actionData.actionIds or {}
	local conditionOk = true

	for idx, condition in ipairs(conditionActionIds) do
		if not ToBool(self:doActionById(condition, combatContext)) then
			conditionOk = false

			break
		end
	end

	local val = 0

	if conditionOk then
		for idx, nodeId in ipairs(actionIds or EMPTY_TABLE) do
			local ret = self:doActionById(nodeId, combatContext)

			if type(ret) == "number" then
				val = val + ret
			end
		end
	elseif actionData.elseActionIds then
		for idx, nodeId in ipairs(actionData.elseActionIds or EMPTY_TABLE) do
			local ret = self:doActionById(nodeId, combatContext)

			if type(ret) == "number" then
				val = val + ret
			end
		end
	end

	return val
end

function CombatAction:registerStopChargeEvent(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_CASTER)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("target not found", AbilityConst.COMBAT_TARGET_TYPE_CASTER)
		end

		return false
	end

	local observer = CombatActionTool.getContextObserver(combatContext)

	if observer == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("observer not found")
		end

		return false
	end

	local abilityId = combatContext:timeline().timelineParams.srcAbilityId

	if not ToBool(abilityId) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("abilityId not found")
		end

		return false
	end

	local chargeTimeActions = actionData.chargeTimeActions
	local copyCombatContext = combatContext:clone()

	targetEntity.maxChargeTime = {
		combatContext.abilityId,
		actionData.chargeTimeActions[#actionData.chargeTimeActions].chargeTime
	}

	local function stopChargeFun(chargeTime)
		chargeTime = math.max(0, chargeTime or 0)

		local minChargeTime = actionData.minChargeTime or 0

		local function doActionFun(realChargeTime)
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				CombatLogger.debug("doActionFun, realChargeTime", realChargeTime)
			end

			copyCombatContext:setEventData(AbilityConst.COMBAT_EVENT_END_CHARGE, {
				chargeTime = realChargeTime
			})

			for idx = #chargeTimeActions, 1, -1 do
				if realChargeTime >= chargeTimeActions[idx].chargeTime then
					return self:doActions(chargeTimeActions[idx], copyCombatContext)
				end
			end

			copyCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_END_CHARGE)
		end

		if targetEntity.subject:isEventListening(AbilityConst.COMBAT_EVENT_ON_SKILL_AUTO_AIM) then
			observer:unlisten(targetEntity.subject, AbilityConst.COMBAT_EVENT_ON_SKILL_AUTO_AIM)
		end

		if chargeTime < minChargeTime then
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				CombatLogger.debug("wait min chargeTime", actionData.minChargeTime)
			end

			local delay = math.max(0.1, minChargeTime - chargeTime)
			local timer = targetEntity:addTimer(delay, function()
				doActionFun(minChargeTime)
			end)
			local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

			if not abilityObject then
				return false
			end

			abilityObject:addExitCallback(function()
				if LoggerManager.checkLogger(LoggerConst.DEBUG) then
					CombatLogger.debug("remove wait min chargeTime timer", timer)
				end

				targetEntity:removeTimer(timer)
			end)

			return true
		else
			doActionFun(chargeTime)

			return true
		end

		return false
	end

	local chargeInfo = targetEntity.chargeMap[abilityId]
	local isFromAutoCast = combatContext.constCasterInfo and combatContext.constCasterInfo.isFromAutoCast

	if chargeInfo == nil or isFromAutoCast then
		return stopChargeFun(0)
	end

	if chargeInfo[1] ~= nil and chargeInfo[2] ~= nil and chargeInfo[2] > chargeInfo[1] then
		return stopChargeFun(chargeInfo[2] - chargeInfo[1])
	end

	observer:listen(targetEntity.subject, AbilityConst.COMBAT_EVENT_END_CHARGE, stopChargeFun)

	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	if targetEntity.stopChargeByAbilityId then
		abilityObject:addExitCallback(function()
			targetEntity:stopChargeByAbilityId(abilityId)
		end)
	end

	return true
end

function CombatAction:removeEvent(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("target not found", AbilityConst.COMBAT_TARGET_TYPE_CASTER)
		end

		return false
	end

	local observer = CombatActionTool.getContextObserver(combatContext)

	if observer == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("observer not found")
		end

		return false
	end

	local eventId = actionData.eventName

	if eventId == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("not support event name", actionData.eventName)
		end

		return false
	end

	observer:unlisten(targetEntity.subject, eventId)
end

function CombatAction:isFirstEnterBreak(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if targetEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("target not found", actionData.target)
		end

		return false
	end

	if not targetEntity.inBreak or not targetEntity:inBreak() then
		return false
	end

	if targetEntity.doneEnterBreakAction == nil then
		targetEntity.doneEnterBreakAction = true

		return true
	end

	return false
end

function CombatAction:isInCharacterState(actionData, combatContext)
	local target = actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, target))

	if not targetEntity then
		return false
	end

	local isNot = actionData.isNot
	local isParentState = actionData.isParentState
	local result

	if isParentState == true then
		result = CharacterStateConst.isChildOfState(targetEntity.characterState, CharacterStateConst[actionData.stateName])
	else
		result = targetEntity.characterState == CharacterStateConst[actionData.stateName]
	end

	return isNot == true and not result or result
end

function CombatAction:switchSkill(actionData, combatContext)
	local target = AbilityConst.COMBAT_TARGET_TYPE_CASTER
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, target))

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			CombatLogger.info("targetEntity not found", target)
		end

		return false
	end

	local now = targetEntity:getGameTime()
	local timeline = combatContext:timeline()
	local buff = combatContext:buff()

	if targetEntity.clearSwitchSkillRecoverTimer then
		targetEntity:clearSwitchSkillRecoverTimer(actionData.from)
	end

	local duration = actionData.overrideDuration
	local abilityObj

	if timeline then
		duration = duration or timeline:getRemainingTime()
		abilityObj = timeline
	elseif buff then
		duration = duration or buff:getRemainingTime()
		abilityObj = buff
	end

	local rawDuration = duration

	if ToBool(actionData.notShowCountDown) then
		duration = 0
	end

	if targetEntity.switchSkill then
		targetEntity:switchSkill(actionData.from, actionData.to, duration and now + duration)
	end

	if actionData.recoverOnExit and abilityObj then
		abilityObj:addExitCallback(function()
			if targetEntity.switchSkill then
				targetEntity:switchSkill(actionData.from, actionData.from, now)
			end
		end)
	elseif actionData.isAutoRecoverByDuration and rawDuration and targetEntity.startSwitchSkillRecoverTimer then
		targetEntity:startSwitchSkillRecoverTimer(actionData.from, rawDuration, now)
	end

	if targetEntity.disableReturnAbilityConsumes then
		targetEntity:disableReturnAbilityConsumes(combatContext.castingCombatContextId)
	end

	if targetEntity.addCastAbilitySp then
		targetEntity:addCastAbilitySp(combatContext.castingCombatContextId)
	end
end

function CombatAction:registerDeadEvent(actionData, combatContext)
	local targetEntity = CombatActionTool.getRegisterEventSubjectEntity(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER)

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("target not found", AbilityConst.COMBAT_TARGET_TYPE_OWNER)
		end

		return false
	end

	if actionData.actionIds then
		local observer = CombatActionTool.getContextObserver(combatContext)

		if observer then
			local copyCombatContext = combatContext:clone()

			observer:listen(targetEntity.subject, AbilityConst.COMBAT_EVENT_DEAD, function()
				self:doActions(actionData, copyCombatContext)
			end)
		end
	end
end

function CombatAction:getVal(val, combatContext)
	if val == nil then
		return nil
	end

	if not Utils.isTable(val) or val.name == nil then
		return val
	end

	return self:doAction(val, combatContext)
end

function CombatAction:isInRange(actionData, combatContext)
	local lValue = self:getVal(actionData.lValue, combatContext)
	local rValue = self:getVal(actionData.rValue, combatContext)
	local mValue = self:getVal(actionData.mValue, combatContext)

	if lValue ~= nil and rValue ~= nil and mValue ~= nil then
		return lValue < mValue and mValue < rValue
	end

	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		CombatLogger.error("isInRange failed", lValue, mValue, rValue)
	end

	return false
end

function CombatAction:isInBattleField(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("isInBattleField failed, target not found", actionData.target)
		end

		return false
	end

	return targetEntity.inBattleField or false
end

function CombatAction:getHpRatio(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if not targetEntity then
		return 0
	end

	return targetEntity.actorCombatAttribute:getHpRatio()
end

function CombatAction:greater(actionData, combatContext)
	local lValue = self:getVal(actionData.lValue, combatContext)
	local rValue = self:getVal(actionData.rValue, combatContext)

	if lValue ~= nil and type(lValue) == type(rValue) then
		return rValue < lValue
	end

	return false
end

function CombatAction:getVoxelNum(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return 0
	end

	local space = ownerEntity.space

	if not space then
		return 0
	end

	local voxelTag = AbilityConst.TAG_STR_TO_NUM[actionData.voxelTag]

	if not voxelTag or voxelTag == 0 then
		return 0
	end

	local radius = actionData.radius
	local position = ownerEntity:getPosition()
	local count = 0

	if ownerEntity.abilityOverrideVoxelState ~= 0 then
		if voxelTag == ownerEntity.abilityOverrideVoxelState then
			for _, element in pairs(AbilityConst.TAG_ABILITY_ELEMENT_LIST) do
				count = count + VoxelUtils.countVoxelByTag(space.id, element, position[1], position[2], position[3], radius, radius, radius)
			end
		else
			count = 0
		end
	else
		count = VoxelUtils.countVoxelByTag(space.id, voxelTag, position[1], position[2], position[3], radius, radius, radius)
	end

	return count
end

function CombatAction:hasBuff(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if targetEntity == nil or not targetEntity.actorBuff then
		return false
	end

	return targetEntity.actorBuff:findOneBuffByTemplateId(actionData.buffId) ~= nil
end

function CombatAction:getConditionTypes(combatContext, actionData, elementType)
	if actionData.needEcs == false or combatContext.BPName == nil then
		return {}
	end

	local abilityMgr = pg.global.abilityMgr

	if not abilityMgr.conditionTypesCache[combatContext.BPName] then
		abilityMgr.conditionTypesCache[combatContext.BPName] = {}
	end

	local cacheResult = abilityMgr.conditionTypesCache[combatContext.BPName][actionData.NodeID]

	if cacheResult then
		return cacheResult
	end

	local conditionTypes = {}
	local condition = pg.global.abilityMgr:getVoxelCondition(combatContext.abilityId, combatContext.buffTemplateId, elementType)

	if not condition or condition == AbilityConst.CONDITION_TYPE_NONE then
		local abilityTypeTemplate = pg.global.abilityMgr:getAbilityTemplate(combatContext.abilityId)
		local abilityType = abilityTypeTemplate and abilityTypeTemplate.abilityType
		local calcData = combatContext.nodeMap[actionData.calcResultNodeId]

		if abilityType ~= AbilityConst.EnumAbilityType.Attack and calcData and calcData.attackData then
			condition = CombatActionTool.getAttackConditionType(calcData.attackData, combatContext)
		end
	end

	if not ToBool(actionData.ignoreAbilityElement) and condition and condition ~= AbilityConst.CONDITION_TYPE_NONE then
		conditionTypes[#conditionTypes + 1] = condition
	end

	local condition = AbilityConst.CONDITION_TYPE_PARSER[actionData.actOnTag]

	if condition and condition ~= AbilityConst.CONDITION_TYPE_NONE then
		conditionTypes[#conditionTypes + 1] = condition
	end

	abilityMgr.conditionTypesCache[combatContext.BPName][actionData.NodeID] = conditionTypes

	return conditionTypes
end

function CombatAction:actOnTargets(actionData, combatContext, overrideCenterPos, overrideRot)
	if not combatContext.constCasterInfo and LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("not constCasterInfo")
	end

	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	local multiTargetsInfo = pg.global.abilityMgr.multiTargetInfoPool:get(true)
	local scale = 1

	if actionData.isScaleWithModel ~= false then
		scale = ownerEntity.curModelScale or 1
	end

	local centerData = self.tempCacheCenterData
	local rotData = self.tempCacheRotData

	Lume.clear(centerData)
	Lume.clear(rotData)

	local argsData

	if #actionData.target > 1 and not ToBool(actionData.hitBoxId) then
		local abilityId = combatContext.abilityId or 0

		actionData.hitBoxId = "sameHitBox_" .. tostring(abilityId) .. "_" .. tostring(actionData.NodeID)

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("@hyj create sameHitBoxId for batch targets: ", actionData.hitBoxId, abilityId, actionData.NodeID)
		end
	end

	combatContext.inActOnTargets = true
	combatContext.actOnTargetsNodeId = actionData.NodeID

	local center = Vector3.GetFromPool(0, 0, 0)
	local rot = Quaternion.GetFromPool(0, 0, 0, 1)

	for idx, tgt in ipairs(actionData.target) do
		if not CombatActionTool.parseMultiTargetInfo(pg.global.abilityMgr, tgt, multiTargetsInfo, scale, combatContext) then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				CombatLogger.error("@jqj parseMultiTargetInfo failed")
			end

			combatContext.multiTargetsInfo = nil
			combatContext.targetIndex = nil
			combatContext.inActOnTargets = false
			combatContext.actOnTargetsNodeId = nil

			pg.global.abilityMgr.multiTargetInfoPool:returnObject(multiTargetsInfo)
			Vector3.returnToPool(center)
			Quaternion.returnToPool(rot)

			return false
		end

		combatContext.multiTargetsInfo = multiTargetsInfo
		combatContext.targetIndex = idx

		local conditionTypes = self:getConditionTypes(combatContext, actionData)
		local maxRange

		combatContext.ignoreMiss = actionData.ignoreMiss

		center:Copy(overrideCenterPos or ownerEntity:getPosition())
		rot:Copy(overrideRot or ownerEntity:getRotation())

		if overrideCenterPos == nil and not CombatActionTool.parsePosition(combatContext, multiTargetsInfo.center, center) and actionData.noTargetOffsetXYZ then
			local noTargetOffsetXYZ = actionData.noTargetOffsetXYZ

			CombatActionTool.translatePointOffsetXYZ(center, ownerEntity:getPosition(), ownerEntity:getRotation(), noTargetOffsetXYZ[1] * scale, noTargetOffsetXYZ[2] * scale, noTargetOffsetXYZ[3] * scale)

			local dist = Vector3.Distance(center, ownerEntity:getPosition())

			maxRange = dist + multiTargetsInfo.maxRange + 5

			if overrideRot == nil and actionData.noTargetOffsetRotation then
				CombatActionTool.applyOffsetRotation(rot, actionData.noTargetOffsetRotation)
			end
		else
			local dist = Vector3.Distance(center, ownerEntity:getPosition())

			maxRange = dist + multiTargetsInfo.maxRange + 5

			if overrideRot == nil then
				CombatActionTool.parseRotationFromTo(combatContext, multiTargetsInfo.rotFrom, multiTargetsInfo.rotTo, rot)

				local offsetXYZ = multiTargetsInfo.offsetXYZ

				CombatActionTool.translatePointOffsetXYZ(center, center, rot, offsetXYZ[1] * scale, offsetXYZ[2] * scale, offsetXYZ[3] * scale)
				CombatActionTool.applyOffsetRotation(rot, multiTargetsInfo.offsetRotation)
			end
		end

		if ownerEntity.authority ~= Const.AUTHORITY_SIMULATED_PROXY or AbilityUtils.isServerPuppetCreation(ownerEntity) then
			if pg.component == "client" then
				self:actOnActors(ownerEntity, combatContext, multiTargetsInfo, conditionTypes, actionData, center, rot, maxRange, tgt)
			else
				ownerEntity:waitOrTriggerClientNotifyHit(actionData, tgt, combatContext)
			end
		end

		if pg.component == "client" then
			self:actOnVoxel(ownerEntity, combatContext, multiTargetsInfo, conditionTypes, center, rot, maxRange)
		end

		combatContext.multiTargetsInfo = nil
		combatContext.targetIndex = nil

		local cacheCenterDataIndex = (idx - 1) * 3

		for ci = 1, 3 do
			centerData[cacheCenterDataIndex + ci] = center[ci]
		end

		local cacheRotDataIndex = (idx - 1) * 4

		for ri = 1, 4 do
			rotData[cacheRotDataIndex + ri] = rot[ri]
		end

		if idx > 1 then
			argsData = argsData or {}
			argsData[#argsData + 1] = Utils.deepCopyTable(multiTargetsInfo.shapeArgs)
		end
	end

	Vector3.returnToPool(center)
	Quaternion.returnToPool(rot)

	combatContext.inActOnTargets = false
	combatContext.actOnTargetsNodeId = nil

	return true, centerData, rotData, multiTargetsInfo, argsData
end

function CombatAction:actOnTargetsSpreadAnnularSector(actionData, combatContext)
	if not combatContext.constCasterInfo then
		return false
	end

	local casterEntity = pg.getEntityByActorId(combatContext.constCasterInfo.actorId)

	if not casterEntity then
		return false
	end

	if casterEntity.startSpreadAnnularSector then
		casterEntity:startSpreadAnnularSector(actionData, combatContext)
	end
end

function CombatAction:actOnVoxel(ownerEntity, combatContext, multiTargetsInfo, conditionTypes, center, rot, maxRange)
	if not ownerEntity or not ownerEntity.space then
		return
	end

	local shape

	for _, conditionType in ipairs(conditionTypes) do
		local reactionName = AbilityConst.CONDITION_NUM_TO_STR[conditionType]
		local actions = VoxelReactionData[reactionName]

		if actions == nil then
			CombatActionTool.returnShape(shape)

			return
		end

		if shape == nil then
			shape = CombatActionTool.getShape(multiTargetsInfo.shapeKind, multiTargetsInfo.shapeArgs)
			shape.center = center
			shape.rot = Quaternion.ToYaw(rot)
		end

		VoxelUtils.doVoxelReact(ownerEntity.space.id, reactionName, multiTargetsInfo.shapeKind, shape)
	end

	CombatActionTool.returnShape(shape)
end

function CombatAction:checkDistanceLess(actionData, combatContext)
	local pointA = Vector3.GetFromPool(0, 0, 0)

	if not CombatActionTool.parsePosition(combatContext, actionData.targetA, pointA) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("parsePosition failed targetA: ", actionData.targetA)
		end

		Vector3.returnToPool(pointA)

		return false
	end

	local pointB = Vector3.GetFromPool(0, 0, 0)

	if not CombatActionTool.parsePosition(combatContext, actionData.targetB, pointB) then
		Vector3.returnToPool(pointA)
		Vector3.returnToPool(pointB)

		return false
	end

	if ToBool(actionData.ignoreYAxis) then
		pointA.y = 0
		pointB.y = 0
	end

	local ret = Vector3.SqrDistance(pointA, pointB) < actionData.distance * actionData.distance

	Vector3.returnToPool(pointA)
	Vector3.returnToPool(pointB)

	return ret
end

function CombatAction:isNot(actionData, combatContext)
	return not ToBool(self:doAction(actionData.action, combatContext))
end

function CombatAction:isActorType(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if not targetEntity then
		return false
	end

	return Utils.isActorType(targetEntity, actionData.actorType)
end

function CombatAction:hasTarget(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)

	return ToBool(targetActorId) and ToBool(pg.getEntityByActorId(targetActorId))
end

function CombatAction:registerAttackEvent(actionData, combatContext)
	local observer = CombatActionTool.getContextObserver(combatContext)

	if not observer then
		return false
	end

	local targetEntity = CombatActionTool.getRegisterEventSubjectEntity(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("targetEntity not found", actionData.target)
		end

		return false
	end

	local copyCombatContext = combatContext:clone()

	observer:listen(targetEntity.subject, AbilityConst.COMBAT_EVENT_ATTACK, function(curCombatContext)
		copyCombatContext:setEventData(AbilityConst.COMBAT_EVENT_ATTACK, curCombatContext)
		self:doActions(actionData, copyCombatContext)
		copyCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_ATTACK)
	end)

	return true
end

function CombatAction:clearHitBox(actionData, combatContext)
	local entity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not entity then
		return false
	end

	local abilityId = combatContext.abilityId or 0

	if entity.clearHitBox then
		entity:clearHitBox(abilityId, actionData.hitBoxId)
	end
end

function CombatAction:registerEnterCombatEvent(actionData, combatContext)
	local owner = CombatActionTool.getRegisterEventSubjectEntity(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local observer = CombatActionTool.getContextObserver(combatContext)

	if observer then
		local copyCombatContext = combatContext:clone()

		observer:listen(owner.subject, AbilityConst.COMBAT_EVENT_ENTER_COMBAT, function()
			self:doActions(actionData, copyCombatContext)
		end)

		if owner:isInCombat() then
			self:doActions(actionData, copyCombatContext)
		end
	end
end

function CombatAction:registerLeaveCombatEvent(actionData, combatContext)
	local owner = CombatActionTool.getRegisterEventSubjectEntity(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER)

	if not owner then
		return
	end

	local observer = CombatActionTool.getContextObserver(combatContext)

	if observer then
		local copyCombatContext = combatContext:clone()

		observer:listen(owner.subject, AbilityConst.COMBAT_EVENT_LEAVE_COMBAT, function()
			self:doActions(actionData, copyCombatContext)
		end)
	end
end

function CombatAction:getCacheVal(actionData, combatContext)
	local target = actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, target))

	if not ownerEntity then
		return 0
	end

	local key = self:getVal(actionData.key, combatContext)
	local val = ownerEntity.getEntityCacheVal and ownerEntity:getEntityCacheVal(key)

	if val == nil then
		return 0
	end

	return val
end

function CombatAction:setCacheVal(actionData, combatContext)
	local target = actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, target))

	if not ownerEntity then
		return false
	end

	local value = self:getVal(actionData.val, combatContext)

	return ownerEntity.setEntityCacheVal and ownerEntity:setEntityCacheVal(actionData.key, value)
end

function CombatAction:getTargetPosition(actionData, combatContext)
	Vector3.enableCreateFromCache()

	local refPos = Vector3(0, 0, 0)
	local result = CombatActionTool.parsePosition(combatContext, actionData.target, refPos)

	if not result then
		Vector3.disableCreateFromCache()

		return nil
	end

	Vector3.disableCreateFromCache(refPos)

	return refPos
end

function CombatAction:getTargetRotation(actionData, combatContext)
	Vector3.enableCreateFromCache()

	local refRot = Quaternion(0, 0, 0, 1)
	local result = CombatActionTool.parseRotation(combatContext, actionData.target, refRot)

	if not result then
		Vector3.disableCreateFromCache()

		return nil
	end

	if actionData.offsetRotation then
		local offsetRotation = Vector3(unpack(actionData.offsetRotation))

		if offsetRotation.x ~= 0 then
			refRot:Copy(refRot * Quaternion.AngleAxis(offsetRotation.x, VEC3_CONST_LEFT))
		end

		if offsetRotation.y ~= 0 then
			refRot:Copy(refRot * Quaternion.AngleAxis(offsetRotation.y, VEC3_CONST_UP))
		end

		if offsetRotation.z ~= 0 then
			refRot:Copy(refRot * Quaternion.AngleAxis(offsetRotation.z, VEC3_CONST_FORWARD))
		end
	end

	Quaternion.removeTempQuaterion(refRot)
	Vector3.disableCreateFromCache()

	return refRot
end

function CombatAction:getPetByIdx(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if not targetEntity then
		return 0
	end

	if Utils.isPet(targetEntity) then
		targetEntity = targetEntity:getMasterEntity()
	end

	if targetEntity and targetEntity.petPrepareList then
		local petEntity = pg.getEntity(targetEntity.petPrepareList[actionData.petIndex])

		return petEntity and petEntity.actorId or 0
	end

	return 0
end

function CombatAction:registerTrapEvent(actionData, combatContext)
	local posType = actionData.center
	local targetActorId = CombatActionTool.parseActorId(combatContext, posType)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("target not found, posType", posType)
		end

		return false
	end

	local shapeKind = actionData.shapeKind
	local shapeArgs = actionData.shapeArgs

	if shapeArgs and shapeArgs.name then
		shapeArgs = self:doAction(shapeArgs, combatContext)
	end

	local relation = actionData.relation
	local isPortal = ToBool(actionData.isPortal)
	local triggerId = actionData.trapKey ~= nil and actionData.trapKey ~= "" and actionData.trapKey or actionData.UID
	local observer = CombatActionTool.getContextObserver(combatContext)

	if (actionData.enterTrapActionIds ~= nil or actionData.leaveTrapActionIds ~= nil) and not observer then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("observer not found")
		end

		return false
	end

	local abilityObject

	if targetEntity.delTrigger then
		abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

		if not abilityObject then
			return false
		end
	end

	local triggerComp

	if targetEntity.addTrigger ~= nil then
		triggerComp = targetEntity:addTrigger(triggerId, shapeKind, actionData.offsetXYZ, shapeArgs, isPortal, actionData.isCreationStandAlone, true)
	end

	if actionData.enterTrapActionIds ~= nil then
		local copyCombatContext = combatContext:clone()

		local function enterTrapFun(id, actorId)
			if id ~= triggerId then
				return
			end

			local enterEntity = pg.getEntityByActorId(actorId)

			if enterEntity == nil or enterEntity == targetEntity then
				return false
			end

			if enterEntity.isRobSpaceEgg and enterEntity.getControlledPlayer then
				local controlledPlayer = enterEntity:getControlledPlayer()

				if controlledPlayer then
					enterEntity = controlledPlayer
					actorId = controlledPlayer.actorId
				end
			end

			if not Utils.checkRelation(targetEntity, enterEntity, relation) then
				return false
			end

			copyCombatContext.trapTargetActorId = actorId

			copyCombatContext:setEventData(AbilityConst.COMBAT_EVENT_ON_ENTER_TRAP, {
				actorId = actorId
			})

			if actionData.prefFilterActionIds then
				for _, actionId in ipairs(actionData.prefFilterActionIds) do
					if not ToBool(self:doActionById(actionId, copyCombatContext)) then
						copyCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_ON_ENTER_TRAP)

						return false
					end
				end
			end

			if pg.component == "client" then
				targetEntity:serverMsgNoGC("RPC_CS_EnterTrigger", id, actorId)
			end

			for _, enterTrapActionId in ipairs(actionData.enterTrapActionIds) do
				self:doActionById(enterTrapActionId, copyCombatContext)
			end

			copyCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_ON_ENTER_TRAP)

			return true
		end

		if observer then
			observer:listen(targetEntity.subject, AbilityConst.COMBAT_EVENT_ON_ENTER_TRAP, enterTrapFun)
		end
	end

	if actionData.leaveTrapActionIds ~= nil then
		local copyCombatContext = combatContext:clone()

		local function leaveTrapFun(id, actorId)
			if id ~= triggerId then
				return
			end

			local leaveEntity = pg.getEntityByActorId(actorId)

			if leaveEntity == nil or leaveEntity == targetEntity then
				return false
			end

			if leaveEntity.isRobSpaceEgg and leaveEntity.getControlledPlayer then
				local controlledPlayer = leaveEntity:getControlledPlayer()

				if controlledPlayer then
					leaveEntity = controlledPlayer
					actorId = controlledPlayer.actorId
				end
			end

			if not Utils.checkRelation(targetEntity, leaveEntity, relation) then
				return false
			end

			copyCombatContext.trapTargetActorId = actorId

			copyCombatContext:setEventData(AbilityConst.COMBAT_EVENT_ON_LEAVE_TRAP, {
				actorId = actorId
			})

			if actionData.prefFilterActionIds then
				for _, actionId in ipairs(actionData.prefFilterActionIds) do
					if not ToBool(self:doActionById(actionId, copyCombatContext)) then
						copyCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_ON_LEAVE_TRAP)

						return false
					end
				end
			end

			if pg.component == "client" then
				targetEntity:serverMsgNoGC("RPC_CS_LeaveTrigger", id, actorId)
			end

			for _, leaveTrapActionId in ipairs(actionData.leaveTrapActionIds) do
				self:doActionById(leaveTrapActionId, copyCombatContext)
			end

			copyCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_ON_LEAVE_TRAP)

			return true
		end

		if observer then
			observer:listen(targetEntity.subject, AbilityConst.COMBAT_EVENT_ON_LEAVE_TRAP, leaveTrapFun)
		end
	end

	if targetEntity.delTrigger then
		abilityObject:addExitCallback(function()
			targetEntity:delTrigger(triggerId, triggerComp, actionData.isNotifyLeaveWhenExit)
		end)
	end

	return true
end

function CombatAction:removeTrapEvent(actionData, combatContext)
	local posType = actionData.center
	local targetActorId = CombatActionTool.parseActorId(combatContext, posType)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("removeTrapEvent target not found, posType", posType)
		end

		return false
	end

	local triggerId = actionData.trapKey ~= nil and actionData.trapKey ~= "" and actionData.trapKey or actionData.UID

	if targetEntity.delTrigger then
		targetEntity:delTrigger(triggerId, nil, actionData.isNotifyLeaveWhenExit)
	end

	return true
end

local function getFlashlightTriggerKey(actionData)
	return actionData.triggerKey ~= nil and actionData.triggerKey ~= "" and actionData.triggerKey or actionData.UID
end

local function toVectorTable(value, defaultValue)
	if value == nil then
		return defaultValue
	end

	if type(value) ~= "table" then
		return value
	end

	if value.class == "Vector3" or value.x ~= nil and value.y ~= nil and value.z ~= nil then
		return {
			value.x,
			value.y,
			value.z
		}
	end

	return value
end

local function resolveFlashlightValue(self, value, combatContext, defaultValue)
	return toVectorTable(self:getVal(value, combatContext), defaultValue)
end

function CombatAction:closeFlashlightTrigger(actionData, combatContext)
	local ownerActorId = CombatActionTool.parseActorId(combatContext, actionData.pos or AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local ownerEntity = pg.getEntityByActorId(ownerActorId)

	if ownerEntity == nil then
		return false
	end

	local triggerKey = actionData.triggerKey ~= nil and actionData.triggerKey ~= "" and actionData.triggerKey or nil
	local candidates = {
		ownerEntity
	}

	if ownerEntity.getCurPetEntity then
		candidates[#candidates + 1] = ownerEntity:getCurPetEntity()
	end

	if ownerEntity.getMasterEntity then
		candidates[#candidates + 1] = ownerEntity:getMasterEntity()
	end

	local closed = false
	local seen = {}

	for _, ent in ipairs(candidates) do
		if ent and not seen[ent] and ent.removeFlashlightTrigger then
			seen[ent] = true
			closed = ent:removeFlashlightTrigger(triggerKey) or closed
		end
	end

	return closed
end

function CombatAction:createFlashlightTrigger(actionData, combatContext)
	local runtimeActionData = Utils.deepCopyTable(actionData)

	runtimeActionData.pos = actionData.pos or AbilityConst.COMBAT_TARGET_TYPE_OWNER
	runtimeActionData.offsetXYZ = resolveFlashlightValue(self, actionData.offsetXYZ, combatContext, {
		0,
		0,
		0
	})
	runtimeActionData.visualScale = resolveFlashlightValue(self, actionData.visualScale, combatContext, {
		1,
		1,
		1
	})
	runtimeActionData.triggerOffsetXYZ = resolveFlashlightValue(self, actionData.triggerOffsetXYZ, combatContext, {
		0,
		0,
		0
	})
	runtimeActionData.shapeArgs = resolveFlashlightValue(self, actionData.shapeArgs, combatContext, actionData.shapeArgs)

	if type(runtimeActionData.shapeArgs) == "number" then
		runtimeActionData.shapeArgs = {
			runtimeActionData.shapeArgs
		}
	end

	local ownerActorId = CombatActionTool.parseActorId(combatContext, runtimeActionData.pos or AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local ownerEntity = pg.getEntityByActorId(ownerActorId)

	if ownerEntity == nil or ownerEntity.addFlashlightTrigger == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("createFlashlightTrigger: owner not found or missing addFlashlightTrigger", ownerActorId)
		end

		return false
	end

	local relation = runtimeActionData.relation and runtimeActionData.relation ~= 0 and runtimeActionData.relation or Const.WORLD_PAIRS_CAMP_ENEMY
	local triggerKey = getFlashlightTriggerKey(runtimeActionData)
	local state = {
		insideSet = {},
		relation = relation,
		triggerKey = triggerKey
	}
	local observer = CombatActionTool.getContextObserver(combatContext)
	local copyCombatContext = combatContext:clone()

	if runtimeActionData.enterActionIds ~= nil then
		local function enterFun(id, actorId)
			if state.closed then
				return false
			end

			if id ~= triggerKey then
				return
			end

			local enterEntity = pg.getEntityByActorId(actorId)

			if enterEntity == nil or enterEntity == ownerEntity then
				return false
			end

			if not Utils.checkRelation(ownerEntity, enterEntity, relation) then
				return false
			end

			copyCombatContext.trapTargetActorId = actorId

			copyCombatContext:setEventData(AbilityConst.COMBAT_EVENT_ON_ENTER_TRAP, {
				actorId = actorId
			})

			for idx = #runtimeActionData.enterActionIds, 1, -1 do
				self:doActionById(runtimeActionData.enterActionIds[idx], copyCombatContext)
			end

			copyCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_ON_ENTER_TRAP)

			return true
		end

		if observer then
			observer:listen(ownerEntity.subject, AbilityConst.COMBAT_EVENT_ON_ENTER_TRAP, enterFun)
		end
	end

	if runtimeActionData.leaveActionIds ~= nil then
		local function leaveFun(id, actorId)
			if id ~= triggerKey then
				return
			end

			local leaveEntity = pg.getEntityByActorId(actorId)

			if leaveEntity == nil or leaveEntity == ownerEntity then
				return false
			end

			if not Utils.checkRelation(ownerEntity, leaveEntity, relation) then
				return false
			end

			copyCombatContext.trapTargetActorId = actorId

			copyCombatContext:setEventData(AbilityConst.COMBAT_EVENT_ON_LEAVE_TRAP, {
				actorId = actorId
			})

			for idx = #runtimeActionData.leaveActionIds, 1, -1 do
				self:doActionById(runtimeActionData.leaveActionIds[idx], copyCombatContext)
			end

			copyCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_ON_LEAVE_TRAP)

			return true
		end

		if observer then
			observer:listen(ownerEntity.subject, AbilityConst.COMBAT_EVENT_ON_LEAVE_TRAP, leaveFun)
		end
	end

	if not ownerEntity:addFlashlightTrigger(triggerKey, state, runtimeActionData) then
		return false
	end

	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if abilityObject then
		abilityObject:addExitCallback(function()
			if ownerEntity and ownerEntity.removeFlashlightTrigger then
				ownerEntity:removeFlashlightTrigger(triggerKey)
			end
		end)
	end

	return true
end

function CombatAction:checkElementType(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if targetEntity and targetEntity.elementTypes then
		return targetEntity.elementTypes[actionData.elementType] ~= nil
	end

	return false
end

function CombatAction:getEventData(actionData, combatContext)
	local key = actionData.eventName
	local data = combatContext.eventData and combatContext.eventData[key] or nil

	if data == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("event data not found", key)
		end

		return nil
	end

	return data
end

function CombatAction:getProperty(actionData, combatContext)
	local data = self:doAction(actionData.data, combatContext)

	return data and data[actionData.propertyName] or nil
end

function CombatAction:getTableItem(actionData, combatContext)
	local data = self:doAction(actionData.table, combatContext)

	if data and Utils.isTable(data) then
		local index = self:getVal(actionData.index, combatContext)

		if index ~= nil then
			local indexType = type(index)

			if indexType == "number" or indexType == "string" then
				return data[index]
			end
		end
	end

	return nil
end

function CombatAction:registerCustomEvent(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return false
	end

	local eventName = self:getVal(actionData.eventName, combatContext)

	if string.isNilOrEmpty(eventName) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jq registerCommonEvent eventName is null")
		end

		return false
	end

	local observer = CombatActionTool.getContextObserver(combatContext)

	if observer == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jq observer not found")
		end

		return false
	end

	local copyCombatContext = combatContext:clone()

	observer:listen(targetEntity.subject, eventName, function(eventCombatContext)
		copyCombatContext:setEventData(eventName, eventCombatContext)
		self:doActions(actionData, copyCombatContext)
		copyCombatContext:clearEventData(eventName)
	end)
end

function CombatAction:notifyCustomEvent(actionData, combatContext)
	local eventName = self:getVal(actionData.eventName, combatContext)

	if string.isNilOrEmpty(eventName) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jq notifyCustomEvent eventName is null")
		end

		return false
	end

	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if targetEntity and targetEntity.subject then
		targetEntity.subject:notify(eventName, combatContext)
	end
end

function CombatAction:registerAttributeChange(actionData, combatContext)
	local targetEntity = CombatActionTool.getRegisterEventSubjectEntity(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local targetType = actionData.targetType or AbilityConst.ATTR_CHANGE_TARGET.SELF
	local attributeId = AttributeConst[actionData.attributeName]

	if attributeId == nil then
		CombatActionTool.logError(combatContext, actionData, "@jq attributeId not found", actionData.attributeName)

		return false
	end

	local observer = CombatActionTool.getContextObserver(combatContext)

	if observer == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jq observer not found")
		end

		return false
	end

	local eventName = AbilityConst.COMBAT_EVENT_ATTRIBUTE_CHANGE

	if targetType == AbilityConst.ATTR_CHANGE_TARGET.CURPET then
		eventName = AbilityConst.COMBAT_EVENT_PET_ATTRIBUTE_CHANGE
	end

	if Utils.isPet(targetEntity) and AbilityUtils.isGroupAttribute(attributeId) then
		targetEntity = targetEntity:getMasterEntity()

		if targetEntity == nil then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				CombatLogger.error("CombatAction[registerAttributeChange] error: masterEntity not found")
			end

			return false
		end

		eventName = AbilityConst.COMBAT_EVENT_ATTRIBUTE_CHANGE
	end

	local attributeChangeType = actionData.changeType or AbilityConst.ATTR_CHANGE_TYPE.ANY
	local copyCombatContext = combatContext:clone()

	observer:listen(targetEntity.subject, eventName, function(attributeContext)
		if attributeContext.attributeId == attributeId then
			local oldValue = attributeContext.oldValue
			local value = attributeContext.value

			if attributeChangeType == AbilityConst.ATTR_CHANGE_TYPE.ADD then
				if not oldValue or not value then
					return
				end

				if value <= oldValue then
					return
				end
			elseif attributeChangeType == AbilityConst.ATTR_CHANGE_TYPE.MINUS then
				if not oldValue or not value then
					return
				end

				if oldValue <= value then
					return
				end
			end

			copyCombatContext:setEventData(eventName, attributeContext)
			self:doActions(actionData, copyCombatContext)
			copyCombatContext:clearEventData(eventName)
		end
	end)
end

function CombatAction:registerCastAbilityEvent(actionData, combatContext)
	local targetEntity = CombatActionTool.getRegisterEventSubjectEntity(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER)

	if not targetEntity then
		return
	end

	local observer = CombatActionTool.getContextObserver(combatContext)

	if observer == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj observer not found")
		end

		return false
	end

	local copyCombatContext = combatContext:clone()

	observer:listen(targetEntity.subject, AbilityConst.COMBAT_EVENT_CAST_ABILITY, function(castCombatContext)
		if CombatActionTool.isBlockTriggerAbilityEvent(castCombatContext.abilityId, castCombatContext.actorId, actionData) then
			return
		end

		copyCombatContext:setEventData(AbilityConst.COMBAT_EVENT_CAST_ABILITY, castCombatContext)
		self:doActions(actionData, copyCombatContext)
		copyCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_CAST_ABILITY)
	end)
end

function CombatAction:registerCastFatherAbilityChange(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not owner then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@registerCastFatherAbilityChange owner not found")
		end

		return false
	end

	local playerEnt = Utils.convertPlayerEntity(owner)

	if not playerEnt then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@registerCastFatherAbilityChange playerEnt not found")
		end

		return false
	end

	local observer = CombatActionTool.getContextObserver(combatContext)

	if observer == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@registerCastFatherAbilityChange observer not found")
		end

		return false
	end

	local copyCombatContext = combatContext:clone()
	local lastFatherAbilityId

	local function onCast(castCombatContext)
		local abilityId = castCombatContext.abilityId

		if not ToBool(abilityId) then
			return
		end

		local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(abilityId)

		if not abilityTemplate then
			return
		end

		if abilityTemplate.abilityType ~= AbilityConst.EnumAbilityType.Skill then
			return
		end

		local castEntity = pg.getEntityByActorId(castCombatContext.actorId) or playerEnt
		local fatherAbilityId = CombatActionTool.findFatherAbilityId(castEntity, abilityId) or abilityId
		local isSame = lastFatherAbilityId ~= nil and lastFatherAbilityId == fatherAbilityId

		lastFatherAbilityId = fatherAbilityId

		copyCombatContext:setEventData(AbilityConst.COMBAT_EVENT_ON_ABILITY_DISABLE_RETURN, castCombatContext)

		if isSame then
			self:doActionIds(actionData.sameActionIds, copyCombatContext)
		else
			self:doActionIds(actionData.diffActionIds, copyCombatContext)
		end

		copyCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_ON_ABILITY_DISABLE_RETURN)
	end

	EventBus.isReceiveAdditionalEvent = true

	observer:listen(playerEnt.subject, AbilityConst.COMBAT_EVENT_ON_ABILITY_DISABLE_RETURN, onCast)

	EventBus.isReceiveAdditionalEvent = false
end

function CombatAction:getEventAttackTarget(actionData, combatContext)
	local attackCombatContext = combatContext.eventData and combatContext.eventData[AbilityConst.COMBAT_EVENT_ATTACK] or nil

	if not attackCombatContext then
		return 0
	end

	return attackCombatContext.beAttackActorId or 0
end

function CombatAction:setNextComboTimelineId(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if owner and owner.setNextComboTimeline then
		owner:setNextComboTimeline(combatContext:timeline(), actionData.timelineId, combatContext)
	end
end

function CombatAction:multiply(actionData, combatContext)
	local lValue = self:getVal(actionData.lValue, combatContext)
	local rValue = self:getVal(actionData.rValue, combatContext)

	if lValue ~= nil and rValue ~= nil then
		return lValue * rValue
	end

	return 0
end

function CombatAction:buffDestroyReason(actionData, combatContext)
	local reason = AbilityConst.BUFF_DESTROY_REASON_PARSER[actionData.destroyReason]

	reason = reason or AbilityConst.BUFF_DESTROY_REASON_NONE

	if combatContext and combatContext:buff() then
		return combatContext:buff().buffData.destroyReason == reason
	end

	return false
end

function CombatAction:getAttribute(actionData, combatContext)
	local targetType = actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER
	local targetEnt = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, targetType))

	if targetEnt then
		local attributeId = AttributeConst[actionData.attributeName]

		return targetEnt.actorCombatAttribute:getAttribValue(attributeId)
	end
end

function CombatAction:getConstVal(actionData, combatContext)
	return actionData.val
end

function CombatAction:clamp(actionData, combatContext)
	local val = self:getVal(actionData.val, combatContext) or 0
	local min = self:getVal(actionData.min, combatContext) or 0
	local max = self:getVal(actionData.max, combatContext) or 0

	return math.clamp(val, min, max)
end

function CombatAction:add(actionData, combatContext)
	local lVal = self:getVal(actionData.lValue, combatContext) or 0
	local rVal = self:getVal(actionData.rValue, combatContext) or 0

	if type(lVal) ~= type(rVal) then
		return nil
	end

	return lVal + rVal
end

function CombatAction:getServerCacheVal(actionData, combatContext)
	local target = actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, target))

	if not ownerEntity then
		return 0
	end

	local key = self:getVal(actionData.key, combatContext)
	local val = EntityCacheValueUtils.getCacheValue(ownerEntity, key)

	if val == nil then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("getServerCacheVal, value not found, key = ", key)
		end

		return 0
	end

	return val
end

function CombatAction:getEventCastAbilityTarget(actionData, combatContext)
	local castAbilityCombatContext = combatContext.eventData and combatContext.eventData[AbilityConst.COMBAT_EVENT_CAST_ABILITY] or nil

	if not castAbilityCombatContext then
		return 0
	end

	return castAbilityCombatContext.runtimeTargetInfo and castAbilityCombatContext.runtimeTargetInfo.actorId or 0
end

function CombatAction:isAbilityType(actionData, combatContext)
	if ToBool(combatContext.eventData) then
		for _, eventCombatContext in pairs(combatContext.eventData) do
			if type(eventCombatContext) == "table" and eventCombatContext.className == "CombatContext" then
				combatContext = eventCombatContext

				break
			end
		end
	end

	local ability = CombatActionTool.getCasterAbility(combatContext)

	return ability and ability:getAbilityTemplate().abilityType == actionData.abilityType
end

function CombatAction:isAbilityEffectTag(actionData, combatContext)
	if ToBool(combatContext.eventData) then
		for _, eventCombatContext in pairs(combatContext.eventData) do
			if type(eventCombatContext) == "table" and eventCombatContext.className == "CombatContext" then
				combatContext = eventCombatContext

				break
			end
		end
	end

	local ability = CombatActionTool.getCasterAbility(combatContext)

	if ability then
		local paramData = pg.global.abilityMgr:getAbilityParamData(ability.abilityId)

		if paramData.abilityEffectTags and paramData.abilityEffectTags[actionData.tag] then
			return true
		end
	end

	return false
end

function CombatAction:doBlockEventActions(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return false
	end

	targetEntity.subject.blockEventName = actionData.blockEvent

	self:doActions(actionData, combatContext)

	targetEntity.subject.blockEventName = nil
end

function CombatAction:registerStunCollision(actionData, combatContext)
	local targetEntity = CombatActionTool.getRegisterEventSubjectEntity(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local observer = CombatActionTool.getContextObserver(combatContext)

	if not observer then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("observer not found")
		end

		return false
	end

	if targetEntity.startListenStunOnCollision then
		targetEntity:startListenStunOnCollision(observer, function(tag)
			combatContext:setEventData(AbilityConst.COMBAT_EVENT_STUN_ON_COLLISION, tag)
			self:doActions(actionData, combatContext)
			combatContext:clearEventData(AbilityConst.COMBAT_EVENT_STUN_ON_COLLISION)
			observer:unlisten(targetEntity.subject, AbilityConst.COMBAT_EVENT_STUN_ON_COLLISION)
		end)
	end

	return true
end

function CombatAction:setTimeScale(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	if ownerEntity.setTimeScale then
		ownerEntity:setTimeScale(actionData.timeScale, AbilityConst.TIME_SCALE_KEY_ABILITY)

		return true
	end

	return false
end

function CombatAction:equal(actionData, combatContext)
	local lValue = self:getVal(actionData.lValue, combatContext)
	local rValue = self:getVal(actionData.rValue, combatContext)

	return lValue == rValue
end

function CombatAction:doSplitRangeActions(actionData, combatContext)
	local value = self:getVal(actionData.value, combatContext)

	if type(value) ~= "number" then
		CombatActionTool.logError(combatContext, actionData, "doSplitRangeActions getVal type error", type(value))

		return false
	end

	local levelCacheKey = actionData.levelCacheKey
	local cacheLevel = CombatActionTool.getCombatContextCacheVal(combatContext, levelCacheKey)

	for index, info in ipairs(actionData.rangeActions) do
		if value <= info.value then
			if cacheLevel ~= index then
				cacheLevel = index

				if levelCacheKey ~= nil then
					CombatActionTool.setCombatContextCacheVal(combatContext, levelCacheKey, cacheLevel)
				end

				self:doActions(info, combatContext)
			end

			break
		end
	end

	return true
end

function CombatAction:registerReceiveBeAttackedEvent(actionData, combatContext)
	local owner = CombatActionTool.getRegisterEventSubjectEntity(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local observer = CombatActionTool.getContextObserver(combatContext)
	local interval = actionData.interval or 0
	local lastTriggerTime = -1

	if observer then
		local copyCombatContext = combatContext:clone()

		observer:listen(owner.subject, AbilityConst.COMBAT_EVENT_RECEIVE_BE_ATTACKED, function(eventCombatContext)
			if actionData.includeAbilities and not actionData.includeAbilities[eventCombatContext.abilityId] then
				return
			end

			local now = owner:getGameTime()

			if lastTriggerTime ~= -1 and now - lastTriggerTime < interval then
				return
			end

			lastTriggerTime = now

			copyCombatContext:setEventData(AbilityConst.COMBAT_EVENT_RECEIVE_BE_ATTACKED, eventCombatContext)
			self:doActions(actionData, copyCombatContext)
			copyCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_RECEIVE_BE_ATTACKED)
		end)
	end
end

function CombatAction:immuneDamage(actionData, combatContext)
	local eventCombatContext = combatContext.eventData[AbilityConst.COMBAT_EVENT_RECEIVE_DAMAGE]

	if eventCombatContext then
		eventCombatContext.damageData.attackResult = AbilityConst.ATTACK_RESULT_IMMUNE
		eventCombatContext.damageData.finalDamage = 0

		return true
	else
		eventCombatContext = combatContext.eventData[AbilityConst.COMBAT_EVENT_RECEIVE_BE_ATTACKED]

		if eventCombatContext then
			eventCombatContext.isImmuteDamage = true
		end
	end

	return false
end

function CombatAction:registerAttackHpZero(actionData, combatContext)
	local ownerEntity = CombatActionTool.getRegisterEventSubjectEntity(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local observer = CombatActionTool.getContextObserver(combatContext)

	if observer then
		local copyCombatContext = combatContext:clone()

		observer:listen(ownerEntity.subject, AbilityConst.COMBAT_EVENT_ON_ATTACK_HP_ZERO, function(killActorId)
			copyCombatContext:setEventData(AbilityConst.COMBAT_EVENT_ON_ATTACK_HP_ZERO, killActorId)
			self:doActions(actionData, copyCombatContext)
			copyCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_ON_ATTACK_HP_ZERO)
		end)
	end
end

function CombatAction:followTarget(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	if not Utils.checkIsAuthorityMaster(ownerEntity) then
		return false
	end

	if targetEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("target not found", actionData.target)
		end

		return false
	end

	local followSpeed = actionData.followSpeed
	local stopDistance = actionData.stopDistance or 0.1

	if ownerEntity.startFollowTarget then
		ownerEntity:startFollowTarget(targetEntity.actorId, followSpeed, stopDistance)
	end

	return true
end

function CombatAction:stopFollowTarget(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	if not Utils.checkIsAuthorityMaster(ownerEntity) then
		return false
	end

	if ownerEntity.stopFollowTarget then
		ownerEntity:stopFollowTarget()
	end

	return true
end

function CombatAction:getProjectilePos(actionData, combatContext)
	if combatContext:projectile() then
		return combatContext:projectile().pos:Clone()
	end

	return nil
end

function CombatAction:getProjectileRotation(actionData, combatContext)
	if combatContext:projectile() then
		return combatContext:projectile().rot:Clone()
	end

	return nil
end

function CombatAction:getProjectileCacheVal(actionData, combatContext)
	if combatContext:projectile() then
		return combatContext:projectile().cacheValMap[actionData.key]
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		CombatLogger.error("getProjectileCacheVal projectile not found", actionData.key)
	end
end

function CombatAction:setProjectileCacheVal(actionData, combatContext)
	local projectile

	if actionData.projectileId then
		local projectileId = self:doActionById(actionData.projectileId, combatContext)
		local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)
		local projectileMgr = ownerEntity and ownerEntity.space and ownerEntity.space.projectileMgr

		if not projectileMgr then
			return false
		end

		projectile = projectileMgr:getProjectile(projectileId)
	else
		projectile = combatContext:projectile()
	end

	if projectile then
		local val = self:getVal(actionData.val, combatContext)

		projectile.cacheValMap[actionData.key] = val

		return true
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		CombatLogger.error("getProjectileCacheVal projectile not found", actionData.key)
	end

	return false
end

function CombatAction:hasBuffTag(actionData, combatContext)
	local target = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if target == nil or target.actorBuff == nil then
		return false
	end

	return target.actorBuff:hasTag(actionData.buffTag)
end

function CombatAction:setProjectileSleep(actionData, combatContext)
	local projectile = combatContext:projectile()

	if projectile then
		projectile.isSleeping = true
		projectile.sleepTime = 0
		projectile.needSleepTime = actionData.time
	end
end

function CombatAction:addTimer(actionData, combatContext)
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)
	local duration = self:getVal(actionData.duration, combatContext)
	local key = self:getVal(actionData.key, combatContext)
	local copyCombatContext = combatContext:clone()

	if abilityObject then
		abilityObject:addTimer(key or copyCombatContext.BPName, duration, function()
			pg.global.abilityMgr.combatAction:doActions(actionData, copyCombatContext)
		end)

		local casterEntity = CombatActionTool.getCasterEnt(combatContext)

		if casterEntity and casterEntity.disableReturnAbilityConsumes then
			casterEntity:disableReturnAbilityConsumes(combatContext.id)

			if casterEntity.addCastAbilitySp then
				casterEntity:addCastAbilitySp(combatContext.id)
			end
		end

		return true
	end

	return false
end

function CombatAction:removeTimer(actionData, combatContext)
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if abilityObject then
		abilityObject:removeTimer(actionData.key)

		return true
	end

	return false
end

function CombatAction:getTargetId(actionData, combatContext)
	return CombatActionTool.parseActorId(combatContext, actionData.target)
end

function CombatAction:getAbilityCacheVal(actionData, combatContext)
	local ability = combatContext:ability()

	if not ability then
		CombatActionTool.logError(combatContext, actionData, "getAbilityCacheVal ability nof found")

		return 0
	end

	local abilityObject = ability:getAbilityObject()
	local key2 = tostring(self:getVal(actionData.key2, combatContext))

	if abilityObject.cacheValMap[actionData.key] ~= nil then
		if key2 and type(abilityObject.cacheValMap[actionData.key]) == "table" then
			return abilityObject.cacheValMap[actionData.key][key2] or 0
		else
			return abilityObject.cacheValMap[actionData.key] or 0
		end
	end

	return 0
end

function CombatAction:projectileRotateAround(actionData, combatContext)
	local projectile = combatContext:projectile()

	if projectile and ToBool(projectile.circleData) then
		projectile.rotateYaw = actionData.rotateYaw
		projectile.rotateRoll = actionData.rotateRoll
		projectile.rotatePitch = actionData.rotatePitch
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		CombatLogger.error("no circleProjectile found")
	end
end

function CombatAction:getBuffLayer(actionData, combatContext)
	if actionData.templateId and actionData.templateId > 0 then
		local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

		if not targetEntity or not targetEntity.actorBuff then
			return 0
		end

		local buff = targetEntity.actorBuff:findOneBuffByTemplateId(actionData.templateId)

		if not buff then
			return 0
		end

		return buff.buffData.layer
	end

	if combatContext:buff() then
		return combatContext:buff().buffData.layer
	end

	CombatActionTool.logError(combatContext, actionData, "buff not found, return layer 0")

	return 0
end

function CombatAction:getBuffLevel(actionData, combatContext)
	if actionData.templateId and actionData.templateId > 0 then
		local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

		if not targetEntity or not targetEntity.actorBuff then
			return 0
		end

		local buff = targetEntity.actorBuff:findOneBuffByTemplateId(actionData.templateId)

		if not buff then
			return 0
		end

		return buff.buffData.level
	end

	if combatContext:buff() then
		return combatContext:buff().buffData.level
	end

	CombatActionTool.logDebug(combatContext, actionData, "buff not found, return level 0")

	return 0
end

function CombatAction:isReceiveBeAttackedEventElementType(actionData, combatContext)
	local elementType = actionData.elementType
	local eventCombatContext = combatContext.eventData[AbilityConst.COMBAT_EVENT_RECEIVE_BE_ATTACKED]

	return eventCombatContext and eventCombatContext.damageData and eventCombatContext.damageData.elementType == elementType
end

function CombatAction:randomPoint(actionData, combatContext)
	local targetPosType = actionData.targetPos
	local radius = actionData.radius

	if not combatContext.constCasterInfo then
		return false
	end

	local casterActorId = combatContext.constCasterInfo.actorId
	local casterEntity = pg.getEntityByActorId(casterActorId)

	if not casterEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj casterEntity not found", casterActorId)
		end

		return false
	end

	local center = casterEntity:getPosition():Clone()

	CombatActionTool.parsePosition(combatContext, targetPosType, center)

	local radian = math.random() * 2 * math.pi
	local distanceSqrt

	if actionData.innerRadius then
		distanceSqrt = math.sqrt(math.random() * (radius * radius - actionData.innerRadius * actionData.innerRadius) + actionData.innerRadius * actionData.innerRadius)
	else
		distanceSqrt = math.sqrt(math.random() * radius * radius)
	end

	local xDelta = math.cos(radian) * distanceSqrt
	local zDelta = math.sin(radian) * distanceSqrt

	combatContext.randomPointPos = Vector3(center.x + xDelta, center.y, center.z + zDelta)

	if actionData.randomHeight then
		combatContext.randomPointPos.y = combatContext.randomPointPos.y + Lume.random(0, actionData.randomHeight)
	end

	return combatContext.randomPointPos
end

function CombatAction:isPuppetLabel(actionData, combatContext)
	local target = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if not target then
		return false
	end

	local label = target.label and target.label or Const.PET_LABEL_MASK.NORMAL

	return label == Const.PET_LABEL_MASK.NORMAL and actionData.label == Const.PET_LABEL_MASK.NORMAL or ToBool(bit.band(label, actionData.label))
end

function CombatAction:addEntityTimer(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not owner then
		return
	end

	if owner.abilityTimerMap[actionData.key] ~= nil then
		CombatActionTool.logError(combatContext, actionData, "addEntityTimer key repeat", actionData.key)
	end

	local key = self:getVal(actionData.key, combatContext) or combatContext.BPName
	local duration = self:getVal(actionData.duration, combatContext)
	local copyCombatContext = CombatContext.clone(combatContext)

	if owner.addCombatContextRefCnt then
		owner:addCombatContextRefCnt(combatContext)
	end

	local timerId = owner.addEntityTimer and owner:addEntityTimer(duration, function()
		owner.abilityTimerMap[key] = nil

		self:doActions(actionData, copyCombatContext)

		if owner.returnCombatContext then
			owner:returnCombatContext(combatContext)
		end
	end)

	if owner.disableReturnAbilityConsumes then
		owner:disableReturnAbilityConsumes(combatContext.id)
	end

	if owner.addCastAbilitySp then
		owner:addCastAbilitySp(combatContext.id)
	end

	owner.abilityTimerMap[key] = timerId
end

function CombatAction:removeEntityTimer(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not owner then
		return
	end

	if owner.abilityTimerMap[actionData.key] ~= nil then
		if owner.removeEntityTimer then
			owner:removeEntityTimer(owner.abilityTimerMap[actionData.key])
		end

		if owner.returnCombatContext then
			owner:returnCombatContext(combatContext)
		end
	end
end

function CombatAction:getBornPos(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not owner then
		return CombatActionTool.INVALID_POS
	end

	if Utils.isPuppet(owner) then
		return Vector3(owner.bornPosition_x, owner.bornPosition_y, owner.bornPosition_z)
	end

	return owner:getPosition()
end

function CombatAction:getInvDirOffsetPos(actionData, combatContext)
	local center = self:getVal(actionData.center, combatContext)
	local point = self:getVal(actionData.point, combatContext)

	if not center or not point then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@hyj getInvDirOffsetPos failed, check center and point", inspect(center), inspect(point))
		end

		return CombatActionTool.INVALID_POS
	end

	local dis = center - point

	if actionData.ignoreYAxis then
		dis.y = 0
	end

	return center + dis:Normalize() * actionData.offset
end

function CombatAction:getNormalizedVector3(actionData, combatContext)
	local val = self:getVal(actionData.val, combatContext)

	return Vector3.Normalize(val)
end

function CombatAction:sub(actionData, combatContext)
	local lValue = self:getVal(actionData.lValue, combatContext) or 0
	local rValue = self:getVal(actionData.rValue, combatContext) or 0

	return lValue - rValue
end

function CombatAction:getTargetOffsetPos(actionData, combatContext)
	Vector3.enableCreateFromCache()

	local refPos = Vector3(0, 0, 0)
	local offset = actionData.offset.name == nil and Vector3(unpack(actionData.offset)) or self:doAction(actionData.offset, combatContext)
	local ret = CombatActionTool.parsePosition(combatContext, actionData.target, refPos)

	if ret then
		local rot = Quaternion(0, 0, 0, 1)

		CombatActionTool.parseRotation(combatContext, actionData.rotType or actionData.target, rot)

		local result = refPos + rot:MulVec3(offset)

		Vector3.disableCreateFromCache(result)

		return result
	end

	Vector3.disableCreateFromCache()

	return CombatActionTool.INVALID_POS
end

function CombatAction:setCombatTargetId(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local casterEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_CASTER))

	if not casterEntity then
		return false
	end

	if casterEntity.setEntityCacheVal then
		casterEntity:setEntityCacheVal("lockedTarget", targetActorId)
	end

	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity and Utils.isPet(targetEntity) then
		local playerEntity = targetEntity:getMasterEntity()

		if playerEntity and casterEntity.setEntityCacheVal then
			casterEntity:setEntityCacheVal("lockedTargetMaster", playerEntity.actorId)
		end
	end

	return true
end

function CombatAction:getCombatTargetId(actionData, combatContext)
	local casterEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_CASTER))

	if not casterEntity then
		return nil
	end

	local targetEntityId
	local lockedTargetMaster = casterEntity.getEntityCacheVal and casterEntity:getEntityCacheVal("lockedTargetMaster")
	local lockedTarget = casterEntity.getEntityCacheVal and casterEntity:getEntityCacheVal("lockedTarget")

	if pg.getEntityByActorId(lockedTarget) ~= nil then
		targetEntityId = lockedTarget
	elseif lockedTargetMaster ~= nil and pg.getEntityByActorId(lockedTargetMaster) ~= nil then
		targetEntityId = lockedTargetMaster
	end

	return targetEntityId
end

function CombatAction:getCombatTarget(actionData, combatContext)
	local casterEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_CASTER))

	if not casterEntity then
		return nil
	end

	local targetEntity
	local lockedTarget = casterEntity.getEntityCacheVal and casterEntity:getEntityCacheVal("lockedTarget")
	local lockedTargetMaster = casterEntity.getEntityCacheVal and casterEntity:getEntityCacheVal("lockedTargetMaster")

	if lockedTarget ~= nil then
		targetEntity = pg.getEntityByActorId(lockedTarget)
	end

	if Utils.isPlayer(casterEntity) or Utils.isPet(casterEntity) then
		if targetEntity == nil then
			targetEntity = pg.getEntityByActorId(Utils.getEntityLockedActorId(casterEntity))
		end
	elseif Utils.isPlayer(targetEntity) then
		if targetEntity:isControllingPet() then
			local curPetEntity = targetEntity:getCurPetEntity()

			targetEntity = curPetEntity
		end
	elseif lockedTargetMaster ~= nil then
		local playerEntity = pg.getEntityByActorId(lockedTargetMaster)

		if playerEntity then
			local curPetEntity = playerEntity:getCurPetEntity()

			if curPetEntity ~= nil then
				targetEntity = curPetEntity
			else
				targetEntity = playerEntity
			end
		end
	end

	if targetEntity ~= nil then
		return targetEntity:getPosition()
	end

	return nil
end

function CombatAction:getPlayerRealControlEnt(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	targetEntity = Utils.convertPlayerEntity(targetEntity)

	if not Utils.isPlayerOrBotPlayer(targetEntity) then
		return 0
	end

	if actionData.forceCurPet then
		local curPet = targetEntity:getCurPetEntity()

		return curPet and curPet.actorId or 0
	end

	if targetEntity:isControllingPet() then
		local curPet = targetEntity:getCurPetEntity()

		if curPet then
			return curPet.actorId
		end
	end

	return targetEntity.actorId
end

function CombatAction:registerCheckEnclosedRegionEvent(actionData, combatContext)
	local observer = CombatActionTool.getContextObserver(combatContext)

	if not observer then
		return false
	end

	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("targetEntity not found", actionData.target)
		end

		return false
	end

	local copyActionData = Utils.deepCopyTable(actionData)
	local timerKey = AbilityConst.COMBAT_EVENT_ON_SKILL_MOVE_PATH_ENCLOSED
	local copyCombatContext = combatContext:clone()

	observer:listen(targetEntity.subject, AbilityConst.COMBAT_EVENT_ON_SKILL_MOVE_PATH_ENCLOSED, function(combatHitResults)
		if not ToBool(combatHitResults) then
			return
		end

		self:doActionIds(copyActionData.commonTriggerActionIds, copyCombatContext)

		local rawCombatHitTargetInfo = copyCombatContext.runtimeTargetInfo and copyCombatContext.runtimeTargetInfo:clone() or nil
		local interval = actionData.interval or 0

		for idx, combatHitResult in ipairs(combatHitResults) do
			copyActionData.key = timerKey .. "_" .. tostring(idx)
			copyActionData.duration = interval * (idx - 1)

			local rawInfo = copyCombatContext.runtimeTargetInfo
			local runtimeTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:get(true)

			copyCombatContext.runtimeTargetInfo = runtimeTargetInfo

			copyCombatContext.runtimeTargetInfo:initTarget(combatHitResult.hitActorId, combatHitResult.hitPos, 1, combatHitResult.hitActorPartIdx)
			self:removeEntityTimer(copyActionData, copyCombatContext)
			self:addEntityTimer(copyActionData, copyCombatContext)
			pg.global.abilityMgr.runtimeTargetInfoPool:returnObject(runtimeTargetInfo)
		end

		copyCombatContext.runtimeTargetInfo = rawCombatHitTargetInfo
	end)

	return true
end

function CombatAction:isAbilityInCD(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return false
	end

	local abilityId = actionData.abilityId

	if not ToBool(abilityId) then
		abilityId = combatContext.abilityId
	end

	return not ToBool(targetEntity.checkAbilityCd and targetEntity:checkAbilityCd(abilityId))
end

function CombatAction:registerSkillMoveBlocked(actionData, combatContext)
	local target = actionData.target
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, target))

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@hyj CombatAction[registerSkillMoveBlocked]: targetEntity not found", target)
		end

		return
	end

	local observer = CombatActionTool.getContextObserver(combatContext)

	if observer then
		local combatContextClone = combatContext:clone()

		observer:listen(targetEntity.subject, AbilityConst.COMBAT_EVENT_ON_SKILL_MOVE_BLOCKED, function(hitPoint, hitNormal)
			combatContextClone:setEventData(AbilityConst.COMBAT_EVENT_ON_SKILL_MOVE_BLOCKED, {
				hitPoint = hitPoint,
				hitNormal = hitNormal
			})
			self:doActions(actionData, combatContextClone)
			combatContextClone:clearEventData(AbilityConst.COMBAT_EVENT_ON_SKILL_MOVE_BLOCKED)
		end)
	end
end

function CombatAction:hookSprint(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	local hookFailTrigger = actionData.hookFailTrigger
	local hookSuccessTrigger = actionData.hookSuccessTrigger
	local hookEndTrigger = actionData.hookEndTrigger
	local hookExitTrigger = actionData.hookExitTrigger
	local observer = CombatActionTool.getContextObserver(combatContext)
	local combatContextClone = combatContext:clone()

	if ownerEntity.disableReturnAbilityConsumes then
		ownerEntity:disableReturnAbilityConsumes(combatContext.castingCombatContextId)
	end

	if observer then
		observer:listen(ownerEntity.subject, AbilityConst.COMBAT_EVENT_ON_SKILL_HOOK_FAIL, function()
			self:doActionIds(hookFailTrigger, combatContextClone)
		end)
		observer:listen(ownerEntity.subject, AbilityConst.COMBAT_EVENT_ON_SKILL_HOOK_SUCCESS, function()
			self:doActionIds(hookSuccessTrigger, combatContextClone)
		end)
		observer:listen(ownerEntity.subject, AbilityConst.COMBAT_EVENT_ON_SKILL_HOOK_END, function()
			self:doActionIds(hookEndTrigger, combatContextClone)
		end)
		observer:listen(ownerEntity.subject, AbilityConst.COMBAT_EVENT_ON_SKILL_HOOK_EXIT, function()
			self:doActionIds(hookExitTrigger, combatContextClone)
		end)
	end
end

function CombatAction:enableFreeAimMode(actionData, combatContext)
	local enable = actionData.enable
	local observer = CombatActionTool.getContextObserver(combatContext)

	if observer == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("observer not found")
		end

		return
	end

	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	if enable then
		local copyCombatContext = combatContext:clone()
		local onConfirmActionIds = actionData.onConfirmActionIds
		local onCancelActionIds = actionData.onCancelActionIds

		observer:listen(ownerEntity.subject, AbilityConst.COMBAT_EVENT_ON_FREE_AIM_CONFIRM_BTN_CLICKED, function()
			self:doActionIds(onConfirmActionIds, copyCombatContext)
		end)
		observer:listen(ownerEntity.subject, AbilityConst.COMBAT_EVENT_ON_FREE_AIM_CANCEL_BTN_CLICKED, function()
			self:doActionIds(onCancelActionIds, copyCombatContext)
		end)
	else
		observer:unlisten(ownerEntity.subject, AbilityConst.COMBAT_EVENT_ON_FREE_AIM_CONFIRM_BTN_CLICKED)
		observer:unlisten(ownerEntity.subject, AbilityConst.COMBAT_EVENT_ON_FREE_AIM_CANCEL_BTN_CLICKED)
	end
end

function CombatAction:getRandomValueForAsyncActions(actionData, combatContext)
	local randomIndex = 1
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	if abilityObject.cacheValMap[actionData.key] ~= nil then
		randomIndex = abilityObject.cacheValMap[actionData.key]
	end

	local valList = actionData.valueList

	return valList and valList[randomIndex] or randomIndex
end

function CombatAction:isInBurrow(actionData, combatContext)
	local isNot = actionData["not"]
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@hyj targetEntity not found", targetActorId)
		end

		return false
	end

	local isInBurrow = targetEntity:BURROW_ST()

	return isNot and not isInBurrow or isInBurrow
end

function CombatAction:addTimerByTargetActorId(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@hyj targetEntity not found", targetActorId)
		end

		return false
	end

	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)
	local duration = self:getVal(actionData.duration, combatContext)

	if abilityObject then
		local runtimeTargetInfo = combatContext.runtimeTargetInfo

		abilityObject:addTimer(targetActorId, duration, function()
			local guardVal = GuardValue(combatContext, "runtimeTargetInfo", runtimeTargetInfo)

			pg.global.abilityMgr.combatAction:doActions(actionData, combatContext)
			guardVal:recover()
		end)

		local casterEntity = CombatActionTool.getCasterEnt(combatContext)

		if casterEntity and casterEntity.disableReturnAbilityConsumes then
			casterEntity:disableReturnAbilityConsumes(combatContext.id)

			if casterEntity.addCastAbilitySp then
				casterEntity:addCastAbilitySp(combatContext.id)
			end
		end

		return true
	end

	return false
end

function CombatAction:checkTargetCreationTag(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@hyj targetEntity not found", targetActorId)
		end

		return false
	end

	local tag = actionData.tag

	if Utils.isCreation(targetEntity) and ToBool(targetEntity:getConfigData()[tag]) then
		return true
	end

	return false
end

function CombatAction:checkRandomIntGenned(actionData, combatContext)
	local ability = combatContext:ability()

	if not ability then
		CombatActionTool.logError(combatContext, actionData, "getAbilityCacheVal ability nof found")

		return false
	end

	local abilityObject = ability:getAbilityObject()
	local gennedKey = AbilityConst.COMBAT_EVENT_ON_ASYNC_RANDOM_INT_GENNED .. actionData.key

	if abilityObject.cacheValMap[gennedKey] ~= nil then
		return true
	end

	return false
end

function CombatAction:constVector3(actionData, combatContext)
	local x = self:getVal(actionData.x, combatContext)
	local y = self:getVal(actionData.y, combatContext)
	local z = self:getVal(actionData.z, combatContext)

	return Vector3(x, y, z)
end

function CombatAction:triggerOrRegisterAsyncEvent(actionData, combatContext)
	if string.isNilOrEmpty(actionData.eventName) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@hyj CombatAction[triggerOrRegisterAsyncEvent]: eventName is null")
		end

		return false
	end

	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@hyj CombatAction[triggerOrRegisterAsyncEvent]: ownerEntity is null")
		end

		return false
	end

	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	local gennedKey = actionData.key

	if ToBool(abilityObject.cacheValMap[gennedKey]) then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("@hyj CombatAction[triggerOrRegisterAsyncEvent]: Data alreadyPrepared ", abilityObject.cacheValMap[gennedKey])
		end

		self:doActions(actionData, combatContext)

		abilityObject.cacheValMap[gennedKey] = nil
	else
		local observer = CombatActionTool.getContextObserver(combatContext)

		if observer == nil then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				CombatLogger.error("@hyj CombatAction[triggerOrRegisterAsyncEvent]: observer not found")
			end

			return false
		end

		if targetEntity.subject then
			local copyCombatContext = combatContext:clone()

			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				CombatLogger.debug("@hyj CombatAction[triggerOrRegisterAsyncEvent]: Data notPrepared, register event ", abilityObject.cacheValMap[gennedKey])
			end

			observer:listen(targetEntity.subject, actionData.eventName, function(data)
				observer:unlisten(targetEntity.subject, actionData.eventName)
				copyCombatContext:setEventData(actionData.eventName, data)

				if LoggerManager.checkLogger(LoggerConst.DEBUG) then
					CombatLogger.debug("@hyj CombatAction[triggerOrRegisterAsyncEvent]: onCustomEvent trigger", actionData.eventName, inspect(actionData), inspect(data))
				end

				self:doActions(actionData, copyCombatContext)
				copyCombatContext:clearEventData(actionData.eventName)

				abilityObject.cacheValMap[gennedKey] = nil
			end)
		end
	end
end

function CombatAction:isInCombat(actionData, combatContext)
	local isNot = actionData["not"]
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@hyj targetEntity not found", targetActorId)
		end

		return false
	end

	local isInCombat = targetEntity:isInCombat()

	return isNot and not isInCombat or isInCombat
end

function CombatAction:checkGenderDifference(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_TARGET))

	if not targetEntity then
		return false
	end

	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	return targetEntity.gender ~= nil and ownerEntity.gender ~= nil and targetEntity.gender ~= ownerEntity.gender or false
end

function CombatAction:checkGenderDifferenceInTeam(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	if ownerEntity.gender == nil then
		return false
	end

	local masterEntity = ownerEntity.getMasterEntity and ownerEntity:getMasterEntity() or ownerEntity

	if masterEntity.pets then
		for _, petId in pairs(masterEntity.petPrepareList or EMPTY_TABLE) do
			if petId ~= ownerEntity.id then
				local petInfo = masterEntity.pets and masterEntity.pets[petId] or pg.getEntity(petId)

				if petInfo and petInfo.gender ~= ownerEntity.gender then
					return true
				end
			end
		end
	end

	return false
end

function CombatAction:getLockedTarget(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return 0
	end

	local masterEntity = ownerEntity.getMasterEntity and ownerEntity:getMasterEntity() or ownerEntity

	return masterEntity.lockedActorId
end

function CombatAction:registerRePressSkillSlot(actionData, combatContext)
	local time = actionData.time
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not owner then
		return false
	end

	if owner.authority ~= Const.AUTHORITY_MASTER and pg.component == "client" then
		return false
	end

	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	local abilityId = actionData.abilityId or combatContext.abilityId

	if not ToBool(abilityId) then
		return false
	end

	if AbilityUtils.isAiPet(owner) then
		local aiTriggerTime = actionData.aiTriggerTime or 0

		abilityObject:addTimer("aiTriggerTimer", aiTriggerTime, function()
			if pg.component == "client" then
				owner:serverMsgNoGC("RPC_CS_RePressSkillSlot", abilityId)
				self:doActions(actionData, combatContext)
			else
				owner:allClientsMsgNoGC("RPC_SC_RePressSkillSlot", abilityId)
				self:doActions(actionData, combatContext)
			end
		end)

		return true
	end

	local endTime = 0
	local registerTime = owner:getGameTime()

	if time == nil then
		if combatContext.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_BUFF then
			endTime = combatContext:buff().buffData.expiredTime
		elseif combatContext.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_TIMELINE then
			local timeline = combatContext:timeline()

			endTime = timeline:getRemainingTime() + registerTime
		else
			CombatActionTool.logError(combatContext, actionData, "only support timeline or buff")

			return false
		end

		time = endTime - registerTime
	else
		endTime = registerTime + time
	end

	local copyCombatContext = combatContext:clone()
	local noTriggerTime = actionData.noTriggerTime
	local overrideTagId = actionData.overrideTagId

	abilityObject:getObserver():listen(owner.subject, AbilityConst.COMBAT_EVENT_ON_RE_PRESS_SKILL_SLOT, function(pressAbilityId)
		if pressAbilityId ~= abilityId then
			return
		end

		if noTriggerTime then
			local triggerTime = owner:getGameTime()

			if triggerTime - registerTime <= noTriggerTime then
				return
			end
		end

		if owner.subject:isEventListening(AbilityConst.COMBAT_EVENT_ON_SKILL_AUTO_AIM) then
			abilityObject:getObserver():unlisten(owner.subject, AbilityConst.COMBAT_EVENT_ON_SKILL_AUTO_AIM)
		end

		if actionData.onlyTriggerOnce then
			abilityObject:getObserver():unlisten(owner.subject, AbilityConst.COMBAT_EVENT_ON_RE_PRESS_SKILL_SLOT)
		end

		self:doActions(actionData, copyCombatContext)
	end, function()
		if owner.setRePressAbilitySlotInfo then
			owner:setRePressAbilitySlotInfo(abilityId, nil, not ToBool(actionData.notShowCountDown))
		end

		if overrideTagId ~= nil and owner.notifyOverrideTagChange then
			owner:notifyOverrideTagChange(abilityId, nil)
		end
	end)

	if owner.setRePressAbilitySlotInfo then
		owner:setRePressAbilitySlotInfo(abilityId, endTime, not ToBool(actionData.notShowCountDown))
	end

	if overrideTagId ~= nil and owner.notifyOverrideTagChange then
		owner:notifyOverrideTagChange(abilityId, overrideTagId)
	end

	if owner.rePressSkillSkillSlotTimer then
		owner:removeTimer(owner.rePressSkillSkillSlotTimer)
	end

	abilityObject:addTimer("rePressSkillSkillSlotTimer", time, function()
		abilityObject:getObserver():unlisten(owner.subject, AbilityConst.COMBAT_EVENT_ON_RE_PRESS_SKILL_SLOT)
	end)
end

function CombatAction:registerAimSkillEndEvent(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	local isFromAutoCast = combatContext.constCasterInfo and combatContext.constCasterInfo.isFromAutoCast

	if isFromAutoCast or AbilityUtils.isAiPet(ownerEntity) then
		self:doActions(actionData.chargeTimeActions[1], combatContext)

		return true
	end

	local autoAimTime = actionData.autoAimTime or -1

	if autoAimTime >= 0 and ownerEntity.setEntityCacheVal then
		ownerEntity:setEntityCacheVal(AbilityConst.COMBAT_EVENT_ON_SKILL_AUTO_AIM, true)
	end

	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	local copyCombatContext = combatContext:clone()

	abilityObject.cacheValMap[AbilityConst.COMBAT_EVENT_ON_SKILL_AUTO_AIM] = {
		startTime = ownerEntity:getGameTime(),
		duration = autoAimTime
	}

	abilityObject:getObserver():listen(ownerEntity.subject, AbilityConst.COMBAT_EVENT_ON_SKILL_AUTO_AIM)
	abilityObject:addExitCallback(function()
		if ownerEntity.setEntityCacheVal then
			ownerEntity:setEntityCacheVal(AbilityConst.COMBAT_EVENT_ON_SKILL_AUTO_AIM, nil)
		end
	end)

	if Switch.EnableAimSkillSwitchMode then
		self:registerRePressSkillSlot(actionData, copyCombatContext)
	else
		self:registerStopChargeEvent(actionData, copyCombatContext)
	end
end

function CombatAction:enableSkillMotionAnimState(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not owner then
		return false
	end

	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	local copyCombatContext = combatContext:clone()

	abilityObject:getObserver():listen(owner.subject, AbilityConst.COMBAT_EVENT_ON_SKILL_MOTION_STATE_CHANGE, function(actionIds)
		self:doActionIds(actionIds, copyCombatContext)
	end)
end

function CombatAction:registerBeAttackedCounterEvent(actionData, combatContext)
	local owner = CombatActionTool.getRegisterEventSubjectEntity(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local conterAttackTimeAddV = owner.actorCombatAttribute:getAttribValue(AttributeConst.counter_attack_time_add_v) or 0
	local observer = CombatActionTool.getContextObserver(combatContext)
	local startOffsetTime = actionData.startOffsetTime or 0
	local perfectCounterTime = actionData.perfectCounterTime or 0
	local normalCounterActionIds = actionData.normalCounterActionIds
	local perfectCounterActionIds = actionData.perfectCounterActionIds
	local startTime = owner:getGameTime() + startOffsetTime
	local perfectCounterImmuneDamage = actionData.perfectCounterImmuneDamage

	if observer then
		local copyCombatContext = combatContext:clone()

		local function triggerEventFunc(eventCombatContext)
			local now = owner:getGameTime()

			if now - startTime <= perfectCounterTime + conterAttackTimeAddV then
				if LoggerManager.checkLogger(LoggerConst.DEBUG) then
					CombatLogger.debug("@hyj CombatAction[registerBeAttackedCounterEvent]: onPerfectCounter")
				end

				self:doActionIds(perfectCounterActionIds, copyCombatContext)

				if eventCombatContext and perfectCounterImmuneDamage then
					eventCombatContext.isImmuteDamage = true
				end

				owner.subject:notify(AbilityConst.COMBAT_EVENT_ON_TRIGGER_PERFECT_COUNTER, copyCombatContext)

				local attacker = CombatActionTool.getCasterEnt(eventCombatContext)

				if attacker then
					attacker.subject:notify(AbilityConst.COMBAT_EVENT_BE_PERFECT_COUNTERED, copyCombatContext)
				end
			else
				if LoggerManager.checkLogger(LoggerConst.DEBUG) then
					CombatLogger.debug("@hyj CombatAction[registerBeAttackedCounterEvent]: onNormalCounter")
				end

				self:doActionIds(normalCounterActionIds, copyCombatContext)

				local attacker = CombatActionTool.getCasterEnt(eventCombatContext)

				if attacker then
					attacker.subject:notify(AbilityConst.COMBAT_EVENT_BE_NORMAL_COUNTERED, copyCombatContext)
				end
			end

			owner.isInDefensiveCounterST = nil
		end

		if actionData.useCustomHitBox then
			observer:listen(owner.subject, AbilityConst.COMBAT_EVENT_ON_CUSTOM_HIT_BOX_BE_ATTACKED, function(eventCombatContext)
				copyCombatContext:setEventData(AbilityConst.COMBAT_EVENT_ON_CUSTOM_HIT_BOX_BE_ATTACKED, eventCombatContext)
				triggerEventFunc(eventCombatContext)
				copyCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_ON_CUSTOM_HIT_BOX_BE_ATTACKED)
			end)
		else
			observer:listen(owner.subject, AbilityConst.COMBAT_EVENT_RECEIVE_BE_ATTACKED, function(eventCombatContext)
				copyCombatContext:setEventData(AbilityConst.COMBAT_EVENT_RECEIVE_BE_ATTACKED, eventCombatContext)
				triggerEventFunc(eventCombatContext)
				copyCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_RECEIVE_BE_ATTACKED)
			end)

			owner.isInDefensiveCounterST = true

			local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

			if not abilityObject then
				return false
			end

			abilityObject:addExitCallback(function()
				owner.isInDefensiveCounterST = nil
			end)
		end
	end
end

function CombatAction:isCombatEventListening(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return false
	end

	return targetEntity.subject:isEventListening(actionData.eventName)
end

function CombatAction:checkIsInAutoAim(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	return ToBool(ownerEntity.getEntityCacheVal and ownerEntity:getEntityCacheVal(AbilityConst.COMBAT_EVENT_ON_SKILL_AUTO_AIM))
end

function CombatAction:setIsInAim(actionData, combatContext)
	if ToBool(actionData.val) then
		local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

		if not ownerEntity then
			return false
		end

		local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

		if not abilityObject then
			return false
		end

		if ownerEntity.subject:isEventListening(AbilityConst.COMBAT_EVENT_ON_SKILL_AUTO_AIM) then
			abilityObject:getObserver():unlisten(ownerEntity.subject, AbilityConst.COMBAT_EVENT_ON_SKILL_AUTO_AIM)

			if ownerEntity.setEntityCacheVal then
				ownerEntity:setEntityCacheVal(AbilityConst.COMBAT_EVENT_ON_SKILL_AUTO_AIM, nil)
			end
		end
	end
end

function CombatAction:registerOnSummonEvent(actionData, combatContext)
	local owner = CombatActionTool.getRegisterEventSubjectEntity(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local observer = CombatActionTool.getContextObserver(combatContext)

	if observer then
		local copyCombatContext = combatContext:clone()

		observer:listen(owner.subject, AbilityConst.COMBAT_EVENT_ON_PET_SUMMON, function()
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				CombatLogger.debug("@hyj CombatAction[registerOnSummonEvent]: onPetSummon")
			end

			self:doActions(actionData, copyCombatContext)
		end)

		if owner.isSummon then
			self:doActions(actionData, copyCombatContext)
		end
	end
end

function CombatAction:registerOnUnSummonEvent(actionData, combatContext)
	local owner = CombatActionTool.getRegisterEventSubjectEntity(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local observer = CombatActionTool.getContextObserver(combatContext)

	if observer then
		local copyCombatContext = combatContext:clone()

		observer:listen(owner.subject, AbilityConst.COMBAT_EVENT_ON_PET_UNSUMMON, function()
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				CombatLogger.debug("@hyj CombatAction[registerOnUnSummonEvent]: onPetUnSummon")
			end

			self:doActions(actionData, copyCombatContext)
		end)
	end
end

function CombatAction:registerPetOnSwitchEvent(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not owner then
		return false
	end

	local observer = CombatActionTool.getContextObserver(combatContext)

	if observer then
		local copyCombatContext = combatContext:clone()

		observer:listen(owner.subject, AbilityConst.COMBAT_EVENT_ON_OLD_PET_SWITCH, function(nextPet)
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				CombatLogger.debug("@hyj CombatAction[registerPetOnSwitchEvent]: onSwitchOldPet")
			end

			self:doActionIds(actionData.oldPetActionIds, copyCombatContext)
		end)

		if actionData.newPetActionIds then
			local newPetSwitchCombatContext = combatContext:clone()

			observer:listen(owner.subject, AbilityConst.COMBAT_EVENT_ON_NEW_PET_SWITCH, function(actorId)
				if LoggerManager.checkLogger(LoggerConst.DEBUG) then
					CombatLogger.debug("@hyj CombatAction[registerPetOnSwitchEvent]: onSwitchNewPet", actorId)
				end

				newPetSwitchCombatContext:setEventData(AbilityConst.COMBAT_EVENT_ON_NEW_PET_SWITCH, actorId)
				self:doActionIds(actionData.newPetActionIds, newPetSwitchCombatContext)
				newPetSwitchCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_ON_NEW_PET_SWITCH)
			end)
		end
	end
end

function CombatAction:getProjectileInstanceId(actionData, combatContext)
	if combatContext:projectile() then
		return combatContext.id
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		CombatLogger.error("CombatAction[getProjectileInstanceId]: projectile not found")
	end

	return 0
end

function CombatAction:isInControlState(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))
	local player = Utils.convertPlayerEntity(owner)

	if not player then
		return false
	end

	return player.controlState == actionData.controlState
end

function CombatAction:getRandomPosAlongLineToTarget(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not owner then
		return CombatActionTool.INVALID_POS
	end

	Vector3.enableCreateFromCache()

	local initPos = owner:getPosition():Clone()
	local refPos = initPos:Clone()
	local initDir = owner:getRotation():MulVec3(VEC3_CONST_FORWARD)

	initDir:SetNormalize()

	local basedOnTarget = ToBool(actionData.basedOnTarget)
	local randomDis = math.random(actionData.rangeMin, actionData.rangeMax)
	local result = CombatActionTool.parsePosition(combatContext, actionData.target, refPos)

	if not result then
		Vector3.disableCreateFromCache(initPos)

		return initPos
	end

	local dir = basedOnTarget and initPos - refPos or refPos - initPos
	local len = dir:Magnitude()

	if len < 0.0001 then
		local pos = basedOnTarget and refPos + initDir * randomDis or initPos + initDir * randomDis

		Vector3.disableCreateFromCache(pos)

		return pos
	end

	dir:SetNormalize()

	local pos = basedOnTarget and refPos + dir * randomDis or initPos + dir * randomDis

	Vector3.disableCreateFromCache(pos)

	return pos
end

function CombatAction:registerCharacterBuff(actionData, combatContext)
	local buff = combatContext:buff()

	if not buff then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("registerCharacterBuff, buff not found")
		end

		return false
	end

	local characterBuffType = actionData.characterBuffType

	if characterBuffType == AbilityConst.CHARACTER_BUFF_TYPE.TRIGGER_ACTION then
		self:registerCustomEvent(actionData, combatContext)
	end
end

function CombatAction:checkAttributeValue(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			CombatLogger.warn("CombatAction:checkAttributeValue failed, target not found", inspect(actionData.target))
		end

		return false
	end

	local attributeId = AttributeConst[actionData.attributeName]

	if attributeId < AttributeConst.GROUP_BEGIN or attributeId > AttributeConst.GROUP_END then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("CombatAction:checkAttributeValue failed, attribute is not defined", attributeId)
		end

		return false
	end

	local checkRatio = actionData.isRatio
	local checkValue = targetEntity.actorCombatAttribute:getAttribValue(attributeId)

	if checkRatio then
		if attributeId >= AttributeConst.GROUP_BASE_XP_BEGIN and attributeId <= AttributeConst.GROUP_BASE_XP_END then
			local beginId = AttributeConst.ID_INFO[attributeId].beginId
			local maxCurId = beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_CUR
			local curId = beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_XP_CUR
			local curValue = targetEntity.actorCombatAttribute:getAttribValue(curId)
			local maxValue = targetEntity.actorCombatAttribute:getAttribValue(maxCurId)

			if maxValue <= 0 or maxValue <= curValue then
				checkValue = 1
			else
				checkValue = curValue / maxValue
			end
		else
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				CombatLogger.error("CombatAction:checkAttributeValue failed, attribute is not XPGroup", attributeId)
			end

			return false
		end
	end

	if actionData.minValue and checkValue < actionData.minValue then
		return false
	end

	if actionData.maxValue and checkValue > actionData.maxValue then
		return false
	end

	return true
end

function CombatAction:puppetPreCastAction(actionData, combatContext, force)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return
	end

	if not Utils.isPuppet(targetEntity) then
		return
	end

	if ToBool(actionData.enableFrameFreeze) then
		self:frameFreeze(actionData, combatContext, force)
	end
end

function CombatAction:burrow(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	if ownerEntity:BURROW_ST() then
		return
	end

	if ownerEntity.setEntityCacheVal then
		ownerEntity:setEntityCacheVal(AbilityConst.COMBAT_EVENT_ON_BURROW_STATE_CHANGE, {
			enterBuffIds = actionData.enterBuffIds,
			duration = actionData.duration,
			switchToAbilityId = actionData.switchToAbilityId,
			exitCastAbilityId = actionData.exitCastAbilityId,
			burrowAbilityId = combatContext.abilityId
		})
	end

	local switchBurrowStateTime = actionData.switchBurrowStateTime

	if switchBurrowStateTime then
		ownerEntity:addTimer(switchBurrowStateTime, function()
			if ownerEntity.characterState == CharacterStateConst.SNEAKIN then
				ownerEntity.considerAsBurrowST = true
			end
		end)
	end
end

function CombatAction:enableSpecialAttackMode(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	if actionData.enable then
		local duration = actionData.duration
		local copyCombatContext = combatContext:clone()
		local switchSkillInfo = {
			from = actionData.normalAttackStartId,
			to = actionData.specialAttackStartId
		}

		self:switchSkill(switchSkillInfo, combatContext)
		self:doActionIds(actionData.enterActionIds, copyCombatContext)

		local overrideData = {
			exitActionIds = actionData.exitActionIds,
			combatContext = copyCombatContext,
			duration = duration,
			switchSkillInfo = switchSkillInfo,
			keepModeInSkill = actionData.keepModeInSkill,
			checkMask = actionData.checkMask
		}

		if ownerEntity.enableSpecialAttackMode then
			ownerEntity:enableSpecialAttackMode(true, duration, overrideData)
		end

		return
	else
		local specialAttackModeData = ownerEntity.specialAttackModeData

		if specialAttackModeData and specialAttackModeData.exitActionIds ~= nil and specialAttackModeData.combatContext ~= nil then
			self:doActionIds(specialAttackModeData.exitActionIds, specialAttackModeData.combatContext)
		end
	end

	if ownerEntity.enableSpecialAttackMode then
		ownerEntity:enableSpecialAttackMode(false)
	end
end

function CombatAction:isSpecialAttackModeShouldExit(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	local specialAttackModeData = ownerEntity.specialAttackModeData

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("@hyj checkShouldExit", specialAttackModeData and specialAttackModeData.shouldEndTime ~= nil and specialAttackModeData.shouldEndTime < ownerEntity:getGameTime())
	end

	if specialAttackModeData and specialAttackModeData.shouldEndTime ~= nil then
		return specialAttackModeData.shouldEndTime < ownerEntity:getGameTime()
	end

	return false
end

function CombatAction:registerServerCacheValChange(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	local copyCombatContext = CombatContext.clone(combatContext)

	abilityObject:getObserver():listen(ownerEntity.subject, AbilityConst.COMBAT_EVENT_ON_SERVER_CACHE_VAL_CHANGE, function(key)
		if key == actionData.key then
			self:doActions(actionData, copyCombatContext)
		end
	end)
end

function CombatAction:noHitInAbility(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	ownerEntity.noHitInAbility = true
end

function CombatAction:enableTakeRootState(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	local enable = actionData.enable

	if enable and ownerEntity.setEntityCacheVal then
		ownerEntity:setEntityCacheVal(AbilityConst.COMBAT_EVENT_ON_TAKE_ROOT_STATE_CHANGE, {
			switchToAbilityId = actionData.switchToAbilityId,
			exitCastAbilityId = actionData.exitCastAbilityId,
			takeRootAbilityId = combatContext.abilityId,
			duration = actionData.duration
		})
	end
end

function CombatAction:getVoxelWaterDepth(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return 0
	end

	if not ownerEntity.space then
		return 0
	end

	local pos = ownerEntity:getPosition()
	local voxelList = VoxelUtils.getVoxelDataList(ownerEntity.space.id, pos.x, pos.z)
	local waterDepth = 0

	for i = #voxelList, 1, -1 do
		local minLayer, maxLayer, material, state, _ = unpack(voxelList[i])

		if maxLayer <= pos.y or minLayer <= pos.y and maxLayer >= pos.y then
			if bit.band(material, VoxelConst.VoxelMaterialDef.Water) ~= 0 or bit.band(material, VoxelConst.VoxelMaterialDef.WaterBottom) ~= 0 or bit.band(state, VoxelConst.VoxelStateDef.WaterPool) ~= 0 then
				waterDepth = waterDepth + (pos.y - minLayer)
			end
		else
			return waterDepth
		end
	end

	return waterDepth
end

function CombatAction:doPetsActions(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	local masterEntity = Utils.convertPlayerEntity(ownerEntity)

	if not masterEntity then
		return false
	end

	local space = masterEntity.space

	if not space then
		return false
	end

	for idx, petId in ipairs(masterEntity.petPrepareList) do
		if space.battleMode > 0 and idx > space.battleMode then
			break
		end

		local petEntity = pg.getEntity(petId)

		if petEntity then
			local runtimeTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:get(true)
			local guardVal = GuardValue(combatContext, "runtimeTargetInfo", runtimeTargetInfo)

			runtimeTargetInfo:initTarget(petEntity.actorId, petEntity:getPosition(), 1, 0)
			self:doActions(actionData, combatContext)
			guardVal:recover()
			pg.global.abilityMgr.runtimeTargetInfoPool:returnObject(runtimeTargetInfo)
		end
	end

	if actionData.applyOnExplorePets then
		for idx, petId in ipairs(masterEntity.petExploreList) do
			local explorePetEntity = pg.getEntity(petId)

			if explorePetEntity then
				local runtimeTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:get(true)
				local guardVal = GuardValue(combatContext, "runtimeTargetInfo", runtimeTargetInfo)

				runtimeTargetInfo:initTarget(explorePetEntity.actorId, explorePetEntity:getPosition(), 1, 0)
				self:doActions(actionData, combatContext)
				guardVal:recover()
				pg.global.abilityMgr.runtimeTargetInfoPool:returnObject(runtimeTargetInfo)
			end
		end
	end

	if masterEntity:EXTRA_TEMP_PET_ST() then
		local curPet = masterEntity:getCurPetEntity()

		if curPet then
			local runtimeTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:get(true)
			local guardVal = GuardValue(combatContext, "runtimeTargetInfo", runtimeTargetInfo)

			runtimeTargetInfo:initTarget(curPet.actorId, curPet:getPosition(), 1, 0)
			self:doActions(actionData, combatContext)
			guardVal:recover()
			pg.global.abilityMgr.runtimeTargetInfoPool:returnObject(runtimeTargetInfo)
		end
	end

	return true
end

function CombatAction:doCreationActions(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity or not ownerEntity.createdCreationList then
		return false
	end

	local templateIds = actionData.templateIds

	Lume.clear(CombatActionTool.TEMP_TABLE)

	local needCheckTemplateId = ToBool(templateIds)

	if needCheckTemplateId then
		for _, templateId in ipairs(templateIds) do
			CombatActionTool.TEMP_TABLE[templateId] = true
		end
	end

	local filteredList = {}

	for _, actorId in ipairs(ownerEntity.createdCreationList) do
		local creationEntity = pg.getEntityByActorId(actorId)

		if creationEntity and (not needCheckTemplateId or CombatActionTool.TEMP_TABLE[creationEntity.templateId]) then
			table.insert(filteredList, creationEntity)
		end
	end

	local randomExecuteNum = actionData.randomExecuteNum
	local useRandomChoice = randomExecuteNum and randomExecuteNum > 0

	if useRandomChoice then
		filteredList = Lume.randomchoiceN(filteredList, randomExecuteNum)
	end

	for _, creationEntity in ipairs(filteredList) do
		local runtimeTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:get(true)
		local guardVal = GuardValue(combatContext, "runtimeTargetInfo", runtimeTargetInfo)

		runtimeTargetInfo:initTarget(creationEntity.actorId, creationEntity:getPosition(), 1, 0)
		self:doActions(actionData, combatContext)
		guardVal:recover()
		pg.global.abilityMgr.runtimeTargetInfoPool:returnObject(runtimeTargetInfo)
	end

	Lume.clear(CombatActionTool.TEMP_TABLE)

	return true
end

function CombatAction:enableMagnesisState(actionData, combatContext)
	local casterActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_CASTER)
	local casterEntity = pg.getEntityByActorId(casterActorId)

	if not casterEntity or not casterEntity.registerMagnesisAbilityActions then
		return false
	end

	local triggerActions = actionData.onTriggerHit
	local onStartActions = actionData.onMagnesisStart
	local onFinishActions = actionData.onMagnesisFinish

	casterEntity:registerMagnesisAbilityActions(combatContext, triggerActions, onStartActions, onFinishActions)
end

function CombatAction:isPuppetStage(actionData, combatContext)
	local target = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if not target then
		return false
	end

	local stage = target:getConfigData() and target:getConfigData().stage or 0

	return ToBool(stage) and stage == actionData.stage
end

function CombatAction:registerGroupEvent(actionData, combatContext)
	EventBus.isReceiveAdditionalEvent = true
	EventBus.isUnSummonAdditionEventValid = ToBool(actionData.unsummonValid)

	if actionData.isReceiveCreationEvent ~= nil then
		EventBus.isReceiveCreationEvent = actionData.isReceiveCreationEvent
	end

	self:doActions(actionData, combatContext)

	EventBus.isReceiveCreationEvent = true
	EventBus.isReceiveAdditionalEvent = false
	EventBus.isUnSummonAdditionEventValid = false
end

function CombatAction:forEach(actionData, combatContext)
	local guardVal = pg.global.abilityMgr.guardValuePool:get(true)
	local startNum = self:getVal(actionData.startNum, combatContext)
	local endNum = self:getVal(actionData.endNum, combatContext)
	local stepNum = self:getVal(actionData.stepNum, combatContext)

	for i = startNum, endNum, stepNum do
		guardVal:ctor(combatContext, "iterNumber", i)
		self:doActions(actionData, combatContext)
		guardVal:recover()
	end

	pg.global.abilityMgr.guardValuePool:returnObject(guardVal)
end

function CombatAction:getIterNumber(actionData, combatContext)
	return combatContext.iterNumber or 0
end

function CombatAction:getRotatedPoint(actionData, combatContext)
	Vector3.enableCreateFromCache()

	local center = Vector3(0, 0, 0)

	CombatActionTool.parsePosition(combatContext, actionData.center, center)

	local rotation = Quaternion(0, 0, 0, 1)

	CombatActionTool.parseRotation(combatContext, actionData.rotation, rotation)

	local angle = type(actionData.angle) == "number" and actionData.angle or self:doAction(actionData.angle, combatContext)

	rotation = rotation * Quaternion.AngleAxis(angle, VEC3_CONST_UP)

	local radius = self:getVal(actionData.radius, combatContext)
	local result = center + Quaternion.MulVec3(rotation, VEC3_CONST_FORWARD) * radius

	Vector3.disableCreateFromCache(result)

	return result
end

function CombatAction:getListItem(actionData, combatContext)
	local list = combatContext.nodeMap[actionData.listId].list
	local index = Utils.isTable(actionData.index) and self:doAction(actionData.index, combatContext) or actionData.index
	local result = list and list[index]

	if result then
		if Utils.isTable(result) and result.name then
			return self:doAction(result, combatContext)
		else
			return result
		end
	end

	CombatActionTool.logError(combatContext, actionData, "getListItem failed")

	return nil
end

function CombatAction:constNumber(actionData, combatContext)
	return actionData.number
end

function CombatAction:constString(actionData, combatContext)
	if actionData.concatenateNumber ~= nil then
		local num = self:getVal(actionData.concatenateNumber, combatContext)

		return actionData.str .. tostring(num)
	end

	return actionData.str
end

function CombatAction:registerAbilityEndEvent(actionData, combatContext)
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return
	end

	local owner = CombatActionTool.getRegisterEventSubjectEntity(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local copyCombatContext = combatContext:clone()

	abilityObject:getObserver():listen(owner.subject, AbilityConst.COMBAT_EVENT_ON_ABILITY_END, function(eventCombatContext)
		if CombatActionTool.isBlockTriggerAbilityEvent(eventCombatContext.abilityId, eventCombatContext.actorId, actionData) then
			return
		end

		copyCombatContext:setEventData(AbilityConst.COMBAT_EVENT_ON_ABILITY_END, eventCombatContext)
		self:doActions(actionData, copyCombatContext)
		copyCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_ON_ABILITY_END)
	end)
end

function CombatAction:isActorGender(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return false
	end

	local configData = targetEntity:getConfigData()
	local gender = targetEntity.gender and targetEntity.gender or configData.gender

	if gender == nil then
		return false
	end

	return gender == actionData.gender
end

function CombatAction:registerPostAttackEvent(actionData, combatContext)
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return
	end

	local owner = CombatActionTool.getRegisterEventSubjectEntity(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local copyCombatContext = combatContext:clone()

	abilityObject:getObserver():listen(owner.subject, AbilityConst.COMBAT_EVENT_ON_POST_ATTACK, function(eventCombatContext)
		copyCombatContext:setEventData(AbilityConst.COMBAT_EVENT_ON_POST_ATTACK, eventCombatContext)
		self:doActions(actionData, copyCombatContext)
		copyCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_ON_POST_ATTACK)
	end)
end

function CombatAction:getEventPostAttackTarget(actionData, combatContext)
	local eventData = combatContext.eventData and combatContext.eventData[AbilityConst.COMBAT_EVENT_ON_POST_ATTACK]

	if eventData then
		return CombatActionTool.parseActorId(eventData, AbilityConst.COMBAT_TARGET_TYPE_TARGET)
	end

	return 0
end

function CombatAction:getHitImpulseDir(actionData, combatContext)
	local timeline = combatContext:timeline()

	if not timeline then
		return Vector3(0, 0, 0)
	end

	if timeline.timelineParams.timelineKind == AbilityConst.TIMELINE_HIT then
		return timeline.timelineParams.hitParams.impulseDir or Vector3(0, 0, 0)
	end

	return Vector3(0, 0, 0)
end

function CombatAction:createFollowingPhantom(actionData, combatContext, callback, ent)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not owner then
		return false
	end

	if not Utils.isPet(owner) then
		CombatActionTool.logDebug(combatContext, actionData, "only support pet entity", owner.actorId, owner.className)

		return false
	end

	local copyCombatContext = combatContext:clone()
	local masterEntity = owner:getMasterEntity()
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	EventBus.isReceiveAdditionalEvent = true

	abilityObject:getObserver():listen(masterEntity.subject, AbilityConst.COMBAT_EVENT_ON_ABILITY_DISABLE_RETURN, function(eventCombatContext)
		if eventCombatContext.castingCombatContextId == copyCombatContext.castingCombatContextId then
			return
		end

		if CombatActionTool.isBlockTriggerAbilityEvent(eventCombatContext.abilityId, eventCombatContext.actorId, actionData) then
			return
		end

		local eventOwner = pg.getEntityByActorId(CombatActionTool.parseActorId(eventCombatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

		if not Utils.isPet(eventOwner) then
			return
		end

		if AbilityUtils.isNormalAttack(eventCombatContext.abilityId) then
			return
		end

		if not AbilityUtils.getFollowingPhantomVisible(masterEntity.actorId, actionData) then
			return false
		end

		self:doActions(actionData, copyCombatContext)

		if callback then
			callback()
		end
	end)

	if actionData.eventMaps then
		abilityObject:getObserver():listen(masterEntity.subject, AbilityConst.COMBAT_EVENT_ON_NOTIFY_FOLLOW_PHANTOM, function(eventName, eventCombatContext)
			if not AbilityUtils.getFollowingPhantomVisible(masterEntity.actorId, actionData) then
				return false
			end

			local nodeId = actionData.eventMaps[eventName]
			local eventActionData = nodeId and copyCombatContext.nodeMap[nodeId]

			if not eventActionData then
				return false
			end

			if eventActionData.checkOwner then
				if not eventCombatContext then
					CombatActionTool.logError(copyCombatContext, eventActionData, "follow phantom event combat context not found", eventName)

					return false
				end

				local eventOwnerActorId = CombatActionTool.parseActorId(eventCombatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
				local copyOwnerActorId = CombatActionTool.parseActorId(copyCombatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)

				if eventOwnerActorId ~= copyOwnerActorId then
					return false
				end
			end

			if ent then
				copyCombatContext.followPhantomActorId = ent.actorId
			end

			self:doActions(eventActionData, copyCombatContext)

			copyCombatContext.followPhantomActorId = nil
		end)
	end

	EventBus.isReceiveAdditionalEvent = false

	return true
end

function CombatAction:getRotationFromTo(actionData, combatContext)
	Vector3.enableCreateFromCache()

	local rotation = Quaternion(0, 0, 0, 1)

	CombatActionTool.parseRotationFromTo(combatContext, actionData.from, actionData.to, rotation, actionData.considerYAxis)
	Quaternion.removeTempQuaterion(rotation)
	Vector3.disableCreateFromCache()

	return rotation
end

function CombatAction:doCounterAction(actionData, combatContext)
	local cacheKey = actionData.UID
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	local owner = abilityObject.owner
	local newCount = (owner.getEntityCacheVal and owner:getEntityCacheVal(cacheKey) or 0) + 1
	local count = self:getVal(actionData.count, combatContext)

	if count <= newCount then
		self:doActions(actionData, combatContext)

		if owner.setEntityCacheVal then
			owner:setEntityCacheVal(cacheKey, 0)
		end
	elseif owner.setEntityCacheVal then
		owner:setEntityCacheVal(cacheKey, newCount)
	end

	abilityObject:addExitCallback(function()
		if owner.setEntityCacheVal then
			owner:setEntityCacheVal(cacheKey, nil)
		end
	end)
end

function CombatAction:doActionsByEventCombatContext(actionData, combatContext)
	local eventName = actionData.eventName
	local eventCombatContext = combatContext.eventData and combatContext.eventData[eventName] or nil

	if not eventCombatContext then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@hyj CombatAction:doActionsByEventCombatContext failed, eventCombatContext is nil", eventName)
		end

		return
	end

	local copyCombatContext = combatContext:clone()
	local rawConstCasterInfo = copyCombatContext.constCasterInfo
	local rawAbilityId = combatContext.abilityId
	local rawAbilityStoreType = combatContext.abilityStoreType
	local rawSrcType = combatContext.srcType
	local rawActorId = combatContext.actorId

	copyCombatContext.runtimeTargetInfo = eventCombatContext.runtimeTargetInfo and eventCombatContext.runtimeTargetInfo:clone()
	copyCombatContext.constCasterInfo = eventCombatContext.constCasterInfo:clone()
	copyCombatContext.abilityId = eventCombatContext.abilityId
	copyCombatContext.abilityStoreType = eventCombatContext.abilityStoreType
	copyCombatContext.srcType = eventCombatContext.srcType
	copyCombatContext.actorId = eventCombatContext.actorId

	self:doActions(actionData, copyCombatContext)

	copyCombatContext.constCasterInfo = rawConstCasterInfo
	copyCombatContext.abilityId = rawAbilityId
	copyCombatContext.abilityStoreType = rawAbilityStoreType
	copyCombatContext.srcType = rawSrcType
	copyCombatContext.actorId = rawActorId
end

function CombatAction:getShieldPoint(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity or not ownerEntity.shieldDataList then
		return 0
	end

	return ownerEntity.shieldDataList:getCurPoint(ownerEntity)
end

function CombatAction:max(actionData, combatContext)
	local valueA = self:getVal(actionData.a, combatContext)
	local valueB = self:getVal(actionData.b, combatContext)

	return math.max(valueA, valueB)
end

function CombatAction:min(actionData, combatContext)
	local valueA = self:getVal(actionData.a, combatContext)
	local valueB = self:getVal(actionData.b, combatContext)

	return math.min(valueA, valueB)
end

function CombatAction:selectPet(actionData, combatContext)
	local masterEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_MASTER))

	if not masterEntity then
		return false
	end

	if not Utils.isPlayer(masterEntity) and not Utils.isBotPlayer(masterEntity) then
		return false
	end

	if not ToBool(masterEntity.petPrepareList) then
		return false
	end

	local guardValue = GuardValue()
	local runtimeTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:get(true)

	if actionData.selectType == AbilityConst.SELECT_TARGET_TYPE.MIN then
		local min, selectedEnt

		for _, petId in ipairs(masterEntity.petPrepareList) do
			local petEnt = pg.getEntity(petId)

			if petEnt then
				runtimeTargetInfo:initTarget(petEnt.actorId, petEnt:getPosition(), 1, 1)
			end

			guardValue:ctor(combatContext, "runtimeTargetInfo", runtimeTargetInfo)

			local val = self:doAction(actionData.selectAction, combatContext)

			if min == nil or val < min then
				min = val
				selectedEnt = petEnt
			end

			guardValue:recover()
		end

		if selectedEnt then
			runtimeTargetInfo:initTarget(selectedEnt.actorId, selectedEnt:getPosition(), 1, 1)
			guardValue:ctor(combatContext, "runtimeTargetInfo", runtimeTargetInfo)
			self:doActions(actionData, combatContext)
			guardValue:recover()
		end
	end

	pg.global.abilityMgr.runtimeTargetInfoPool:returnObject(runtimeTargetInfo)

	return true
end

function CombatAction:doActionsInCd(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return false
	end

	local cd = self:getVal(actionData.cd, combatContext)
	local key = actionData.key or actionData.UID
	local lastCallTime = targetEntity.getEntityCacheVal and targetEntity:getEntityCacheVal(key) or -cd
	local now = targetEntity:getGameTime()

	if cd > now - lastCallTime then
		return false
	end

	self:doActions(actionData, combatContext)

	if targetEntity.setEntityCacheVal then
		targetEntity:setEntityCacheVal(key, now)
	end

	return true
end

function CombatAction:registerCacheValChange(actionData, combatContext)
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	local copyCombatContext = combatContext:clone()

	abilityObject:getObserver():listen(abilityObject.owner.subject, AbilityConst.COMBAT_EVENT_ON_CACHE_VAL_CHANGE, function(key)
		if key == actionData.key then
			self:doActions(actionData, copyCombatContext)
		end
	end)
end

function CombatAction:getLossHpRatio(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity or not targetEntity.actorCombatAttribute then
		return 0
	end

	return 1 - targetEntity.actorCombatAttribute:getHpRatio()
end

function CombatAction:getEventAttributeChangeTarget(actionData, combatContext)
	return combatContext.eventData and combatContext.eventData[AbilityConst.COMBAT_EVENT_ATTRIBUTE_CHANGE] and combatContext.eventData[AbilityConst.COMBAT_EVENT_ATTRIBUTE_CHANGE].actorId or nil
end

function CombatAction:getParamByLuaConfig(actionData, combatContext)
	return CombatActionTool.getParamByLuaConfig(actionData.calcType, actionData.calcId, actionData.paramName, combatContext)
end

function CombatAction:getLossHp(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return 0
	end

	return targetEntity.actorCombatAttribute:getMaxHp() - targetEntity.actorCombatAttribute:getHp()
end

function CombatAction:registerAddAbilityImpulse(actionData, combatContext)
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	local copyCombatContext = combatContext:clone()

	abilityObject:getObserver():listen(abilityObject.owner.subject, AbilityConst.COMBAT_EVENT_ON_ADD_ABILITY_IMPULSE, function(impulse)
		copyCombatContext:setEventData(AbilityConst.COMBAT_EVENT_ON_ADD_ABILITY_IMPULSE, impulse)
		self:doActions(actionData, copyCombatContext)
		copyCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_ON_ADD_ABILITY_IMPULSE)
	end)
end

function CombatAction:getEventAddAbilityImpulseValue(actionData, combatContext)
	return combatContext.eventData and combatContext.eventData[AbilityConst.COMBAT_EVENT_ON_ADD_ABILITY_IMPULSE] or 0
end

function CombatAction:getTargetPosOrCustomPos(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_TARGET))

	if targetEntity then
		local targetPos = actionData.useHitPos and CombatActionTool.getHitPosition(targetEntity) or targetEntity:getPosition()
		local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))
		local distance = actionData.distance
		local ignoreDistanceConfig = distance == nil or distance < 0
		local outputTargetActorId = actionData.outputTargetActorId

		if ignoreDistanceConfig or ownerEntity and distance >= Vector3.Distance(targetPos, ownerEntity:getPosition()) then
			return outputTargetActorId and targetEntity.actorId or targetPos
		end
	end

	return self:getVal(actionData.pos, combatContext)
end

function CombatAction:getEventCombatContextTarget(actionData, combatContext)
	local eventCombatContext = combatContext.eventData and combatContext.eventData[actionData.eventName]

	if type(eventCombatContext) == "table" and eventCombatContext.nodeStack then
		return CombatActionTool.parseActorId(eventCombatContext, actionData.target)
	end

	return 0
end

function CombatAction:registerReceiveDamageEvent(actionData, combatContext)
	local targetEntity = CombatActionTool.getRegisterEventSubjectEntity(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)

	if targetEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("targetEntity not found", actionData.target)
		end

		return false
	end

	local targetType = actionData.targetType or AbilityConst.ATTR_CHANGE_TARGET.SELF
	local eventName = AbilityConst.COMBAT_EVENT_RECEIVE_DAMAGE

	if targetType == AbilityConst.ATTR_CHANGE_TARGET.CURPET then
		eventName = AbilityConst.COMBAT_EVENT_PET_RECEIVE_DAMAGE
	end

	local observer = CombatActionTool.getContextObserver(combatContext)

	if observer then
		local copyCombatContext = combatContext:clone()

		observer:listen(targetEntity.subject, eventName, function(eventCombatContext)
			if pg.component == "game" then
				targetEntity:allClientsMsgNoGC("RPC_SC_NotifyReceiveDamage", eventName, eventCombatContext.actorId, eventCombatContext:getRPCDynamicInfo())
			end

			copyCombatContext:setEventData(eventName, eventCombatContext)
			self:doActions(actionData, copyCombatContext)
			copyCombatContext:clearEventData(eventName)
		end)
	end
end

function CombatAction:doIgnoreProcessAttributeActions(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	for _, attributeName in ipairs(actionData.attributes) do
		local attributeId = AttributeConst[attributeName]

		if attributeId then
			ownerEntity.ignoreProcessAttributeMap[attributeId] = (ownerEntity.ignoreProcessAttributeMap[attributeId] or 0) + 1
		end
	end

	self:doActions(actionData, combatContext)

	for _, attributeName in ipairs(actionData.attributes) do
		local attributeId = AttributeConst[attributeName]

		if attributeId then
			if ownerEntity.ignoreProcessAttributeMap[attributeId] == 1 then
				ownerEntity.ignoreProcessAttributeMap[attributeId] = nil
			else
				ownerEntity.ignoreProcessAttributeMap[attributeId] = ownerEntity.ignoreProcessAttributeMap[attributeId] - 1
			end
		end
	end
end

function CombatAction:getEventTrapTarget(actionData, combatContext)
	if not combatContext.eventData then
		return 0
	end

	if combatContext.eventData[AbilityConst.COMBAT_EVENT_ON_ENTER_TRAP] then
		return combatContext.eventData[AbilityConst.COMBAT_EVENT_ON_ENTER_TRAP].actorId
	end

	if combatContext.eventData[AbilityConst.COMBAT_EVENT_ON_LEAVE_TRAP] then
		return combatContext.eventData[AbilityConst.COMBAT_EVENT_ON_LEAVE_TRAP].actorId
	end

	return 0
end

function CombatAction:registerSkillHookBeHitEvent(actionData, combatContext)
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	local copyCombatContext = combatContext:clone()

	abilityObject:getObserver():listen(abilityObject.owner.subject, AbilityConst.COMBAT_EVENT_ON_SKILL_HOOK_BE_HIT, function(hooker)
		copyCombatContext:setEventData(AbilityConst.COMBAT_EVENT_ON_SKILL_HOOK_BE_HIT, hooker)
		self:doActions(actionData, copyCombatContext)
		copyCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_ON_SKILL_HOOK_BE_HIT)
	end)
end

function CombatAction:getEventSkillHookBeHitCaster(actionData, combatContext)
	if not combatContext.eventData then
		return 0
	end

	if combatContext.eventData[AbilityConst.COMBAT_EVENT_ON_SKILL_HOOK_BE_HIT] then
		return combatContext.eventData[AbilityConst.COMBAT_EVENT_ON_SKILL_HOOK_BE_HIT]
	end

	return 0
end

function CombatAction:checkPetPrototypeId(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if targetEntity then
		local prototypeId = actionData.petPrototypeId

		if Utils.isPet(targetEntity) and Utils.getPetPetPrototypeId(targetEntity.templateId) == prototypeId then
			return true
		end

		if Utils.isPuppet(targetEntity) and Utils.getPuppetPetPrototypeId(targetEntity.templateId) == prototypeId then
			return true
		end
	end

	return false
end

function CombatAction:enableSpecialDefenseST(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	ownerEntity.isInSpecialDefense = actionData.enable

	if actionData.enable then
		local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

		if not abilityObject then
			return false
		end

		abilityObject:addExitCallback(function()
			ownerEntity.isInSpecialDefense = false
		end)
	end
end

function CombatAction:isInSpecialDefenseST(actionData, combatContext)
	local isNot = actionData["not"]
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity == nil then
		return false
	end

	local isInSpecialDefenseST = targetEntity:SPECIAL_DEFENSE_ST()

	return isNot and not isInSpecialDefenseST or isInSpecialDefenseST
end

function CombatAction:reboundDash(actionData, combatContext)
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	abilityObject:addExitCallback(function()
		if abilityObject.owner.endReboundDash then
			abilityObject.owner:endReboundDash()
		end
	end)

	if abilityObject.owner.startReboundDash then
		abilityObject.owner:startReboundDash(actionData, combatContext)
	end
end

function CombatAction:checkRelationWithReferenceTarget(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))
	local referenceTargetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.referenceTarget))

	if not targetEntity or not referenceTargetEntity then
		return false
	end

	return Utils.checkRelation(targetEntity, referenceTargetEntity, actionData.relation)
end

function CombatAction:getAIBlackBoardValue(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if targetEntity and targetEntity.agent then
		return targetEntity.agent:getBlackBoardProperty(actionData.valueName)
	end

	return nil
end

function CombatAction:hasShield(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return false
	end

	return targetEntity.shieldDataList:getCurPoint(targetEntity) > 0
end

function CombatAction:isAbilityTag(actionData, combatContext)
	local eventData = combatContext.eventData and combatContext.eventData[actionData.eventName]

	if eventData then
		local abilityId = eventData.abilityId
		local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(abilityId)

		return ToBool(Lume.findInList(abilityTemplate.tags, actionData.tag))
	else
		return false
	end
end

function CombatAction:getRotationOffsetBasedOnTargetRotation(actionData, combatContext)
	Vector3.enableCreateFromCache()

	local refRot = Quaternion(0, 0, 0, 1)
	local result = CombatActionTool.parseRotation(combatContext, actionData.target, refRot)

	if not result then
		Vector3.disableCreateFromCache()

		return nil
	end

	local offsetRotation = actionData.offsetRotation and (actionData.offsetRotation.name == nil and Vector3(unpack(actionData.offsetRotation)) or self:doAction(actionData.offsetRotation, combatContext)) or Vector3(0, 0, 0)

	if offsetRotation.w ~= nil then
		offsetRotation = Quaternion.ToEulerAngles(offsetRotation)
	end

	local left = refRot * VEC3_CONST_LEFT
	local up = refRot * VEC3_CONST_UP
	local forward = refRot * VEC3_CONST_FORWARD
	local resultRot = Quaternion(0, 0, 0, 1)

	if offsetRotation.x ~= 0 then
		resultRot:Copy(resultRot * Quaternion.AngleAxis(offsetRotation.x, left))
	end

	if offsetRotation.y ~= 0 then
		resultRot:Copy(resultRot * Quaternion.AngleAxis(offsetRotation.y, up))
	end

	if offsetRotation.z ~= 0 then
		resultRot:Copy(resultRot * Quaternion.AngleAxis(offsetRotation.z, forward))
	end

	Quaternion.removeTempQuaterion(resultRot)
	Vector3.disableCreateFromCache()

	return resultRot
end

function CombatAction:getDistanceBetweenTarget(actionData, combatContext)
	local pointA = Vector3.GetFromPool(0, 0, 0)

	if not CombatActionTool.parsePosition(combatContext, actionData.targetA, pointA) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("parsePosition failed targetA: ", actionData.targetA)
		end

		Vector3.returnToPool(pointA)

		return 0
	end

	local pointB = Vector3.GetFromPool(0, 0, 0)

	if not CombatActionTool.parsePosition(combatContext, actionData.targetB, pointB) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("parsePosition failed targetB: ", actionData.targetB)
		end

		Vector3.returnToPool(pointA)
		Vector3.returnToPool(pointB)

		return 0
	end

	if ToBool(actionData.onlyXZ) then
		pointA.y = 0
		pointB.y = 0
	end

	local dist = Vector3.Distance(pointA, pointB)

	Vector3.returnToPool(pointA)
	Vector3.returnToPool(pointB)

	return dist
end

function CombatAction:constVector5(actionData, combatContext)
	local vector5 = {}

	vector5[1] = self:getVal(actionData.x, combatContext)
	vector5[2] = self:getVal(actionData.y, combatContext)
	vector5[3] = self:getVal(actionData.z, combatContext)
	vector5[4] = self:getVal(actionData.w, combatContext)
	vector5[5] = self:getVal(actionData.v, combatContext)

	return vector5
end

function CombatAction:getGroundPosFromRefPos(actionData, combatContext)
	local refPos
	local refPosType = actionData.refPos

	if refPosType then
		if Utils.isTable(refPosType) and not refPosType.name then
			refPos = Vector3(unpack(refPosType))
		else
			refPos = Vector3(0, 0, 0)

			local isValid = CombatActionTool.parsePosition(combatContext, refPosType, refPos)

			if not isValid then
				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					CombatLogger.error("@hyj Convert refPosType failed, check refPos", inspect(refPosType), inspect(refPos))
				end

				return CombatActionTool.INVALID_POS
			end
		end
	end

	if pg.component == "client" then
		return PhysicsUtils.getGroundPos(refPos, nil, nil, nil, false) or refPos
	else
		local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

		if not ownerEntity then
			return CombatActionTool.INVALID_POS
		end

		if not ownerEntity.space then
			return CombatActionTool.INVALID_POS
		end

		local groundPos, result = VoxelUtils.getGroundPos(ownerEntity.space.id, Vector3(refPos.x, refPos.y + 4, refPos.z))

		if result then
			return groundPos
		else
			return refPos
		end
	end
end

function CombatAction:getClientPreparedData(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return nil
	end

	local clientPreparedData = ownerEntity.getEntityCacheVal and ownerEntity:getEntityCacheVal(AbilityConst.COMBAT_EVENT_ON_CLIENT_DATA_PREPARED)
	local index = actionData.index

	return clientPreparedData and clientPreparedData[index] or nil
end

function CombatAction:initDynamicList(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	if actionData.isOnlyServer then
		if not ownerEntity.dynamicListIsOnlyServer then
			ownerEntity.dynamicListIsOnlyServer = {}
		end

		ownerEntity.dynamicListIsOnlyServer[actionData.listId] = true

		if pg.component == "game" then
			if ownerEntity.setEntityCacheVal then
				ownerEntity:setEntityCacheVal(actionData.listId, {})
			end

			ownerEntity:allClientsMsgNoGC("RPC_SC_ChangeDynamicListMap", actionData.listId, ownerEntity.getEntityCacheVal and ownerEntity:getEntityCacheVal(actionData.listId) or {})

			return true
		else
			return true
		end
	else
		if ownerEntity.setEntityCacheVal then
			ownerEntity:setEntityCacheVal(actionData.listId, {})
		end

		return true
	end
end

function CombatAction:addDynamicListItem(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return
	end

	if ownerEntity.dynamicListIsOnlyServer and ownerEntity.dynamicListIsOnlyServer[actionData.listId] and pg.component == "client" then
		return true
	end

	local list = ownerEntity.getEntityCacheVal and ownerEntity:getEntityCacheVal(actionData.listId)

	if not Utils.isTable(list) then
		CombatActionTool.logError(combatContext, actionData, "not type table", tostring(list))

		return false
	end

	table.insert(list, self:getVal(actionData.value, combatContext))

	if ownerEntity.dynamicListIsOnlyServer and ownerEntity.dynamicListIsOnlyServer[actionData.listId] and pg.component == "game" then
		ownerEntity:allClientsMsgNoGC("RPC_SC_ChangeDynamicListMap", actionData.listId, ownerEntity.getEntityCacheVal and ownerEntity:getEntityCacheVal(actionData.listId) or {})
	end

	return true
end

function CombatAction:removeDynamicListItem(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	if ownerEntity.dynamicListIsOnlyServer and ownerEntity.dynamicListIsOnlyServer[actionData.listId] and pg.component == "client" then
		return true
	end

	local list = ownerEntity.getEntityCacheVal and ownerEntity:getEntityCacheVal(actionData.listId)

	if not Utils.isTable(list) then
		CombatActionTool.logError(combatContext, actionData, "not type table", tostring(list))

		return false
	end

	local removeVal = self:getVal(actionData.value, combatContext)

	for i = 1, #list do
		if list[i] == removeVal then
			table.remove(list, i)

			if ownerEntity.dynamicListIsOnlyServer and ownerEntity.dynamicListIsOnlyServer[actionData.listId] and pg.component == "game" then
				ownerEntity:allClientsMsgNoGC("RPC_SC_ChangeDynamicListMap", actionData.listId, ownerEntity.getEntityCacheVal and ownerEntity:getEntityCacheVal(actionData.listId) or {})
			end

			return true
		end
	end

	return true
end

function CombatAction:removeDynamicListItemByIndex(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	if ownerEntity.dynamicListIsOnlyServer and ownerEntity.dynamicListIsOnlyServer[actionData.listId] and pg.component == "client" then
		return true
	end

	local list = ownerEntity.getEntityCacheVal and ownerEntity:getEntityCacheVal(actionData.listId)

	if not Utils.isTable(list) then
		CombatActionTool.logError(combatContext, actionData, "not type table", tostring(list))

		return false
	end

	local index = self:getVal(actionData.index, combatContext)

	if index < 1 or index > #list then
		CombatActionTool.logError(combatContext, actionData, "index out of range", index, "#list", #list)

		if ownerEntity.dynamicListIsOnlyServer and ownerEntity.dynamicListIsOnlyServer[actionData.listId] and pg.component == "game" and actionData.isSendMsgToClient then
			ownerEntity:allClientsMsgNoGC("RPC_SC_ChangeDynamicListMap", actionData.listId, ownerEntity.getEntityCacheVal and ownerEntity:getEntityCacheVal(actionData.listId) or {})
		end

		return false
	end

	table.remove(list, index)

	if ownerEntity.dynamicListIsOnlyServer and ownerEntity.dynamicListIsOnlyServer[actionData.listId] and pg.component == "game" and actionData.isSendMsgToClient then
		ownerEntity:allClientsMsgNoGC("RPC_SC_ChangeDynamicListMap", actionData.listId, ownerEntity.getEntityCacheVal and ownerEntity:getEntityCacheVal(actionData.listId) or {})
	end

	return true
end

function CombatAction:getDynamicListItem(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return
	end

	local list = ownerEntity.getEntityCacheVal and ownerEntity:getEntityCacheVal(actionData.listId)

	if not Utils.isTable(list) then
		CombatActionTool.logError(combatContext, actionData, "not type table", tostring(list))

		return false
	end

	return list[self:getVal(actionData.index, combatContext)]
end

function CombatAction:getDynamicListCount(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return
	end

	local list = ownerEntity.getEntityCacheVal and ownerEntity:getEntityCacheVal(actionData.listId)

	if not Utils.isTable(list) then
		CombatActionTool.logError(combatContext, actionData, "not type table", tostring(list))

		return 0
	end

	return #list
end

function CombatAction:getDynamicListLeastRepeatItem(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return
	end

	local list = ownerEntity.getEntityCacheVal and ownerEntity:getEntityCacheVal(actionData.listId)

	if not Utils.isTable(list) then
		CombatActionTool.logError(combatContext, actionData, "not type table", tostring(list))

		return nil
	end

	if #list == 0 then
		return nil
	end

	local countMap = {}

	for _, v in ipairs(list) do
		local key = tostring(v)

		countMap[key] = (countMap[key] or 0) + 1
	end

	local minCount = math.huge
	local minItem
	local minIndex = 0

	for i, v in ipairs(list) do
		local cnt = countMap[tostring(v)]

		if cnt < minCount then
			minCount = cnt
			minItem = v
			minIndex = i
		end
	end

	return minItem
end

function CombatAction:getDynamicListMostRepeatItem(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return nil
	end

	local list = ownerEntity.getEntityCacheVal and ownerEntity:getEntityCacheVal(actionData.listId)

	if not Utils.isTable(list) then
		CombatActionTool.logError(combatContext, actionData, "not type table", tostring(list))

		return nil
	end

	if #list == 0 then
		return nil
	end

	local countMap = {}

	for _, v in ipairs(list) do
		local key = tostring(v)

		countMap[key] = (countMap[key] or 0) + 1
	end

	local maxCount = 0
	local maxItem

	for i, v in ipairs(list) do
		local cnt = countMap[tostring(v)]

		if maxCount < cnt then
			maxCount = cnt
			maxItem = v
		end
	end

	return maxItem
end

function CombatAction:getDynamicListMaxRepeatCount(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return 0
	end

	local list = ownerEntity.getEntityCacheVal and ownerEntity:getEntityCacheVal(actionData.listId)

	if not Utils.isTable(list) then
		CombatActionTool.logError(combatContext, actionData, "not type table", tostring(list))

		return 0
	end

	if #list == 0 then
		return 0
	end

	local countMap = {}

	for _, v in ipairs(list) do
		local key = tostring(v)

		countMap[key] = (countMap[key] or 0) + 1
	end

	local maxCount = 0

	for _, cnt in pairs(countMap) do
		if maxCount < cnt then
			maxCount = cnt
		end
	end

	return maxCount
end

function CombatAction:checkVoxel(actionData, combatContext)
	local actions = actionData.actions

	if not actions then
		return
	end

	local checkTag = AbilityConst.TAG_STR_TO_NUM[actionData.check_tag]
	local targetData = actionData.target

	if checkTag == nil then
		CombatLogger.error("@jqj check_tag is nil", actionData.check_tag)

		return
	end

	local casterEntity = CombatActionTool.getCasterEnt(combatContext)

	if not casterEntity or not casterEntity.space then
		return false
	end

	local checkSuccess = false

	if casterEntity.abilityOverrideVoxelState ~= 0 then
		if checkTag == casterEntity.abilityOverrideVoxelState then
			local shape = CombatActionTool.getShape(AbilityConst.LX_GEOMETRY_TYPE_PARSER[targetData.shapeKind], targetData.shapeArgs)

			for _, element in pairs(AbilityConst.TAG_ABILITY_ELEMENT_LIST) do
				checkSuccess = pg.world.checkVoxelSpanByTag(casterEntity.space.id, AbilityConst.LX_GEOMETRY_TYPE_PARSER[targetData.shapeKind], shape, element)

				if checkSuccess then
					break
				end
			end

			CombatActionTool.returnShape(shape)
		else
			return false
		end
	else
		local shape = CombatActionTool.getShape(AbilityConst.LX_GEOMETRY_TYPE_PARSER[targetData.shapeKind], targetData.shapeArgs)

		checkSuccess = pg.world.checkVoxelSpanByTag(casterEntity.space.id, AbilityConst.LX_GEOMETRY_TYPE_PARSER[targetData.shapeKind], shape, checkTag)

		CombatActionTool.returnShape(shape)
	end

	if checkSuccess then
		for _, action in ipairs(actions) do
			self:doAction(action, combatContext)
		end
	end
end

function CombatAction:conditionOr(actionData, combatContext)
	for _, actionId in ipairs(actionData.conditionIds) do
		if ToBool(self:doActionById(actionId, combatContext)) then
			return true
		end
	end

	return false
end

function CombatAction:conditionAnd(actionData, combatContext)
	for _, actionId in ipairs(actionData.conditionIds) do
		if not ToBool(self:doActionById(actionId, combatContext)) then
			return false
		end
	end

	return true
end

function CombatAction:hasEntityTag(actionData, combatContext)
	local targetEnt = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEnt then
		return false
	end

	if Utils.hasEntityTag(targetEnt, actionData.entityTag) then
		return true
	end

	if not actionData.radius or actionData.radius <= 0 then
		return false
	end

	local tmpList = ListPool.getList(2)
	local cnt = targetEnt:entitiesInRangeWithTable(actionData.radius, Const.SEARCH_USR_TYPE_ACTOR_CREATION, 10, tmpList)

	for i = 1, cnt do
		local ent = pg.getEntityByActorId(tmpList[i])

		if ent and Utils.hasEntityTag(ent, actionData.entityTag) then
			ListPool.returnList(tmpList)

			return true
		end
	end

	ListPool.returnList(tmpList, 2)

	return false
end

function CombatAction:getWaterAbsorbCount(actionData, combatContext)
	if combatContext.waterAbsorbCount then
		return combatContext.waterAbsorbCount
	end

	if combatContext.eventData and combatContext.eventData[AbilityConst.COMBAT_EVENT_ON_WATER_ABSORB] then
		return combatContext.eventData[AbilityConst.COMBAT_EVENT_ON_WATER_ABSORB].waterAbsorbCount
	end

	CombatActionTool.logError(combatContext, actionData, "waterAbsorbCount not found")

	return 0
end

function CombatAction:getBodySize(actionData, combatContext)
	local target = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	return target and target.bodySize or 0
end

function CombatAction:notifyEvent(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if targetEntity and targetEntity.subject then
		targetEntity.subject:notify(actionData.eventName, combatContext)
	end
end

function CombatAction:registerFlyStateChangeEvent(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("target not found", actionData.target)
		end

		return false
	end

	if actionData.enterActionIds or actionData.exitActionIds then
		local observer = CombatActionTool.getContextObserver(combatContext)

		if observer then
			local copyCombatContext = combatContext:clone()

			observer:listen(targetEntity.subject, AbilityConst.COMBAT_EVENT_ON_FLY_STATE_CHANGE, function(isEnterFlying)
				if isEnterFlying then
					if actionData.enterActionIds then
						for idx = 1, #actionData.enterActionIds do
							self:doActionById(actionData.enterActionIds[idx], copyCombatContext)
						end
					end
				elseif actionData.exitActionIds then
					for idx = 1, #actionData.exitActionIds do
						self:doActionById(actionData.exitActionIds[idx], copyCombatContext)
					end
				end
			end)
		end
	end
end

function CombatAction:registerInflateChangeEvent(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("target not found", actionData.target)
		end

		return false
	end

	if actionData.enterActionIds or actionData.exitActionIds then
		local observer = CombatActionTool.getContextObserver(combatContext)

		if observer then
			local copyCombatContext = combatContext:clone()

			observer:listen(targetEntity.subject, AbilityConst.COMBAT_EVENT_ON_INFLATE_STATE_CHANGE, function(state)
				if state then
					if actionData.enterActionIds then
						for idx = 1, #actionData.enterActionIds do
							self:doActionById(actionData.enterActionIds[idx], copyCombatContext)
						end
					end
				elseif actionData.exitActionIds then
					for idx = 1, #actionData.exitActionIds do
						self:doActionById(actionData.exitActionIds[idx], copyCombatContext)
					end
				end
			end)
		end
	end
end

function CombatAction:getMainElementType(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	return targetEntity and targetEntity.mainElementType or 0
end

function CombatAction:getMainElementName(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))
	local mainElement = targetEntity and targetEntity.mainElementType or 0

	return ElementPropData[mainElement] and ElementPropData[mainElement].name or nil
end

function CombatAction:checkAbilityElementType(actionData, combatContext)
	if ToBool(combatContext.eventData) then
		for _, eventCombatContext in pairs(combatContext.eventData) do
			if type(eventCombatContext) == "table" and eventCombatContext.className == "CombatContext" then
				combatContext = eventCombatContext

				break
			end
		end
	end

	local ability = CombatActionTool.getCasterAbility(combatContext)

	if not ability then
		return false
	end

	return pg.global.abilityMgr:getAbilityParamData(ability.abilityId).elementType == actionData.elementType
end

function CombatAction:doActionByIndex(actionData, combatContext)
	local list = combatContext.nodeMap[actionData.actionsListId].list
	local index = Utils.isTable(actionData.index) and self:doAction(actionData.index, combatContext) or actionData.index
	local action = list and list[index]

	if action then
		return self:doAction(action, combatContext)
	end

	return false
end

function CombatAction:registerAddBuffEvent(actionData, combatContext)
	local observer = CombatActionTool.getContextObserver(combatContext)

	if not observer then
		return false
	end

	local targetEntity = CombatActionTool.getRegisterEventSubjectEntity(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)

	if not targetEntity then
		return false
	end

	local copyCombatContext = combatContext:clone()

	observer:listen(targetEntity.subject, AbilityConst.COMBAT_EVENT_ON_ADD_NEW_BUFF, function(combatContext)
		copyCombatContext:setEventData(AbilityConst.COMBAT_EVENT_ON_ADD_NEW_BUFF, combatContext)
		self:doActions(actionData, copyCombatContext)
		copyCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_ON_ADD_NEW_BUFF)
	end)

	return true
end

function CombatAction:registerMergeBuffEvent(actionData, combatContext)
	local observer = CombatActionTool.getContextObserver(combatContext)

	if not observer then
		return false
	end

	local targetEntity = CombatActionTool.getRegisterEventSubjectEntity(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)

	if not targetEntity then
		return false
	end

	local copyCombatContext = combatContext:clone()

	observer:listen(targetEntity.subject, AbilityConst.COMBAT_EVENT_ON_MERGE_BUFF, function(combatContext)
		copyCombatContext:setEventData(AbilityConst.COMBAT_EVENT_ON_MERGE_BUFF, combatContext)
		self:doActions(actionData, copyCombatContext)
		copyCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_ON_MERGE_BUFF)
	end)

	return true
end

function CombatAction:registerBuffLifeEvent(actionData, combatContext)
	local target = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_TARGET))

	if not target then
		return false
	end

	local buffId = self:getVal(actionData.buffId, combatContext)

	if not buffId or buffId == 0 then
		return false
	end

	local observer = CombatActionTool.getContextObserver(combatContext)

	if not observer then
		return false
	end

	local copyCombatContext = combatContext:clone()

	observer:listen(target.subject, AbilityConst.COMBAT_EVENT_ON_BUFF_LIFE, function(eventType, buffId2)
		if buffId2 ~= buffId then
			return
		end

		if eventType == AbilityConst.BUFF_LIFE_EVENT_TYPE.START and not actionData.isListenStart then
			return
		elseif eventType == AbilityConst.BUFF_LIFE_EVENT_TYPE.LAYER_INCREASE and not actionData.isListenLayerIncrease then
			return
		elseif eventType == AbilityConst.BUFF_LIFE_EVENT_TYPE.LAYER_DECREASE and not actionData.isListenLayerDecrease then
			return
		elseif eventType == AbilityConst.BUFF_LIFE_EVENT_TYPE.DESTROY and not actionData.isListenDestroy then
			return
		end

		self:doActions(actionData, copyCombatContext)
	end)

	return true
end

function CombatAction:registerAddBuffOnTargetEvent(actionData, combatContext)
	local observer = CombatActionTool.getContextObserver(combatContext)

	if not observer then
		return false
	end

	local targetEntity = CombatActionTool.getRegisterEventSubjectEntity(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)

	if not targetEntity then
		return false
	end

	local copyCombatContext = combatContext:clone()
	local buffTemplateIds = actionData.buffTemplateIds
	local needCheckTemplateId = ToBool(buffTemplateIds)
	local onlyCheckNewBuff = actionData.onlyCheckNewBuff

	observer:listen(targetEntity.subject, AbilityConst.COMBAT_EVENT_ON_ADD_BUFF_ON_TARGET, function(combatContext, targetActorId, buffTemplateId, isNewAdd)
		if onlyCheckNewBuff and not isNewAdd then
			return
		end

		local contains = not needCheckTemplateId

		if needCheckTemplateId then
			for _, templateId in ipairs(buffTemplateIds) do
				if templateId == buffTemplateId then
					contains = true

					break
				end
			end
		end

		if not contains then
			return
		end

		copyCombatContext:setEventData(AbilityConst.COMBAT_EVENT_ON_ADD_BUFF_ON_TARGET, {
			eventCombatContext = combatContext,
			targetActorId = targetActorId,
			buffTemplateId = buffTemplateId
		})
		self:doActions(actionData, copyCombatContext)
		copyCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_ON_ADD_BUFF_ON_TARGET)
	end)

	return true
end

function CombatAction:isTempPetTeam(actionData, combatContext)
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)
	local player = AbilityUtils.getPlayer(ownerEntity)

	if player then
		return player.petTeamType ~= Const.PET_TEAM_TYPE_DEFAULT
	end

	return false
end

function CombatAction:isExtraTempPet(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	return targetEntity and targetEntity.isExtraTempPet and targetEntity:isExtraTempPet()
end

function CombatAction:registerRoguePersistDataChange(actionData, combatContext)
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	local copyCombatContext = combatContext:clone()
	local player = Utils.getMasterPlayer(abilityObject.owner)

	if not player then
		CombatActionTool.logDebug(combatContext, "player not found")

		return false
	end

	local cumulativeCount = self:getVal(actionData.cumulativeCount, combatContext)
	local cumulateChangeCount = 0

	abilityObject:getObserver():listen(player.subject, AbilityConst.COMBAT_EVENT_ON_ROGUE_PERSIST_DATA_CHANGE, function(key, changeVal)
		if key ~= actionData.key then
			return
		end

		copyCombatContext:setEventData(AbilityConst.COMBAT_EVENT_ON_ROGUE_PERSIST_DATA_CHANGE, changeVal)

		if changeVal > 0 then
			cumulateChangeCount = cumulateChangeCount + changeVal

			self:doActions(actionData, copyCombatContext)

			if actionData.cumulativeCountActionIds and cumulativeCount then
				while cumulateChangeCount >= cumulativeCount do
					cumulateChangeCount = cumulateChangeCount - cumulativeCount

					self:doActionIds(actionData.cumulativeCountActionIds, copyCombatContext)
				end
			end
		elseif changeVal < 0 and actionData.responseNegative then
			self:doActions(actionData, copyCombatContext)
		end
	end)
end

function CombatAction:getRoguePersistData(actionData, combatContext)
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)
	local player = Utils.getMasterPlayer(ownerEntity)

	if not player or not player.rogueCombatData then
		CombatActionTool.logDebug(combatContext, "player not found")

		return 0
	end

	if actionData.key == AbilityConst.ROGUE_BATTLE_DATA_KEY.SKILL_EP_MAX then
		return player.rogueCombatData[actionData.key] or 100
	end

	return player.rogueCombatData[actionData.key] or 0
end

function CombatAction:getProjectileId(actionData, combatContext)
	local projectile

	if actionData.projectileAction then
		projectile = self:doActionById(actionData.projectileAction, combatContext)
	else
		projectile = combatContext:projectile()
	end

	return projectile and projectile.instanceId or 0
end

function CombatAction:searchEntity(actionData, combatContext)
	local radius = actionData.radius
	local heightUp = actionData.heightUp
	local heightDown = actionData.heightDown
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)

	if not ownerEntity then
		return 0
	end

	local ent
	local checkValidPlayer = actionData.checkValidPlayer

	if actionData.isRandom == true then
		ent = AbilityUtils.searchRandomEntity(ownerEntity, radius, actionData.relation, heightDown, heightUp, actionData.filterCondition, actionData.checkValidLock, combatContext, checkValidPlayer)
	else
		ent = AbilityUtils.searchClosestEntity(ownerEntity, radius, actionData.relation, heightDown, heightUp, actionData.filterCondition, actionData.checkValidLock, combatContext, checkValidPlayer)
	end

	return ent and ent.actorId or 0
end

function CombatAction:registerRogueCoinChange(actionData, combatContext)
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	local copyCombatContext = combatContext:clone()

	abilityObject:getObserver():listen(abilityObject.owner.subject, AbilityConst.COMBAT_EVENT_ON_ROGUE_COIN_CHANGE, function(addValue)
		copyCombatContext:setEventData(AbilityConst.COMBAT_EVENT_ON_ROGUE_COIN_CHANGE, addValue)
		self:doActions(actionData, copyCombatContext)
		copyCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_ON_ROGUE_COIN_CHANGE)
	end)
end

function CombatAction:setProjAroundSelfData(actionData, combatContext)
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)

	if ownerEntity.setProjAroundSelf then
		ownerEntity:setProjAroundSelf(actionData, combatContext)
	end

	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	abilityObject:addExitCallback(function()
		if ownerEntity.clearProjAroundSelf then
			ownerEntity:clearProjAroundSelf()
		end
	end)

	return true
end

function CombatAction:getEventReceiveDamageAttackTarget(actionData, combatContext)
	local eventCombatContext = combatContext.eventData and combatContext.eventData[AbilityConst.COMBAT_EVENT_RECEIVE_DAMAGE]
	local casterEnt = CombatActionTool.getCasterEnt(eventCombatContext)

	return casterEnt and casterEnt.actorId or 0
end

function CombatAction:registerCharacterStateChangeEvent(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("target not found", actionData.target)
		end

		return false
	end

	if actionData.actionIds then
		local observer = CombatActionTool.getContextObserver(combatContext)

		if observer then
			local copyCombatContext = combatContext:clone()

			observer:listen(targetEntity.subject, AbilityConst.COMBAT_EVENT_ON_CHARACTER_STATE_CHANGE, function(oldState, newState)
				copyCombatContext:setEventData(AbilityConst.ON_CHARACTER_STATE_CHANGE_OLD_STATE, oldState)
				copyCombatContext:setEventData(AbilityConst.ON_CHARACTER_STATE_CHANGE_NEW_STATE, newState)
				self:doActions(actionData, copyCombatContext)
				copyCombatContext:clearEventData(AbilityConst.ON_CHARACTER_STATE_CHANGE_OLD_STATE)
				copyCombatContext:clearEventData(AbilityConst.ON_CHARACTER_STATE_CHANGE_NEW_STATE)
			end)
		end
	end
end

function CombatAction:isEnterCharacterState(actionData, combatContext)
	local characterStates = actionData.characterState
	local oldState = combatContext.eventData and combatContext.eventData[AbilityConst.ON_CHARACTER_STATE_CHANGE_OLD_STATE]
	local newState = combatContext.eventData and combatContext.eventData[AbilityConst.ON_CHARACTER_STATE_CHANGE_NEW_STATE]

	for _, characterState in ipairs(characterStates) do
		characterState = CharacterStateConst[characterState]

		if CharacterStateConst.isChildOfState(newState, characterState) and not CharacterStateConst.isChildOfState(oldState, characterState) then
			return true
		end
	end

	return false
end

function CombatAction:isLeaveCharacterState(actionData, combatContext)
	local characterStates = actionData.characterState
	local oldState = combatContext.eventData and combatContext.eventData[AbilityConst.ON_CHARACTER_STATE_CHANGE_OLD_STATE]
	local newState = combatContext.eventData and combatContext.eventData[AbilityConst.ON_CHARACTER_STATE_CHANGE_NEW_STATE]

	for _, characterState in ipairs(characterStates) do
		characterState = CharacterStateConst[characterState]

		if not CharacterStateConst.isChildOfState(newState, characterState) and CharacterStateConst.isChildOfState(oldState, characterState) then
			return true
		end
	end

	return false
end

function CombatAction:getBuffSeriesCnt(actionData, combatContext)
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)

	if not ownerEntity then
		return 0
	end

	return ownerEntity.buffSeriesCntMap[actionData.buffSeries] or 0
end

function CombatAction:getRogueCoinCnt(actionData, combatContext)
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)
	local player = Utils.getMasterPlayer(ownerEntity)

	if player then
		return player.commonMoneyNums[ItemConst.ITEM_SPECIAL_ROGUE_COIN] or 0
	end

	return 0
end

function CombatAction:div(actionData, combatContext)
	local lValue = self:doAction(actionData.lValue, combatContext) or 0
	local rValue = self:doAction(actionData.rValue, combatContext)

	if ToBool(rValue) then
		return lValue / rValue
	end

	return 0
end

function CombatAction:toInt(actionData, combatContext)
	local val = self:doAction(actionData.val, combatContext)

	if type(val) ~= "number" then
		return 0
	end

	if actionData.convertType == 0 then
		return math.ceil(val)
	elseif actionData.convertType == 1 then
		return math.floor(val)
	else
		return math.floor(val + 0.5)
	end
end

function CombatAction:doPlayerTeamActions(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	local masterEntity = Utils.convertPlayerEntity(ownerEntity)

	if not masterEntity then
		return false
	end

	local memberInfo

	if masterEntity.isInDungeonTeam and masterEntity:isInDungeonTeam() then
		if masterEntity.getCurDungeonTeamMemberInfo then
			memberInfo = masterEntity:getCurDungeonTeamMemberInfo()
		elseif masterEntity.getCurTeamMemberInfo then
			memberInfo = masterEntity:getCurTeamMemberInfo()
		end
	elseif masterEntity.isInTeam and masterEntity:isInTeam() then
		if masterEntity.getCurTeamMemberInfo then
			memberInfo = masterEntity:getCurTeamMemberInfo()
		elseif masterEntity.teamInfo then
			memberInfo = masterEntity.teamInfo.membersInfo
		end
	end

	if ToBool(memberInfo) then
		local ignoreSpaceCheck = actionData.ignoreSpaceCheck

		for _, info in pairs(memberInfo) do
			local teamMemberEntity = pg.getEntity(info.entityId)
			local teamMemberValid = teamMemberEntity ~= nil

			if teamMemberValid and not ignoreSpaceCheck then
				teamMemberValid = teamMemberEntity.space == masterEntity.space and Vector3.SqrDistance(teamMemberEntity:getPosition(), masterEntity:getPosition()) < 14400
			end

			if teamMemberValid then
				local runtimeTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:get(true)
				local guardVal = GuardValue(combatContext, "runtimeTargetInfo", runtimeTargetInfo)

				runtimeTargetInfo:initTarget(teamMemberEntity.actorId, teamMemberEntity:getPosition(), 1, 0)
				self:doActions(actionData, combatContext)
				guardVal:recover()
				pg.global.abilityMgr.runtimeTargetInfoPool:returnObject(runtimeTargetInfo)
			end
		end
	else
		local runtimeTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:get(true)
		local guardVal = GuardValue(combatContext, "runtimeTargetInfo", runtimeTargetInfo)

		runtimeTargetInfo:initTarget(masterEntity.actorId, masterEntity:getPosition(), 1, 0)
		self:doActions(actionData, combatContext)
		guardVal:recover()
		pg.global.abilityMgr.runtimeTargetInfoPool:returnObject(runtimeTargetInfo)
	end

	return true
end

function CombatAction:enterSpeedBurst(actionData, combatContext)
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)

	ownerEntity.speedBurstData = {
		duration = actionData.duration
	}

	if actionData.startActionIds then
		self:doActionIds(actionData.startActionIds, combatContext)
	end

	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	local combatContextCopy = combatContext:clone()

	local function exitFunction()
		ownerEntity.needTriggerSpeedBurstExit = nil

		if ownerEntity.setRePressAbilitySlotInfo then
			ownerEntity:setRePressAbilitySlotInfo(combatContext.abilityId)
		end

		self:doActionIds(actionData.exitActinIds, combatContextCopy)

		if ownerEntity.switchSkill then
			ownerEntity:switchSkill(combatContext.abilityId, combatContext.abilityId, 0)
		end

		if ownerEntity.refreshStepHeight then
			ownerEntity:refreshStepHeight()

			ownerEntity.rePressSkillSlotInfo[combatContext.abilityId] = nil
		end

		if ownerEntity.stopEffect then
			ownerEntity:stopEffect("Eff_Parmon_Common_ExploreSkill_SpeedBurst_Start")
			ownerEntity:stopEffect("Eff_Parmon_Common_ExploreSkill_SpeedBurst_Loop")
			ownerEntity:stopEffect("Eff_Parmon_Common_ExploreSkill_SpeedBurst_End")
		end
	end

	ownerEntity.needTriggerSpeedBurstExit = true

	abilityObject:getObserver():listen(abilityObject.owner.subject, AbilityConst.COMBAT_EVENT_ON_CHARACTER_STATE_CHANGE, function(oldState, newState)
		if newState == CharacterStateConst.SPEEDBURSTLOOP then
			if ownerEntity.setActionMask then
				ownerEntity:setActionMask(AbilityConst.ACTION_MASK_IN_CAST, false, combatContextCopy.abilityId)
			end

			self:doActionIds(actionData.loopActionIds, combatContextCopy)

			return
		end

		if newState == CharacterStateConst.SPEEDBURSTEND then
			self:doActionIds(actionData.endActionIds, combatContextCopy)

			if ownerEntity.switchSkill then
				ownerEntity:switchSkill(combatContext.abilityId, combatContext.abilityId, 0)
			end

			return
		end

		if CharacterStateConst.isChildOfState(oldState, CharacterStateConst.SPEEDBURST) and not CharacterStateConst.isChildOfState(newState, CharacterStateConst.SPEEDBURST) and ownerEntity.needTriggerSpeedBurstExit then
			exitFunction()

			return
		end
	end)
	abilityObject:addExitCallback(function()
		if ownerEntity.characterState == CharacterStateConst.SPEEDBURSTLOOP or ownerEntity.characterState == CharacterStateConst.SPEEDBURSTSTART then
			AnimationUtils.playAnimationState(ownerEntity, CharacterStateConst.SPEEDBURSTEND)
		elseif CharacterStateConst.isChildOfState(ownerEntity.characterState, CharacterStateConst.SPEEDBURST) then
			AnimationUtils.playAnimationState(ownerEntity, CharacterStateConst.IDLE)
		end

		if ownerEntity.needTriggerSpeedBurstExit then
			exitFunction()
		end

		if ownerEntity.refreshStepHeight then
			ownerEntity:refreshStepHeight()
		end
	end)

	return true
end

function CombatAction:registerPetLeaveControlEvent(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("target not found")
		end

		return false
	end

	if not Utils.isPet(targetEntity) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("target should be Pet!", targetEntity.actorId)
		end

		return false
	end

	local observer = CombatActionTool.getContextObserver(combatContext)

	if observer then
		local copyCombatContext = combatContext:clone()

		observer:listen(targetEntity.subject, AbilityConst.COMBAT_EVENT_ON_PET_LEAVE_CONTROL, function()
			self:doActions(actionData, copyCombatContext)
		end)
	end
end

function CombatAction:registerPetEnterControlEvent(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return false
	end

	if not Utils.isPet(targetEntity) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("target should be Pet!", targetEntity.actorId)
		end

		return false
	end

	local observer = CombatActionTool.getContextObserver(combatContext)

	if observer then
		local copyCombatContext = combatContext:clone()

		observer:listen(targetEntity.subject, AbilityConst.COMBAT_EVENT_ON_PET_ENTER_CONTROL, function()
			self:doActions(actionData, copyCombatContext)
		end)
	end
end

function CombatAction:registerPawnMovedDistanceReachThresholdEvent(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("target not found")
		end

		return false
	end

	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	local observer = abilityObject:getObserver()

	if not observer then
		return false
	end

	targetEntity:setEntityCacheVal(AbilityConst.COMBAT_EVENT_ON_PAWN_MOVED_DISTANCE_REACH_THRESHOLD, {
		hasMovedDistance = 0,
		threshold = actionData.threshold,
		onlyConsiderXZ = actionData.onlyConsiderXZ
	})

	local copyCombatContext = combatContext:clone()

	observer:listen(targetEntity.subject, AbilityConst.COMBAT_EVENT_ON_PAWN_MOVED_DISTANCE_REACH_THRESHOLD, function()
		self:doActions(actionData, copyCombatContext)
	end)

	if Utils.checkClient() and not Utils.isServerPuppet(targetEntity) then
		local func = targetEntity.DC_OnKCCMove

		if func then
			targetEntity.onKCCMovedAbilityRefCnt = (targetEntity.onKCCMovedAbilityRefCnt or 0) + 1

			local eModel = targetEntity.eModel

			if eModel.onKCCMoved == nil then
				function eModel.onKCCMoved(velocity)
					func(targetEntity, velocity)
				end
			end

			abilityObject:addExitCallback(function()
				targetEntity.onKCCMovedAbilityRefCnt = math.max(targetEntity.onKCCMovedAbilityRefCnt - 1, 0)

				if not targetEntity.beControlled and targetEntity.onKCCMovedAbilityRefCnt == 0 then
					eModel.onKCCMoved = nil
				end
			end)
		end
	end
end

function CombatAction:getLevel(actionData, combatContext)
	local targetType = actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER
	local targetEnt = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, targetType))

	return targetEnt and targetEnt.level or 0
end

function CombatAction:registerInflateChangeEvent(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("target not found", actionData.target)
		end

		return false
	end

	if actionData.enterActionIds or actionData.exitActionIds then
		local observer = CombatActionTool.getContextObserver(combatContext)

		if observer then
			local copyCombatContext = combatContext:clone()

			observer:listen(targetEntity.subject, AbilityConst.COMBAT_EVENT_ON_INFLATE_STATE_CHANGE, function(state)
				if state then
					if actionData.enterActionIds then
						for idx = 1, #actionData.enterActionIds do
							self:doActionById(actionData.enterActionIds[idx], copyCombatContext)
						end
					end
				elseif actionData.exitActionIds then
					for idx = 1, #actionData.exitActionIds do
						self:doActionById(actionData.exitActionIds[idx], copyCombatContext)
					end
				end
			end)
		end
	end
end

function CombatAction:checkReceiveAttackDirInAngleRange(actionData, combatContext)
	local eventCombatContext = combatContext.eventData and (combatContext.eventData[AbilityConst.COMBAT_EVENT_RECEIVE_BE_ATTACKED] or combatContext.eventData[AbilityConst.COMBAT_EVENT_RECEIVE_DAMAGE])

	if eventCombatContext then
		local targetEntity = CombatActionTool.getOwnerEntity(combatContext)
		local hitPos = eventCombatContext.runtimeTargetInfo and eventCombatContext.runtimeTargetInfo.hitPos

		if hitPos then
			local dir = hitPos - targetEntity:getPosition()

			dir:SetNormalize()

			local targetForward = targetEntity:getRotation():MulVec3(VEC3_CONST_FORWARD)

			targetForward:SetNormalize()

			local cosTheta = dir.x * targetForward.x + dir.z * targetForward.z
			local isVectorLeft = Vector3.Cross(targetForward, dir).y

			if isVectorLeft > 0 then
				local leftStartAngle = actionData.leftStartAngle
				local leftEndAngle = actionData.leftEndAngle

				if cosTheta <= math.cos(math.rad(leftStartAngle)) and cosTheta > math.cos(math.rad(leftEndAngle)) then
					return true
				end
			else
				local rightStartAngle = actionData.rightStartAngle
				local rightEndAngle = actionData.rightEndAngle

				if cosTheta < math.cos(math.rad(rightStartAngle)) and cosTheta >= math.cos(math.rad(rightEndAngle)) then
					return true
				end
			end
		end
	end

	return false
end

function CombatAction:checkReceiveProjectileAttack(actionData, combatContext)
	local eventCombatContext = combatContext.eventData and (combatContext.eventData[AbilityConst.COMBAT_EVENT_RECEIVE_BE_ATTACKED] or combatContext.eventData[AbilityConst.COMBAT_EVENT_RECEIVE_DAMAGE])

	if eventCombatContext then
		local projectile = eventCombatContext:projectile()

		if projectile then
			return true
		end
	end

	return false
end

function CombatAction:isTargetAlive(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if not targetEntity or not targetEntity.isAlive then
		return false
	end

	return targetEntity:isAlive()
end

function CombatAction:getTargetConfigData(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if not targetEntity then
		return nil
	end

	return targetEntity:getConfigData()
end

function CombatAction:isEventBuffHasTag(actionData, combatContext)
	local checkTag = actionData.tag
	local eventData = combatContext.eventData and combatContext.eventData[AbilityConst.COMBAT_EVENT_ON_ADD_BUFF_ON_TARGET] or nil

	if eventData and eventData.buffTemplateId then
		local buffLevelTemplate = pg.global.abilityMgr:getBuffTemplate(eventData.buffTemplateId)

		if buffLevelTemplate then
			local tagIds = buffLevelTemplate.tags

			if not tagIds then
				return false
			end

			if table.contains(tagIds, checkTag) then
				return true
			end
		end
	end

	return false
end

function CombatAction:isEventBuffInTagGroup(actionData, combatContext)
	local eventData = combatContext.eventData and combatContext.eventData[AbilityConst.COMBAT_EVENT_ON_ADD_BUFF_ON_TARGET] or nil

	if eventData and eventData.buffTemplateId then
		local buffLevelTemplate = pg.global.abilityMgr:getBuffTemplate(eventData.buffTemplateId)

		if buffLevelTemplate then
			local tagIds = buffLevelTemplate.tags

			if not tagIds then
				return false
			end

			local tags = BuffTagGroupData.BUFF_TAG_GROUP_PARSER[actionData.buffTagGroup]

			if tags then
				for _, tagId in ipairs(tagIds) do
					if table.contains(tags, tagId) then
						return true
					end
				end
			end
		end
	end

	return false
end

function CombatAction:inActionMask(actionData, combatContext)
	local target = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	return target and target.getActionMask and target:getActionMask(actionData.actionMask)
end

function CombatAction:isInSkipCutscene(actionData, combatContext)
	return ToBool(combatContext.isCutSceneFastForwarding)
end

function CombatAction:registerOnTriggerPerfectCounterEvent(actionData, combatContext)
	local owner = CombatActionTool.getRegisterEventSubjectEntity(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local observer = CombatActionTool.getContextObserver(combatContext)

	if observer then
		local copyCombatContext = combatContext:clone()

		observer:listen(owner.subject, AbilityConst.COMBAT_EVENT_ON_TRIGGER_PERFECT_COUNTER, function()
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				CombatLogger.debug("@hyj CombatAction[registerOnTriggerPerfectCounterEvent]: onTriggerPerfectCounter")
			end

			self:doActions(actionData, copyCombatContext)
		end)
	end
end

function CombatAction:registerBePerfectCounteredEvent(actionData, combatContext)
	local owner = CombatActionTool.getRegisterEventSubjectEntity(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local observer = CombatActionTool.getContextObserver(combatContext)

	if observer then
		local copyCombatContext = combatContext:clone()

		observer:listen(owner.subject, AbilityConst.COMBAT_EVENT_BE_PERFECT_COUNTERED, function(eventCombatContext)
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				CombatLogger.debug("@hyj CombatAction[registerBePerfectCounteredEvent]: bePerfectCountered")
			end

			copyCombatContext:setEventData(AbilityConst.COMBAT_EVENT_BE_PERFECT_COUNTERED, eventCombatContext)
			self:doActions(actionData, copyCombatContext)
			copyCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_BE_PERFECT_COUNTERED)
		end)
	end
end

function CombatAction:registerBeNormalCounteredEvent(actionData, combatContext)
	local owner = CombatActionTool.getRegisterEventSubjectEntity(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local observer = CombatActionTool.getContextObserver(combatContext)

	if observer then
		local copyCombatContext = combatContext:clone()

		observer:listen(owner.subject, AbilityConst.COMBAT_EVENT_BE_NORMAL_COUNTERED, function(eventCombatContext)
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				CombatLogger.debug("@hyj CombatAction[registerBeNormalCounteredEvent]: beNormalCountered")
			end

			copyCombatContext:setEventData(AbilityConst.COMBAT_EVENT_BE_NORMAL_COUNTERED, eventCombatContext)
			self:doActions(actionData, copyCombatContext)
			copyCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_BE_NORMAL_COUNTERED)
		end)
	end
end

function CombatAction:isTargetInDefensiveCounterState(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	return targetEntity and ToBool(targetEntity.isInDefensiveCounterST) or false
end

function CombatAction:getBuffShieldPoint(actionData, combatContext)
	local buff = combatContext:buff()

	if not buff then
		return 0
	end

	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)

	if not ownerEntity then
		return 0
	end

	return ownerEntity.shieldDataList:getCurPoint(ownerEntity, buff.buffData.instanceId)
end

function CombatAction:setCombatActionTimeline(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if targetEntity == nil then
		return false
	end

	if targetEntity.authority ~= Const.AUTHORITY_MASTER then
		return false
	end

	local srcAbility = CombatActionTool.getCasterAbility(combatContext)
	local abilityId = srcAbility and srcAbility.abilityId or 0
	local realTimelineId = self:getVal(actionData.timelineId, combatContext)
	local realPlayRate = actionData.playRate or 1
	local attackSpeed = combatContext.attackSpeed or 1

	realPlayRate = realPlayRate * attackSpeed

	local combatActionTimelineParam = pg.global.abilityMgr.combatParamsPool:get(true)

	combatActionTimelineParam.combatContextId = targetEntity:genCombatContextId()
	combatActionTimelineParam.attackSpeed = attackSpeed

	local castingCombatContextId

	if combatContext.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_ABILITY then
		castingCombatContextId = combatActionTimelineParam.combatContextId

		if targetEntity.startHitTriggerRecord then
			targetEntity:startHitTriggerRecord(castingCombatContextId, combatContext)
		end
	else
		castingCombatContextId = combatContext.castingCombatContextId
	end

	combatActionTimelineParam.castingCombatContextId = castingCombatContextId
	combatActionTimelineParam.srcActorId = combatContext.constCasterInfo and combatContext.constCasterInfo.actorId or CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	combatActionTimelineParam.srcAbilityId = abilityId
	combatActionTimelineParam.srcAbilityStoreType = combatContext.abilityStoreType
	combatActionTimelineParam.randomPointPos = combatContext.randomPointPos
	combatActionTimelineParam.targetActorId = combatContext.runtimeTargetInfo and combatContext.runtimeTargetInfo.actorId
	combatActionTimelineParam.hitPos = combatContext.runtimeTargetInfo and combatContext.runtimeTargetInfo.hitPos
	combatActionTimelineParam.hitDir = combatContext.runtimeTargetInfo and combatContext.runtimeTargetInfo.hitDir
	combatActionTimelineParam.hitIdx = combatContext.runtimeTargetInfo and combatContext.runtimeTargetInfo.hitIdx
	combatActionTimelineParam.srcType = combatContext.srcType
	combatActionTimelineParam.constCasterInfo = combatContext.constCasterInfo and combatContext.constCasterInfo:clone()

	local isFromDialogueGraph = combatContext.constCasterInfo and combatContext.constCasterInfo.castSource == AbilityConst.CAST_SOURCE.DIALOGUE_GRAPH

	if not isFromDialogueGraph then
		if pg.component == "client" then
			targetEntity:serverMsgNoGC("RPC_CS_SetCombatActionTimeline", realTimelineId, realPlayRate, combatActionTimelineParam, combatContext.id, combatContext.nodeStack or {})
		else
			targetEntity:allClientsMsgNoGC("RPC_SC_SetCombatActionTimeline", realTimelineId, realPlayRate, combatActionTimelineParam)
		end
	end

	if not targetEntity.actorTimeline:setTimeline(realTimelineId, realPlayRate, combatActionTimelineParam) then
		pg.global.abilityMgr.combatParamsPool:returnObject(combatActionTimelineParam)
	end

	return true
end

function CombatAction:jumpToNextTimeline(actionData, combatContext)
	local timelineId = actionData.timelineId
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj targetEntity not found", targetActorId)
		end

		return false
	end

	if targetEntity.authority ~= Const.AUTHORITY_MASTER then
		return false
	end

	local timeline = combatContext:timeline()

	if timeline == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatActionTool.logError(combatContext, actionData, "timeline not found")
		end

		return false
	end

	if timeline.isPlaying then
		local oldTimelineId = timeline.timelineId

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("RPC_CS_JumpToNextTimeline", targetEntity.actorId, timeline.layer, oldTimelineId, timelineId, combatContext.nodeStack)
		end

		local canJump = timeline:checkPushCmdToPending(AbilityConst.ACTION_TIMELINE_CMD_CONTINUE)

		if not canJump then
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				CombatLogger.debug("jumpToNextTimeline failed, current status cannot continue", targetActorId, timelineId)
			end

			return false
		end

		if pg.component == "client" then
			local ability = combatContext:ability()

			if ability and ability:isSwitchAbility() then
				targetEntity:serverMsgNoGC("RPC_CS_NotifySwitch", ability.abilityId, false)
			end

			targetEntity:serverMsgNoGC("RPC_CS_JumpToNextTimeline", timeline.layer, oldTimelineId, timelineId, combatContext.id, combatContext.nodeStack)
		else
			local ability = combatContext:ability()

			if ability and ability:isSwitchAbility() then
				targetEntity:notifySwitchAbility()
			end

			targetEntity:allClientsMsgNoGC("RPC_SC_JumpToNextTimeline", timeline.layer, oldTimelineId, timelineId)
		end

		timeline:continueTimeline(timelineId, timeline.playRate)
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		CombatLogger.error("@jqj CombatAction:jumpToNextTimeline failed", timeline, timeline.isPlaying)
	end

	return true
end

function CombatAction:stopActionTimeline(actionData, combatContext)
	local timelineId = actionData.timelineId
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj targetEntity not found", targetActorId)
		end

		return false
	end

	if targetEntity.authority ~= Const.AUTHORITY_MASTER then
		return false
	end

	local layer = actionData.layer

	if timelineId == nil or layer == nil then
		local timeline = combatContext:timeline()

		if timeline then
			if timelineId == nil then
				timelineId = timeline.timelineId
			end

			if layer == nil then
				layer = timeline.layer
			end
		end
	end

	if not ToBool(layer) then
		layer = AbilityConst.ACTION_TIMELINE_LAYER_BASE
	end

	timelineId = timelineId or 0

	if targetEntity.actorTimeline then
		if pg.component == "client" then
			targetEntity:serverMsgNoGC("RPC_CS_StopActionTimeline", layer, timelineId)
		else
			targetEntity:allClientsMsgNoGC("RPC_SC_StopActionTimeline", layer, timelineId)
		end

		targetEntity.actorTimeline:stopTimeline(layer, timelineId)
	elseif targetEntity.ballTimeline then
		targetEntity.ballTimeline:stopTimeline()
	end

	return true
end

function CombatAction:createProjectile(actionData, combatContext)
	local ability = CombatActionTool.getCasterAbility(combatContext)
	local ownerActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local ownerEntity = pg.getEntityByActorId(ownerActorId)

	if not ownerEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@hyj ownerEntity not found")
		end

		return false
	end

	local projectileMgr = ownerEntity.space and ownerEntity.space.projectileMgr

	if not projectileMgr then
		return false
	end

	if ownerEntity.authority ~= Const.AUTHORITY_MASTER then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("ownerEntity no authority", ownerEntity)
		end

		return false
	end

	local projectileType = actionData.projectileType
	local posType = actionData.pos
	local rotationType = actionData.rotation
	local offsetXYZ = actionData.offsetXYZ and (actionData.offsetXYZ.name == nil and Vector3(unpack(actionData.offsetXYZ)) or self:doAction(actionData.offsetXYZ, combatContext)) or Vector3(0, 0, 0)
	local offsetRotation = actionData.offsetRotation and (actionData.offsetRotation.name == nil and Vector3(unpack(actionData.offsetRotation)) or self:doAction(actionData.offsetRotation, combatContext)) or Vector3(0, 0, 0)

	if offsetRotation.w ~= nil then
		offsetRotation = Quaternion.ToEulerAngles(offsetRotation)
	end

	local originPos = ownerEntity:getPosition():Clone()

	CombatActionTool.parsePosition(combatContext, posType, originPos)

	local originRot = combatContext.overrideProjStartQua or ownerEntity:getRotation():Clone()

	CombatActionTool.parseRotation(combatContext, posType, originRot)

	local targetActorId = 0
	local targetPosType = actionData.targetPos
	local targetPos

	targetActorId, targetPos = CombatActionTool.getProjectileTargetInfo(combatContext, targetPosType, projectileType, originPos, originRot)

	local lastProjectile = combatContext:projectile()

	if lastProjectile ~= nil and not ToBool(targetActorId) then
		targetActorId = lastProjectile.targetActorId
	end

	local target = pg.getEntityByActorId(targetActorId)
	local oriScale = ownerEntity.curModelScale or 1
	local pos = combatContext.overrideProjStartPos or CombatActionTool.translatePoint(originPos, originRot, offsetXYZ * oriScale)
	local rotation = originRot:Clone()
	local projTemplate = pg.global.abilityMgr:getProjectileTemplate(actionData.templateId)
	local gravityRatio = projTemplate and projTemplate.gravityRatio and projTemplate.gravityRatio or 0

	if gravityRatio ~= 0 then
		combatContext.isProjectileHasGravity = true
	end

	CombatActionTool.parseRotationTowards(combatContext, rotationType, pos, rotation, {
		posType = actionData.rotationTowardsPos,
		targetRotation = actionData.targetRotation,
		targetPos = targetPos
	})

	local projectileTemplate = pg.global.abilityMgr:getProjectileTemplate(actionData.templateId)

	if ProjectileConst.PROJECTILE_TYPE_PARSER[projectileType] == ProjectileConst.PROJECTILE_TYPE_TRACKING and projectileTemplate.trackingNoOffsetRotationRange then
		if targetPos then
			if Vector3.SqrDistance(targetPos, pos) < projectileTemplate.trackingNoOffsetRotationRange * projectileTemplate.trackingNoOffsetRotationRange then
				offsetRotation:Set(0, 0, 0)
			end
		elseif target and Vector3.SqrDistance(target:getPosition(), pos) < projectileTemplate.trackingNoOffsetRotationRange * projectileTemplate.trackingNoOffsetRotationRange then
			offsetRotation:Set(0, 0, 0)
		end
	end

	if offsetRotation.x ~= 0 then
		rotation:Copy(rotation * Quaternion.AngleAxis(offsetRotation.x, VEC3_CONST_LEFT))
	end

	if offsetRotation.y ~= 0 then
		rotation:Copy(rotation * Quaternion.AngleAxis(offsetRotation.y, VEC3_CONST_UP))
	end

	if offsetRotation.z ~= 0 then
		rotation:Copy(rotation * Quaternion.AngleAxis(offsetRotation.z, VEC3_CONST_FORWARD))
	end

	Vector3.enableCreateFromCache()

	local emitDir = rotation * VEC3_CONST_FORWARD
	local emitRotFromType = actionData.emitRotFrom
	local emitRotToType = actionData.emitRotTo

	if emitRotFromType ~= nil or emitRotToType ~= nil then
		local emitRotation = rotation:Clone()

		CombatActionTool.parseProjectileEmitRotationFromTo(combatContext, emitRotFromType, emitRotToType, pos, emitRotation)

		emitDir = emitRotation * VEC3_CONST_FORWARD
	end

	local casterInfo = ability and ability:getCastingInfo() or {}

	if casterInfo.aimPos then
		emitDir = casterInfo.aimPos - originPos

		emitDir:SetNormalize()
	end

	Vector3.disableCreateFromCache(emitDir)

	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)
	local autoAimInfo = abilityObject and abilityObject.cacheValMap[AbilityConst.COMBAT_EVENT_ON_SKILL_AUTO_AIM] or {}
	local autoAimDuration = autoAimInfo.duration or -1
	local autoAimStartTime = autoAimInfo.startTime or 0
	local curTime = ownerEntity:getGameTime()

	if (ownerEntity.isMainPlayer or ownerEntity.isMainPet) and pg.game.camera.playerCameraMode.isInAim and autoAimDuration < curTime - autoAimStartTime then
		targetActorId = 0
	end

	local startSleepTime

	if Utils.isTable(actionData.startSleepTime) then
		startSleepTime = self:doAction(actionData.startSleepTime, combatContext)
	end

	if combatContext.overrideProjTargetActorId or combatContext.overrideProjTargetPos then
		local ent = pg.getEntityByActorId(combatContext.overrideProjTargetActorId)

		if ent then
			targetActorId = ent.actorId
		elseif combatContext.overrideProjTargetPos then
			targetPos = combatContext.overrideProjTargetPos
		end
	end

	local projectileParams = ProjectileParams.createInstance(combatContext.abilityId or 0, combatContext.abilityStoreType or 0, ownerActorId, targetActorId, actionData.templateId, ownerEntity.genProjectileInstanceId and ownerEntity:genProjectileInstanceId(), pos, rotation, targetPos, ToBool(combatContext.srcCombatContextId) and combatContext.srcCombatContextId or combatContext.id, combatContext.castingCombatContextId, self:getVal(actionData.soundId, combatContext))

	projectileParams.startSleepTime = startSleepTime
	projectileParams.emitDir = emitDir

	if target and target.eModel then
		projectileParams.trackingRandomOffset = Vector3(Lume.random(-0.1, 0.1) * target.eModel.radius, Lume.random(-0.1, 0.1) * target.eModel.height, 0)
	else
		projectileParams.trackingRandomOffset = Vector3.zero
	end

	local projectile = projectileMgr:addProjectile(projectileParams, combatContext)

	return projectile
end

function CombatAction:createSegmentedProjectile(actionData, combatContext)
	local ability = CombatActionTool.getCasterAbility(combatContext)

	if not ability then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@hyj ability not found")
		end

		return false
	end

	local ownerActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local ownerEntity = pg.getEntityByActorId(ownerActorId)

	if not ownerEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@hyj ownerEntity not found")
		end

		return false
	end

	if ownerEntity.authority ~= Const.AUTHORITY_MASTER then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("ownerEntity no authority", ownerEntity)
		end

		return false
	end

	local templateId = actionData.templateId

	if not ToBool(templateId) then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("@hyj projectileTemplateId not found", templateId)
		end

		return false
	end

	local projTemplate = pg.global.abilityMgr:getProjectileTemplate(templateId)

	if not projTemplate then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("@hyj projectileTemplate not found", templateId)
		end

		return false
	end

	local projectileType = projTemplate.kind
	local posType = actionData.pos
	local rotationType = projTemplate.rotation and projTemplate.rotation or AbilityConst.COMBAT_ROTATION_TYPE_NONE
	local offsetXYZ = Vector3(unpack(actionData.offsetXYZ))
	local startRotationOffset = projTemplate.startRotationOffset and (projTemplate.startRotationOffset.name == nil and Vector3(unpack(projTemplate.startRotationOffset)) or self:doAction(projTemplate.startRotationOffset, combatContext)) or Vector3(0, 0, 0)
	local oriScale = ownerEntity.curModelScale or 1
	local originPos = ownerEntity:getPosition():Clone()

	CombatActionTool.parsePosition(combatContext, posType, originPos)

	local originRot = ownerEntity:getRotation():Clone()

	CombatActionTool.parseRotation(combatContext, posType, originRot)

	local targetActorId = 0
	local targetPosType = projTemplate.targetPos
	local targetPos

	targetActorId, targetPos = CombatActionTool.getProjectileTargetInfo(combatContext, targetPosType, projectileType, originPos, originRot)

	local targetEntity = pg.getEntityByActorId(targetActorId)
	local pos = CombatActionTool.translatePoint(originPos, originRot, offsetXYZ * oriScale)
	local rotation = originRot:Clone()

	CombatActionTool.parseRotationTowards(combatContext, rotationType, pos, rotation, {
		posType = actionData.rotationTowardsPos,
		targetRotation = actionData.targetRotation
	})

	local projectileTemplate = pg.global.abilityMgr:getProjectileTemplate(actionData.templateId)

	if ProjectileConst.PROJECTILE_TYPE_PARSER[projectileType] == ProjectileConst.PROJECTILE_TYPE_TRACKING and projectileTemplate.trackingNoOffsetRotationRange then
		if targetPos then
			if Vector3.SqrDistance(targetPos, pos) < projectileTemplate.trackingNoOffsetRotationRange * projectileTemplate.trackingNoOffsetRotationRange then
				startRotationOffset:Set(0, 0, 0)
			end
		elseif targetEntity and Vector3.SqrDistance(targetEntity:getPosition(), pos) < projectileTemplate.trackingNoOffsetRotationRange * projectileTemplate.trackingNoOffsetRotationRange then
			startRotationOffset:Set(0, 0, 0)
		end
	end

	if startRotationOffset.x ~= 0 then
		rotation:Copy(rotation * Quaternion.AngleAxis(startRotationOffset.x, VEC3_CONST_LEFT))
	end

	if startRotationOffset.y ~= 0 then
		rotation:Copy(rotation * Quaternion.AngleAxis(startRotationOffset.y, VEC3_CONST_UP))
	end

	if startRotationOffset.z ~= 0 then
		rotation:Copy(rotation * Quaternion.AngleAxis(startRotationOffset.z, VEC3_CONST_FORWARD))
	end

	local circleData = {}

	if actionData.isCircleProjectile then
		local centerOffsetXYZ = Vector3(unpack(actionData.centerOffsetXYZ))
		local centerRotationType = actionData.centerRotation
		local centerRotation = ownerEntity:getRotation():Clone()
		local centerPos = CombatActionTool.translatePoint(originPos, centerRotation, centerOffsetXYZ * oriScale)

		CombatActionTool.parseRotationTowards(combatContext, centerRotationType, centerPos, centerRotation, {
			posType = actionData.rotationTowardsPos,
			targetRotation = actionData.targetRotation
		})

		local centerOffsetRotation = Vector3(unpack(actionData.centerOffsetRotation))

		if centerOffsetRotation.x ~= 0 then
			centerRotation:Copy(centerRotation * Quaternion.AngleAxis(centerOffsetRotation.x, VEC3_CONST_LEFT))
		end

		if centerOffsetRotation.y ~= 0 then
			centerRotation:Copy(centerRotation * Quaternion.AngleAxis(centerOffsetRotation.y, VEC3_CONST_UP))
		end

		if centerOffsetRotation.z ~= 0 then
			centerRotation:Copy(centerRotation * Quaternion.AngleAxis(centerOffsetRotation.z, VEC3_CONST_FORWARD))
		end

		local circleCenterUp = VEC3_CONST_UP
		local circleCenterLeft = VEC3_CONST_LEFT
		local circleCenterForward = VEC3_CONST_FORWARD

		circleCenterUp = centerRotation:MulVec3(circleCenterUp)

		circleCenterUp:SetNormalize()

		circleCenterLeft = centerRotation:MulVec3(circleCenterLeft)

		circleCenterLeft:SetNormalize()

		circleCenterForward = centerRotation:MulVec3(circleCenterForward)

		circleCenterForward:SetNormalize()

		pos = CombatActionTool.translatePoint(centerPos, centerRotation, offsetXYZ * oriScale)
		rotation = ownerEntity:getRotation():Clone()

		CombatActionTool.parseRotationTowards(combatContext, rotationType, pos, rotation, {
			centerPos = centerPos,
			centerRotation = centerRotation
		})

		if startRotationOffset.x ~= 0 then
			rotation:Copy(rotation * Quaternion.AngleAxis(startRotationOffset.x, VEC3_CONST_LEFT))
		end

		if startRotationOffset.y ~= 0 then
			rotation:Copy(rotation * Quaternion.AngleAxis(startRotationOffset.y, VEC3_CONST_UP))
		end

		if startRotationOffset.z ~= 0 then
			rotation:Copy(rotation * Quaternion.AngleAxis(startRotationOffset.z, VEC3_CONST_FORWARD))
		end

		circleData.centerPos = centerPos
		circleData.centerUp = circleCenterUp
		circleData.centerLeft = circleCenterLeft
		circleData.centerForward = circleCenterForward

		if rotationType ~= "InvCircleCenter" then
			circleData.needMoveCenter = true
		end
	end

	Vector3.enableCreateFromCache()

	local emitDir = rotation * VEC3_CONST_FORWARD
	local emitRotFromType = actionData.emitRotFrom
	local emitRotToType = actionData.emitRotTo

	if emitRotFromType ~= nil or emitRotToType ~= nil then
		local emitRotation = rotation:Clone()

		CombatActionTool.parseProjectileEmitRotationFromTo(combatContext, emitRotFromType, emitRotToType, pos, emitRotation)

		emitDir = emitRotation * VEC3_CONST_FORWARD
	end

	Vector3.disableCreateFromCache(emitDir)

	local casterInfo = ability:getCastingInfo() or {}

	if casterInfo.aimPos then
		local dir = casterInfo.aimPos - originPos

		rotation = Quaternion.LookRotation(dir, VEC3_CONST_UP)
	end

	local abilityObject = combatContext:ability():getAbilityObject()
	local autoAimInfo = abilityObject.cacheValMap[AbilityConst.COMBAT_EVENT_ON_SKILL_AUTO_AIM] or {}
	local autoAimDuration = autoAimInfo.duration or -1
	local autoAimStartTime = autoAimInfo.startTime or 0
	local curTime = ownerEntity:getGameTime()

	if (ownerEntity.isMainPlayer or ownerEntity.isMainPet) and pg.game.camera.playerCameraMode.isInAim and autoAimDuration < curTime - autoAimStartTime then
		targetActorId = 0
	end

	local projectileParams = ProjectileParams.createInstance(ability.abilityId, ability.storeType, ownerActorId, targetActorId, templateId, ownerEntity.genProjectileInstanceId and ownerEntity:genProjectileInstanceId(), pos, rotation, targetPos, combatContext.srcCombatContextId or 0, combatContext.castingCombatContextId)

	projectileParams.circleData = circleData
	projectileParams.emitDir = emitDir

	if targetEntity and targetEntity.eModel then
		projectileParams.trackingRandomOffset = Vector3(Lume.random(-0.1, 0.1) * targetEntity.eModel.radius, Lume.random(-0.1, 0.1) * targetEntity.eModel.height, 0)
	else
		projectileParams.trackingRandomOffset = Vector3.zero
	end

	local projectileMgr = ownerEntity.space and ownerEntity.space.projectileMgr

	if not projectileMgr then
		return false
	end

	projectileParams.iterNumber = combatContext.iterNumber

	local projectile = projectileMgr:addProjectile(projectileParams, combatContext)

	return projectile
end

function CombatAction:createSegmentedCircleProjectile(actionData, combatContext)
	local ownerActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local ownerEntity = pg.getEntityByActorId(ownerActorId)

	if not ownerEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@hyj ownerEntity not found")
		end

		return false
	end

	local projectileNum = actionData.projectileNum
	local circleRadius = actionData.circleRadius
	local deltaAngle = math.pi * 2 / projectileNum

	for i = 1, projectileNum do
		local angle = deltaAngle * i
		local offsetZ = circleRadius * math.cos(angle)
		local offsetX = circleRadius * math.sin(angle)
		local offsetXYZ = Vector3(offsetX, 0, offsetZ)

		actionData = Utils.deepCopyTable(actionData)
		actionData.isCircleProjectile = true
		actionData.offsetXYZ = {
			offsetXYZ.x,
			offsetXYZ.y,
			offsetXYZ.z
		}

		self:createSegmentedProjectile(actionData, combatContext)
	end
end

function CombatAction:createSegmentedRandomProjectile(actionData, combatContext)
	local nums = actionData.projectileNum
	local randomCenter = Vector3(unpack(actionData.startPosOffset))
	local randomSize = Vector3(unpack(actionData.startRegion))
	local destination = Vector3(unpack(actionData.destinationPosOffset))
	local destRandomSize = Vector3(unpack(actionData.destinationRegion))

	randomSize = randomSize * 0.5

	local offsetPitchRange = Vector2(unpack(actionData.offsetPitchRange))
	local offsetYawRange = Vector2(unpack(actionData.offsetYawRange))
	local offsetRollRange = Vector2(unpack(actionData.offsetRollRange))
	local casterActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_CASTER)
	local casterEntity = pg.getEntityByActorId(casterActorId)

	if not casterEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@hyj casterEntity not found", casterActorId)
		end

		return false
	end

	local originPos = casterEntity:getPosition():Clone()
	local originRot = casterEntity:getRotation():Clone()
	local copyActionData = Utils.deepCopyTable(actionData)

	for i = 1, nums do
		if actionData.templateIdList then
			local tmpNum = #actionData.templateIdList
			local randomIndex = math.random(1, tmpNum)

			copyActionData.templateId = actionData.templateIdList[randomIndex]

			if copyActionData.templateId == nil then
				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					CombatLogger.error("@hyj index out of projIdList", casterActorId)
				end

				return false
			end
		end

		local randX = (math.random() * 2 - 1) * randomSize.x + randomCenter.x
		local randY = (math.random() * 2 - 1) * randomSize.y + randomCenter.y
		local randZ = (math.random() * 2 - 1) * randomSize.z + randomCenter.z
		local randPitch = math.random(offsetPitchRange.x, offsetPitchRange.y)
		local randYaw = math.random(offsetYawRange.x, offsetYawRange.y)
		local randRoll = math.random(offsetRollRange.x, offsetRollRange.y)

		copyActionData.offsetPitch = randPitch
		copyActionData.offsetXYZ = {
			randX,
			randY,
			randZ
		}
		copyActionData.offsetRotation = {
			randPitch,
			randYaw,
			randRoll
		}

		local destRandX = (math.random() * 2 - 1) * destRandomSize.x + destination.x
		local destRandZ = (math.random() * 2 - 1) * destRandomSize.z + destination.z
		local destinationOffset = Vector3(destRandX, destination.y, destRandZ)

		combatContext.randomPointPos = originPos + originRot:MulVec3(destinationOffset)

		self:createSegmentedProjectile(copyActionData, combatContext)
	end
end

function CombatAction:reflectProjectile(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return
	end

	local projectileMgr = ownerEntity.space and ownerEntity.space.projectileMgr

	if not projectileMgr then
		return false
	end

	local eventCombatContext = combatContext.eventData[AbilityConst.COMBAT_EVENT_RECEIVE_BE_ATTACKED]
	local eventProjectile = eventCombatContext and eventCombatContext:projectile()

	if not eventProjectile then
		return
	end

	eventCombatContext.isImmuteDamage = true

	local eventProjectileOwner = eventProjectile:getSrcEntity()
	local newDir = -eventProjectile.rot:MulVec3(VEC3_CONST_FORWARD)
	local newRot = Quaternion.LookRotation(newDir, VEC3_CONST_UP)
	local projectileParams = ProjectileParams.createInstance(combatContext.abilityId or eventProjectile.srcAbilityId or 0, combatContext.abilityStoreType or eventProjectile.srcAbilityStoreType or 0, ownerEntity.actorId, eventProjectile.targetActorId ~= nil and eventProjectileOwner.actorId or 0, eventProjectile.templateId, ownerEntity.genProjectileInstanceId and ownerEntity:genProjectileInstanceId(), eventProjectile.pos, newRot, eventProjectile.targetPos ~= nil and CombatActionTool.getHitPosition(eventProjectileOwner) + newDir * 2 or nil, ToBool(combatContext.srcCombatContextId) and combatContext.srcCombatContextId or combatContext.id, combatContext.castingCombatContextId)

	projectileParams.emitDir = newDir

	local projectile = projectileMgr:addProjectile(projectileParams, combatContext)

	if projectile then
		projectile.extraHitActionIds = actionData.extraHitActionIds
		projectile.overrideScale = eventProjectileOwner.curModelScale
	end

	eventProjectile:destroy()

	return projectile
end

function CombatAction:initBezierControlPointByAction(actionData, combatContext)
	local projectile = combatContext:projectile()

	if not projectile then
		return false
	end

	if projectile.projectileType ~= ProjectileConst.PROJECTILE_TYPE_BEZIER then
		return false
	end

	local projTemplate = pg.global.abilityMgr:getProjectileTemplate(projectile.templateId)
	local refStartPoint = self:getVal(actionData.overrideRefStartPoint, combatContext) or Vector3(unpack(projTemplate.refStartPoint))
	local refTargetPoint = self:getVal(actionData.overrideRefTargetPoint, combatContext) or Vector3(unpack(projTemplate.refTargetPoint))
	local refControlPoint = self:getVal(actionData.overrideRefControlPoint, combatContext) or projTemplate.refControlPoint

	projectile.controlPos = CombatActionTool.calcRelativeControlPoint(refStartPoint, refTargetPoint, refControlPoint, projectile.startPos, projectile.targetPos)
end

function CombatAction:createVector3ListByAction(actionData, combatContext)
	local vec3List = {}

	for _, vector3Action in ipairs(actionData.actionIds) do
		local vec3 = self:doActionById(vector3Action, combatContext)

		table.insert(vec3List, vec3)
	end

	return vec3List
end

function CombatAction:getEventAttributeChangeValue(actionData, combatContext)
	local eventName = AbilityConst.COMBAT_EVENT_ATTRIBUTE_CHANGE

	if actionData.targetType == AbilityConst.ATTR_CHANGE_TARGET.CURPET then
		eventName = AbilityConst.COMBAT_EVENT_PET_ATTRIBUTE_CHANGE
	end

	local context = combatContext.eventData and combatContext.eventData[eventName]

	if not context then
		return 0
	end

	return context.value - context.oldValue
end

function CombatAction:addExtraCollisionTest(actionData, combatContext)
	local ownerActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local ownerEntity = pg.getEntityByActorId(ownerActorId)

	if ownerEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("CombatAction[addExtraCollisionTest]: entity not find", ownerActorId)
		end

		return false
	end

	local key = actionData.key or combatContext.BPName

	if ownerEntity.addAbilityCollisionTest and actionData.radius > 0 and actionData.collidableActorTypes then
		local duration = actionData.duration or 0
		local timerId

		if duration > 0 then
			timerId = ownerEntity:addTimer(duration, function()
				ownerEntity:removeAbilityCollisionTest(key)
			end)
		end

		ownerEntity:addAbilityCollisionTest(key, actionData, combatContext, timerId)

		return true
	end

	return false
end

function CombatAction:removeExtraCollisionTest(actionData, combatContext)
	local ownerActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local ownerEntity = pg.getEntityByActorId(ownerActorId)

	if ownerEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("CombatAction[removeExtraCollisionTest]: entity not find", ownerActorId)
		end

		return false
	end

	local key = actionData.key or combatContext.BPName

	if ownerEntity.removeAbilityCollisionTest then
		ownerEntity:removeAbilityCollisionTest(key)

		return true
	end
end

function CombatAction:checkTargetTemplateId(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return false
	end

	local isRefId = actionData.isRefId
	local checkId = targetEntity.templateId

	checkId = isRefId and targetEntity:getConfigData().refId or checkId

	return checkId == actionData.templateId
end

function CombatAction:registerRepeatEvent(actionData, combatContext)
	EventBus.enableRegisterRepeatEvent = true

	self:doActions(actionData, combatContext)

	EventBus.enableRegisterRepeatEvent = false

	return true
end

function CombatAction:removeExtraTempPet(actionData, combatContext)
	local delayTime = actionData.delayTime
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)
	local player = AbilityUtils.getPlayer(ownerEntity)

	if not player then
		return
	end

	local petEnt = pg.getEntity(player.extraTempPetId)

	if not petEnt or petEnt.isAbilityEndRemoveExtraTempPet then
		return
	end

	local combatContextClone = combatContext:clone()

	local function removePetFun()
		if pg.component == "client" then
			local shaderView = petEnt.eModel.modelShaderView

			if shaderView then
				ClientEffectUtils.PlayPreset(petEnt, AbilitySettingGlobalConstData.extraTempPetDissolvePreset, delayTime, false)
			end
		end

		if player.addEntityTimer then
			player:addEntityTimer(delayTime, function()
				if pg.component == "game" then
					player:setExtraTempPetTemplateId(0)
				end

				self:doActionIds(actionData.removeActionIds, combatContextClone)
			end)
		end
	end

	local isAbilityNotBackSwing = petEnt:ABILITY_ST() and not petEnt:BACKSWING_ST()

	if isAbilityNotBackSwing then
		petEnt.isDyingExtraTempPet = true

		abilityObject:getObserver():listen(petEnt.subject, AbilityConst.COMBAT_EVENT_ON_ACTION_MASK_CHANGE, function(maskId, value)
			if value and maskId == AbilityConst.ACTION_MASK_IN_BACKSWING then
				abilityObject:getObserver():unlisten(petEnt.subject, AbilityConst.COMBAT_EVENT_ON_ACTION_MASK_CHANGE)
				abilityObject:getObserver():unlisten(petEnt.subject, AbilityConst.COMBAT_EVENT_ON_ABILITY_END)
				self:doActions(actionData, combatContextClone)
				removePetFun()
			end
		end)
		abilityObject:getObserver():listen(petEnt.subject, AbilityConst.COMBAT_EVENT_ON_ABILITY_END, function()
			abilityObject:getObserver():unlisten(petEnt.subject, AbilityConst.COMBAT_EVENT_ON_ACTION_MASK_CHANGE)
			abilityObject:getObserver():unlisten(petEnt.subject, AbilityConst.COMBAT_EVENT_ON_ABILITY_END)
			self:doActions(actionData, combatContextClone)
			removePetFun()
		end)
	else
		self:doActions(actionData, combatContext)
		removePetFun()
	end

	return true
end

function CombatAction:notifyFollowPhantomEvent(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		CombatLogger.error("target not found", actionData.target)

		return false
	end

	local masterEntity = targetEntity.getMasterEntity and targetEntity:getMasterEntity() or targetEntity

	masterEntity.subject:notify(AbilityConst.COMBAT_EVENT_ON_NOTIFY_FOLLOW_PHANTOM, actionData.eventName, combatContext)

	return true
end

function CombatAction:getCombatContextAbilityId(actionData, combatContext)
	local eventName = actionData.eventName

	if eventName then
		local eventCombatContext = combatContext.eventData and combatContext.eventData[eventName] or nil

		if not eventCombatContext then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				CombatLogger.error("@hyj CombatAction:doActionsByEventCombatContext failed, eventCombatContext is nil", eventName)
			end

			return false
		end

		return eventCombatContext.abilityId or 0
	end

	return combatContext.abilityId or 0
end

function CombatAction:checkAbilityAttackType(actionData, combatContext)
	if ToBool(combatContext.eventData) then
		for _, eventCombatContext in pairs(combatContext.eventData) do
			if type(eventCombatContext) == "table" and eventCombatContext.className == "CombatContext" then
				combatContext = eventCombatContext

				break
			end
		end
	end

	local ability = CombatActionTool.getCasterAbility(combatContext)

	if not ability then
		return false
	end

	return pg.global.abilityMgr:getAbilityParamData(ability.abilityId).attackType == actionData.attackType
end

function CombatAction:registerAbilityBackswingForAbilityIds(actionData, combatContext)
	local abilityIds = actionData.abilityIds

	if not abilityIds then
		return false
	end

	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)

	if not ownerEntity or not ownerEntity:ABILITY_ST() then
		return false
	end

	local ability = combatContext:ability()

	if not ability or not ownerEntity.isCastingAbility or not ownerEntity:isCastingAbility(ability.abilityId) then
		return false
	end

	for _, abilityId in ipairs(abilityIds) do
		ownerEntity.cancelAbilityByAbilityIdList[abilityId] = true
	end

	local duration = actionData.duration
	local timer

	if duration and duration > 0 then
		timer = ownerEntity:addTimer(duration, function()
			Lume.clear(ownerEntity.cancelAbilityByAbilityIdList)
		end)
	end

	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	abilityObject:addExitCallback(function()
		Lume.clear(ownerEntity.cancelAbilityByAbilityIdList)

		if timer then
			ownerEntity:removeTimer(timer)
		end
	end)

	return true
end

function CombatAction:isTargetActiveForBattle(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if not targetEntity then
		return false
	end

	if Utils.isPet(targetEntity) and not targetEntity.isSummon and not targetEntity:isPetActiveForCombat() then
		return false
	end

	if Utils.isSupportPet(targetEntity) then
		return false
	end

	return targetEntity:isAlive()
end

function CombatAction:checkState(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	return targetEntity and targetEntity:checkInState(actionData.stateName)
end

function CombatAction:enableAimSense(actionData, combatContext)
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)

	if not ownerEntity then
		return false
	end

	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	if actionData.enable then
		local enterActorIdMap = {}

		if ownerEntity.enterAimSense then
			ownerEntity:enterAimSense(actionData, enterActorIdMap)
		end

		local copyCombatContext = combatContext:clone()
		local guardVal = GuardValue()

		abilityObject:getObserver():listen(ownerEntity.subject, AbilityConst.COMBAT_EVENT_ON_ENTER_AIM_SENSE, function(actorId)
			if enterActorIdMap[actorId] then
				return
			end

			enterActorIdMap[actorId] = true

			local actorEntity = pg.getEntityByActorId(actorId)

			if not actorEntity then
				return false
			end

			local runtimeTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:get(true)

			guardVal:ctor(copyCombatContext, "runtimeTargetInfo", runtimeTargetInfo)
			runtimeTargetInfo:initTarget(actorId, actorEntity:getPosition(), 1, 0)
			self:doActions(actionData, copyCombatContext)
			guardVal:recover()
			pg.global.abilityMgr.runtimeTargetInfoPool:returnObject(runtimeTargetInfo)
		end)

		if ownerEntity.leaveAimSense then
			abilityObject:addExitCallback(function()
				ownerEntity:leaveAimSense(actionData, enterActorIdMap)
			end)
		end
	else
		if ownerEntity.leaveAimSense then
			ownerEntity:leaveAimSense(actionData)
		end

		abilityObject:getObserver():unlisten(ownerEntity.subject, AbilityConst.COMBAT_EVENT_ON_ENTER_AIM_SENSE)
	end
end

function CombatAction:registerAbilityBackSwing(actionData, combatContext)
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	local copyCombatContext = combatContext:clone()

	abilityObject:getObserver():listen(ownerEntity.subject, AbilityConst.COMBAT_EVENT_ON_ABILITY_BACK_SWING, function(abilityId, actorId)
		if not ToBool(abilityId) then
			return
		end

		if CombatActionTool.isBlockTriggerAbilityEvent(abilityId, actorId, actionData) then
			return
		end

		copyCombatContext:setEventData(AbilityConst.COMBAT_EVENT_ON_ABILITY_BACK_SWING, abilityId)
		self:doActions(actionData, copyCombatContext)
		copyCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_ON_ABILITY_BACK_SWING)
	end)
end

function CombatAction:constQua(actionData, combatContext)
	return Quaternion.Euler(actionData.xAngle, actionData.yAngle, actionData.zAngle)
end

function CombatAction:registerPetListChangeEvent(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	local playerEnt = Utils.convertPlayerEntity(ownerEntity)

	if not playerEnt then
		return false
	end

	if actionData.actionIds then
		local observer = CombatActionTool.getContextObserver(combatContext)

		if observer then
			local copyCombatContext = combatContext:clone()

			observer:listen(playerEnt.subject, AbilityConst.COMBAT_EVENT_ON_PET_LIST_CHANGE, function()
				self:doActions(actionData, copyCombatContext)
			end)
		end
	end
end

function CombatAction:isInAbility(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return false
	end

	local isInAbility = targetEntity.inAbility and targetEntity:inAbility()
	local checkAbilityType = actionData.abilityType

	if isInAbility and checkAbilityType then
		local template = pg.global.abilityMgr:getAbilityTemplate(targetEntity.getCastingAbilityId and targetEntity:getCastingAbilityId())

		return template and template.abilityType == checkAbilityType
	end

	return isInAbility
end

function CombatAction:registerAbilityStateChangeEvent(actionData, combatContext)
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	local owner = CombatActionTool.getRegisterEventSubjectEntity(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local copyCombatContext = combatContext:clone()

	abilityObject:getObserver():listen(owner.subject, AbilityConst.COMBAT_EVENT_ON_ABILITY_STATE_CHANGE, function(abilityId, actorId)
		if CombatActionTool.isBlockTriggerAbilityEvent(abilityId, actorId, actionData) then
			return
		end

		copyCombatContext:setEventData(AbilityConst.COMBAT_EVENT_ON_ABILITY_STATE_CHANGE, abilityId)
		self:doActions(actionData, copyCombatContext)
		copyCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_ON_ABILITY_STATE_CHANGE)
	end)
end

function CombatAction:registerBagWeightLevelChangeEvent(actionData, combatContext)
	local targetEntity = CombatActionTool.getRegisterEventSubjectEntity(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER)

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("target not found", actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER)
		end

		return false
	end

	local playerEnt = Utils.convertPlayerEntity(targetEntity)

	if not playerEnt then
		return false
	end

	if actionData.actionIds then
		local observer = CombatActionTool.getContextObserver(combatContext)

		if observer then
			local copyCombatContext = combatContext:clone()

			observer:listen(playerEnt.subject, AbilityConst.COMBAT_EVENT_ON_BAG_WEIGHT_LEVEL_CHANGE, function()
				self:doActions(actionData, copyCombatContext)
			end)
		end
	end
end

function CombatAction:checkBagWeightLevel(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("target not found", actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER)
		end

		return false
	end

	local playerEnt = Utils.convertPlayerEntity(targetEntity)

	if not playerEnt then
		return false
	end

	return playerEnt.curLoadLevel == actionData.loadLevel
end

function CombatAction:registerPlayerEggModeChangeEvent(actionData, combatContext)
	local targetEntity = CombatActionTool.getRegisterEventSubjectEntity(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER)

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("target not found", actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER)
		end

		return false
	end

	local playerEnt = Utils.convertPlayerEntity(targetEntity)

	if not playerEnt then
		return false
	end

	if actionData.actionIds then
		local observer = CombatActionTool.getContextObserver(combatContext)

		if observer then
			local copyCombatContext = combatContext:clone()

			observer:listen(playerEnt.subject, AbilityConst.COMBAT_EVENT_ON_PLAYER_EGG_MODE_CHANGE, function()
				self:doActions(actionData, copyCombatContext)
			end)
		end
	end
end

function CombatAction:checkPlayerEggMode(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("target not found", actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER)
		end

		return false
	end

	local playerEnt = Utils.convertPlayerEntity(targetEntity)

	if not playerEnt then
		return false
	end

	return playerEnt:isControllingEgg()
end

function CombatAction:getCreatedEntityCount(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))
	local count = 0

	if targetEntity then
		local filterCondition = actionData.filterCondition
		local checkCreation = actionData.checkCreation
		local checkPuppet = actionData.checkPuppet

		if filterCondition then
			local abilityMgr = pg.global.abilityMgr

			if checkCreation and targetEntity.createdCreationList then
				for _, actorId in ipairs(targetEntity.createdCreationList) do
					local runtimeTargetInfo = abilityMgr.runtimeTargetInfoPool:getWithCtor(true, actorId)
					local guardValue = abilityMgr.guardValuePool:getWithCtor(true, combatContext, "runtimeTargetInfo", runtimeTargetInfo)

					if self:doActionById(filterCondition, combatContext) then
						count = count + 1
					end

					abilityMgr.guardValuePool:returnObject(guardValue)
					abilityMgr.runtimeTargetInfoPool:returnObject(runtimeTargetInfo)
				end
			end

			if checkPuppet and targetEntity.createdPuppetList then
				for _, actorId in ipairs(targetEntity.createdPuppetList) do
					local runtimeTargetInfo = abilityMgr.runtimeTargetInfoPool:getWithCtor(true, actorId)
					local guardValue = abilityMgr.guardValuePool:getWithCtor(true, combatContext, "runtimeTargetInfo", runtimeTargetInfo)

					if self:doActionById(filterCondition, combatContext) then
						count = count + 1
					end

					abilityMgr.guardValuePool:returnObject(guardValue)
					abilityMgr.runtimeTargetInfoPool:returnObject(runtimeTargetInfo)
				end
			end
		else
			if checkCreation and targetEntity.createdCreationList then
				count = count + #targetEntity.createdCreationList
			end

			if checkPuppet and targetEntity.createdPuppetList then
				count = count + #targetEntity.createdPuppetList
			end
		end
	end

	return count
end

function CombatAction:registerMoveChangeEvent(actionData, combatContext)
	local observer = CombatActionTool.getContextObserver(combatContext)

	if not observer then
		return false
	end

	local targetEntity = CombatActionTool.getRegisterEventSubjectEntity(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER)

	if not targetEntity then
		return false
	end

	local copyCombatContext = combatContext:clone()

	observer:listen(targetEntity.subject, AbilityConst.COMBAT_EVENT_ON_MOVE_CHANGE, function(isPositionMoved)
		self:doActions(actionData, copyCombatContext)
	end)

	if targetEntity.addAbilityTickReason then
		targetEntity:addAbilityTickReason(AbilityConst.ABILITY_TICK_REASONS.MOVE_CHECK)
	end

	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	abilityObject:addExitCallback(function()
		if targetEntity.removeAbilityTickReason then
			targetEntity:removeAbilityTickReason(AbilityConst.ABILITY_TICK_REASONS.MOVE_CHECK)
		end
	end)

	return true
end

function CombatAction:checkIsMoving(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("target not found", actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER)
		end

		return false
	end

	return targetEntity.isPositionMoved
end

function CombatAction:isPlayerInCarryEggState(actionData, combatContext)
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)

	if not Utils.isPlayer(ownerEntity) then
		return false
	end

	if not ownerEntity:CARRY_EGG_ST() then
		return false
	end

	local eggEnt = pg.getEntity(ownerEntity.carryObjId)

	if not eggEnt then
		return false
	end

	return eggEnt.subType == actionData.carryEggState
end

function CombatAction:getTargetProperty(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("target not found", actionData.target)
		end

		return false
	end

	local property = actionData.property

	return targetEntity[property]
end

function CombatAction:getAngle(actionData, combatContext)
	local rotationA = self:doActionById(actionData.rotationANodeID, combatContext)
	local rotationB = self:doActionById(actionData.rotationBNodeID, combatContext)

	if rotationA.z and rotationB.z then
		return Quaternion.Angle(rotationA, rotationB)
	else
		CombatActionTool.logError(combatContext, actionData, "angle error", tostring(rotationA), tostring(rotationB))

		return 0
	end
end

function CombatAction:random(actionData, combatContext)
	local min = self:getVal(actionData.min, combatContext)
	local max = self:getVal(actionData.max, combatContext)

	assert(type(min) == "number", "min is not number," .. tostring(min))
	assert(type(max) == "number", "max is not number" .. tostring(max))

	return Lume.random(min, max)
end

function CombatAction:getValByFormula(actionData, combatContext)
	local formulaData = FormulaData[actionData.formulaId]

	if not formulaData then
		CombatActionTool.logError(actionData, combatContext, "formula data not found")

		return 0
	end

	return formulaData.formula(self:getVal(actionData.arg1, combatContext), self:getVal(actionData.arg2, combatContext), self:getVal(actionData.arg3, combatContext), self:getVal(actionData.arg4, combatContext), self:getVal(actionData.arg5, combatContext))
end

local refCachePos = Vector3(0, 0, 0)

function CombatAction:checkTargetPos(actionData, combatContext)
	return CombatActionTool.parsePosition(combatContext, actionData.targetPos, refCachePos)
end

function CombatAction:getPlayer(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return 0
	end

	local player = AbilityUtils.getPlayer(targetEntity)

	return player and player.actorId or 0
end

function CombatAction:enableTargetAIBehaviorTree(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if not targetEntity then
		return false
	end

	local enable = actionData.enable

	if enable then
		AIUtils.ResumeAI(targetEntity.id, AiConst.PauseBtReason.AbilityAction)
	else
		AIUtils.PauseAI(targetEntity.id, AiConst.PauseBtReason.AbilityAction)

		if actionData.autoRecover then
			local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

			if not abilityObject then
				return false
			end

			abilityObject:addExitCallback(function()
				AIUtils.ResumeAI(targetEntity.id, AiConst.PauseBtReason.AbilityAction)
			end)
		end
	end
end

function CombatAction:notifySystemEvent(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity or not targetEntity.eventEmitter then
		return false
	end

	local eventName = actionData.eventName

	if not eventName or not EventConst[eventName] then
		return false
	end

	targetEntity.eventEmitter:emit(EventConst[eventName])
end

function CombatAction:getTargetHitPosition(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if not targetEntity then
		return CombatActionTool.INVALID_POS
	end

	return CombatActionTool.getHitPosition(targetEntity) or targetEntity:getPosition()
end

function CombatAction:fastforwardTimeline(actionData, combatContext)
	local target = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not target or not target.actorTimeline then
		return false
	end

	if target.authority ~= Const.AUTHORITY_MASTER then
		return false
	end

	local timelineId = self:getVal(actionData.timelineId, combatContext)
	local timeline = target.actorTimeline:getTimelineInstance(timelineId)

	if not timeline then
		return
	end

	local time = self:getVal(actionData.time, combatContext)

	if type(time) ~= "number" or time <= 0 then
		return false
	end

	time = math.min(time, 10)

	if pg.component == "client" then
		local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)

		if not ownerEntity then
			return false
		end

		ownerEntity:serverMsgNoGC("RPC_CS_FastForwardTimeline", combatContext.id, combatContext.nodeStack or {}, target.actorId, timelineId, time)
	else
		target:allClientsMsgNoGC("RPC_SC_FastForwardTimeline", timelineId, time)
	end

	timeline:tick(time)

	return true
end

function CombatAction:checkDynamicListSame(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	local list = ownerEntity:getEntityCacheVal(actionData.listId)

	if not Utils.isTable(list) then
		CombatActionTool.logError(combatContext, actionData, "not type table", tostring(list))

		return false
	end

	if #list <= 1 then
		return true
	end

	local first = list[1]

	for i = 2, #list do
		if list[i] ~= first then
			return false
		end
	end

	return true
end

function CombatAction:addSimpleTimer(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return false
	end

	local duration = self:getVal(actionData.duration, combatContext)
	local copyCombatContext = combatContext:clone()
	local timer = targetEntity:addTimer(duration, function()
		pg.global.abilityMgr.combatAction:doActions(actionData, copyCombatContext)
	end)
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	abilityObject:addExitCallback(function()
		targetEntity:removeTimer(timer)
	end)
end

function CombatAction:getDirectionFromTo(actionData, combatContext)
	Vector3.enableCreateFromCache()

	local dirFromPos = Vector3(0, 0, 0)

	if not CombatActionTool.parsePosition(combatContext, actionData.from, dirFromPos) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("CombatAction:checkDirInAngleRange failed, dirFrom invalid", actionData.dirFrom)
		end

		Vector3.disableCreateFromCache(dirFromPos)

		return dirFromPos
	end

	local dirToPos = Vector3(0, 0, 0)

	if not CombatActionTool.parsePosition(combatContext, actionData.to, dirToPos) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("CombatAction:checkDirInAngleRange failed, dirTo invalid", actionData.dirTo)
		end

		Vector3.disableCreateFromCache(dirToPos)

		return dirToPos
	end

	local result = dirToPos - dirFromPos

	Vector3.disableCreateFromCache(result)

	return result
end

function CombatAction:getForwardDir(actionData, combatContext)
	Vector3.enableCreateFromCache()

	local rotation = Quaternion.identity

	if not CombatActionTool.parseRotation(combatContext, actionData.rotation, rotation) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("CombatAction:getForwardDir failed, rotation invalid", actionData.rotation)
		end

		local result = Vector3.Clone(VEC3_CONST_FORWARD)

		Vector3.disableCreateFromCache(result)

		return result
	end

	local result = rotation:MulVec3(VEC3_CONST_FORWARD)

	Vector3.disableCreateFromCache(result)

	return result
end

function CombatAction:getSignedAngle(actionData, combatContext)
	local dir = self:getVal(actionData.dir, combatContext)

	if not dir then
		return false
	end

	dir:SetNormalize()

	local refDir = self:getVal(actionData.refDir, combatContext)

	if not refDir then
		return false
	end

	refDir:SetNormalize()

	return Vector3.SignedAngle(refDir, dir, Vector3.constUp)
end

function CombatAction:checkDirInAngleRange(actionData, combatContext)
	local angle = self:getSignedAngle(actionData, combatContext)

	if not angle then
		return false
	end

	if angle >= 0 and angle <= actionData.leftAngle then
		return true
	elseif angle <= 0 and angle >= -actionData.rightAngle then
		return true
	end

	return false
end

function CombatAction:isCalcResultElementAdvantage(actionData, combatContext)
	if ToBool(combatContext.eventData) then
		for _, eventCombatContext in pairs(combatContext.eventData) do
			if type(eventCombatContext) == "table" and eventCombatContext.className == "CombatContext" then
				combatContext = eventCombatContext

				break
			end
		end
	end

	return combatContext.isElementAdvantage or false
end

function CombatAction:checkDamageAbilityType(actionData, combatContext)
	if ToBool(combatContext.eventData) then
		for _, eventCombatContext in pairs(combatContext.eventData) do
			if type(eventCombatContext) == "table" and eventCombatContext.className == "CombatContext" then
				combatContext = eventCombatContext

				break
			end
		end
	end

	local abilityType = combatContext.overrideAbilityType

	if not abilityType then
		local ability = CombatActionTool.getCasterAbility(combatContext)

		abilityType = ability and ability:getAbilityTemplate().abilityType
	end

	return abilityType == actionData.abilityType
end

function CombatAction:constDouble(actionData, combatContext)
	return actionData.value
end

function CombatAction:checkTargetLifeState(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if not targetEntity then
		return false
	end

	return targetEntity.life == actionData.life
end

function CombatAction:registerLifeStateChangeEvent(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return false
	end

	local observer = CombatActionTool.getContextObserver(combatContext)

	if observer then
		local copyCombatContext = combatContext:clone()

		observer:listen(targetEntity.subject, AbilityConst.COMBAT_EVENT_ON_LIFE_STATE_CHANGE, function()
			self:doActions(actionData, copyCombatContext)
		end)
	end
end

function CombatAction:registerEntBeCarriedStateChange(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return false
	end

	if actionData.enterActionIds or actionData.exitActionIds then
		local observer = CombatActionTool.getContextObserver(combatContext)

		if observer then
			local copyCombatContext = combatContext:clone()

			observer:listen(targetEntity.subject, AbilityConst.COMBAT_EVENT_ON_ENT_BE_CARRIED_STATE_CHANGE, function(isEnter)
				if isEnter then
					self:doActionIds(actionData.enterActionIds, copyCombatContext)
				else
					self:doActionIds(actionData.exitActionIds, copyCombatContext)
				end
			end)
		end
	end
end

function CombatAction:checkTargetBeCarried(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if not targetEntity then
		return false
	end

	return Utils.checkEntBeCarried(targetEntity)
end

function CombatAction:voxelRaycast(actionData, combatContext)
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)
	local originPos = ownerEntity:getPosition():Clone()

	CombatActionTool.parsePosition(combatContext, actionData.fromPos, originPos)

	local targetPos = ownerEntity:getPosition():Clone()

	CombatActionTool.parsePosition(combatContext, actionData.toPos, targetPos)

	local hitRet, _, _, _, _ = VoxelUtils.rayCast(ownerEntity, originPos[1], originPos[2], originPos[3], targetPos[1], targetPos[2], targetPos[3])

	return hitRet
end

function CombatAction:getBuffRemainingTime(actionData, combatContext)
	local buffTemplateId = actionData.templateId
	local buff

	if buffTemplateId == nil then
		buff = combatContext:buff()
	else
		local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

		buff = targetEntity and targetEntity.actorBuff and targetEntity.actorBuff:findOneBuffByTemplateId(buffTemplateId)
	end

	return buff and buff:getRemainingTime() or 0
end

function CombatAction:getSuitId(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return 0
	end

	return AbilityUtils.getSuitId(targetEntity)
end

function CombatAction:registerAbilityDisableReturnEvent(actionData, combatContext)
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return
	end

	local target = CombatActionTool.getRegisterEventSubjectEntity(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER)

	if not target then
		return
	end

	local copyCombatContext = combatContext:clone()

	abilityObject:getObserver():listen(target.subject, AbilityConst.COMBAT_EVENT_ON_ABILITY_DISABLE_RETURN, function(eventCombatContext)
		if CombatActionTool.isBlockTriggerAbilityEvent(copyCombatContext.abilityId, copyCombatContext.actorId, actionData) then
			return
		end

		copyCombatContext:setEventData(AbilityConst.COMBAT_EVENT_ON_ABILITY_DISABLE_RETURN, eventCombatContext)
		self:doActions(actionData, copyCombatContext)
		copyCombatContext:clearEventData(AbilityConst.COMBAT_EVENT_ON_ABILITY_DISABLE_RETURN)
	end)
end

return CombatAction
