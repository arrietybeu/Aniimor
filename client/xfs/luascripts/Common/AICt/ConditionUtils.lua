-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\ConditionUtils.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("ConditionUtils")
local CTRGraph = require("Common.AICt.CTRGraph")
local AICtrGraphData = require("Common.Data.AICtrData.aictr_graph_data")
local CTRConst = require("Common.AICt.CTRConst")
local CTREventFuc = require("Common.AICt.CTREventFunc")
local AIUtils = require("Common.Utils.AIUtils")
local CTUtils = require("Common.AI.ConditionTrigger.CTUtils")
local Time = require("Core.Common.Time")
local ConditionUtils = {}

ConditionUtils.graphDic = {}
ConditionUtils.debugModeSimple = false
ConditionUtils.debugModeBreak = false
ConditionUtils.stack = {}

function ConditionUtils.switchSimpleDebugMode(open, actorId)
	ConditionUtils.stack = {}
	ConditionUtils.debugModeSimple = open

	if open then
		function CTRGraph.Debug.recorderCallback(graphId, debugInfo)
			ConditionUtils.addExecuteGraph(graphId, debugInfo)
		end

		CTRGraph.Debug._ListenerActorId = actorId
	else
		CTRGraph.Debug.recorderCallback = nil
	end
end

function ConditionUtils.getAIStackInfo()
	local stack = ConditionUtils.stack

	ConditionUtils.stack = {}

	return stack
end

function ConditionUtils.addExecuteGraph(graphName, debugInfo)
	if not ConditionUtils.debugModeSimple then
		return
	end

	local triggerName = ""

	for _, v in ipairs(debugInfo.triggers) do
		if string.isNilOrEmpty(triggerName) then
			triggerName = v
		else
			triggerName = triggerName .. "/" .. v
		end
	end

	local res = {
		frame = Time.frameCount,
		graphName = graphName,
		triggerName = triggerName,
		triggerSuccess = tostring(debugInfo.triggerSuccess),
		executeSuccess = tostring(debugInfo.executeSuccess),
		triggerTp = debugInfo.triggerTp
	}

	table.insert(ConditionUtils.stack, res)
end

function ConditionUtils.switchAICtrBreakDebugMode(graphId, mode)
	if not AIUtils.checkOpenBCOptimize() then
		local graph = ConditionUtils.getGraph(graphId)

		graph:setDebugMode(mode)
	else
		CTUtils.setGraphDebugMode(graphId, mode)
	end
end

function ConditionUtils.bindToCSharpGraphFunc(graphId, startGraphAction, executeNodeAction, endGraphAction)
	if not AIUtils.checkOpenBCOptimize() then
		local graph = ConditionUtils.getGraph(graphId)

		graph:bindToCSharpGraphFunc(startGraphAction, executeNodeAction, endGraphAction)
	else
		local graph = CTUtils.getGraph(graphId)

		if graph then
			graph.startGraphAction = startGraphAction
			graph.executeNodeAction = executeNodeAction
			graph.endGraphAction = endGraphAction
		end
	end
end

function ConditionUtils.getTriggerList(graphId, refList)
	local graph = ConditionUtils.getGraph(graphId)

	return graph and graph:getTriggerNameList(refList)
end

function ConditionUtils.getTickTrigger(graphId)
	local graph = ConditionUtils.getGraph(graphId)

	return graph and graph:getTickTrigger()
end

function ConditionUtils.getTickLodTrigger(graphId)
	local graph = ConditionUtils.getGraph(graphId)

	return graph and graph:getTickLodTrigger()
end

function ConditionUtils.getMessageTriggerList(graphId, refList)
	local graph = ConditionUtils.getGraph(graphId)

	return graph and graph:getMessageTriggerNameList(refList)
end

function ConditionUtils.getGraph(graphId)
	if ConditionUtils.graphDic[graphId] then
		return ConditionUtils.graphDic[graphId]
	end

	if AIUtils.checkOpenBCOptimize() then
		logger:error("@LCL 新版本BC下访问到了老版本的Graph", debug.traceback())
	end

	local cData = AICtrGraphData[graphId]

	if cData == nil then
		return nil
	end

	local graph = CTRGraph.new(graphId, cData)

	ConditionUtils.graphDic[graphId] = graph

	return graph
end

function ConditionUtils.isBehaviourInterrupt(graphId, interruptId, context)
	local graph = ConditionUtils.getGraph(graphId)
	local res = graph:onGetInterruptResult(interruptId, context)

	return res
end

function ConditionUtils.DoSubGraph(flow, graphId, context)
	local graph = ConditionUtils.getGraph(graphId)

	flow:addSubFlow(context, graph)
end

function ConditionUtils.DoEventFuc(eName, context)
	if CTREventFuc[eName] then
		CTREventFuc[eName](context)
	elseif LoggerManager.checkLogger(LoggerConst.WARN) then
		logger:warn(string.format("CTREventFuc:%s is invalid", currentBTData.eName))
	end
end

function ConditionUtils.DoTrigger(targetActorId, sendMsgName, context)
	CTREventFuc.DoTrigger(targetActorId, sendMsgName, context)
end

return ConditionUtils
