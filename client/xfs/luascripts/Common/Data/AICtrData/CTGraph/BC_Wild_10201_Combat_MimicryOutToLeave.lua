-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_Combat_MimicryOutToLeave.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Combat_Prepare" then
		return _M._to_57_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 57 then
		return _M._to_88_0(flow)
	end

	if nodeId == 88 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_57_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", "LOCOMOTION")
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(57)

	return true
end

function _M._to_88_0(flow)
	if not _B(flow, "PBT_LeaveTargetAndDestroy") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", 0)
	flow.__agent:addSubTreeLocalParam("tLeaveDistance", 50)
	flow.__agent:addSubTreeLocalParam("tSpeed", 8)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
	flow.__agent:addSubTreeLocalParam("tMaxTime", 10)
	flow.__agent:addSubTreeLocalParam("tDestroyOnFail", true)
	flow:setContinue(88)

	return true
end

return _M
