-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10203_Security_FireWatch.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_106_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 106 then
		return _M._to_108_0(flow)
	end

	if nodeId == 108 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_106_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_118_1(flow)

	if _0 then
		flow:setActive()
		_C(106, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_119_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 1)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 20)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 6)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 2)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(106)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_108_0(flow)
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
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 15)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(108)

	return true
end

function _M._get_91_2(flow)
	local _4 = _M._get_93_2(flow)
	local _0 = _C(94, "HasEntityTag", flow, _4, "TE_Env_UniversalMark_C")

	if not _0 then
		return false
	end

	local _3 = _M._get_93_2(flow)
	local _2 = _C(90, "GetDistance", flow, _3, 0, false)
	local _1 = _2 <= 15

	if not _1 then
		return false
	end

	return true
end

function _M._get_93_3(flow)
	local _0 = _C(92, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(93, "__iterItem", v)

		if _M._get_91_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_93_2(flow)
	return flow:getCache(93, "__iterItem")
end

function _M._get_118_1(flow)
	local _1 = _M._get_93_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_119_2(flow)
	local _0 = _M._get_93_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(119, "__iterItem", v)

		_1 = _M._get_120_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_120_3(flow)
	local _0 = flow:getCache(119, "__iterItem")

	return _C(120, "GetDistance", flow, _0, 0, false)
end

return _M
