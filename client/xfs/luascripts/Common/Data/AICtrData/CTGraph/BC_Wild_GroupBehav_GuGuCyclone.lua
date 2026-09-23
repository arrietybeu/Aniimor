-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_GuGuCyclone.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value0)
	agent:addSubTreeLocalParam("tTimeout", value1)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_1(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8, value9)
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

local function _doBehaviourTail_2(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8)
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

function _M.executeEventTrigger(flow, eventName)
	if eventName == "GBPMsg_ResPoint01" then
		flow:setActive()

		local _0 = _M._get_17_2(flow)
		local _1 = _M._get_17_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _0, _1)

		return _M._to_20_0(flow)
	end

	if eventName == "GBPMsg_Common02" then
		return _M._to_51_0(flow)
	end

	if eventName == "GBPMsg_Common03" then
		return _M._to_75_0(flow)
	end

	if eventName == "GBPMsg_Common04" then
		return _M._to_66_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_17_2(flow)
	local _1 = _M._get_17_3(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 20 then
		return true
	end

	if nodeId == 29 then
		return true
	end

	if nodeId == 34 then
		return true
	end

	if nodeId == 36 then
		return true
	end

	if nodeId == 63 then
		return _M._to_79_0(flow)
	end

	if nodeId == 74 then
		return true
	end

	if nodeId == 78 then
		return true
	end

	if nodeId == 79 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_20_0(flow)
	if not _B(flow, "PBT_MoveToResPointPortInDist") then
		return
	end

	local _0 = _M._get_17_2(flow)
	local _1 = _M._get_17_3(flow)

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
	flow:setContinue(20)

	return true
end

function _M._to_29_0(flow)
	if not _B(flow, "PBT_Com_Node_OnlyShowBubble") then
		return
	end

	return _doBehaviourTail_0(flow, 29, "Love", 5)
end

function _M._to_34_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 34, 0, "Happy", 2, "Skill_DountStart", "Skill_DountLoop1", "Skill_DountEnd", 8, "", false, false)
end

function _M._to_36_0(flow)
	if not _B(flow, "PBT_Com_Node_OnlyShowBubble") then
		return
	end

	return _doBehaviourTail_0(flow, 36, "Laugh", 5)
end

function _M._to_51_0(flow)
	local _2 = _M._get_49_2(flow)
	local _0 = _2 == 1

	if _0 then
		return _M._to_34_0(flow)
	end

	local _3 = _M._get_49_2(flow)
	local _1 = _3 == 2

	if _1 then
		return _M._to_29_0(flow)
	end
end

function _M._to_63_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_2(flow, 63, 0, "Skill_Drift", 3, "", 0, "", false, false, false)
end

function _M._to_66_0(flow)
	local _2 = _M._get_69_2(flow)
	local _0 = _2 == 1

	if _0 then
		return _M._to_36_0(flow)
	end

	local _3 = _M._get_69_2(flow)
	local _1 = _3 == 2

	if _1 then
		return _M._to_74_0(flow)
	end
end

function _M._to_74_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 74, 0, "Upset", 5, "StunLoop", "StunLoop", "StunEnd", 8, "", false, false)
end

function _M._to_75_0(flow)
	local _2 = _M._get_62_2(flow)
	local _0 = _2 == 1

	if _0 then
		return _M._to_78_0(flow)
	end

	local _3 = _M._get_62_2(flow)
	local _1 = _3 == 2

	if _1 then
		return _M._to_63_0(flow)
	end
end

function _M._to_78_0(flow)
	if not _B(flow, "PBT_Com_Node_OnlyShowBubble") then
		return
	end

	return _doBehaviourTail_0(flow, 78, "Doubt", 5)
end

function _M._to_79_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_2(flow, 79, 0, "Skill_Drift", 3, "", 0, "", false, false, false)
end

function _M._get_17_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_17_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_49_2(flow)
	return flow:getContextValue("tRoleIndex")
end

function _M._get_62_2(flow)
	return flow:getContextValue("tRoleIndex")
end

function _M._get_69_2(flow)
	return flow:getContextValue("tRoleIndex")
end

return _M
