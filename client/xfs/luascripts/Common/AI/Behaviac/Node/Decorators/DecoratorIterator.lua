-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Node\\Decorators\\DecoratorIterator.lua

local enums = require("Common.AI.Behaviac.Enums")
local common = require("Common.AI.Behaviac.Common")
local macros = require("Common.AI.Behaviac.Macros")
local functions = require("Common.AI.Behaviac.Functions")
local EBTStatus = enums.EBTStatus
local ENodePhase = enums.ENodePhase
local EPreDecoratorPhase = enums.EPreDecoratorPhase
local TriggerMode = enums.TriggerMode
local EOperatorType = enums.EOperatorType
local constSupportedVersion = enums.constSupportedVersion
local constInvalidChildIndex = enums.constInvalidChildIndex
local constBaseKeyStrDef = enums.constBaseKeyStrDef
local constPropertyValueType = enums.constPropertyValueType
local Logging = common.d_log
local StringUtils = common.StringUtils
local Decorator = require("Common.AI.Behaviac.Core.Decorator")
local DecoratorIterator = functions.class("DecoratorIterator", Decorator)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("DecoratorIterator", DecoratorIterator)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("DecoratorIterator", "Decorator")

local _M = DecoratorIterator
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)

	self.m_opl = false
	self.m_opr = false
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

		if nameStr == "Opl" then
			local pParenthesis = string.find(checkstr, "%(")

			if not pParenthesis then
				self.m_Iterator = NodeParser.parseProperty(valueStr)
			else
				macros.BEHAVIAC_ASSERT(false)
			end
		elseif nameStr == "Opr" then
			local pParenthesis

			if type(checkstr) == "string" then
				pParenthesis = string.find(checkstr, "%(")
			end

			if not pParenthesis then
				self.m_Iterator = NodeParser.parseProperty(valueStr)
			else
				self.m_Iterator = NodeParser.parseMethod(valueStr)
			end
		end
	end
end

function _M:isDecoratorIterator()
	return true
end

return _M
