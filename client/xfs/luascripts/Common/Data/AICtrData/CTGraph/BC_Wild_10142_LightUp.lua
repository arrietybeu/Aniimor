-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10142_LightUp.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_2_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 0 then
		return true
	end

	if nodeId == 2 then
		return _M._to_0_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_0_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tSkillId", 11420900)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(0)

	return true
end

function _M._to_2_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	local _0 = _C(3, "RandomInteger", flow, 0, 2)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", _0)
	flow:setContinue(2)

	return true
end

return _M
