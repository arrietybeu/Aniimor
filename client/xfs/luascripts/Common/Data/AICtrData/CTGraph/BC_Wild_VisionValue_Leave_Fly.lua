-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_VisionValue_Leave_Fly.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "VisionValue_Leave" then
		return _M._to_102_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 58 then
		return _M._to_78_0(flow)
	end

	if nodeId == 78 then
		return true
	end

	if nodeId == 102 then
		return _M._to_58_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_58_0(flow)
	if not _B(flow, "PBT_LeaveTarget") then
		return
	end

	local _0 = _M._get_57_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tLeaveDistance", 30)
	flow.__agent:addSubTreeLocalParam("tSpeed", 7)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tMaxTime", 6)
	flow:setContinue(58)

	return true
end

function _M._to_78_0(flow)
	if not _B(flow, "PBT_DestroySelf") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(78)

	return true
end

function _M._to_102_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", "FLYING")
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(102)

	return true
end

function _M._get_15_0(flow)
	return _C(15, "GetPerceptibilityTable", flow)
end

function _M._get_17_2(flow)
	local _0 = _M._get_52_1(flow)

	return _C(17, "IsEntityType", flow, _0, "ACTOR_TYPE_PLAYER")
end

function _M._get_18_1(flow)
	local _0 = _M._get_52_1(flow)

	return _C(18, "GetPerceptibilityValue", flow, _0)
end

function _M._get_22_2(flow)
	local _0 = _M._get_18_1(flow)

	return _0 > 40
end

function _M._get_49_2(flow)
	local _0 = _M._get_18_1(flow)

	return _0 <= 160
end

function _M._get_52_1(flow)
	local _0 = _M._get_15_0(flow)

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

function _M._get_54_1(flow)
	local _1 = _M._get_15_0(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_57_1(flow)
	local _0 = _C(56, "GetPerceptibilityTable", flow)

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

return _M
