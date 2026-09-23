-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10023_Security_Patrol.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_8_0(flow)
	end
end

function _M._to_8_0(flow)
	local _0 = _M._get_37_1(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_1_0(flow)

		_A(flow, "StopEffectOnTarget", _1, "Eff_Parmon_10023_Behav_Security_Locking")
		flow:setActive()

		local _2 = _M._get_1_0(flow)

		_A(flow, "StopEffectOnTarget", _2, "Eff_Parmon_10023_Behav_Security_Finding")
		flow:setActive()

		local _3 = _M._get_1_0(flow)

		_A(flow, "PlayEffectOnTarget", _3, "Eff_Parmon_10023_Behav_Security_Finding", -1)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_1_0(flow)
	return _C(1, "GetSelfId", flow)
end

function _M._get_37_1(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckVisionNormal")
	local _1 = _M._get_1_0(flow)

	_0:setContextValue("targetActorId", _1)

	local _2 = _0:getMacroValue("result")

	flow:clearSubMacro(_0)

	return _2
end

return _M
