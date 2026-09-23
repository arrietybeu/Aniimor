-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Attachments\\AttachActionConfig.lua

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
local AttachActionConfig = functions.class("AttachActionConfig")

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("AttachActionConfig", AttachActionConfig)

local _M = AttachActionConfig
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	self.m_opl = false
	self.m_opr1 = false
	self.m_operator = EOperatorType.E_INVALID
	self.m_opr2 = false
	self.__name = "AttachActionConfig"
end

function _M:parse(properties)
	local nameStr, valueStr

	for _, p in ipairs(properties) do
		nameStr = p[1]
		valueStr = p[2]

		local checkIsFunc = valueStr.func

		if nameStr == "Opl" then
			if not checkIsFunc then
				self.m_opl = NodeParser.parseProperty(valueStr)
			else
				self.m_opl = NodeParser.parseMethod(valueStr)
			end
		elseif nameStr == "Opr1" then
			if not checkIsFunc then
				self.m_opr1 = NodeParser.parseProperty(valueStr)
			else
				self.m_opr1 = NodeParser.parseMethod(valueStr)
			end
		elseif nameStr == "Operator" then
			self.m_operator = NodeParser.parseOperatorType(valueStr)
		elseif nameStr == "Opr2" then
			if not checkIsFunc then
				self.m_opr2 = NodeParser.parseProperty(valueStr)
			else
				self.m_opr2 = NodeParser.parseMethod(valueStr)
			end
		end
	end

	return self.m_opl ~= nil
end

function _M:execute(agent, tick)
	local bValid = false

	if self.m_opl and self.m_operator == EOperatorType.E_INVALID then
		bValid = true

		self.m_opl:run(agent, tick)
	elseif self.m_operator == EOperatorType.E_ASSIGN then
		if self.m_opl then
			self.m_opl:setValueCast(agent, tick, self.m_opr2, false)

			bValid = true
		end
	elseif self.m_operator >= EOperatorType.E_ADD and self.m_operator <= EOperatorType.E_DIV then
		if self.m_opl then
			self.m_opl:compute(agent, tick, self.m_opr1, self.m_opr2, self.m_operator)

			bValid = true
		end
	elseif self.m_operator >= EOperatorType.E_EQUAL and self.m_operator <= EOperatorType.E_LESSEQUAL and self.m_opl then
		bValid = self.m_opl:compare(agent, tick, self.m_opr2, self.m_operator)
	end

	return bValid
end

return _M
