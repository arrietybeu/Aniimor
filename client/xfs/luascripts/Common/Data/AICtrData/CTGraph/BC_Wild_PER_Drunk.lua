-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_PER_Drunk.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "PercpetEntityReactionTriggerDrunk" then
		return _M._to_16_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 11 then
		return _M._to_12_0(flow)
	end

	if nodeId == 12 then
		return _M._to_15_0(flow)
	end

	if nodeId == 13 then
		return _M._to_11_0(flow)
	end

	if nodeId == 14 then
		return true
	end

	if nodeId == 15 then
		return _M._to_14_0(flow)
	end

	if nodeId == 16 then
		return _M._to_13_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_11_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_0_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tStopDist", 1)
	flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 2)
	flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
	flow:setContinue(11)

	return true
end

function _M._to_12_0(flow)
	if not _B(flow, "PBT_Com_Eat") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("eatTimeOut", 5)
	flow:setContinue(12)

	return true
end

function _M._to_13_0(flow)
	if not _B(flow, "PBT_Com_Happy_New") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 3)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tPlayOnce", true)
	flow:setContinue(13)

	return true
end

function _M._to_14_0(flow)
	if not _B(flow, "PBT_Sleep") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("sleepTimeOut", 30)
	flow.__agent:addSubTreeLocalParam("tShowEmojiBubble", true)
	flow.__agent:addSubTreeLocalParam("tisLoop", false)
	flow:setContinue(14)

	return true
end

function _M._to_15_0(flow)
	if not _B(flow, "PBT_Behav_Com_Drunk") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tDuration", 3)
	flow:setContinue(15)

	return true
end

function _M._to_16_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_0_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(16)

	return true
end

function _M._get_0_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

return _M
