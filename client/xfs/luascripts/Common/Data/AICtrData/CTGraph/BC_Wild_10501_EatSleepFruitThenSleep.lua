-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10501_EatSleepFruitThenSleep.lua

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

local function _doBehaviourTail_1(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8, value9)
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
	return _M._to_47_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_38_1(flow)

	_A(flow, "RemoveEntityTag", _0, "TE_Env_BeUsed")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 40 then
		return _M._to_93_0(flow)
	end

	if nodeId == 41 then
		return _M._to_42_0(flow)
	end

	if nodeId == 50 then
		return _M._to_49_0(flow)
	end

	if nodeId == 52 then
		return _M._to_91_0(flow)
	end

	if nodeId == 53 then
		return true
	end

	if nodeId == 54 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_40_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_43_2(flow)

	if _0 then
		flow:setActive()
		_C(40, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_38_1(flow)

		return _doBehaviourTail_0(flow, 40, _1, 0.5, 6, true, 4, 99999, 0, 2, false, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_41_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 41, 0, "Eat", 5, "Behav_EatStart", "Behav_EatLoop", "Behav_EatEnd", 5, "", false, false)
end

function _M._to_42_0(flow)
	flow:setActive()

	local _0 = _M._get_38_1(flow)

	_A(flow, "DestroyEnvObj", _0, 0)

	return _M._to_54_0(flow)
end

function _M._to_47_0(flow)
	local _2 = _M._get_48_1(flow)
	local _0 = not _2

	if _0 then
		return _M._to_52_0(flow)
	end

	local _1 = _M._get_48_1(flow)

	if _1 then
		return _M._to_40_0(flow)
	end
end

function _M._to_49_0(flow)
	flow:setActive()

	local _0 = _M._get_38_1(flow)

	_A(flow, "DestroyEnvObj", _0, 0)

	return _M._to_53_0(flow)
end

function _M._to_50_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 50, 0, "Eat", 5, "Behav_EatStart", "Behav_EatLoop", "Behav_EatEnd", 5, "", false, false)
end

function _M._to_52_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_43_2(flow)

	if _0 then
		flow:setActive()
		_C(52, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_38_1(flow)

		return _doBehaviourTail_0(flow, 52, _1, 0.5, 6, true, 1, 99999, 0, 0, false, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_53_0(flow)
	if not _B(flow, "PBT_AddBuff") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tBuffId", 1145115)
	flow.__agent:addSubTreeLocalParam("duration", 5)
	flow:setContinue(53)

	return true
end

function _M._to_54_0(flow)
	if not _B(flow, "PBT_AddBuff") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tBuffId", 1145115)
	flow.__agent:addSubTreeLocalParam("duration", 5)
	flow:setContinue(54)

	return true
end

function _M._to_91_0(flow)
	flow:setActive()

	local _0 = _M._get_38_1(flow)

	_A(flow, "AddEntityTag", _0, "TE_Env_BeUsed")
	flow:setActive()

	local _1 = _C(98, "GetSelfId", flow)

	_A(flow, "StartNpcDialog", 70008558, _1)

	return _M._to_50_0(flow)
end

function _M._to_93_0(flow)
	flow:setActive()

	local _0 = _M._get_38_1(flow)

	_A(flow, "AddEntityTag", _0, "TE_Env_BeUsed")

	return _M._to_41_0(flow)
end

function _M._get_24_2(flow)
	return flow:getCache(24, "__iterItem")
end

function _M._get_24_3(flow)
	local _0 = _C(30, "GetAoiEntityTableByLevel", flow, 0, 10, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(24, "__iterItem", v)

		if _M._get_88_3(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_29_3(flow)
	local _0 = flow:getCache(34, "__iterItem")

	return _C(29, "GetDistance", flow, _0, 0, false)
end

function _M._get_34_2(flow)
	local _0 = _M._get_24_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(34, "__iterItem", v)

		_1 = _M._get_29_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_38_1(flow)
	local _0 = flow:getCache(38, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_34_2(flow)

	flow:setCache(38, "1", _0)

	return _0
end

function _M._get_43_2(flow)
	local _2 = _M._get_24_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _0 = not _3

	if not _0 then
		return false
	end

	local _4 = _M._get_38_1(flow)
	local _1 = _C(39, "CheckEntityExist", flow, _4)

	if not _1 then
		return false
	end

	return true
end

function _M._get_48_1(flow)
	return _C(48, "CheckHasEntityTag", flow, 0, "TE_Wild_10501_Rage")
end

function _M._get_88_3(flow)
	local _2 = _M._get_24_2(flow)
	local _0 = _C(31, "HasEntityTag", flow, _2, "TE_Env_SleepFruit")

	if not _0 then
		return false
	end

	local _3 = _M._get_24_2(flow)
	local _4 = _C(86, "HasEntityTag", flow, _3, "TE_Env_Attaching", "TE_Env_BeUsed")
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
