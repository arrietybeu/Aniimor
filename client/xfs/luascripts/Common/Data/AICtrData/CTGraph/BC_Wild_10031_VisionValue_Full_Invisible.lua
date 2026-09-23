-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10031_VisionValue_Full_Invisible.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tSkillId", value1)
	agent:addSubTreeLocalParam("tSkillTargetActorId", value2)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value3)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value4)
	agent:addSubTreeLocalParam("tRaycastOpen", value5)
	agent:addSubTreeLocalParam("tCastAbilitySource", value6)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_1(flow, nodeId, value0, value1, value2)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tTgtId", value0)
	agent:addSubTreeLocalParam("tTargetAtYawDegree", value1)
	agent:addSubTreeLocalParam("tInstant", value2)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_2(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value0)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value1)
	flow:setContinue(nodeId)

	return true
end

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "VisionValue_Full" then
		return _M._to_80_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "RemoveAITag", 0, "TA_VisionFull")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 62 then
		return true
	end

	if nodeId == 69 then
		return _M._to_62_0(flow)
	end

	if nodeId == 70 then
		return _M._to_71_0(flow)
	end

	if nodeId == 71 then
		return _M._to_69_0(flow)
	end

	if nodeId == 81 then
		return _M._to_95_0(flow)
	end

	if nodeId == 82 then
		return _M._to_81_0(flow)
	end

	if nodeId == 83 then
		return true
	end

	if nodeId == 85 then
		return _M._to_86_0(flow)
	end

	if nodeId == 86 then
		return _M._to_82_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_62_0(flow)
	if not _B(flow, "PBT_Leave") then
		return
	end

	local _0 = _M._get_59_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow:setContinue(62)

	return true
end

function _M._to_69_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_64_0(flow)

	return _doBehaviourTail_0(flow, 69, 0, 10310900, _0, "", 5, false, 0)
end

function _M._to_70_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_59_2(flow)

	return _doBehaviourTail_1(flow, 70, _0, 0, false)
end

function _M._to_71_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_2(flow, 71, "Surprise", 5)
end

function _M._to_80_0(flow)
	local _0 = _M._get_89_2(flow)

	if _0 then
		return _M._to_85_0(flow)
	end

	flow:setActive()
	_A(flow, "AddAITag", 0, "TA_VisionFull")
	flow:setActive()
	_A(flow, "RemoveAITag", 0, "TA_VisionAlert")
	flow:setActive()

	local _1 = _M._get_64_0(flow)

	_A(flow, "HideEmojiOnTarget", _1, "")

	return _M._to_70_0(flow)
end

function _M._to_81_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_59_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tStopDist", 0.5)
	flow.__agent:addSubTreeLocalParam("tMaxTimeout", 10)
	flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
	flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
	flow:setContinue(81)

	return true
end

function _M._to_82_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_59_2(flow)

	return _doBehaviourTail_0(flow, 82, 0, 10310900, _0, "", 5, false, 0)
end

function _M._to_83_0(flow)
	if not _B(flow, "PBT_ReadyToFight") then
		return
	end

	local _0 = _M._get_59_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tRandomWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tShowExclamation", false)
	flow:setContinue(83)

	return true
end

function _M._to_85_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_59_2(flow)

	return _doBehaviourTail_1(flow, 85, _0, 0, false)
end

function _M._to_86_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_2(flow, 86, "Angry", 5)
end

function _M._to_95_0(flow)
	flow:setActive()
	_A(flow, "SendMessageToTrigger", 0, 1003101)

	return _M._to_83_0(flow)
end

function _M._get_59_2(flow)
	return flow:getContextValue("sensorTgtId")
end

function _M._get_64_0(flow)
	return _C(64, "GetSelfId", flow)
end

function _M._get_89_2(flow)
	local _3 = _M._get_59_2(flow)
	local _0 = _C(92, "IsControllingPet", flow, _3)

	if not _0 then
		return false
	end

	local _4 = _M._get_59_2(flow)
	local _5 = _C(88, "GetControllingPetActorId", flow, _4)
	local _2 = _C(94, "GetPetData", flow, _5, "baseFormPet", true, 0)
	local _1 = _2 == 1003100

	if not _1 then
		return false
	end

	return true
end

return _M
