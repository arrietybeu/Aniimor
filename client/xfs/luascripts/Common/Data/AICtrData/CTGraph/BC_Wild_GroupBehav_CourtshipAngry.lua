-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_CourtshipAngry.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tAnimationKey", value1)
	agent:addSubTreeLocalParam("tAnimationTimeout", value2)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value3)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value4)
	agent:addSubTreeLocalParam("tTimelineTag", value5)
	agent:addSubTreeLocalParam("tNeedLoop", value6)
	agent:addSubTreeLocalParam("tAnimationPlayOnce", value7)
	agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", value8)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "GBPMsg_Common03" then
		return _M._to_42_0(flow)
	end

	if eventName == "GBPMsg_Common02" then
		return _M._to_41_0(flow)
	end

	if eventName == "GBPMsg_Common01" then
		return _M._to_43_0(flow)
	end

	if eventName == "GBPMsg_ResPoint01" then
		flow:setActive()

		local _0 = _M._get_46_2(flow)
		local _1 = _M._get_46_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _0, _1)

		return _M._to_47_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_46_2(flow)
	local _1 = _M._get_46_3(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 41 then
		return true
	end

	if nodeId == 42 then
		return true
	end

	if nodeId == 43 then
		return true
	end

	if nodeId == 47 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_41_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 41, 0, "Behav_AngryLoop", 5, "Angry", 10, "", false, false, false)
end

function _M._to_42_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 42, 2, "Behav_AngryLoop", 5, "Angry", 10, "", false, false, false)
end

function _M._to_43_0(flow)
	if not _B(flow, "PBT_Noop") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(43)

	return true
end

function _M._to_47_0(flow)
	if not _B(flow, "PBT_MoveToResPointPortInDist") then
		return
	end

	local _0 = _M._get_46_2(flow)
	local _1 = _M._get_46_3(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tPointId", _0)
	flow.__agent:addSubTreeLocalParam("tPortId", _1)
	flow.__agent:addSubTreeLocalParam("tTimeout", 1000)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 0)
	flow.__agent:addSubTreeLocalParam("tSpeed", 1)
	flow.__agent:addSubTreeLocalParam("tInteractDist", 0.2)
	flow.__agent:addSubTreeLocalParam("tIgnoreSelfBodySize", true)
	flow.__agent:addSubTreeLocalParam("tIgnorePointBodySize", true)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow:setContinue(47)

	return true
end

function _M._get_46_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_46_3(flow)
	return flow:getContextValue("tPortId")
end

return _M
