-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10041_IdleExitMimicry.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_52_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 52 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_52_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_66_2(flow)

	if _0 then
		flow:setActive()
		_C(52, "DoBehaviour", flow, "PBT_SwitchState")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tCharacterState", "SWIMMIMICRYOUT")
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
		flow:setContinue(52)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_65_1(flow)
	local _0 = _C(63, "GetPerceptibilityTable", flow)

	if _0 == nil then
		return
	end

	local key = next(_0)
	local value = _0[key]

	for k, v in pairs(_0) do
		if value < v then
			key, value = k, v
		end
	end

	return key
end

function _M._get_66_2(flow)
	local _1 = _M._get_65_1(flow)
	local _0 = _C(64, "GetPerceptibilityValue", flow, _1)

	return _0 <= 0
end

return _M
