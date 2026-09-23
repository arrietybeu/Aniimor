-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_LevelMsg_FollowRouteThenChangeSense.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerGenericTemplate" then
		return _M._to_23_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 23 then
		return _M._to_31_0(flow)
	end

	if nodeId == 31 then
		return _M._to_37_0(flow)
	end

	if nodeId == 37 then
		return _M._to_20_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_20_0(flow)
	flow:setActive()
	_A(flow, "SetVisionAreaOverride", "visionAreaMid")

	return true
end

function _M._to_23_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	local _0 = "LOCOMOTION"

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", _0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(23)

	return true
end

function _M._to_31_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_25_1(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_34_1(flow)

		if _P(flow, 1, _1, 1, nil) then
			flow:setContinue(31)

			return true
		end
	else
		flow:setActiveFail()
	end
end

function _M._to_37_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 1)
	flow:setContinue(37)

	return true
end

function _M._get_25_1(flow)
	local _1 = _M._get_33_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_29_2(flow)
	local _1 = _M._get_33_2(flow)
	local _0 = _C(28, "GetDistanceFromEntityToResPointPort", flow, 0, _1)

	return _0 < 5
end

function _M._get_33_3(flow)
	local _0 = _C(32, "GetAoiResPointPortTableByLevel", flow, 0, 30, 0, {
		"TR_NS_GenericTemplate"
	}, nil)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(33, "__iterItem", v)

		if _M._get_29_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_33_2(flow)
	return flow:getCache(33, "__iterItem")
end

function _M._get_34_1(flow)
	local _1 = _M._get_35_2(flow)
	local _0 = _C(26, "UnpackResPointPort", flow, _1, 1)

	return _C(34, "GetRouteIdFromResPoint", flow, false, _0)
end

function _M._get_35_2(flow)
	local _0 = _M._get_33_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(35, "__iterItem", v)

		_1 = _M._get_36_2(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_36_2(flow)
	local _0 = flow:getCache(35, "__iterItem")

	return _C(36, "GetDistanceFromEntityToResPointPort", flow, 0, _0)
end

return _M
