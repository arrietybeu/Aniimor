-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_SingInTheStone.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "GBPMsg_ResPoint01" then
		flow:setActive()

		local _0 = _M._get_2_2(flow)
		local _1 = _M._get_2_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _0, _1)

		return _M._to_0_0(flow)
	end

	if eventName == "GBPMsg_Common01" then
		return _M._to_6_0(flow)
	end

	if eventName == "GBPMsg_ResPoint02" then
		return _M._to_8_0(flow)
	end

	if eventName == "GBPMsg_ResPoint03" then
		return _M._to_11_0(flow)
	end

	if eventName == "GBPMsg_ResPoint04" then
		return _M._to_13_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_2_2(flow)
	local _1 = _M._get_2_3(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 0 then
		return true
	end

	if nodeId == 6 then
		return true
	end

	if nodeId == 8 then
		return true
	end

	if nodeId == 11 then
		return true
	end

	if nodeId == 13 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_0_0(flow)
	if not _B(flow, "PBT_MoveToResPointPortInDist") then
		return
	end

	local _0 = _M._get_2_2(flow)
	local _1 = _M._get_2_3(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tPointId", _0)
	flow.__agent:addSubTreeLocalParam("tPortId", _1)
	flow.__agent:addSubTreeLocalParam("tTimeout", 1000)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tInteractDist", 0)
	flow.__agent:addSubTreeLocalParam("tIgnoreSelfBodySize", true)
	flow.__agent:addSubTreeLocalParam("tIgnorePointBodySize", true)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow:setContinue(0)

	return true
end

function _M._to_6_0(flow)
	if not _B(flow, "PBT_Com_Happy") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Behav_Happy")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 4)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow:setContinue(6)

	return true
end

function _M._to_8_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_9_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(8)

		return true
	end
end

function _M._to_11_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_12_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(11)

		return true
	end
end

function _M._to_13_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_14_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(13)

		return true
	end
end

function _M._get_2_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_2_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_9_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(9, "GetRouteIdFromResPoint", flow, true, _0, 1)
end

function _M._get_12_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(12, "GetRouteIdFromResPoint", flow, true, _0, 2)
end

function _M._get_14_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(14, "GetRouteIdFromResPoint", flow, true, _0, 3)
end

return _M
