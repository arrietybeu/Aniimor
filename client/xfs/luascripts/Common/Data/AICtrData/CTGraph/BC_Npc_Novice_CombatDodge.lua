-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Npc_Novice_CombatDodge.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "CombatDodgeTrigger" then
		return _M._to_6_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 6 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_6_0(flow)
	if not _B(flow, "PBT_Pet_CombatDodge") then
		return
	end

	local _0 = flow:getContextValue("tTargetActorId")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow:setContinue(6)

	return true
end

return _M
