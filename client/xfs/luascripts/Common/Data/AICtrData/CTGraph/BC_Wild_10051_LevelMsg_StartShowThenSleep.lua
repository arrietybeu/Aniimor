-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10051_LevelMsg_StartShowThenSleep.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerStartShow" then
		return _M._to_24_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 24 then
		return _M._to_25_0(flow)
	end

	if nodeId == 25 then
		return _M._to_27_0(flow)
	end

	if nodeId == 26 then
		return true
	end

	if nodeId == 27 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_24_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_12_1(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_14_1(flow)

		if _P(flow, 1, _1, 1, nil) then
			flow:setContinue(24)

			return true
		end
	else
		flow:setActiveFail()
	end
end

function _M._to_25_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Env_FlapHair")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 10)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", true)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", true)
	flow:setContinue(25)

	return true
end

function _M._to_27_0(flow)
	if not _B(flow, "PBT_Sleep") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("sleepTimeOut", 999)
	flow.__agent:addSubTreeLocalParam("tShowEmojiBubble", true)
	flow.__agent:addSubTreeLocalParam("tisLoop", false)
	flow:setContinue(27)

	return true
end

function _M._get_12_1(flow)
	local _1 = _M._get_22_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_14_1(flow)
	local _1 = _M._get_18_1(flow)
	local _0 = _C(13, "UnpackResPointPort", flow, _1, 1)

	return _C(14, "GetRouteIdFromResPoint", flow, false, _0)
end

function _M._get_15_2(flow)
	local _0 = flow:getCache(23, "__iterItem")

	return _C(15, "GetDistanceFromEntityToResPointPort", flow, 0, _0)
end

function _M._get_18_1(flow)
	local _0 = flow:getCache(18, "resPointPort")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_23_2(flow)

	flow:setCache(18, "resPointPort", _0)

	return _0
end

function _M._get_22_3(flow)
	local _0 = _C(17, "GetAoiResPointPortTableByLevel", flow, 0, 30, 0, {
		"TR_NS_GenericTemplate"
	}, nil)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(22, "__iterItem", v)

		_1[#_1 + 1] = v
	end

	return _1
end

function _M._get_23_2(flow)
	local _0 = _M._get_22_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(23, "__iterItem", v)

		_1 = _M._get_15_2(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

return _M
