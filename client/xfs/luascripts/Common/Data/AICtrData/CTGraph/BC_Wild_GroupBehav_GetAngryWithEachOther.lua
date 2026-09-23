-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_GetAngryWithEachOther.lua

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

function _M.executeEventTrigger(flow, eventName)
	if eventName == "GBPMsg_ResPoint01" then
		flow:setActive()

		local _0 = _M._get_123_2(flow)
		local _1 = _M._get_123_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _0, _1)

		return _M._to_126_0(flow)
	end

	if eventName == "GBPMsg_Common02" then
		return _M._to_156_0(flow)
	end

	if eventName == "GBPMsg_Common01" then
		return _M._to_155_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_123_2(flow)
	local _1 = _M._get_123_3(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 126 then
		return true
	end

	if nodeId == 151 then
		return _M._to_152_0(flow)
	end

	if nodeId == 152 then
		return true
	end

	if nodeId == 153 then
		return _M._to_154_0(flow)
	end

	if nodeId == 154 then
		return true
	end

	if nodeId == 155 then
		return _M._to_151_0(flow)
	end

	if nodeId == 156 then
		return _M._to_153_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_126_0(flow)
	if not _B(flow, "PBT_MoveToResPointPortInDist") then
		return
	end

	local _0 = _M._get_123_2(flow)
	local _1 = _M._get_123_3(flow)

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
	flow:setContinue(126)

	return true
end

function _M._to_151_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 151, 0, "Attack01", 2, "", 1, "", false, false, false)
end

function _M._to_152_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 152, 0, "Attack02", 2, "", 0, "", false, false, false)
end

function _M._to_153_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 153, 0, "Attack02", 2, "", 1, "", false, false, false)
end

function _M._to_154_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 154, 0, "Attack01", 2, "", 0, "", false, false, false)
end

function _M._to_155_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 155, 0, "Behav_Angry", 2, "Angry", 1, "", false, false, false)
end

function _M._to_156_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 156, 0, "Behav_Angry", 2, "Angry", 1, "", false, false, false)
end

function _M._get_123_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_123_2(flow)
	return flow:getContextValue("tPointId")
end

return _M
