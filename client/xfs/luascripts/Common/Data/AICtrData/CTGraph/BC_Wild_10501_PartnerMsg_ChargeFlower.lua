-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10501_PartnerMsg_ChargeFlower.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Msg_PartnerMsg" then
		flow:setActive()
		_A(flow, "ShowQuestionMark", 0, "DirectFull")

		return _M._to_94_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 94 then
		return _M._to_95_0(flow)
	end

	if nodeId == 95 then
		return _M._to_97_0(flow)
	end

	if nodeId == 96 then
		return true
	end

	if nodeId == 103 then
		return _M._to_96_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_94_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_93_1(flow)

	if _0 then
		flow:setActive()
		_C(94, "DoBehaviour", flow, "PBT_CustomAnimation")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "Hit_L")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 1)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 0)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
		flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
		flow:setContinue(94)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_95_0(flow)
	if not _B(flow, "PBT_AddBuff") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tBuffId", 2150102)
	flow.__agent:addSubTreeLocalParam("duration", 5)
	flow:setContinue(95)

	return true
end

function _M._to_96_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_85_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tSkillId", 10800351)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(96)

	return true
end

function _M._to_97_0(flow)
	flow:setActive()

	local _0 = _C(98, "GetPartnerIds", flow, 0)

	for _, v in ipairs(_0) do
		local _1 = flow:getMessageContext()

		_1.sourceActorId = flow.__actorId

		flow:sendMessage(v, "Msg_LeaderMsg", _1)
	end

	return _M._to_103_0(flow)
end

function _M._to_103_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_85_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(103)

	return true
end

function _M._get_85_1(flow)
	local _0 = flow:getCache(85, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_87_2(flow)

	flow:setCache(85, "1", _0)

	return _0
end

function _M._get_86_3(flow)
	local _0 = flow:getCache(87, "__iterItem")

	return _C(86, "GetDistance", flow, _0, 0, false)
end

function _M._get_87_2(flow)
	local _0 = _M._get_88_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(87, "__iterItem", v)

		_1 = _M._get_86_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_88_3(flow)
	local _0 = _C(90, "GetAoiEntityTableByLevel", flow, 0, 30, 64)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(88, "__iterItem", v)

		if _M._get_91_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_88_2(flow)
	return flow:getCache(88, "__iterItem")
end

function _M._get_91_2(flow)
	local _0 = _M._get_88_2(flow)

	return _C(91, "HasEntityTag", flow, _0, "TE_Chest_ChargeTarget")
end

function _M._get_93_1(flow)
	local _1 = _M._get_88_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

return _M
