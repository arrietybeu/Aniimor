-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10291_FentuftCharge.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _P = CTHelper.DoPatrolBehavior
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerCharge" then
		return _M._to_1_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 1 then
		return _M._to_2_0(flow)
	end

	if nodeId == 2 then
		return _M._to_4_0(flow)
	end

	if nodeId == 3 then
		return true
	end

	if nodeId == 5 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_1_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 81640331, 1, nil) then
		flow:setContinue(1)

		return true
	end
end

function _M._to_2_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tSkillId", 12910200)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 3)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(2)

	return true
end

function _M._to_3_0(flow)
	if not _B(flow, "PBT_Behav_Com_Sleep") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSleepTimeout", 99999)
	flow.__agent:addSubTreeLocalParam("tisLoop", false)
	flow:setContinue(3)

	return true
end

function _M._to_4_0(flow)
	return _M._to_3_0(flow)
end

return _M
