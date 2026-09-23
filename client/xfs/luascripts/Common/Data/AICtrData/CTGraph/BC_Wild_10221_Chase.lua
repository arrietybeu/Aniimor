-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10221_Chase.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
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

function _M.executeTickLodTrigger(flow)
	return _M._to_59_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 58 then
		return _M._to_63_0(flow)
	end

	if nodeId == 59 then
		return _M._to_58_0(flow)
	end

	if nodeId == 60 then
		return true
	end

	if nodeId == 63 then
		return _M._to_64_0(flow)
	end

	if nodeId == 64 then
		return _M._to_70_0(flow)
	end

	if nodeId == 70 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_58_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 58, 0, "Alert", 2, "Behav_AlertStart", "Behav_AlertLoop", "Behav_AlertEnd", 3, "", false, true)
end

function _M._to_59_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_5_1(flow)

	if _0 then
		flow:setActive()
		_C(59, "DoBehaviour", flow, "PBT_TurnToTargetAtYaw")

		local _1 = _M._get_10_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTgtId", _1)
		flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
		flow.__agent:addSubTreeLocalParam("tInstant", false)
		flow:setContinue(59)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_63_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntityAtPos") then
		return
	end

	local _0 = _M._get_10_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tStopDist", 4)
	flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
	flow.__agent:addSubTreeLocalParam("tTargetYaw", 0)
	flow.__agent:addSubTreeLocalParam("tTargetDistance", 0)
	flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow:setContinue(63)

	return true
end

function _M._to_64_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_10_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tSkillId", 12210110)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(64)

	return true
end

function _M._to_70_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 70, 0, "Think", 3, "Behav_AlertStart", "Behav_AlertLoop", "Behav_AlertEnd", 3, "", false, true)
end

function _M._get_2_3(flow)
	local _0 = _C(1, "GetAoiEntityTableByLevel", flow, 0, 30, 14)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(2, "__iterItem", v)

		if _M._get_73_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_2_2(flow)
	return flow:getCache(2, "__iterItem")
end

function _M._get_5_1(flow)
	local _1 = _M._get_2_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_9_1(flow)
	local _0 = _M._get_2_3(flow)

	return _C(9, "SelectOneByRandom", flow, _0)
end

function _M._get_10_1(flow)
	local _0 = flow:getCache(10, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_9_1(flow)

	flow:setCache(10, "1", _0)

	return _0
end

function _M._get_73_2(flow)
	local _4 = _M._get_2_2(flow)
	local _5 = _C(71, "GetDistance", flow, _4, 0, false)
	local _0 = _5 <= 15

	if not _0 then
		return false
	end

	local _2 = _M._get_2_2(flow)
	local _3 = _C(68, "GetPuppetData", flow, _2, "petPrototypeId", true, 0)
	local _1 = _3 == 1020100

	if not _1 then
		return false
	end

	return true
end

return _M
