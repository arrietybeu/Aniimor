-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Node\\Composites\\Sequence.lua

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
local Composite = require("Common.AI.Behaviac.Core.Composite")
local Sequence = functions.class("Sequence", Composite)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("Sequence", Sequence)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("Sequence", "Composite")

local _M = Sequence
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)
end

function _M:release()
	_M.super.release(self)
end

function _M:sequenceUpdate(agent, tick, childStatus, activeChildIndex, children)
	local s = childStatus
	local childSize = #children

	while true do
		if s == EBTStatus.BT_RUNNING then
			local pChild = children[activeChildIndex]

			if self:checkIfInterrupted(agent, tick) then
				return EBTStatus.BT_FAILURE, activeChildIndex
			end

			s = tick:exec(pChild, agent)
		end

		if s ~= EBTStatus.BT_SUCCESS then
			return s, activeChildIndex
		end

		activeChildIndex = activeChildIndex + 1

		if childSize < activeChildIndex then
			return EBTStatus.BT_SUCCESS, activeChildIndex
		end

		s = EBTStatus.BT_RUNNING
	end
end

function _M:checkIfInterrupted(agent, tick)
	return self:evaluteCustomCondition(agent, tick)
end

function _M:isSequence()
	return true
end

function _M:onEnter(agent, tick)
	self:setActiveChildIndex(tick, 1)

	return true
end

function _M:update(agent, tick, childStatus)
	local activeChildIndex = self:getActiveChildIndex(tick)
	local outStatus, outActiveChildIndex = self:sequenceUpdate(agent, tick, childStatus, activeChildIndex, self.m_children)

	self:setActiveChildIndex(tick, outActiveChildIndex)

	return outStatus
end

function _M:evaluate(agent, tick)
	local ret = true

	for _, child in ipairs(self.m_children) do
		ret = child:evaluate(agent, tick)

		if not ret then
			break
		end
	end

	return ret
end

return Sequence
