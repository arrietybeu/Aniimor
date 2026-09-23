-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10141_KongMingLantern_Come.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8, value9)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tTargetActorId", value0)
	agent:addSubTreeLocalParam("tStopDist", value1)
	agent:addSubTreeLocalParam("tMaxTimeout", value2)
	agent:addSubTreeLocalParam("tFaceTarget", value3)
	agent:addSubTreeLocalParam("tSpeed", value4)
	agent:addSubTreeLocalParam("tMoveUpdateLevel", value5)
	agent:addSubTreeLocalParam("tPathFindType", value6)
	agent:addSubTreeLocalParam("tSpeedRateType", value7)
	agent:addSubTreeLocalParam("tUseAccurateArrive", value8)
	agent:addSubTreeLocalParam("tNoBodySize", value9)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_1(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8)
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

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Msg_KMLantern_come" then
		return _M._to_16_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 1 then
		return _M._to_12_0(flow)
	end

	if nodeId == 11 then
		return true
	end

	if nodeId == 12 then
		return _M._to_11_0(flow)
	end

	if nodeId == 15 then
		return _M._to_1_0(flow)
	end

	if nodeId == 19 then
		return _M._to_20_0(flow)
	end

	if nodeId == 20 then
		return _M._to_21_0(flow)
	end

	if nodeId == 21 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_1_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = flow:getContextValue("sourceActorId")
	local _1 = _C(13, "RandomInteger", flow, 1, 2)

	return _doBehaviourTail_0(flow, 1, _0, _1, 5, false, 0, 99999, 0, 1, false, false)
end

function _M._to_11_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 11, 10, "Idle", 5, "", 3, "", false, false, false)
end

function _M._to_12_0(flow)
	if not _B(flow, "PBT_SwitchToFly") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tFlyHeight", 0)
	flow.__agent:addSubTreeLocalParam("tMaxTime", 2)
	flow:setContinue(12)

	return true
end

function _M._to_15_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Love")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow:setContinue(15)

	return true
end

function _M._to_16_0(flow)
	local _1 = _C(17, "RandomInteger", flow, 0, 1)
	local _0 = _1 > 0.7

	if _0 then
		return _M._to_15_0(flow)
	end

	return _M._to_19_0(flow)
end

function _M._to_19_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _C(23, "RandomInteger", flow, 1, 2)

	return _doBehaviourTail_0(flow, 19, 0, _0, 5, false, 0, 99999, 0, 1, false, false)
end

function _M._to_20_0(flow)
	if not _B(flow, "PBT_SwitchToFly") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tFlyHeight", 0)
	flow.__agent:addSubTreeLocalParam("tMaxTime", 2)
	flow:setContinue(20)

	return true
end

function _M._to_21_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 21, 10, "Idle", 5, "", 3, "", false, false, false)
end

return _M
