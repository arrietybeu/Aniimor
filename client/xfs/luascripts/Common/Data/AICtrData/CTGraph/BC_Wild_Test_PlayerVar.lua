-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_Test_PlayerVar.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "RecruitMoveToPointMsgTrigger" then
		return _M._to_53_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 53 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_53_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 1000000)
	flow:setContinue(53)

	return true
end

return _M
