-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Recruit_FollowOneByOne.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tTargetActorId", value0)
	agent:addSubTreeLocalParam("tRandomValue", value1)
	flow:setContinue(nodeId)

	return true
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

		local _1 = flow:getContextValue("followOneByOneActorId")

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

function _M._to_10_0(flow)
	flow:addTimer(1, _M, "_to_19_0", flow)

	return _M._to_15_0(flow)
end

function _M._to_15_0(flow)
	local _3 = _M._get_11_2(flow)
	local _0 = _3 == 0

	if _0 then
		return _M._to_0_0(flow)
	end

	local _4 = _M._get_11_2(flow)
	local _1 = _4 == 1

	if _1 then
		return _M._to_18_0(flow)
	end

	local _5 = _M._get_11_2(flow)
	local _2 = _5 == 2

	if _2 then
		return _M._to_16_0(flow)
	end
end

function _M._to_16_0(flow)
	if not _B(flow, "PBT_Behav_Com_FollowWithFormation") then
		return
	end

	local _0 = _M._get_2_2(flow)

	return _doBehaviourTail_0(flow, 16, _0, 0)
end

function _M._to_18_0(flow)
	if not _B(flow, "PBT_Behav_Com_FollowByRelativePos") then
		return
	end

	local _0 = _M._get_2_2(flow)

	return _doBehaviourTail_0(flow, 18, _0, 0)
end

function _M._to_19_0(flow)
	flow:setActive()

	local _0 = _C(20, "GetSelfId", flow)
	local _1 = _M._get_2_2(flow)

	_A(flow, "SendMessageToTriggerSpecial", _0, _1)

	return true
end

function _M._get_2_2(flow)
	return flow:getContextValue("recruitTargetActorId")
end

function _M._get_6_1(flow)
	local _1 = _C(5, "GetSelfId", flow)
	local _0 = _C(4, "IsInBehavTag", flow, _1, "TB_Recruit_BeCalled")

	return not _0
end

function _M._get_11_2(flow)
	local _0 = _M._get_2_2(flow)

	return _C(11, "GetPetData", flow, _0, "beFollowMode", true, 0)
end

return _M
