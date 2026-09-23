-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Npc_HappyHelgonNightSleep.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerDragonStartSleep" then
		return _M._to_35_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 38 then
		return true
	end

	if nodeId == 39 then
		return true
	end

	if nodeId == 43 then
		return _M._to_38_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_35_0(flow)
	local _1 = _C(26, "GetDayTime", flow)
	local _0 = _C(28, "IsSameDayTime", flow, _1, 2)

	if _0 then
		return _M._to_43_0(flow)
	end
end

function _M._to_38_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_SleepStart")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_SleepLoop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_SleepEnd")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", true)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(38)

	return true
end

function _M._to_43_0(flow)
	if not _B(flow, "PBT_TriggerBlueprint") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEventName", "StartSleep")
	flow:setContinue(43)

	return true
end

function _M._get_33_0(flow)
	return _C(33, "GetSelfId", flow)
end

return _M
