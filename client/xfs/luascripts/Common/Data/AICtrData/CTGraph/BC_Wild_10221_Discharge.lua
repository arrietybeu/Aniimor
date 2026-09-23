-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10221_Discharge.lua

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

local function _doBehaviourTail_1(flow, nodeId, value0, value1, value2)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tTgtId", value0)
	agent:addSubTreeLocalParam("tTargetAtYawDegree", value1)
	agent:addSubTreeLocalParam("tInstant", value2)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_2(flow, nodeId, value0, value1, value2, value3, value4, value5, value6)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tSkillId", value1)
	agent:addSubTreeLocalParam("tSkillTargetActorId", value2)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value3)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value4)
	agent:addSubTreeLocalParam("tRaycastOpen", value5)
	agent:addSubTreeLocalParam("tCastAbilitySource", value6)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_3(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8, value9)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value1)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value2)
	agent:addSubTreeLocalParam("tAnimationStartKey", value3)
	agent:addSubTreeLocalParam("tAnimationLoopKey", value4)
	agent:addSubTreeLocalParam("tAnimationEndKey", value5)
	agent:addSubTreeLocalParam("tAnimationTimeout", value6)
	agent:addSubTreeLocalParam("tTimelineTag", value7)
	agent:addSubTreeLocalParam("tNeedLoop", value8)
	agent:addSubTreeLocalParam("tAnimationPlayOnce", value9)
	flow:setContinue(nodeId)

	return true
end

