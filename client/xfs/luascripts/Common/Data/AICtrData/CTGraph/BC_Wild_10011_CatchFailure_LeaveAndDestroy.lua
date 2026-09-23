-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10011_CatchFailure_LeaveAndDestroy.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "CatchResult_Failure" then
		return _M._to_103_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 100 then
		return true
	end

	if nodeId == 103 then
		return _M._to_100_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_100_0(flow)
	if not _B(flow, "PBT_LeaveTargetAndDestroy") then
		return
	end

	local _0 = _M._get_102_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tLeaveDistance", 12)
	flow.__agent:addSubTreeLocalParam("tSpeed", 6)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tMaxTime", 3)
	flow.__agent:addSubTreeLocalParam("tDestroyOnFail", true)
	flow:setContinue(100)

	return true
end

function _M._to_103_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	local _0 = "LOCOMOTION"

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", _0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(103)

	return true
end

function _M._get_102_1(flow)
	local _0 = _C(101, "GetAoiEntityTableByLevel", flow, 0, 30, 2)

	return _C(102, "SelectOneByRandom", flow, _0)
end

return _M
