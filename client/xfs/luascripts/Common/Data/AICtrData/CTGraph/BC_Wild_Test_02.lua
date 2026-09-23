-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_Test_02.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tActorId", value0)
	agent:addSubTreeLocalParam("tStopDist", value1)
	agent:addSubTreeLocalParam("tHeight", value2)
	agent:addSubTreeLocalParam("tTimeout", value3)
	agent:addSubTreeLocalParam("tNotFaceToPos", value4)
	agent:addSubTreeLocalParam("tMinHoldTime", value5)
	agent:addSubTreeLocalParam("tIgnoreVertical", value6)
	agent:addSubTreeLocalParam("tIgnoreHorizontal", value7)
	agent:addSubTreeLocalParam("tSpeed", value8)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_1(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tCharacterState", value0)
	agent:addSubTreeLocalParam("tAnimationKey", value1)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_99_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 95 then
		return _M._to_100_0(flow)
	end

	if nodeId == 99 then
		return _M._to_95_0(flow)
	end

	if nodeId == 100 then
		return _M._to_101_0(flow)
	end

	if nodeId == 101 then
		return _M._to_103_0(flow)
	end

	if nodeId == 103 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_95_0(flow)
	if not _B(flow, "PBT_FlyToTarget") then
		return
	end

	local _0 = _M._get_98_0(flow)

	return _doBehaviourTail_0(flow, 95, _0, 0, 5, 10, false, 0, false, true, 0)
end

function _M._to_99_0(flow)
	if not _B(flow, "PBT_SwitchToFly") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tFlyHeight", 1)
	flow.__agent:addSubTreeLocalParam("tMaxTime", 5)
	flow:setContinue(99)

	return true
end

function _M._to_100_0(flow)
	if not _B(flow, "PBT_FlyToTarget") then
		return
	end

	local _0 = _M._get_98_0(flow)

	return _doBehaviourTail_0(flow, 100, _0, 0, -3, 10, false, 0, false, true, 1)
end

function _M._to_101_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	return _doBehaviourTail_1(flow, 101, "GROUND", "")
end

function _M._to_103_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	return _doBehaviourTail_1(flow, 103, "LOCOMOTION", "")
end

function _M._get_98_0(flow)
	return _C(98, "GetSelfId", flow)
end

return _M
