-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_NSSwimMimicry.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerGenericTemplate" then
		return _M._to_29_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 29 then
		return _M._to_40_0(flow)
	end

	if nodeId == 40 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_29_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	local _0 = "SWIMMIMICRYOUT"

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", _0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(29)

	return true
end

function _M._to_40_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_34_1(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_31_1(flow)

		if _P(flow, 1, _1, 1, nil) then
			flow:setContinue(40)

			return true
		end
	else
		flow:setActiveFail()
	end
end

function _M._get_31_1(flow)
	local _1 = _M._get_49_2(flow)
	local _0 = _C(35, "UnpackResPointPort", flow, _1, 1)

	return _C(31, "GetRouteIdFromResPoint", flow, true, _0, 1)
end

function _M._get_34_1(flow)
	local _1 = _M._get_42_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_38_2(flow)
	local _1 = _M._get_42_2(flow)
	local _0 = _C(37, "GetDistanceFromEntityToResPointPort", flow, 0, _1)

	return _0 < 5
end

function _M._get_42_3(flow)
	local _0 = _C(41, "GetAoiResPointPortTableByLevel", flow, 0, 30, 0, {
		"TR_NS_GenericTemplate"
	}, nil)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(42, "__iterItem", v)

		if _M._get_38_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_42_2(flow)
	return flow:getCache(42, "__iterItem")
end

function _M._get_49_2(flow)
	local _0 = _M._get_42_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(49, "__iterItem", v)

		_1 = _M._get_50_2(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_50_2(flow)
	local _0 = flow:getCache(49, "__iterItem")

	return _C(50, "GetDistanceFromEntityToResPointPort", flow, 0, _0)
end

return _M
