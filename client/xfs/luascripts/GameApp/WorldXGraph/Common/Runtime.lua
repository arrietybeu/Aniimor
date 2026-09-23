-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\WorldXGraph\\Common\\Runtime.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Runtime = {}

Runtime.__index = Runtime

local Context = require("GameApp.WorldXGraph.Common.Context")
local Scheduler = require("GameApp.WorldXGraph.Common.Scheduler")
local Trace = require("GameApp.WorldXGraph.Common.Trace")
local Performance = require("GameApp.WorldXGraph.Common.Performance")
local Time = require("Core.Common.Time")

local function CopyBlackboard(source)
	local result = {}

	if source == nil then
		return result
	end

	for key, value in pairs(source) do
		result[key] = value
	end

	return result
end

function Runtime.Load(data, graphItem, luaCmd)
	local self = setmetatable({}, Runtime)

	self.data = data
	self.dialogueId = data.dialogueId
	self.startNodeId = data.startNodeId
	self.nodes = data.nodes or {}
	self.connections = data.connections or {}
	self.logicMap = data.logicMap or {}
	self.flowOut = data.flowOut or {}
	self.valueIn = data.valueIn or {}
	self.logicCache = {}
	self.blackboard = CopyBlackboard(data.blackboard)
	self.graphItem = graphItem
	self.luaCmd = luaCmd
	self.passToken = graphItem and graphItem.passToken or 0
	self.isActive = false
	self.finishCode = nil
	self.nodeStates = {}
	self.scheduler = Scheduler.new(self)
	self.performance = {}

	for nodeId, _ in pairs(self.nodes) do
		self.nodeStates[nodeId] = {}
	end

	self:EnsureConnectionIndexes()
	self:ApplyExternalLuaVariables()

	return self
end

function Runtime:ApplyExternalLuaVariables()
	if self.graphItem == nil or self.graphItem.luaVariables == nil then
		return
	end

	local ok, err = pcall(function()
		for key in pairs(self.blackboard) do
			local override = self.graphItem.luaVariables[key]

			if override ~= nil then
				self.blackboard[key] = override
			end
		end
	end)

	if not ok and Trace.isEnabled() then
		Trace.record("RuntimeWarning", {
			warning = "ApplyExternalLuaVariables failed",
			error = tostring(err)
		})
	end
end

function Runtime:EnsureConnectionIndexes()
	if next(self.flowOut) ~= nil or next(self.valueIn) ~= nil then
		return
	end

	self.flowOut = {}
	self.valueIn = {}

	for _, conn in ipairs(self.connections or EMPTY_TABLE) do
		if conn.isFlow then
			self.flowOut[conn.source] = self.flowOut[conn.source] or {}

			local byPort = self.flowOut[conn.source]

			byPort[conn.sourcePort] = byPort[conn.sourcePort] or {}

			local targets = byPort[conn.sourcePort]

			targets[#targets + 1] = {
				nodeId = conn.target,
				portId = conn.targetPort
			}
		else
			self.valueIn[conn.target] = self.valueIn[conn.target] or {}
			self.valueIn[conn.target][conn.targetPort] = {
				nodeId = conn.source,
				portId = conn.sourcePort
			}
		end
	end

	for _, byPort in pairs(self.flowOut) do
		for _, targets in pairs(byPort) do
			table.sort(targets, function(left, right)
				return (left.nodeId or 0) < (right.nodeId or 0)
			end)
		end
	end
end

function Runtime:GetLogic(kind)
	local logic = self.logicCache[kind]

	if logic ~= nil then
		return logic
	end

	local logicPath = self.logicMap[kind]

	if logicPath == nil or logicPath == "" then
		error("Unknown node kind: " .. tostring(kind))
	end

	local requireStartedAt = Performance.NowMs()
	local ok, result = pcall(require, logicPath)

	if not ok then
		error(result)
	end

	logic = result

	Performance.Add(self.performance, "logicRequireMs", "logicRequireCount", Performance.ElapsedMs(requireStartedAt))

	self.logicCache[kind] = logic

	return logic
end

function Runtime:GetFlowTargets(nodeId, portId)
	local byPort = self.flowOut[nodeId]

	if byPort == nil then
		return {}
	end

	return byPort[portId] or {}
end

function Runtime:HasFlowConnection(nodeId, portId)
	local targets = self:GetFlowTargets(nodeId, portId)

	return targets ~= nil and #targets > 0
end

local function GetValueGetterName(portId)
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

	return "Get" .. table.concat(result, "")
end

function Runtime:GetValueInput(nodeId, portId, defaultValue, passToken)
	local byPort = self.valueIn[nodeId]
	local conn = byPort and byPort[portId] or nil

	if conn ~= nil then
		local sourceData = self.nodes[conn.nodeId]

		if sourceData ~= nil then
			local logic = self:GetLogic(sourceData.kind)
			local getterName = GetValueGetterName(conn.portId)
			local getter = logic[getterName]

			if getter == nil then
				error("ValueOutput getter missing: kind=" .. tostring(sourceData.kind) .. " port=" .. tostring(conn.portId) .. " expected=" .. getterName)
			end

			local sourceCtx = Context.new(self, conn.nodeId, passToken, nil)

			return getter(sourceCtx)
		end
	end

	local data = self.nodes[nodeId]

	if data and data.inputs and data.inputs[portId] ~= nil then
		return data.inputs[portId]
	end

	return defaultValue
