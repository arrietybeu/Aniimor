-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_VisionValue_10022_LevelMsg.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerDragonCry" then
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "TA_VisionFull")

		return _M._to_90_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 90 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_90_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Cry")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_CryStart")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_CryLoop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_CryEnd")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 2)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(90)

	return true
end

return _M
