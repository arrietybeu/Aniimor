-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Node\\Composites\\IfElse.lua

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
local Cls_IfElse = functions.class("IfElse", Composite)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("IfElse", Cls_IfElse)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("IfElse", "Composite")

local _M = Cls_IfElse
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)
end

function _M:release()
	_M.super.release(self)
end

function _M:isIfElse()
	return true
end

function _M:onEnter(agent, tick)
	self:setActiveChildIndex(tick, constInvalidChildIndex)

	if #self.m_children == 3 then
		return true
	end

	macros.BEHAVIAC_ASSERT(false, "IfElse has to have three children: condition, if, else")

	return false
end

function _M:onExit(agent, tick, status)
	return true
end

function _M:update(agent, tick, childStatus)
	macros.BEHAVIAC_ASSERT(childStatus ~= EBTStatus.BT_INVALID, "[_M:update()] childStatus ~= EBTStatus.BT_INVALID")
	macros.BEHAVIAC_ASSERT(#self.m_children == 3, "[_M:update()] #self.m_children == 3")

	local conditionResult = EBTStatus.BT_INVALID

	if childStatus == EBTStatus.BT_SUCCESS or childStatus == EBTStatus.BT_FAILURE then
		conditionResult = childStatus
	end

	local activeChildIndex = self:getActiveChildIndex(tick)

	if activeChildIndex == constInvalidChildIndex then
		local pCondition = self.m_children[1]

		if conditionResult == EBTStatus.BT_INVALID then
			conditionResult = tick:exec(pCondition, agent)
		end

		if conditionResult == EBTStatus.BT_SUCCESS then
			activeChildIndex = 2

			self:setActiveChildIndex(tick, activeChildIndex)
		elseif conditionResult == EBTStatus.BT_FAILURE then
			activeChildIndex = 3

			self:setActiveChildIndex(tick, activeChildIndex)
		end
	else
		return childStatus
	end

	if activeChildIndex ~= constInvalidChildIndex then
		local pChild = self.m_children[activeChildIndex]
		local s = tick:exec(pChild, agent)

		return s
	end

	return EBTStatus.BT_RUNNING
end

return _M
