-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\GraphContext.lua

local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("FlowCanvas")
local GraphContext = Class.LiteClass("GraphContext")
local CallbackHandler = require("Core.Common.CallbackHandler")
local SandboxConst = require("Common.Const.SandboxConst")
local pairs = pairs

function GraphContext:ctor(space, graph, sandbox)
	self.space = space
	self.spaceId = space.id
	self.graph = graph
	self.graphId = graph.graphId
	self.contextId = self:genContextId()
	self.logger = logger
	self.context = {}
	self.timers = {}
	self.timersRevert = {}
	self.repeatTimersRevert = {}
	self.timerId2Handler = {}
	self.repeatTimerId2Interval = {}
	self.timerStopInfo = {}
	self.runningNodes = {}
	self.sequenceFlow = {}
	self.spaceEventListeners = {}
	self.sandboxEventListeners = {}
	self.sandbox = sandbox
	self.sandboxId = sandbox.staticId
	self.blackboard = {}
	self.graphTimerKey = "graphTimerKey" .. self.contextId
	self.callOutputNodesCount = {}
	self.callInputNodesCount = {}
	self.callOutputNodesInfo = {}
	self.callInputNodesInfo = {}
end

function GraphContext:genContextId()
	return self.space.id .. self.graphId
end

function GraphContext:getContextId()
	return self.contextId
end

function GraphContext:registerSpaceEventListener(nodeId, eventName, listener)
	self:unregisterSpaceEventListener(nodeId, eventName)

	local space = self.space

	if not space then
		return false
	end

	local eventListeners = self.spaceEventListeners[nodeId] or {}

	self.spaceEventListeners[nodeId] = eventListeners

	space:addSpaceEventListener(eventName, listener)

	eventListeners[eventName] = listener

	self:addRunningNode(nodeId)

	return true
end

function GraphContext:unregisterSpaceEventListener(nodeId, eventName)
	local eventListeners = self.spaceEventListeners[nodeId]

	if not eventListeners then
		return false
	end

	local listener = eventListeners[eventName]

	if not listener then
		return false
	end

	local space = self.space

	if space then
		space:removeEventListener(eventName, listener)
	end

	eventListeners[eventName] = nil

	if not next(eventListeners) then
		self.spaceEventListeners[nodeId] = nil
	end

	if not self.spaceEventListeners[nodeId] and not self.sandboxEventListeners[nodeId] then
		self:removeRunningNode(nodeId)
	end

	return true
end

function GraphContext:registerSandboxEventListener(nodeId, eventName, listener)
	self:unregisterSandboxEventListener(nodeId, eventName)

	local sandbox = self.sandbox

	if not sandbox then
		return false
	end

	local eventListeners = self.sandboxEventListeners[nodeId] or {}

	self.sandboxEventListeners[nodeId] = eventListeners

	sandbox:addEventListener(eventName, listener)

	eventListeners[eventName] = listener

	self:addRunningNode(nodeId)

	return true
end

function GraphContext:unregisterSandboxEventListener(nodeId, eventName)
	local eventListeners = self.sandboxEventListeners[nodeId]

	if not eventListeners then
		return false
	end

	local listener = eventListeners[eventName]

	if not listener then
		return false
	end

	local sandbox = self.sandbox

	if sandbox then
		sandbox:removeEventListener(eventName, listener)
	end

	eventListeners[eventName] = nil

	if not next(eventListeners) then
		self.sandboxEventListeners[nodeId] = nil
	end

	if not self.spaceEventListeners[nodeId] and not self.sandboxEventListeners[nodeId] then
		self:removeRunningNode(nodeId)
	end

	return true
end

function GraphContext:unregisterSpaceEventListeners(nodeId)
	local spaceListeners = self.spaceEventListeners[nodeId]

	if not spaceListeners then
		return false
	end

	local space = self.space

	if space then
		for eventName, listener in pairs(spaceListeners) do
			space:removeEventListener(eventName, listener)
		end
	end

	self.spaceEventListeners[nodeId] = nil

	if not self.sandboxEventListeners[nodeId] then
		self:removeRunningNode(nodeId)
	end

	return true
end

function GraphContext:unregisterSandboxEventListeners(nodeId)
	local sandboxListeners = self.sandboxEventListeners[nodeId]

	if not sandboxListeners then
		return false
	end

	local sandbox = self.sandbox

	if sandbox then
		for eventName, listener in pairs(sandboxListeners) do
			sandbox:removeEventListener(eventName, listener)
		end
	end

	self.sandboxEventListeners[nodeId] = nil

	if not self.spaceEventListeners[nodeId] then
		self:removeRunningNode(nodeId)
	end

	return true
end

function GraphContext:unregisterEventListeners(nodeId)
	local spaceUnregistered = self:unregisterSpaceEventListeners(nodeId)
	local sandboxUnregistered = self:unregisterSandboxEventListeners(nodeId)

	return spaceUnregistered or sandboxUnregistered
end

