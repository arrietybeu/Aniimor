-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10031_Invisible.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerStartInvisible" then
		return _M._to_16_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 16 then
		return _M._to_20_0(flow)
	end

	if nodeId == 20 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_16_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _C(17, "GetSelfId", flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tSkillId", 10320901)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Surprise")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(16)

	return true
end

function _M._to_20_0(flow)
	if not _B(flow, "PBT_AddBuff") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tBuffId", 2103220)
	flow.__agent:addSubTreeLocalParam("duration", -1)
	flow:setContinue(20)

	return true
end

return _M
