-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Core\\Condition.lua

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
local Condition = functions.class("Condition", Leaf)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("Condition", Condition)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("Condition", "Leaf")

local _M = Condition
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)

	self.m_opl = false
	self.m_opr = false
	self.m_operator = EOperatorType.E_EQUAL
end

function _M:release()
	_M.super.release(self)

	self.m_opl = false
	self.m_opr = false
end

function _M:onLoading(version, agentType, properties)
	_M.super.onLoading(self, version, agentType, properties)

	local nameStr, valueStr, checkstr

	for _, p in ipairs(properties) do
		nameStr = p[1]
		valueStr = p[2]

		local valuetype = {}

		checkstr = valueStr

		if valueStr.func ~= nil then
			checkstr = valueStr.func
		else
			valuetype = valueStr.type
			checkstr = valueStr.value
		end

		if nameStr == "Operator" then
			self.m_operator = NodeParser.parseOperatorType(valueStr)
		elseif nameStr == "Opl" then
			local pParenthesis

			if type(checkstr) == "string" then
				pParenthesis = string.find(checkstr, "%(")
			end

			if not pParenthesis then
				self.m_opl = NodeParser.parseProperty(valueStr)
			else
				self.m_opl = NodeParser.parseMethod(valueStr)
			end
		elseif nameStr == "Opr" then
			local pParenthesis

			if type(checkstr) == "string" then
				pParenthesis = string.find(checkstr, "%(")
			end

			if not pParenthesis then
				self.m_opr = NodeParser.parseProperty(valueStr)
			else
				self.m_opr = NodeParser.parseMethod(valueStr)
			end
		end
	end
end

function _M:isCondition()
	return true
end

function _M:onEnter(agent, tick)
	return true
end

function _M:onExit(agent, tick, status)
	return true
end

function _M:update(agent, tick, childStatus)
	macros.BEHAVIAC_ASSERT(self:isCondition(), "[_M:update()] self:isCondition")

	if self:evaluate(agent, tick) then
		return EBTStatus.BT_SUCCESS
	else
		return EBTStatus.BT_FAILURE
	end
end

function _M:evaluate(agent, tick)
	if self.m_opl and self.m_opr then
		return self.m_opl:compare(agent, tick, self.m_opr, self.m_operator)
	else
		local result = self:evaluateImpl(agent, tick, EBTStatus.BT_INVALID)

		return result == EBTStatus.BT_SUCCESS
	end
end

return _M
