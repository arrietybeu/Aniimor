-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\AIUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Utils = require("Common.Utils.Utils")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local AiConst = require("Common.Const.AiConst")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local CTRPool = require("Common.AICt.CTRPool")
local CTRConst = require("Common.AICt.CTRConst")
local CTUtils = require("Common.AI.ConditionTrigger.CTUtils")
local ParmonBehaivorData = require("Data.parmon_behavior_data")
local logger = LoggerManager.getLogger("AIUtils")
local CallbackHandlerNoGC = require("Core.Common.CallbackHandlerNoGC")
local ListPool = require("Common.Container.ListPool")
local Const = require("Common.Const.Const")
local PerceptibilityConst = require("Common.Const.PerceptibilityConst")
local InteractTagData = require("Data.interact_tag_data")
local TablePool = require("Common.Container.TablePool")
local lume = require("Core.Common.lume")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local layer = require("Common.Const.PhysicsLayerConst")
local calcUtils = require("Common.Utils.CalcUtils")
local SceneUtils = require("Common.Utils.SceneUtils")
local routeDefaultValueData = require("Common.Data.Scene.route_default_value_data")
local CalcUtils = require("Utils.CalcUtils")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local VoxelUtils = require("Common.Utils.VoxelUtils")
local ECSConst = require("Common.Const.ECSConst")
local EcologyEthnicInteractRuleData = require("Data.ecology_ethnic_interact_rule_data")
local EcologyEthnicInteractBehavData = require("Data.ecology_ethnic_interact_behav_data")
local AbilityConst = require("Common.Const.AbilityConst")
local SysConfigData = require("Data.sys_config_data")
local BehaviorXConst = require("Common.Const.BehaviorXConst")
local AttributeEntryData = require("Data.attribute_entry_data")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local ipairs = ipairs
local pairs = pairs
local bit = bit
local bit_band = bit.band
local pg = pg
local Vector3 = Vector3
local table = table
local math_min = math.min
local math_max = math.max
local math_maxFloat = math.maxFloat
local math_maxInt = math.maxInt
local EBTRootState_NAME = BaseEnum.EBTRootState_NAME
local next = next
local AIUtils = {}
local WAY_POINT_DEFAULTS = routeDefaultValueData and routeDefaultValueData.wayPoints or {}

function AIUtils.getActorIdFromContext(actorId, context)
	if actorId == nil or actorId == 0 then
		actorId = context._entActorId
	end

	return actorId
end

function AIUtils.checkEntCanBeEnemy(ent)
	if ent == nil then
		return false
	end

	if ent.isDead and ent:isDead() then
		return false
	end

	if ent.isFakeDead and ent:isFakeDead() then
		return false
	end

	if ent.PET_PROTECTED_ST and ent:PET_PROTECTED_ST() then
		return false
	end

	if Utils.isPet(ent, true) and not ent.isSummon then
		return false
	end

	if ent.attaching and ent:attaching() then
		return false
	end

	if ent.syncEntityRole == 1 and ent.authorityId ~= ent.space.ownerPlayerId then
		return false
	end

	return true
end

function AIUtils.checkEntInLowHpPercent(ent)
	if ent == nil then
		return false
	end

	return ent.actorCombatAttribute:getHpRatio() <= AiConst.CatchMode_LowHPPercent
end

function AIUtils.checkEntCanBeEnemyInCatchMode(ent)
	return AIUtils.checkEntCanBeEnemy(ent) and not AIUtils.checkEntInLowHpPercent(ent)
end

function AIUtils.getCombatPlayerEnemyActorId(puppetEnt, lockedEnt)
	local pet = lockedEnt:getCurPetEntity()

	if Utils.checkClient() then
		if pet and not pet:PET_PROTECTED_ST() and (lockedEnt:isControllingPet() or puppetEnt.hatePet[lockedEnt.actorId]) then
			return pet.actorId
		end
	elseif pet and (lockedEnt:isControllingPet() or puppetEnt.hatePet[lockedEnt.actorId]) then
		return pet.actorId
	end

	return lockedEnt.actorId
end

function AIUtils.getPuppetTarget(puppetEnt, range)
	if EnableBotTest then
		return
	end

	if puppetEnt.space:isMultiPlayerEnv() then
		return AIUtils.getPuppetTargetInMultiPlayerEnv(puppetEnt, range)
	else
		local lockActorId = puppetEnt:getAttackTargetActorId()
		local lockedEnt = pg.getEntityByActorId(lockActorId)

		if Utils.isPlayer(lockedEnt) then
			return AIUtils.getCombatPlayerEnemyActorId(puppetEnt, lockedEnt)
		elseif AIUtils.checkEntCanBeEnemy(lockedEnt) then
			return lockActorId
		end

		lockActorId = Utils.isVirtualEntity(puppetEnt) and 0 or AIUtils.getCombatTargetByHate(puppetEnt, range, AIUtils.checkEntCanBeEnemy)

		if lockActorId == 0 then
			lockActorId = AIUtils.getCombatTargetByBehatredMap(puppetEnt, range, AIUtils.checkEntCanBeEnemy)
		end

		lockedEnt = pg.getEntityByActorId(lockActorId)

		if Utils.isPlayer(lockedEnt) then
			return AIUtils.getCombatPlayerEnemyActorId(puppetEnt, lockedEnt)
		elseif Utils.isPet(lockedEnt) and not lockedEnt.isSummon then
			local playerEnt = lockedEnt:getMasterEntity()
			local currentSummonPet = playerEnt:getCurPetEntity()

			return currentSummonPet and currentSummonPet.actorId or 0
		elseif Utils.isBotPlayer(lockedEnt) then
			local pet = lockedEnt:getCurPetEntity()

			if pet then
				return pet.actorId
			end
		end

		return lockActorId
	end
end

function AIUtils.getPuppetTargetInMultiPlayerEnv(puppetEnt, range)
	local hateMode = puppetEnt:getConfigData().hateMode

	if hateMode == AbilityConst.HATE_MODE.Team_Hate_Mode_Duty_First then
		local tankActorEnt = pg.getEntityByActorId(Utils.getCurTankActorId(puppetEnt.space))

		if AIUtils.checkEntCanBeEnemy(tankActorEnt) then
			return tankActorEnt.actorId
		end
	elseif hateMode == AbilityConst.HATE_MODE.Team_Hate_Mode_Equal then
		local lockHatredTargetEndTime = puppetEnt.lockHatredTargetEndTime or 0

		if lockHatredTargetEndTime > puppetEnt:getGameTime() then
			return puppetEnt:getAttackTargetActorId()
		end
	end

	local lockActorId = Utils.isVirtualEntity(puppetEnt) and 0 or AIUtils.getCombatTargetByHate(puppetEnt, range, AIUtils.checkEntCanBeEnemy)

	if lockActorId == 0 then
		lockActorId = AIUtils.getCombatTargetByBehatredMap(puppetEnt, range, AIUtils.checkEntCanBeEnemy)
	end

	lockActorId = AIUtils.getCombatTargetByDuty(puppetEnt, lockActorId)

	local lockedEnt = pg.getEntityByActorId(lockActorId)

	if Utils.isPet(lockedEnt) then
		lockedEnt = lockedEnt.master
	end

	if Utils.isPlayer(lockedEnt) then
		return AIUtils.getCombatPlayerEnemyActorId(puppetEnt, lockedEnt)
	end

	if Utils.isBotPlayer(lockedEnt) then
		local pet = lockedEnt:getCurPetEntity()

		if pet then
			return pet.actorId
		end
	end

	return lockActorId
end

function AIUtils.getBotPlayerTarget(ent, range)
	local targetActorId = AIUtils.getCombatTargetByHate(ent, range, AIUtils.checkEntCanBeEnemy)

	if targetActorId == 0 then
		targetActorId = AIUtils.getCombatTargetByBehatredMap(ent, range, AIUtils.checkEntCanBeEnemy)
	end

	if targetActorId == 0 then
		targetActorId = AIUtils.getCombatTargetByViewHatredMap(ent, range, AIUtils.checkEntCanBeEnemy)
	end

	return targetActorId
end

function AIUtils.resetCombatTargetPlayerToControllingPet(actorId)
	local targetEnt = pg.getEntityByActorId(actorId)

	if (Utils.isPlayer(targetEnt) or Utils.isBotPlayer(targetEnt)) and targetEnt:isControllingPet() then
		return targetEnt:getCurPetEntity().actorId or 0
	else
		return actorId
	end
