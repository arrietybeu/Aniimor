-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10501_SleepSnore.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		flow:setActive()
		_A(flow, "AddEntityTag", 0, "TE_Wild_10501_Snore")

		return _M._to_2_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "RemoveEntityTag", 0, "TE_Wild_10501_Snore")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 2 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_2_0(flow)
	if not _B(flow, "PBT_Behav_Com_Sleep") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSleepTimeout", 999)
	flow.__agent:addSubTreeLocalParam("tisLoop", true)
	flow:setContinue(2)

	return true
end

return _M
