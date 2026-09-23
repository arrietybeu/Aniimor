-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_HumorFriend CP.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8, value9)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value1)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value2)
	agent:addSubTreeLocalParam("tAnimationStartKey", value3)
	agent:addSubTreeLocalParam("tAnimationLoopKey", value4)
	agent:addSubTreeLocalParam("tAnimationEndKey", value5)
	agent:addSubTreeLocalParam("tAnimationTimeout", value6)
	agent:addSubTreeLocalParam("tTimelineTag", value7)
	agent:addSubTreeLocalParam("tNeedLoop", value8)
	agent:addSubTreeLocalParam("tAnimationPlayOnce", value9)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_1(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value0)
	agent:addSubTreeLocalParam("tTimeout", value1)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "GBPMsg_ResPoint01" then
		flow:setActive()

		local _0 = _M._get_25_2(flow)
		local _1 = _M._get_25_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _0, _1)

		return _M._to_28_0(flow)
	end

	if eventName == "GBPMsg_Common01" then
		return _M._to_103_0(flow)
	end

	if eventName == "GBPMsg_Common03" then
		return _M._to_57_0(flow)
	end

	if eventName == "GBPMsg_Common04" then
		return _M._to_112_0(flow)
	end

	if eventName == "GBPMsg_Common05" then
		return _M._to_97_0(flow)
	end

	if eventName == "GBPMsg_Common02" then
		return _M._to_108_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_25_2(flow)
	local _1 = _M._get_25_3(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 28 then
		return true
	end

	if nodeId == 57 then
		return _M._to_111_0(flow)
	end

	if nodeId == 83 then
		return true
	end

	if nodeId == 97 then
		return true
	end

	if nodeId == 103 then
		return true
	end

	if nodeId == 108 then
		return true
	end

	if nodeId == 111 then
		return true
	end

	if nodeId == 112 then
		return _M._to_83_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_28_0(flow)
	if not _B(flow, "PBT_MoveToResPointPortInDist") then
		return
	end

	local _0 = _M._get_25_2(flow)
	local _1 = _M._get_25_3(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tPointId", _0)
	flow.__agent:addSubTreeLocalParam("tPortId", _1)
	flow.__agent:addSubTreeLocalParam("tTimeout", 1000)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tInteractDist", 0)
	flow.__agent:addSubTreeLocalParam("tIgnoreSelfBodySize", true)
	flow.__agent:addSubTreeLocalParam("tIgnorePointBodySize", true)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow:setContinue(28)

	return true
end

function _M._to_57_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 57, 0, "Cry", 14, "Behav_CryStart", "Behav_CryLoop", "Behav_CryEnd", 15, "", false, false)
end

function _M._to_83_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 83, 0, "", 5, "Behav_LoveStart", "Behav_LoveLoop", "Behav_LoveEnd", 15, "", false, false)
end

function _M._to_97_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 97, 0, "Kiss", 3, "Behav_LoveStart", "Behav_LoveLoop", "Behav_LoveEnd", 7.5, "", false, false)
end

function _M._to_103_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "AI_IdleSpecial01")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 4)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Chat")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 3)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(103)

	return true
end

function _M._to_108_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 108, 0, "Angry", 3, "Behav_AngryStart", "Behav_AngryLoop", "Behav_AngryEnd", 4, "", false, false)
end

function _M._to_111_0(flow)
	if not _B(flow, "PBT_Com_Node_OnlyShowBubble") then
		return
	end

	return _doBehaviourTail_1(flow, 111, "Laugh", 3)
end

function _M._to_112_0(flow)
	if not _B(flow, "PBT_Com_Node_OnlyShowBubble") then
		return
	end

	return _doBehaviourTail_1(flow, 112, "Surprise", 3)
end

function _M._get_25_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_25_3(flow)
	return flow:getContextValue("tPortId")
end

return _M
