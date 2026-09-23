-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10431_PER_StareFriendly.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Event_PER_StareFriendly" then
		return _M._to_232_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 232 then
		return _M._to_236_0(flow)
	end

	if nodeId == 236 then
		return _M._to_244_0(flow)
	end

	if nodeId == 243 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 243 then
		return _M._get_246_2(flow)
	end
end

function _M._to_232_0(flow)
	if not _B(flow, "PBT_Node_Com_WaitAndFriendlyAlert") then
		return
	end

	local _0 = _M._get_235_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow:setContinue(232)

	return true
end

function _M._to_236_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_235_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(236)

	return true
end

function _M._to_239_0(flow)
	local _0 = _M._get_245_1(flow)

	if _0 then
		flow:setActive()
		_A(flow, "SendMessageToTrigger", 0, 1043101)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_243_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 243)

	if not _1 then
		flow:setActive()
		_C(243, "DoBehaviour", flow, "PBT_CustomLoopAnimation")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Think2")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_DoubtStart")
		flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_DoubtLoop")
		flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_DoubtEnd")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
		flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
		flow:setContinue(243)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_244_0(flow)
	flow:addTimer(1, _M, "_to_239_0", flow)

	return _M._to_243_0(flow)
end

function _M._get_235_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_245_1(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_235_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayer")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_245_3(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_235_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayerInterrupt")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_246_2(flow)
	local _2 = _M._get_235_2(flow)
	local _3 = _C(237, "GetDistance", flow, _2, 0, false)
	local _0 = _3 > 10

	if _0 then
		return true
	end

	local _1 = _M._get_245_3(flow)

	if _1 then
		return true
	end

	return false
end

return _M