function _M.executeTickLodTrigger(flow)
	return _M._to_11_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _C(21, "GetSelfId", flow)

	_A(flow, "HideEmojiOnTarget", _0, "")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 11 then
		return _M._to_12_0(flow)
	end

	if nodeId == 12 then
		return _M._to_25_0(flow)
	end

	if nodeId == 15 then
		return _M._to_17_0(flow)
	end

	if nodeId == 17 then
		return _M._to_31_0(flow)
	end

	if nodeId == 18 then
		return true
	end

	if nodeId == 28 then
		return true
	end

	if nodeId == 31 then
		return _M._to_18_0(flow)
	end

	if nodeId == 37 then
		return _M._to_38_0(flow)
	end

	if nodeId == 38 then
		return _M._to_41_0(flow)
	end

	if nodeId == 39 then
		return true
	end

	if nodeId == 47 then
		return true
	end

	if nodeId == 48 then
		return _M._to_49_0(flow)
	end

	if nodeId == 49 then
		return _M._to_51_0(flow)
	end

	if nodeId == 50 then
		return true
	end

	if nodeId == 51 then
		return _M._to_50_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_11_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_5_1(flow)

	if _0 then
		flow:setActive()
		_C(11, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_10_1(flow)

		return _doBehaviourTail_0(flow, 11, _1, 0.5, 5, true, 4, 2, 5, 1, true, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_12_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_10_1(flow)

	return _doBehaviourTail_1(flow, 12, _0, 0, false)
end

function _M._to_15_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_10_1(flow)

	return _doBehaviourTail_2(flow, 15, 0, 12210300, _0, "", 0, false, 0)
end

function _M._to_17_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_3(flow, 17, 0, "Happy", 2, "Behav_HappyStart", "Behav_HappyLoop", "Behav_HappyEnd", 2, "", false, true)
end

function _M._to_18_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_3(flow, 18, 0, "Sleep", 18, "Behav_SleepStart", "Behav_SleepLoop", "Behav_SleepEnd", 10, "", false, false)
end

function _M._to_25_0(flow)
	local _2 = _M._get_26_1(flow)
	local _0 = not _2

	if _0 then
		return _M._to_35_0(flow)
	end

	local _1 = _M._get_26_1(flow)

	if _1 then
		return _M._to_28_0(flow)
	end
end

function _M._to_28_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_3(flow, 28, 0, "", 0, "Behav_CryStart", "Behav_CryLoop", "Behav_CryEnd", 2, "", false, true)
end

function _M._to_31_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	local _0 = _C(29, "RandomInteger", flow, 0, 2)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", _0)
	flow:setContinue(31)

	return true
end

function _M._to_35_0(flow)
	local _0 = _M._get_34_2(flow)

	if _0 then
		return _M._to_15_0(flow)
	end

	local _2 = _M._get_34_2(flow)
	local _1 = not _2

	if _1 then
		return _M._to_37_0(flow)
	end
end

function _M._to_37_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_5_1(flow)

	if _0 then
		flow:setActive()
		_C(37, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_10_1(flow)

		return _doBehaviourTail_0(flow, 37, _1, 0.5, 5, true, 4, 2, 5, 1, true, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_38_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_10_1(flow)

	return _doBehaviourTail_1(flow, 38, _0, 0, false)
end

function _M._to_39_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_3(flow, 39, 0, "", 0, "Behav_CryStart", "Behav_CryLoop", "Behav_CryEnd", 2, "", false, true)
end

function _M._to_41_0(flow)
	local _2 = _M._get_42_1(flow)
	local _0 = not _2

	if _0 then
		return _M._to_45_0(flow)
	end

	local _1 = _M._get_42_1(flow)

	if _1 then
		return _M._to_39_0(flow)
	end
end

function _M._to_45_0(flow)
	local _0 = _M._get_44_2(flow)

	if _0 then
		return _M._to_48_0(flow)
	end

	local _2 = _M._get_44_2(flow)
	local _1 = not _2

	if _1 then
		return _M._to_47_0(flow)
	end
end

function _M._to_47_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_3(flow, 47, 0, "", 0, "Behav_AngryStart", "Behav_AngryLoop", "Behav_AngryEnd", 2, "", false, true)
end

function _M._to_48_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_10_1(flow)

	return _doBehaviourTail_2(flow, 48, 0, 12210300, _0, "", 0, false, 0)
end

function _M._to_49_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_3(flow, 49, 0, "Happy", 2, "Behav_HappyStart", "Behav_HappyLoop", "Behav_HappyEnd", 2, "", false, true)
end

function _M._to_50_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_3(flow, 50, 0, "Sleep", 18, "Behav_SleepStart", "Behav_SleepLoop", "Behav_SleepEnd", 10, "", false, false)
end

function _M._to_51_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	local _0 = _C(52, "RandomInteger", flow, 0, 2)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", _0)
	flow:setContinue(51)

	return true
end

function _M._get_2_3(flow)
	local _0 = _C(1, "GetAoiEntityTableByLevel", flow, 0, 10, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(2, "__iterItem", v)

		if _M._get_24_3(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_2_2(flow)
	return flow:getCache(2, "__iterItem")
end

function _M._get_5_1(flow)
	local _1 = _M._get_2_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_9_1(flow)
	local _0 = _M._get_2_3(flow)

	return _C(9, "SelectOneByRandom", flow, _0)
end

function _M._get_10_1(flow)
	local _0 = flow:getCache(10, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_9_1(flow)

	flow:setCache(10, "1", _0)

	return _0
end

function _M._get_24_3(flow)
	local _3 = _M._get_2_2(flow)
	local _0 = _C(7, "CheckHasChemState", flow, _3, "STATE_Conductive_KEY")

	if not _0 then
		return false
	end

	local _4 = _M._get_2_2(flow)
	local _5 = _C(22, "CheckHasChemState", flow, _4, "STATE_ELECTRIC_KEY")
	local _1 = not _5

	if not _1 then
		return false
	end

	local _6 = _M._get_2_2(flow)
	local _7 = _C(53, "GetDistance", flow, _6, 0, true)
	local _2 = _7 <= 5

	if not _2 then
		return false
	end

	return true
end

function _M._get_26_1(flow)
	local _0 = _M._get_10_1(flow)

	return _C(26, "CheckHasChemState", flow, _0, "STATE_ELECTRIC_KEY")
end

function _M._get_34_2(flow)
	local _1 = _M._get_10_1(flow)
	local _0 = _C(33, "GetDistance", flow, 0, _1, true)

	return _0 <= 2
end

function _M._get_42_1(flow)
	local _0 = _M._get_10_1(flow)

	return _C(42, "CheckHasChemState", flow, _0, "STATE_ELECTRIC_KEY")
end

function _M._get_44_2(flow)
	local _1 = _M._get_10_1(flow)
	local _0 = _C(43, "GetDistance", flow, 0, _1, true)

	return _0 <= 2
end

return _M
