-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_PER_Scare_ToPlayer.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tAnimationKey", value1)
	agent:addSubTreeLocalParam("tAnimationTimeout", value2)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value3)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value4)
	agent:addSubTreeLocalParam("tTimelineTag", value5)
	agent:addSubTreeLocalParam("tNeedLoop", value6)
	agent:addSubTreeLocalParam("tAnimationPlayOnce", value7)
	agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", value8)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Event_PER_Scare" then
		return _M._to_44_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 5 then
		return true
	end

	if nodeId == 31 then
		return _M._to_40_0(flow)
	end

	if nodeId == 32 then
		return _M._to_29_0(flow)
	end

	if nodeId == 39 then
		return true
	end

	if nodeId == 40 then
		return _M._to_33_0(flow)
	end

	if nodeId == 42 then
		return true
	end

	if nodeId == 44 then
		return _M._to_42_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 5 then
		return _M._get_20_1(flow)
	end

	if nodeId == 31 then
		return _M._get_20_1(flow)
	end

	if nodeId == 39 then
		return _M._get_20_1(flow)
	end

	if nodeId == 42 then
		return _M._get_45_3(flow)
	end
end

function _M._to_5_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 5)

	if not _1 then
		flow:setActive()
		_C(5, "DoBehaviour", flow, "PBT_CustomAnimation")

		return _doBehaviourTail_0(flow, 5, 0, "Behav_Angry", 5, "", 5, "", false, false, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_29_0(flow)
	flow:setActive()

	local _0 = _C(30, "GetSelfId", flow)

	_A(flow, "SendMessageToTrigger", _0, 1006)

	return _M._to_5_0(flow)
end

function _M._to_32_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", "LOCOMOTION")
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(32)

	return true
end

function _M._to_33_0(flow)
	local _1 = _C(36, "GetSelfId", flow)
	local _0 = _C(41, "IsChildOfCharState", flow, _1, "FLYHOVER")

	if _0 then
		return _M._to_32_0(flow)
	end

	flow:setActive()

	local _2 = _C(38, "GetSelfId", flow)

	_A(flow, "SendMessageToTrigger", _2, 1006)

	return _M._to_39_0(flow)
end

function _M._to_39_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 39)

	if not _1 then
		flow:setActive()
		_C(39, "DoBehaviour", flow, "PBT_CustomAnimation")

		return _doBehaviourTail_0(flow, 39, 0, "Behav_Angry", 5, "", 5, "", false, false, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_40_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", 0)
	flow.__agent:addSubTreeLocalParam("tStopDist", 2)
	flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 0)
	flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
	flow:setContinue(40)

	return true
end

function _M._to_42_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 42)

	if not _1 then
		flow:setActive()
		_C(42, "DoBehaviour", flow, "PBT_Behav_Com_Scare")

		local _1 = _M._get_43_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("MoveToCount", 0)
		flow:setContinue(42)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_44_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_45_1(flow)

	if _0 then
		flow:setActive()
		_C(44, "DoBehaviour", flow, "PBT_Node_Com_SensedAlert")

		local _1 = _M._get_43_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow:setContinue(44)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_17_1(flow)
	return _C(17, "GetPetMaster", flow, 0)
end

function _M._get_20_1(flow)
	local _0 = _M._get_22_3(flow)

	return not _0
end

function _M._get_22_3(flow)
	local _6 = _M._get_17_1(flow)
	local _7 = _6 == 0
	local _0 = not _7

	if not _0 then
		return false
	end

	local _5 = _M._get_17_1(flow)
	local _1 = _C(23, "IsControllingPet", flow, _5)

	if not _1 then
		return false
	end

	local _3 = _M._get_17_1(flow)
	local _4 = _C(14, "GetControllingPetActorId", flow, _3)
	local _2 = _4 == 0

	if not _2 then
		return false
	end

	return true
end

function _M._get_43_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_45_3(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_43_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayerInterrupt")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_45_1(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_43_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayer")

	flow:clearSubMacro(_0)

	return _2
end

return _M
