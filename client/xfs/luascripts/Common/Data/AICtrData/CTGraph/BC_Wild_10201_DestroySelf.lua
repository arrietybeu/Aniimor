-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_DestroySelf.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_101_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 97 then
		return true
	end

	if nodeId == 101 then
		return _M._to_97_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_97_0(flow)
	if not _B(flow, "PBT_DestroySelf") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(97)

	return true
end

function _M._to_101_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 20)
	flow:setContinue(101)

	return true
end

return _M
