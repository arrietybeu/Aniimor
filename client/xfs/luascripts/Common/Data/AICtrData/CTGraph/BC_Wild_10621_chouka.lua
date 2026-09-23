-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10621_chouka.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6)
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

local function _doBehaviourTail_1(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tAnimationKey", value1)
	agent:addSubTreeLocalParam("tAnimationTimeout", value2)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value3)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value4)
	agent:addSubTreeLocalParam("tTimelineTag", value5)
	agent:addSubTreeLocalParam("tNeedLoop", value6)
	agent:addSubTreeLocalParam("tAnimationPlayOnce", value7)
	agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", value8)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_2(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value0)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value1)
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

local function _doBehaviourTail_4(flow, nodeId, value0, value1, value2)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("firstDialogueId", value0)
	agent:addSubTreeLocalParam("lastDialogueId", value1)
	agent:addSubTreeLocalParam("tWaitTime", value2)
	flow:setContinue(nodeId)

	return true
end

function _M.executeTickLodTrigger(flow)
	return _M._to_9_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 5 then
		return _M._to_29_0(flow)
	end

	if nodeId == 6 then
		return _M._to_30_0(flow)
	end

	if nodeId == 7 then
		return _M._to_31_0(flow)
	end

	if nodeId == 8 then
		return _M._to_24_0(flow)
	end

	if nodeId == 17 then
		return true
	end

	if nodeId == 18 then
		return true
	end

	if nodeId == 19 then
		return true
	end

	if nodeId == 20 then
		return _M._to_5_0(flow)
	end

	if nodeId == 24 then
		return _M._to_32_0(flow)
	end

	if nodeId == 25 then
		return true
	end

	if nodeId == 26 then
		return _M._to_6_0(flow)
	end

	if nodeId == 27 then
		return _M._to_8_0(flow)
	end

	if nodeId == 28 then
		return _M._to_7_0(flow)
	end

	if nodeId == 29 then
		return _M._to_25_0(flow)
	end

	if nodeId == 30 then
		return _M._to_17_0(flow)
	end

	if nodeId == 31 then
		return _M._to_18_0(flow)
	end

	if nodeId == 32 then
		return _M._to_19_0(flow)
	end

	if nodeId == 33 then
		return _M._to_20_0(flow)
	end

	if nodeId == 34 then
		return _M._to_26_0(flow)
	end

	if nodeId == 35 then
		return _M._to_28_0(flow)
	end

	if nodeId == 36 then
		return _M._to_27_0(flow)
	end

	if nodeId == 37 then
		return _M._to_35_0(flow)
	end

	if nodeId == 38 then
		return _M._to_36_0(flow)
	end

	if nodeId == 39 then
		return _M._to_34_0(flow)
	end

	if nodeId == 40 then
		return _M._to_33_0(flow)
	end

	if nodeId == 41 then
		return _M._to_40_0(flow)
	end

	if nodeId == 44 then
		return _M._to_49_0(flow)
	end

	if nodeId == 45 then
		return _M._to_44_0(flow)
	end

	if nodeId == 49 then
		return _M._to_50_0(flow)
	end

	if nodeId == 50 then
		return _M._to_51_0(flow)
	end

	if nodeId == 51 then
		return _M._to_52_0(flow)
	end

	if nodeId == 52 then
		return _M._to_53_0(flow)
	end

	if nodeId == 53 then
		return true
	end

	if nodeId == 54 then
		return _M._to_39_0(flow)
	end

	if nodeId == 55 then
		return _M._to_63_0(flow)
	end

	if nodeId == 59 then
		return _M._to_61_0(flow)
	end

	if nodeId == 60 then
		return true
	end

	if nodeId == 61 then
		return _M._to_60_0(flow)
	end

	if nodeId == 62 then
		return _M._to_64_0(flow)
	end

	if nodeId == 63 then
		return _M._to_62_0(flow)
	end

	if nodeId == 64 then
		return _M._to_59_0(flow)
	end

	if nodeId == 65 then
		return _M._to_75_0(flow)
	end

	if nodeId == 66 then
		return _M._to_37_0(flow)
	end

	if nodeId == 70 then
		return _M._to_72_0(flow)
	end

	if nodeId == 71 then
		return true
	end

	if nodeId == 72 then
		return _M._to_71_0(flow)
	end

	if nodeId == 73 then
		return _M._to_70_0(flow)
	end

	if nodeId == 74 then
		return _M._to_73_0(flow)
	end

	if nodeId == 75 then
		return _M._to_74_0(flow)
	end

	if nodeId == 76 then
		return _M._to_38_0(flow)
	end

	if nodeId == 77 then
		return _M._to_86_0(flow)
	end

	if nodeId == 81 then
		return _M._to_83_0(flow)
	end

	if nodeId == 82 then
		return true
	end

	if nodeId == 83 then
		return true
	end

	if nodeId == 84 then
		return _M._to_81_0(flow)
	end

	if nodeId == 85 then
		return _M._to_84_0(flow)
	end

	if nodeId == 86 then
		return _M._to_85_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_5_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_0(flow, 5, 0, 16230303, 0, "", 5, false, 0)
