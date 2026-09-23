-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Core\\Runtime.lua

local Runtime = {}

Runtime.__index = Runtime

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("Runtime")
local Context = require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.Context")
local Scheduler = require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.Scheduler")
local Performance = require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.Performance")
local NodeRegistry = require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.NodeRegistry")
local RuntimeGuard = require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.RuntimeGuard")
local SafeCallbackWithStatusAndReturn = require("Core.Framework.SafeCallbackWithStatusAndReturn")
local RuntimeDebug = UNITY_EDITOR and require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.RuntimeDebug") or nil

local function copyValue(value, copied)
	if type(value) ~= "table" then
		return value
	end

	local cached = copied[value]

	if cached ~= nil then
		return cached
	end

	local result = {}

	copied[value] = result

	for key, childValue in pairs(value) do
		result[copyValue(key, copied)] = copyValue(childValue, copied)
	end

	return result
end

local function copyBlackboard(source)
	return source ~= nil and copyValue(source, {}) or {}
end

function Runtime.load(data, graphItem, luaCmd, luaVariables)
	local self = setmetatable({}, Runtime)

	self.data = data
	self.dialogueId = data.dialogueId
	self.startNodeId = data.startNodeId
	self.nodes = data.nodes or {}
	self.logicCache = {}
	self.blackboard = copyBlackboard(data.blackboard)
	self.graphItem = graphItem
	self.luaCmd = luaCmd
	self.passToken = graphItem and graphItem.passToken or 0
	self.isActive = false
	self.isPaused = false
	self.finishCode = nil
	self.pendingExecutions = {}
	self.nodeStates = {}
	self.nodeRunTokens = {}
	self.runNodeContexts = {}
	self.isCleaningNodes = false
	self.scheduler = Scheduler.new(self)
	self.performance = {}
	self.debugPreviewDisabled = false
	self.debugSequence = 0
	self.nextActivation = 1
	self.activationContexts = {}
	self.executionDepth = 0
	self.pendingFinishCode = nil
	self.runtimeGuard = RuntimeGuard.new(self)

	self:applyExternalLuaVariables(luaVariables)

	return self
end

function Runtime:applyExternalLuaVariables(luaVariables)
	if luaVariables == nil then
		return
	end

	local ok, err = SafeCallbackWithStatusAndReturn(function()
		for key in pairs(self.blackboard) do
			local override = luaVariables[key]

			if override ~= nil then
				self.blackboard[key] = copyValue(override, {})
			end
		end
	end)

	if not ok and RuntimeDebug ~= nil then
		RuntimeDebug.runtimeDiagnostic(self, "RuntimeWarning", nil, {
			warning = "ApplyExternalLuaVariables failed",
			error = tostring(err)
		}, "DiagnosticOnly")
	end
end

function Runtime:getLogic(kind)
	local logic = self.logicCache[kind]

	if logic ~= nil then
		return logic
	end

	local didLoad, requireElapsedMs

	logic, didLoad, requireElapsedMs = NodeRegistry.getNodeClass(kind)

	if didLoad then
		Performance.add(self.performance, "logicRequireMs", "logicRequireCount", requireElapsedMs)
	end

	self.logicCache[kind] = logic

	return logic
end

function Runtime:getFlowTargets(nodeId, portId)
	local node = self.nodes[nodeId]
	local byPort = node and node.flowOut or nil

	if byPort == nil then
		return nil
	end

	return byPort[portId]
end

function Runtime:hasFlowConnection(nodeId, portId)
	local targets = self:getFlowTargets(nodeId, portId)

	return targets ~= nil and #targets > 0
end

function Runtime:isFlowInputConnected(nodeId, portId)
	local node = self.nodes[nodeId]

	return node ~= nil and node.flowIn ~= nil and node.flowIn[portId] ~= nil
end

function Runtime:isStopPort(nodeId, portId)
	local node = self.nodes[nodeId]

	return node ~= nil and node.flowIn ~= nil and node.flowIn[portId] == 1
end

function Runtime:isValueInputConnected(nodeId, portId)
	local node = self.nodes[nodeId]
	local byPort = node and node.valueIn or nil

	return byPort ~= nil and byPort[portId] ~= nil
end

function Runtime:getCurrentPassToken()
	local graphItem = self.graphItem

	if graphItem ~= nil and graphItem.passToken ~= nil then
		return graphItem.passToken
	end

	return self.passToken
end

