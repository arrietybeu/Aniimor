-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Node\\Decorators\\DecoratorNot.lua

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
local DecoratorNot = functions.class("DecoratorNot", Decorator)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("DecoratorNot", DecoratorNot)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("DecoratorNot", "Decorator")

local _M = DecoratorNot
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)
end

function _M:release()
	_M.super.release(self)
end

function _M:evaluate(agent, tick)
	macros.BEHAVIAC_ASSERT(#self.m_children == 1, "[_M:evaluate()] #self.m_children == 1")

	return not self.m_children[1]:evaluate(agent, tick)
end

function _M:isDecoratorNot()
	return true
end

function _M:decorate(status, tick)
	if status == EBTStatus.BT_FAILURE then
		return EBTStatus.BT_SUCCESS
	end

	if status == EBTStatus.BT_SUCCESS then
		return EBTStatus.BT_FAILURE
	end

	return status
end

return _M
