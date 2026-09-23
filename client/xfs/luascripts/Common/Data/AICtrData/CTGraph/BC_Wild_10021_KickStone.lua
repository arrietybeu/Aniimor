-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10021_KickStone.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
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

local function _doBehaviourTail_2(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value0)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value1)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_3(flow, nodeId, value0, value1, value2)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tTgtId", value0)
	agent:addSubTreeLocalParam("tTargetAtYawDegree", value1)
	agent:addSubTreeLocalParam("tInstant", value2)
	flow:setContinue(nodeId)

	return true
end

function _M.executeTickLodTrigger(flow)
	return _M._to_58_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 29 then
		return _M._to_32_0(flow)
	end

	if nodeId == 32 then
		return _M._to_71_0(flow)
	end

	if nodeId == 41 then
		return _M._to_42_0(flow)
	end

	if nodeId == 42 then
		return _M._to_29_0(flow)
	end

	if nodeId == 62 then
		return _M._to_65_0(flow)
	end

	if nodeId == 63 then
		return _M._to_62_0(flow)
	end

	if nodeId == 65 then
		return _M._to_72_0(flow)
	end

	if nodeId == 66 then
		return _M._to_63_0(flow)
	end

	if nodeId == 69 then
		return _M._to_41_0(flow)
	end

	if nodeId == 70 then
		return _M._to_66_0(flow)
	end

	if nodeId == 71 then
		return true
	end

	if nodeId == 72 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_29_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_27_1(flow)

	return _doBehaviourTail_0(flow, 29, _0, 0.2, 5, true, 0, 10, 0, 2, false, false)
end

function _M._to_32_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _C(56, "CheckCanUseSkill", flow, 0, 10210220)

	if _0 then
		flow:setActive()
		_C(32, "DoBehaviour", flow, "PBT_CastSkill")

		return _doBehaviourTail_1(flow, 32, 0, 10210220, 0, "", 5, false, 0)
	else
		flow:setActiveFail()
	end
end

function _M._to_41_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_2(flow, 41, "Proud", 2.5)
end

function _M._to_42_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 1)
	flow:setContinue(42)

	return true
end

function _M._to_58_0(flow)
	local _0 = _M._get_52_2(flow)

	if _0 then
		return _M._to_69_0(flow)
	end

	local _1 = _M._get_61_2(flow)

	if _1 then
		return _M._to_70_0(flow)
	end
end

function _M._to_62_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_27_1(flow)

	return _doBehaviourTail_0(flow, 62, _0, 0.2, 5, true, 0, 10, 0, 2, false, false)
end

function _M._to_63_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 1)
	flow:setContinue(63)

	return true
end

function _M._to_65_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _C(64, "CheckCanUseSkill", flow, 0, 10210230)

	if _0 then
		flow:setActive()
		_C(65, "DoBehaviour", flow, "PBT_CastSkill")

		return _doBehaviourTail_1(flow, 65, 0, 10210230, 0, "", 5, false, 0)
	else
		flow:setActiveFail()
	end
end

function _M._to_66_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_2(flow, 66, "Proud", 2.5)
end

function _M._to_69_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_27_1(flow)

	return _doBehaviourTail_3(flow, 69, _0, 0, false)
end

function _M._to_70_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_27_1(flow)

	return _doBehaviourTail_3(flow, 70, _0, 0, false)
end

function _M._to_71_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_2(flow, 71, "Happy", 2.5)
end

function _M._to_72_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_2(flow, 72, "Happy", 2.5)
end

function _M._get_22_2(flow)
	local _2 = _M._get_37_2(flow)
	local _0 = _C(19, "HasEntityTag", flow, _2, "TE_Env_10021_KickStone")

	if not _0 then
		return false
	end

	local _3 = _M._get_37_2(flow)
	local _4 = _C(20, "GetDistance", flow, _3, 0, false)
	local _1 = _4 <= 10

	if not _1 then
		return false
	end

	return true
end

function _M._get_25_1(flow)
	local _0 = _M._get_37_3(flow)

	return _C(25, "SelectOneByRandom", flow, _0)
end

function _M._get_27_1(flow)
	local _0 = flow:getCache(27, "Stone")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_25_1(flow)

	flow:setCache(27, "Stone", _0)

	return _0
end

function _M._get_37_2(flow)
	return flow:getCache(37, "__iterItem")
end

function _M._get_37_3(flow)
	local _0 = _C(16, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(37, "__iterItem", v)

		if _M._get_22_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_52_2(flow)
	local _2 = _M._get_37_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _0 = not _3

	if not _0 then
		return false
	end

	local _1 = _C(51, "CheckCanUseSkill", flow, 0, 10210220)

	if not _1 then
		return false
	end

	return true
end

function _M._get_61_2(flow)
	local _2 = _M._get_37_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _0 = not _3

	if not _0 then
		return false
	end

	local _1 = _C(54, "CheckCanUseSkill", flow, 0, 10210230)

	if not _1 then
		return false
	end

	return true
end

return _M
