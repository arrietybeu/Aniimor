-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10161_MakeLove_Love.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
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

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Msg_MakeLove_Start" then
		return _M._to_13_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_97_2(flow)
	local _1 = flow:getMessageContext()

	_1.sourceActorId = flow.__actorId

	flow:sendMessage(_0, "Msg_MakeLove_End", _1)
	flow:setActive()

	local _2 = _M._get_87_0(flow)

	_A(flow, "LerpProperty", false, 1, _2)
	flow:setActive()

	local _3 = _M._get_87_0(flow)

	_A(flow, "HideEmojiOnTarget", _3, "")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 13 then
		return _M._to_101_0(flow)
	end

	if nodeId == 15 then
		return true
	end

	if nodeId == 101 then
		return _M._to_114_0(flow)
	end

	if nodeId == 122 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_13_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_97_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tStopDist", 0.3)
	flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0.5)
	flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 0)
	flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 0)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
	flow:setContinue(13)

	return true
end

function _M._to_15_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 15, 0, "Love", 10, "Behav_MakeLove_Start", "Behav_MakeLove_Loop", "Behav_MakeLove_End", 10, "", false, false)
end

function _M._to_101_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_97_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(101)

	return true
end

function _M._to_111_0(flow)
	flow:setActive()

	local _0 = _C(112, "GetSelfId", flow)
	local _1 = flow:getMessageContext()

	_1.sourceActorId = flow.__actorId

	flow:sendMessage(_0, "Msg_MakeLove_Unlock", _1)
	flow:setActive()

	local _2 = _C(119, "GetSelfId", flow)

	_A(flow, "SetPetAppearance", _2, 1111016101)
	flow:setActive()

	local _3 = _C(126, "GetSelfId", flow)

	_A(flow, "PlayEffectOnTarget", _3, "Eff_Parmon_10161_Behav_FlowerCloseToOpen", 0)

	return true
end

function _M._to_114_0(flow)
	do return _M._to_115_0(flow) end
	return _M._to_122_0(flow)
end

function _M._to_115_0(flow)
	flow:addTimer(2, _M, "_to_111_0", flow)

	return _M._to_15_0(flow)
end

function _M._to_122_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 122, 0, "Love", 10, "Behav_MakeLove_Start", "Behav_MakeLove_Loop", "Behav_MakeLove_End", 10, "", false, false)
end

function _M._to_123_0(flow)
	flow:setActive()

	local _0 = _C(124, "GetSelfId", flow)
	local _1 = flow:getMessageContext()

	_1.sourceActorId = flow.__actorId

	flow:sendMessage(_0, "Msg_MakeLove_Unlock", _1)
	flow:setActive()

	local _2 = _C(128, "GetSelfId", flow)

	_A(flow, "SetPetAppearance", _2, 1111016101)

	return true
end

function _M._get_87_0(flow)
	return _C(87, "GetSelfId", flow)
end

function _M._get_97_2(flow)
	return flow:getContextValue("TheOtherActorID")
end

function _M._get_116_1(flow)
	return _C(116, "GetEntProperty", flow, 0, "gender")
end

return _M
