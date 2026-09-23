-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Attachments\\Precondition.lua

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
local AttachAction = require("Common.AI.Behaviac.Attachments.AttachAction")
local Precondition = functions.class("Precondition", AttachAction)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("Precondition", Precondition)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("Precondition", "AttachAction")

local _M = Precondition
local PreconditionConfig = require("Common.AI.Behaviac.Attachments.PreconditionConfig")
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)

	self.m_ActionConfig = PreconditionConfig.new()
end

function _M:release()
	_M.super.release(self)
end

function _M:onLoading(version, agentType, properties)
	_M.super.onLoading(self, version, agentType, properties)
	self.m_ActionConfig:parse(properties)
end

function _M:getPhase()
	return self.m_ActionConfig.m_phase
end

function _M:setPhase(phase)
	self.m_ActionConfig.m_phase = phase
end

function _M:isAnd()
	return self.m_ActionConfig.m_bAnd
end

function _M:setIsAnd(isAnd)
	self.m_ActionConfig.m_bAnd = isAnd
end

function _M:isPrecondition()
	return true
end

return _M
