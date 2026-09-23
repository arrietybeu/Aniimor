-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Node\\Composites\\Selector.lua

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
local Selector = functions.class("Selector", Composite)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("Selector", Selector)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("Selector", "Composite")

local _M = Selector
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)
end

function _M:release()
	_M.super.release(self)
end

function _M:selectorUpdate(agent, tick, childStatus, activeChildIndex, children)
	local s = childStatus
	local childSize = #children

	macros.BEHAVIAC_ASSERT(activeChildIndex >= 1 and activeChildIndex <= childSize)

	while true do
		macros.BEHAVIAC_ASSERT(activeChildIndex <= childSize, "[_M:SelectorUpdate()] activeChildIndex %d < childSize %d", activeChildIndex, childSize)

		if s == EBTStatus.BT_RUNNING then
			local pChild = children[activeChildIndex]

			if self:checkIfInterrupted(agent, tick) then
				return EBTStatus.BT_FAILURE, activeChildIndex
			end

			s = tick:exec(pChild, agent)
		end

		if s ~= EBTStatus.BT_FAILURE then
			return s, activeChildIndex
		end

		activeChildIndex = activeChildIndex + 1

		if childSize < activeChildIndex then
			return EBTStatus.BT_FAILURE, activeChildIndex
		end

		s = EBTStatus.BT_RUNNING
	end
end

function _M:evaluate(agent, tick)
	local ret = true

	for _, child in ipairs(self.m_children) do
		ret = child:evaluate(agent, tick)

		if ret then
			break
		end
	end

	return ret
end

function _M:checkIfInterrupted(agent, tick)
	return self:evaluteCustomCondition(agent, tick)
end

function _M:isSelector()
	return true
end

function _M:onEnter(agent, tick)
	macros.BEHAVIAC_ASSERT(#self.m_children > 0, "[_M:onEnter()] #self.m_children > 0")
	self:setActiveChildIndex(tick, 1)

	return true
end

function _M:onExit(agent, tick, status)
	return true
end

function _M:update(agent, tick, childStatus)
	local activeChildIndex = self:getActiveChildIndex(tick)

	macros.BEHAVIAC_ASSERT(activeChildIndex <= #self.m_children, "[_M:update()] activeChildIndex <= #self.m_children")

	local outStatus, outActiveChildIndex = self:selectorUpdate(agent, tick, childStatus, activeChildIndex, self.m_children)

	self:setActiveChildIndex(tick, outActiveChildIndex)

	return outStatus
end

return _M
