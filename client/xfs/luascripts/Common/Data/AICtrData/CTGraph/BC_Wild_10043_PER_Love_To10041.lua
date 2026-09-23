-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10043_PER_Love_To10041.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local CTRConst = require("Common.AICt.CTRConst")
local _M = {}
local _C = CTHelper.SafeCall
local _eventTriggerList = {
	"Event_PER_Love"
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
	if eventName == "Event_PER_Love" then
		return _M._to_26_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 23 then
		return true
	end

	if nodeId == 29 then
		return _M._to_30_0(flow)
	end

	if nodeId == 30 then
		return _M._to_28_0(flow)
	end

	if nodeId == 31 then
		return _M._to_29_0(flow)
	end

	if nodeId == 36 then
		return _M._to_23_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_23_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()
	_C(23, "DoBehaviour", flow, "PBT_Behav_Com_Love")

	local _0 = _M._get_24_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow:setContinue(23)

	return true
end

function _M._to_26_0(flow)
	local _0 = _M._get_27_1(flow)

	if _0 then
		return _M._to_31_0(flow)
	end

	local _1 = _M._get_27_2(flow)

	if _1 then
		return _M._to_36_0(flow)
	end
end

function _M._to_28_0(flow)
	flow:setActive()
	_C(28, "DoAction", flow, "SendMessageToTrigger", 0, 1004102)

	return true
end

function _M._to_29_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()
	_C(29, "DoBehaviour", flow, "PBT_MoveAroundTarget")

	local _0 = _M._get_24_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tRadius", 0.5)
	flow.__agent:addSubTreeLocalParam("tSpeed", 2)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tClockwise", false)
	flow.__agent:addSubTreeLocalParam("tTimeout", 5)
	flow:setContinue(29)

	return true
end

function _M._to_30_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()
	_C(30, "DoBehaviour", flow, "PBT_Behav_Com_Love")

	local _0 = _M._get_24_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow:setContinue(30)

	return true
end

function _M._to_31_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_33_2(flow)

	if _0 then
		flow:setActive()
		_C(31, "DoBehaviour", flow, "PBT_ShowEmojiBubble")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Love")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 2)
		flow:setContinue(31)

		return true
	end
end

function _M._to_36_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()
	_C(36, "DoBehaviour", flow, "PBT_ShowEmojiBubble")
	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Love")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 2)
	flow:setContinue(36)

	return true
end

function _M._get_24_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_27_1(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_24_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayer")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_27_2(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_24_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPuppet")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_32_2(flow)
	local _0 = _M._get_24_2(flow)

	return _C(32, "IsInAnimState", flow, _0, "IdleSpecial")
end

function _M._get_33_2(flow)
	local _0 = _M._get_32_2(flow)
	local _1 = _M._get_35_2(flow)

	return _C(33, "And", flow, _0, _1)
end

function _M._get_34_1(flow)
	local _0 = _M._get_24_2(flow)

	return _C(34, "GetPetData", flow, _0, "baseFormPet")
end

function _M._get_35_2(flow)
	local _0 = _M._get_34_1(flow)

	return _C(35, "IsEqual", flow, _0, 1004100)
end

return _M
