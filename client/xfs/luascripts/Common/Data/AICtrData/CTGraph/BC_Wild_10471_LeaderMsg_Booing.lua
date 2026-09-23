-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10471_LeaderMsg_Booing.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Msg_LeaderMsg" then
		return _M._to_59_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 41 then
		return true
	end

	if nodeId == 57 then
		return _M._to_60_0(flow)
	end

	if nodeId == 59 then
		return _M._to_57_0(flow)
	end

	if nodeId == 60 then
		return _M._to_41_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_41_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_HappyStart")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_HappyLoop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_HappyEnd")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 9999)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", true)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(41)

	return true
end

function _M._to_57_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _C(62, "GetLeaderId", flow, 0)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(57)

	return true
end

function _M._to_59_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "SprintStop")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 1.75)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Surprise")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 1.75)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(59)

	return true
end

function _M._to_60_0(flow)
	if not _B(flow, "PBT_Wild_10501_DreamDialogue") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("firstDialogueId", 70008749)
	flow.__agent:addSubTreeLocalParam("lastDialogueId", 70008753)
	flow:setContinue(60)

	return true
end

return _M
