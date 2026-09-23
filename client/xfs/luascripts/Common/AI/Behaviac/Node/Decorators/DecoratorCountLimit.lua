-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Node\\Decorators\\DecoratorCountLimit.lua

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
local DecoratorCount = require("Common.AI.Behaviac.Node.Decorators.DecoratorCount")
local DecoratorCountLimit = functions.class("DecoratorCountLimit", DecoratorCount)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("DecoratorCountLimit", DecoratorCountLimit)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("DecoratorCountLimit", "DecoratorCount")

local _M = DecoratorCountLimit
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)
end

function _M:release()
	_M.super.release(self)
end

function _M:checkIfReInit(agent)
	return self:evaluteCustomCondition(agent)
end

function _M:isDecoratorCountLimit()
	return true
end

function _M:init(tick)
	_M.super.init(self, tick)
	self:setInitialized(tick, false)
end

function _M:onEnter(agent, tick)
	_M.super.onEnter(self, agent, tick)

	if self:checkIfReInit(agent) then
		self:setInitialized(tick, false)
	end

	local bInitialized = self:getInitialized(tick)

	if not bInitialized then
		self:setInitialized(tick, true)

		local countP = self:getCountP(agent, tick)

		self:setNum(tick, countP)
	end

	local num = self:getNum(tick)

	if num > 0 then
		num = num - 1

		self:setNum(tick, num)

		return true
	elseif num == 0 then
		return false
	elseif num == -1 then
		return true
	end

	macros.BEHAVIAC_ASSERT(false, "[_M:onEnter()] false")

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

return _M
