-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_MoveToDuckBait.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	flow:setContinue(nodeId)

	return true
end

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Msg_DuckBait" then
		flow:setActive()
		_A(flow, "SetVisionAreaOverride", "visionAreaLow")

		return _M._to_77_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "SetVisionAreaOverride", "visionAreaDefault")
	flow:setActive()

	local _0 = _C(90, "GetSelfId", flow)

	_A(flow, "HideEmojiOnTarget", _0, "Love2")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 35 then
		return _M._to_78_0(flow)
	end

	if nodeId == 72 then
		return _M._to_73_0(flow)
	end

	if nodeId == 73 then
		return _M._to_35_0(flow)
	end

	if nodeId == 77 then
		return _M._to_69_0(flow)
	end

	if nodeId == 79 then
		return true
	end

	if nodeId == 84 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 35 then
		return _M._get_62_1(flow)
	end

	if nodeId == 79 then
		return _M._get_62_1(flow)
	end

	if nodeId == 84 then
		return _M._get_62_1(flow)
	end
end

function _M._to_35_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 35)

	if not _1 then
		flow:setActive()
		_C(35, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_58_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 2.5)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 3)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 0)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", true)
		flow:setContinue(35)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_69_0(flow)
	local _1 = _M._get_58_1(flow)
	local _2 = _C(65, "GetDistance", flow, _1, 0, false)
	local _0 = _2 > 3

	if _0 then
		return _M._to_72_0(flow)
	end

	return _M._to_83_0(flow)
end

function _M._to_72_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Surprise")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 2)
	flow:setContinue(72)

	return true
end

function _M._to_73_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	return _doBehaviourTail_0(flow, 73, 0.5)
end

function _M._to_77_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_58_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(77)

	return true
end

function _M._to_78_0(flow)
	flow:addTimer(0, _M, "_to_81_0", flow)

	return _M._to_79_0(flow)
end

function _M._to_79_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 79)

	if not _1 then
		flow:setActive()
		_C(79, "DoBehaviour", flow, "PBT_Com_Node_Wait")

		return _doBehaviourTail_0(flow, 79, 20)
	else
		flow:setActiveFail()
	end
end

function _M._to_81_0(flow)
	flow:setActive()

	local _0 = _C(82, "GetSelfId", flow)

	_A(flow, "PlayEmojiOnTarget", _0, "Love2", 4)

	return true
end

function _M._to_83_0(flow)
	flow:addTimer(0, _M, "_to_85_0", flow)

	return _M._to_84_0(flow)
end

function _M._to_84_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 84)

	if not _1 then
		flow:setActive()
		_C(84, "DoBehaviour", flow, "PBT_Com_Node_Wait")

		return _doBehaviourTail_0(flow, 84, 20)
	else
		flow:setActiveFail()
	end
end

function _M._to_85_0(flow)
	flow:setActive()

	local _0 = _C(86, "GetSelfId", flow)

	_A(flow, "PlayEmojiOnTarget", _0, "Love2", 4)

	return true
end

function _M._get_58_1(flow)
	return flow:getContextValue("sourceActorId")
end

function _M._get_62_1(flow)
	local _1 = _M._get_58_1(flow)
	local _0 = _C(61, "CheckEntityExist", flow, _1)

	return not _0
end

return _M
