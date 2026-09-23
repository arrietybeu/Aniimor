-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Node\\Decorators\\DecoratorSuccessUntil.lua

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
local DecoratorSuccessUntil = functions.class("DecoratorSuccessUntil", DecoratorCount)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("DecoratorSuccessUntil", DecoratorSuccessUntil)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("DecoratorSuccessUntil", "DecoratorCount")

local _M = DecoratorSuccessUntil
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)
end

function _M:release()
	_M.super.release(self)
end

function _M:isDecoratorSuccessUntil()
	return true
end

function _M:onEnter(agent, tick)
	local num = self:getNum(tick)

	if num == 0 then
		local countP = self:getCountP(agent, tick)

		if countP == 0 then
			return false
		end

		self:setNum(tick, countP)
	end

	return _M.super.onEnter(self, agent, tick)
end

function _M:decorate(status, tick)
	local num = self:getNum(tick)

	if num > 0 then
		num = num - 1

		self:setNum(tick, num)

		if num == 0 then
			return EBTStatus.BT_FAILURE
		end

		return EBTStatus.BT_SUCCESS
	end

	if num == -1 then
		return EBTStatus.BT_SUCCESS
	end

	macros.BEHAVIAC_ASSERT(num == 0, "[_M:decorate()] n == 0")

	return EBTStatus.BT_FAILURE
end

return _M
