-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Attachments\\EffectorConfig.lua

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
local AttachActionConfig = require("Common.AI.Behaviac.Attachments.AttachActionConfig")
local EffectorConfig = functions.class("EffectorConfig", AttachActionConfig)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("EffectorConfig", EffectorConfig)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("EffectorConfig", "AttachActionConfig")

local _M = EffectorConfig

function _M:ctor()
	_M.super.ctor(self)

	self.m_phase = ENodePhase.E_SUCCESS
end

function _M:parse(properties)
	local success = _M.super.parse(self, properties)
	local nameStr, valueStr

	for _, p in ipairs(properties) do
		nameStr = p[1]
		valueStr = p[2]

		if nameStr == "Phase" then
			if valueStr == "Success" then
				self.m_phase = ENodePhase.E_SUCCESS

				break
			end

			if valueStr == "Failure" then
				self.m_phase = ENodePhase.E_FAILURE

				break
			end

			if valueStr == "Both" then
				self.m_phase = ENodePhase.E_BOTH

				break
			end

			macros.BEHAVIAC_ASSERT(false)

			break
		end
	end

	return success
end

return _M
