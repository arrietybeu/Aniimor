-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_1023102_AwayFromSparki.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value0)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value1)
	flow:setContinue(nodeId)

	return true
end

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Msg_NeedToRunAway" then
		return _M._to_1_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 0 then
		return _M._to_5_0(flow)
	end

	if nodeId == 1 then
		return _M._to_4_0(flow)
	end

	if nodeId == 2 then
		return _M._to_0_0(flow)
	end

	if nodeId == 3 then
		return true
	end

	if nodeId == 4 then
		return _M._to_2_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_0_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_0(flow, 0, "Cry", 10)
end

function _M._to_1_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0.8)
	flow:setContinue(1)

	return true
end

function _M._to_2_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0.8)
	flow:setContinue(2)

	return true
end

function _M._to_3_0(flow)
	if not _B(flow, "PBT_Wild_10231_Leave") then
		return
	end

	local _0 = flow:getContextValue("sourceActorId")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tLeaveDistance", 60)
	flow.__agent:addSubTreeLocalParam("tSpeed", 6)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
	flow.__agent:addSubTreeLocalParam("tMaxTime", 5)
	flow:setContinue(3)

	return true
end

function _M._to_4_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_0(flow, 4, "Surprise", 0.8)
end

function _M._to_5_0(flow)
	flow:setActive()

	local _0 = _C(6, "GetSelfId", flow)

	_A(flow, "RemoveEntityTag", _0, "TE_Wild_10231_GetClose")

	return _M._to_3_0(flow)
end

return _M
