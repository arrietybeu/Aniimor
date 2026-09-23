-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10051_MoveToAflameHappy.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_5_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 2 then
		return _M._to_6_0(flow)
	end

	if nodeId == 5 then
		return _M._to_2_0(flow)
	end

	if nodeId == 6 then
		return _M._to_36_0(flow)
	end

	if nodeId == 36 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 2 then
		return _M._get_46_1(flow)
	end

	if nodeId == 6 then
		return _M._get_46_1(flow)
	end

	if nodeId == 36 then
		return _M._get_46_1(flow)
	end
end

function _M._to_2_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 2)

	if not _1 then
		flow:setActive()
		_C(2, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_44_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 3)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 0)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 10)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(2)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_5_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_13_1(flow)

	if _0 then
		flow:setActive()
		_C(5, "DoBehaviour", flow, "PBT_TurnToTargetAtYaw")

		local _1 = _M._get_44_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTgtId", _1)
		flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
		flow.__agent:addSubTreeLocalParam("tInstant", false)
		flow:setContinue(5)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_6_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 6)

	if not _1 then
		flow:setActive()
		_C(6, "DoBehaviour", flow, "PBT_ShowEmojiBubble")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 2.5)
		flow:setContinue(6)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_36_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 36)

	if not _1 then
		flow:setActive()
		_C(36, "DoBehaviour", flow, "PBT_CustomLoopAnimation")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_HappyStart")
		flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_HappyLoop")
		flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_HappyEnd")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
		flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", true)
		flow:setContinue(36)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_8_2(flow)
	local _4 = _M._get_30_2(flow)
	local _0 = _C(33, "CheckHasChemState", flow, _4, "STATE_AFLAME_KEY")

	if not _0 then
		return false
	end

	local _3 = _M._get_30_2(flow)
	local _2 = _C(10, "GetDistance", flow, _3, 0, false)
	local _1 = _2 <= 15

	if not _1 then
		return false
	end

	return true
end

function _M._get_13_1(flow)
	local _1 = _M._get_30_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_30_2(flow)
	return flow:getCache(30, "__iterItem")
end

function _M._get_30_3(flow)
	local _0 = _C(26, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(30, "__iterItem", v)

		if _M._get_8_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_41_2(flow)
	local _0 = _M._get_30_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(41, "__iterItem", v)

		_1 = _M._get_42_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_42_3(flow)
	local _0 = flow:getCache(41, "__iterItem")

	return _C(42, "GetDistance", flow, _0, 0, false)
end

function _M._get_44_1(flow)
	local _0 = flow:getCache(44, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_41_2(flow)

	flow:setCache(44, "1", _0)

	return _0
end

function _M._get_46_1(flow)
	local _1 = _M._get_44_1(flow)
	local _0 = _C(45, "CheckHasChemState", flow, _1, "STATE_AFLAME_KEY")

	return not _0
end

return _M
