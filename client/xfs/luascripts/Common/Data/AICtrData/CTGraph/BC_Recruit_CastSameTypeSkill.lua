-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Recruit_CastSameTypeSkill.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "CastSameTypeSkillMsgTrigger" then
		return _M._to_9_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 0 then
		return _M._to_22_0(flow)
	end

	if nodeId == 8 then
		return true
	end

	if nodeId == 9 then
		return _M._to_7_0(flow)
	end

	if nodeId == 17 then
		return _M._to_24_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_0_0(flow)
	if not _B(flow, "PBT_CastSameTypeSkill") then
		return
	end

	local _0 = _M._get_3_2(flow)
	local _1 = _M._get_3_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tSkillId", _0)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _1)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 4)
	flow:setContinue(0)

	return true
end

function _M._to_7_0(flow)
	local _0 = _M._get_4_2(flow)

	if _0 then
		return _M._to_16_0(flow)
	end

	local _2 = _M._get_4_2(flow)
	local _1 = not _2

	if _1 then
		return _M._to_8_0(flow)
	end
end

function _M._to_8_0(flow)
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
	flow:setContinue(8)

	return true
end

function _M._to_9_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", "LOCOMOTION")
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(9)

	return true
end

function _M._to_16_0(flow)
	local _2 = _M._get_11_1(flow)
	local _0 = not _2

	if _0 then
		return _M._to_0_0(flow)
	end

	local _1 = _M._get_11_1(flow)

	if _1 then
		return _M._to_17_0(flow)
	end
end

function _M._to_17_0(flow)
	if not _B(flow, "PBT_CastChargeSkill") then
		return
	end

	local _0 = _M._get_3_1(flow)
	local _1 = _M._get_3_2(flow)
	local _2 = _M._get_20_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tSkillId", _1)
	flow.__agent:addSubTreeLocalParam("tAutoCast", _2)
	flow.__agent:addSubTreeLocalParam("tChargeTime", 0)
	flow.__agent:addSubTreeLocalParam("tPartId", 0)
	flow.__agent:addSubTreeLocalParam("tSkipBackswing", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 4)
	flow:setContinue(17)

	return true
end

function _M._to_22_0(flow)
	flow:setActive()

	local _0 = _C(21, "GetSelfId", flow)

	_A(flow, "SendMessageToTrigger", _0, 1009)

	return true
end

function _M._to_24_0(flow)
	flow:setActive()

	local _0 = _C(23, "GetSelfId", flow)

	_A(flow, "SendMessageToTrigger", _0, 1009)

	return true
end

function _M._get_3_2(flow)
	return flow:getContextValue("tSkillId")
end

function _M._get_3_1(flow)
	return flow:getContextValue("tSkillTargetActorId")
end

function _M._get_4_2(flow)
	local _0 = _C(10, "GetSelfId", flow)
	local _1 = _M._get_3_2(flow)

	return _C(4, "CheckSkillCanCast", flow, _0, _1)
end

function _M._get_11_1(flow)
	local _0 = _M._get_3_2(flow)

	return _C(11, "GetSkillProperty", flow, _0, "isCharge")
end

function _M._get_20_1(flow)
	local _1 = _C(18, "GetId", flow, "slavesOwnerId")
	local _2 = _M._get_3_2(flow)
	local _0 = _C(19, "CheckEntIsChargeSkill", flow, _1, _2)

	return not _0
end

return _M
