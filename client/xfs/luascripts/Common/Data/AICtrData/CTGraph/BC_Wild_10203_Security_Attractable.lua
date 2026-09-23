-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10203_Security_Attractable.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_39_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 39 then
		return _M._to_72_0(flow)
	end

	if nodeId == 51 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_39_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_56_2(flow)

	if _0 then
		flow:setActive()
		_C(39, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_47_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 0.4)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 10)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 4)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 10)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(39)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_51_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_AlertStart")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_AlertLoop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_AlertLEnd")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 20)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(51)

	return true
end

function _M._to_72_0(flow)
	flow:setActive()
	_A(flow, "AddAITag", 0, "Finish")

	return _M._to_51_0(flow)
end

function _M._get_47_1(flow)
	local _0 = _M._get_74_3(flow)

	return _C(47, "SelectOneByRandom", flow, _0)
end

function _M._get_56_2(flow)
	local _3 = _M._get_74_3(flow)
	local _4 = not _3 or next(_3) == nil
	local _0 = not _4

	if not _0 then
		return false
	end

	local _2 = _C(66, "HasAITag", flow, 0, "Finish")
	local _1 = not _2

	if not _1 then
		return false
	end

	return true
end

function _M._get_74_2(flow)
	return flow:getCache(74, "__iterItem")
end

function _M._get_74_3(flow)
	local _0 = _C(87, "GetAoiEntityTableByLevel", flow, 0, 30, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(74, "__iterItem", v)

		if _M._get_84_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_84_2(flow)
	local _2 = _M._get_74_2(flow)
	local _0 = _C(80, "HasEntityTag", flow, _2, "TE_Env_Ball")

	if not _0 then
		return false
	end

	local _4 = _M._get_74_2(flow)
	local _3 = _C(83, "GetDistance", flow, _4, 0, false)
	local _1 = _3 <= 7

	if not _1 then
		return false
	end

	return true
end

return _M
