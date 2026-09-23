-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_10021&10024.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tAnimationKey", value1)
	agent:addSubTreeLocalParam("tAnimationTimeout", value2)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value3)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value4)
	agent:addSubTreeLocalParam("tTimelineTag", value5)
	agent:addSubTreeLocalParam("tNeedLoop", value6)
	agent:addSubTreeLocalParam("tAnimationPlayOnce", value7)
	agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", value8)
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
		return _M._to_86_0(flow)
	end

	if eventName == "GBPMsg_Common02" then
		return _M._to_57_0(flow)
	end

	if eventName == "GBPMsg_Common03" then
		return _M._to_88_0(flow)
	end

	if eventName == "GBPMsg_Common04" then
		return _M._to_84_0(flow)
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
		return _M._to_87_0(flow)
	end

	if nodeId == 75 then
		return true
	end

	if nodeId == 77 then
		return true
	end

	if nodeId == 80 then
		return _M._to_75_0(flow)
	end

	if nodeId == 84 then
		return true
	end

	if nodeId == 86 then
		return _M._to_80_0(flow)
	end

	if nodeId == 87 then
		return _M._to_77_0(flow)
	end

	if nodeId == 88 then
		return true
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
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tInteractDist", 0)
	flow.__agent:addSubTreeLocalParam("tIgnoreSelfBodySize", true)
	flow.__agent:addSubTreeLocalParam("tIgnorePointBodySize", true)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow:setContinue(28)

	return true
end

function _M._to_57_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 57, 0, "AI_IdleSpecial01", 5, "", 0, "", false, false, false)
end

function _M._to_75_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 75, 0, "Attack02", 5, "", 0, "", false, false, false)
end

function _M._to_77_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 77, 0, "JumpBack", 5, "Surprise", 2, "", false, false, false)
end

function _M._to_80_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 80, 0, "Attack01", 5, "", 0, "", false, false, false)
end

function _M._to_84_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Angry")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 3)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_AngryStart")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_AngryLoop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_AngryEnd")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 4)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(84)

	return true
end

function _M._to_86_0(flow)
	if not _B(flow, "PBT_Com_Node_OnlyShowBubble") then
		return
	end

	return _doBehaviourTail_1(flow, 86, "Angry", 5)
end

function _M._to_87_0(flow)
	if not _B(flow, "PBT_Com_Node_OnlyShowBubble") then
		return
	end

	return _doBehaviourTail_1(flow, 87, "Proud", 2)
end

function _M._to_88_0(flow)
	if not _B(flow, "PBT_Com_Node_OnlyShowBubble") then
		return
	end

	return _doBehaviourTail_1(flow, 88, "Proud", 4)
end

function _M._get_25_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_25_3(flow)
	return flow:getContextValue("tPortId")
end

return _M
