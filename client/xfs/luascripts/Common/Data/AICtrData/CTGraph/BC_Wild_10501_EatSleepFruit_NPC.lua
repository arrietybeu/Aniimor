-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10501_EatSleepFruit_NPC.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8, value9)
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

local function _doBehaviourTail_1(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8, value9)
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
	return _M._to_17_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_13_1(flow)

	_A(flow, "RemoveEntityTag", _0, "TE_Env_BeUsed")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 2 then
		return _M._to_0_0(flow)
	end

	if nodeId == 10 then
		return _M._to_27_0(flow)
	end

	if nodeId == 15 then
		return _M._to_33_0(flow)
	end

	if nodeId == 20 then
		return _M._to_19_0(flow)
	end

	if nodeId == 21 then
		return _M._to_32_0(flow)
	end

	if nodeId == 22 then
		return _M._to_26_0(flow)
	end

	if nodeId == 32 then
		return true
	end

	if nodeId == 33 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_0_0(flow)
	flow:setActive()

	local _0 = _M._get_13_1(flow)

	_A(flow, "DestroyEnvObj", _0, 0)

	return _M._to_15_0(flow)
end

function _M._to_2_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 2, 0, "Eat", 5, "Behav_EatStart", "Behav_EatLoop", "Behav_EatEnd", 5, "", false, false)
end

function _M._to_10_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_12_2(flow)

	if _0 then
		flow:setActive()
		_C(10, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_13_1(flow)

		return _doBehaviourTail_1(flow, 10, _1, 0.5, 6, true, 4, 99999, 0, 2, false, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_15_0(flow)
	if not _B(flow, "PBT_AddBuff") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tBuffId", 11149)
	flow.__agent:addSubTreeLocalParam("duration", 5)
	flow:setContinue(15)

	return true
end

function _M._to_17_0(flow)
	local _2 = _M._get_18_1(flow)
	local _0 = not _2

	if _0 then
		return _M._to_22_0(flow)
	end

	local _1 = _M._get_18_1(flow)

	if _1 then
		return _M._to_10_0(flow)
	end
end

function _M._to_19_0(flow)
	flow:setActive()

	local _0 = _M._get_13_1(flow)

	_A(flow, "DestroyEnvObj", _0, 0)

	return _M._to_21_0(flow)
end

function _M._to_20_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 20, 0, "Eat", 5, "Behav_EatStart", "Behav_EatLoop", "Behav_EatEnd", 5, "", false, false)
end

function _M._to_21_0(flow)
	if not _B(flow, "PBT_AddBuff") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tBuffId", 11149)
	flow.__agent:addSubTreeLocalParam("duration", 5)
	flow:setContinue(21)

	return true
end

function _M._to_22_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_12_2(flow)

	if _0 then
		flow:setActive()
		_C(22, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_13_1(flow)

		return _doBehaviourTail_1(flow, 22, _1, 0.5, 6, true, 1, 99999, 0, 0, false, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_26_0(flow)
	flow:setActive()

	local _0 = _M._get_13_1(flow)

	_A(flow, "AddEntityTag", _0, "TE_Env_BeUsed")
	flow:setActive()

	local _1 = _C(31, "GetSelfId", flow)

	_A(flow, "StartNpcDialog", 70008558, _1)

	return _M._to_20_0(flow)
end

function _M._to_27_0(flow)
	flow:setActive()

	local _0 = _M._get_13_1(flow)

	_A(flow, "AddEntityTag", _0, "TE_Env_BeUsed")

	return _M._to_2_0(flow)
end

function _M._to_32_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 32, 0, "", 0, "Behav_SleepStart", "Behav_SleepLoop", "Behav_SleepEnd", 999, "", true, false)
end

function _M._to_33_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 33, 0, "", 0, "Behav_SleepStart", "Behav_SleepLoop", "Behav_SleepEnd", 999, "", true, false)
end

function _M._get_1_2(flow)
	local _0 = _M._get_9_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(1, "__iterItem", v)

		_1 = _M._get_4_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_4_3(flow)
	local _0 = flow:getCache(1, "__iterItem")

	return _C(4, "GetDistance", flow, _0, 0, false)
end

function _M._get_9_3(flow)
	local _0 = _C(5, "GetAoiEntityTableByLevel", flow, 0, 10, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(9, "__iterItem", v)

		if _M._get_25_3(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_9_2(flow)
	return flow:getCache(9, "__iterItem")
end

function _M._get_12_2(flow)
	local _2 = _M._get_9_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _0 = not _3

	if not _0 then
		return false
	end

	local _4 = _M._get_13_1(flow)
	local _1 = _C(14, "CheckEntityExist", flow, _4)

	if not _1 then
		return false
	end

	return true
end

function _M._get_13_1(flow)
	local _0 = flow:getCache(13, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_1_2(flow)

	flow:setCache(13, "1", _0)

	return _0
end

function _M._get_18_1(flow)
	return _C(18, "CheckHasEntityTag", flow, 0, "TE_Wild_10501_Rage")
end

function _M._get_25_3(flow)
	local _2 = _M._get_9_2(flow)
	local _0 = _C(6, "HasEntityTag", flow, _2, "TE_Env_SleepFruit")

	if not _0 then
		return false
	end

	local _3 = _M._get_9_2(flow)
	local _4 = _C(23, "HasEntityTag", flow, _3, "TE_Env_Attaching", "TE_Env_BeUsed")
	local _1 = not _4

	if not _1 then
		return false
	end

	if false then
		return false
	end

	return true
end

return _M
