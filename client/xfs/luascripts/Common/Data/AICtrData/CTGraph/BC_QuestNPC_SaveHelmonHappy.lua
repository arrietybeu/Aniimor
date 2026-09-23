-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_QuestNPC_SaveHelmonHappy.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
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

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerStartHappy" then
		flow:setActive()

		local _0 = _C(24, "GetStaticId", flow, 0)

		_A(flow, "SetPlayerVar", _0, 999)

		return _M._to_25_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 9 then
		return _M._to_18_0(flow)
	end

	if nodeId == 18 then
		return true
	end

	if nodeId == 25 then
		return _M._to_9_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_9_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 9, 0, "Behav_Love", 6, "Laugh", 5, "", false, false, false)
end

function _M._to_18_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 18, 0, "Behav_Happy", 6, "Happy", 5, "", false, false, false)
end

function _M._to_25_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Love")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "EnvBehav_SnuggleStart")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "EnvBehav_SnuggleLoop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "EnvBehav_SnuggleEnd")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 6)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(25)

	return true
end

return _M
