-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Node\\Decorators\\DecoratorWeight.lua

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
local DecoratorWeight = functions.class("DecoratorWeight", Decorator)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("DecoratorWeight", DecoratorWeight)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("DecoratorWeight", "Decorator")

local _M = DecoratorWeight
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)

	self.m_weight_p = false
end

function _M:release()
	_M.super.release(self)

	self.m_weight_p = false
end

function _M:onLoading(version, agentType, properties)
	_M.super.onLoading(self, version, agentType, properties)

	local nameStr, valueStr

	for _, p in ipairs(properties) do
		nameStr = p[1]
		valueStr = p[2]

		if nameStr == "Weight" then
			self.m_weight_p = NodeParser.parseProperty(valueStr)
		end
	end
end

function _M:getWeightP(agent, tick)
	return self.m_weight_p and self.m_weight_p:getValue(agent, tick) or 0
end

function _M:isManagingChildrenAsSubTrees()
	return false
end

function _M:isDecoratorWeight()
	return true
end

function _M:decorate(status, tick)
	return status
end

return _M
