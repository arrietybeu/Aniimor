-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Node\\Actions\\Assignment.lua

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
local Assignment = functions.class("Assignment", Leaf)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("Assignment", Assignment)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("Assignment", "Leaf")

local _M = Assignment
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)

	self.m_opl = false
	self.m_opr = false
	self.m_bCast = false
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

		if nameStr == "CastRight" then
			self.m_bCast = valueStr == "true"
		elseif nameStr == "Opl" then
			self.m_opl = NodeParser.parseProperty(valueStr)
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

function _M:isAssignment()
	return true
end

function _M:onEnter(agent, tick)
	return true
end

function _M:onExit(agent, tick, status)
	return true
end

function _M:update(agent, tick, childStatus)
	macros.BEHAVIAC_ASSERT(childStatus == EBTStatus.BT_RUNNING, "[_M:update()] childStatus == EBTStatus.BT_RUNNING")
	macros.BEHAVIAC_ASSERT(self:isAssignment(), "[_M:update()] self:isAssignment()")

	local status = EBTStatus.BT_SUCCESS

	if self.m_opl then
		self.m_opl:setValueCast(agent, tick, self.m_opr, self.m_bCast)
	else
		status = self:evaluateImpl(agent, tick, childStatus)
	end

	return status
end

return _M
