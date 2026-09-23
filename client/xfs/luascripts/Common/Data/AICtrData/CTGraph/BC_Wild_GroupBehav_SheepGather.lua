-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_SheepGather.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Event_GB_SheepGather" then
		return _M._to_35_0(flow)
	end

	if eventName == "Event_GB_SheepAbility" then
		return _M._to_9_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 1 then
		return true
	end

	if nodeId == 9 then
		return true
	end

	if nodeId == 30 then
		return true
	end

	if nodeId == 35 then
		return _M._to_5_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_1_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Angry")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 3)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_AngryStart")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_AngryLoop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_AngryEnd")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 3)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(1)

	return true
end

function _M._to_5_0(flow)
	local _0 = _M._get_6_2(flow)

	if _0 then
		return _M._to_1_0(flow)
	end

	local _2 = _M._get_6_2(flow)
	local _1 = not _2

	if _1 then
		return _M._to_30_0(flow)
	end
end

function _M._to_9_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = flow:getContextValue("targetActorId")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tSkillId", 12610600)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(9)

	return true
end

function _M._to_30_0(flow)
	if not _B(flow, "PBT_Wild_11026101_MoveToTarget") then
		return
	end

	local _0 = flow:getContextValue("targetActorId")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tStopDist", 1.2)
	flow.__agent:addSubTreeLocalParam("tMaxTimeout", 3)
	flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 10)
	flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
	flow:setContinue(30)

	return true
end

function _M._to_35_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", "LOCOMOTION")
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(35)

	return true
end

function _M._get_6_2(flow)
	local _0 = flow:getContextValue("memberIndex")

	return _0 == 1
end

return _M
