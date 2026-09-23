-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Core\\Context.lua

local Context = {}

Context.__index = Context

local NodeRegistry = require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.NodeRegistry")
local Performance = require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.Performance")
local SafeCallbackWithStatusAndReturn = require("Core.Framework.SafeCallbackWithStatusAndReturn")
local RuntimeDebug = UNITY_EDITOR and require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.RuntimeDebug") or nil

function Context.new(runtime, nodeId, passToken, inputPortId, activationId, parentActivationId, triggerSequence, runToken)
	local self = setmetatable({}, Context)

	self.runtime = runtime
	self._nodeId = nodeId
	self.inputPortId = inputPortId
	self.passTokenSnapshot = passToken
	self._activationId = activationId or 0
	self._parentActivationId = parentActivationId or 0
	self._triggerSequence = triggerSequence or 0
	self.runTokenSnapshot = runToken or 0
	self._hasTriggeredDefaultOut = false

	return self
end

function Context:nodeId()
	return self._nodeId
end

function Context:nodeKind()
	return NodeRegistry.getKindName(self.runtime.nodes[self._nodeId].kind)
end

function Context:inputPort()
	return self.inputPortId
end

function Context:passToken()
	return self.passTokenSnapshot
end

function Context:isFlowValid()
	if self.runtime.isPassTokenValid ~= nil then
		return self.runtime:isPassTokenValid(self.passTokenSnapshot)
	end

	return self.runtime.isActive and self.runtime.passToken == self.passTokenSnapshot
end

function Context:isValid()
	if not self:isFlowValid() then
		return false
	end

	if self.runTokenSnapshot == 0 then
		return true
	end

	local runTokens = self.runtime.nodeRunTokens

	return runTokens ~= nil and runTokens[self._nodeId] == self.runTokenSnapshot
end

function Context:tryConsumeRunToken()
	if not self:isFlowValid() or self.runTokenSnapshot == 0 then
		return false
	end

	local runTokens = self.runtime.nodeRunTokens

	if runTokens == nil or runTokens[self._nodeId] ~= self.runTokenSnapshot then
		return false
	end

	runTokens[self._nodeId] = nil

	return true
end

function Context:refreshFlowPassToken()
	local passToken = self.runtime:refreshPassToken()

	if passToken == nil then
		return false
	end

	self.passTokenSnapshot = passToken
	self.runTokenSnapshot = 0

	return true
end

function Context:hasTriggeredDefaultOut()
	return self._hasTriggeredDefaultOut
end

function Context:graphItem()
	return self.runtime.graphItem
end

function Context:getInput(portId, defaultValue)
	return self.runtime:getValueInput(self._nodeId, portId, defaultValue, self.passTokenSnapshot)
end

function Context:activationId()
	return self._activationId
end

function Context:parentActivationId()
	return self._parentActivationId
end

function Context:triggerSequence()
	return self._triggerSequence
end

function Context:getField(fieldId, defaultValue)
	local data = self.runtime.nodes[self._nodeId]

	if data.fields and data.fields[fieldId] ~= nil then
		return data.fields[fieldId]
	end

	return defaultValue
end

function Context:getDynamicInputs()
	local data = self.runtime.nodes[self._nodeId]

	return data and data.dynamicInputs or nil
end

function Context:getBlackboard(variableName, defaultValue)
	if variableName == nil then
		return defaultValue
	end

	local blackboard = self.runtime.blackboard

	if blackboard and blackboard[variableName] ~= nil then
		local value = blackboard[variableName]

		if RuntimeDebug ~= nil and RuntimeDebug.isSemanticCaptureEnabled() then
			RuntimeDebug.runtimeDiagnostic(self.runtime, "VariableRead", self, {
				variableName = variableName,
				value = value
			}, "OrderedStrict")
		end

		return value
	end

	return defaultValue
end

function Context:setBlackboard(variableName, value)
	if variableName == nil or self.runtime.blackboard == nil then
		return
	end

	local previousValue = self.runtime.blackboard[variableName]

	self.runtime.blackboard[variableName] = value

	if previousValue ~= value then
		self:markProgress()
	end

	if RuntimeDebug ~= nil and RuntimeDebug.isSemanticCaptureEnabled() then
		RuntimeDebug.runtimeDiagnostic(self.runtime, "VariableWrite", self, {
			variableName = variableName,
			value = value
		}, "OrderedStrict")
	end
end

function Context:markProgress()
	local runtimeGuard = self.runtime and self.runtime.runtimeGuard or nil

	if runtimeGuard ~= nil then
		runtimeGuard:markProgress(self)
	end
