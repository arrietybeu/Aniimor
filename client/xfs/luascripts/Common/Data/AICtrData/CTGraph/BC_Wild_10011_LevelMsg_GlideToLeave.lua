-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10011_LevelMsg_GlideToLeave.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerStartShow" then
		return _M._to_14_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 14 then
		return _M._to_20_0(flow)
	end

	if nodeId == 20 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_14_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_7_1(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_17_1(flow)

		if _P(flow, 2, _1, 1, nil) then
			flow:setContinue(14)

			return true
		end
	else
		flow:setActiveFail()
	end
end

function _M._to_20_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_24_1(flow)

	if _0 then
		flow:setActive()
		_C(20, "DoBehaviour", flow, "PBT_LeaveTargetAndDestroy")

		local _1 = _M._get_23_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tLeaveDistance", 5)
		flow.__agent:addSubTreeLocalParam("tSpeed", 4)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
		flow.__agent:addSubTreeLocalParam("tMaxTime", 10)
		flow.__agent:addSubTreeLocalParam("tDestroyOnFail", false)
		flow:setContinue(20)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_7_1(flow)
	local _1 = _M._get_16_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_9_1(flow)
	local _0 = flow:getCache(9, "resPointPort")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_18_2(flow)

	flow:setCache(9, "resPointPort", _0)

	return _0
end

function _M._get_12_2(flow)
	local _1 = _M._get_16_2(flow)
	local _0 = _C(11, "GetDistanceFromEntityToResPointPort", flow, 0, _1)

	return _0 < 5
end

function _M._get_16_3(flow)
	local _0 = _C(15, "GetAoiResPointPortTableByLevel", flow, 0, 30, 0, {
		"TR_NS_GenericTemplate"
	}, nil)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(16, "__iterItem", v)

		if _M._get_12_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_16_2(flow)
	return flow:getCache(16, "__iterItem")
end

function _M._get_17_1(flow)
	local _1 = _M._get_9_1(flow)
	local _0 = _C(8, "UnpackResPointPort", flow, _1, 1)

	return _C(17, "GetRouteIdFromResPoint", flow, false, _0)
end

function _M._get_18_2(flow)
	local _0 = _M._get_16_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(18, "__iterItem", v)

		_1 = _M._get_19_2(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_19_2(flow)
	local _0 = flow:getCache(18, "__iterItem")

	return _C(19, "GetDistanceFromEntityToResPointPort", flow, 0, _0)
end

function _M._get_22_1(flow)
	local _0 = _M._get_27_3(flow)

	return _C(22, "SelectOneByRandom", flow, _0)
end

function _M._get_23_1(flow)
	local _0 = flow:getCache(23, "312")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_22_1(flow)

	flow:setCache(23, "312", _0)

	return _0
end

function _M._get_24_1(flow)
	local _1 = _M._get_27_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_27_3(flow)
	local _0 = _C(26, "GetAoiEntityTableByLevel", flow, 0, 100, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(27, "__iterItem", v)

		_1[#_1 + 1] = v
	end

	return _1
end

return _M
