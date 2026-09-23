-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\AIBehaviorGroupTemplate.lua

local AiConst = require("Common.Const.AiConst")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local CTRConst = require("Common.AICt.CTRConst")
local CTUtils = require("Common.AI.ConditionTrigger.CTUtils")
local ParmonBehaivorData = require("Data.parmon_behavior_data")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("AIBehaviorGroupTemplate")
local Const = require("Common.Const.Const")
local AIBehaviorGroupTemplate = {}
local weakValueMetatable = {
	__mode = "v"
}
local nilBehaviorGroupId = {}
local templateCache = {}
local cacheMap = {}

AIBehaviorGroupTemplate.cache = templateCache
AIBehaviorGroupTemplate.cacheMap = cacheMap

local emptySourceList = Const.CACHED_EMPTY_TABLE
local nilEventContext = {}
local EBTRootStateName = BaseEnum.EBTRootState_NAME
local TickLod = AiConst.TICK_TRIGGER_LOD
local defaultStateView = Const.CACHED_EMPTY_TABLE

local function newWritableTickLodMap()
	return {
		[TickLod.High] = emptySourceList,
		[TickLod.Mid] = emptySourceList,
		[TickLod.Low] = emptySourceList,
		[TickLod.VeryLow] = emptySourceList
	}
end

local defaultTickLodTriggerBehaviourIdMap = newWritableTickLodMap()
local ALLKEY = "*"
local isRegistrationDebugEnabled = AiConst.AI_DEBUG.REGISTRATION_INFO
local debugTraceback = debug.traceback
local xpcall = xpcall
local next = next
local table = table

local function getBehaviorGroupCacheKey(behaviorGroupId)
	if behaviorGroupId == nil then
		return nilBehaviorGroupId
	end

	return behaviorGroupId
end

function cacheMap.get(behaviorGroupId, behaviorTableSlot, sourceBehaviorPriorityList)
	local groupCache = templateCache[getBehaviorGroupCacheKey(behaviorGroupId)]

	if groupCache then
		return groupCache[behaviorTableSlot]
	end
end

function cacheMap.set(behaviorGroupId, behaviorTableSlot, sourceBehaviorPriorityList, template)
	local groupKey = getBehaviorGroupCacheKey(behaviorGroupId)
	local groupCache = templateCache[groupKey]

	if not groupCache then
		groupCache = setmetatable({}, weakValueMetatable)
		templateCache[groupKey] = groupCache
	end

	groupCache[behaviorTableSlot] = template
end

function cacheMap.clear()
	while true do
		local key = next(templateCache)

		if key == nil then
			return
		end

		templateCache[key] = nil
	end
end

function AIBehaviorGroupTemplate.clearCache()
	cacheMap.clear()
end

local function copyArray(source)
	local result = {}

	for i = 1, #source do
		result[i] = source[i]
	end

	return result
end

local function copyInto(source, target)
	for i = #target, 1, -1 do
		target[i] = nil
	end

	for i = 1, #source do
		target[i] = source[i]
	end
end

local function clearArrayIfNotEmpty(target)
	if #target > 0 then
		table.clearArray(target)
	end
end

local function refreshStateFilterMetadata(template, behaviorPriorityList)
	local hasMotionStateFilter = false
	local hasAgentRootStateFilter = false

	for i = 1, #behaviorPriorityList do
		local graphData = ParmonBehaivorData[behaviorPriorityList[i]]

		if graphData then
			hasMotionStateFilter = hasMotionStateFilter or graphData.bindMotionStateReverse ~= nil
			hasAgentRootStateFilter = hasAgentRootStateFilter or graphData.bindAiStateReverse ~= nil

			if hasMotionStateFilter and hasAgentRootStateFilter then
				break
			end
		end
	end

	template.hasMotionStateFilter = hasMotionStateFilter
	template.hasAgentRootStateFilter = hasAgentRootStateFilter
end

local function newTemplate(sharedBehaviorPriorityList)
	local template = {
		sharedBehaviorPriorityList = sharedBehaviorPriorityList,
		stateViews = {}
	}

	refreshStateFilterMetadata(template, sharedBehaviorPriorityList)

	return template