function GraphContext:unregisterAllEventListeners()
	local nodeIds = {}

	for nodeId in pairs(self.spaceEventListeners) do
		nodeIds[nodeId] = true
	end

	for nodeId in pairs(self.sandboxEventListeners) do
		nodeIds[nodeId] = true
	end

	for nodeId in pairs(nodeIds) do
		self:unregisterEventListeners(nodeId)
	end
end

function GraphContext:destroy()
	self:unregisterAllEventListeners()
	self.graph:onContextDestroy(self)

	self.context = {}

	local space = self.space

	for _, timer in pairs(self.timers) do
		space:removeTimer(timer)
	end

	self.space = nil
	self._destroyed = true
	self.runningNodes = {}
	self.sequenceFlow = {}
	self.spaceEventListeners = {}
	self.sandboxEventListeners = {}
	self.blackboard = {}
	self.timersRevert = {}
	self.repeatTimersRevert = {}
	self.repeatTimerId2Interval = {}
	self.timerStopInfo = {}
	self.callOutputNodesCount = {}
	self.callInputNodesCount = {}
	self.callOutputNodesInfo = {}
	self.callInputNodesInfo = {}
end

function GraphContext:setContextValue(k, v)
	self.context[k] = v
end

function GraphContext:getContextValue(k)
	return self.context[k]
end

function GraphContext:addSequeceFlow(k, flowInput)
	local sequence = self.sequenceFlow[k] or {}

	sequence[flowInput] = true
	self.sequenceFlow[k] = sequence

	return sequence
end

function GraphContext:getSequenceFlow(k)
	return self.sequenceFlow[k]
end

function GraphContext:removeSequenceFlow(k)
	self.sequenceFlow[k] = nil
end

function GraphContext:setCurNodeId(nodeId)
	self.nodeId = nodeId
end

function GraphContext:getCurNodeId()
	return self.nodeId
end

function GraphContext:getSpace()
	if self._destroyed then
		return nil
	end

	if not self.space and LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("space is nil, spaceId: %s, graphId: %s, sandboxId: %s", self.spaceId, self.graphId, self.sandboxId)
	end

	return self.space
end

function GraphContext:debugOpen()
	return self.graph.debugSwitch or false
end

function GraphContext:addRunningNode(nodeId)
	if not _G_IsDebugMode then
		return
	end

	if not self.runningNodes[nodeId] then
		self.runningNodes[nodeId] = true

		if self:debugOpen() then
			self.space:allClientsMsg("RPC_SC_GraphRunningNode", self.graphId, nodeId, true)
		end
	end
end

function GraphContext:removeRunningNode(nodeId)
	if not _G_IsDebugMode then
		return
	end

	if self.runningNodes[nodeId] then
		self.runningNodes[nodeId] = false

		if self:debugOpen() then
			self.space:allClientsMsg("RPC_SC_GraphRunningNode", self.graphId, nodeId, false)
		end
	end
end

function GraphContext:onNodeOutput(nodeId, nextNodeId, nextNodePortName)
	local count = self.callOutputNodesCount[nodeId] or 0

	self.callOutputNodesCount[nodeId] = count + 1

	if nextNodeId ~= nil then
		self.callOutputNodesInfo[nodeId] = self.callOutputNodesInfo[nodeId] or {}
		self.callOutputNodesInfo[nodeId][nextNodeId] = self.callOutputNodesInfo[nodeId][nextNodeId] or {}
		self.callOutputNodesInfo[nodeId][nextNodeId][nextNodePortName] = (self.callOutputNodesInfo[nodeId][nextNodeId][nextNodePortName] or 0) + 1
	end
end

function GraphContext:onNodeInput(nodeId, sourceNodeId, sourceNodePortName)
	local count = self.callInputNodesCount[nodeId] or 0

	self.callInputNodesCount[nodeId] = count + 1

	if sourceNodeId ~= nil then
		self.callInputNodesInfo[nodeId] = self.callInputNodesInfo[nodeId] or {}
		self.callInputNodesInfo[nodeId][sourceNodeId] = self.callInputNodesInfo[nodeId][sourceNodeId] or {}
		self.callInputNodesInfo[nodeId][sourceNodeId][sourceNodePortName] = (self.callInputNodesInfo[nodeId][sourceNodeId][sourceNodePortName] or 0) + 1
	end
end

function GraphContext:addContextTimer(k, time, flowNode, funcName)
	local handler = CallbackHandler(flowNode, funcName, self)

	self:_addContextTimerInner(k, time, handler)
end

function GraphContext:_addContextTimerInner(k, time, handler)
	if not self.space then
		return
	end

	self:removeContextTimer(k)

	local timerId = self.space:addTimer(time, handler)

	self.timers[k] = timerId
	self.timersRevert[timerId] = k
	self.timerId2Handler[timerId] = handler
end

function GraphContext:addContextRepeatTimer(k, time, flowNode, funcName)
	local handler = CallbackHandler(flowNode, funcName, self)

	self:_addContextRepeatTimerInner(k, time, handler)
end

