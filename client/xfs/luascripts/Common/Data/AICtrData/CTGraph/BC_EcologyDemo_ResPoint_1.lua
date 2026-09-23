-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_EcologyDemo_ResPoint_1.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_5_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_54_0(flow)
	local _1 = _M._get_63_1(flow)
	local _2 = _M._get_63_2(flow)

	_A(flow, "ExitResPointPort", _0, _1, _2, 0, 0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 5 then
		return _M._to_53_0(flow)
	end

	if nodeId == 58 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_5_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_48_1(flow)

	if _0 then
		flow:setActive()
		_C(5, "DoBehaviour", flow, "PBT_MoveToResPointPort")

		local _1 = _M._get_63_1(flow)
		local _2 = _M._get_63_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tPointId", _1)
		flow.__agent:addSubTreeLocalParam("tPortId", _2)
		flow.__agent:addSubTreeLocalParam("tTimeout", 10000)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeed", 0)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow:setContinue(5)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_53_0(flow)
	flow:setActive()

	local _0 = _M._get_54_0(flow)
	local _1 = _M._get_63_1(flow)
	local _2 = _M._get_63_2(flow)

	_A(flow, "JoinResPointPort", _0, _1, _2)

	return _M._to_58_0(flow)
end

function _M._to_58_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Behav_Happy")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(58)

	return true
end

function _M._get_40_1(flow)
	local _0 = _M._get_46_1(flow)

	return _C(40, "SelectOneByRandom", flow, _0)
end

function _M._get_41_3(flow)
	local _0 = _C(50, "GetSelfId", flow)

	return _C(41, "GetAoiResPointPortTableByLevel", flow, _0, 30, 0, nil, {
		"TRPW_Catch01"
	})
end

function _M._get_43_1(flow)
	local _0 = flow:getCache(43, "resPointPort")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_40_1(flow)

	flow:setCache(43, "resPointPort", _0)

	return _0
end

function _M._get_46_1(flow)
	local _0 = flow:getCache(46, "resPointPortList")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_41_3(flow)

	flow:setCache(46, "resPointPortList", _0)

	return _0
end

function _M._get_48_1(flow)
	local _1 = _M._get_46_1(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_54_0(flow)
	return _C(54, "GetSelfId", flow)
end

function _M._get_63_2(flow)
	local _0 = _M._get_43_1(flow)

	return _C(63, "UnpackResPointPort", flow, _0, 2)
end

function _M._get_63_1(flow)
	local _0 = _M._get_43_1(flow)

	return _C(63, "UnpackResPointPort", flow, _0, 1)
end

return _M
