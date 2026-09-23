-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10021_VisionValue_Alert_Overload_FindHelgon.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "VisionValue_Alert" then
		return _M._to_32_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 10 then
		return _M._to_13_0(flow)
	end

	if nodeId == 12 then
		return _M._to_41_0(flow)
	end

	if nodeId == 13 then
		return _M._to_12_0(flow)
	end

	if nodeId == 30 then
		return _M._to_38_0(flow)
	end

	if nodeId == 35 then
		return _M._to_10_0(flow)
	end

	if nodeId == 41 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_10_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_1_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(10)

	return true
end

function _M._to_12_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "AI_IdleSpecial03")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(12)

	return true
end

function _M._to_13_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0.25)
	flow:setContinue(13)

	return true
end

function _M._to_30_0(flow)
	flow:setActive()

	local _0 = flow:getSubFlow("BCS_Common_VisionAlertTag")

	if _0:executeSubFlow() then
		flow:setContinue(30)

		if _0:isFinish() then
			return flow:executeContinue()
		end

		return true
	end
end

function _M._to_32_0(flow)
	local _0 = _M._get_16_4(flow)

	if _0 then
		return _M._to_30_0(flow)
	end
end

function _M._to_35_0(flow)
	if not _B(flow, "PBT_ShowQuestionMark") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tMarkType", "Normal")
	flow.__agent:addSubTreeLocalParam("tTimeout", 1.8)
	flow:setContinue(35)

	return true
end

function _M._to_38_0(flow)
	flow:setActive()

	local _0 = _C(39, "GetSelfId", flow)

	_A(flow, "HideEmojiOnTarget", _0, "")

	return _M._to_35_0(flow)
end

function _M._to_41_0(flow)
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
	flow:setContinue(41)

	return true
end

function _M._get_1_2(flow)
	return flow:getContextValue("sensorTgtId")
end

function _M._get_7_2(flow)
	local _1 = _M._get_1_2(flow)
	local _0 = _C(14, "GetControllingPetActorId", flow, _1)

	return _C(7, "GetPetData", flow, _0, "petPrototypeId", true, 0)
end

function _M._get_16_4(flow)
	local _4 = _M._get_7_2(flow)
	local _0 = _4 == 1002400

	if _0 then
		return true
	end

	local _5 = _M._get_7_2(flow)
	local _1 = _5 == 1002200

	if _1 then
		return true
	end

	local _6 = _M._get_7_2(flow)
	local _2 = _6 == 1002300

	if _2 then
		return true
	end

	local _7 = _M._get_7_2(flow)
	local _3 = _7 == 1002500

	if _3 then
		return true
	end

	return false
end

return _M
