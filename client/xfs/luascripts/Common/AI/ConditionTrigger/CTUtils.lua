-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\ConditionTrigger\\CTUtils.lua

local CTUtils = {}
local AICtrGraphTriggerData = require("Common.Data.AICtrData.aictr_graph_trigger_data")
local _emptyTable = {}
local _graphMap = {}
local _graphPathMap = {}
local _debugGraphPathMap = {}
local _graphPathPrefix = "Common/Data/AICtrData/CTGraph/"
local _debugGraphPathSuffix = "_Debug"
local _require = require
local __flowPool = {}
local __flowPoolIndex = 0
local __flowPoolMaxCount = 256

function CTUtils._getGraphPath(graphId, debugMode)
	local graphPathMap = debugMode and _debugGraphPathMap or _graphPathMap
	local graphPath = graphPathMap[graphId]

	if not graphPath then
		if debugMode then
			graphPath = _graphPathPrefix .. graphId .. _debugGraphPathSuffix
		else
			graphPath = _graphPathPrefix .. graphId
		end

		graphPathMap[graphId] = graphPath
	end

	return graphPath
end

function CTUtils.setGraphDebugMode(graphId, mode)
	if mode then
		local CTFlow = _require("Common.AI.ConditionTrigger.CTFlow")

		CTFlow.init = CTFlow.initDebug
		CTFlow.dispose = CTFlow.disposeDebug
	end

	local graph

	if mode then
		graph = _require(CTUtils._getGraphPath(graphId, true))
	else
		graph = _require(CTUtils._getGraphPath(graphId, false))
	end

	if graph then
		graph.debugMode = mode

		CTUtils.setHotfixGraph(graphId, graph)
	end
end

function CTUtils.setHotfixGraph(graphId, hotfixGraph)
	_graphMap[graphId] = hotfixGraph
end

function CTUtils.getGraph(graphId)
	if not graphId then
		return nil
	end

	local graph = _graphMap[graphId]

	if not graph then
		graph = _require(CTUtils._getGraphPath(graphId, false))
		_graphMap[graphId] = graph
	end

	return graph
end

local function getGraphTriggers(graphId)
	local triggerData = AICtrGraphTriggerData[graphId]

	if not triggerData then
		return _emptyTable, _emptyTable, -1
	end

	return triggerData[1] or _emptyTable, triggerData[2] or _emptyTable, triggerData[3] or -1
end

function CTUtils.getEventTriggerList(graphId)
	local eventTriggerList = getGraphTriggers(graphId)

	return eventTriggerList
end

function CTUtils.getMessageTriggerList(graphId)
	local _, messageTriggerList = getGraphTriggers(graphId)

	return messageTriggerList
end

function CTUtils.getTickLodTrigger(graphId)
	local _, _, tickLodTriggerLevel = getGraphTriggers(graphId)

	return tickLodTriggerLevel
end

function CTUtils.getGraphTriggers(graphId)
	return getGraphTriggers(graphId)
end

function CTUtils.GetFlow(...)
	local flow

	if __flowPoolIndex > 0 then
		flow = __flowPool[__flowPoolIndex]
		__flowPool[__flowPoolIndex] = nil
		__flowPoolIndex = __flowPoolIndex - 1
	else
		local CTFlow = _require("Common.AI.ConditionTrigger.CTFlow")

		flow = CTFlow.new()
	end

	flow:init(...)

	return flow
end

function CTUtils.ReturnFlow(flow)
	if __flowPoolIndex < __flowPoolMaxCount then
		__flowPoolIndex = __flowPoolIndex + 1
		__flowPool[__flowPoolIndex] = flow
	end
end

function CTUtils.ClearFlowPool()
	table.clear(__flowPool)

	__flowPoolIndex = 0
end

return CTUtils
