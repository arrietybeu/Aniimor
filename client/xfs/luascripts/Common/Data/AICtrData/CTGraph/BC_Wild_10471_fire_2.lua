-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10471_fire_2.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_11_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 11 then
		return _M._to_20_0(flow)
	end

	if nodeId == 20 then
		return _M._to_22_0(flow)
	end

	if nodeId == 22 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 11 then
		return _M._get_17_1(flow)
	end

	if nodeId == 20 then
		return _M._get_17_1(flow)
	end
end

function _M._to_11_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_15_1(flow)
	local _1 = _M.checkInterrupt(flow, 11)

	if _0 and not _1 then
		flow:setActive()
		_C(11, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _2 = _M._get_19_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _2)
		flow.__agent:addSubTreeLocalParam("tStopDist", 0.5)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 0)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 10)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(11)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_20_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 20)

	if not _1 then
		flow:setActive()
		_C(20, "DoBehaviour", flow, "PBT_Wild_10501_Dialogue")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("firstDialogueId", 1047100)
		flow.__agent:addSubTreeLocalParam("lastDialogueId", 1047100)
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow:setContinue(20)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_22_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_HappyStart")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_HappyLoop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_HappyEnd")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 999)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", true)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(22)

	return true
end

function _M._get_7_2(flow)
	return flow:getCache(7, "__iterItem")
end

function _M._get_7_3(flow)
	local _0 = _C(16, "GetAoiEntityTableByLevel", flow, 0, 10, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(7, "__iterItem", v)

		if _M._get_26_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_9_2(flow)
	local _0 = _M._get_7_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(9, "__iterItem", v)

		_1 = _M._get_10_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_10_3(flow)
	local _0 = flow:getCache(9, "__iterItem")

	return _C(10, "GetDistance", flow, _0, 0, false)
end

function _M._get_15_1(flow)
	local _1 = _M._get_7_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_17_1(flow)
	local _1 = _M._get_19_1(flow)
	local _0 = _C(18, "CheckHasChemState", flow, _1, "STATE_AFLAME_KEY")

	return not _0
end

function _M._get_19_1(flow)
	local _0 = flow:getCache(19, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_9_2(flow)

	flow:setCache(19, "1", _0)

	return _0
end

function _M._get_26_2(flow)
	local _2 = _M._get_7_2(flow)
	local _0 = _C(5, "CheckHasChemState", flow, _2, "STATE_AFLAME_KEY")

	if not _0 then
		return false
	end

	local _3 = _M._get_7_2(flow)
	local _4 = _C(24, "GetDistance", flow, _3, 0, false)
	local _1 = _4 <= 10

	if not _1 then
		return false
	end

	return true
end

return _M
