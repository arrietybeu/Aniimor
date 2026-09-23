-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Core\\Decorator.lua

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
local SingleChild = require("Common.AI.Behaviac.Core.SingleChild")
local Decorator = functions.class("Decorator", SingleChild)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("Decorator", Decorator)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("Decorator", "SingleChild")

local _M = Decorator
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)

	self.m_bDecorateWhenChildEnds = false
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

		if nameStr == "DecorateWhenChildEnds" and valueStr == "true" then
			self.m_bDecorateWhenChildEnds = true
		end
	end
end

function _M:isManagingChildrenAsSubTrees()
	return true
end

function _M:isDecorator()
	return true
end

function _M:init(node)
	_M.super.init(self, node)
end

function _M:onEnter(agent, tick)
	return true
end

function _M:onExit(agent, tick, status)
	if self:isManagingChildrenAsSubTrees() then
		tick:abort(self, agent)
	end

	return true
end

function _M:update(agent, tick, childStatus)
	macros.BEHAVIAC_ASSERT(self:isDecorator(), "[_M:update()] isDecorator")

	local status = EBTStatus.BT_INVALID

	if childStatus ~= EBTStatus.BT_RUNNING then
		status = childStatus

		if not self.m_bDecorateWhenChildEnds or status ~= EBTStatus.BT_RUNNING then
			local result = self:decorate(status, tick)

			if result ~= EBTStatus.BT_RUNNING then
				return result
			end

			return EBTStatus.BT_RUNNING
		end
	end

	status = _M.super.update(self, agent, tick, childStatus)

	if not self.m_bDecorateWhenChildEnds or status ~= EBTStatus.BT_RUNNING then
		local result = self:decorate(status, tick)

		if result ~= EBTStatus.BT_RUNNING then
			return result
		end
	end

	return EBTStatus.BT_RUNNING
end

function _M:decorate(status, tick)
	Logging.error("derived class must be rewrite _M:decorate")

	return EBTStatus.BT_RUNNING
end

return _M
