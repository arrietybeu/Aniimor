-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_69993_PER_StareFriendly.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Event_PER_StareFriendly" then
		return _M._to_82_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 82 then
		return _M._to_84_0(flow)
	end

	if nodeId == 90 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 90 then
		return _M._get_87_2(flow)
	end
end

function _M._to_82_0(flow)
	if not _B(flow, "PBT_Node_Com_SensedAlert") then
		return
	end

	local _0 = _M._get_79_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow:setContinue(82)

	return true
end

function _M._to_84_0(flow)
	flow:addTimer(1, _M, "_to_85_0", flow)

	return _M._to_90_0(flow)
end

function _M._to_85_0(flow)
	local _0 = _M._get_83_1(flow)

	if _0 then
		flow:setActive()
		_A(flow, "SendMessageToTrigger", 0, 6999301)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_90_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 90)

	if not _1 then
		flow:setActive()
		_C(90, "DoBehaviour", flow, "PBT_CustomLoopAnimation")
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
		flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", true)
		flow:setContinue(90)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_79_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_83_3(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_79_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayerInterrupt")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_83_1(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_79_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayer")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_87_2(flow)
	local _2 = _M._get_79_2(flow)
	local _3 = _C(88, "GetDistance", flow, _2, 0, false)
	local _0 = _3 > 10

	if _0 then
		return true
	end

	local _1 = _M._get_83_3(flow)

	if _1 then
		return true
	end

	return false
end

return _M
