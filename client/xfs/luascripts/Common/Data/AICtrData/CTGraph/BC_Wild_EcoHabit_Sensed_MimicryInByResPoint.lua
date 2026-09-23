-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_EcoHabit_Sensed_MimicryInByResPoint.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "SensedMsgTrigger" then
		return _M._to_81_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_74_1(flow)
	local _1 = _M._get_74_2(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 2)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 77 then
		return _M._to_89_0(flow)
	end

	if nodeId == 79 then
		return _M._to_77_0(flow)
	end

	if nodeId == 89 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_77_0(flow)
	if not _B(flow, "PBT_Behav_Com_MimicryIn") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(77)

	return true
end

function _M._to_79_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_74_1(flow)
	local _1 = _M._get_74_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tPointId", _0)
	flow.__agent:addSubTreeLocalParam("tPortId", _1)
	flow.__agent:addSubTreeLocalParam("tTimeout", 1000)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tSpeed", 3.5)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow:setContinue(79)

	return true
end

function _M._to_81_0(flow)
	local _3 = _M._get_65_3(flow)
	local _4 = not _3 or next(_3) == nil
	local _0 = not _4

	if _0 then
		flow:setActive()

		local _1 = _M._get_74_1(flow)
		local _2 = _M._get_74_2(flow)

		_A(flow, "PreJoinResPointPort", 0, _1, _2)

		return _M._to_79_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._to_89_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 999999)
	flow:setContinue(89)

	return true
end

function _M._get_65_2(flow)
	return flow:getCache(65, "__iterItem")
end

function _M._get_65_3(flow)
	local _0 = _C(64, "GetAoiResPointPortTableByLevel", flow, 0, 30, 5, {
		"TR_Mimicry"
	}, {
		"TR_Mimicry"
	})
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(65, "__iterItem", v)

		if _M._get_66_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_66_2(flow)
	local _1 = _M._get_65_2(flow)
	local _0 = _C(69, "GetDistanceFromEntityToResPointPort", flow, 0, _1)

	return _0 < 20
end

function _M._get_68_2(flow)
	local _0 = _M._get_65_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(68, "__iterItem", v)

		_1 = _M._get_70_2(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_70_2(flow)
	local _0 = flow:getCache(68, "__iterItem")

	return _C(70, "GetDistanceFromEntityToResPointPort", flow, 0, _0)
end

function _M._get_71_1(flow)
	local _0 = flow:getCache(71, "resPointPort2")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_68_2(flow)

	flow:setCache(71, "resPointPort2", _0)

	return _0
end

function _M._get_74_2(flow)
	local _0 = _M._get_71_1(flow)

	return _C(74, "UnpackResPointPort", flow, _0, 2)
end

function _M._get_74_1(flow)
	local _0 = _M._get_71_1(flow)

	return _C(74, "UnpackResPointPort", flow, _0, 1)
end

return _M