function Runtime:isPassTokenValid(passToken)
	return self.isActive and not self.isCleaningNodes and passToken == self.passToken and passToken == self:getCurrentPassToken()
end

function Runtime:refreshPassToken()
	if not self.isActive or self.isCleaningNodes then
		return nil
	end

	local passToken = self:getCurrentPassToken()

	if passToken ~= self.passToken then
		self.passToken = passToken
		self.pendingExecutions = {}
		self.nodeRunTokens = {}
	end

	return passToken
end

local function getValueGetterName(portId)
	local result = {}
	local upperNext = true

	for part in tostring(portId or ""):gmatch("[A-Za-z0-9]+") do
		if upperNext then
			result[#result + 1] = part:sub(1, 1):upper() .. part:sub(2)
			upperNext = false
		else
			result[#result + 1] = part
		end
	end

	return "get" .. table.concat(result, "")
end

local function triggerNodeFailureFlows(ctx)
	if not ctx:isFlowValid() then
		return
	end

	if not ctx:hasTriggeredDefaultOut() then
		ctx:triggerFlow("Out")
	end

	local finishPortId = ctx:hasFlowConnection("FinishOut") and "FinishOut" or "Finish"

	ctx:triggerFlow(finishPortId)
end

function Runtime:getValueInput(nodeId, portId, defaultValue, passToken)
	local data = self.nodes[nodeId]
	local byPort = data and data.valueIn or nil
	local conn = byPort and byPort[portId] or nil

	if conn ~= nil then
		local sourceData = self.nodes[conn.nodeId]

		if sourceData ~= nil then
			local logic = self:getLogic(sourceData.kind)
			local getterName = getValueGetterName(conn.portId)
			local getter = logic[getterName]

			if getter == nil then
				error(string.format("ValueOutput getter missing: kind = %d port = %s expected = %s", sourceData.kind, tostring(conn.portId), getterName))
			end

			local sourceCtx = Context.new(self, conn.nodeId, passToken, nil, 0, 0, 0)
			local value = getter(sourceCtx)

			if value ~= nil then
				return value
			end

			return defaultValue
		end
	end

	if data and data.inputs and data.inputs[portId] ~= nil then
		local value = data.inputs[portId]

		if value ~= nil then
			return value
		end

		return defaultValue
	end

	return defaultValue
end

function Runtime:play()
	if self.finishCode ~= nil or self.isActive then
		return
	end

	self.runtimeGuard:reset("play")

	local playStartedAt = Performance.nowMs()
	local ok, err = SafeCallbackWithStatusAndReturn(function()
		if RuntimeDebug ~= nil then
			RuntimeDebug.graphStart(self)
		end

		self.isActive = true
		self.isPaused = false
		self.pendingExecutions = {}
		self.nodeRunTokens = {}

		if self.graphItem and self.graphItem.OnDialogueGraphPlay then
			self.graphItem:OnDialogueGraphPlay()
		end

		self:executeNode(self.startNodeId)
	end)

	Performance.record(self.performance, "luaRuntimePlayMs", Performance.elapsedMs(playStartedAt))

	if not ok then
		error(err)
	end
end

function Runtime:executeNode(nodeId, inputPortId, parentActivationId, triggerSequence)
	if not self:isPassTokenValid(self.passToken) then
		return
	end

	if self.isPaused then
		self.pendingExecutions[#self.pendingExecutions + 1] = {
			kind = "node",
			nodeId = nodeId,
			portId = inputPortId,
			passToken = self.passToken,
			parentActivationId = parentActivationId,
			triggerSequence = triggerSequence
		}

		return
	end

	self.executionDepth = self.executionDepth + 1

	local activationId = self.nextActivation

	self.nextActivation = activationId + 1

	local node = self.nodes[nodeId]

	if node == nil then
		if RuntimeDebug ~= nil then
			RuntimeDebug.runtimeDiagnostic(self, "对应节点配置不存在，请检查对话图导出文件！", nil, {
				reason = "NodeMissing",
				nodeId = nodeId
			}, "OrderedStrict")
		end

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("对应节点配置不存在，请检查对话图导出文件！", nodeId)
		end

		self:finishGraph(-1)

		return
	end

	local isStopPort = self:isStopPort(nodeId, inputPortId)
	local runToken

	if isStopPort then
		runToken = self.nodeRunTokens[nodeId] or 0
	else
		runToken = activationId
		self.nodeRunTokens[nodeId] = runToken
	end

	local ctx = Context.new(self, nodeId, self.passToken, inputPortId, activationId, parentActivationId, triggerSequence, runToken)

	self.activationContexts[activationId] = {
		nodeId = nodeId,
		inputPortId = inputPortId,
		parentActivationId = parentActivationId or 0,
		triggerSequence = triggerSequence or 0,
		runToken = runToken
	}

	if RuntimeDebug ~= nil then
		RuntimeDebug.nodeEnter(self, ctx)
	end

	local loadOk, logic = SafeCallbackWithStatusAndReturn(self.getLogic, self, node.kind)

	if not loadOk then
		if RuntimeDebug ~= nil then
			RuntimeDebug.nodeFailure(self, ctx, tostring(logic))
			RuntimeDebug.runtimeDiagnostic(self, "UnsupportedNode", ctx, {
				nodeKind = node.kind,
				reason = tostring(logic)
			}, "OrderedStrict")
		end

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("加载对话图节点失败 nodeId=%s kind=%s error=%s", tostring(nodeId), tostring(node.kind), tostring(logic))
		end

		self:finishGraph(-1)

		return
	end

	if logic.onGraphFinished ~= nil then
		self.runNodeContexts[nodeId] = ctx
	end

	local runner = logic.startNode or logic.run
	local ok, runResult, runMessage
	local performanceFrame = Performance.beginNode(self.performance)

	if logic.startNode ~= nil then
		ok, runResult, runMessage = SafeCallbackWithStatusAndReturn(runner, logic, ctx)
	else
		ok, runResult, runMessage = SafeCallbackWithStatusAndReturn(runner, ctx)
	end

	Performance.endNode(self.performance, performanceFrame, nodeId, NodeRegistry.getKindName(node.kind))

	if logic.startNode ~= nil then
		self.runtimeGuard:onNodeFinished(ctx)
	end

	if self.performanceReportPending and not Performance.hasActiveNodes(self.performance) then
		self.performanceReportPending = false

		logger:info("[对话图性能] %s", Performance.getReport(self.dialogueId, self.finishCode, self.performance))
	end

	if not ok then
		if RuntimeDebug ~= nil then
			RuntimeDebug.nodeFailure(self, ctx, tostring(runResult))
		end

		if logic.onNodeRunFailure ~= nil then
			SafeCallbackWithStatusAndReturn(logic.onNodeRunFailure, logic, ctx, tostring(runResult))
		end

		triggerNodeFailureFlows(ctx)

		return
	end

	if runResult == false then
		if RuntimeDebug ~= nil then
			RuntimeDebug.nodeFailure(self, ctx, tostring(runMessage or "RunResultFalse"))
		end

		triggerNodeFailureFlows(ctx)

		return
	end
end

function Runtime:onNodePortFired(nodeId, sourcePortId, activationId)
	local passToken = self.passToken

	if not self:isPassTokenValid(passToken) then
		return
	end

	local targets = self:getFlowTargets(nodeId, sourcePortId)

	if targets == nil then
		return
	end

	if self.isPaused then
		self.pendingExecutions[#self.pendingExecutions + 1] = {
			kind = "flow",
			nodeId = nodeId,
			portId = sourcePortId,
			passToken = self.passToken,
			activationId = activationId
		}

		return
	end

	local activation = self.activationContexts[activationId] or {}
	local sourceCtx = Context.new(self, nodeId, self.passToken, activation.inputPortId, activationId or 0, activation.parentActivationId or 0, activation.triggerSequence or 0, activation.runToken or 0)
	local flowSequence = 0

	if RuntimeDebug ~= nil then
		flowSequence = RuntimeDebug.flowOut(self, sourceCtx, sourcePortId)
	end

	for _, target in ipairs(targets) do
		if not self:isPassTokenValid(passToken) then
			return
		end

		self:executeNode(target.nodeId, target.portId, activationId or 0, flowSequence)

		if not self.isActive then
			return
		end
	end
end

function Runtime:finishGraph(code)
	if not self.isActive then
		return
	end

	if self.isCleaningNodes then
		self.pendingFinishCode = self.pendingFinishCode or code or 0

		return
	end

	self.finishCode = code or 0
	self.isActive = false
	self.isPaused = false
	self.pendingExecutions = {}

	local schedulerCleanupStartedAt = Performance.nowMs()

	self.scheduler:cancelAll()
	Performance.record(self.performance, "finishSchedulerCleanupMs", Performance.elapsedMs(schedulerCleanupStartedAt))

	self.activationContexts = {}
	self.nodeRunTokens = {}

	self:OnGraphStopped(self.finishCode)

	if Performance.isEnabled() then
		if Performance.hasActiveNodes(self.performance) then
			self.performanceReportPending = true
		else
			logger:info("[对话图性能] %s", Performance.getReport(self.dialogueId, self.finishCode, self.performance))
		end
	end

	if RuntimeDebug ~= nil then
		local runtimeDebugStartedAt = Performance.nowMs()

		RuntimeDebug.graphFinish(self, self.finishCode)
		Performance.record(self.performance, "finishRuntimeDebugMs", Performance.elapsedMs(runtimeDebugStartedAt))
	end
end

function Runtime:OnGraphStopped(code)
	local beginCallbackStartedAt = Performance.nowMs()

	if self.graphItem and self.graphItem.BeginGraphFinish then
		self.graphItem:BeginGraphFinish(self.finishCode)
	end

	Performance.record(self.performance, "finishBeginCallbackMs", Performance.elapsedMs(beginCallbackStartedAt))
	self:onNodesStopped(code)

	local completeCallbackStartedAt = Performance.nowMs()

	if self.graphItem and self.graphItem.CompleteGraphFinish then
		self.graphItem:CompleteGraphFinish(self.finishCode)
	end

	Performance.record(self.performance, "finishCompleteCallbackMs", Performance.elapsedMs(completeCallbackStartedAt))
end

function Runtime:onNodesStopped(code)
	if self.isCleaningNodes then
		return false
	end

	self.isCleaningNodes = true

	local contexts = self.runNodeContexts

	self.runNodeContexts = {}

	for nodeId, ctx in pairs(contexts) do
		contexts[nodeId] = nil

		local node = self.nodes[nodeId]
		local logic = node and self.logicCache[node.kind]

		if logic ~= nil and logic.onGraphFinished ~= nil then
			local ok, err = SafeCallbackWithStatusAndReturn(logic.onGraphFinished, ctx, code)

			if not ok then
				logger:error("对话图节点清理失败 nodeId=%s error=%s", tostring(nodeId), tostring(err))

				if RuntimeDebug ~= nil then
					RuntimeDebug.runtimeDiagnostic(self, "RuntimeError", ctx, {
						nodeKind = node.kind,
						error = tostring(err)
					}, "OrderedStrict")
				end
			end
		end
	end

	self.isCleaningNodes = false
end

function Runtime:onGraphSkipping()
	if not self.isActive or self.isCleaningNodes then
		return false
	end

	local passToken = self:getCurrentPassToken()

	if self.lastCleanupPassToken == passToken then
		return true
	end

	if passToken == self.passToken then
		return false
	end

	self:refreshPassToken()

	self.lastCleanupPassToken = passToken

	self.scheduler:cancelAll()

	self.activationContexts = {}

	self:onNodesStopped()

	local finishCode = self.pendingFinishCode

	self.pendingFinishCode = nil

	if finishCode ~= nil then
		self:finishGraph(finishCode)

		return false
	end

	return self.isActive and self:getCurrentPassToken() == passToken
end

function Runtime:stop()
	self:finishGraph(-1)
end

function Runtime:pause()
	if not self.isActive or self.isPaused then
		return
	end

	self.isPaused = true

	self.scheduler:pause()

	if RuntimeDebug ~= nil then
		RuntimeDebug.graphPause(self)
	end
end

function Runtime:resume()
	if not self.isActive or not self.isPaused then
		return
	end

	self.isPaused = false

	self.scheduler:resume()

	if RuntimeDebug ~= nil then
		RuntimeDebug.graphResume(self)
	end

	while self.isActive and not self.isPaused and #self.pendingExecutions > 0 do
		local pending = table.remove(self.pendingExecutions, 1)

		if self:isPassTokenValid(pending.passToken) then
			if pending.kind == "flow" then
				self:onNodePortFired(pending.nodeId, pending.portId, pending.activationId)
			else
				self:executeNode(pending.nodeId, pending.portId, pending.parentActivationId, pending.triggerSequence)
			end
		end
	end
end

function Runtime:dispose()
	if RuntimeDebug ~= nil and self.finishCode == nil then
		RuntimeDebug.graphDispose(self)
	end

	self.isActive = false
	self.isPaused = false
	self.pendingExecutions = {}

	self.scheduler:cancelAll()

	self.activationContexts = {}
	self.nodeRunTokens = {}
	self.runNodeContexts = {}
	self.pendingFinishCode = nil
end

return Runtime
