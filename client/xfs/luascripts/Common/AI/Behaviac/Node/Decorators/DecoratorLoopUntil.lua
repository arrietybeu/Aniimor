-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Node\\Decorators\\DecoratorLoopUntil.lua

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
local DecoratorLoopUntil = functions.class("DecoratorLoopUntil", DecoratorCount)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("DecoratorLoopUntil", DecoratorLoopUntil)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("DecoratorLoopUntil", "DecoratorCount")

local _M = DecoratorLoopUntil
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)

	self.m_until = false
end

function _M:release()
	_M.super.release(self)
end

function _M:onLoading(version, agentType, properties)
	_M.super.onLoading(self, version, agentType, properties)

	local nameStr, valueStr

	for _, p in ipairs(properties) do
		nameStr = p[1]
		valueStr = p[2]

		if nameStr == "Until" then
			self.m_until = valueStr == "true"
		end
	end
end

function _M:isDecoratorLoopUntil()
	return true
end

function _M:decorate(status, tick)
	local num = self:getNum(tick)

	if num > 0 then
		num = num - 1

		self:setNum(tick, num)
	end

	if num == 0 then
		return EBTStatus.BT_SUCCESS
	end

	macros.BEHAVIAC_ASSERT(self:isDecoratorLoopUntil(), "[_M:decorate()] self:isDecoratorLoopUntil")

	if self.m_until then
		if status == EBTStatus.BT_SUCCESS then
			return EBTStatus.BT_SUCCESS
		end
	elseif status == EBTStatus.BT_FAILURE then
		return EBTStatus.BT_FAILURE
	end

	return EBTStatus.BT_RUNNING
end

return _M
