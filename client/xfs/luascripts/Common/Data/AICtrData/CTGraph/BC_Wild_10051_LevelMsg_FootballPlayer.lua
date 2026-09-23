-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10051_LevelMsg_FootballPlayer.lua

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

local function _doBehaviourTail_1(flow, nodeId, value0, value1, value2, value3, value4, value5, value6)
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

local function _doBehaviourTail_2(flow, nodeId, value0)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_3(flow, nodeId, value0, value1, value2, value3)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tAnimationTimeout", value0)
	agent:addSubTreeLocalParam("tTimelineTag", value1)
	agent:addSubTreeLocalParam("tNeedLoop", value2)
	agent:addSubTreeLocalParam("tPlayOnce", value3)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_4(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tAnimationKey", value0)
	agent:addSubTreeLocalParam("tAnimationTimeout", value1)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value2)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value3)
	agent:addSubTreeLocalParam("tTimelineTag", value4)
	agent:addSubTreeLocalParam("tNeedLoop", value5)
	agent:addSubTreeLocalParam("tTgtId", value6)
	agent:addSubTreeLocalParam("tTargetAtYawDegree", value7)
	flow:setContinue(nodeId)

	return true
end

function _M.executeTickLodTrigger(flow)
	return _M._to_33_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 34 then
		return true
	end

	if nodeId == 38 then
		return _M._to_39_0(flow)
	end

	if nodeId == 39 then
		return _M._to_51_0(flow)
	end

	if nodeId == 40 then
		return _M._to_73_0(flow)
	end

	if nodeId == 44 then
		return _M._to_42_0(flow)
	end

	if nodeId == 46 then
		return _M._to_53_0(flow)
	end

	if nodeId == 47 then
		return _M._to_43_0(flow)
	end

	if nodeId == 49 then
		return _M._to_68_0(flow)
	end

	if nodeId == 51 then
		return _M._to_44_0(flow)
	end

	if nodeId == 52 then
		return _M._to_64_0(flow)
	end

	if nodeId == 61 then
		return _M._to_83_0(flow)
	end

	if nodeId == 64 then
		return _M._to_71_0(flow)
	end

	if nodeId == 68 then
		return _M._to_70_0(flow)
	end

	if nodeId == 70 then
		return _M._to_66_0(flow)
	end

	if nodeId == 71 then
		return _M._to_62_0(flow)
	end

	if nodeId == 72 then
		return _M._to_85_0(flow)
	end

	if nodeId == 76 then
		return _M._to_82_0(flow)
	end

	if nodeId == 78 then
		return _M._to_79_0(flow)
	end

	if nodeId == 81 then
		return _M._to_84_0(flow)
	end

	if nodeId == 82 then
		return _M._to_81_0(flow)
	end

	if nodeId == 83 then
		return _M._to_47_0(flow)
	end

	if nodeId == 84 then
		return _M._to_78_0(flow)
	end

	if nodeId == 85 then
		return _M._to_61_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_9_0(flow)
	local _0 = _M._get_23_1(flow)

	if _0 then
		return _M._to_18_0(flow)
	end
end

function _M._to_18_0(flow)
	local _0 = _M._get_13_2(flow)

	if _0 then
		flow:setActive()
		_A(flow, "AddAITag", 0, "Attack01")

		return true
	end

	local _1 = _M._get_12_2(flow)

	if _1 then
		return _M._to_40_0(flow)
	end

	local _2 = _M._get_10_2(flow)

	if _2 then
		return _M._to_38_0(flow)
	end

	local _3 = _M._get_11_2(flow)

	if _3 then
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "Attack02")

		return true
	end
end

function _M._to_33_0(flow)
	local _0 = _M._get_8_2(flow)

	if _0 then
		return _M._to_9_0(flow)
	end

	local _2 = _M._get_8_2(flow)
	local _1 = not _2

	if _1 then
		return _M._to_34_0(flow)
	end
end

