-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_EcoHabit_Eat.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_76_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_66_1(flow)
	local _1 = _M._get_66_2(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 61 then
		return _M._to_67_0(flow)
	end

	if nodeId == 77 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_61_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_66_1(flow)
	local _1 = _M._get_66_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tPointId", _0)
	flow.__agent:addSubTreeLocalParam("tPortId", _1)
	flow.__agent:addSubTreeLocalParam("tTimeout", 1000)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 0)
	flow.__agent:addSubTreeLocalParam("tSpeed", 1.6)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow:setContinue(61)

	return true
end

function _M._to_67_0(flow)
	flow:setActive()

	local _0 = _M._get_66_1(flow)
	local _1 = _M._get_66_2(flow)

	_A(flow, "JoinResPointPort", 0, _0, _1)

	return _M._to_77_0(flow)
end

function _M._to_76_0(flow)
	local _3 = _M._get_71_2(flow)
	local _4 = not _3 or next(_3) == nil
	local _0 = not _4

	if _0 then
		flow:setActive()

		local _1 = _M._get_66_1(flow)
		local _2 = _M._get_66_2(flow)

		_A(flow, "PreJoinResPointPort", 0, _1, _2)

		return _M._to_61_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._to_77_0(flow)
	if not _B(flow, "PBT_Eat") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("eatTimeOut", 10)
	flow:setContinue(77)

	return true
end

function _M._get_63_1(flow)
	local _0 = _M._get_71_2(flow)

	return _C(63, "SelectOneByRandom", flow, _0)
end

function _M._get_66_1(flow)
	local _0 = _M._get_70_1(flow)

	return _C(66, "UnpackResPointPort", flow, _0, 1)
end

function _M._get_66_2(flow)
	local _0 = _M._get_70_1(flow)

	return _C(66, "UnpackResPointPort", flow, _0, 2)
end

function _M._get_70_1(flow)
	local _0 = flow:getCache(70, "resPointPort")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_63_1(flow)

	flow:setCache(70, "resPointPort", _0)

	return _0
end

function _M._get_71_2(flow)
	local _0 = _C(62, "GetAoiResPointPortTableByLevel", flow, 0, 30, 0, {
		"TR_EcoHabit_Eat"
	}, {
		"TR_EcoHabit_Eat"
	})

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		flow:setCache(71, "__iterItem", v)

		if _M._get_74_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_74_2(flow)
	local _1 = flow:getCache(71, "__iterItem")
	local _0 = _C(73, "GetDistanceFromEntityToResPointPort", flow, 0, _1)

	return _0 < 15
end

return _M
