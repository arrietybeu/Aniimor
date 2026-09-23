-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_Test_RVO.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_8_0(flow)
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
	flow.__agent:addSubTreeLocalParam("tSpeed", 3)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow:setContinue(1)

	return true
end

function _M._to_4_0(flow)
	flow:setActive()

	local _0 = _M._get_3_1(flow)
	local _1 = _M._get_3_2(flow)

	_A(flow, "JoinResPointPort", 0, _0, _1)

	return true
end

function _M._to_8_0(flow)
	local _4 = _M._get_13_2(flow)
	local _3 = not _4 or next(_4) == nil
	local _0 = not _3

	if _0 then
		flow:setActive()

		local _1 = _M._get_3_1(flow)
		local _2 = _M._get_3_2(flow)

		_A(flow, "PreJoinResPointPort", 0, _1, _2)

		return _M._to_1_0(flow)
	else
		flow:setActiveFail()
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
		"TR_Test_RVO"
	}, nil)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		flow:setCache(13, "__iterItem", v)

		if _M._get_19_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_14_2(flow)
	local _0 = flow:getCache(13, "__iterItem")

	return _C(14, "GetDistanceFromEntityToResPointPort", flow, 0, _0)
end

function _M._get_19_2(flow)
	local _2 = _M._get_14_2(flow)
	local _0 = _2 < 20

	if not _0 then
		return false
	end

	local _3 = _M._get_14_2(flow)
	local _1 = _3 > 5

	if not _1 then
		return false
	end

	return true
end

return _M
