-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10043_PER_CastSkill_HealPlayer.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "PercpetEntityReactionTriggerCastSkill" then
		return _M._to_31_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 14 then
		return _M._to_22_0(flow)
	end

	if nodeId == 18 then
		return true
	end

	if nodeId == 22 then
		return _M._to_27_0(flow)
	end

	if nodeId == 25 then
		return _M._to_18_0(flow)
	end

	if nodeId == 31 then
		return _M._to_14_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_14_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_29_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tStopDist", 4)
	flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 2)
	flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 0)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", true)
	flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
	flow:setContinue(14)

	return true
end

function _M._to_18_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_LoveStart")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_LoveLoop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_LoveEnd")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", true)
	flow:setContinue(18)

	return true
end

function _M._to_22_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_29_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(22)

	return true
end

function _M._to_23_0(flow)
	flow:setActive()
	_A(flow, "SendMessageToTrigger", 0, 1004301)

	return true
end

function _M._to_25_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_29_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tSkillId", 10430110)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(25)

	return true
end

function _M._to_27_0(flow)
	flow:addTimer(0.3, _M, "_to_23_0", flow)

	return _M._to_25_0(flow)
end

function _M._to_31_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_11_2(flow)

	if _0 then
		flow:setActive()
		_C(31, "DoBehaviour", flow, "PBT_Behav_Com_Notice")

		local _1 = _M._get_29_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tWait", true)
		flow:setContinue(31)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_11_2(flow)
	local _2 = _M._get_30_1(flow)
	local _0 = _C(4, "IsControllingPet", flow, _2)

	if not _0 then
		return false
	end

	local _3 = _M._get_30_1(flow)
	local _4 = _C(7, "GetControllingPetActorId", flow, _3)
	local _5 = _C(3, "GetHpPercent", flow, _4)
	local _1 = _5 <= 0.5

	if not _1 then
		return false
	end

	return true
end

function _M._get_29_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_30_1(flow)
	local _0 = _M._get_29_2(flow)

	return _C(30, "GetPetMaster", flow, _0)
end

return _M
