-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_Yahaha_MimicryOut_Happy.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerYahaha" then
		return _M._to_14_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 14 then
		return _M._to_19_0(flow)
	end

	if nodeId == 19 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_14_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	local _0 = "MIMICRYOUT"

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", _0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Mimicry_End")
	flow:setContinue(14)

	return true
end

function _M._to_19_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_HappyStart")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_Happyloop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_HappyEnd")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", true)
	flow:setContinue(19)

	return true
end

return _M
