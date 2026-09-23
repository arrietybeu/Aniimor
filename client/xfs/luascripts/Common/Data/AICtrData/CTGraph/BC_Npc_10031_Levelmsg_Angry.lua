-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Npc_10031_Levelmsg_Angry.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerAngry" then
		return _M._to_28_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 28 then
		return _M._to_34_0(flow)
	end

	if nodeId == 34 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_28_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_33_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(28)

	return true
end

function _M._to_34_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Angry")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 60)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_AngryStart")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_AngryLoop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_AngryEnd")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 60)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(34)

	return true
end

function _M._get_33_1(flow)
	local _0 = _C(32, "GetAoiEntityTableByLevel", flow, 0, 10, 2)

	return _C(33, "SelectOneByRandom", flow, _0)
end

return _M
