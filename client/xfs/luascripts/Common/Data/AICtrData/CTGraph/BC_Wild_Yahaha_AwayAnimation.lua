-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_Yahaha_AwayAnimation.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerYahahaAway" then
		return _M._to_22_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 22 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_22_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Behav_Cry")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 4)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Cry")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 2)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(22)

	return true
end

return _M
