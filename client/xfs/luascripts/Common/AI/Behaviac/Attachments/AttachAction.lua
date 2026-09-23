-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Attachments\\AttachAction.lua

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
local BaseNode = require("Common.AI.Behaviac.Core.BaseNode")
local AttachAction = functions.class("AttachAction", BaseNode)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("AttachAction", AttachAction)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("AttachAction", "BaseNode")

local _M = AttachAction
local AttachActionConfig = require("Common.AI.Behaviac.Attachments.AttachActionConfig")
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)

	self.m_ActionConfig = AttachActionConfig.new()
end

function _M:release()
	_M.super.release(self)

	self.m_ActionConfig = AttachActionConfig.new()
end

function _M:onLoading(version, agentType, properties)
	_M.super.onLoading(self, version, agentType, properties)
	self.m_ActionConfig:parse(properties)
end

function _M:evaluate(agent, tick)
	local bValid = self.m_ActionConfig:execute(agent, tick)

	if not bValid then
		local childStatus = EBTStatus.BT_INVALID

		bValid = EBTStatus.BT_SUCCESS == self:evaluateImpl(agent, tick, childStatus)
	end

	return bValid
end

function _M:evaluateWithStatus(agent, tick, status)
	local bValid = self.m_ActionConfig:execute(agent, tick)

	if not bValid then
		local childStatus = EBTStatus.BT_INVALID

		bValid = EBTStatus.BT_SUCCESS == self:evaluateImpl(agent, tick, childStatus)
	end

	return bValid
end

return _M
