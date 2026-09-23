-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Node\\Composites\\SequenceStochastic.lua

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
local CompositeStochastic = require("Common.AI.Behaviac.Node.Composites.CompositeStochastic")
local SequenceStochastic = functions.class("SequenceStochastic", CompositeStochastic)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("SequenceStochastic", SequenceStochastic)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("SequenceStochastic", "CompositeStochastic")

local _M = SequenceStochastic
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)
end

function _M:release()
	_M.super.release(self)
end

function _M:checkIfInterrupted(agent, tick)
	return self:evaluteCustomCondition(agent, tick)
end

function _M:isSequenceStochastic()
	return true
end

function _M:update(agent, tick, childStatus)
	local activeChildIndex = self:getActiveChildIndex(tick)

	macros.BEHAVIAC_ASSERT(activeChildIndex <= #self.m_children, "[_M:update()] activeChildIndex <= #self.m_children")

	local bFirst = true
	local s = childStatus

	while true do
		if not bFirst or s == EBTStatus.BT_RUNNING then
			local indexSet = self:getIndexSet(tick)
			local childIndex = indexSet[activeChildIndex]
			local pChild = self.m_children[childIndex]

			if self:checkIfInterrupted(agent, tick) then
				return EBTStatus.BT_FAILURE
			end

			s = tick:exec(pChild, agent)
		end

		bFirst = false

		if s ~= EBTStatus.BT_SUCCESS then
			return s
		end

		activeChildIndex = activeChildIndex + 1

		self:setActiveChildIndex(tick, activeChildIndex)

		if activeChildIndex > #self.m_children then
			return EBTStatus.BT_SUCCESS
		end
	end
end

return _M
