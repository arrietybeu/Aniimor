-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_MoveToEatBait.lua

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
	agent:addSubTreeLocalParam("tTargetYaw", value4)
	agent:addSubTreeLocalParam("tTargetDistance", value5)
	agent:addSubTreeLocalParam("tNoBodySize", value6)
	agent:addSubTreeLocalParam("tSpeed", value7)
	agent:addSubTreeLocalParam("tSpeedRateType", value8)
	agent:addSubTreeLocalParam("tUseAccurateArrive", value9)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_1(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tCharacterState", value0)
	agent:addSubTreeLocalParam("tAnimationKey", value1)
	flow:setContinue(nodeId)

	return true
end

function _M.executeTickLodTrigger(flow)
	return _M._to_4_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 4 then
		return _M._to_40_0(flow)
	end

	if nodeId == 18 then
		return _M._to_32_0(flow)
	end

	if nodeId == 35 then
		return _M._to_18_0(flow)
	end

	if nodeId == 40 then
		return _M._to_35_0(flow)
	end

	if nodeId == 42 then
		return _M._to_43_0(flow)
	end

	if nodeId == 43 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_4_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_13_2(flow)

	if _0 then
		flow:setActive()
		_C(4, "DoBehaviour", flow, "PBT_MoveToTargetEntityAtPos")

		local _1 = _M._get_30_1(flow)
		local _2 = _C(44, "RandomInteger", flow, -75, 75)
		local _3 = _C(45, "RandomInteger", flow, 1, 3)

		return _doBehaviourTail_0(flow, 4, _1, 0, 7, true, _2, _3, false, 0, 0, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_18_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Eat")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 2)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_EatStart")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_EatLoop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_EatLoop")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 10)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(18)

	return true
end

function _M._to_32_0(flow)
	flow:setActive()

	local _0 = _M._get_30_1(flow)

	_A(flow, "SetModelActive", _0, "P_Chest_Shell02", false)
	flow:setActive()

	local _1 = _M._get_30_1(flow)

	_A(flow, "DestroyEnvObj", _1, 10)

	return _M._to_42_0(flow)
end

function _M._to_35_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntityAtPos") then
		return
	end

	local _0 = _M._get_30_1(flow)

	return _doBehaviourTail_0(flow, 35, _0, 0, 3, true, 0, 0.01, false, 0, 0, false)
end

function _M._to_40_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	return _doBehaviourTail_1(flow, 40, "GROUND", "")
end

function _M._to_42_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	return _doBehaviourTail_1(flow, 42, "FLYING", "")
end

function _M._to_43_0(flow)
	if not _B(flow, "PBT_Leave") then
		return
	end

	local _0 = _M._get_30_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow:setContinue(43)

	return true
end

function _M._get_1_2(flow)
	local _0 = _C(0, "GetAoiEntityTableByLevel", flow, 0, 30, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(1, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_15_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_7_1(flow)
	local _0 = _M._get_1_2(flow)

	return _C(7, "SelectOneByRandom", flow, _0)
end

function _M._get_13_2(flow)
	local _2 = _M._get_1_2(flow)
	local _3 = not _2 or next(_2) == nil
	local _0 = not _3

	if not _0 then
		return false
	end

	local _4 = _M._get_36_2(flow)
	local _1 = not _4 or next(_4) == nil

	if not _1 then
		return false
	end

	return true
end

function _M._get_15_2(flow)
	local _0 = flow:getCache(1, "__iterItem")

	return _C(15, "HasEntityTag", flow, _0, "TE_Env_Bait")
end

function _M._get_30_1(flow)
	local _0 = flow:getCache(30, "Bait")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_7_1(flow)

	flow:setCache(30, "Bait", _0)

	return _0
end

function _M._get_36_2(flow)
	local _3 = _M._get_30_1(flow)
	local _0 = _C(8, "GetAoiEntityTableByLevel", flow, _3, 10, 2)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(36, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_39_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_39_2(flow)
	local _1 = flow:getCache(36, "__iterItem")
	local _2 = _M._get_30_1(flow)
	local _0 = _C(38, "GetDistance", flow, _1, _2, false)

	return _0 <= 6
end

return _M
