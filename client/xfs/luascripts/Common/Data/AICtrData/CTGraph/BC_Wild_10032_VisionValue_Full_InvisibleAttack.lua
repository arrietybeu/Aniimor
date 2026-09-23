-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10032_VisionValue_Full_InvisibleAttack.lua

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

local function _doBehaviourTail_1(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8, value9)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tTargetActorId", value0)
	agent:addSubTreeLocalParam("tStopDist", value1)
	agent:addSubTreeLocalParam("tMaxTimeout", value2)
	agent:addSubTreeLocalParam("tFaceTarget", value3)
	agent:addSubTreeLocalParam("tSpeed", value4)
	agent:addSubTreeLocalParam("tMoveUpdateLevel", value5)
	agent:addSubTreeLocalParam("tPathFindType", value6)
	agent:addSubTreeLocalParam("tSpeedRateType", value7)
	agent:addSubTreeLocalParam("tUseAccurateArrive", value8)
	agent:addSubTreeLocalParam("tNoBodySize", value9)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_2(flow, nodeId, value0, value1, value2)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tSensorTgtId", value0)
	agent:addSubTreeLocalParam("tRandomWaitTime", value1)
	agent:addSubTreeLocalParam("tShowExclamation", value2)
	flow:setContinue(nodeId)

	return true
end

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "VisionValue_Full" then
		flow:setActive()
		_A(flow, "AddAITag", 0, "TA_VisionFull")
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "TA_VisionAlert")
		flow:setActive()

		local _0 = _C(64, "GetSelfId", flow)

		_A(flow, "HideEmojiOnTarget", _0, "")

		return _M._to_70_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "RemoveAITag", 0, "TA_VisionFull")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 69 then
		return _M._to_71_0(flow)
	end

	if nodeId == 70 then
		return _M._to_88_0(flow)
	end

	if nodeId == 71 then
		return _M._to_84_0(flow)
	end

	if nodeId == 76 then
		return _M._to_83_0(flow)
	end

	if nodeId == 78 then
		return _M._to_103_0(flow)
	end

	if nodeId == 79 then
		return _M._to_78_0(flow)
	end

	if nodeId == 81 then
		return _M._to_79_0(flow)
	end

	if nodeId == 83 then
		return true
	end

	if nodeId == 102 then
		return true
	end

	if nodeId == 103 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_69_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_0(flow, 69, 0, 10320900, 0, "", 5, false, 0)
end

function _M._to_70_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_59_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(70)

	return true
end

function _M._to_71_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_59_2(flow)

	return _doBehaviourTail_1(flow, 71, _0, 0.5, 10, true, 0, 99999, 0, 2, false, false)
end

function _M._to_74_0(flow)
	local _5 = _C(104, "GetSelfId", flow)
	local _4 = _C(105, "GetPuppetData", flow, _5, "petPrototypeId", true, 0)
	local _0 = _4 == 1003202

	if _0 then
		return _M._to_102_0(flow)
	end

	local _2 = _C(73, "GetSelfId", flow)
	local _3 = _C(72, "GetTargetBuffLayerCount", flow, _2, 2103213)
	local _1 = _3 > 0

	if _1 then
		return _M._to_81_0(flow)
	end

	return _M._to_69_0(flow)
end

function _M._to_76_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_59_2(flow)

	return _doBehaviourTail_0(flow, 76, 0, 10320000, _0, "", 5, false, 0)
end

function _M._to_78_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Laugh")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow:setContinue(78)

	return true
end

function _M._to_79_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_59_2(flow)

	return _doBehaviourTail_0(flow, 79, 0, 10320000, _0, "", 5, false, 0)
end

function _M._to_81_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	return _doBehaviourTail_1(flow, 81, 0, 0.5, 10, true, 0, 99999, 0, 2, false, false)
end

function _M._to_83_0(flow)
	if not _B(flow, "PBT_ReadyToFight") then
		return
	end

	local _0 = _M._get_59_2(flow)

	return _doBehaviourTail_2(flow, 83, _0, 0, false)
end

function _M._to_84_0(flow)
	flow:addTimer(0.5, _M, "_to_85_0", flow)

	return _M._to_76_0(flow)
end

function _M._to_85_0(flow)
	flow:setActive()

	local _0 = _C(86, "GetSelfId", flow)

	_A(flow, "PlayEmojiOnTarget", _0, "Laugh", 5)

	return true
end

function _M._to_87_0(flow)
	local _0 = _M._get_94_2(flow)

	if _0 then
		flow:setActive()
		_A(flow, "SendMessageToTrigger", 0, 1003301)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_88_0(flow)
	flow:addTimer(3, _M, "_to_87_0", flow)

	return _M._to_74_0(flow)
end

function _M._to_102_0(flow)
	if not _B(flow, "PBT_ReadyToFight") then
		return
	end

	local _0 = _M._get_59_2(flow)

	return _doBehaviourTail_2(flow, 102, _0, 0, false)
end

function _M._to_103_0(flow)
	if not _B(flow, "PBT_ReadyToFight") then
		return
	end

	local _0 = _M._get_59_2(flow)

	return _doBehaviourTail_2(flow, 103, _0, 0, false)
end

function _M._get_59_2(flow)
	return flow:getContextValue("sensorTgtId")
end

function _M._get_94_2(flow)
	local _3 = _M._get_59_2(flow)
	local _0 = _C(96, "IsControllingPet", flow, _3)

	if not _0 then
		return false
	end

	local _5 = _M._get_59_2(flow)
	local _4 = _C(98, "GetControllingPetActorId", flow, _5)
	local _2 = _C(97, "GetPetData", flow, _4, "baseFormPet", true, 0)
	local _1 = _2 == 1003300

	if not _1 then
		return false
	end

	return true
end

return _M
