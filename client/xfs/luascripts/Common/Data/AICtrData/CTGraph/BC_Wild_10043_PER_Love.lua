-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10043_PER_Love.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tTgtId", value0)
	agent:addSubTreeLocalParam("tTargetAtYawDegree", value1)
	agent:addSubTreeLocalParam("tInstant", value2)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_1(flow, nodeId, value0)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tTargetActorId", value0)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Event_PER_Love" then
		return _M._to_34_0(flow)
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

	if nodeId == 38 then
		return true
	end

	if nodeId == 39 then
		return _M._to_46_0(flow)
	end

	if nodeId == 44 then
		return _M._to_54_0(flow)
	end

	if nodeId == 45 then
		return true
	end

	if nodeId == 46 then
		return _M._to_44_0(flow)
	end

	if nodeId == 53 then
		return _M._to_38_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 14 then
		return _M._get_60_2(flow)
	end

	if nodeId == 18 then
		return _M._get_60_2(flow)
	end

	if nodeId == 38 then
		return _M._get_36_3(flow)
	end

	if nodeId == 45 then
		return _M._get_57_2(flow)
	end
end

function _M._to_14_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 14)

	if not _1 then
		flow:setActive()
		_C(14, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_32_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
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
	else
		flow:setActiveFail()
	end
end

function _M._to_18_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 18)

	if not _1 then
		flow:setActive()
		_C(18, "DoBehaviour", flow, "PBT_CustomLoopAnimation")
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
	else
		flow:setActiveFail()
	end
end

function _M._to_22_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_32_2(flow)

	return _doBehaviourTail_0(flow, 22, _0, 0, false)
end

function _M._to_23_0(flow)
	local _0 = _M._get_36_1(flow)

	if _0 then
		flow:setActive()
		_A(flow, "SendMessageToTrigger", 0, 1004301)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_25_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_32_2(flow)

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
	if not _B(flow, "PBT_Behav_Com_Notice") then
		return
	end

	local _0 = _M._get_32_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tWait", true)
	flow:setContinue(31)

	return true
end

function _M._to_34_0(flow)
	local _0 = _M._get_11_2(flow)

	if _0 then
		return _M._to_31_0(flow)
	end

	return _M._to_35_0(flow)
end

function _M._to_35_0(flow)
	local _0 = _M._get_42_2(flow)

	if _0 then
		return _M._to_39_0(flow)
	end

	local _2 = _M._get_32_2(flow)
	local _3 = _C(49, "GetPetData", flow, _2, "baseFormPet", true, 0)
	local _4 = _3 == 1004100
	local _1 = not _4

	if _1 then
		return _M._to_53_0(flow)
	end
end

function _M._to_38_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 38)

	if not _1 then
		flow:setActive()
		_C(38, "DoBehaviour", flow, "PBT_Behav_Com_Love")

		local _1 = _M._get_32_2(flow)

		return _doBehaviourTail_1(flow, 38, _1)
	else
		flow:setActiveFail()
	end
end

function _M._to_39_0(flow)
	if not _B(flow, "PBT_Node_Com_SensedAlert") then
		return
	end

	local _0 = _M._get_32_2(flow)

	return _doBehaviourTail_1(flow, 39, _0)
end

function _M._to_44_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Love")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 2)
	flow:setContinue(44)

	return true
end

function _M._to_45_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 45)

	if not _1 then
		flow:setActive()
		_C(45, "DoBehaviour", flow, "PBT_Behav_Com_Love")

		local _1 = _M._get_32_2(flow)

		return _doBehaviourTail_1(flow, 45, _1)
	else
		flow:setActiveFail()
	end
end

function _M._to_46_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_32_2(flow)

	return _doBehaviourTail_0(flow, 46, _0, 0, false)
end

function _M._to_47_0(flow)
	local _0 = _M._get_36_1(flow)

	if _0 then
		flow:setActive()
		_A(flow, "SendMessageToTrigger", 0, 1004302)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_53_0(flow)
	if not _B(flow, "PBT_Node_Com_SensedAlert") then
		return
	end

	return _doBehaviourTail_1(flow, 53, 0)
end

function _M._to_54_0(flow)
	flow:addTimer(1, _M, "_to_47_0", flow)

	return _M._to_45_0(flow)
end

function _M._get_7_1(flow)
	local _0 = _M._get_30_1(flow)

	return _C(7, "GetControllingPetActorId", flow, _0)
end

function _M._get_11_2(flow)
	local _3 = _M._get_7_1(flow)
	local _4 = _C(3, "GetHpPercent", flow, _3)
	local _0 = _4 <= 0.5

	if not _0 then
		return false
	end

	local _2 = _M._get_30_1(flow)
	local _1 = _C(4, "IsControllingPet", flow, _2)

	if not _1 then
		return false
	end

	return true
end

function _M._get_30_1(flow)
	local _0 = _M._get_32_2(flow)

	return _C(30, "GetPetMaster", flow, _0)
end

function _M._get_32_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_36_1(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_32_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayer")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_36_3(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_32_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayerInterrupt")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_42_2(flow)
	local _4 = _M._get_32_2(flow)
	local _0 = _C(43, "IsInAnimState", flow, _4, "IdleSpecial")

	if not _0 then
		return false
	end

	local _3 = _M._get_32_2(flow)
	local _2 = _C(41, "GetPetData", flow, _3, "baseFormPet", true, 0)
	local _1 = _2 == 1004100

	if not _1 then
		return false
	end

	return true
end

function _M._get_57_2(flow)
	local _2 = _M._get_32_2(flow)
	local _3 = _C(55, "GetDistance", flow, _2, 0, false)
	local _0 = _3 > 10

	if _0 then
		return true
	end

	local _1 = _M._get_36_3(flow)

	if _1 then
		return true
	end

	return false
end

function _M._get_60_2(flow)
	local _2 = _M._get_7_1(flow)
	local _3 = _C(58, "GetDistance", flow, _2, 0, false)
	local _0 = _3 > 15

	if _0 then
		return true
	end

	local _1 = _M._get_36_3(flow)

	if _1 then
		return true
	end

	return false
end

return _M