end

local function getSharedBehaviorPriorityList(template)
	local sharedBehaviorPriorityList = template.sharedBehaviorPriorityList

	if not sharedBehaviorPriorityList then
		sharedBehaviorPriorityList = template.behaviorPriorityList or emptySourceList
		template.sharedBehaviorPriorityList = sharedBehaviorPriorityList
	end

	if template.hasMotionStateFilter == nil or template.hasAgentRootStateFilter == nil then
		refreshStateFilterMetadata(template, sharedBehaviorPriorityList)
	end

	return sharedBehaviorPriorityList
end

function AIBehaviorGroupTemplate.getOrCreate(behaviorGroupId, behaviorTableSlot, sourceBehaviorPriorityList, forceRefresh)
	sourceBehaviorPriorityList = sourceBehaviorPriorityList or emptySourceList

	local template = cacheMap.get(behaviorGroupId, behaviorTableSlot, sourceBehaviorPriorityList)

	if template then
		if forceRefresh then
			local sharedBehaviorPriorityList = getSharedBehaviorPriorityList(template)

			copyInto(sourceBehaviorPriorityList, sharedBehaviorPriorityList)
			refreshStateFilterMetadata(template, sharedBehaviorPriorityList)

			template.stateViews = {}
		end

		return template
	end

	template = newTemplate(copyArray(sourceBehaviorPriorityList))

	cacheMap.set(behaviorGroupId, behaviorTableSlot, sourceBehaviorPriorityList, template)

	return template
end

local function containsBehavior(behaviorList, behaviorId)
	if behaviorList then
		for i = 1, #behaviorList do
			if behaviorList[i] == behaviorId then
				return true
			end
		end
	end

	return false
end

local function compareBehaviorPriority(left, right)
	local leftData = ParmonBehaivorData[left]
	local rightData = ParmonBehaivorData[right]

	if not leftData or not rightData then
		return false
	end

	return leftData.priority > rightData.priority
end

