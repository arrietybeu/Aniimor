-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Node\\Decorators\\DecoratorTime.lua

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
local DecoratorTime = functions.class("DecoratorTime", Decorator)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("DecoratorTime", DecoratorTime)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("DecoratorTime", "Decorator")

local _M = DecoratorTime
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)

	self.m_time_p = false
end

function _M:release()
	_M.super.release(self)

	self.m_time_p = false
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

		if nameStr == "Time" then
			local pParenthesis

			if type(checkstr) == "string" then
				pParenthesis = string.find(checkstr, "%(")
			end

			if not pParenthesis then
				self.m_time_p = NodeParser.parseProperty(valueStr)
			else
				self.m_time_p = NodeParser.parseMethod(valueStr)
			end
		end
	end
end

function _M:getTimeP(agent, tick)
	return self.m_time_p and self.m_time_p:getValue(agent, tick) or 0
end

function _M:isDecoratorTime()
	return true
end

function _M:init(tick)
	_M.super.init(self, tick)
	self:setStart(tick, 0)
	self:setTime(tick, 0)
end

function _M:onEnter(agent, tick)
	self:setStart(tick, common.getClock())
	self:setTime(tick, self:getTimeP(agent, tick) or 0)

	if self:getTime(tick) > 0 then
		return _M.super.onEnter(self, agent, tick)
	end

	return false
end

function _M:decorate(status, tick)
	local time = common.getClock()
	local startTime = self:getStart(tick)

	if time < startTime then
		startTime = time

		self:setStart(tick, startTime)
	end

	if time - startTime >= self:getTime(tick) then
		return EBTStatus.BT_SUCCESS
	end

	return EBTStatus.BT_RUNNING
end

function _M:setStart(tick, n)
	tick:setNodeMem("start", n, self)
end

function _M:getStart(tick)
	return tick:getNodeMem("start", self)
end

function _M:setTime(tick, tm)
	tick:setNodeMem("time", tm, self)
end

function _M:getTime(tick)
	return tick:getNodeMem("time", self)
end

return _M
