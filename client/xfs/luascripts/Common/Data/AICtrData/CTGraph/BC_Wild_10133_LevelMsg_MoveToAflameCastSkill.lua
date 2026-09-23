-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10133_LevelMsg_MoveToAflameCastSkill.lua

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
		return _M._to_26_0(flow)
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
		return _M._to_31_0(flow)
	end

	if nodeId == 18 then
		return _M._to_21_0(flow)
	end

	if nodeId == 19 then
		return _M._to_18_0(flow)
	end

	if nodeId == 21 then
		return true
	end

	if nodeId == 22 then
		return _M._to_19_0(flow)
	end

	if nodeId == 23 then
		return _M._to_38_0(flow)
	end

	if nodeId == 34 then
		return _M._to_46_0(flow)
	end

	if nodeId == 35 then
		return _M._to_34_0(flow)
	end

	if nodeId == 36 then
		return _M._to_35_0(flow)
	end

	if nodeId == 42 then
		return _M._to_44_0(flow)
	end

	if nodeId == 43 then
		return _M._to_42_0(flow)
	end

	if nodeId == 44 then
		return true
	end

	if nodeId == 45 then
		return _M._to_43_0(flow)
	end

	if nodeId == 46 then
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

	local _0 = _C(4, "CheckCanUseSkill", flow, 0, 11330110)

	if _0 then
		flow:setActive()
		_C(0, "DoBehaviour", flow, "PBT_CastSkill")

		local _1 = _M._get_29_1(flow)

		return _doBehaviourTail_0(flow, 0, 0, 11330110, _1, "", 5, false, 0)
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

	local _0 = _M._get_29_1(flow)

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

	local _0 = _M._get_29_1(flow)

	return _doBehaviourTail_4(flow, 5, _0, 0, false)
end

function _M._to_18_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_29_1(flow)

	return _doBehaviourTail_2(flow, 18, _0, 2, 5, true, 0, 10, 0, 2, false, false)
end

function _M._to_19_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	return _doBehaviourTail_3(flow, 19, 1)
end

function _M._to_21_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _C(20, "CheckCanUseSkill", flow, 0, 11330410)

	if _0 then
		flow:setActive()
		_C(21, "DoBehaviour", flow, "PBT_CastSkill")

		local _1 = _M._get_29_1(flow)

		return _doBehaviourTail_0(flow, 21, 0, 11330410, _1, "", 5, false, 0)
	else
		flow:setActiveFail()
	end
end

function _M._to_22_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_1(flow, 22, "Angry", 2.5)
end

function _M._to_23_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_29_1(flow)

	return _doBehaviourTail_4(flow, 23, _0, 0, false)
end

function _M._to_26_0(flow)
	local _0 = _M._get_13_2(flow)

	if _0 then
		return _M._to_5_0(flow)
	end

	local _1 = _M._get_17_2(flow)

	if _1 then
		return _M._to_23_0(flow)
	end
end

function _M._to_31_0(flow)
	do return _M._to_1_0(flow) end

	local _1 = _C(33, "RandomInteger", flow, 0, 1)
	local _0 = _1 > 0.5

	if _0 then
		return _M._to_36_0(flow)
	end
end

function _M._to_34_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _C(37, "CheckCanUseSkill", flow, 0, 11330110)

	if _0 then
		flow:setActive()
		_C(34, "DoBehaviour", flow, "PBT_CastSkill")

		local _1 = _M._get_29_1(flow)

		return _doBehaviourTail_0(flow, 34, 0, 11330110, _1, "", 5, false, 0)
	else
		flow:setActiveFail()
	end
end

function _M._to_35_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_29_1(flow)

	return _doBehaviourTail_2(flow, 35, _0, 2, 5, true, 0, 10, 0, 2, false, false)
end

function _M._to_36_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	return _doBehaviourTail_3(flow, 36, 1)
end

function _M._to_38_0(flow)
	local _1 = _C(40, "RandomInteger", flow, 0, 1)
	local _0 = _1 > 0.5

	if _0 then
		return _M._to_22_0(flow)
	end

	return _M._to_45_0(flow)
end

function _M._to_42_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	return _doBehaviourTail_2(flow, 42, 0, 2, 5, true, 0, 10, 0, 2, false, false)
end

function _M._to_43_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	return _doBehaviourTail_3(flow, 43, 1)
end

function _M._to_44_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _C(41, "CheckCanUseSkill", flow, 0, 11330410)

	if _0 then
		flow:setActive()
		_C(44, "DoBehaviour", flow, "PBT_CastSkill")

		local _1 = _M._get_29_1(flow)

		return _doBehaviourTail_0(flow, 44, 0, 11330410, _1, "", 5, false, 0)
	else
		flow:setActiveFail()
	end
end

function _M._to_45_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_1(flow, 45, "Furious", 2.5)
end

function _M._to_46_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_1(flow, 46, "Furious", 2.5)
end

function _M._get_6_2(flow)
	local _4 = _M._get_28_2(flow)
	local _0 = _C(9, "CheckHasChemState", flow, _4, "STATE_AFLAME_KEY")

	if not _0 then
		return false
	end

	local _3 = _M._get_28_2(flow)
	local _2 = _C(8, "GetDistance", flow, _3, 0, false)
	local _1 = _2 <= 24

	if not _1 then
		return false
	end

	return true
end

function _M._get_13_2(flow)
	local _2 = _M._get_28_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _0 = not _3

	if not _0 then
		return false
	end

	local _1 = _C(10, "CheckCanUseSkill", flow, 0, 11330110)

	if not _1 then
		return false
	end

	return true
end

function _M._get_17_2(flow)
	local _2 = _M._get_28_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _0 = not _3

	if not _0 then
		return false
	end

	local _1 = _C(14, "CheckCanUseSkill", flow, 0, 11330410)

	if not _1 then
		return false
	end

	return true
end

function _M._get_24_1(flow)
	local _0 = _M._get_28_3(flow)

	return _C(24, "SelectOneByRandom", flow, _0)
end

function _M._get_28_3(flow)
	local _0 = _C(30, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(28, "__iterItem", v)

		if _M._get_6_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_28_2(flow)
	return flow:getCache(28, "__iterItem")
end

function _M._get_29_1(flow)
	local _0 = flow:getCache(29, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_24_1(flow)

	flow:setCache(29, "1", _0)

	return _0
end

return _M