end

function Runtime:Play()
	if self.finishCode ~= nil then
		return
	end

	local playStartedAt = Performance.NowMs()
	local ok, err = pcall(function()
		self.isActive = true

		if self.graphItem and self.graphItem.OnDialogueGraphPlay then
			self.graphItem:OnDialogueGraphPlay()
		end

		if Trace.isEnabled() then
			Trace.beginRun("compiled", self.dialogueId)
		end

		self:ExecuteNode(self.startNodeId)
	end)

	Performance.Record("RecordLuaRuntimePlayPerformance", Performance.ElapsedMs(playStartedAt))

	if not ok then
		error(err)
	end
end

function Runtime:ExecuteNode(nodeId, inputPortId)
	if not self.isActive then
		return
	end

	local node = self.nodes[nodeId]

	if node == nil then
		self:FinishGraph(-1)

		return
	end

	local currentFrame = Time.frameCount

	if currentFrame ~= nil then
		self.nodeEnterFrame = self.nodeEnterFrame or {}

		local entryKey = tostring(nodeId) .. "|" .. tostring(inputPortId or "")

		if self.nodeEnterFrame[entryKey] == currentFrame then
			if Trace.isEnabled() then
				Trace.record("NodeEnterDedup", {
					nodeId = nodeId,
					nodeKind = node.kind,
					port = tostring(inputPortId or "")
				})
			end

			return
		end

		self.nodeEnterFrame[entryKey] = currentFrame
	end

	if Trace.isEnabled() then
		Trace.record("NodeEnter", {
			nodeId = nodeId,
			nodeKind = node.kind
		})
	end

	local logic = self:GetLogic(node.kind)
	local ctx = Context.new(self, nodeId, self.passToken, inputPortId)
	local runner = logic.StartNode or logic.Run
	local ok, err

	if logic.StartNode ~= nil then
		ok, err = pcall(runner, logic, ctx)
	else
		ok, err = pcall(runner, ctx)
	end

	if not ok then
		if Trace.isEnabled() then
			Trace.record("NodeError", {
				nodeId = nodeId,
				nodeKind = node.kind,
				error = tostring(err)
			})
		end

		if logic.OnNodeRunFailure ~= nil then
			pcall(logic.OnNodeRunFailure, logic, ctx, tostring(err))
		end

		self:FinishGraph(-1)

		return
	end

	if err == false then
		if Trace.isEnabled() then
			Trace.record("NodeError", {
				error = "RunResultFalse",
				nodeId = nodeId,
				nodeKind = node.kind
			})
		end

		self:FinishGraph(-1)

		return
	end
end

function Runtime:OnNodePortFired(nodeId, sourcePortId)
	if not self.isActive then
		return
	end

	if Trace.isEnabled() then
		Trace.record("FlowOut", {
			nodeId = nodeId,
			port = sourcePortId
		})
	end

	for _, target in ipairs(self:GetFlowTargets(nodeId, sourcePortId)) do
		self:ExecuteNode(target.nodeId, target.portId)

		if not self.isActive then
			return
		end
	end
end

function Runtime:FinishGraph(code)
	if self.finishCode ~= nil then
		return
	end

	self.finishCode = code or 0

	self:NotifyGraphFinished(self.finishCode)

	self.isActive = false

	self.scheduler:CancelAll()

	if Trace.isEnabled() then
		Trace.endRun(self.finishCode)
	end

	Performance.Flush(self.performance)

	if self.graphItem and self.graphItem.FinishCompiledGraph then
		self.graphItem:FinishCompiledGraph(self.finishCode)
	end
end

function Runtime:NotifyGraphFinished(code)
	for nodeId, node in pairs(self.nodes) do
		local logic = self.logicCache[node.kind]

		if logic ~= nil and logic.OnGraphFinished ~= nil then
			local ctx = Context.new(self, nodeId, self.passToken, nil)
			local ok, err = pcall(logic.OnGraphFinished, ctx, code)

			if not ok and Trace.isEnabled() then
				Trace.record("NodeError", {
					nodeId = nodeId,
					nodeKind = node.kind,
					error = tostring(err)
				})
			end
		end
	end
end

function Runtime:Stop()
	if self.finishCode == nil then
		self:FinishGraph(-1)
	else
		self.isActive = false

		self.scheduler:CancelAll()
	end
end

function Runtime:Pause()
	self.scheduler:Pause()
end

function Runtime:Resume()
	self.scheduler:Resume()
end

function Runtime:Dispose()
	self.isActive = false

	self.scheduler:CancelAll()
end

return Runtime