end

function AIUtils.getCombatTargetByHate(ent, range, filterFunc)
	if ent.forceLock ~= 0 then
		local targetEnt = pg.getEntityByActorId(ent.forceLock)

		if targetEnt ~= nil then
			return ent.forceLock
		end
	end

	return AIUtils.getCombatTargetByHateList(ent, range, filterFunc)
end

function AIUtils.getCombatTargetByDuty(ent, targetActorId)
	local hateMode = ent:getConfigData().hateMode

	if hateMode == AbilityConst.HATE_MODE.Team_Hate_Mode_Duty_First then
		local targetEnt = pg.getEntityByActorId(targetActorId)

		if targetEnt and (Utils.isPlayer(targetEnt) or Utils.isPet(targetEnt)) then
			if Utils.isPet(targetEnt) then
				targetEnt = targetEnt.master
			end

			if Utils.isPlayer(targetEnt) then
				local targetPlayer = targetEnt
				local curPet = targetPlayer:getCurPetEntity()

				if curPet and curPet:getConfigData().functionId == "TANK" and AIUtils.checkEntCanBeEnemy(curPet) then
					return curPet.actorId
				end
			end

			local teamMemberInfo = Utils.checkClient() and pg.me:getCurTeamMemberInfo() or targetEnt:getCurTeamMemberInfo()

			for _, member in pairs(teamMemberInfo) do
				local memberPlayer = pg.getEntity(member.entityId)
				local curPet = memberPlayer and memberPlayer:getCurPetEntity()

				if curPet and curPet:getConfigData().functionId == "TANK" and AIUtils.checkEntCanBeEnemy(curPet) then
					return curPet.actorId
				end
			end
		end
	end

	return targetActorId
end

function AIUtils.getCombatTargetByHateList(ent, range, filterFunc)
	local entId = 0
	local maxHateValue = 0
	local hatredMap = ent:getHatred()
	local myPos = ent:getPosition()
	local hateMode = ent:getConfigData().hateMode

	if hateMode == AbilityConst.HATE_MODE.Team_Hate_Mode_Duty_First or hateMode == AbilityConst.HATE_MODE.Team_Hate_Mode_Default then
		local currentAttackEntActorId = ent:getAttackTargetActorId()
		local currentHateValue = hatredMap[currentAttackEntActorId] or 0

		maxHateValue = currentHateValue * (1 + SysConfigData.teamHateSwitchTargetOverRatio)
		entId = currentAttackEntActorId
	end

	for id, hateValue in pairs(hatredMap) do
		local targetEnt = pg.getEntityByActorId(id)

		if targetEnt ~= nil then
			local entPos = targetEnt:getPosition()

			if maxHateValue < hateValue and (not filterFunc or filterFunc(targetEnt)) and (not range or range >= 0 or Utils.squareDist(myPos, entPos) < range * range) then
				maxHateValue = hateValue
				entId = id
			end
		end
	end

	if entId == 0 then
		for id, viewHatred in pairs(ent.viewHatredMap or EMPTY_TABLE) do
			local targetEnt = pg.getEntityByActorId(id)

			if targetEnt ~= nil then
				local entPos = targetEnt:getPosition()

				if maxHateValue < viewHatred and (not filterFunc or filterFunc(targetEnt)) and (not range or range >= 0 or Utils.squareDist(myPos, entPos) < range * range) then
					maxHateValue = viewHatred
					entId = id
				end
			end
		end
	end

	return entId
end

function AIUtils.getCombatTargetByBehatredMap(ent, range, filterFunc)
	local entId = 0
	local behatredMap = ent:getBehatredMap()
	local minDistance = math_maxFloat
	local myPos = ent:getPosition()

	for id, _ in pairs(behatredMap) do
		local targetEnt = pg.getEntityByActorId(id)

		if targetEnt ~= nil then
			local entPos = targetEnt:getPosition()
			local distance = Utils.squareDist(myPos, entPos)

			if distance < minDistance and (not filterFunc or filterFunc(targetEnt)) and (not range or range == 0 or distance < range * range) then
				minDistance = distance
				entId = id
			end
		end
	end

	return entId
end

function AIUtils.getCombatTargetByMasterAOI(ent, filterFunc)
	local masterEnt = ent:getMasterEntity()
	local masterPos = masterEnt:getPosition()
	local minDistance = math_maxFloat
	local puppetList = ListPool.getList(3)
	local count = AIUtils.SearchEntitiesInRangeWithCache(masterEnt, AiConst.InvadeMode_PetCombatRange, Const.SEARCH_USR_TYPE_MONSTER, puppetList)
	local targetEntActorId = 0

	for i = 1, count do
		local actorId = puppetList[i]
		local puppetEnt = pg.getEntityByActorId(actorId)

		if puppetEnt and Utils.isEnemy(ent, puppetEnt) then
			local entPos = puppetEnt:getPosition()
			local distance = Utils.squareDist(masterPos, entPos)

			if distance < minDistance and (not filterFunc or filterFunc(puppetEnt)) and distance < AiConst.InvadeMode_PetCombatRange * AiConst.InvadeMode_PetCombatRange then
				targetEntActorId = actorId
				minDistance = distance
			end
		end
	end

	ListPool.returnList(puppetList, 3)

	return targetEntActorId
end

function AIUtils.getCombatTargetByViewHatredMap(ent, filterFunc)
	if not ent then
		return 0
	end

	for actorId, viewHatred in pairs(ent.viewHatredMap or AiConst.DefaultNullTable) do
		local targetEnt = pg.getEntityByActorId(actorId)

		if targetEnt ~= nil and Utils.isEnemy(ent, targetEnt) and (not filterFunc or filterFunc(targetEnt)) then
			return actorId
		end
	end

	return 0
end

function AIUtils.checkEntCanBeEnemyByActorId(entActorId)
	return AIUtils.checkEntCanAttack(pg.getEntityByActorId(entActorId))
end

function AIUtils.checkEntCanBeUseSkill(ent)
	if not AIUtils.checkEntCanBeEnemy(ent) then
		return false
	end

	if ent.isBreak and ent:isBreak() then
		return false
	end

	return true
end

function AIUtils.checkEntIsInLeave(ent)
	return ent.hasAITag and ent:hasAITag("TA_Percept_Leave")
end

function AIUtils.checkAIPlanCanBreak(ent, curPlan, newPlanData, newBehaviorId)
	if newPlanData == nil then
		return false
	end

	if not ent:checkAIPlanCD(newBehaviorId) then
		return false
	end

	if curPlan == nil then
		return true
	end

	return AIUtils.checkAIPlanCanBreakByPriority(curPlan, newPlanData.priority, newBehaviorId)
end

function AIUtils.checkAIPlanCanBreakByPriority(curPlan, newPriority, newBehaviorId)
	local interruptType = curPlan:getInterruptType()
	local curBehaviorId = curPlan:getID()
	local curPlanPriority = curPlan:getPriority()
	local beInterrupted = false

	if bit.band(interruptType, AiConst.AIBeInterruptedType.CanInterruptedByHighPriority) ~= 0 then
		beInterrupted = beInterrupted or curPlanPriority < newPriority
	end

	if bit.band(interruptType, AiConst.AIBeInterruptedType.CanInterruptedByEP) ~= 0 then
		beInterrupted = beInterrupted or curPlanPriority == newPriority and curBehaviorId ~= newBehaviorId
	end

	if bit.band(interruptType, AiConst.AIBeInterruptedType.CanInterruptedBySelf) ~= 0 then
		beInterrupted = beInterrupted or curBehaviorId == newBehaviorId
	end

	return beInterrupted
end

function AIUtils.checkAdditiveAIPlanCanRun(ent)
	return
end

function AIUtils.PauseAI(entId, reason)
	local ent = pg.getEntity(entId)

	if ent and ent.pauseBt then
		ent:pauseBt(reason)
	end
end

function AIUtils.ResumeAI(entId, reason)
	local ent = pg.getEntity(entId)

	if ent and ent.resumeBt then
		ent:resumeBt(reason)
	end
end

function AIUtils.getMoveUpdateTimeout(moveUpdateLevel)
	return 0.1 * moveUpdateLevel
end