function GraphContext:_addContextRepeatTimerInner(k, time, handler, leftMs)
	if not self.space then
		return
	end

	self:removeContextTimer(k)

	local timerId

	if leftMs ~= nil then
		timerId = self.space.callbackGuard:recoverTimerCallback(leftMs, time, true, handler)
	else
		timerId = self.space:addRepeatTimer(time, handler)
	end

	self.timers[k] = timerId
	self.repeatTimersRevert[timerId] = k
	self.timerId2Handler[timerId] = handler
	self.repeatTimerId2Interval[timerId] = time
end

function GraphContext:getTimer(k)
	return self.timers[k] or self.timerStopInfo[k]
end

function GraphContext:removeContextTimer(k, nodeId)
	if not self.space then
		return
	end

	if k == nil then
		return
	end

	local timerId = self.timers[k]

	if timerId then
		self.space:removeTimer(timerId)

		self.timers[k] = nil
		self.timersRevert[timerId] = nil
		self.repeatTimersRevert[timerId] = nil
		self.repeatTimerId2Interval[timerId] = nil
	end

	if self.timerId2Handler[timerId] then
		self.timerId2Handler[timerId] = nil
	end

	self.timerStopInfo[k] = nil
end

function GraphContext:getBlackboardVariable(variableName)
	local localVar = self.blackboard[variableName]

	if localVar then
		return localVar
	end

	return self.graph.blackboard[variableName]
end

function GraphContext:setBlackboardVariable(variableName, variableValue)
	self.blackboard[variableName] = variableValue
end

function GraphContext:getSandboxPhase(sandboxId)
	if not self.space then
		return 0
	end

	local player = self.space:getMainPlayer()

	if player then
		return player:getSandboxPhase(sandboxId)
	end

	return 0
end

function GraphContext:setSandboxPhase(phase)
	if not self.space then
		return
	end

	local player = self.space:getMainPlayer()

	if player then
		player:setSandboxPhase(self.sandboxId, phase, SandboxConst.PHASE_CHANGE_REASON.INTERNAL)
	end
end

function GraphContext:getGraphPlayers()
	if self._destroyed then
		return {}
	end

	local space, sandboxId = self.space, self.sandboxId

	if not space then
		logger:error("GraphContext:getGraphPlayers space is nil, graphId=%s, sandboxId=%s", self.graphId, sandboxId)

		return {}
	end

	local sandbox = space.sandboxes and space.sandboxes[sandboxId]

	if not sandbox then
		logger:error("GraphContext:getGraphPlayers  sandbox is nil, graphId=%s, sandboxId=%s, spaceId=%s", self.graphId, sandboxId, space.id)

		return space.players
	end

	return sandbox:getActivePlayers()
end

function GraphContext:stopGameTime()
	if not self.space then
		return
	end

	for timerId, handler in pairs(self.timerId2Handler) do
		local timerKey = self.timersRevert[timerId] or self.repeatTimersRevert[timerId]
		local leftMs = self.space.callbackGuard:getSerializableTimerLeftMs(timerId)
		local timerInfo

		if leftMs >= 0 then
			if self.timersRevert[timerId] then
				timerInfo = {
					false,
					leftMs,
					handler
				}
			elseif self.repeatTimersRevert[timerId] then
				timerInfo = {
					true,
					leftMs,
					handler,
					self.repeatTimerId2Interval[timerId]
				}
			end
		end

		if timerKey ~= nil then
			self:removeContextTimer(timerKey)

			if timerInfo ~= nil then
				self.timerStopInfo[timerKey] = timerInfo
			end
		end
	end
end

function GraphContext:startGameTime()
	local timerStopInfo = self.timerStopInfo

	self.timerStopInfo = {}

	for timerKey, timerInfo in pairs(timerStopInfo) do
		local isRepeat, leftMs, handler, repeatInterval = unpack(timerInfo)

		if isRepeat then
			if repeatInterval == nil then
				self.logger:warn("@graph GraphContext/startGameTime lost repeatInterval graphId=%s sandboxId=%s timerKey=%s", self.graphId, self.sandboxId, timerKey)
			else
				self:_addContextRepeatTimerInner(timerKey, repeatInterval, handler, leftMs)
			end
		else
			self:_addContextTimerInner(timerKey, leftMs / 1000, handler)
		end
	end
end

function GraphContext:getTargetPlayers(targetType, specifiedPlayerId)
	local players

	if targetType == SandboxConst.NODE_TARGET_TYPE.AllPlayersInSandbox then
		players = self:getGraphPlayers()
	elseif targetType == SandboxConst.NODE_TARGET_TYPE.SpaceOwner then
		if self.space then
			local mainPlayer = self.space:getMainPlayer()

			if mainPlayer then
				players = {
					mainPlayer
				}
			end
		end
	elseif targetType == SandboxConst.NODE_TARGET_TYPE.SpecifiedPlayer then
		local specifiedPlayer = pg.getEntity(specifiedPlayerId)

		if specifiedPlayer then
			players = {
				specifiedPlayer
			}
		end
	end

	return players or {}
end

return GraphContext
