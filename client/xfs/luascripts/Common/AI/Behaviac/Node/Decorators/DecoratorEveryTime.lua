-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Node\\Decorators\\DecoratorEveryTime.lua

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
local DecoratorTime = require("Common.AI.Behaviac.Node.Decorators.DecoratorTime")
local DecoratorEveryTime = functions.class("DecoratorEveryTime", DecoratorTime)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("DecoratorEveryTime", DecoratorEveryTime)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("DecoratorEveryTime", "DecoratorTime")

local _M = DecoratorEveryTime
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)
end

function _M:release()
	_M.super.release(self)
end

function _M:init(tick)
	_M.super.init(self, tick)
	self:setInitialized(tick, false)
	self:setStart(tick, 0)
	self:setTime(tick, 0)
end

function _M:onEnter(agent, tick)
	local bInitialized = self:getInitialized(tick)

	if bInitialized then
		local status = self:getStatus(tick)

		if status == EBTStatus.BT_RUNNING then
			return true
		else
			return self:checkTime(agent, tick)
		end
	end

	if _M.super.onEnter(self, agent, tick) then
		self:setInitialized(tick, true)

		return self:checkTime(agent, tick)
	else
		return false
	end
end

function _M:checkTime(agent, tick)
	local time = common.getClock()
	local startTime = self:getStart(tick)

	if time < startTime then
		startTime = time

		self:setStart(tick, startTime)
	end

	if time - startTime >= self:getTime(tick) then
		self:setStart(tick, time)

		return true
	end

	return false
end

function _M:decorate(status, tick)
	return status
end

function _M:setInitialized(tick, b)
	tick:setNodeMem("initialized", b, self)
end

function _M:getInitialized(tick)
	return tick:getNodeMem("initialized", self)
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
