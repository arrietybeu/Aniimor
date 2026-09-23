-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Node\\Decorators\\DecoratorRepeat.lua

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
local DecoratorRepeat = functions.class("DecoratorRepeat", DecoratorCount)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("DecoratorRepeat", DecoratorRepeat)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("DecoratorRepeat", "DecoratorCount")

local _M = DecoratorRepeat
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)
end

function _M:release()
	_M.super.release(self)
end

function _M:isDecoratorRepeat()
	return true
end

function _M:update(agent, tick, childStatus)
	macros.BEHAVIAC_ASSERT(self:isDecoratorRepeat(), "[_M:update()] self:isDecoratorRepeat")
	macros.BEHAVIAC_ASSERT(self.m_root, "[_M:update()] self.m_root")

	local num = self:getNum(tick)

	macros.BEHAVIAC_ASSERT(num >= 0, "[_M:update()] num >= 0")

	local status = EBTStatus.BT_INVALID

	for i = 1, num do
		status = tick:exec(self.m_root, agent, childStatus)

		if self.m_bDecorateWhenChildEnds then
			while status == EBTStatus.BT_RUNNING do
				status = _M.super.update(self, agent, tick, childStatus)
			end
		end

		if status == EBTStatus.BT_FAILURE then
			return EBTStatus.BT_FAILURE
		end
	end

	return EBTStatus.BT_SUCCESS
end

function _M:decorate(status, tick)
	macros.BEHAVIAC_ASSERT(false, "[_M:decorate()]")

	return EBTStatus.BT_INVALID
end

return _M
