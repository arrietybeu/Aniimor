-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_PER_StareFriendly.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Event_PER_StareFriendly" then
		return _M._to_6_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 5 then
		return true
	end

	if nodeId == 6 then
		return _M._to_5_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_5_0(flow)
	if not _B(flow, "PBT_Behav_Com_StareFriendly") then
		return
	end

	local _0 = _M._get_0_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tRange", 0)
	flow:setContinue(5)

	return true
end

function _M._to_6_0(flow)
	if not _B(flow, "PBT_Node_Com_WaitAndFriendlyAlert") then
		return
	end

	local _0 = _M._get_0_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow:setContinue(6)

	return true
end

function _M._get_0_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

return _M
