-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10021_HideStart.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerHideStart" then
		return _M._to_100_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 100 then
		return _M._to_141_0(flow)
	end

	if nodeId == 141 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_100_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "AI_IdleSpecial01")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 3)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", true)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(100)

	return true
end

function _M._to_141_0(flow)
	if not _B(flow, "PBT_Behav_Com_MimicryIn") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(141)

	return true
end

return _M
