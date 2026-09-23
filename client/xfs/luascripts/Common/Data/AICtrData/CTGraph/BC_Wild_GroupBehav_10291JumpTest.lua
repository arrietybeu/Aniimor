-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_10291JumpTest.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tTargetActorId", value0)
	agent:addSubTreeLocalParam("tRadius", value1)
	agent:addSubTreeLocalParam("tSpeed", value2)
	agent:addSubTreeLocalParam("tSpeedRateType", value3)
	agent:addSubTreeLocalParam("tClockwise", value4)
	agent:addSubTreeLocalParam("tTimeout", value5)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "GBPMsg_ResPointGO" then
		flow:setActive()

		local _0 = _M._get_4_2(flow)
		local _1 = _M._get_4_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _0, _1)

		return _M._to_3_0(flow)
	end

	if eventName == "GBPMsg_ResPointDoPatrol1" then
		return _M._to_5_0(flow)
	end

	if eventName == "GBPMsg_ResPointgoat" then
		return _M._to_8_0(flow)
	end

	if eventName == "GBPMsg_ResPointDoPatrol2" then
		return _M._to_14_0(flow)
	end

	if eventName == "Event_PER_Love" then
		return _M._to_20_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_4_2(flow)
	local _1 = _M._get_4_3(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 3 then
		return true
	end

	if nodeId == 5 then
		return true
	end

	if nodeId == 8 then
		return true
	end

	if nodeId == 14 then
		return true
	end

	if nodeId == 20 then
		return _M._to_21_0(flow)
	end

	if nodeId == 21 then
		return _M._to_26_0(flow)
	end

	if nodeId == 22 then
		return _M._to_24_0(flow)
	end

	if nodeId == 23 then
		return true
	end

	if nodeId == 24 then
		return _M._to_25_0(flow)
	end

	if nodeId == 25 then
		return _M._to_23_0(flow)
	end

	if nodeId == 29 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 22 then
		return _M._get_27_3(flow)
	end

	if nodeId == 24 then
		return _M._get_27_3(flow)
	end

	if nodeId == 25 then
		return _M._get_27_3(flow)
	end
end

function _M._to_3_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_4_2(flow)
	local _1 = _M._get_4_3(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tPointId", _0)
	flow.__agent:addSubTreeLocalParam("tPortId", _1)
	flow.__agent:addSubTreeLocalParam("tTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", true)
	flow:setContinue(3)

	return true
end

function _M._to_5_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_6_1(flow)

	if _P(flow, 1, _0, -1, nil) then
		flow:setContinue(5)

		return true
	end
end

function _M._to_8_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_9_1(flow)

	if _P(flow, 1, _0, -1, nil) then
		flow:setContinue(8)

		return true
	end
end

function _M._to_14_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_15_1(flow)

	if _P(flow, 1, _0, -1, nil) then
		flow:setContinue(14)

		return true
	end
end

function _M._to_20_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Love")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 3)
	flow:setContinue(20)

	return true
end

function _M._to_21_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_28_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(21)

	return true
end

function _M._to_22_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 22)

	if not _1 then
		flow:setActive()
		_C(22, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_28_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 2)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 7)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 4)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 10)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(22)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_23_0(flow)
	if not _B(flow, "PBT_Behav_Com_Happy") then
		return
	end

	local _0 = _M._get_28_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow:setContinue(23)

	return true
end

function _M._to_24_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 24)

	if not _1 then
		flow:setActive()
		_C(24, "DoBehaviour", flow, "PBT_MoveAroundTarget")

		local _1 = _M._get_28_2(flow)
		local _2 = _M._get_30_2(flow)

		return _doBehaviourTail_0(flow, 24, _1, 1.5, 2.8, 1, false, _2)
	else
		flow:setActiveFail()
	end
end

function _M._to_25_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 25)

	if not _1 then
		flow:setActive()
		_C(25, "DoBehaviour", flow, "PBT_MoveAroundTarget")

		local _1 = _M._get_28_2(flow)
		local _2 = _M._get_30_2(flow)

		return _doBehaviourTail_0(flow, 25, _1, 1.5, 2.8, 1, true, _2)
	else
		flow:setActiveFail()
	end
end

function _M._to_26_0(flow)
	local _0 = _M._get_27_1(flow)

	if _0 then
		return _M._to_22_0(flow)
	end

	return _M._to_29_0(flow)
end

function _M._to_29_0(flow)
	if not _B(flow, "PBT_Behav_Com_Love") then
		return
	end

	local _0 = _M._get_28_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow:setContinue(29)

	return true
end

function _M._get_4_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_4_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_6_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(6, "GetRouteIdFromResPoint", flow, true, _0, 1)
end

function _M._get_9_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(9, "GetRouteIdFromResPoint", flow, true, _0, 2)
end

function _M._get_15_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(15, "GetRouteIdFromResPoint", flow, true, _0, 1)
end

function _M._get_27_1(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_28_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayer")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_27_3(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_28_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayerInterrupt")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_28_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_30_2(flow)
	return _C(30, "RandomInteger", flow, 1, 2)
end

return _M
