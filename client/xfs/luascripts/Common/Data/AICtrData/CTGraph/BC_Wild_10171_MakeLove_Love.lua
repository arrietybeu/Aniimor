-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10171_MakeLove_Love.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Msg_MakeLove_Start" then
		return _M._to_13_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	return _M._to_114_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 13 then
		return _M._to_101_0(flow)
	end

	if nodeId == 15 then
		return true
	end

	if nodeId == 101 then
		return _M._to_14_0(flow)
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
	flow.__agent:addSubTreeLocalParam("tStopDist", 0.5)
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

function _M._to_14_0(flow)
	flow:setActive()

	local _0 = _C(51, "GetSelfId", flow)

	_A(flow, "LerpProperty", true, 2, _0)

	return _M._to_113_0(flow)
end

function _M._to_15_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Love")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 10)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_MakeLove_Start")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_MakeLove_Loop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_MakeLove_End")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 10)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(15)

	return true
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

	return true
end

function _M._to_113_0(flow)
	flow:addTimer(2, _M, "_to_111_0", flow)

	return _M._to_15_0(flow)
end

function _M._to_114_0(flow)
	local _0 = _M._get_123_3(flow)

	if _0 then
		flow:setActive()

		local _5 = _C(125, "GetSelfId", flow)

		_A(flow, "SendMessageToTrigger", _5, 1018103)
		flow:setActive()

		local _6 = _M._get_97_2(flow)
		local _7 = flow:getMessageContext()

		_7.sourceActorId = flow.__actorId

		flow:sendMessage(_6, "Msg_MakeLove_End", _7)
		flow:setActive()

		local _8 = _M._get_128_0(flow)

		_A(flow, "LerpProperty", false, 1, _8)
		flow:setActive()

		local _9 = _M._get_128_0(flow)

		_A(flow, "HideEmojiOnTarget", _9, "")

		return true
	end

	flow:setActive()

	local _1 = _M._get_97_2(flow)
	local _2 = flow:getMessageContext()

	_2.sourceActorId = flow.__actorId

	flow:sendMessage(_1, "Msg_MakeLove_End", _2)
	flow:setActive()

	local _3 = _M._get_87_0(flow)

	_A(flow, "LerpProperty", false, 1, _3)
	flow:setActive()

	local _4 = _M._get_87_0(flow)

	_A(flow, "HideEmojiOnTarget", _4, "")

	return true
end

function _M._get_87_0(flow)
	return _C(87, "GetSelfId", flow)
end

function _M._get_97_2(flow)
	return flow:getContextValue("TheOtherActorID")
end

function _M._get_123_3(flow)
	local _6 = _M._get_133_1(flow)
	local _3 = _C(130, "GetDistance", flow, _6, 0, false)
	local _0 = _3 <= 12

	if not _0 then
		return false
	end

	local _4 = _M._get_133_1(flow)
	local _1 = _C(119, "IsControllingPet", flow, _4)

	if not _1 then
		return false
	end

	local _7 = _M._get_133_1(flow)
	local _8 = _C(120, "GetControllingPetActorId", flow, _7)
	local _5 = _C(131, "GetPetData", flow, _8, "baseFormPet", true, 0)
	local _2 = _5 == 1018100

	if not _2 then
		return false
	end

	return true
end

function _M._get_128_0(flow)
	return _C(128, "GetSelfId", flow)
end

function _M._get_133_1(flow)
	local _0 = _C(132, "GetPerceptibilityTable", flow)

	if _0 == nil then
		return
	end

	local key = next(_0)
	local value = _0[key]

	for k, v in pairs(_0) do
		if value < v then
			key, value = k, v
		end
	end

	return key
end

return _M
