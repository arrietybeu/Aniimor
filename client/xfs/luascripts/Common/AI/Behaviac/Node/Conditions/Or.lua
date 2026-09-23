-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Node\\Conditions\\Or.lua

local enums = require("Common.AI.Behaviac.Enums")
local common = require("Common.AI.Behaviac.Common")
local macros = require("Common.AI.Behaviac.Macros")
local functions = require("Common.AI.Behaviac.Functions")
local EBTStatus = enums.EBTStatus
local ENodePhase = enums.ENodePhase
local EPreconditionPhase = enums.EPreconditionPhase
local TriggerMode = enums.TriggerMode
local EOperatorType = enums.EOperatorType
local constSupportedVersion = enums.constSupportedVersion
local constInvalidChildIndex = enums.constInvalidChildIndex
local constBaseKeyStrDef = enums.constBaseKeyStrDef
local constPropertyValueType = enums.constPropertyValueType
local Logging = common.d_log
local StringUtils = common.StringUtils
local Condition = require("Common.AI.Behaviac.Core.Condition")
local Cls_Or = functions.class("Or", Condition)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("Or", Cls_Or)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("Or", "Condition")

local _M = Cls_Or
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)
end

function _M:release()
	_M.super.release(self)
end

function _M:evaluate(agent, tick)
	local ret = true

	for _, child in ipairs(self.m_children) do
		ret = child:evaluate(agent, tick)

		if ret then
			break
		end
	end

	return ret
end

function _M:isOr()
	return true
end

function _M:update(agent, tick, childStatus)
	for _, pChild in ipairs(self.m_children) do
		local status = tick:exec(pChild, agent)

		if status == EBTStatus.BT_SUCCESS then
			return status
		end

		macros.BEHAVIAC_ASSERT(status == EBTStatus.BT_FAILURE, "[_M:update()] status == EBTStatus.BT_FAILURE")
	end

	return EBTStatus.BT_FAILURE
end

return _M
