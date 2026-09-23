-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10451_RecruitIdleSp.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Event_PER_StareFriendly" then
		return _M._to_52_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 7 then
		return true
	end

	if nodeId == 52 then
		return _M._to_26_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 7 then
		return _M._get_56_2(flow)
	end
end

function _M._to_7_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 7)

	if not _1 then
		flow:setActive()
		_C(7, "DoBehaviour", flow, "PBT_CustomAnimation")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "IdleSpecial")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
		flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", true)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
		flow:setContinue(7)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_10_0(flow)
	local _0 = _M._get_53_1(flow)

	if _0 then
		flow:setActive()
		_A(flow, "SendMessageToTrigger", 0, 1045101)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_26_0(flow)
	flow:addTimer(0.5, _M, "_to_10_0", flow)

	return _M._to_7_0(flow)
end

function _M._to_52_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_51_2(flow)

	if _0 then
		flow:setActive()
		_C(52, "DoBehaviour", flow, "PBT_TurnToTargetAtYaw")

		local _1 = _M._get_50_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTgtId", _1)
		flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
		flow.__agent:addSubTreeLocalParam("tInstant", false)
		flow:setContinue(52)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_50_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_51_2(flow)
	local _0 = _M._get_50_2(flow)

	return _C(51, "IsInAnimState", flow, _0, "IdleSpecial")
end

function _M._get_53_1(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_50_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayer")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_53_3(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_50_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayerInterrupt")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_56_2(flow)
	local _2 = _M._get_50_2(flow)
	local _3 = _C(54, "GetDistance", flow, _2, 0, false)
	local _0 = _3 > 10

	if _0 then
		return true
	end

	local _1 = _M._get_53_3(flow)

	if _1 then
		return true
	end

	return false
end

return _M
