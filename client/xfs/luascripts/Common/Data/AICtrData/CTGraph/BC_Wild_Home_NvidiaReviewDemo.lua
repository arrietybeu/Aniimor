-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_Home_NvidiaReviewDemo.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "NvidiaReviewDemoTrigger" then
		return _M._to_2_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 2 then
		return _M._to_11_0(flow)
	end

	if nodeId == 12 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_2_0(flow)
	if not _B(flow, "PBT_Behav_Home_NvidiaReviewDemo") then
		return
	end

	local _0 = flow:getContextValue("animationKey")
	local _1 = flow:getContextValue("emojiKey")
	local _2 = _M._get_7_2(flow)
	local _3 = _M._get_8_2(flow)
	local _4 = _M._get_9_2(flow)
	local _5 = flow:getContextValue("speed")
	local _6 = flow:getContextValue("speedRateType")
	local _7 = flow:getContextValue("actorId")
	local _8 = flow:getContextValue("animationTime")
	local _9 = flow:getContextValue("emojiTime")
	local _10 = flow:getContextValue("targetPos")
	local _11 = flow:getContextValue("stopDist")
	local _12 = flow:getContextValue("isFollow")
	local _13 = flow:getContextValue("isGoTargetPos")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tAnimationKey", _0)
	flow.__agent:addSubTreeLocalParam("tEmojiKey", _1)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", _2)
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", _3)
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", _4)
	flow.__agent:addSubTreeLocalParam("tSpeed", _5)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", _6)
	flow.__agent:addSubTreeLocalParam("tActorId", _7)
	flow.__agent:addSubTreeLocalParam("tAnimationTime", _8)
	flow.__agent:addSubTreeLocalParam("tEmojiTime", _9)
	flow.__agent:addSubTreeLocalParam("tTargetPos", _10)
	flow.__agent:addSubTreeLocalParam("tStopDist", _11)
	flow.__agent:addSubTreeLocalParam("tIsFollow", _12)
	flow.__agent:addSubTreeLocalParam("tMoveDist", 0)
	flow.__agent:addSubTreeLocalParam("tIsGoTargetPos", _13)
	flow:setContinue(2)

	return true
end

function _M._to_11_0(flow)
	flow:setActive()
	_A(flow, "FinishHomeLandOperation", false)

	return _M._to_12_0(flow)
end

function _M._to_12_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	local _0 = flow:getContextValue("waitTime")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", _0)
	flow:setContinue(12)

	return true
end

function _M._get_5_2(flow)
	return flow:getContextValue("animationLoopKey")
end

function _M._get_7_2(flow)
	local _0 = _M._get_5_2(flow)

	return _C(7, "GetTableValueByKey", flow, _0, 1)
end

function _M._get_8_2(flow)
	local _0 = _M._get_5_2(flow)

	return _C(8, "GetTableValueByKey", flow, _0, 2)
end

function _M._get_9_2(flow)
	local _0 = _M._get_5_2(flow)

	return _C(9, "GetTableValueByKey", flow, _0, 3)
end

return _M
