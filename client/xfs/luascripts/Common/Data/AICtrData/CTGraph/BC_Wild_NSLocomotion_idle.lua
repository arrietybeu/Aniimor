-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_NSLocomotion_idle.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_16_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 16 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_16_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_19_1(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_27_1(flow)

		if _P(flow, 1, _1, 0, nil) then
			flow:setContinue(16)

			return true
		end
	else
		flow:setActiveFail()
	end
end

function _M._get_15_3(flow)
	local _0 = _C(21, "GetAoiResPointPortTableByLevel", flow, 0, 30, 0, {
		"TR_NS_GenericTemplate"
	}, nil)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(15, "__iterItem", v)

		if _M._get_24_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_15_2(flow)
	return flow:getCache(15, "__iterItem")
end

function _M._get_19_1(flow)
	local _1 = _M._get_15_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_22_1(flow)
	local _0 = flow:getCache(22, "resPointPort")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_32_2(flow)

	flow:setCache(22, "resPointPort", _0)

	return _0
end

function _M._get_24_2(flow)
	local _1 = _M._get_15_2(flow)
	local _0 = _C(23, "GetDistanceFromEntityToResPointPort", flow, 0, _1)

	return _0 < 5
end

function _M._get_27_1(flow)
	local _1 = _M._get_22_1(flow)
	local _0 = _C(20, "UnpackResPointPort", flow, _1, 1)

	return _C(27, "GetRouteIdFromResPoint", flow, true, _0, 2)
end

function _M._get_32_2(flow)
	local _0 = _M._get_15_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(32, "__iterItem", v)

		_1 = _M._get_33_2(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_33_2(flow)
	local _0 = flow:getCache(32, "__iterItem")

	return _C(33, "GetDistanceFromEntityToResPointPort", flow, 0, _0)
end

return _M
