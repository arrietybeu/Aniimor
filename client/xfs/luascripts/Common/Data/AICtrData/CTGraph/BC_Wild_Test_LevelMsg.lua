-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_Test_LevelMsg.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTrigger01" then
		return _M._to_45_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_41_1(flow)
	local _1 = _M._get_41_2(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 39 then
		return _M._to_42_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_39_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_41_1(flow)
	local _1 = _M._get_41_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tPointId", _0)
	flow.__agent:addSubTreeLocalParam("tPortId", _1)
	flow.__agent:addSubTreeLocalParam("tTimeout", 1000)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tSpeed", 6)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow:setContinue(39)

	return true
end

function _M._to_42_0(flow)
	flow:setActive()

	local _0 = _M._get_41_1(flow)
	local _1 = _M._get_41_2(flow)

	_A(flow, "JoinResPointPort", 0, _0, _1)

	return true
end

function _M._to_45_0(flow)
	local _4 = _M._get_50_2(flow)
	local _3 = not _4 or next(_4) == nil
	local _0 = not _3

	if _0 then
		flow:setActive()

		local _1 = _M._get_41_1(flow)
		local _2 = _M._get_41_2(flow)

		_A(flow, "PreJoinResPointPort", 0, _1, _2)

		return _M._to_39_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._get_41_1(flow)
	local _0 = _M._get_49_1(flow)

	return _C(41, "UnpackResPointPort", flow, _0, 1)
end

function _M._get_41_2(flow)
	local _0 = _M._get_49_1(flow)

	return _C(41, "UnpackResPointPort", flow, _0, 2)
end

function _M._get_47_1(flow)
	local _0 = _M._get_50_2(flow)

	return _C(47, "SelectOneByRandom", flow, _0)
end

function _M._get_49_1(flow)
	local _0 = flow:getCache(49, "resPointPort")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_47_1(flow)

	flow:setCache(49, "resPointPort", _0)

	return _0
end

function _M._get_50_2(flow)
	local _0 = _C(46, "GetAoiResPointPortTableByLevel", flow, 0, 30, 0, {
		"TR_Test_DynamicVoxel"
	}, nil)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		flow:setCache(50, "__iterItem", v)

		if _M._get_52_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_52_2(flow)
	local _1 = flow:getCache(50, "__iterItem")
	local _0 = _C(51, "GetDistanceFromEntityToResPointPort", flow, 0, _1)

	return _0 < 30
end

return _M
