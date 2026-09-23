-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Recruit_MoveToPoint.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "RecruitMoveToPointMsgTrigger" then
		return _M._to_0_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 0 then
		return _M._to_3_0(flow)
	end

	if nodeId == 3 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_0_0(flow)
	if not _B(flow, "PBT_MoveToPoint") then
		return
	end

	local _0 = flow:getContextValue("movePos")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tMovePos", _0)
	flow.__agent:addSubTreeLocalParam("tMoveMaxTime", 15)
	flow.__agent:addSubTreeLocalParam("tMoveSpeed", -1)
	flow.__agent:addSubTreeLocalParam("tBehaviorSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow.__agent:addSubTreeLocalParam("tTeleportIfCannotMove", false)
	flow:setContinue(0)

	return true
end

function _M._to_3_0(flow)
	if not _B(flow, "PBT_TurnToTargetPos") then
		return
	end

	local _0 = flow:getContextValue("turnPos")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tTargetPos", _0)
	flow:setContinue(3)

	return true
end

return _M