function AIUtils.getAITickCount(entity)
	if Utils.checkClient() then
		if pg.me:isTeamPlayerInWorld() then
			local lodLevel = AiConst.LOD.VeryLow

			for _, memberInfo in pairs(pg.me:getCurTeamInfo().membersInfo) do
				lodLevel = math_min(lodLevel, AIUtils.getAILodLevel(entity, pg.getEntity(memberInfo.entityId)))
			end

			return lodLevel
		else
			return AIUtils.getAILodLevel(entity, pg.me)
		end
	else
		return AiConst.LOD.High
	end
end

function AIUtils.getAILodLevel(entity, player)
	if player then
		local playerDistance = entity:getPlayerDistance()

		if playerDistance < 30 then
			return AiConst.LOD.High
		elseif playerDistance < 50 then
			return AiConst.LOD.Mid
		elseif playerDistance < 70 then
			return AiConst.LOD.Low
		else
			return AiConst.LOD.VeryLow
		end
	end

	return AiConst.LOD.VeryLow
end

function AIUtils.getAITickTriggerMultiByLod(entity, tickTriggerLod)
	if (Utils.isBoss(entity) or Utils.isPet(entity)) and tickTriggerLod == AiConst.TICK_TRIGGER_LOD.VeryLow then
		return AiConst.TICK_TRIGGER_LOD.VeryLow * 2
	end

	return tickTriggerLod
end

function AIUtils.getAITickInterval(entity)
	if Utils.isBoss(entity) or Utils.isPet(entity) then
		return AiConst.TICK_INTERVAL.Special
	end

	return AiConst.TICK_INTERVAL.Normal
end