end

function Context:callCmd(cmdName, ...)
	local luaCmd = self.runtime.luaCmd

	if not luaCmd then
		return nil
	end

	if not Performance.isEnabled() then
		return luaCmd:onGraphNodeRunning(cmdName, ...)
	end

	local startedAt = Performance.nowMs()
	local results = {
		SafeCallbackWithStatusAndReturn(luaCmd.onGraphNodeRunning, luaCmd, cmdName, ...)
	}

	Performance.recordCommand(self.runtime.performance, cmdName, Performance.elapsedMs(startedAt))

	if not results[1] then
		error(results[2])
	end

	return table.unpack(results, 2)
end

function Context:invokeCmd(cmdName, ...)
	return self:callCmd(cmdName, ...)
end

function Context:delay(seconds, callback)
	if not self:isFlowValid() then
		return nil
	end

	return self.runtime.scheduler:delay(self._nodeId, seconds, callback)
end

function Context:delayFrame(frames, callback)
	if not self:isFlowValid() then
		return nil
	end

	return self.runtime.scheduler:delayFrame(self._nodeId, frames or 0, callback)
end

function Context:startTimeout(seconds, onTimeout)
	if not self:isFlowValid() then
		return nil
	end

	return self.runtime.scheduler:startTimeout(self._nodeId, seconds, onTimeout)
end

function Context:cancelTimeout()
	self.runtime.scheduler:cancelTimeout(self._nodeId)
end

function Context:triggerFlow(portId)
	if not self:isFlowValid() then
		if RuntimeDebug ~= nil then
			RuntimeDebug.flowIgnored(self.runtime, self, portId, "invalid")
		end

		return
	end

	if portId == "Out" then
		self._hasTriggeredDefaultOut = true
	end

	self.runtime:onNodePortFired(self._nodeId, portId, self._activationId)
end

function Context:triggerNodeFlow(nodeId, portId)
	if not self:isFlowValid() then
		if RuntimeDebug ~= nil then
			RuntimeDebug.flowIgnored(self.runtime, self, portId, "invalid")
		end

		return
	end

	self.runtime:onNodePortFired(nodeId, portId, self._activationId)
end

function Context:getFlowTargets(sourcePortId)
	return self.runtime:getFlowTargets(self._nodeId, sourcePortId)
end

function Context:getFlowTargetsFromNode(nodeId, sourcePortId)
	return self.runtime:getFlowTargets(nodeId, sourcePortId)
end

function Context:getNodeKindByNodeId(nodeId)
	local node = self.runtime.nodes[nodeId]

	if node == nil or type(node.kind) == "number" then
		return node and node.kind or nil
	end

	return NodeRegistry.getKindValue(node.kind)
end

function Context:getNodeField(nodeId, fieldId, defaultValue)
	local node = self.runtime.nodes[nodeId]

	if node ~= nil and node.fields ~= nil and node.fields[fieldId] ~= nil then
		return node.fields[fieldId]
	end

	return defaultValue
end

function Context:hasFlowConnection(sourcePortId)
	return self.runtime:hasFlowConnection(self._nodeId, sourcePortId)
end

function Context:getNodeInput(nodeId, portId, defaultValue)
	return self.runtime:getValueInput(nodeId, portId, defaultValue, self.passTokenSnapshot)
end

function Context:isFlowInputConnected(targetPortId)
	return self.runtime:isFlowInputConnected(self._nodeId, targetPortId)
end

function Context:isStopPort()
	return self.runtime:isStopPort(self._nodeId, self.inputPortId)
end

function Context:isValueInputConnected(portId)
	return self.runtime:isValueInputConnected(self._nodeId, portId)
end

function Context:stateGet(key, defaultValue)
	local state = self.runtime.nodeStates[self._nodeId]

	if state == nil or state[key] == nil then
		return defaultValue
	end

	return state[key]
end

function Context:stateSet(key, value)
	local nodeStates = self.runtime.nodeStates
	local state = nodeStates[self._nodeId]

	if state == nil then
		if value == nil then
			return
		end

		state = {}
		nodeStates[self._nodeId] = state
	end

	state[key] = value
end

function Context:finishGraph(code)
	self.runtime:finishGraph(code)
end

function Context:fail(errorMsg)
	if RuntimeDebug ~= nil then
		RuntimeDebug.runtimeDiagnostic(self.runtime, "NodeFailure", self, {
			message = tostring(errorMsg)
		}, "OrderedStrict")
	end
end

return Context
