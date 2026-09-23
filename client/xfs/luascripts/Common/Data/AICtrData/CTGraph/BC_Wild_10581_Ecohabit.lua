-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10581_Ecohabit.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_13_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_5_1(flow)
	local _1 = _M._get_5_2(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 0 then
		return _M._to_6_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_0_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_5_1(flow)
	local _1 = _M._get_5_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tPointId", _0)
	flow.__agent:addSubTreeLocalParam("tPortId", _1)
	flow.__agent:addSubTreeLocalParam("tTimeout", 1000)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 0)
	flow.__agent:addSubTreeLocalParam("tSpeed", 1.6)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow:setContinue(0)

	return true
end

function _M._to_6_0(flow)
	flow:setActive()

	local _0 = _M._get_5_1(flow)
	local _1 = _M._get_5_2(flow)

	_A(flow, "JoinResPointPort", 0, _0, _1)

	return true
end

function _M._to_13_0(flow)
	local _0 = _M._get_17_2(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_5_1(flow)
		local _2 = _M._get_5_2(flow)

		_A(flow, "PreJoinResPointPort", 0, _1, _2)

		return _M._to_0_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._get_2_1(flow)
	local _0 = _M._get_10_2(flow)

	return _C(2, "SelectOneByRandom", flow, _0)
end

function _M._get_5_2(flow)
	local _0 = _M._get_9_1(flow)

	return _C(5, "UnpackResPointPort", flow, _0, 2)
end

function _M._get_5_1(flow)
	local _0 = _M._get_9_1(flow)

	return _C(5, "UnpackResPointPort", flow, _0, 1)
end

function _M._get_9_1(flow)
	local _0 = flow:getCache(9, "resPointPort")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_2_1(flow)

	flow:setCache(9, "resPointPort", _0)

	return _0
end

function _M._get_10_2(flow)
	local _0 = _C(1, "GetAoiResPointPortTableByLevel", flow, 0, 30, 0, {
		"TR_GB_10581shangan"
	}, {
		"TR_GB_10581shangan"
	})

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		flow:setCache(10, "__iterItem", v)

		if _M._get_12_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_12_2(flow)
	local _1 = flow:getCache(10, "__iterItem")
	local _0 = _C(11, "GetDistanceFromEntityToResPointPort", flow, 0, _1)

	return _0 < 15
end

function _M._get_17_2(flow)
	local _0 = _C(16, "IsChildOfCharState", flow, 0, "SWIMMING")

	if not _0 then
		return false
	end

	local _2 = _M._get_10_2(flow)
	local _3 = not _2 or next(_2) == nil
	local _1 = not _3

	if not _1 then
		return false
	end

	return true
end

return _M
