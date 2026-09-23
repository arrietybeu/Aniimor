-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10621_dashuizhang.lua

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

local function _doBehaviourTail_1(flow, nodeId, value0, value1, value2)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("firstDialogueId", value0)
	agent:addSubTreeLocalParam("lastDialogueId", value1)
	agent:addSubTreeLocalParam("tWaitTime", value2)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_2(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8)
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
	return _M._to_46_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 13 then
		return _M._to_15_0(flow)
	end

	if nodeId == 15 then
		return true
	end

	if nodeId == 21 then
		return _M._to_13_0(flow)
	end

	if nodeId == 22 then
		return _M._to_21_0(flow)
	end

	if nodeId == 23 then
		return _M._to_24_0(flow)
	end

	if nodeId == 24 then
		return _M._to_25_0(flow)
	end

	if nodeId == 25 then
		return _M._to_47_0(flow)
	end

	if nodeId == 29 then
		return _M._to_30_0(flow)
	end

	if nodeId == 30 then
		return _M._to_33_0(flow)
	end

	if nodeId == 33 then
		return _M._to_48_0(flow)
	end

	if nodeId == 34 then
		return _M._to_38_0(flow)
	end

	if nodeId == 37 then
		return _M._to_34_0(flow)
	end

	if nodeId == 38 then
		return _M._to_49_0(flow)
	end

	if nodeId == 47 then
		return true
	end

	if nodeId == 48 then
		return true
	end

	if nodeId == 49 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_13_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_4_1(flow)

	return _doBehaviourTail_0(flow, 13, 0, 16230301, _0, "", 5, false, 0)
end

function _M._to_14_0(flow)
	local _3 = _C(39, "RandomInteger", flow, 0, 100)
	local _0 = _3 <= 70

	if _0 then
		return _M._to_22_0(flow)
	end

	local _4 = _C(41, "RandomInteger", flow, 0, 100)
	local _1 = _4 <= 70

	if _1 then
		return _M._to_23_0(flow)
	end

	local _5 = _C(43, "RandomInteger", flow, 0, 100)
	local _2 = _5 <= 70

	if _2 then
		return _M._to_29_0(flow)
	end

	return _M._to_37_0(flow)
end

function _M._to_15_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	return _doBehaviourTail_1(flow, 15, 1038139, 1038140, 0)
end

function _M._to_21_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	local _0 = _M._get_20_2(flow)
	local _1 = _M._get_20_2(flow)

	return _doBehaviourTail_2(flow, 21, 0, "Behav_Happy", _0, "Happy", _1, "", true, false, false)
end

function _M._to_22_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_4_1(flow)

	return _doBehaviourTail_3(flow, 22, _0, 0, false)
end

function _M._to_23_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_4_1(flow)

	return _doBehaviourTail_3(flow, 23, _0, 0, false)
end

function _M._to_24_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	local _0 = _M._get_27_2(flow)
	local _1 = _M._get_27_2(flow)

	return _doBehaviourTail_2(flow, 24, _0, "Behav_HAppy", 5, "Laugh", _1, "", true, false, false)
end

function _M._to_25_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_4_1(flow)

	return _doBehaviourTail_0(flow, 25, 0, 16230302, _0, "", 5, false, 0)
end

function _M._to_29_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_4_1(flow)

	return _doBehaviourTail_3(flow, 29, _0, 0, false)
end

function _M._to_30_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	local _0 = _M._get_32_2(flow)
	local _1 = _M._get_32_2(flow)

	return _doBehaviourTail_2(flow, 30, _0, "Behav_Angry", 5, "Surprise", _1, "", true, false, false)
end

function _M._to_33_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_4_1(flow)

	return _doBehaviourTail_0(flow, 33, 0, 16230303, _0, "", 5, false, 0)
end

function _M._to_34_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	local _0 = _M._get_36_2(flow)
	local _1 = _M._get_36_2(flow)

	return _doBehaviourTail_2(flow, 34, _0, "Behav_Angry", 5, "Angry", _1, "", true, false, false)
end

function _M._to_37_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_4_1(flow)

	return _doBehaviourTail_3(flow, 37, _0, 0, false)
end

function _M._to_38_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_4_1(flow)

	return _doBehaviourTail_0(flow, 38, 0, 16230304, _0, "", 5, false, 0)
end

function _M._to_46_0(flow)
	local _1 = _M._get_2_3(flow)
	local _2 = not _1 or next(_1) == nil
	local _0 = not _2

	if _0 then
		return _M._to_14_0(flow)
	end
end

function _M._to_47_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	return _doBehaviourTail_1(flow, 47, 1038139, 1038140, 0)
end

function _M._to_48_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	return _doBehaviourTail_1(flow, 48, 1038139, 1038140, 0)
end

function _M._to_49_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	return _doBehaviourTail_1(flow, 49, 1038139, 1038140, 0)
end

function _M._get_2_2(flow)
	return flow:getCache(2, "__iterItem")
end

function _M._get_2_3(flow)
	local _0 = _C(5, "GetAoiEntityTableByLevel", flow, 0, 10, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(2, "__iterItem", v)

		if _M._get_18_3(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_4_1(flow)
	local _0 = flow:getCache(4, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_12_1(flow)

	flow:setCache(4, "1", _0)

	return _0
end

function _M._get_12_1(flow)
	local _0 = _M._get_2_3(flow)

	return _C(12, "SelectOneByRandom", flow, _0)
end

function _M._get_18_3(flow)
	local _6 = _M._get_2_2(flow)
	local _7 = _C(16, "GetDistance", flow, _6, 0, false)
	local _0 = _7 <= 5

	if not _0 then
		return false
	end

	local _3 = _M._get_2_2(flow)
	local _4 = _C(6, "GetPuppetData", flow, _3, "id", true, 0)
	local _1 = _4 == 11062100

	if not _1 then
		return false
	end

	local _5 = _M._get_2_2(flow)
	local _2 = _C(50, "HasEntityTag", flow, _5, "TE_Par_10621_Fight")

	if not _2 then
		return false
	end

	return true
end

function _M._get_20_2(flow)
	return _C(20, "RandomInteger", flow, 1, 5)
end

function _M._get_27_2(flow)
	return _C(27, "RandomInteger", flow, 1, 5)
end

function _M._get_32_2(flow)
	return _C(32, "RandomInteger", flow, 1, 5)
end

function _M._get_36_2(flow)
	return _C(36, "RandomInteger", flow, 1, 5)
end

return _M