function _M._to_34_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_36_1(flow)

	if _0 then
		flow:setActive()
		_C(34, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_5_2(flow)

		return _doBehaviourTail_0(flow, 34, _1, 15, 10, true, 7, 2, 0, 1, false, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_38_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_37_2(flow)

	return _doBehaviourTail_0(flow, 38, _0, 1.5, 10, true, 7, 2, 0, 1, false, false)
end

function _M._to_39_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_23_1(flow)

	if _0 then
		flow:setActive()
		_C(39, "DoBehaviour", flow, "PBT_CastSkill")

		local _1 = _M._get_37_2(flow)

		return _doBehaviourTail_1(flow, 39, 0, 10510500, _1, "Love", 3, false, 0)
	else
		flow:setActiveFail()
	end
end

function _M._to_40_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_37_2(flow)

	return _doBehaviourTail_0(flow, 40, _0, 1.5, 10, true, 7, 2, 0, 1, false, false)
end

function _M._to_42_0(flow)
	flow:setActive()
	_A(flow, "AddAITag", 0, "Attack02")
	flow:setActive()
	_A(flow, "RemoveAITag", 0, "Attack01")

	return true
end

function _M._to_43_0(flow)
	flow:setActive()
	_A(flow, "AddAITag", 0, "Attack01")
	flow:setActive()
	_A(flow, "RemoveAITag", 0, "Attack02")

	return true
end

function _M._to_44_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	local _0 = _C(32, "RandomInteger", flow, 1, 2)

	return _doBehaviourTail_2(flow, 44, _0)
end

function _M._to_46_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_23_1(flow)

	if _0 then
		flow:setActive()
		_C(46, "DoBehaviour", flow, "PBT_CastSkill")

		local _1 = _M._get_37_2(flow)

		return _doBehaviourTail_1(flow, 46, 0, 10510210, _1, "", 0, false, 0)
	else
		flow:setActiveFail()
	end
end

function _M._to_47_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	local _0 = _C(48, "RandomInteger", flow, 1, 2)

	return _doBehaviourTail_2(flow, 47, _0)
end

function _M._to_49_0(flow)
	if not _B(flow, "PBT_Com_Happy_New") then
		return
	end

	return _doBehaviourTail_3(flow, 49, 5, "", false, true)
end

function _M._to_51_0(flow)
	if not _B(flow, "PBT_Com_Happy_New") then
		return
	end

	return _doBehaviourTail_3(flow, 51, 5, "", false, true)
end

function _M._to_52_0(flow)
	if not _B(flow, "PBT_Com_Love") then
		return
	end

	local _0 = _M._get_37_2(flow)

	return _doBehaviourTail_4(flow, 52, "Behav_Love", 5, "", 5, "", false, _0, 0)
end

function _M._to_53_0(flow)
	local _1 = _C(54, "RandomInteger", flow, 0, 1)
	local _0 = _1 > 0.6

	if _0 then
		return _M._to_49_0(flow)
	end

	return _M._to_58_0(flow)
end

function _M._to_58_0(flow)
	local _1 = _C(59, "RandomInteger", flow, 0, 1)
	local _0 = _1 > 0.3

	if _0 then
		return _M._to_52_0(flow)
	end

	return _M._to_72_0(flow)
end

function _M._to_61_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_37_2(flow)

	return _doBehaviourTail_1(flow, 61, 0, 10510500, _0, "", 0, false, 0)
end

function _M._to_62_0(flow)
	flow:setActive()
	_A(flow, "AddAITag", 0, "Attack01")
	flow:setActive()
	_A(flow, "RemoveAITag", 0, "Attack02")

	return true
end

function _M._to_64_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	local _0 = _C(65, "RandomInteger", flow, 1, 2)

	return _doBehaviourTail_2(flow, 64, _0)
end

function _M._to_66_0(flow)
	flow:setActive()
	_A(flow, "AddAITag", 0, "Attack01")
	flow:setActive()
	_A(flow, "RemoveAITag", 0, "Attack02")

	return true
end

function _M._to_68_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	local _0 = _C(69, "RandomInteger", flow, 1, 2)

	return _doBehaviourTail_2(flow, 68, _0)
end

function _M._to_70_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_37_2(flow)

	return _doBehaviourTail_0(flow, 70, _0, 1.5, 5, true, 7, 99999, 0, 0, false, false)
end

function _M._to_71_0(flow)
	if not _B(flow, "PBT_MoveAroundTarget") then
		return
	end

	local _0 = _M._get_37_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tRadius", 4)
	flow.__agent:addSubTreeLocalParam("tSpeed", 7)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tClockwise", false)
	flow.__agent:addSubTreeLocalParam("tTimeout", 10)
	flow:setContinue(71)

	return true
end

function _M._to_72_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_37_2(flow)

	return _doBehaviourTail_0(flow, 72, _0, 1.5, 10, true, 7, 2, 0, 1, false, false)
end

function _M._to_73_0(flow)
	local _1 = _C(74, "RandomInteger", flow, 0, 1)
	local _0 = _1 > 0.5

	if _0 then
		return _M._to_46_0(flow)
	end

	return _M._to_76_0(flow)
end

function _M._to_76_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_37_2(flow)

	return _doBehaviourTail_1(flow, 76, 0, 10510500, _0, "", 0, false, 0)
end

function _M._to_78_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	local _0 = _C(77, "RandomInteger", flow, 1, 2)

	return _doBehaviourTail_2(flow, 78, _0)
end

function _M._to_79_0(flow)
	flow:setActive()
	_A(flow, "AddAITag", 0, "Attack01")
	flow:setActive()
	_A(flow, "RemoveAITag", 0, "Attack02")

	return true
end

function _M._to_81_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_37_2(flow)

	return _doBehaviourTail_1(flow, 81, 0, 10510500, _0, "", 0, false, 0)
end

function _M._to_82_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	return _doBehaviourTail_0(flow, 82, 0, 1.5, 10, true, 7, 2, 0, 1, false, false)
end

function _M._to_83_0(flow)
	if not _B(flow, "PBT_Com_Love") then
		return
	end

	local _0 = _M._get_37_2(flow)

	return _doBehaviourTail_4(flow, 83, "Behav_Love", 5, "", 5, "", false, _0, 0)
end

function _M._to_84_0(flow)
	if not _B(flow, "PBT_Com_Happy_New") then
		return
	end

	return _doBehaviourTail_3(flow, 84, 5, "", false, true)
end

function _M._to_85_0(flow)
	if not _B(flow, "PBT_Com_Alert") then
		return
	end

	local _0 = _M._get_37_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow:setContinue(85)

	return true
end

function _M._get_1_2(flow)
	local _1 = _M._get_4_2(flow)
	local _0 = _C(0, "HasEntityTag", flow, _1, "TE_Env_UniversalMark_A")

	if not _0 then
		return false
	end

	if false then
		return false
	end

	return true
end

function _M._get_4_2(flow)
	return flow:getCache(4, "__iterItem")
end

function _M._get_4_3(flow)
	local _0 = _C(2, "GetAoiEntityTableByLevel", flow, 0, 100, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(4, "__iterItem", v)

		if _M._get_1_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_5_2(flow)
	local _0 = _M._get_4_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(5, "__iterItem", v)

		_1 = _M._get_6_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_6_3(flow)
	local _0 = flow:getCache(5, "__iterItem")

	return _C(6, "GetDistance", flow, _0, 0, false)
end

function _M._get_8_2(flow)
	local _1 = _M._get_5_2(flow)
	local _0 = _C(7, "GetDistance", flow, _1, 0, false)

	return _0 < 80
end

function _M._get_10_2(flow)
	local _0 = _M._get_16_1(flow)

	if not _0 then
		return false
	end

	local _1 = _M._get_14_2(flow)

	if not _1 then
		return false
	end

	return true
end

function _M._get_11_2(flow)
	local _0 = _M._get_17_2(flow)

	if not _0 then
		return false
	end

	local _1 = _M._get_14_2(flow)

	if not _1 then
		return false
	end

	return true
end

function _M._get_12_2(flow)
	local _0 = _M._get_17_2(flow)

	if not _0 then
		return false
	end

	local _1 = _M._get_15_1(flow)

	if not _1 then
		return false
	end

	return true
end

function _M._get_13_2(flow)
	local _0 = _M._get_16_1(flow)

	if not _0 then
		return false
	end

	local _1 = _M._get_15_1(flow)

	if not _1 then
		return false
	end

	return true
end

function _M._get_14_2(flow)
	return _C(14, "HasAITag", flow, 0, "Attack02")
end

function _M._get_15_1(flow)
	local _0 = _M._get_14_2(flow)

	return not _0
end

function _M._get_16_1(flow)
	local _0 = _M._get_17_2(flow)

	return not _0
end

function _M._get_17_2(flow)
	return _C(17, "HasAITag", flow, 0, "Attack01")
end

function _M._get_22_2(flow)
	return flow:getCache(22, "__iterItem")
end

function _M._get_22_3(flow)
	local _0 = _C(20, "GetAoiEntityTableByLevel", flow, 0, 50, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(22, "__iterItem", v)

		if _M._get_25_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_23_1(flow)
	local _1 = _M._get_22_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_25_2(flow)
	local _2 = _M._get_22_2(flow)
	local _0 = _C(19, "HasEntityTag", flow, _2, "TE_Env_Ball")

	if not _0 then
		return false
	end

	local _3 = _M._get_22_2(flow)
	local _4 = _C(26, "GetDistance", flow, _3, 0, false)
	local _1 = _4 < 8

	if not _1 then
		return false
	end

	return true
end

function _M._get_31_3(flow)
	local _0 = flow:getCache(37, "__iterItem")

	return _C(31, "GetDistance", flow, _0, 0, false)
end

function _M._get_36_1(flow)
	local _0 = _M._get_5_2(flow)

	return _C(36, "CheckEntityExist", flow, _0)
end

function _M._get_37_2(flow)
	local _0 = _M._get_22_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(37, "__iterItem", v)

		_1 = _M._get_31_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

return _M
