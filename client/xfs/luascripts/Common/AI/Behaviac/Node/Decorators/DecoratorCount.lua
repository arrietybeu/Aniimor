-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Node\\Decorators\\DecoratorCount.lua

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
local DecoratorCount = functions.class("DecoratorCount", Decorator)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("DecoratorCount", DecoratorCount)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("DecoratorCount", "Decorator")

local _M = DecoratorCount
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)

	self.m_count_p = false
end

function _M:release()
	_M.super.release(self)

	self.m_count_p = false
end

function _M:onLoading(version, agentType, properties)
	_M.super.onLoading(self, version, agentType, properties)

	local nameStr, valueStr

	for _, p in ipairs(properties) do
		nameStr = p[1]
		valueStr = p[2]

		if nameStr == "Count" then
			self.m_count_p = NodeParser.parseProperty(valueStr)
		end
	end
end

function _M:getCountP(agent, tick)
	return self.m_count_p and self.m_count_p:getValue(agent, tick) or 0
end

function _M:isDecoratorCount()
	return true
end

function _M:init(tick)
	_M.super.init(self, tick)
	self:setNum(tick, 0)
end

function _M:onReset(agent, tick)
	self:setNum(tick, 0)

	return true
end

function _M:onEnter(agent, tick)
	_M.super.onEnter(self, agent, tick)

	local countP = self:getCountP(agent, tick)

	if countP == 0 then
		return false
	end

	self:setNum(tick, countP)

	return true
end

function _M:setNum(tick, n)
	tick:setNodeMem("num", n, self)
end

function _M:getNum(tick)
	return tick:getNodeMem("num", self)
end

return _M
