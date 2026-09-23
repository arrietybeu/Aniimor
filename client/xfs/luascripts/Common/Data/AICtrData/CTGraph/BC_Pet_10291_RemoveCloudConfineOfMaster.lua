-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_10291_RemoveCloudConfineOfMaster.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8, value9)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tTargetActorId", value0)
	agent:addSubTreeLocalParam("tStopDist", value1)
	agent:addSubTreeLocalParam("tMaxTimeout", value2)
	agent:addSubTreeLocalParam("tFaceTarget", value3)
	agent:addSubTreeLocalParam("tSpeed", value4)
	agent:addSubTreeLocalParam("tMoveUpdateLevel", value5)
	agent:addSubTreeLocalParam("tPathFindType", value6)
	agent:addSubTreeLocalParam("tSpeedRateType", value7)
	agent:addSubTreeLocalParam("tUseAccurateArrive", value8)
	agent:addSubTreeLocalParam("tNoBodySize", value9)
	flow:setContinue(nodeId)

	return true
end

function _M.executeTickLodTrigger(flow)
	return _M._to_15_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "HideQuestionMark", 0)
	flow:setActive()

	local _0 = _C(26, "GetSelfId", flow)

	_A(flow, "HideEmojiOnTarget", _0, "")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 1 then
		return _M._to_30_0(flow)
	end

	if nodeId == 8 then
		return _M._to_17_0(flow)
	end

	if nodeId == 14 then
		return _M._to_8_0(flow)
	end

	if nodeId == 15 then
		return _M._to_27_0(flow)
	end

	if nodeId == 16 then
		return _M._to_44_0(flow)
	end

	if nodeId == 17 then
		return true
	end

	if nodeId == 27 then
		return _M._to_16_0(flow)
	end

	if nodeId == 44 then
		return _M._to_1_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 17 then
		return _M._get_20_2(flow)
	end
end

function _M._to_1_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_9_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tSkillId", 12930900)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(1)

	return true
end

function _M._to_8_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Love")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 4)
	flow:setContinue(8)

	return true
end

function _M._to_14_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_9_1(flow)

	return _doBehaviourTail_0(flow, 14, _0, 3.5, 5, true, 3.5, 99999, 0, 0, false, false)
end

function _M._to_15_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_3_2(flow)

	if _0 then
		flow:setActive()
		_C(15, "DoBehaviour", flow, "PBT_ShowQuestionMark")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tMarkType", "DirectFull")
		flow.__agent:addSubTreeLocalParam("tTimeout", 0.5)
		flow:setContinue(15)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_16_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0.5)
	flow:setContinue(16)

	return true
end

function _M._to_17_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 17)

	if not _1 then
		flow:setActive()
		_C(17, "DoBehaviour", flow, "PBT_Com_Node_Wait")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 4)
		flow:setContinue(17)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_27_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_9_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(27)

	return true
end

function _M._to_30_0(flow)
	flow:addTimer(0.2, _M, "_to_31_0", flow)

	return _M._to_14_0(flow)
end

function _M._to_31_0(flow)
	flow:setActive()
	_A(flow, "SendMessageToTrigger", 0, 1029101)

	return true
end

function _M._to_44_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_9_1(flow)

	return _doBehaviourTail_0(flow, 44, _0, 3, 5, true, 3.5, 99999, 0, 0, false, false)
end

function _M._get_3_2(flow)
	local _1 = _M._get_9_1(flow)
	local _0 = _C(2, "GetTargetBuffLayerCount", flow, _1, 21293041)

	return _0 > 0
end

function _M._get_9_1(flow)
	return _C(9, "GetPetMaster", flow, 0)
end

function _M._get_20_2(flow)
	local _1 = _C(19, "GetPetMaster", flow, 0)
	local _0 = _C(18, "GetDistance", flow, _1, 0, false)

	return _0 > 4
end

return _M
