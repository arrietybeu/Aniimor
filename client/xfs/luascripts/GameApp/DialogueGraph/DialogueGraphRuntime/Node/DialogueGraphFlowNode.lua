-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphFlowNode.lua

local DialogueGraphFlowNode = {}

DialogueGraphFlowNode.__index = DialogueGraphFlowNode

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("DialogueGraph")
local Time = require("Core.Common.Time")
local NODE_RUNNING_TIMES_KEY = "__flowNodeRunningTimes"

local function graphName(ctx)
	local runtime = ctx.runtime

	if runtime ~= nil and runtime.data ~= nil and runtime.data.graphName ~= nil then
		return runtime.data.graphName
	end

	return "DialogueGraph_" .. tostring(runtime and runtime.dialogueId or "")
end

function DialogueGraphFlowNode.extend(nodeName)
	local node = {
		nodeName = nodeName
	}

	setmetatable(node, DialogueGraphFlowNode)

	return node
end

function DialogueGraphFlowNode:startNode(ctx)
	local ok, failureMessage, infoLog = self:onNodeRunning(ctx)

	if ok == false then
		self:onNodeRunFailure(ctx, failureMessage, infoLog)

		return false, failureMessage
	end

	local runResult, runMessage, infoLog = self.run(ctx)

	if not ctx:isFlowValid() then
		return true, nil
	end

	if runResult == false then
		self:onNodeRunFailure(ctx, runMessage, infoLog)

		return false, runMessage
	end

	self:onNodeRunSuccess(ctx)

	return true, nil
end

function DialogueGraphFlowNode:onNodeRunning(ctx)
	local nodeRunningTimes = ctx:stateGet(NODE_RUNNING_TIMES_KEY, 0) + 1

	ctx:stateSet(NODE_RUNNING_TIMES_KEY, nodeRunningTimes)

	local runtimeGuard = ctx.runtime and ctx.runtime.runtimeGuard or nil

	if runtimeGuard ~= nil then
		local valid, issue = runtimeGuard:checkNodeRunning(ctx)

		if not valid then
			runtimeGuard:handleIssue(ctx, issue)

			return false, issue.message
		end
	end

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		if UNITY_EDITOR then
			logger:info("%s <color=yellow>%s-%d</color> frameCount:%d-RunTimes:%d Running!", graphName(ctx), tostring(ctx:nodeKind()), ctx:nodeId(), Time.frameCount, nodeRunningTimes)
		else
			logger:info("%s %s-%d frameCount:%d-RunTimes:%d Running!", graphName(ctx), tostring(ctx:nodeKind()), ctx:nodeId(), Time.frameCount, nodeRunningTimes)
		end
	end

	return true, nil
end

function DialogueGraphFlowNode:onNodeRunSuccess(ctx)
	local nodeRunningTimes = ctx:stateGet(NODE_RUNNING_TIMES_KEY, 0)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) and LoggerManager.checkLogger(LoggerConst.DEBUG) then
		if UNITY_EDITOR then
			logger:info("%s <color=green>%s-%d</color> frameCount:%d-RunTimes:%d RunSuccess!", graphName(ctx), tostring(ctx:nodeKind()), ctx:nodeId(), Time.frameCount, nodeRunningTimes)
		else
			logger:info("%s %s-%d frameCount:%d-RunTimes:%d RunSuccess!", graphName(ctx), tostring(ctx:nodeKind()), ctx:nodeId(), Time.frameCount, nodeRunningTimes)
		end
	end
end

function DialogueGraphFlowNode:onNodeRunFailure(ctx, message, infoLog)
	if string.isNilOrEmpty(message) then
		return
	end

	infoLog = infoLog == true

	if not infoLog then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			if UNITY_EDITOR then
				logger:error("%s <color=red>%d-%s> %s Failure!</color> /r/n %s", graphName(ctx), ctx:nodeId(), tostring(ctx:nodeKind()), message, debug.traceback())
			else
				logger:error("%s %d-%s %s Failure! /r/n %s", graphName(ctx), ctx:nodeId(), tostring(ctx:nodeKind()), message, debug.traceback())
			end
		end
	elseif LoggerManager.checkLogger(LoggerConst.INFO) then
		if UNITY_EDITOR then
			logger:info("%s <color=red>%d-%s> %s Failure!</color> /r/n %s", graphName(ctx), ctx:nodeId(), tostring(ctx:nodeKind()), message, debug.traceback())
		else
			logger:info("%s %d-%s %s Failure! /r/n %s", graphName(ctx), ctx:nodeId(), tostring(ctx:nodeKind()), message, debug.traceback())
		end
	end
end

return DialogueGraphFlowNode