end

function _M._to_6_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_0(flow, 6, 0, 16230302, 0, "", 5, false, 0)
end

function _M._to_7_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_0(flow, 7, 0, 16230301, 0, "", 5, false, 0)
end

function _M._to_8_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_0(flow, 8, 0, 16230304, 0, "", 5, false, 0)
end

function _M._to_9_0(flow)
	local _3 = _C(10, "RandomInteger", flow, 0, 100)
	local _0 = _3 <= 70

	if _0 then
		return _M._to_46_0(flow)
	end

	local _4 = _C(12, "RandomInteger", flow, 0, 100)
	local _1 = _4 <= 70

	if _1 then
		return _M._to_56_0(flow)
	end

	local _5 = _C(14, "RandomInteger", flow, 0, 100)
	local _2 = _5 <= 70

	if _2 then
		return _M._to_67_0(flow)
	end

	return _M._to_78_0(flow)
end

function _M._to_17_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 17, 0, "Behav_Cry", 5, "", 5, "", false, false, false)
end

function _M._to_18_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 18, 0, "Behav_Love", 5, "", 5, "", false, false, false)
end

function _M._to_19_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 19, 0, "Behav_Happy", 5, "", 5, "", false, false, false)
end

function _M._to_20_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 20, 0, "Skill_TurnTable_Loop", 1, "", 5, "", true, false, false)
end

function _M._to_24_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_2(flow, 24, "Surprise", 5)
end

function _M._to_25_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_3(flow, 25, 0, "", 5, "StunStart", "StunLoop", "StunEnd", 5, "", false, false)
end

function _M._to_26_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 26, 0, "Skill_TurnTable_Loop", 1, "", 5, "", true, false, false)
end

function _M._to_27_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 27, 0, "Skill_TurnTable_Loop", 1, "", 5, "", true, false, false)
end

function _M._to_28_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 28, 0, "Skill_TurnTable_Loop", 1, "", 5, "", true, false, false)
end

function _M._to_29_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	return _doBehaviourTail_4(flow, 29, 1038118, 1038118, 0)
end

function _M._to_30_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	return _doBehaviourTail_4(flow, 30, 1038119, 1038119, 0)
end

function _M._to_31_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	return _doBehaviourTail_4(flow, 31, 1038120, 1038120, 0)
end

function _M._to_32_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	return _doBehaviourTail_4(flow, 32, 1038121, 1038121, 0)
end

function _M._to_33_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	return _doBehaviourTail_4(flow, 33, 1038115, 1038117, 0)
end

function _M._to_34_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	return _doBehaviourTail_4(flow, 34, 1038115, 1038117, 0)
end

function _M._to_35_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	return _doBehaviourTail_4(flow, 35, 1038115, 1038117, 0)
end

function _M._to_36_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	return _doBehaviourTail_4(flow, 36, 1038115, 1038117, 0)
end

function _M._to_37_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 37, 0, "Behav_DoubtLoop", 2, "", 5, "", true, false, false)
end

function _M._to_38_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 38, 0, "IdleSpecial", 2, "", 5, "", true, false, false)
end

function _M._to_39_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 39, 0, "IdleSpecial", 2, "", 5, "", true, false, false)
end

function _M._to_40_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 40, 0, "IdleSpecial", 2, "", 5, "", true, false, false)
end

function _M._to_41_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	return _doBehaviourTail_4(flow, 41, 1038162, 1038162, 0)
end

function _M._to_44_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 44, 0, "Behav_DoubtLoop", 2, "", 5, "", true, false, false)
end

