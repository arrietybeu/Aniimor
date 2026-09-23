-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10475_PER_StareFriendly.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local CTRConst = require("Common.AICt.CTRConst")
local _M = {}
local _C = CTHelper.SafeCall
local _eventTriggerList = {
	"Event_PER_StareFriendly"
}

function _M.getEventTriggerList()
	return _eventTriggerList
end

local _messageTriggerList = {}

function _M.getMessageTriggerList()
	return _messageTriggerList
end

local _tickLodTriggerLevel = -1

function _M.getTickLodTriggerLevel()
	return _tickLodTriggerLevel
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Event_PER_StareFriendly" then
		return _M._to_89_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 87 then
		return true
	end

	if nodeId == 89 then
		return _M._to_101_0(flow)
	end

	if nodeId == 101 then
		return _M._to_110_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 87 then
		return _M._get_111_2(flow)
	end

	if nodeId == 101 then
		return _M._get_111_2(flow)
	end
end

function _M._to_87_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 87)

	if not _1 then
		flow:setActive()
		_C(87, "DoBehaviour", flow, "PBT_CustomAnimation")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "IdleSpecial")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 6.5)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 0)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
		flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", true)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
		flow:setContinue(87)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_89_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_105_2(flow)

	if _0 then
		flow:setActive()
		_C(89, "DoBehaviour", flow, "PBT_Node_Com_WaitAndFriendlyAlert")

		local _1 = _M._get_86_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow:setContinue(89)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_101_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 101)

	if not _1 then
		flow:setActive()
		_C(101, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_86_2(flow)

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
		flow:setContinue(101)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_104_0(flow)
	local _0 = _M._get_109_1(flow)

	if _0 then
		flow:setActive()
		_C(104, "DoAction", flow, "SendMessageToTrigger", 0, 1047501)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_110_0(flow)
	flow:addTimer(2, _M, "_to_104_0", flow)

	return _M._to_87_0(flow)
end

function _M._get_86_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_94_2(flow)
	local _0 = _M._get_86_2(flow)

	return _C(94, "IsInAnimState", flow, _0, "IdleSpecial")
end

function _M._get_102_3(flow)
	local _0 = _M._get_86_2(flow)

	return _C(102, "GetDistance", flow, _0, 0, false)
end

function _M._get_103_2(flow)
	local _0 = _M._get_102_3(flow)

	return _C(103, "IsGreaterThan", flow, _0, 10)
end

function _M._get_105_2(flow)
	local _0 = _M._get_94_2(flow)

	if not _0 then
		return false
	end

	local _1 = _M._get_107_2(flow)

	if not _1 then
		return false
	end

	return true
end

function _M._get_107_2(flow)
	local _0 = _M._get_108_2(flow)

	return _C(107, "IsEqual", flow, _0, 1047500)
end

function _M._get_108_2(flow)
	local _0 = _M._get_86_2(flow)

	return _C(108, "GetPetData", flow, _0, "baseFormPet", true, 0)
end

function _M._get_109_1(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_86_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayer")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_109_3(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_86_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayerInterrupt")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_111_2(flow)
	local _0 = _M._get_103_2(flow)

	if _0 then
		return true
	end

	local _1 = _M._get_109_3(flow)

	if _1 then
		return true
	end

	return false
end

return _M
