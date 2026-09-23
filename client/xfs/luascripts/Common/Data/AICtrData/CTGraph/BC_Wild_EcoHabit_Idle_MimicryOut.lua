-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_EcoHabit_Idle_MimicryOut.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_87_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 87 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_87_0(flow)
	if not _B(flow, "PBT_Behav_Com_MimicryOut") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(87)

	return true
end

return _M
