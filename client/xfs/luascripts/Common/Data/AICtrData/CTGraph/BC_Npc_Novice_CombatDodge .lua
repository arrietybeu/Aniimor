-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Npc_Novice_CombatDodge .lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local CTRConst = require("Common.AICt.CTRConst")
local _M = {}
local _C = CTHelper.SafeCall
local _eventTriggerList = {
	"CombatDodgeTrigger"
}

function _M.getEventTriggerList()
	return _eventTriggerList
end

local _messageTriggerList = {}

function _M.getMessageTriggerList()
	return _messageTriggerList
end

local _tickLodTriggerLevel = -1

function _M.getTickLodTriggerLevel()
	return _tickLodTriggerLevel
end

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
	if flow.__isAdditive then
		return
	end

	flow:setActive()
	_C(6, "DoBehaviour", flow, "PBT_Pet_CombatDodge")

	local _0 = _M._get_1_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow:setContinue(6)

	return true
end

function _M._get_1_1(flow)
	return flow:getContextValue("tTargetActorId")
end

return _M
