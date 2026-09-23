-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10191_DayMimicryIdle.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_3_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 0 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 0 then
		return _M._get_6_1(flow)
	end
end

function _M._to_0_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 0)

	if not _1 then
		flow:setActive()
		_C(0, "DoBehaviour", flow, "PBT_SwitchState")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tCharacterState", "MIMICRY")
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
		flow:setContinue(0)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_3_0(flow)
	local _0 = _M._get_2_2(flow)

	if _0 then
		return _M._to_0_0(flow)
	end
end

function _M._get_2_2(flow)
	local _0 = _C(1, "GetDayTime", flow)

	return _C(2, "IsSameDayTime", flow, _0, 1)
end

function _M._get_6_1(flow)
	local _0 = _M._get_2_2(flow)

	return not _0
end

return _M
