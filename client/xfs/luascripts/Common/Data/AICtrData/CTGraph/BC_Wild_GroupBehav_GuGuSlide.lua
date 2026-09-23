-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_GuGuSlide.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "GBPMsg_ResPoint01" then
		flow:setActive()

		local _0 = _M._get_17_2(flow)
		local _1 = _M._get_17_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _0, _1)

		return _M._to_20_0(flow)
	end

	if eventName == "GBPMsg_Common03" then
		return _M._to_50_0(flow)
	end

	if eventName == "GBPMsg_Common02" then
		return _M._to_56_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_17_2(flow)
	local _1 = _M._get_17_3(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 20 then
		return true
	end

	if nodeId == 49 then
		return true
	end

	if nodeId == 51 then
		return true
	end

	if nodeId == 52 then
		return true
	end

	if nodeId == 56 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_20_0(flow)
	if not _B(flow, "PBT_MoveToResPointPortInDist") then
		return
	end

	local _0 = _M._get_17_2(flow)
	local _1 = _M._get_17_3(flow)

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
	flow:setContinue(20)

	return true
end

function _M._to_49_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 80650130, 1, nil) then
		flow:setContinue(49)

		return true
	end
end

function _M._to_50_0(flow)
	local _3 = _M._get_27_2(flow)
	local _0 = _3 == 1

	if _0 then
		return _M._to_49_0(flow)
	end

	local _4 = _M._get_27_2(flow)
	local _1 = _4 == 2

	if _1 then
		return _M._to_51_0(flow)
	end

	local _5 = _M._get_27_2(flow)
	local _2 = _5 == 3

	if _2 then
		return _M._to_52_0(flow)
	end
end

function _M._to_51_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 80650131, 1, nil) then
		flow:setContinue(51)

		return true
	end
end

function _M._to_52_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 80650132, 1, nil) then
		flow:setContinue(52)

		return true
	end
end

function _M._to_56_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 2)
	flow:setContinue(56)

	return true
end

function _M._get_17_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_17_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_27_2(flow)
	return flow:getContextValue("tRoleIndex")
end

return _M
