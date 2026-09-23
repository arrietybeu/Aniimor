-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Recruit_BeCalled_10461.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Event_PER_StareFriendly" then
		return _M._to_71_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 59 then
		return true
	end

	if nodeId == 71 then
		return _M._to_67_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 59 then
		return _M._get_75_2(flow)
	end
end

function _M._to_49_0(flow)
	local _0 = _M._get_72_1(flow)

	if _0 then
		flow:setActive()
		_A(flow, "SendMessageToTrigger", 0, 1046302)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_59_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 59)

	if not _1 then
		flow:setActive()
		_C(59, "DoBehaviour", flow, "PBT_CustomAnimation")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "Behav_Love")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 7)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 0)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
		flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
		flow:setContinue(59)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_67_0(flow)
	flow:addTimer(3, _M, "_to_49_0", flow)

	return _M._to_59_0(flow)
end

function _M._to_71_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_70_2(flow)

	if _0 then
		flow:setActive()
		_C(71, "DoBehaviour", flow, "PBT_TurnToTargetAtYaw")

		local _1 = _M._get_69_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTgtId", _1)
		flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
		flow.__agent:addSubTreeLocalParam("tInstant", false)
		flow:setContinue(71)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_69_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_70_2(flow)
	local _0 = _M._get_69_2(flow)

	return _C(70, "IsInAnimState", flow, _0, "IdleSpecial")
end

function _M._get_72_1(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_69_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayer")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_72_3(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_69_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayerInterrupt")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_75_2(flow)
	local _2 = _M._get_69_2(flow)
	local _3 = _C(73, "GetDistance", flow, _2, 0, false)
	local _0 = _3 > 10

	if _0 then
		return true
	end

	local _1 = _M._get_72_3(flow)

	if _1 then
		return true
	end

	return false
end

return _M
