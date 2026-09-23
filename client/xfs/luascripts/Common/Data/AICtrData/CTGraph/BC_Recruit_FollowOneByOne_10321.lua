-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Recruit_FollowOneByOne_10321.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local CTRConst = require("Common.AICt.CTRConst")
local _M = {}
local _C = CTHelper.SafeCall
local _eventTriggerList = {
	"Event_Recruit_Follow"
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
	if eventName == "Event_Recruit_Follow" then
		return _M._to_10_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 0 then
		return true
	end

	if nodeId == 16 then
		return true
	end

	if nodeId == 18 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_0_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_6_1(flow)

	if _0 then
		flow:setActive()
		_C(0, "DoBehaviour", flow, "PBT_FollowOneByOne")

		local _1 = _M._get_2_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tFollowEntActorID", _1)
		flow.__agent:addSubTreeLocalParam("tFollowStopDist", 2)
		flow.__agent:addSubTreeLocalParam("tStartFollowDist", 0)
		flow:setContinue(0)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_9_0(flow)
	flow:setActive()
	_C(9, "DoAction", flow, "SendMessageToTrigger", 0, 1032102)

	return true
end

function _M._to_10_0(flow)
	flow:addTimer(1, _M, "_to_19_0", flow)

	return _M._to_15_0(flow)
end

function _M._to_15_0(flow)
	local _0 = _M._get_12_2(flow)

	if _0 then
		return _M._to_0_0(flow)
	end

	local _1 = _M._get_13_2(flow)

	if _1 then
		return _M._to_18_0(flow)
	end

	local _2 = _M._get_14_2(flow)

	if _2 then
		return _M._to_16_0(flow)
	end
end

function _M._to_16_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()
	_C(16, "DoBehaviour", flow, "PBT_Behav_Com_FollowWithFormation")

	local _0 = _M._get_2_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tRandomValue", 0)
	flow:setContinue(16)

	return true
end

function _M._to_18_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()
	_C(18, "DoBehaviour", flow, "PBT_Behav_Com_FollowByRelativePos")

	local _0 = _M._get_2_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tRandomValue", 0)
	flow:setContinue(18)

	return true
end

function _M._to_19_0(flow)
	local _0 = _M._get_22_2(flow)

	if _0 then
		return _M._to_23_0(flow)
	end

	local _1 = _M._get_24_2(flow)

	if _1 then
		return _M._to_9_0(flow)
	end
end

function _M._to_23_0(flow)
	flow:setActive()
	_C(23, "DoAction", flow, "SendMessageToTrigger", 0, 1032101)

	return true
end

function _M._get_2_1(flow)
	return flow:getContextValue("followOneByOneActorId")
end

function _M._get_2_2(flow)
	return flow:getContextValue("recruitTargetActorId")
end

function _M._get_4_2(flow)
	local _0 = _M._get_5_0(flow)

	return _C(4, "IsInBehavTag", flow, _0, "TB_Recruit_BeCalled")
end

function _M._get_5_0(flow)
	return _C(5, "GetSelfId", flow)
end

function _M._get_6_1(flow)
	local _0 = _M._get_4_2(flow)

	return _C(6, "Not", flow, _0)
end

function _M._get_11_2(flow)
	local _0 = _M._get_2_2(flow)

	return _C(11, "GetPetData", flow, _0, "beFollowMode", true, 0)
end

function _M._get_12_2(flow)
	local _0 = _M._get_11_2(flow)

	return _C(12, "IsEqual", flow, _0, 0)
end

function _M._get_13_2(flow)
	local _0 = _M._get_11_2(flow)

	return _C(13, "IsEqual", flow, _0, 1)
end

function _M._get_14_2(flow)
	local _0 = _M._get_11_2(flow)

	return _C(14, "IsEqual", flow, _0, 2)
end

function _M._get_20_2(flow)
	local _0 = _M._get_2_2(flow)

	return _C(20, "GetPetData", flow, _0, "baseFormPet", true, 0)
end

function _M._get_22_2(flow)
	local _0 = _M._get_20_2(flow)

	return _C(22, "IsEqual", flow, _0, 1032300)
end

function _M._get_24_2(flow)
	local _0 = _M._get_20_2(flow)

	return _C(24, "IsEqual", flow, _0, 1032400)
end

return _M
