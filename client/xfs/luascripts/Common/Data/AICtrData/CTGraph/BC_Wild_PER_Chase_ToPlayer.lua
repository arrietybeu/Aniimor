-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_PER_Chase_ToPlayer.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tTargetActorId", value0)
	agent:addSubTreeLocalParam("", value1)
	agent:addSubTreeLocalParam("Speed", value2)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "PercpetEntityReactionTriggerChase" then
		return _M._to_31_0(flow)
	end

	if eventName == "Event_PER_Chase" then
		return _M._to_35_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 5 then
		return true
	end

	if nodeId == 31 then
		return _M._to_32_0(flow)
	end

	if nodeId == 33 then
		return true
	end

	if nodeId == 35 then
		return _M._to_37_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 5 then
		return _M._get_20_1(flow)
	end

	if nodeId == 31 then
		return _M._get_20_1(flow)
	end

	if nodeId == 33 then
		return _M._get_36_3(flow)
	end
end

function _M._to_5_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 5)

	if not _1 then
		flow:setActive()
		_C(5, "DoBehaviour", flow, "PBT_Behav_Com_Chase")

		local _1 = _M._get_0_2(flow)

		return _doBehaviourTail_0(flow, 5, _1, 1, 0)
	else
		flow:setActiveFail()
	end
end

function _M._to_29_0(flow)
	flow:setActive()
	_A(flow, "SendMessageToTrigger", 0, 1005)

	return true
end

function _M._to_31_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_22_3(flow)
	local _1 = _M.checkInterrupt(flow, 31)

	if _0 and not _1 then
		flow:setActive()
		_C(31, "DoBehaviour", flow, "PBT_Behav_Com_Notice")

		local _2 = _M._get_0_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _2)
		flow.__agent:addSubTreeLocalParam("tWait", false)
		flow:setContinue(31)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_32_0(flow)
	flow:addTimer(2, _M, "_to_29_0", flow)

	return _M._to_5_0(flow)
end

function _M._to_33_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 33)

	if not _1 then
		flow:setActive()
		_C(33, "DoBehaviour", flow, "PBT_Behav_Com_Chase")

		local _1 = _M._get_34_2(flow)

		return _doBehaviourTail_0(flow, 33, _1, 1, 0)
	else
		flow:setActiveFail()
	end
end

function _M._to_35_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_36_1(flow)

	if _0 then
		flow:setActive()
		_C(35, "DoBehaviour", flow, "PBT_Node_Com_SensedAlert")

		local _1 = _M._get_34_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow:setContinue(35)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_37_0(flow)
	flow:addTimer(0.5, _M, "_to_39_0", flow)

	return _M._to_33_0(flow)
end

function _M._to_39_0(flow)
	flow:setActive()

	local _0 = _C(40, "GetSelfId", flow)
	local _1 = _M._get_34_2(flow)

	_A(flow, "SendMessageToTriggerSpecial", _0, _1)

	return true
end

function _M._get_0_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_17_1(flow)
	local _0 = _M._get_0_2(flow)

	return _C(17, "GetPetMaster", flow, _0)
end

function _M._get_20_1(flow)
	local _0 = _M._get_22_3(flow)

	return not _0
end

function _M._get_22_3(flow)
	local _7 = _M._get_17_1(flow)
	local _8 = _7 == 0
	local _0 = not _8

	if not _0 then
		return false
	end

	local _6 = _M._get_17_1(flow)
	local _1 = _C(23, "IsControllingPet", flow, _6)

	if not _1 then
		return false
	end

	local _3 = _M._get_0_2(flow)
	local _4 = _M._get_17_1(flow)
	local _5 = _C(14, "GetControllingPetActorId", flow, _4)
	local _2 = _3 == _5

	if not _2 then
		return false
	end

	return true
end

function _M._get_34_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_36_3(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_34_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayerInterrupt")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_36_1(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_34_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayer")

	flow:clearSubMacro(_0)

	return _2
end

return _M
