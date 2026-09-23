-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_PER_Fight_ToPuppet.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Event_PER_Fight" then
		return _M._to_34_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 5 then
		return _M._to_29_0(flow)
	end

	if nodeId == 31 then
		return _M._to_5_0(flow)
	end

	if nodeId == 34 then
		return _M._to_37_0(flow)
	end

	if nodeId == 37 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 5 then
		return _M._get_20_1(flow)
	end

	if nodeId == 31 then
		return _M._get_20_1(flow)
	end
end

function _M._to_5_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 5)

	if not _1 then
		flow:setActive()
		_C(5, "DoBehaviour", flow, "PBT_ReadyToFight")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tSensorTgtId", 0)
		flow.__agent:addSubTreeLocalParam("tRandomWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tShowExclamation", false)
		flow:setContinue(5)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_29_0(flow)
	flow:setActive()

	local _0 = _C(30, "GetSelfId", flow)

	_A(flow, "SendMessageToTrigger", _0, 1002)

	return true
end

function _M._to_34_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_35_2(flow)

	if _0 then
		flow:setActive()
		_C(34, "DoBehaviour", flow, "PBT_Node_Com_SensedAlert")

		local _1 = _M._get_33_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow:setContinue(34)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_37_0(flow)
	if not _B(flow, "PBT_Behav_Com_Angry") then
		return
	end

	local _0 = _M._get_33_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow:setContinue(37)

	return true
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

function _M._get_33_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_35_2(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_33_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPuppet")

	flow:clearSubMacro(_0)

	return _2
end

return _M
