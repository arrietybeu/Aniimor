-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10141_Morphling_Doubt.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_0_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 0 then
		return _M._to_12_0(flow)
	end

	if nodeId == 12 then
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

	local _0 = _M._get_8_1(flow)

	if _0 then
		flow:setActive()
		_C(0, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_10_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 0.2)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 2)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 0)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(0)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_12_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Think")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_DoubtStart")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_DoubtLoop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_DoubtEnd")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(12)

	return true
end

function _M._get_2_2(flow)
	return flow:getCache(2, "__iterItem")
end

function _M._get_2_3(flow)
	local _0 = _C(5, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(2, "__iterItem", v)

		if _M._get_6_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_4_3(flow)
	local _0 = flow:getCache(9, "__iterItem")

	return _C(4, "GetDistance", flow, _0, 0, false)
end

function _M._get_6_2(flow)
	local _0 = _M._get_2_2(flow)

	return _C(6, "HasEntityTag", flow, _0, "TE_Env_10141Morphling")
end

function _M._get_8_1(flow)
	local _1 = _M._get_2_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_9_2(flow)
	local _0 = _M._get_2_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(9, "__iterItem", v)

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

function _M._get_10_1(flow)
	local _0 = flow:getCache(10, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_9_2(flow)

	flow:setCache(10, "1", _0)

	return _0
end

return _M
