-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_SkippySlide.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "GBPMsg_ResPoint02" then
		return _M._to_47_0(flow)
	end

	if eventName == "GBPMsg_ResPoint01" then
		flow:setActive()

		local _0 = _M._get_42_2(flow)
		local _1 = _M._get_42_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _0, _1)

		return _M._to_44_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_42_2(flow)
	local _1 = _M._get_42_3(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 44 then
		return true
	end

	if nodeId == 47 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_44_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_42_2(flow)
	local _1 = _M._get_42_3(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tPointId", _0)
	flow.__agent:addSubTreeLocalParam("tPortId", _1)
	flow.__agent:addSubTreeLocalParam("tTimeout", 1000)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tSpeed", 1)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow:setContinue(44)

	return true
end

function _M._to_47_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_48_1(flow)

	if _P(flow, 1, _0, 0, nil) then
		flow:setContinue(47)

		return true
	end
end

function _M._get_42_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_42_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_48_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(48, "GetRouteIdFromResPoint", flow, true, _0, 1)
end

return _M
