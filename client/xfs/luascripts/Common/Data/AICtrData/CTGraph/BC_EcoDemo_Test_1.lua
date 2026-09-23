-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_EcoDemo_Test_1.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_36_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_35_1(flow)
	local _1 = _M._get_35_2(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 22 then
		return _M._to_39_0(flow)
	end

	if nodeId == 39 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_22_0(flow)
	if not _B(flow, "PBT_MoveToResPointPortInDist") then
		return
	end

	local _0 = _M._get_35_1(flow)
	local _1 = _M._get_35_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tPointId", _0)
	flow.__agent:addSubTreeLocalParam("tPortId", _1)
	flow.__agent:addSubTreeLocalParam("tTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tInteractDist", 3)
	flow.__agent:addSubTreeLocalParam("tIgnoreSelfBodySize", true)
	flow.__agent:addSubTreeLocalParam("tIgnorePointBodySize", true)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow:setContinue(22)

	return true
end

function _M._to_36_0(flow)
	local _3 = _M._get_29_4(flow)
	local _4 = not _3 or next(_3) == nil
	local _0 = not _4

	if _0 then
		flow:setActive()

		local _1 = _M._get_35_1(flow)
		local _2 = _M._get_35_2(flow)

		_A(flow, "PreJoinResPointPort", 0, _1, _2)

		return _M._to_22_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._to_39_0(flow)
	if not _B(flow, "PBT_Node_Com_SwitchToHideMimicryIn") then
		return
	end

	local _0 = _M._get_34_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetPos", _0)
	flow:setContinue(39)

	return true
end

function _M._get_29_4(flow)
	return _C(29, "GetAoiResPointPortTableByLevel", flow, 0, 30, 10, {
		"TR_Test"
	}, {
		"TR_Test"
	})
end

function _M._get_32_1(flow)
	local _0 = _M._get_29_4(flow)

	return _C(32, "SelectOneByRandom", flow, _0)
end

function _M._get_33_1(flow)
	local _0 = flow:getCache(33, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_32_1(flow)

	flow:setCache(33, "1", _0)

	return _0
end

function _M._get_34_2(flow)
	local _0 = _M._get_35_1(flow)
	local _1 = _M._get_35_2(flow)

	return _C(34, "GetResPointPortPosition", flow, _0, _1)
end

function _M._get_35_1(flow)
	local _0 = _M._get_33_1(flow)

	return _C(35, "UnpackResPointPort", flow, _0, 1)
end

function _M._get_35_2(flow)
	local _0 = _M._get_33_1(flow)

	return _C(35, "UnpackResPointPort", flow, _0, 2)
end

return _M
