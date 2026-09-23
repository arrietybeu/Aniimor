-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_Habit_RespondToPlayerAction.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Event_PetRespondToPlayerAction" then
		return _M._to_163_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _C(173, "GetSelfId", flow)
	local _1 = _M._get_160_6(flow)

	_A(flow, "HideEmojiOnTarget", _0, _1)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 161 then
		return true
	end

	if nodeId == 163 then
		return _M._to_165_0(flow)
	end

	if nodeId == 164 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_161_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	local _0 = _M._get_160_6(flow)
	local _1 = flow:getContextValue("animationStartKey")
	local _2 = flow:getContextValue("animationLoopKey")
	local _3 = flow:getContextValue("animationEndKey")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", _0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 3)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", _1)
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", _2)
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", _3)
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", true)
	flow:setContinue(161)

	return true
end

function _M._to_163_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = flow:getContextValue("entityActorId")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(163)

	return true
end

function _M._to_164_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	local _0 = _M._get_160_2(flow)
	local _1 = _M._get_160_6(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", _0)
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", _1)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 3)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", true)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(164)

	return true
end

function _M._to_165_0(flow)
	local _1 = _M._get_170_2(flow)
	local _0 = not _1

	if _0 then
		return _M._to_164_0(flow)
	end

	return _M._to_161_0(flow)
end

function _M._get_160_2(flow)
	return flow:getContextValue("animationKey")
end

function _M._get_160_6(flow)
	return flow:getContextValue("emojiBubbleKey")
end

function _M._get_170_2(flow)
	local _2 = _M._get_160_2(flow)
	local _0 = _2 == nil

	if _0 then
		return true
	end

	local _3 = _M._get_160_2(flow)
	local _1 = _3 == ""

	if _1 then
		return true
	end

	return false
end

return _M