function AIUtils.tickTriggerExec(entity, tickLodTriggerBehaviourIdMap, triggerFuncName)
	local tickLodTriggerCount = tickLodTriggerBehaviourIdMap.tickLodTriggerCount

	tickLodTriggerCount = tickLodTriggerCount + 1

	local triggerFunc = entity[triggerFuncName]
	local highIndex = 1
	local midIndex = tickLodTriggerCount % AIUtils.getAITickTriggerMultiByLod(entity, AiConst.TICK_TRIGGER_LOD.Mid) == 0 and 1 or math_maxInt
	local lowIndex = tickLodTriggerCount % AIUtils.getAITickTriggerMultiByLod(entity, AiConst.TICK_TRIGGER_LOD.Low) == 0 and 1 or math_maxInt
	local veryLowIndex = tickLodTriggerCount % AIUtils.getAITickTriggerMultiByLod(entity, AiConst.TICK_TRIGGER_LOD.VeryLow) == 0 and 1 or math_maxInt
	local highLen = #tickLodTriggerBehaviourIdMap[AiConst.TICK_TRIGGER_LOD.High]
	local midLen = #tickLodTriggerBehaviourIdMap[AiConst.TICK_TRIGGER_LOD.Mid]
	local lowLen = #tickLodTriggerBehaviourIdMap[AiConst.TICK_TRIGGER_LOD.Low]
	local veryLowLen = #tickLodTriggerBehaviourIdMap[AiConst.TICK_TRIGGER_LOD.VeryLow]
	local execList = ListPool.getList(3)

	while highIndex <= highLen or midIndex <= midLen or lowIndex <= lowLen or veryLowIndex <= veryLowLen do
		local behaviourID, indexBelong, currentBehaviorPriority

		if highIndex <= highLen then
			behaviourID = tickLodTriggerBehaviourIdMap[AiConst.TICK_TRIGGER_LOD.High][highIndex]
			indexBelong = AiConst.TICK_TRIGGER_LOD.High
			currentBehaviorPriority = ParmonBehaivorData[behaviourID].priority
		end

		if midIndex <= midLen then
			local midBehaviourID = tickLodTriggerBehaviourIdMap[AiConst.TICK_TRIGGER_LOD.Mid][midIndex]
			local midBehaviorPriority = ParmonBehaivorData[midBehaviourID].priority

			if not currentBehaviorPriority or currentBehaviorPriority < midBehaviorPriority then
				behaviourID = midBehaviourID
				indexBelong = AiConst.TICK_TRIGGER_LOD.Mid
				currentBehaviorPriority = midBehaviorPriority
			end
		end

		if lowIndex <= lowLen then
			local lowBehaviourID = tickLodTriggerBehaviourIdMap[AiConst.TICK_TRIGGER_LOD.Low][lowIndex]
			local lowBehaviorPriority = ParmonBehaivorData[lowBehaviourID].priority

			if not currentBehaviorPriority or currentBehaviorPriority < lowBehaviorPriority then
				behaviourID = lowBehaviourID
				indexBelong = AiConst.TICK_TRIGGER_LOD.Low
				currentBehaviorPriority = lowBehaviorPriority
			end
		end

		if veryLowIndex <= veryLowLen then
			local veryLowBehaviourID = tickLodTriggerBehaviourIdMap[AiConst.TICK_TRIGGER_LOD.VeryLow][veryLowIndex]
			local veryLowBehaviorPriority = ParmonBehaivorData[veryLowBehaviourID].priority

			if not currentBehaviorPriority or currentBehaviorPriority < veryLowBehaviorPriority then
				behaviourID = veryLowBehaviourID
				indexBelong = AiConst.TICK_TRIGGER_LOD.VeryLow
				currentBehaviorPriority = veryLowBehaviorPriority
			end
		end

		execList[#execList + 1] = CallbackHandlerNoGC.newOnce(entity, triggerFunc, behaviourID, AiConst.TICK_TRIGGER_LOD_NAME, CTRConst.NodeBaseType.TickLodTrigger)

		if indexBelong == AiConst.TICK_TRIGGER_LOD.High then
			highIndex = highIndex + 1
		elseif indexBelong == AiConst.TICK_TRIGGER_LOD.Mid then
			midIndex = midIndex + 1
		elseif indexBelong == AiConst.TICK_TRIGGER_LOD.Low then
			lowIndex = lowIndex + 1
		elseif indexBelong == AiConst.TICK_TRIGGER_LOD.VeryLow then
			veryLowIndex = veryLowIndex + 1
		else
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("@cyj 数据有问题！")
			end

			break
		end
	end

	for _, exec in ipairs(execList) do
		exec()
	end

	ListPool.returnList(execList, 3)

	if tickLodTriggerCount >= AiConst.TICK_TRIGGER_LOD.AllMulti then
		tickLodTriggerCount = 0
	end

	tickLodTriggerBehaviourIdMap.tickLodTriggerCount = tickLodTriggerCount
end

function AIUtils.registerAITrigger(entity, entityMotionState, entityAgentRootState, eventEmitter, behaviourID, tickLodTriggerBehaviourIdMap, debugRegisteredGraphs, triggerFuncName, ignoreCheck, debugRegisteredBehaviorIds)
	local graphData = ParmonBehaivorData[behaviourID]

	if graphData == nil then
		return
	end

	if not ignoreCheck and (not AIUtils.checkAIBindMotionState(graphData.bindMotionStateReverse, entityMotionState) or not AIUtils.checkAIRootState(graphData.bindAiStateReverse, entityAgentRootState)) then
		return
	end

	if graphData.isGroupBehav == 1 then
		local curGroupBehaviour = entity:getCurrentGroupBehaviour()

		if not curGroupBehaviour or curGroupBehaviour.parmonBehavId ~= behaviourID then
			return
		end
	end

	local ctrGraphId = graphData.triggerAndCondition

	if debugRegisteredGraphs then
		debugRegisteredGraphs[#debugRegisteredGraphs + 1] = ctrGraphId
	end

	if debugRegisteredBehaviorIds then
		debugRegisteredBehaviorIds[#debugRegisteredBehaviorIds + 1] = behaviourID
	end

	local kEventTrigger = CTRConst.NodeBaseType.EventTrigger
	local kMessageTrigger = CTRConst.NodeBaseType.MessageTrigger
	local eventList, messageList, tickLodTriggerLevel = CTUtils.getGraphTriggers(ctrGraphId)

	for i = 1, #eventList do
		local eventName = eventList[i]

		eventEmitter:addEventListener(eventName, CallbackHandlerNoGC.new(entity, triggerFuncName, behaviourID, eventName, kEventTrigger))
	end

	for i = 1, #messageList do
		local messageName = messageList[i]

		eventEmitter:addEventListener(messageName, CallbackHandlerNoGC.new(entity, triggerFuncName, behaviourID, messageName, kMessageTrigger))
	end

	if tickLodTriggerLevel > 0 then
		local lodList = tickLodTriggerBehaviourIdMap[tickLodTriggerLevel]

		lodList[#lodList + 1] = behaviourID
	end
end

function AIUtils.unregisterAITrigger(entity, eventEmitter, tickLodTriggerBehaviourIdMap, debugRegisteredGraphs, debugRegisteredBehaviorIds)
	if eventEmitter then
		eventEmitter:removeAllListeners()
	end

	table.clearArray(tickLodTriggerBehaviourIdMap[AiConst.TICK_TRIGGER_LOD.High])
	table.clearArray(tickLodTriggerBehaviourIdMap[AiConst.TICK_TRIGGER_LOD.Mid])
	table.clearArray(tickLodTriggerBehaviourIdMap[AiConst.TICK_TRIGGER_LOD.Low])
	table.clearArray(tickLodTriggerBehaviourIdMap[AiConst.TICK_TRIGGER_LOD.VeryLow])

	tickLodTriggerBehaviourIdMap.tickLodTriggerCount = 0

	if debugRegisteredGraphs then
		table.clearArray(debugRegisteredGraphs)
	end

	if debugRegisteredBehaviorIds then
		table.clearArray(debugRegisteredBehaviorIds)
	end
end

function AIUtils.checkAIBindMotionState(bindMotionStateList, myMotionState)
	return bindMotionStateList == nil or bindMotionStateList[CharacterStateConst[myMotionState].name] ~= nil
end

function AIUtils.checkAIRootState(aiRootStateValue, myRootState)
	return aiRootStateValue == nil or aiRootStateValue[EBTRootState_NAME[myRootState]] ~= nil
end

function AIUtils.setDebugEnt(actorId)
	AiConst.AI_DEBUG.ENT_ID = actorId or 0
end

function AIUtils.checkDebugEnt(actorId)
	return AiConst.AI_DEBUG.MODE and AiConst.AI_DEBUG.ENT_ID == actorId
end

function AIUtils.checkAINodeDebug(actorId)
	return AiConst.AI_DEBUG.MODE and AiConst.AI_DEBUG.NODE_LOG.Enable and AiConst.AI_DEBUG.NODE_LOG.EntId == actorId
end

function AIUtils.setAINodeDebug(actorId)
	if AiConst.AI_DEBUG.MODE then
		AiConst.AI_DEBUG.NODE_LOG.Enable = true
		AiConst.AI_DEBUG.NODE_LOG.EntId = actorId
	end
end

function AIUtils.enterCombat(entity, targetActorId)
	if entity and entity.isAIRunning and entity:isAIRunning() then
		entity.agent:enterCombat(targetActorId)
	end
end

function AIUtils.exitCombat(entity)
	if entity and entity.isAIRunning and entity:isAIRunning() then
		entity.agent:resetRootState()
	end
end

function AIUtils.onSetGoHome(entity, going)
	if entity.agent == nil then
		return false
	end

	if going then
		AIUtils.enterGoHome(entity)
	else
		AIUtils.resetRootState(entity)
	end
end

function AIUtils.enterGoHome(entity)
	if entity and entity.isAIRunning and entity:isAIRunning() then
		entity.agent:enterGoHome()
	end
end

function AIUtils.enterIdle(entity)
	if entity and entity.isAIRunning and entity:isAIRunning() then
		entity.agent:resetRootState()
	end
end

function AIUtils.enterFollow(entity, followTarget)
	if entity and entity.isAIRunning and entity:isAIRunning() then
		entity.agent:enterFollow(followTarget)
	end
end

function AIUtils.enterGuide(entity, targetActorId)
	if entity and entity.isAIRunning and entity:isAIRunning() then
		entity.agent:enterGuide(targetActorId)
	end
end

function AIUtils.exitGuide(entity)
	if entity and entity.isAIRunning and entity:isAIRunning() then
		entity.agent:exitGuide()
	end
end

function AIUtils.enterRecruit(entity, targetActorId)
	if entity and entity.isAIRunning and entity:isAIRunning() then
		entity.agent:enterRecruit(targetActorId)
	end
end

function AIUtils.enterAlert(entity)
	if entity and entity.isAIRunning and entity:isAIRunning() then
		entity.agent:enterAlert()
	end
end

function AIUtils.enterSensed(entity)
	if entity and entity.isAIRunning and entity:isAIRunning() then
		entity.agent:enterSensed()
	end
end

function AIUtils.enterAfk(entity)
	if entity and entity.isAIRunning and entity:isAIRunning() then
		entity.agent:enterAfk()
	end
end

function AIUtils.resetRootState(entity)
	if entity and entity.isAIRunning and entity:isAIRunning() then
		local aiAgent = entity.agent

		if Utils.isPet(entity) then
			local masterEnt = entity.master

			if not Utils.isBotPet(entity) then
				if entity.isInCombat and entity:isInCombat() == true then
					aiAgent:enterCombat()
				elseif masterEnt and masterEnt:checkCommandPetAIState() then
					aiAgent:enterWait()
				elseif masterEnt and masterEnt:AFK_ST() then
					aiAgent:enterAfk()
				else
					aiAgent:enterFollow()
				end
			elseif entity.isInCombat and entity:isInCombat() == true then
				aiAgent:enterCombat()
			else
				aiAgent:enterFollow()
			end
		elseif Utils.isHomePet(entity) then
			aiAgent:enterHomeLand()
		elseif Utils.isBotPlayer(entity) then
			if entity.isInCombat and entity:isInCombat() == true then
				aiAgent:enterCombat()
			else
				aiAgent:enterIdle()
			end
		elseif entity.isInGoHome then
			aiAgent:enterGoHome()
		elseif entity.isInCombat and entity:isInCombat() == true then
			aiAgent:enterCombat()
		elseif not string.isNilOrEmpty(entity.slavesOwnerId) then
			local masterEntity = pg.getEntity(entity.slavesOwnerId)

			aiAgent:enterRecruit(masterEntity and masterEntity.actorId or 0)
		else
			local senseState = entity.perceptibility and entity.perceptibility.senseState or PerceptibilityConst.SenseState.None

			if senseState == PerceptibilityConst.SenseState.None then
				aiAgent:resetRootState(entity.agent:getRootState())
			elseif senseState == PerceptibilityConst.SenseState.Alert then
				aiAgent:enterAlert(true)
			elseif senseState == PerceptibilityConst.SenseState.Sensed then
				aiAgent:enterSensed(true)
			end
		end
	end
end

function AIUtils.petAttractHatre(entity, targetActorId)
	AIUtils.attackTarget(entity, targetActorId)

	local context = CTRPool.getContext()

	context.enemyId = targetActorId

	AIControllerUtils.sendAIEvent(entity, "ProtectMasterMsgTrigger", context)
end

function AIUtils.attackTarget(entity, targetActorId, partId)
	if LoggerManager.checkLogger(LoggerConst.DEBUG, "AI") then
		local oldLockTargetActorId = entity:getAttackTargetActorId() or 0
		local oldEnt = pg.getEntityByActorId(oldLockTargetActorId)

		if oldEnt and Utils.isPet(oldEnt) then
			oldLockTargetActorId = oldEnt.master.actorId
		end

		local curEnt = pg.getEntityByActorId(targetActorId)
		local newTargetActorId = targetActorId

		if curEnt and Utils.isPet(curEnt) then
			newTargetActorId = curEnt.master.actorId
		end

		if newTargetActorId ~= oldLockTargetActorId then
			local hatredMap = entity:getHatred()

			logger:debug("@cyj shd %s 改变攻击目标: 由%s,仇恨值(%s) --> %s,仇恨值(%s),当前所有仇恨table:%s", entity.actorId, oldLockTargetActorId, hatredMap[oldLockTargetActorId] or 0, newTargetActorId, hatredMap[newTargetActorId] or 0, inspect(hatredMap))
		end
	end

	entity:lockTarget(targetActorId, partId, nil, true)
end

function AIUtils.releaseAttackTarget(entity)
	if entity.unlockTarget then
		entity:unlockTarget(true)
	end
end

function AIUtils.petCommandUltimateSkill(entity)
	if entity:isAIRunning() then
		local context = CTRPool.getContext()
		local agent = entity.agent

		context.tSkillTargetActorId = agent:getTarget()
		context.tSkillId = agent:getUltimateSkillId()

		AIControllerUtils.sendAIEvent(entity, "CastSkillMsgTrigger", context)

		return true
	end

	return false
end

function AIUtils.checkHasPerceptibility(entity)
	if (Utils.isNpc(entity) or Utils.isPuppet(entity)) and entity:getConfigData().attackType == 0 then
		return true
	end

	if Utils.isPet(entity) then
		return true
	end

	return false
end

function AIUtils.checkMimicryBlockPercept(entity)
	if not entity then
		return false
	end

	local config = entity:getConfigData()

	if config and config.mimicryBlockPercept then
		return true
	end

	return false
end

function AIUtils.getBehaviorState(ent)
	return ent and ent.behaviorState
end

function AIUtils.getBehaviorStateName(entity)
	return BehaviorPathMapData.EnumMap[AIUtils.getBehaviorState(entity)]
end

function AIUtils.pauseBt(entity, reason)
	if entity and entity.pauseBt then
		entity:pauseBt(reason)
	end
end

function AIUtils.resumeBt(entity, reason)
	if entity and entity.resumeBt then
		entity:resumeBt(reason)
	end
end

function AIUtils.resumePerception(entity, reason)
	if entity.resumePerceptibility then
		entity:resumePerceptibility(reason)
	end
end

function AIUtils.pausePerception(entity, reason)
	if entity.pausePerceptibility then
		entity:pausePerceptibility(reason)
	end
end

function AIUtils.getMimicryState(entity)
	if CharacterStateConst.isMimicryState(entity.characterState) then
		local mimicryType = entity:getConfigData().mimicryType

		if mimicryType and mimicryType > 0 then
			return mimicryType
		else
			return AiConst.MimicryState.Defense
		end
	end

	return AiConst.MimicryState.None
end

function AIUtils.getPatrolData(ent, dataId)
	local sceneId = ent.space and ent.space.sceneId
	local spaceId = ent.space and ent.space.id
	local sceneClimbData = SceneUtils.getSceneClimbData(sceneId, spaceId)
	local climbData = sceneClimbData[dataId]
	local flag, posX, posY, posZ, angleX, angleY, angleZ

	if climbData then
		posX = climbData.position[1]
		posY = climbData.position[2]
		posZ = climbData.position[3]
		angleX = climbData.rotation[1]
		angleY = climbData.rotation[2]
		angleZ = climbData.rotation[3]
	elseif Utils.checkClient() then
		local entPos = ent:getPosition()

		flag, posX, posY, posZ, angleX, angleY, angleZ = pg.global.aiClimbMgr:GetClimbTreeData(dataId, entPos.x, entPos.y, entPos.z)

		if flag then
			local ClimbTreeData = require("Data.climb_tree_data")

			climbData = ClimbTreeData[dataId]
		end
	end

	if not climbData then
		logger:warn("climb tree plan init error: data not exist, dataId: %s", dataId)
	end

	return climbData, posX, posY, posZ, angleX, angleY, angleZ
end

function AIUtils.searchInteractEnvObj(entityActorId)
	if not Utils.checkClient() then
		return 0, 0, 0
	end

	local targetActorId = 0
	local interactAbilityId = 0
	local targetInteractEnt
	local targetInView = false
	local entity = pg.getEntityByActorId(entityActorId)
	local isPlayerGo = Utils.isPawnFollowPet(entity)

	if entity and entity.getNoImpPerceivedMap then
		local perceivedNoImpList = entity:getNoImpPerceivedMap(Const.SEARCH_USR_TYPE_AI_INTERACT)
		local highestOrder = 0

		for _, actorId in ipairs(perceivedNoImpList) do
			local ent = pg.getEntityByActorId(actorId)

			if ent then
				local entPos = ent:getPosition()

				if Utils.isEnvObj(ent) and Utils.checkValidLock(ent) then
					local tagList = clientEcsUtils.getChemTagList(ent, ListPool.getList())
					local newTagTable = TablePool.getTable()

					for _, tagName in ipairs(tagList) do
						newTagTable[tagName] = true
					end

					for _, tagName in ipairs(tagList) do
						local envObjInteractInfo = InteractTagData[tagName]
						local overrideTagTable = envObjInteractInfo.overrideTag

						if newTagTable[tagName] and overrideTagTable then
							for _, tTagName in ipairs(tagList) do
								local overrideTag = overrideTagTable[tTagName]

								if overrideTag then
									newTagTable[tTagName] = nil

									break
								end
							end
						end
					end

					local entInView = false

					if isPlayerGo then
						entInView = pg.game.camera:checkInViewport(entPos)
					end

					for tagName, _ in pairs(newTagTable) do
						local envObjInteractInfo = InteractTagData[tagName]
						local envObjOrder = envObjInteractInfo.order
						local tInteractAbilityId = AbilityUtils.findInteractAbility(entity, tagName)

						if tInteractAbilityId ~= 0 then
							local isBetter = false

							if isPlayerGo then
								if entInView and not targetInView then
									isBetter = true
								elseif entInView == targetInView then
									if highestOrder < envObjOrder then
										isBetter = true
									elseif envObjOrder == highestOrder then
										isBetter = Vector3.SqrDistance(entPos, entity:getPosition()) < Vector3.SqrDistance(targetInteractEnt:getPosition(), entity:getPosition())
									end
								end
							elseif highestOrder < envObjOrder then
								isBetter = true
							elseif envObjOrder == highestOrder then
								isBetter = Vector3.SqrDistance(entPos, entity:getPosition()) < Vector3.SqrDistance(targetInteractEnt:getPosition(), entity:getPosition())
							end

							if isBetter then
								targetActorId = actorId
								highestOrder = envObjOrder
								interactAbilityId = tInteractAbilityId
								targetInteractEnt = ent
								targetInView = entInView

								if LoggerManager.checkLogger(LoggerConst.DEBUG, "AI") then
									logger:debug("@cyj SearchInteractEnvObj", targetActorId, tagName, highestOrder, interactAbilityId, targetInView)
								end
							end
						end
					end

					TablePool.returnTable(newTagTable)
					ListPool.returnList(tagList)
				end
			end
		end
	end

	return targetActorId, 0, interactAbilityId
end

function AIUtils.getEnvObjInteractAbility(entity, target)
	local highestOrder = 0
	local interactAbilityId = 0

	if Utils.isEnvObj(target) and Utils.checkValidLock(target) then
		local tagList = clientEcsUtils.getChemTagList(target, ListPool.getList())
		local newTagTable = TablePool.getTable()

		for _, tagName in ipairs(tagList) do
			newTagTable[tagName] = true
		end

		for _, tagName in ipairs(tagList) do
			local envObjInteractInfo = InteractTagData[tagName]
			local overrideTagTable = envObjInteractInfo.overrideTag

			if newTagTable[tagName] and overrideTagTable then
				for _, tTagName in ipairs(tagList) do
					local overrideTag = overrideTagTable[tTagName]

					if overrideTag then
						newTagTable[tTagName] = nil

						break
					end
				end
			end
		end

		for tagName, _ in pairs(newTagTable) do
			local envObjInteractInfo = InteractTagData[tagName]
			local envObjOrder = envObjInteractInfo.order
			local tInteractAbilityId = AbilityUtils.findInteractAbility(entity, tagName)

			if tInteractAbilityId ~= 0 and highestOrder < envObjOrder then
				highestOrder = envObjOrder
				interactAbilityId = tInteractAbilityId
			end
		end

		TablePool.returnTable(newTagTable)
		ListPool.returnList(tagList)
	end

	return interactAbilityId
end

function AIUtils.getPerceptibilitySearchEnt(entity)
	return Utils.isPet(entity) and entity:getMasterEntity() or entity
end

function AIUtils.clearCache()
	require("Common.AI.VisionAreaTemplateCache").clearCache()
	require("Common.AI.AIBehaviorGroupTemplate").clearCache()
end

function AIUtils.filterVisionPerceivedIsResponseFunc(sensor, entity)
	if not entity.isPerceptibilityResponse then
		return false, PerceptibilityConst.VisionFilterReason.NotResponse
	end

	return true
end

function AIUtils.filterNoImpVisionPerceivedIsResponseFunc(sensor, entity)
	if Utils.isPlayer(entity) then
		if not entity.isNoImpPerceptibilityResponse then
			return false, PerceptibilityConst.VisionFilterReason.NotResponse
		end
	elseif Utils.isPet(entity) then
		local masterEnt = entity.getMasterEntity and entity:getMasterEntity()

		if masterEnt and not masterEnt.isNoImpPerceptibilityResponse then
			return false, PerceptibilityConst.VisionFilterReason.NotResponse
		end
	end

	return true
end

local layerVisionPerceivedRayCastMask = bit.lshift(1, layer.eDefault) + bit.lshift(1, layer.eGround)

function AIUtils.filterVisionPerceivedRayCastFunc(sensor, entity)
	if sensor:checkPerceptibilityRayCast() then
		local ent = AIUtils.getPerceptibilitySearchEnt(sensor.ent)
		local selfPos = ent:getPosition()
		local selfX, selfY, selfZ = selfPos[1], selfPos[2], selfPos[3]
		local entGetHeightFunc = ent.getRealHeight or ent.getHeight

		selfY = selfY + entGetHeightFunc(ent) / 2

		local targetPos = entity:getPosition()
		local targetX, targetY, targetZ = targetPos[1], targetPos[2], targetPos[3]
		local entityGetHeightFunc = entity.getRealHeight or entity.getHeight

		targetY = targetY + entityGetHeightFunc(entity) / 2

		if Utils.checkClient() then
			if PhysicsUtils.checkLinecastXYZ(targetX, targetY, targetZ, selfX, selfY, selfZ, layerVisionPerceivedRayCastMask) then
				return false, PerceptibilityConst.VisionFilterReason.BlockedRayCast
			end
		else
			local hitRet, hitMask, hitPosX, hitPosY, hitPosZ = VoxelUtils.rayCast(entity, selfX, selfY, selfZ, targetX, targetY, targetZ)

			if hitRet then
				return false, PerceptibilityConst.VisionFilterReason.BlockedRayCast
			end
		end
	end

	return true
end

function AIUtils.filterControllingPetPlayer(sensor, entity)
	if Utils.isPlayer(entity) and entity:isControllingPet() then
		return false, PerceptibilityConst.VisionFilterReason.ControllingPet
	end

	return true
end

function AIUtils.filterVisionPerceivedInvisibleFunc(sensor, entity)
	if sensor:checkPerceptibilityInvisible() then
		if Utils.isPlayer(entity) then
			if entity:isControllingPet() then
				if entity:getCurPetEntity():CAMOUFLAGE_ST() then
					return false, PerceptibilityConst.VisionFilterReason.Invisible
				end
			elseif entity:CAMOUFLAGE_ST() then
				return false, PerceptibilityConst.VisionFilterReason.Invisible
			end
		elseif (Utils.isPet(entity) or Utils.isPuppet(entity)) and entity:CAMOUFLAGE_ST() then
			return false, PerceptibilityConst.VisionFilterReason.Invisible
		end
	end

	return true
end

function AIUtils.filterVisionPerceivedTallGrassFunc(sensor, entity)
	if sensor:checkPerceptibilityTallGrassSwitch() then
		if Utils.isPlayer(entity) and entity:isControllingPet() then
			if entity:getCurPetEntity().inGrass then
				return false, PerceptibilityConst.VisionFilterReason.SneakTallGrass
			end
		elseif entity.inGrass then
			return false, PerceptibilityConst.VisionFilterReason.SneakTallGrass
		end
	end

	return true
end

function AIUtils.filterVisionPerceivedSameSpeciesFunc(sensor, entity)
	local targetEntity = entity
	local ent = sensor.ent

	if Utils.isPlayer(entity) and entity:isControllingPet() then
		targetEntity = entity:getCurPetEntity()
	end

	if Utils.isPet(targetEntity) or Utils.isPuppet(targetEntity) then
		local tEthnicGroupVisionType = ent:getConfigData().ethnicGroupVisionType

		if tEthnicGroupVisionType == 1 then
			if Utils.IsSameSpecies(ent, targetEntity) then
				return false, PerceptibilityConst.VisionFilterReason.SameSpecies
			end
		elseif tEthnicGroupVisionType == 2 then
			return true, false
		elseif Utils.IsSameEthnicGroup(ent, targetEntity) then
			return false, PerceptibilityConst.VisionFilterReason.SameEthnicity
		end
	end

	return true, true
end

function AIUtils.filterVisionPerceivedFriendFunc(sensor, entity)
	local targetEntity = entity
	local ent = sensor.ent

	if Utils.isPlayer(entity) and entity:isControllingPet() then
		targetEntity = entity:getCurPetEntity()
	end

	if not targetEntity or AIUtils.checkPuppetFriendly(ent, targetEntity.actorId) then
		return false, PerceptibilityConst.VisionFilterReason.Friend
	end

	return true
end

function AIUtils.filterVisionPerceivedAffinityFunc(sensor, entity)
	if Utils.isPlayer(entity) and not entity:isControllingPet() and AIUtils.checkPuppetAffinity(sensor.ent, entity.actorId) then
		return false, PerceptibilityConst.VisionFilterReason.Affinity
	end

	return true
end

function AIUtils.filterHighVisionPerceivedFunc(sensor, entity)
	local ent = AIUtils.getPerceptibilitySearchEnt(sensor.ent)
	local entityPosition = entity:getPosition()
	local minePosition = ent:getPosition()
	local visionHeight = sensor:getPerceptibilityGroupDataProperty(PerceptibilityConst.PropertyName.visionHeight)

	if entityPosition.y - minePosition.y > visionHeight[1] and entityPosition.y - minePosition.y < visionHeight[2] then
		return true
	end

	return false, PerceptibilityConst.VisionFilterReason.HighVision
end

function AIUtils.filterDeadEntityFunc(entity)
	if AbilityUtils.checkEntityIsDead(entity) then
		return false, PerceptibilityConst.VisionFilterReason.Dead
	end

	return true
end

function AIUtils.getVisionPerceivedAreaMultiFunc(sensor, actorId)
	local ent = AIUtils.getPerceptibilitySearchEnt(sensor.ent)
	local targetEntity = pg.getEntityByActorId(actorId)
	local mineWorldLocation = ent:getPosition()
	local dirX, dirY, dirZ = ent:getRotation():MulVec3NoGC(Vector3.constForward)
	local entityWorldLocation = targetEntity:getPosition()
	local visionArea = sensor.VP_visionArea

	for tVisionAreaIndex, tVisionArea in ipairs(visionArea) do
		if calcUtils.isPointInAnnularSector(entityWorldLocation.x, entityWorldLocation.z, dirX, dirZ, mineWorldLocation.x, mineWorldLocation.z, tVisionArea.distanceStart, tVisionArea.distanceEnd, tVisionArea.angleStart, tVisionArea.angleEnd) then
			return visionArea[tVisionAreaIndex].multiple, tVisionAreaIndex
		end
	end
end

function AIUtils.filterVisionPerceivedHighGrassRegionFunc(sensor, entity)
	if entity.curHighGrassId ~= 0 then
		return false, PerceptibilityConst.VisionFilterReason.InHighGrassArea
	end

	return true
end

function AIUtils.filterVisionPerceivedBeAttachedFunc(sensor, entity)
	if entity.attaching and entity:attaching() then
		return false, PerceptibilityConst.VisionFilterReason.BeAttached
	end

	return true
end

local function testSmokeFunc(actorId)
	local ent = pg.getEntityByActorId(actorId)

	if not ent then
		return false
	end

	return ToBool(ent.isSmoke)
end

function AIUtils.filterVisionPerceivedSmokeFunc(sensor, entity)
	local selfEnt = AIUtils.getPerceptibilitySearchEnt(sensor.ent)

	if not pg.world.checkNoBlockedBySmoke(selfEnt.aoi, selfEnt:getPosition(), entity:getPosition(), testSmokeFunc) then
		return false, PerceptibilityConst.VisionFilterReason.SmokeBlock
	end

	return true
end

function AIUtils.filterPosFunc(sensor, entity)
	if AIUtils.getVisionPerceivedAreaMultiFunc(sensor, entity.actorId) then
		return true
	end

	return false, PerceptibilityConst.VisionFilterReason.AreaFilter
end

function AIUtils.filterPosFuncNoImp(sensor, entity)
	local ent = AIUtils.getPerceptibilitySearchEnt(sensor.ent)
	local mineWorldLocation = ent:getPosition()
	local entityWorldLocation = entity:getPosition()
	local sqrDist = Vector3.SqrDistance(mineWorldLocation, entityWorldLocation)

	if sqrDist <= sensor.VP_maxVisionDistance * sensor.VP_maxVisionDistance then
		return true
	end

	return false, PerceptibilityConst.VisionFilterReason.AreaFilter
end

function AIUtils.getEcologyEthnicData(subjectProtoTypeId, objectProtoTypeId)
	local behavId = (EcologyEthnicInteractRuleData[subjectProtoTypeId] or AiConst.DefaultNullTable)[objectProtoTypeId] or 0

	return EcologyEthnicInteractBehavData[behavId], behavId
end

function AIUtils.checkWayPointIsContinuity(wayPointData)
	local inexecutionAction = wayPointData.inexecutionAction or WAY_POINT_DEFAULTS.inexecutionAction
	local useOnlinePathFinding = wayPointData.useOnlinePathFinding or WAY_POINT_DEFAULTS.useOnlinePathFinding
	local behaviorPatrolMoveType = wayPointData.behaviorPatrolMoveType or WAY_POINT_DEFAULTS.behaviorPatrolMoveType

	return inexecutionAction and not useOnlinePathFinding and AIUtils.checkIsCommonPatrolMoveType(behaviorPatrolMoveType)
end

function AIUtils.checkIsCommonPatrolMoveType(behaviorPatrolMoveType)
	return behaviorPatrolMoveType == nil or behaviorPatrolMoveType == AiConst.EBehaviorPatrolMoveType.Common
end

function AIUtils.getContinuityWayPointList(targetIndex, rawWayPointListData, outWayPointList)
	outWayPointList = outWayPointList or {}

	table.clearArray(outWayPointList)

	local count = #rawWayPointListData

	while targetIndex <= count do
		local wayPointData = rawWayPointListData[targetIndex]

		if AIUtils.checkWayPointIsContinuity(wayPointData) then
			outWayPointList[#outWayPointList + 1] = wayPointData.position
			targetIndex = targetIndex + 1
		else
			local behaviorPatrolMoveType = wayPointData.behaviorPatrolMoveType or WAY_POINT_DEFAULTS.behaviorPatrolMoveType

			if AIUtils.checkIsCommonPatrolMoveType(behaviorPatrolMoveType) then
				outWayPointList[#outWayPointList + 1] = wayPointData.position

				break
			end

			targetIndex = targetIndex - 1

			break
		end
	end

	if count < targetIndex then
		targetIndex = count
	end

	return outWayPointList, targetIndex
end

function AIUtils.findCloseIndexInSplinePosList(entity, fromIndex, wayPointListData)
	local closeDist = math_maxInt
	local closeIndex = fromIndex
	local targetEntPos = entity:getPosition()
	local wayPointListCount = #wayPointListData

	while fromIndex <= wayPointListCount do
		local wayPointData = wayPointListData[fromIndex]

		if AIUtils.checkWayPointIsContinuity(wayPointData) then
			local tDist = Vector3.HoriSqrDistance(targetEntPos, wayPointData.position)

			if tDist < closeDist then
				closeIndex = fromIndex
				closeDist = tDist
			end

			fromIndex = fromIndex + 1
		else
			local behaviorPatrolMoveType = wayPointData.behaviorPatrolMoveType or WAY_POINT_DEFAULTS.behaviorPatrolMoveType

			if not AIUtils.checkIsCommonPatrolMoveType(behaviorPatrolMoveType) then
				fromIndex = fromIndex - 1
			end

			break
		end
	end

	if closeIndex < wayPointListCount then
		Vector3.enableCreateFromCache()

		local preWayPointVector = targetEntPos - wayPointListData[closeIndex].position
		local nextWayPointVector = targetEntPos - wayPointListData[closeIndex + 1].position

		if Vector3.Dot(preWayPointVector, nextWayPointVector) < 0 and Vector3.Angle(preWayPointVector, nextWayPointVector) > 170 then
			closeIndex = closeIndex + 1
		end

		Vector3.disableCreateFromCache()
	end

	return closeIndex
end

function AIUtils.findNearestWayPointIndex(entity, wayPointListData, fromIndex)
	local targetEntPos = entity:getPosition()
	local closeIndex = CalcUtils.findNearestPointIndex(entity:getPosition(), wayPointListData, "position", fromIndex)
	local wayPointListCount = #wayPointListData

	if closeIndex < wayPointListCount then
		Vector3.enableCreateFromCache()

		local preWayPointVector = targetEntPos - wayPointListData[closeIndex].position
		local nextWayPointVector = targetEntPos - wayPointListData[closeIndex + 1].position

		if Vector3.Dot(preWayPointVector, nextWayPointVector) < 0 and Vector3.Angle(preWayPointVector, nextWayPointVector) > 170 then
			closeIndex = closeIndex + 1
		end

		Vector3.disableCreateFromCache()
	end

	if closeIndex == wayPointListCount then
		local patrolWayPoint = wayPointListData[closeIndex].position

		if AutoPathFindUtils.checkTwoPosClose(entity, targetEntPos[1], targetEntPos[2], targetEntPos[3], patrolWayPoint[1], patrolWayPoint[2], patrolWayPoint[3]) then
			closeIndex = 1
		end
	end

	return closeIndex
end

function AIUtils.checkChemStateAndAbility(entity, stateName, state)
	if entity and Utils.checkClient() then
		if ECSConst.AI_STATE_CONVERTER[stateName] then
			if entity.isChemStateActive then
				return entity:isChemStateActive(stateName, state)
			end
		elseif ECSConst.AI_ABILITY_CONVERTER[stateName] and entity.isChemAbilityActive then
			return entity:isChemAbilityActive(stateName)
		end
	end

	return false
end

function AIUtils.checkAnyChemStateAndAbility(ent, stateNameList, state)
	if Utils.tableIsEmptyOrNil(stateNameList) then
		return false
	end

	for _, stateName in ipairs(stateNameList) do
		if AIUtils.checkChemStateAndAbility(ent, stateName, state) then
			return true
		end
	end

	return false
end

function AIUtils.getEntityCurrentBehaviourID(ent)
	if ent and ent.AIPlan then
		local plan = ent:getCurrentAIParmonPlan()

		return plan and plan:getID()
	end
end

function AIUtils.getEntityCurrentRouteID(ent)
	if ent and ent.AIPlan then
		return ent.AIPlan.curRouteId
	end
end

function AIUtils.getFollowSpeedRateType(speed, entity)
	local walkSpeed = AIControllerUtils.getWalkSpeed(entity)
	local runSpeed = AIControllerUtils.getRunSpeed(entity)
	local sprintSpeed = AIControllerUtils.getSprintSpeed(entity)

	if speed < math_max(walkSpeed, runSpeed * AiConst.FOLLOW_SPEED_RATE) then
		return BaseEnum.SpeedRateType.Slow
	elseif speed < math_max(runSpeed, sprintSpeed * AiConst.FOLLOW_SPEED_RATE) then
		return BaseEnum.SpeedRateType.Mid
	end

	return BaseEnum.SpeedRateType.Fast
end

function AIUtils.getGoHomePos(entity)
	return entity.bornPosition
end

function AIUtils.getAIRootState(entity)
	if Utils.checkIsAuthorityMaster(entity) then
		return entity.agent and entity.agent:getRootState() or 0
	else
		return entity.aiState or 0
	end
end

function AIUtils.getAIProfileInfo()
	if Utils.checkClient() then
		local allAIInfo = {}
		local allAIType = {}
		local EntityManager = require("Core.Common.EntityManager")
		local npcCount = 0

		for _, ent in pairs(EntityManager._entities) do
			if ent.agent and ent:isAIRunning() then
				local classType = ent:getClassType()
				local aiTickLevel = AIUtils.getAILodLevel(ent, pg.me)

				if not allAIInfo[aiTickLevel] then
					allAIInfo[aiTickLevel] = 0
				end

				if not allAIType[classType] then
					allAIType[classType] = 0
				end

				allAIInfo[aiTickLevel] = allAIInfo[aiTickLevel] + 1
				allAIType[classType] = allAIType[classType] + 1

				if Utils.isNpc(ent) then
					npcCount = npcCount + 1

					print("AI NPC info:", ent.templateId, ent.staticId)
				end
			end
		end

		print("AI info:", inspect(allAIInfo), inspect(allAIType), ",npc:", npcCount)
	end
end

local Time = require("Core.Common.Time")

AIUtils.recordStartFrame = 0
AIUtils.recordStartTime = 0
AIUtils.recordState = false
AIUtils.recordTemp = {}
AIUtils.recordTotal = {}
AIUtils.recordCallCount = {}
AIUtils.recordByFrame = {}

local typeList = {
	"[lodTick]",
	"  [updateVision]",
	"  [updateNoImpVision]",
	"[clientTick]",
	"  [aiTick]",
	"    [checkPlanInterrupt]",
	"    [checkPlanContinue]",
	"    [stateMessage]",
	"    [tickTrigger(Dynamic)]",
	"    [tickTrigger(Additive)]",
	"    [tickTrigger(Normal)]",
	"    [btTickBefore]",
	"    [btTick]",
	"    [btTickLater]"
}

function AIUtils.startRecord()
	AIUtils.recordState = true
	AIUtils.recordStartTime = Time.realtimeSinceStartup
	AIUtils.recordStartFrame = Time.unityFrameCount
end

function AIUtils.endRecord()
	AIUtils.recordState = false

	local time = Time.realtimeSinceStartup - AIUtils.recordStartTime
	local frameCount = Time.unityFrameCount - AIUtils.recordStartFrame

	print(string.format("time: %s, frameCount: %s", time, frameCount))

	for _, type in ipairs(typeList) do
		for _type, totalTime in pairs(AIUtils.recordTotal) do
			if string.startsWith(_type, type) then
				local callCount = AIUtils.recordCallCount[_type] or 1

				print(string.format("%s - totalTime: %.2f, callCount: %s, averageTime: %.2f", _type, totalTime, callCount, totalTime / callCount))
			end
		end
	end

	print(string.format("frameInfo: %s", inspect(AIUtils.recordByFrame, {
		depth = 3
	})))
end

function AIUtils.startSample(type)
	if not AIUtils.recordState then
		return
	end

	AIUtils.recordTemp[type] = os.clock()
end

function AIUtils.endSample(type)
	if not AIUtils.recordState then
		return
	end

	local usedTime = (os.clock() - AIUtils.recordTemp[type]) * 1000

	AIUtils.recordTemp[type] = nil
	AIUtils.recordTotal[type] = (AIUtils.recordTotal[type] or 0) + usedTime
	AIUtils.recordCallCount[type] = (AIUtils.recordCallCount[type] or 0) + 1
end

function AIUtils.markEntByFrame(ent)
	if not AIUtils.recordState then
		return
	end

	local frameCount = Time.unityFrameCount

	if not AIUtils.recordByFrame[frameCount] then
		AIUtils.recordByFrame[frameCount] = {
			entNum = 0,
			time = os.clock(),
			ents = {}
		}
	end

	AIUtils.recordByFrame[frameCount].entNum = AIUtils.recordByFrame[frameCount].entNum + 1

	table.insert(AIUtils.recordByFrame[frameCount].ents, ent.actorId)
end

function AIUtils.joinGroupCombat(entity, target)
	target = target and (Utils.isPet(target) and target.master or target)

	if target and target.joinGroupCombat then
		target:joinGroupCombat(entity)
	end
end

function AIUtils.leaveGroupCombat(entity, target)
	target = target and (Utils.isPet(target) and target.master or target)

	if target and target.leaveGroupCombat then
		target:leaveGroupCombat(entity)
	end
end

function AIUtils.checkOpenCPP()
	return AiConst.CPP and Utils.checkClient()
end

function AIUtils.checkOpenBCOptimize()
	return AiConst.CT_V2
end

function AIUtils.initBehaviorXWorkSpace()
	if AIUtils.checkOpenCPP() then
		local isUnityEditor = false
		local loggerLevel = BehaviorXConst.LogLevel.error

		if UNITY_EDITOR then
			isUnityEditor = true
			loggerLevel = BehaviorXConst.LogLevel.info + BehaviorXConst.LogLevel.warn + BehaviorXConst.LogLevel.error
		end

		if Utils.checkClient() then
			local rawRoot = pg.global.resMgr:RawFileGetRootDir()
			local packagePrefix = rawRoot .. "/BehaviorX/"
			local ok = pg.world.initBehaviorX("BehaviorXData/", BehaviorXConst.BehaviorXFileType.bson, loggerLevel, isUnityEditor, packagePrefix)

			if ok == false then
				logger:error("BehaviorX VFS initialization failed")
			end
		end
	end
end

function AIUtils.destroyBehaviorXWorkSpace()
	if AIUtils.checkOpenCPP() then
		pg.world.destroyBehaviorX()
	end
end

function AIUtils.SearchEntitiesInRangeWithTable(entity, range, userType, maxFindCount, outputTable)
	local count = entity:entitiesInRangeWithTable(range, userType, maxFindCount, outputTable)
	local invalidCount = 0

	if bit.band(userType, Const.SEARCH_USR_TYPE_PET) > 0 then
		for i = count, 1, -1 do
			local ent = pg.getEntityByActorId(outputTable[i])

			if Utils.isPet(ent) and not ent.isSummon then
				if i ~= count - invalidCount then
					outputTable[i] = outputTable[count - invalidCount]
				end

				invalidCount = invalidCount + 1
			end
		end
	end

	local length = #outputTable

	if length > count - invalidCount then
		for i = count - invalidCount + 1, length do
			outputTable[i] = nil
		end
	end

	return count - invalidCount
end

function AIUtils.SearchEntitiesInRangeWithCache(entity, range, userType, outputList, acceptDelay)
	if entity.searchPerceptibilityRangeCandidates then
		local handled, count = entity:searchPerceptibilityRangeCandidates(range, userType, outputList)

		if handled then
			return count
		end
	end

	local count = entity:entitiesInRangeWithCache(range, userType, outputList, acceptDelay)
	local invalidCount = 0

	if bit_band(userType, Const.SEARCH_USR_TYPE_PET) > 0 then
		for i = count, 1, -1 do
			local ent = pg.getEntityByActorId(outputList[i])

			if Utils.isPet(ent) and not ent.isSummon then
				if i ~= count - invalidCount then
					outputList[i] = outputList[count - invalidCount]
				end

				invalidCount = invalidCount + 1
			end
		end
	end

	local length = #outputList

	if length > count - invalidCount then
		for i = count - invalidCount + 1, length do
			outputList[i] = nil
		end
	end

	return count - invalidCount
end

function AIUtils.checkPuppetFriendly(puppet, actorId)
	local targetEntity = pg.getEntityByActorId(actorId)

	if not targetEntity or not puppet then
		return false
	end

	if Utils.isPet(targetEntity) or Utils.isPuppet(targetEntity) then
		local configData = AIUtils.getEcologyEthnicData(puppet.petPrototypeId, targetEntity.petPrototypeId)

		if configData and configData.isFriendly then
			return true
		end
	elseif Utils.isPlayer(targetEntity) then
		local playerKey = -1
		local configData = AIUtils.getEcologyEthnicData(puppet.petPrototypeId, playerKey)

		if configData and configData.isFriendly then
			return true
		end
	end

	return false
end

function AIUtils.checkPuppetAffinity(puppet, playerActorId)
	local player = pg.getEntityByActorId(playerActorId)

	if not player or not puppet or not Utils.isPlayer(player) then
		return false
	end

	local puppetConfigData = puppet:getConfigData()
	local puppetEthnicGroup = puppetConfigData and puppetConfigData.ethnicGroup or 0

	for _, configId in pairs(player.closePetActiveEntrysMap) do
		local closeEthnicList = AttributeEntryData[configId].attrComplexValue

		for _, ethnic in ipairs(closeEthnicList) do
			if ethnic == puppetEthnicGroup then
				return true
			end
		end
	end

	return false
end

function AIUtils.isSimpleRoute(routeData)
	local routeType = routeData and routeData.routeType or routeDefaultValueData and routeDefaultValueData.routeType or AiConst.RouteType.Default

	if routeData and routeType == AiConst.RouteType.Simple then
		return true
	end

	return false
end

return AIUtils
