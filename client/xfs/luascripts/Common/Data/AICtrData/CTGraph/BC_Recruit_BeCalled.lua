-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Recruit_BeCalled.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tTgtId", value0)
	agent:addSubTreeLocalParam("tTargetAtYawDegree", value1)
	agent:addSubTreeLocalParam("tInstant", value2)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_1(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tCharacterState", value0)
	agent:addSubTreeLocalParam("tAnimationKey", value1)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "RecruitBeginTrigger" then
		flow:setActive()

		local _0 = _C(35, "GetSelfId", flow)

		_A(flow, "SendMessageToTrigger", _0, 1007)

		return _M._to_20_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_7_1(flow)

	_A(flow, "RecruitBeginFollowOneByOne", _0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 8 then
		return true
	end

	if nodeId == 16 then
		return _M._to_47_0(flow)
	end

	if nodeId == 21 then
		return _M._to_49_0(flow)
	end

	if nodeId == 27 then
		return true
	end

	if nodeId == 28 then
		return true
	end

	if nodeId == 37 then
		return true
	end

	if nodeId == 39 then
		return _M._to_48_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_8_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_7_1(flow)

	return _doBehaviourTail_0(flow, 8, _0, 0, false)
end

function _M._to_16_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	local _0 = "LOCOMOTION"

	return _doBehaviourTail_1(flow, 16, _0, "")
end

function _M._to_20_0(flow)
	local _3 = _M._get_18_0(flow)
	local _0 = _C(44, "IsChildOrTransitionOfCharState", flow, _3, "SNEAK")

	if _0 then
		return _M._to_16_0(flow)
	end

	local _4 = _M._get_18_0(flow)
	local _1 = _C(45, "IsChildOrTransitionOfCharState", flow, _4, "MIMICRY")

	if _1 then
		return _M._to_39_0(flow)
	end

	local _5 = _M._get_18_0(flow)
	local _2 = _C(46, "IsChildOrTransitionOfCharState", flow, _5, "SWIMMIMICRY")

	if _2 then
		return _M._to_21_0(flow)
	end

	flow:setActive()
	_A(flow, "PlayEmojiOnTarget", 0, "Love", 2)

	return _M._to_28_0(flow)
end

function _M._to_21_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	local _0 = "SWIMMING"

	return _doBehaviourTail_1(flow, 21, _0, "")
end

function _M._to_27_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_7_1(flow)

	return _doBehaviourTail_0(flow, 27, _0, 0, false)
end

function _M._to_28_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_7_1(flow)

	return _doBehaviourTail_0(flow, 28, _0, 0, false)
end

function _M._to_37_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	return _doBehaviourTail_0(flow, 37, 0, 0, false)
end

function _M._to_39_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	local _0 = "LOCOMOTION"

	return _doBehaviourTail_1(flow, 39, _0, "")
end

function _M._to_47_0(flow)
	flow:setActive()
	_A(flow, "PlayEmojiOnTarget", 0, "Love", 2)

	return _M._to_8_0(flow)
end

function _M._to_48_0(flow)
	flow:setActive()
	_A(flow, "PlayEmojiOnTarget", 0, "Love", 2)

	return _M._to_37_0(flow)
end

function _M._to_49_0(flow)
	flow:setActive()
	_A(flow, "PlayEmojiOnTarget", 0, "Love", 2)

	return _M._to_27_0(flow)
end

function _M._get_7_1(flow)
	return flow:getContextValue("recruitTargetActorId")
end

function _M._get_18_0(flow)
	return _C(18, "GetSelfId", flow)
end

return _M
