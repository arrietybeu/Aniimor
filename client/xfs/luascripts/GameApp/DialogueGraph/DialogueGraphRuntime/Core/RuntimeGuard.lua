-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Core\\RuntimeGuard.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Logger = LoggerManager.getLogger("DialogueGraphRuntimeGuard")
local RuntimeDebug = UNITY_EDITOR and require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.RuntimeDebug") or nil
local NodeLoopRule = require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.GuardRules.NodeLoopRule")
local RuntimeGuard = {}

RuntimeGuard.__index = RuntimeGuard
RuntimeGuard.Action = {
	LOG_ONLY = 1,
	ABORT_GRAPH = 3,
	NODE_FAILURE = 2
}

function RuntimeGuard.new(runtime)
	local self = setmetatable({}, RuntimeGuard)

	self.runtime = runtime
	self.nodeRunningRules = {
		NodeLoopRule
	}
	self.ruleStates = {}

	for index = 1, #self.nodeRunningRules do
		local rule = self.nodeRunningRules[index]

		self.ruleStates[rule.id] = rule.createState(runtime)
	end

	return self
end

function RuntimeGuard:checkNodeRunning(ctx)
	for index = 1, #self.nodeRunningRules do
		local rule = self.nodeRunningRules[index]
		local state = self.ruleStates[rule.id]
		local valid, issue = rule.check(ctx, state, RuntimeGuard.Action)

		if valid and issue ~= nil then
			self:handleIssue(ctx, issue)
		end

		if not valid then
			return false, issue
		end
	end

	return true
end

function RuntimeGuard:handleIssue(ctx, issue)
	if issue.action == RuntimeGuard.Action.LOG_ONLY and LoggerManager.checkLogger(LoggerConst.WARN) then
		Logger:warn("对话图运行警告 dialogueId=%s nodeId=%s nodeKind=%s rule=%s code=%s message=%s", tostring(self.runtime.dialogueId), tostring(ctx:nodeId()), tostring(ctx:nodeKind()), tostring(issue.rule), tostring(issue.code), tostring(issue.message))
	elseif issue.action ~= RuntimeGuard.Action.LOG_ONLY and LoggerManager.checkLogger(LoggerConst.ERROR) then
		Logger:error("对话图运行异常 dialogueId=%s nodeId=%s nodeKind=%s rule=%s code=%s message=%s", tostring(self.runtime.dialogueId), tostring(ctx:nodeId()), tostring(ctx:nodeKind()), tostring(issue.rule), tostring(issue.code), tostring(issue.message))
	end

	if RuntimeDebug ~= nil then
		local diagnosticType = issue.action == RuntimeGuard.Action.LOG_ONLY and "RuntimeWarning" or "RuntimeGuardFailure"

		RuntimeDebug.runtimeDiagnostic(self.runtime, diagnosticType, ctx, issue, "OrderedStrict")
	end

	if issue.action == RuntimeGuard.Action.ABORT_GRAPH and ctx:isFlowValid() then
		ctx:finishGraph(-1)
	end
end

function RuntimeGuard:onNodeFinished(ctx)
	for index = 1, #self.nodeRunningRules do
		local rule = self.nodeRunningRules[index]

		if rule.onNodeFinished ~= nil then
			rule.onNodeFinished(ctx, self.ruleStates[rule.id])
		end
	end
end

function RuntimeGuard:markProgress(ctx)
	for index = 1, #self.nodeRunningRules do
		local rule = self.nodeRunningRules[index]

		if rule.markProgress ~= nil then
			rule.markProgress(ctx, self.ruleStates[rule.id])
		end
	end
end

function RuntimeGuard:reset(reason)
	for index = 1, #self.nodeRunningRules do
		local rule = self.nodeRunningRules[index]

		if rule.reset ~= nil then
			rule.reset(self.ruleStates[rule.id], reason)
		end
	end
end

return RuntimeGuard