function AIBehaviorGroupTemplate.mergeBehaviorPriorityListInto(baseBehaviorPriorityList, addedBehaviorList, result, shouldSort)
	copyInto(baseBehaviorPriorityList or emptySourceList, result)

	for i = 1, #(addedBehaviorList or emptySourceList) do
		local behaviorId = addedBehaviorList[i]

		if not ParmonBehaivorData[behaviorId] then
			if LoggerManager.checkLogger(LoggerConst.WARN, "AI") then
				logger:warn("行为不存在,请检查配置, key: %s", behaviorId)
			end
		elseif not containsBehavior(result, behaviorId) then
			result[#result + 1] = behaviorId
		end
	end

	if shouldSort and #result > 1 then
		table.sort(result, compareBehaviorPriority)
	end

	return result
end

function AIBehaviorGroupTemplate.createBehaviorPriorityList(baseBehaviorPriorityList, addedBehaviorList, result)
	return AIBehaviorGroupTemplate.mergeBehaviorPriorityListInto(baseBehaviorPriorityList, addedBehaviorList, result, true)
end

local function isStateMatched(graphData, behaviorId, motionStateName, agentRootStateName, groupBehaviorId)
	local bindMotionState = graphData.bindMotionStateReverse

	if bindMotionState and bindMotionState[motionStateName] == nil then
		return false
	end

	local bindRootState = graphData.bindAiStateReverse

	if bindRootState and bindRootState[agentRootStateName] == nil then
		return false
	end

	return graphData.isGroupBehav ~= 1 or groupBehaviorId == behaviorId
end

local function addRoute(stateView, triggerName, behaviorId, triggerType)
	local routes = stateView.triggerRoutes[triggerName]

	if not routes then
		routes = {}
		stateView.triggerRoutes[triggerName] = routes
	end

	routes[#routes + 1] = behaviorId
	routes[#routes + 1] = triggerType
end

local function newStateView()
	local stateView = {
		triggerRoutes = {},
		tickLodTriggerBehaviourIdMap = defaultTickLodTriggerBehaviourIdMap
	}

	if isRegistrationDebugEnabled then
		stateView.debugRegisteredGraphs = {}
		stateView.debugRegisteredBehaviorIds = {}
	end

	return stateView
end

local function getOrCreateTickLodList(stateView, tickLodLevel)
	if defaultTickLodTriggerBehaviourIdMap[tickLodLevel] == nil then
		return nil
	end

	local tickLodMap = stateView.tickLodTriggerBehaviourIdMap

	if tickLodMap == defaultTickLodTriggerBehaviourIdMap then
		tickLodMap = newWritableTickLodMap()
		stateView.tickLodTriggerBehaviourIdMap = tickLodMap
	end

	local tickList = tickLodMap[tickLodLevel]

	if tickList == emptySourceList then
		tickList = {}
		tickLodMap[tickLodLevel] = tickList
	end

	return tickList
end

local function createStateView(template, entityMotionState, entityAgentRootState, groupBehaviorId)
	local stateView
	local eventTriggerType = CTRConst.NodeBaseType.EventTrigger
	local messageTriggerType = CTRConst.NodeBaseType.MessageTrigger
	local sharedBehaviorPriorityList = getSharedBehaviorPriorityList(template)
	local motionStateName

	if template.hasMotionStateFilter then
		local motionState = CharacterStateConst[entityMotionState]

		motionStateName = motionState and motionState.name
	end

	local agentRootStateName

	if template.hasAgentRootStateFilter then
		agentRootStateName = EBTRootStateName[entityAgentRootState]
	end

	for i = 1, #sharedBehaviorPriorityList do
		local behaviorId = sharedBehaviorPriorityList[i]
		local graphData = ParmonBehaivorData[behaviorId]

		if graphData and isStateMatched(graphData, behaviorId, motionStateName, agentRootStateName, groupBehaviorId) then
			stateView = stateView or newStateView()

			local graphId = graphData.triggerAndCondition

			if isRegistrationDebugEnabled then
				stateView.debugRegisteredGraphs[#stateView.debugRegisteredGraphs + 1] = graphId
				stateView.debugRegisteredBehaviorIds[#stateView.debugRegisteredBehaviorIds + 1] = behaviorId
			end

			local eventList, messageList, tickLodLevel = CTUtils.getGraphTriggers(graphId)

			for eventIndex = 1, #eventList do
				addRoute(stateView, eventList[eventIndex], behaviorId, eventTriggerType)
			end

			for messageIndex = 1, #messageList do
				addRoute(stateView, messageList[messageIndex], behaviorId, messageTriggerType)
			end

			local tickList = getOrCreateTickLodList(stateView, tickLodLevel)

			if tickList then
				tickList[#tickList + 1] = behaviorId
			end
		end
	end

	return stateView or defaultStateView
end

function AIBehaviorGroupTemplate.getStateView(template, entityMotionState, entityAgentRootState, groupBehaviorId)
	local groupKey = groupBehaviorId or ALLKEY
	local groupStateViews = template.stateViews[groupKey]

	if not groupStateViews then
		groupStateViews = {}
		template.stateViews[groupKey] = groupStateViews
	end

	local motionKey = entityMotionState or ALLKEY
	local motionStateViews = groupStateViews[motionKey]

	if not motionStateViews then
		motionStateViews = {}
		groupStateViews[motionKey] = motionStateViews
	end

	local rootKey = entityAgentRootState or ALLKEY
	local stateView = motionStateViews[rootKey]

	if not stateView then
		stateView = createStateView(template, entityMotionState, entityAgentRootState, groupBehaviorId)
		motionStateViews[rootKey] = stateView
	end

	return stateView
end

function AIBehaviorGroupTemplate.bind(entity, entityMotionState, entityAgentRootState, template, tickLodTriggerBehaviourIdMap, debugRegisteredGraphs, debugRegisteredBehaviorIds)
	local groupBehavior = entity.getCurrentGroupBehaviour and entity:getCurrentGroupBehaviour()
	local groupBehaviorId = groupBehavior and groupBehavior.parmonBehavId
	local stateView = AIBehaviorGroupTemplate.getStateView(template, entityMotionState, entityAgentRootState, groupBehaviorId)

	if stateView == defaultStateView then
		if debugRegisteredGraphs then
			clearArrayIfNotEmpty(debugRegisteredGraphs)
		end

		if debugRegisteredBehaviorIds then
			clearArrayIfNotEmpty(debugRegisteredBehaviorIds)
		end

		clearArrayIfNotEmpty(tickLodTriggerBehaviourIdMap[TickLod.High])
		clearArrayIfNotEmpty(tickLodTriggerBehaviourIdMap[TickLod.Mid])
		clearArrayIfNotEmpty(tickLodTriggerBehaviourIdMap[TickLod.Low])
		clearArrayIfNotEmpty(tickLodTriggerBehaviourIdMap[TickLod.VeryLow])

		tickLodTriggerBehaviourIdMap.tickLodTriggerCount = 0

		return defaultStateView
	end

	if debugRegisteredGraphs then
		copyInto(stateView.debugRegisteredGraphs or emptySourceList, debugRegisteredGraphs)
	end

	if debugRegisteredBehaviorIds then
		copyInto(stateView.debugRegisteredBehaviorIds or emptySourceList, debugRegisteredBehaviorIds)
	end

	copyInto(stateView.tickLodTriggerBehaviourIdMap[TickLod.High], tickLodTriggerBehaviourIdMap[TickLod.High])
	copyInto(stateView.tickLodTriggerBehaviourIdMap[TickLod.Mid], tickLodTriggerBehaviourIdMap[TickLod.Mid])
	copyInto(stateView.tickLodTriggerBehaviourIdMap[TickLod.Low], tickLodTriggerBehaviourIdMap[TickLod.Low])
	copyInto(stateView.tickLodTriggerBehaviourIdMap[TickLod.VeryLow], tickLodTriggerBehaviourIdMap[TickLod.VeryLow])

	tickLodTriggerBehaviourIdMap.tickLodTriggerCount = 0

	return stateView.triggerRoutes
end

function AIBehaviorGroupTemplate.dispatchRoutes(entity, triggerFuncName, routes, triggerName, context)
	local triggerFunc = entity[triggerFuncName]

	for i = 1, #routes, 2 do
		triggerFunc(entity, routes[i], triggerName, routes[i + 1], context)
	end
end

local function dispatchRouteQueue(entity, plan, triggerFuncName, eventName, context, routes)
	AIBehaviorGroupTemplate.dispatchRoutes(entity, triggerFuncName, routes, eventName, context)

	local head = 1
	local queue = plan.eventQueue

	while queue and head <= (plan.eventQueueCount or 0) do
		eventName = queue[head]
		context = queue[head + 1]
		queue[head] = nil
		queue[head + 1] = nil
		head = head + 2

		if context == nilEventContext then
			context = nil
		end

		local eventRoutes = plan.eventRoutes

		routes = eventRoutes and eventRoutes[eventName]

		if routes then
			plan.emittingEventName = eventName

			AIBehaviorGroupTemplate.dispatchRoutes(entity, triggerFuncName, routes, eventName, context)
		end
	end
end

function AIBehaviorGroupTemplate.emitRoutes(entity, plan, triggerFuncName, eventName, context)
	local eventRoutes = plan.eventRoutes
	local routes = eventRoutes and eventRoutes[eventName]

	if not routes then
		return
	end

	if plan.eventEmitting then
		if plan.emittingEventName == eventName then
			return
		end

		local queue = plan.eventQueue

		if not queue then
			queue = {}
			plan.eventQueue = queue
		end

		local count = plan.eventQueueCount or 0

		queue[count + 1] = eventName
		queue[count + 2] = context == nil and nilEventContext or context
		plan.eventQueueCount = count + 2

		return
	end

	plan.eventEmitting = true
	plan.emittingEventName = eventName

	local success, dispatchError = xpcall(dispatchRouteQueue, debugTraceback, entity, plan, triggerFuncName, eventName, context, routes)
	local queue = plan.eventQueue
	local queueCount = plan.eventQueueCount or 0

	for i = 1, queueCount do
		queue[i] = nil
	end

	plan.eventQueueCount = 0
	plan.emittingEventName = nil
	plan.eventEmitting = false

	if not success then
		logger:error(dispatchError, 0)
	end
end

return AIBehaviorGroupTemplate
