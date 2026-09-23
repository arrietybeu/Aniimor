-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10023_AlertRoute.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerTest_Alert" then
		return _M._to_38_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 27 then
		return true
	end

	if nodeId == 35 then
		return true
	end

	if nodeId == 38 then
		return _M._to_43_0(flow)
	end

	if nodeId == 43 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_38_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_16_1(flow)

	if _0 then
		flow:setActive()
		_C(38, "DoBehaviour", flow, "PBT_TurnToTargetAtYaw")

		local _1 = _M._get_42_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTgtId", _1)
		flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
		flow.__agent:addSubTreeLocalParam("tInstant", false)
		flow:setContinue(38)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_43_0(flow)
	if not _B(flow, "PBT_Com_Node_OnlyShowBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Angry")
	flow.__agent:addSubTreeLocalParam("tTimeout", 5)
	flow:setContinue(43)

	return true
end

function _M._get_14_1(flow)
	local _0 = _M._get_23_3(flow)

	return _C(14, "SelectOneByRandom", flow, _0)
end

function _M._get_16_1(flow)
	local _1 = _M._get_23_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_19_1(flow)
	local _0 = flow:getCache(19, "resPointPort")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_14_1(flow)

	flow:setCache(19, "resPointPort", _0)

	return _0
end

function _M._get_22_2(flow)
	local _1 = _M._get_23_2(flow)
	local _0 = _C(21, "GetDistanceFromEntityToResPointPort", flow, 0, _1)

	return _0 < 30
end

function _M._get_23_3(flow)
	local _0 = _C(18, "GetAoiResPointPortTableByLevel", flow, 0, 30, 0, {
		"TR_10023_HelgonBus"
	}, nil)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(23, "__iterItem", v)

		if _M._get_22_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_23_2(flow)
	return flow:getCache(23, "__iterItem")
end

function _M._get_25_1(flow)
	local _1 = _M._get_19_1(flow)
	local _0 = _C(17, "UnpackResPointPort", flow, _1, 1)

	return _C(25, "GetRouteIdFromResPoint", flow, true, _0, 2)
end

function _M._get_42_1(flow)
	local _0 = _C(41, "GetAoiEntityTableByLevel", flow, 0, 30, 2)

	return _C(42, "SelectOneByRandom", flow, _0)
end

return _M
