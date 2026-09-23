-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Node\\Decorators\\DecoratorCountOnce.lua

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
local DecoratorCountOnce = functions.class("DecoratorCountOnce", DecoratorCount)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("DecoratorCountOnce", DecoratorCountOnce)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("DecoratorCountOnce", "DecoratorCount")

local _M = DecoratorCountOnce
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

function _M:isDecoratorCountOnce()
	return true
end

function _M:init(tick)
	_M.super.init(self, tick)
	self:setInitialized(tick, false)
	self:setRunOnce(tick, false)
end

function _M:onEnter(agent, tick)
	_M.super.onEnter(self, agent, tick)

	local bRunOnce = self:getRunOnce(tick)

	if bRunOnce then
		return false
	end

	if self.m_status == EBTStatus.BT_RUNNING then
		return true
	end

	if self.checkIfReInit(agent) then
		self:setInitialized(tick, false)
	end

	local bInitialized = self:getInitialized(tick)
	local num = self:getNum(tick)

	if not bInitialized then
		self:setInitialized(tick, true)

		local countP = self:getCountP(agent, tick)

		self:setNum(countP)

		num = self:getNum(tick)

		macros.BEHAVIAC_ASSERT(num > 0, "[_M:onEnter()] false num > 0")
	end

	if num > 0 then
		num = num - 1

		self:setNum(tick, num)

		return true
	elseif num == 0 then
		self:setRunOnce(tick, true)

		return false
	elseif num == -1 then
		self:setRunOnce(tick, true)

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

function _M:setRunOnce(tick, b)
	tick:setNodeMem("runOnce", b, self)
end

function _M:getRunOnce(tick)
	return tick:getNodeMem("runOnce", self)
end

return _M
