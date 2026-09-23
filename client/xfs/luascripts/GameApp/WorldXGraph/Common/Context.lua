-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\WorldXGraph\\Common\\Context.lua

local Context = {}

Context.__index = Context

local Trace = require("GameApp.WorldXGraph.Common.Trace")
local Performance = require("GameApp.WorldXGraph.Common.Performance")

function Context.new(runtime, nodeId, passToken, inputPortId)
	local self = setmetatable({}, Context)

	self.runtime = runtime
	self.nodeId = nodeId
	self.inputPortId = inputPortId
	self.passTokenSnapshot = passToken
	self.hasTriggeredDefaultOut = false

	return self
end

function Context:NodeId()
	return self.nodeId
end

function Context:NodeKind()
	return self.runtime.nodes[self.nodeId].kind
end

function Context:InputPort()
	return self.inputPortId
end

function Context:PassToken()
	return self.passTokenSnapshot
end

function Context:IsValid()
	return self.runtime.isActive and self.runtime.passToken == self.passTokenSnapshot
end

function Context:HasTriggeredDefaultOut()
	return self.hasTriggeredDefaultOut
end

function Context:GraphItem()
	return self.runtime.graphItem
end

function Context:GetInput(portId, defaultValue)
	return self.runtime:GetValueInput(self.nodeId, portId, defaultValue, self.passTokenSnapshot)
end

function Context:GetField(fieldId, defaultValue)
	local data = self.runtime.nodes[self.nodeId]

	if data.fields and data.fields[fieldId] ~= nil then
		return data.fields[fieldId]
	end

	return defaultValue
end

function Context:GetBlackboard(variableName, defaultValue)
	local blackboard = self.runtime.blackboard or {}

	if blackboard[variableName] ~= nil then
		return blackboard[variableName]
	end

	return defaultValue
end

function Context:SetBlackboard(variableName, value)
	self.runtime.blackboard = self.runtime.blackboard or {}
	self.runtime.blackboard[variableName] = value
end

function Context:CallCmd(cmdName, ...)
	local luaCmd = self.runtime.luaCmd

	if not luaCmd then
		return nil
	end

	local firstParam = ...

	if Trace.isEnabled() then
		Trace.record("NodeCmd", {
			cmd = cmdName,
			param = Trace.summarizeParam(firstParam)
		})
	end

	local cmdStartedAt = Performance.NowMs()
	local results = {
		pcall(luaCmd.onGraphNodeRunning, luaCmd, cmdName, ...)
	}

	Performance.Add(self.runtime.performance, "nodeCmdMs", "nodeCmdCount", Performance.ElapsedMs(cmdStartedAt))

	if not results[1] then
		error(results[2])
	end

	return table.unpack(results, 2)
end

function Context:InvokeCmd(cmdName, ...)
	return self:CallCmd(cmdName, ...)
end

function Context:Delay(seconds, callback)
	return self.runtime.scheduler:Delay(self.nodeId, seconds, callback)
end

function Context:DelayFrame(frames, callback)
	return self.runtime.scheduler:DelayFrame(self.nodeId, frames or 0, callback)
end

function Context:StartTimeout(seconds, onTimeout)
	return self.runtime.scheduler:StartTimeout(self.nodeId, seconds, onTimeout)
end

function Context:CancelTimeout()
	self.runtime.scheduler:CancelTimeout(self.nodeId)
end

function Context:TriggerFlow(portId)
	if not self:IsValid() then
		if Trace.isEnabled() then
			Trace.record("FlowIgnored", {
				reason = "invalid",
				nodeId = self.nodeId,
				port = portId
			})
		end

		return
	end

	if portId == "Out" then
		self.hasTriggeredDefaultOut = true
	end

	self.runtime:OnNodePortFired(self.nodeId, portId)
end

function Context:TriggerNodeFlow(nodeId, portId)
	if not self:IsValid() then
		if Trace.isEnabled() then
			Trace.record("FlowIgnored", {
				reason = "invalid",
				nodeId = nodeId,
				port = portId
			})
		end

		return
	end

	self.runtime:OnNodePortFired(nodeId, portId)
end

function Context:GetFlowTargets(sourcePortId)
	return self.runtime:GetFlowTargets(self.nodeId, sourcePortId)
end

function Context:GetFlowTargetsFromNode(nodeId, sourcePortId)
	return self.runtime:GetFlowTargets(nodeId, sourcePortId)
end

function Context:GetNodeKindByNodeId(nodeId)
	local node = self.runtime.nodes[nodeId]

	return node and node.kind or nil
end

function Context:GetNodeField(nodeId, fieldId, defaultValue)
	local node = self.runtime.nodes[nodeId]

	if node ~= nil and node.fields ~= nil and node.fields[fieldId] ~= nil then
		return node.fields[fieldId]
	end

	return defaultValue
end

function Context:HasFlowConnection(sourcePortId)
	return self.runtime:HasFlowConnection(self.nodeId, sourcePortId)
end

function Context:StateGet(key, defaultValue)
	local state = self.runtime.nodeStates[self.nodeId]

	if state[key] == nil then
		return defaultValue
	end

	return state[key]
end

function Context:StateSet(key, value)
	self.runtime.nodeStates[self.nodeId][key] = value
end

function Context:RecordTrace(eventType, payload)
	if Trace.isEnabled() then
		Trace.record(eventType, payload)
	end
end

function Context:FinishGraph(code)
	self.runtime:FinishGraph(code)
end

function Context:Fail(errorMsg)
	if Trace.isEnabled() then
		Trace.record("Fail", tostring(errorMsg))
	end
end

return Context
