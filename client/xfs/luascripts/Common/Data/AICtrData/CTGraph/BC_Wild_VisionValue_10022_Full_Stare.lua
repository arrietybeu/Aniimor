-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_VisionValue_10022_Full_Stare.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tTgtId", value0)
	agent:addSubTreeLocalParam("tTargetAtYawDegree", value1)
	agent:addSubTreeLocalParam("tInstant", value2)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_1(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8, value9)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value1)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value2)
	agent:addSubTreeLocalParam("tAnimationStartKey", value3)
	agent:addSubTreeLocalParam("tAnimationLoopKey", value4)
	agent:addSubTreeLocalParam("tAnimationEndKey", value5)
	agent:addSubTreeLocalParam("tAnimationTimeout", value6)
	agent:addSubTreeLocalParam("tTimelineTag", value7)
	agent:addSubTreeLocalParam("tNeedLoop", value8)
	agent:addSubTreeLocalParam("tAnimationPlayOnce", value9)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_2(flow, nodeId, value0)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tEventName", value0)
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

		local _0 = _C(67, "GetSelfId", flow)

		_A(flow, "HideEmojiOnTarget", _0, "")

		return _M._to_72_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "RemoveAITag", 0, "TA_VisionFull")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 63 then
		return _M._to_82_0(flow)
	end

	if nodeId == 70 then
		return _M._to_83_0(flow)
	end

	if nodeId == 74 then
		return _M._to_78_0(flow)
	end

	if nodeId == 75 then
		return _M._to_81_0(flow)
	end

	if nodeId == 76 then
		return _M._to_79_0(flow)
	end

	if nodeId == 78 then
		return _M._to_76_0(flow)
	end

	if nodeId == 79 then
		return _M._to_80_0(flow)
	end

	if nodeId == 80 then
		return _M._to_75_0(flow)
	end

	if nodeId == 81 then
		return true
	end

	if nodeId == 82 then
		return _M._to_70_0(flow)
	end

	if nodeId == 83 then
		return true
	end

	if nodeId == 84 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_63_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_55_2(flow)

	return _doBehaviourTail_0(flow, 63, _0, 0, false)
end

function _M._to_70_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 70, 0, "Angry", 3, "Behav_AngryStart", "Behav_AngryLoop", "Behav_AngryEnd", 5, "", false, false)
end

function _M._to_72_0(flow)
	local _1 = _M._get_77_0(flow)
	local _0 = _C(73, "HasEntityTag", flow, _1, "TE_DragonOpenChest")

	if _0 then
		return _M._to_86_0(flow)
	end

	return _M._to_63_0(flow)
end

function _M._to_74_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_55_2(flow)

	return _doBehaviourTail_0(flow, 74, _0, 0, false)
end

function _M._to_75_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 75, 0, "Angry", 3, "Behav_AngryStart", "Behav_AngryLoop", "Behav_AngryEnd", 5, "", false, false)
end

function _M._to_76_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "AI_IdleSpecial02")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 2)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(76)

	return true
end

function _M._to_78_0(flow)
	if not _B(flow, "PBT_TriggerBlueprint") then
		return
	end

	return _doBehaviourTail_2(flow, 78, "FindPlayer")
end

function _M._to_79_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_55_2(flow)

	return _doBehaviourTail_0(flow, 79, _0, 0, false)
end

function _M._to_80_0(flow)
	if not _B(flow, "PBT_TriggerBlueprint") then
		return
	end

	return _doBehaviourTail_2(flow, 80, "Speak")
end

function _M._to_81_0(flow)
	if not _B(flow, "PBT_TriggerBlueprint") then
		return
	end

	return _doBehaviourTail_2(flow, 81, "StopSpeak")
end

function _M._to_82_0(flow)
	if not _B(flow, "PBT_TriggerBlueprint") then
		return
	end

	return _doBehaviourTail_2(flow, 82, "DragonAngry")
end

function _M._to_83_0(flow)
	if not _B(flow, "PBT_TriggerBlueprint") then
		return
	end

	return _doBehaviourTail_2(flow, 83, "DragonStopAngry")
end

function _M._to_84_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 84, 0, "Cry", 5, "Behav_CryStart", "Behav_CryLoop", "Behav_CryEnd", 2, "", false, false)
end

function _M._to_86_0(flow)
	local _1 = _M._get_77_0(flow)
	local _0 = _C(85, "HasEntityTag", flow, _1, "TE_DragonFinish")

	if _0 then
		return _M._to_84_0(flow)
	end

	return _M._to_74_0(flow)
end

function _M._get_55_2(flow)
	return flow:getContextValue("sensorTgtId")
end

function _M._get_77_0(flow)
	return _C(77, "GetSelfId", flow)
end

return _M
