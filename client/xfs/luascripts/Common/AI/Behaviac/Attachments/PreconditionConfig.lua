-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Attachments\\PreconditionConfig.lua

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
local PreconditionConfig = functions.class("PreconditionConfig", AttachActionConfig)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("PreconditionConfig", PreconditionConfig)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("PreconditionConfig", "AttachActionConfig")

local _M = PreconditionConfig

function _M:ctor()
	_M.super.ctor(self)

	self.m_phase = EPreconditionPhase.E_ENTER
	self.m_bAnd = false
	self.__name = "PreconditionConfig"
end

function _M:parse(properties)
	local success = _M.super.parse(self, properties)
	local nameStr, valueStr

	for _, p in ipairs(properties) do
		nameStr = p[1]
		valueStr = p[2]

		if nameStr == "BinaryOperator" then
			if valueStr == "Or" then
				self.m_bAnd = false
			elseif valueStr == "And" then
				self.m_bAnd = true
			else
				macros.BEHAVIAC_ASSERT(false, "[_M:parse()] BinaryOperator")
			end
		elseif nameStr == "Phase" then
			if valueStr == "Enter" then
				self.m_phase = EPreconditionPhase.E_ENTER

				break
			end

			if valueStr == "Update" then
				self.m_phase = EPreconditionPhase.E_UPDATE

				break
			end

			if valueStr == "Both" then
				self.m_phase = EPreconditionPhase.E_BOTH

				break
			end

			macros.BEHAVIAC_ASSERT(false, "[_M:parse()] Phase")

			break
		end
	end

	return success
end

return _M
