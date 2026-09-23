-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_Common_CombatDodge.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

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

	local _0 = _M._get_7_1(flow)

	if _0 then
		flow:setActive()
		_C(6, "DoBehaviour", flow, "PBT_Pet_CombatDodge")

		local _1 = flow:getContextValue("tTargetActorId")

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow:setContinue(6)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_7_1(flow)
	local _0 = _C(4, "IsInUltimateSkill", flow, 0)

	return not _0
end

return _M
