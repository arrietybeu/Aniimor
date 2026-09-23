-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10024_VisionValue_Alert_Overload_FindHelm.lua

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

local function _doBehaviourTail_1(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tAnimationKey", value1)
	agent:addSubTreeLocalParam("tAnimationTimeout", value2)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value3)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value4)
	agent:addSubTreeLocalParam("tTimelineTag", value5)
	agent:addSubTreeLocalParam("tNeedLoop", value6)
	agent:addSubTreeLocalParam("tAnimationPlayOnce", value7)
	agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", value8)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_2(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8, value9)
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
	agent:addSubTreeLocalParam("tBreakTag", value9)
	flow:setContinue(nodeId)

	return true
end

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "VisionValue_Alert" then
		return _M._to_32_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 30 then
		return _M._to_38_0(flow)
	end

	if nodeId == 35 then
		return _M._to_76_0(flow)
	end

	if nodeId == 60 then
		return _M._to_81_0(flow)
	end

	if nodeId == 61 then
		return _M._to_62_0(flow)
	end

	if nodeId == 76 then
		return _M._to_78_0(flow)
	end

	if nodeId == 77 then
		return _M._to_85_0(flow)
	end

	if nodeId == 78 then
		return _M._to_77_0(flow)
	end

	if nodeId == 81 then
		return _M._to_82_0(flow)
	end

	if nodeId == 82 then
		return _M._to_86_0(flow)
	end

	if nodeId == 85 then
		return true
	end

	if nodeId == 86 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
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
	local _0 = _M._get_50_2(flow)

	if _0 then
		return _M._to_30_0(flow)
	end

	local _2 = _M._get_1_2(flow)
	local _3 = _C(47, "GetControllingPetActorId", flow, _2)
	local _4 = _C(48, "GetPetData", flow, _3, "petPrototypeId", true, 0)
	local _1 = _4 == 1002100

	if _1 then
		return _M._to_61_0(flow)
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

function _M._to_60_0(flow)
	if not _B(flow, "PBT_ShowQuestionMark") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tMarkType", "Normal")
	flow.__agent:addSubTreeLocalParam("tTimeout", 1.8)
	flow:setContinue(60)

	return true
end

function _M._to_61_0(flow)
	flow:setActive()

	local _0 = flow:getSubFlow("BCS_Common_VisionAlertTag")

	if _0:executeSubFlow() then
		flow:setContinue(61)

		if _0:isFinish() then
			return flow:executeContinue()
		end

		return true
	end
end

function _M._to_62_0(flow)
	flow:setActive()

	local _0 = _C(59, "GetSelfId", flow)

	_A(flow, "HideEmojiOnTarget", _0, "")

	return _M._to_60_0(flow)
end

function _M._to_76_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_1_2(flow)

	return _doBehaviourTail_0(flow, 76, _0, 0, false)
end

function _M._to_77_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 77, 0, "AI_IdleSpecial01", 1.2, "", 0, "", false, false, false)
end

function _M._to_78_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 78, 0, "JumpBack", 1.5, "", 0, "", false, false, false)
end

function _M._to_81_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_1_2(flow)

	return _doBehaviourTail_0(flow, 81, _0, 0, false)
end

function _M._to_82_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 82, 0, "AI_IdleSpecial01", 1.2, "0", 0, "", false, false, false)
end

function _M._to_85_0(flow)
	if not _B(flow, "PBT_LoopAnimAndBreak") then
		return
	end

	return _doBehaviourTail_2(flow, 85, 0, "0", 0, "Idle", "Idle", "Idle", 1, "", false, "TA_VisionAlert")
end

function _M._to_86_0(flow)
	if not _B(flow, "PBT_LoopAnimAndBreak") then
		return
	end

	return _doBehaviourTail_2(flow, 86, 0, "0", 0, "Idle", "Idle", "Idle", 1, "", false, "TA_VisionAlert")
end

function _M._get_1_2(flow)
	return flow:getContextValue("sensorTgtId")
end

function _M._get_50_2(flow)
	local _3 = _M._get_52_2(flow)
	local _0 = _3 == 1002600

	if _0 then
		return true
	end

	local _2 = _M._get_52_2(flow)
	local _1 = _2 == 1002700

	if _1 then
		return true
	end

	return false
end

function _M._get_52_2(flow)
	local _1 = _M._get_1_2(flow)
	local _0 = _C(53, "GetControllingPetActorId", flow, _1)

	return _C(52, "GetPetData", flow, _0, "petPrototypeId", true, 0)
end

return _M
