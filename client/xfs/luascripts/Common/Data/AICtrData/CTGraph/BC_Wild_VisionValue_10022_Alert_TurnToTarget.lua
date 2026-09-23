-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_VisionValue_10022_Alert_TurnToTarget.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "VisionValue_Alert" then
		return _M._to_78_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "RemoveAITag", 0, "TA_VisionAlert")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 67 then
		return _M._to_68_0(flow)
	end

	if nodeId == 68 then
		return _M._to_75_0(flow)
	end

	if nodeId == 70 then
		return true
	end

	if nodeId == 75 then
		return true
	end

	if nodeId == 77 then
		return _M._to_69_0(flow)
	end

	if nodeId == 78 then
		return _M._to_79_0(flow)
	end

	if nodeId == 81 then
		return _M._to_67_0(flow)
	end

	if nodeId == 85 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_67_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_57_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(67)

	return true
end

function _M._to_68_0(flow)
	if not _B(flow, "PBT_TriggerBlueprint") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEventName", "FindPlayer")
	flow:setContinue(68)

	return true
end

function _M._to_69_0(flow)
	local _3 = _M._get_73_0(flow)
	local _0 = _C(84, "HasEntityTag", flow, _3, "TE_DragonFinish")

	if _0 then
		return _M._to_85_0(flow)
	end

	local _2 = _M._get_73_0(flow)
	local _1 = _C(72, "HasEntityTag", flow, _2, "TE_DragonOpenChest")

	if _1 then
		return _M._to_81_0(flow)
	end

	return _M._to_70_0(flow)
end

function _M._to_70_0(flow)
	if not _B(flow, "PBT_Vision_Alert") then
		return
	end

	local _0 = _M._get_57_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tRandomWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tRandomWaitTime2", 0)
	flow:setContinue(70)

	return true
end

function _M._to_75_0(flow)
	if not _B(flow, "PBT_LoopAnimAndBreak") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "0")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Idle")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Idle")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Idle")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 1)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tBreakTag", "TA_VisionAlert")
	flow:setContinue(75)

	return true
end

function _M._to_77_0(flow)
	if not _B(flow, "PBT_ShowQuestionMark") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tMarkType", "Normal")
	flow.__agent:addSubTreeLocalParam("tTimeout", 1.8)
	flow:setContinue(77)

	return true
end

function _M._to_78_0(flow)
	flow:setActive()

	local _0 = flow:getSubFlow("BCS_Common_VisionAlertTag")

	if _0:executeSubFlow() then
		flow:setContinue(78)

		if _0:isFinish() then
			return flow:executeContinue()
		end

		return true
	end
end

function _M._to_79_0(flow)
	flow:setActive()

	local _0 = _C(76, "GetSelfId", flow)

	_A(flow, "HideEmojiOnTarget", _0, "")

	return _M._to_77_0(flow)
end

function _M._to_81_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Behav_Alert")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(81)

	return true
end

function _M._to_85_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_CryStart")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_CryLoop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_CryEnd")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(85)

	return true
end

function _M._get_57_2(flow)
	return flow:getContextValue("sensorTgtId")
end

function _M._get_73_0(flow)
	return _C(73, "GetSelfId", flow)
end

return _M
