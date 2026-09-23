-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_MasterInCloudConfineEmpathySad.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_12_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "HideQuestionMark", 0)
	flow:setActive()

	local _0 = _C(22, "GetSelfId", flow)

	_A(flow, "HideEmojiOnTarget", _0, "")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 4 then
		return true
	end

	if nodeId == 8 then
		return _M._to_4_0(flow)
	end

	if nodeId == 10 then
		return _M._to_8_0(flow)
	end

	if nodeId == 12 then
		return _M._to_23_0(flow)
	end

	if nodeId == 23 then
		return _M._to_10_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_4_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Cry")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_CryStart")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_CryLoop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_CryEnd")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(4)

	return true
end

function _M._to_8_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_5_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tStopDist", 2.5)
	flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
	flow.__agent:addSubTreeLocalParam("tSpeed", 3.5)
	flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
	flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
	flow:setContinue(8)

	return true
end

function _M._to_10_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 1)
	flow:setContinue(10)

	return true
end

function _M._to_12_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_7_2(flow)

	if _0 then
		flow:setActive()
		_C(12, "DoBehaviour", flow, "PBT_ShowQuestionMark")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tMarkType", "DirectFull")
		flow.__agent:addSubTreeLocalParam("tTimeout", 0.5)
		flow:setContinue(12)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_23_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_5_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(23)

	return true
end

function _M._get_5_1(flow)
	return _C(5, "GetPetMaster", flow, 0)
end

function _M._get_7_2(flow)
	local _1 = _M._get_5_1(flow)
	local _0 = _C(6, "GetTargetBuffLayerCount", flow, _1, 21293041)

	return _0 > 0
end

return _M
