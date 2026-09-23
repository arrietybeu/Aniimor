-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10474_PER_StareFriendly.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Event_PER_StareFriendly" then
		return _M._to_15_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 11 then
		return true
	end

	if nodeId == 15 then
		return _M._to_17_0(flow)
	end

	if nodeId == 17 then
		return _M._to_22_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 11 then
		return _M._get_23_2(flow)
	end

	if nodeId == 17 then
		return _M._get_23_2(flow)
	end
end

function _M._to_11_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 11)

	if not _1 then
		flow:setActive()
		_C(11, "DoBehaviour", flow, "PBT_CustomAnimation")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "IdleSpecial")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 4)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 0)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
		flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", true)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
		flow:setContinue(11)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_12_0(flow)
	local _0 = _M._get_21_1(flow)

	if _0 then
		flow:setActive()
		_A(flow, "SendMessageToTrigger", 0, 1047401)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_15_0(flow)
	if not _B(flow, "PBT_Node_Com_WaitAndFriendlyAlert") then
		return
	end

	local _0 = _M._get_10_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow:setContinue(15)

	return true
end

function _M._to_17_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 17)

	if not _1 then
		flow:setActive()
		_C(17, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_10_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 3)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 10)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 0)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 10)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 0)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(17)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_22_0(flow)
	flow:addTimer(2, _M, "_to_12_0", flow)

	return _M._to_11_0(flow)
end

function _M._get_10_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_21_1(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_10_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayer")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_21_3(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_10_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayerInterrupt")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_23_2(flow)
	local _2 = _M._get_10_2(flow)
	local _3 = _C(18, "GetDistance", flow, _2, 0, false)
	local _0 = _3 > 10

	if _0 then
		return true
	end

	local _1 = _M._get_21_3(flow)

	if _1 then
		return true
	end

	return false
end

return _M
