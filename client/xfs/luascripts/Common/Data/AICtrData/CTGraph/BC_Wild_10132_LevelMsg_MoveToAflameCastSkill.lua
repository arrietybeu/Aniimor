-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10132_LevelMsg_MoveToAflameCastSkill.lua

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

local function _doBehaviourTail_1(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value0)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value1)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_2(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8, value9)
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

local function _doBehaviourTail_3(flow, nodeId, value0)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_4(flow, nodeId, value0, value1, value2)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tTgtId", value0)
	agent:addSubTreeLocalParam("tTargetAtYawDegree", value1)
	agent:addSubTreeLocalParam("tInstant", value2)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_64_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 33 then
		return _M._to_39_0(flow)
	end

	if nodeId == 34 then
		return _M._to_36_0(flow)
	end

	if nodeId == 35 then
		return _M._to_33_0(flow)
	end

	if nodeId == 36 then
		return _M._to_35_0(flow)
	end

	if nodeId == 38 then
		return _M._to_66_0(flow)
	end

	if nodeId == 39 then
		return true
	end

	if nodeId == 51 then
		return _M._to_54_0(flow)
	end

	if nodeId == 52 then
		return _M._to_51_0(flow)
	end

	if nodeId == 54 then
		return _M._to_57_0(flow)
	end

	if nodeId == 55 then
		return _M._to_52_0(flow)
	end

	if nodeId == 56 then
		return _M._to_77_0(flow)
	end

	if nodeId == 57 then
		return true
	end

	if nodeId == 69 then
		return _M._to_73_0(flow)
	end

	if nodeId == 70 then
		return _M._to_69_0(flow)
	end

	if nodeId == 72 then
		return true
	end

	if nodeId == 73 then
		return _M._to_72_0(flow)
	end

	if nodeId == 74 then
		return _M._to_70_0(flow)
	end

	if nodeId == 78 then
		return _M._to_82_0(flow)
	end

	if nodeId == 79 then
		return true
	end

	if nodeId == 80 then
		return _M._to_79_0(flow)
	end

	if nodeId == 82 then
		return _M._to_83_0(flow)
	end

	if nodeId == 83 then
		return _M._to_80_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_33_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _C(37, "CheckCanUseSkill", flow, 0, 11320110)

	if _0 then
		flow:setActive()
		_C(33, "DoBehaviour", flow, "PBT_CastSkill")

		local _1 = _M._get_60_1(flow)

		return _doBehaviourTail_0(flow, 33, 0, 11320110, _1, "", 5, false, 0)
	else
		flow:setActiveFail()
	end
end

function _M._to_34_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_1(flow, 34, "Dizzy", 2.5)
end

function _M._to_35_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_60_1(flow)

	return _doBehaviourTail_2(flow, 35, _0, 2, 5, true, 0, 10, 0, 2, false, false)
end

function _M._to_36_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	return _doBehaviourTail_3(flow, 36, 1)
end

function _M._to_38_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_60_1(flow)

	return _doBehaviourTail_4(flow, 38, _0, 0, false)
end

function _M._to_39_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_1(flow, 39, "Happy", 2.5)
end

function _M._to_51_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_60_1(flow)

	return _doBehaviourTail_2(flow, 51, _0, 2, 5, true, 0, 10, 0, 2, false, false)
end

function _M._to_52_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	return _doBehaviourTail_3(flow, 52, 1)
end

function _M._to_54_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _C(53, "CheckCanUseSkill", flow, 0, 11320410)

	if _0 then
		flow:setActive()
		_C(54, "DoBehaviour", flow, "PBT_CastSkill")

		local _1 = _M._get_60_1(flow)

		return _doBehaviourTail_0(flow, 54, 0, 11320410, _1, "", 5, false, 0)
	else
		flow:setActiveFail()
	end
end

function _M._to_55_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_1(flow, 55, "Angry", 2.5)
end

function _M._to_56_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_60_1(flow)

	return _doBehaviourTail_4(flow, 56, _0, 0, false)
end

function _M._to_57_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_1(flow, 57, "Happy", 2.5)
end

