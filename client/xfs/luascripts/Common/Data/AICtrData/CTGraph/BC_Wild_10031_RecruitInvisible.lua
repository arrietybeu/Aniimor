-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10031_RecruitInvisible.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Event_PER_StareFriendly" then
		return _M._to_8_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 7 then
		return true
	end

	if nodeId == 8 then
		return _M._to_26_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_7_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_29_0(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tSkillId", 10310900)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(7)

	return true
end

function _M._to_8_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_20_4(flow)

	if _0 then
		flow:setActive()
		_C(8, "DoBehaviour", flow, "PBT_TurnToTargetAtYaw")

		local _1 = _M._get_30_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTgtId", _1)
		flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
		flow.__agent:addSubTreeLocalParam("tInstant", false)
		flow:setContinue(8)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_10_0(flow)
	local _0 = _M._get_36_1(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_29_0(flow)

		_A(flow, "SendMessageToTrigger", _1, 1003201)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_26_0(flow)
	flow:addTimer(0.5, _M, "_to_10_0", flow)

	return _M._to_7_0(flow)
end

function _M._get_20_4(flow)
	if false then
		return false
	end

	if false then
		return false
	end

	local _3 = _M._get_30_2(flow)
	local _2 = _C(19, "GetDistance", flow, _3, 0, false)
	local _0 = _2 <= 10

	if not _0 then
		return false
	end

	local _4 = _M._get_30_2(flow)
	local _1 = _C(31, "IsInSkill", flow, _4, 10320900)

	if not _1 then
		return false
	end

	return true
end

function _M._get_29_0(flow)
	return _C(29, "GetSelfId", flow)
end

function _M._get_30_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_36_1(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_30_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayer")

	flow:clearSubMacro(_0)

	return _2
end

return _M
