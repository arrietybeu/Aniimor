-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_Test_MultiRoute.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	flow:setActive()

	local _0 = _M._get_3_1(flow)
	local _1 = _M._get_3_2(flow)

	_A(flow, "PreJoinResPointPort", 0, _0, _1)

	return _M._to_1_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_3_1(flow)
	local _1 = _M._get_3_2(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 1 then
		return _M._to_4_0(flow)
	end

	if nodeId == 17 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_1_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_3_1(flow)
	local _1 = _M._get_3_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tPointId", _0)
	flow.__agent:addSubTreeLocalParam("tPortId", _1)
	flow.__agent:addSubTreeLocalParam("tTimeout", 1000)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 0)
	flow.__agent:addSubTreeLocalParam("tSpeed", 1)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow:setContinue(1)

	return true
end

function _M._to_4_0(flow)
	flow:setActive()

	local _0 = _M._get_3_1(flow)
	local _1 = _M._get_3_2(flow)

	_A(flow, "JoinResPointPort", 0, _0, _1)

	return _M._to_17_0(flow)
end

function _M._to_17_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_18_1(flow)

	if _P(flow, 1, _0, 0, nil) then
		flow:setContinue(17)

		return true
	end
end

function _M._get_3_1(flow)
	local _0 = _M._get_12_1(flow)

	return _C(3, "UnpackResPointPort", flow, _0, 1)
end

function _M._get_3_2(flow)
	local _0 = _M._get_12_1(flow)

	return _C(3, "UnpackResPointPort", flow, _0, 2)
end

function _M._get_10_1(flow)
	local _0 = _M._get_13_2(flow)

	return _C(10, "SelectOneByRandom", flow, _0)
end

function _M._get_12_1(flow)
	local _0 = flow:getCache(12, "resPointPort")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_10_1(flow)

	flow:setCache(12, "resPointPort", _0)

	return _0
end

function _M._get_13_2(flow)
	local _0 = _C(9, "GetAoiResPointPortTableByLevel", flow, 0, 30, 0, {
		"TR_Test_MultiRoute"
	}, nil)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		flow:setCache(13, "__iterItem", v)

		if _M._get_15_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_15_2(flow)
	local _1 = flow:getCache(13, "__iterItem")
	local _0 = _C(14, "GetDistanceFromEntityToResPointPort", flow, 0, _1)

	return _0 < 30
end

function _M._get_18_1(flow)
	local _0 = _M._get_3_1(flow)
	local _1 = _M._get_3_2(flow)

	return _C(18, "GetRouteIdFromResPoint", flow, true, _0, _1)
end

return _M
