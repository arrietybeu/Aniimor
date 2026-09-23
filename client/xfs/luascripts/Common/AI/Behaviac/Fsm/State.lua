-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Fsm\\State.lua

local enums = require("Common.AI.Behaviac.Enums")
local common = require("Common.AI.Behaviac.Common")
local macros = require("Common.AI.Behaviac.Macros")
local functions = require("Common.AI.Behaviac.Functions")
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
local Leaf = require("Common.AI.Behaviac.Core.Leaf")
local State = functions.class("State", Leaf)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("State", State)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("State", "Leaf")

local _M = State
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)

	self.m_bIsEndState = false
	self.m_method = false
	self.m_transitions = {}
end

function _M:release()
	_M.super.release(self)

	self.m_method = false
end

function _M:onLoading(version, agentType, properties)
	_M.super.onLoading(self, version, agentType, properties)

	local nameStr, valueStr

	for _, p in ipairs(properties) do
		nameStr = p[1]
		valueStr = p[2]

		if nameStr == "Method" then
			self.m_method = NodeParser.parseMethod(valueStr)
		elseif nameStr == "IsEndState" then
			self.m_bIsEndState = valueStr == "true"
		end
	end
end

function _M:attach(pAttachment, bIsPrecondition, bIsEffector, bIsTransition)
	if bIsTransition then
		macros.BEHAVIAC_ASSERT(not bIsEffector and not bIsPrecondition, "Transition flag conficts with effector and precondition flag")

		local pTransition = pAttachment

		macros.BEHAVIAC_ASSERT(pTransition, "Transition node cann't be nil")

		return table.insert(self.m_transitions, pTransition)
	else
		return _M.super.attach(self, pAttachment, bIsPrecondition, bIsEffector, bIsTransition)
	end
end

function _M:stateUpdate(agent, tick)
	local status = self:getStatus(tick)

	if self.m_bIsEndState then
		status = self:execute(agent, tick)

		self:setNextStateId(tick, -1)

		status = EBTStatus.BT_SUCCESS
	else
		local bTransitioned, nextStateId = State.s_updateGlobalTransitions(self, agent, tick, self.m_transitions, status)

		if not bTransitioned then
			status = self:execute(agent, tick)
			bTransitioned, nextStateId = self:s_updateAlwaysTransitions(agent, tick, self.m_transitions, status)
		end

		self:setNextStateId(tick, nextStateId)

		if bTransitioned then
			status = EBTStatus.BT_SUCCESS
		end
	end

	return status
end

function _M:s_updateAlwaysTransitions(agent, tick, transitions, status)
	local bTransitioned = false
	local nextStateId = -1

	if transitions and #transitions > 0 then
		for _, transition in ipairs(transitions) do
			if not transition:isGlobalTransition() and transition:evaluateWithStatus(agent, tick, status) then
				nextStateId = transition:getTargetStateId()

				macros.BEHAVIAC_ASSERT(nextStateId ~= -1, "Invalid nextStateId")
				transition:applyEffects(agent, tick, ENodePhase.E_BOTH)

				bTransitioned = true

				break
			end
		end
	end

	return bTransitioned, nextStateId
end

function _M:s_updateGlobalTransitions(agent, tick, transitions, status)
	local bTransitioned = false
	local nextStateId = -1

	if transitions and #transitions > 0 then
		for _, transition in ipairs(transitions) do
			if transition:isGlobalTransition() and transition:evaluateWithStatus(agent, tick, status) then
				nextStateId = transition:getTargetStateId()

				macros.BEHAVIAC_ASSERT(nextStateId ~= -1, "Invalid nextStateId")
				transition:applyEffects(agent, tick, ENodePhase.E_BOTH)

				bTransitioned = true

				break
			end
		end
	end

	return bTransitioned, nextStateId
end

function _M:isEndState()
	return self.m_bIsEndState
end

function _M:evaluateImpl(agent, tick, childStatus)
	return EBTStatus.BT_RUNNING
end

function _M:execute(agent, tick)
	local status = EBTStatus.BT_RUNNING

	if self.m_method then
		self.m_method:run(agent, tick)
	else
		status = self:evaluateImpl(agent, tick, EBTStatus.BT_RUNNING)
	end

	return status
end

function _M:isState()
	return true
end

function _M:init(tick)
	_M.super.init(self, tick)
	self:setNextStateId(tick, -1)
end

function _M:onEnter(agent, tick)
	self:setNextStateId(tick, -1)

	return true
end

function _M:onExit(agent, tick, status)
	return _M.super.onExit(self, agent, tick, status)
end

function _M:update(agent, tick, childStatus)
	macros.BEHAVIAC_ASSERT(childStatus == EBTStatus.BT_RUNNING)
	macros.BEHAVIAC_ASSERT(self:isState(), "[_M:update()] node is not a state")

	return self:stateUpdate(agent, tick)
end

function _M:setNextStateId(tick, id)
	tick:setNodeMem("nextStateId", id, self)
end

function _M:getNextStateId(tick)
	return tick:getNodeMem("nextStateId", self)
end

return _M
