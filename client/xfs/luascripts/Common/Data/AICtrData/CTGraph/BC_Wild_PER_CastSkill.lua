-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_PER_CastSkill.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "PercpetEntityReactionTriggerCastSkiill" then
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
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_10_2(flow)
	local _1 = _M._get_0_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tSkillId", _0)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _1)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(5)

	return true
end

function _M._to_6_0(flow)
	if not _B(flow, "PBT_Node_Com_SensedAlert") then
		return
	end

	local _0 = _M._get_0_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow:setContinue(6)

	return true
end

function _M._get_0_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_10_2(flow)
	local _0 = flow:getContextValue("interactArg")

	return _C(10, "GetTableValueByKey", flow, _0, 1)
end

return _M
