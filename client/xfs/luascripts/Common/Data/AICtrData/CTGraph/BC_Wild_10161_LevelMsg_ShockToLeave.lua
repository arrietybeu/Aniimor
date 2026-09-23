-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10161_LevelMsg_ShockToLeave.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerSneakToLeave" then
		return _M._to_18_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 1 then
		return true
	end

	if nodeId == 18 then
		return _M._to_32_0(flow)
	end

	if nodeId == 32 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_18_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", -1)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Hit_Shake")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 1)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Surprise")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", true)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", true)
	flow:setContinue(18)

	return true
end

function _M._to_32_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_23_1(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_20_1(flow)

		if _P(flow, 1, _1, 1, nil) then
			flow:setContinue(32)

			return true
		end
	else
		flow:setActiveFail()
	end
end

function _M._get_20_1(flow)
	local _1 = _M._get_29_1(flow)
	local _0 = _C(30, "UnpackResPointPort", flow, _1, 1)

	return _C(20, "GetRouteIdFromResPoint", flow, true, _0, 1)
end

function _M._get_21_2(flow)
	local _0 = flow:getCache(22, "__iterItem")

	return _C(21, "GetDistanceFromEntityToResPointPort", flow, 0, _0)
end

function _M._get_22_2(flow)
	local _0 = _M._get_24_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(22, "__iterItem", v)

		_1 = _M._get_21_2(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_23_1(flow)
	local _1 = _M._get_24_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_24_3(flow)
	local _0 = _C(25, "GetAoiResPointPortTableByLevel", flow, 0, 50, 0, {
		"TR_NS_FollowRouteToEat"
	}, nil)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(24, "__iterItem", v)

		if _M._get_27_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_24_2(flow)
	return flow:getCache(24, "__iterItem")
end

function _M._get_27_2(flow)
	local _1 = _M._get_24_2(flow)
	local _0 = _C(28, "GetDistanceFromEntityToResPointPort", flow, 0, _1)

	return _0 < 5
end

function _M._get_29_1(flow)
	local _0 = flow:getCache(29, "resPointPort")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_22_2(flow)

	flow:setCache(29, "resPointPort", _0)

	return _0
end

return _M