function _M._to_45_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	return _doBehaviourTail_4(flow, 45, 1038163, 1038163, 0)
end

function _M._to_46_0(flow)
	local _1 = _C(47, "RandomInteger", flow, 0, 100)
	local _0 = _1 <= 50

	if _0 then
		return _M._to_41_0(flow)
	end

	return _M._to_45_0(flow)
end

function _M._to_49_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	return _doBehaviourTail_4(flow, 49, 1038115, 1038117, 0)
end

function _M._to_50_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 50, 0, "Skill_TurnTable_Loop", 1, "", 5, "", true, false, false)
end

function _M._to_51_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_0(flow, 51, 0, 16230303, 0, "", 5, false, 0)
end

function _M._to_52_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	return _doBehaviourTail_4(flow, 52, 1038118, 1038118, 0)
end

function _M._to_53_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_3(flow, 53, 0, "", 5, "StunStart", "StunLoop", "StunEnd", 5, "", false, false)
end

function _M._to_54_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	return _doBehaviourTail_4(flow, 54, 1038162, 1038162, 0)
end

function _M._to_55_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	return _doBehaviourTail_4(flow, 55, 1038163, 1038163, 0)
end

function _M._to_56_0(flow)
	local _1 = _C(57, "RandomInteger", flow, 0, 100)
	local _0 = _1 <= 50

	if _0 then
		return _M._to_54_0(flow)
	end

	return _M._to_55_0(flow)
end

function _M._to_59_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_0(flow, 59, 0, 16230302, 0, "", 5, false, 0)
end

function _M._to_60_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 60, 0, "Behav_Cry", 5, "", 5, "", false, false, false)
end

function _M._to_61_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	return _doBehaviourTail_4(flow, 61, 1038119, 1038119, 0)
end

function _M._to_62_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	return _doBehaviourTail_4(flow, 62, 1038115, 1038117, 0)
end

function _M._to_63_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 63, 0, "Behav_DoubtLoop", 2, "", 5, "", true, false, false)
end

function _M._to_64_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 64, 0, "Skill_TurnTable_Loop", 1, "", 5, "", true, false, false)
end

function _M._to_65_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	return _doBehaviourTail_4(flow, 65, 1038162, 1038162, 0)
end

function _M._to_66_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	return _doBehaviourTail_4(flow, 66, 1038163, 1038163, 0)
end

function _M._to_67_0(flow)
	local _1 = _C(69, "RandomInteger", flow, 0, 100)
	local _0 = _1 <= 50

	if _0 then
		return _M._to_65_0(flow)
	end

	return _M._to_66_0(flow)
end

function _M._to_70_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_0(flow, 70, 0, 16230301, 0, "", 5, false, 0)
end

function _M._to_71_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 71, 0, "Behav_Love", 5, "", 5, "", false, false, false)
end

function _M._to_72_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	return _doBehaviourTail_4(flow, 72, 1038120, 1038120, 0)
end

function _M._to_73_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 73, 0, "Skill_TurnTable_Loop", 1, "", 5, "", true, false, false)
end

function _M._to_74_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	return _doBehaviourTail_4(flow, 74, 1038115, 1038117, 0)
end

function _M._to_75_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 75, 0, "IdleSpecial", 2, "", 5, "", true, false, false)
end

function _M._to_76_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	return _doBehaviourTail_4(flow, 76, 1038162, 1038162, 0)
end

function _M._to_77_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	return _doBehaviourTail_4(flow, 77, 1038163, 1038163, 0)
end

function _M._to_78_0(flow)
	local _1 = _C(80, "RandomInteger", flow, 0, 100)
	local _0 = _1 <= 50

	if _0 then
		return _M._to_76_0(flow)
	end

	return _M._to_77_0(flow)
end

function _M._to_81_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_0(flow, 81, 0, 16230304, 0, "", 5, false, 0)
end

function _M._to_83_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_2(flow, 83, "Surprise", 5)
end

function _M._to_84_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 84, 0, "Skill_TurnTable_Loop", 1, "", 5, "", true, false, false)
end

function _M._to_85_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	return _doBehaviourTail_4(flow, 85, 1038115, 1038117, 0)
end

function _M._to_86_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 86, 0, "Behav_DoubtLoop", 2, "", 5, "", true, false, false)
end

return _M
