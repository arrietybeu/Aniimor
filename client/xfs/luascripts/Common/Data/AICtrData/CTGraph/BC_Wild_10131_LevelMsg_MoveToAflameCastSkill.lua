-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10131_LevelMsg_MoveToAflameCastSkill.lua

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
		return _M._to_28_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 0 then
		return true
	end

	if nodeId == 1 then
		return _M._to_3_0(flow)
	end

	if nodeId == 2 then
		return _M._to_0_0(flow)
	end

	if nodeId == 3 then
		return _M._to_2_0(flow)
	end

	if nodeId == 5 then
		return _M._to_33_0(flow)
	end

	if nodeId == 19 then
		return _M._to_22_0(flow)
	end

	if nodeId == 20 then
		return _M._to_19_0(flow)
	end

	if nodeId == 22 then
		return true
	end

	if nodeId == 23 then
		return _M._to_20_0(flow)
	end

	if nodeId == 24 then
		return _M._to_42_0(flow)
	end

	if nodeId == 36 then
		return _M._to_40_0(flow)
	end

	if nodeId == 37 then
		return _M._to_36_0(flow)
	end

	if nodeId == 38 then
		return _M._to_37_0(flow)
	end

	if nodeId == 40 then
		return true
	end

	if nodeId == 46 then
		return _M._to_49_0(flow)
	end

	if nodeId == 47 then
		return _M._to_46_0(flow)
	end

	if nodeId == 48 then
		return _M._to_47_0(flow)
	end

	if nodeId == 49 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_0_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _C(4, "CheckCanUseSkill", flow, 0, 11310110)

	if _0 then
		flow:setActive()
		_C(0, "DoBehaviour", flow, "PBT_CastSkill")

		local _1 = _M._get_31_1(flow)

		return _doBehaviourTail_0(flow, 0, 0, 11310110, _1, "", 5, false, 0)
	else
		flow:setActiveFail()
	end
end

function _M._to_1_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_1(flow, 1, "Dizzy", 2.5)
end

function _M._to_2_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_31_1(flow)

	return _doBehaviourTail_2(flow, 2, _0, 2, 5, true, 0, 10, 0, 2, false, false)
end

function _M._to_3_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	return _doBehaviourTail_3(flow, 3, 1)
end

function _M._to_5_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_31_1(flow)

	return _doBehaviourTail_4(flow, 5, _0, 0, false)
end

function _M._to_19_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_31_1(flow)

	return _doBehaviourTail_2(flow, 19, _0, 2, 5, true, 0, 10, 0, 2, false, false)
end

function _M._to_20_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	return _doBehaviourTail_3(flow, 20, 1)
end

function _M._to_22_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _C(21, "CheckCanUseSkill", flow, 0, 11310410)

	if _0 then
		flow:setActive()
		_C(22, "DoBehaviour", flow, "PBT_CastSkill")

		local _1 = _M._get_31_1(flow)

		return _doBehaviourTail_0(flow, 22, 0, 11310410, _1, "", 5, false, 0)
	else
		flow:setActiveFail()
	end
end

function _M._to_23_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_1(flow, 23, "Angry", 2.5)
end

function _M._to_24_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_31_1(flow)

	return _doBehaviourTail_4(flow, 24, _0, 0, false)
end

function _M._to_28_0(flow)
	local _0 = _M._get_14_2(flow)

	if _0 then
		return _M._to_5_0(flow)
	end

	local _1 = _M._get_18_2(flow)

	if _1 then
		return _M._to_24_0(flow)
	end
end

function _M._to_33_0(flow)
	local _1 = _C(35, "RandomInteger", flow, 0, 1)
	local _0 = _1 > 0.5

	if _0 then
		return _M._to_1_0(flow)
	end

	return _M._to_38_0(flow)
end

function _M._to_36_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _C(39, "CheckCanUseSkill", flow, 0, 11310110)

	if _0 then
		flow:setActive()
		_C(36, "DoBehaviour", flow, "PBT_CastSkill")

		local _1 = _M._get_31_1(flow)

		return _doBehaviourTail_0(flow, 36, 0, 11310110, _1, "", 5, false, 0)
	else
		flow:setActiveFail()
	end
end

function _M._to_37_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_31_1(flow)

	return _doBehaviourTail_2(flow, 37, _0, 2, 5, true, 0, 10, 0, 2, false, false)
end

function _M._to_38_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	return _doBehaviourTail_3(flow, 38, 1)
end

function _M._to_40_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_1(flow, 40, "Furious", 2.5)
end

function _M._to_42_0(flow)
	local _1 = _C(44, "RandomInteger", flow, 0, 1)
	local _0 = _1 > 0.5

	if _0 then
		return _M._to_23_0(flow)
	end

	return _M._to_48_0(flow)
end

function _M._to_46_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_31_1(flow)

	return _doBehaviourTail_2(flow, 46, _0, 2, 5, true, 0, 10, 0, 2, false, false)
end

function _M._to_47_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	return _doBehaviourTail_3(flow, 47, 1)
end

function _M._to_48_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_1(flow, 48, "Furious", 2.5)
end

function _M._to_49_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _C(45, "CheckCanUseSkill", flow, 0, 11310410)

	if _0 then
		flow:setActive()
		_C(49, "DoBehaviour", flow, "PBT_CastSkill")

		local _1 = _M._get_31_1(flow)

		return _doBehaviourTail_0(flow, 49, 0, 11310410, _1, "", 5, false, 0)
	else
		flow:setActiveFail()
	end
end

function _M._get_7_2(flow)
	local _4 = _M._get_30_2(flow)
	local _0 = _C(10, "CheckHasChemState", flow, _4, "STATE_AFLAME_KEY")

	if not _0 then
		return false
	end

	local _3 = _M._get_30_2(flow)
	local _2 = _C(9, "GetDistance", flow, _3, 0, false)
	local _1 = _2 <= 24

	if not _1 then
		return false
	end

	return true
end

function _M._get_14_2(flow)
	local _2 = _M._get_30_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _0 = not _3

	if not _0 then
		return false
	end

	local _1 = _C(11, "CheckCanUseSkill", flow, 0, 11310110)

	if not _1 then
		return false
	end

	return true
end

function _M._get_18_2(flow)
	local _2 = _M._get_30_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _0 = not _3

	if not _0 then
		return false
	end

	local _1 = _C(15, "CheckCanUseSkill", flow, 0, 11310410)

	if not _1 then
		return false
	end

	return true
end

function _M._get_26_1(flow)
	local _0 = _M._get_30_3(flow)

	return _C(26, "SelectOneByRandom", flow, _0)
end

function _M._get_30_2(flow)
	return flow:getCache(30, "__iterItem")
end

function _M._get_30_3(flow)
	local _0 = _C(32, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(30, "__iterItem", v)

		if _M._get_7_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_31_1(flow)
	local _0 = flow:getCache(31, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_26_1(flow)

	flow:setCache(31, "1", _0)

	return _0
end

return _M
