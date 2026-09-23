-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Node\\Decorators\\DecoratorAlwaysSuccess.lua

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
local DecoratorAlwaysSuccess = functions.class("DecoratorAlwaysSuccess", Decorator)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("DecoratorAlwaysSuccess", DecoratorAlwaysSuccess)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("DecoratorAlwaysSuccess", "Decorator")

local _M = DecoratorAlwaysSuccess
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)
end

function _M:release()
	_M.super.release(self)
end

function _M:isDecoratorAlwaysSuccess()
	return true
end

function _M:decorate(status, tick)
	return EBTStatus.BT_SUCCESS
end

return _M
