-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Fsm\\FSM.lua

local enums = require("Common.AI.Behaviac.Enums")
local common = require("Common.AI.Behaviac.Common")
local macros = require("Common.AI.Behaviac.Macros")
local functions = require("Common.AI.Behaviac.Functions")
local TablePool = require("Common.Container.TablePool")
local EBTStatus = enums.EBTStatus
local ENodePhase = enums.ENodePhase
local EPreconditionPhase = enums.EPreconditionPhase
local TriggerMode = enums.TriggerMode
local EOperatorType = enums.EOperatorType
local constSupportedVersion = enums.constSupportedVersion
local constInvalidChildIndex = enums.constInvalidChildIndex
local constBaseKeyStrDef = enums.constBaseKeyStrDef
local constPropertyValueType = enums.constPropertyValueType
local Logging = common.d_log
local StringUtils = common.StringUtils
local Composite = require("Common.AI.Behaviac.Core.Composite")
local FSM = functions.class("FSM", Composite)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("FSM", FSM)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("FSM", "Composite")

local _M = FSM
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)

	self.m_initialId = -1
end

function _M:release()
	_M.super.release(self)

	self.m_initialId = -1
end

function _M:onLoading(version, agentType, properties)
	_M.super.onLoading(self, version, agentType, properties)

	local nameStr, valueStr

	for _, p in ipairs(properties) do
		nameStr = p[1]
		valueStr = p[2]

		if nameStr == "initialid" then
			self.m_initialId = tonumber(valueStr)
		end
	end
end

function _M:setInitialId(initialid)
	self.m_initialId = initialid
end

function _M:getInitialId()
	return self.m_initialId
end

function _M:init(tick)
	_M.super.init(self, tick)
end

function _M:onEvent(agent, tick, eventName, eventParams)
	local bGoOn = true

	if self:hasEvents() then
		local currentId = self:getCurrentNodeId(tick)
		local currentState = self:getChildById(currentId)

		if currentState ~= false and currentState:isReferencedBehavior() then
			local tCurrentTick = currentState:getSubTreeTick(tick)
			local curVisitingNode = tCurrentTick:getBt()

			if curVisitingNode then
				bGoOn = curVisitingNode:onEvent(agent, tCurrentTick, eventName, eventParams)
			end

			bGoOn = bGoOn and _M.super.onEvent(self, agent, tick, eventName, eventParams)
		end
	end

	return bGoOn
end

function _M:onReset(agent, tick)
	local currentId = self:getCurrentNodeId(tick)
	local currentState = self:getChildById(currentId)

	if currentState and currentState:isReferencedBehavior() and currentState:getStatus(tick) == EBTStatus.BT_RUNNING then
		tick:abort(currentState, agent)
	end

	self:setCurrentNodeId(tick, -1)

	return _M.super.onReset(self, agent, tick)
end

function _M:onEnter(agent, tick)
	self:setActiveChildIndex(tick, 0)
	self:setCurrentNodeId(tick, self:getInitialId())

	return _M.super.onEnter(self, agent, tick)
end

function _M:onExit(agent, tick, status)
	local currentId = self:getCurrentNodeId(tick)
	local currentState = self:getChildById(currentId)

	if currentState and currentState:isReferencedBehavior() and currentState:getStatus(tick) == EBTStatus.BT_RUNNING then
		tick:abort(currentState, agent)
	end

	self:setCurrentNodeId(tick, -1)

	return _M.super.onExit(self, agent, tick, status)
end

local FSM_stateTable = {}

function _M:updateFSM(agent, tick, childStatus)
	local status = childStatus
	local bLoop = true
	local kMaxCount = 10

	table.clear(FSM_stateTable)

	local tmpStateUpdateCount = FSM_stateTable

	while bLoop do
		local currentId = self:getCurrentNodeId(tick)
		local currentState = self:getChildById(currentId)

		status = tick:execWithChildStatus(currentState, agent, childStatus)

		if currentState ~= nil and currentState:isEndState() == true then
			status = EBTStatus.BT_SUCCESS

			break
		end

		local nextStateId = currentState:getNextStateId(tick)

		if nextStateId < 0 then
			bLoop = false
		else
			if tmpStateUpdateCount[self:getCurrentNodeId(tick)] == nil then
				tmpStateUpdateCount[self:getCurrentNodeId(tick)] = 0
			end

			tmpStateUpdateCount[self:getCurrentNodeId(tick)] = tmpStateUpdateCount[self:getCurrentNodeId(tick)] + 1

			if currentState:isReferencedBehavior() then
				tick:abort(currentState, agent)
			end

			if kMaxCount < tmpStateUpdateCount[self:getCurrentNodeId(tick)] then
				agent.ent.logger:warn("@cyj dead loop!!")

				break
			end

			self:setCurrentNodeId(tick, nextStateId)
		end
	end

	return status
end

function _M:getCurrentState(tick)
	local currentId = self:getCurrentNodeId(tick)
	local currentState = self:getChildById(currentId)

	return currentState
end

function _M:updateCurrent(agent, tick, childStatus)
	return self:update(agent, tick, childStatus)
end

function _M:update(agent, tick, childStatus)
	return self:updateFSM(agent, tick, childStatus)
end

function _M:setActiveChildIndex(tick, activeChildIndex)
	tick:setNodeMem("activeChildIndex", activeChildIndex, self)
end

function _M:getActiveChildIndex(tick)
	return tick:getNodeMem("activeChildIndex", self)
end

function _M:setCurrentNodeId(tick, currentNodeId)
	tick:setNodeMem("currentNodeId", currentNodeId, self)
end

function _M:getCurrentNodeId(tick)
	return tick:getNodeMem("currentNodeId", self)
end

function _M:traverse(childFirst, handler, agent, tick, userData)
	if childFirst then
		local currentState = self:getCurrentState(tick)

		if currentState then
			currentState:traverse(childFirst, handler, agent, tick, userData)
		end

		handler(self, agent, tick, userData)
	elseif handler(self, agent, tick, userData) then
		local currentState = self:getCurrentState(tick)

		if currentState then
			currentState:traverse(childFirst, handler, agent, tick, userData)
		end
	end
end

return _M