function _M._to_64_0(flow)
	local _0 = _M._get_46_2(flow)

	if _0 then
		return _M._to_38_0(flow)
	end

	local _1 = _M._get_50_2(flow)

	if _1 then
		return _M._to_56_0(flow)
	end
end

function _M._to_66_0(flow)
	local _1 = _C(67, "RandomInteger", flow, 0, 1)
	local _0 = _1 > 0.5

	if _0 then
		return _M._to_34_0(flow)
	end

	return _M._to_74_0(flow)
end

function _M._to_69_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_60_1(flow)

	return _doBehaviourTail_2(flow, 69, _0, 2, 5, true, 0, 10, 0, 2, false, false)
end

function _M._to_70_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	return _doBehaviourTail_3(flow, 70, 1)
end

function _M._to_72_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_1(flow, 72, "Happy", 2.5)
end

function _M._to_73_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _C(71, "CheckCanUseSkill", flow, 0, 11320110)

	if _0 then
		flow:setActive()
		_C(73, "DoBehaviour", flow, "PBT_CastSkill")

		local _1 = _M._get_60_1(flow)

		return _doBehaviourTail_0(flow, 73, 0, 11320110, _1, "", 5, false, 0)
	else
		flow:setActiveFail()
	end
end

function _M._to_74_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_1(flow, 74, "Alert", 2.5)
end

function _M._to_77_0(flow)
	local _1 = _C(76, "RandomInteger", flow, 0, 1)
	local _0 = _1 > 0.5

	if _0 then
		return _M._to_55_0(flow)
	end

	return _M._to_78_0(flow)
end

function _M._to_78_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_1(flow, 78, "Furious", 2.5)
end

function _M._to_79_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_1(flow, 79, "Happy", 2.5)
end

function _M._to_80_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _C(81, "CheckCanUseSkill", flow, 0, 11320410)

	if _0 then
		flow:setActive()
		_C(80, "DoBehaviour", flow, "PBT_CastSkill")

		local _1 = _M._get_60_1(flow)

		return _doBehaviourTail_0(flow, 80, 0, 11320410, _1, "", 5, false, 0)
	else
		flow:setActiveFail()
	end
end

function _M._to_82_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	return _doBehaviourTail_3(flow, 82, 1)
end

function _M._to_83_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_60_1(flow)

	return _doBehaviourTail_2(flow, 83, _0, 2, 5, true, 0, 10, 0, 2, false, false)
end

function _M._get_40_2(flow)
	local _4 = _M._get_62_2(flow)
	local _0 = _C(61, "CheckHasChemState", flow, _4, "STATE_AFLAME_KEY")

	if not _0 then
		return false
	end

	local _3 = _M._get_62_2(flow)
	local _2 = _C(42, "GetDistance", flow, _3, 0, false)
	local _1 = _2 <= 8

	if not _1 then
		return false
	end

	return true
end

function _M._get_46_2(flow)
	local _2 = _C(44, "IsTableEmpty", flow, nil)
	local _0 = not _2

	if not _0 then
		return false
	end

	local _1 = _C(43, "CheckCanUseSkill", flow, 0, 10510210)

	if not _1 then
		return false
	end

	return true
end

function _M._get_50_2(flow)
	local _2 = _C(48, "IsTableEmpty", flow, nil)
	local _0 = not _2

	if not _0 then
		return false
	end

	local _1 = _C(47, "CheckCanUseSkill", flow, 0, 10510500)

	if not _1 then
		return false
	end

	return true
end

function _M._get_59_1(flow)
	local _0 = _M._get_62_3(flow)

	return _C(59, "SelectOneByRandom", flow, _0)
end

function _M._get_60_1(flow)
	local _0 = flow:getCache(60, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_59_1(flow)

	flow:setCache(60, "1", _0)

	return _0
end

function _M._get_62_3(flow)
	local _0 = _C(58, "GetAoiEntityTableByLevel", flow, 0, 10, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(62, "__iterItem", v)

		if _M._get_40_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_62_2(flow)
	return flow:getCache(62, "__iterItem")
end

return _M
