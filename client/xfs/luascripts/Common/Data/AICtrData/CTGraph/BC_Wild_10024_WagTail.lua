-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10024_WagTail.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
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
	if eventName == "LevelMsgTriggerWagTail" then
		return _M._to_112_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 112 then
		return _M._to_113_0(flow)
	end

	if nodeId == 113 then
		return _M._to_114_0(flow)
	end

	if nodeId == 114 then
		return _M._to_115_0(flow)
	end

	if nodeId == 115 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_112_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 112, 0, "Behav_LoveLoop", 2, "", 0, "", true, false, false)
end

function _M._to_113_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 113, 0, "Behav_LoveEnd", 3, "", 0, "", false, true, false)
end

function _M._to_114_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 114, 0, "JumpBack", 3, "", 0, "", false, true, false)
end

function _M._to_115_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 115, 0, "IdleSpecial", 3, "", 0, "", false, true, false)
end

return _M
