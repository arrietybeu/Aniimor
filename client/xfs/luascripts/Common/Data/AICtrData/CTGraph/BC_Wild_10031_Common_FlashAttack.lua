-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10031_Common_FlashAttack.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "VisionValue_Alert" then
		return _M._to_42_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 23 then
		return _M._to_24_0(flow)
	end

	if nodeId == 24 then
		return true
	end

	if nodeId == 42 then
		return _M._to_52_0(flow)
	end

	if nodeId == 52 then
		return _M._to_54_0(flow)
	end

	if nodeId == 54 then
		return _M._to_75_0(flow)
	end

	if nodeId == 56 then
		return true
	end

	if nodeId == 75 then
		return _M._to_56_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_24_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tSkillId", 10310500)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(24)

	return true
end

function _M._to_42_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", 0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(42)

	return true
end

function _M._to_52_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Alert")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 2)
	flow:setContinue(52)

	return true
end

function _M._to_54_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0.25)
	flow:setContinue(54)

	return true
end

function _M._to_56_0(flow)
	if not _B(flow, "PBT_LeaveTarget") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", 0)
	flow.__agent:addSubTreeLocalParam("tLeaveDistance", 30)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tMaxTime", 0)
	flow:setContinue(56)

	return true
end

function _M._to_75_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Attack03")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Cry")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(75)

	return true
end

function _M._get_26_3(flow)
	return flow:getCache(26, "__iterItem")
end

function _M._get_26_2(flow)
	local _0 = _C(25, "GetPerceptibilityTable", flow)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(26, "__iterItem", k)

		if _M._get_31_2(flow) then
			_1[#_1 + 1] = k
		end
	end

	return _1
end

function _M._get_27_1(flow)
	local _0 = _M._get_26_2(flow)

	return not _0 or next(_0) == nil
end

function _M._get_31_2(flow)
	local _2 = _M._get_26_3(flow)
	local _3 = _C(29, "GetPerceptibilityValue", flow, _2)
	local _0 = _3 >= 1

	if not _0 then
		return false
	end

	local _4 = _M._get_26_3(flow)
	local _1 = _C(32, "IsEntityType", flow, _4, "ACTOR_TYPE_PLAYER")

	if not _1 then
		return false
	end

	return true
end

function _M._get_39_3(flow)
	local _0 = _C(41, "GetPerceptibilityTable", flow)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(39, "__iterItem", k)

		if _M._get_48_2(flow) then
			_1[#_1 + 1] = k
		end
	end

	return _1
end

function _M._get_39_2(flow)
	return flow:getCache(39, "__iterItem")
end

function _M._get_46_1(flow)
	local _0 = _M._get_39_3(flow)

	return not _0 or next(_0) == nil
end

function _M._get_48_2(flow)
	local _2 = _M._get_39_2(flow)
	local _3 = _C(43, "GetPerceptibilityValue", flow, _2)
	local _0 = _3 >= 1

	if not _0 then
		return false
	end

	local _4 = _M._get_39_2(flow)
	local _1 = _C(45, "IsEntityType", flow, _4, "ACTOR_TYPE_PLAYER")

	if not _1 then
		return false
	end

	return true
end

function _M._get_49_1(flow)
	local _0 = _M._get_39_3(flow)

	return _C(49, "SelectOneByRandom", flow, _0)
end

function _M._get_57_3(flow)
	return _C(57, "GetDistance", flow, 0, 8, false)
end

return _M
