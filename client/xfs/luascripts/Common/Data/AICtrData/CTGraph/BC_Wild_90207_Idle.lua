-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_90207_Idle.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "TA_90207_EnterCombat")

		return _M._to_42_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 42 then
		return _M._to_43_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_42_0(flow)
	if not _B(flow, "PBT_SetFullbodyIdle") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "MimicrySkill")
	flow:setContinue(42)

	return true
end

function _M._to_43_0(flow)
	flow:setActive()
	_C(43, "SetAIBlackboardValue", flow, 0, "skillCd", 0)

	return true
end

return _M
