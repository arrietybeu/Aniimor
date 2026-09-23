-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_Home_Leisure_RandomPerformance.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Msg_Home_Leisure_Walk" then
		return _M._to_2_0(flow)
	end

	if eventName == "Msg_Home_Leisure_Mount" then
		return _M._to_11_0(flow)
	end

	if eventName == "Msg_Home_Leisure_Petting" then
		return _M._to_12_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 2 then
		return _M._to_5_0(flow)
	end

	if nodeId == 11 then
		return true
	end

	if nodeId == 12 then
		return _M._to_13_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_2_0(flow)
	if not _B(flow, "PBT_Behav_Home_Leisure_RandomPerformance") then
		return
	end

	local _0 = flow:getContextValue("isStartLoopEndAnim")
	local _1 = flow:getContextValue("animationStartKey")
	local _2 = flow:getContextValue("animationLoopKey")
	local _3 = flow:getContextValue("animationEndKey")
	local _4 = flow:getContextValue("emojiKey")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tIsStartLoopEndAnim", _0)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", _1)
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", _2)
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", _3)
	flow.__agent:addSubTreeLocalParam("tEmojiKey", _4)
	flow.__agent:addSubTreeLocalParam("tBornPos", nil)
	flow:setContinue(2)

	return true
end

function _M._to_5_0(flow)
	flow:setActive()

	local _0 = flow:getContextValue("revision")

	_A(flow, "FinishHomeLandLeisure", _0)

	return true
end

function _M._to_11_0(flow)
	if not _B(flow, "PBT_Behav_Home_Leisure_Mount") then
		return
	end

	local _0 = flow:getContextValue("vehiclePos")
	local _1 = flow:getContextValue("vehicleActorId")
	local _2 = flow:getContextValue("seatIndex")
	local _3 = flow:getContextValue("revision")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tVehiclePos", _0)
	flow.__agent:addSubTreeLocalParam("tVehicleActorId", _1)
	flow.__agent:addSubTreeLocalParam("tSeatIndex", _2)
	flow.__agent:addSubTreeLocalParam("tRevision", _3)
	flow:setContinue(11)

	return true
end

function _M._to_12_0(flow)
	if not _B(flow, "PBT_Behav_Home_Leisure_Petting") then
		return
	end

	local _0 = flow:getContextValue("targetActorId")
	local _1 = _M._get_14_1(flow)
	local _2 = flow:getContextValue("emojiKey")
	local _3 = flow:getContextValue("animationStartKey")
	local _4 = flow:getContextValue("animationLoopKey")
	local _5 = flow:getContextValue("animationEndKey")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tIsMasterInIdle", _1)
	flow.__agent:addSubTreeLocalParam("tMoveDist", 0)
	flow.__agent:addSubTreeLocalParam("tStopLoop", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiKey", _2)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", _3)
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", _4)
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", _5)
	flow:setContinue(12)

	return true
end

function _M._to_13_0(flow)
	flow:setActive()

	local _0 = flow:getContextValue("revision")

	_A(flow, "FinishHomeLandLeisure", _0)

	return true
end

function _M._get_14_1(flow)
	local _0 = _C(9, "GetPetMaster", flow, 0)

	return _C(14, "IsInCharState", flow, _0, 1, 4)
end

return _M
