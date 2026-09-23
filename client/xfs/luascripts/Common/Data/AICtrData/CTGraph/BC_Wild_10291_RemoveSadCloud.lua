-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10291_RemoveSadCloud.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_74_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "HideQuestionMark", 0)
	flow:setActive()

	local _0 = _C(110, "GetSelfId", flow)

	_A(flow, "HideEmojiOnTarget", _0, "")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 74 then
		return _M._to_75_0(flow)
	end

	if nodeId == 75 then
		return _M._to_125_0(flow)
	end

	if nodeId == 77 then
		return _M._to_78_0(flow)
	end

	if nodeId == 78 then
		return true
	end

	if nodeId == 83 then
		return _M._to_85_0(flow)
	end

	if nodeId == 95 then
		return _M._to_83_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 83 then
		return _M._get_111_1(flow)
	end

	if nodeId == 95 then
		return _M._get_111_1(flow)
	end
end

function _M._to_74_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_40_1(flow)

	if _0 then
		flow:setActive()
		_C(74, "DoBehaviour", flow, "PBT_ShowQuestionMark")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tMarkType", "DirectFull")
		flow.__agent:addSubTreeLocalParam("tTimeout", 0.5)
		flow:setContinue(74)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_75_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_27_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(75)

	return true
end

function _M._to_77_0(flow)
	if not _B(flow, "PBT_TurnToTargetPos") then
		return
	end

	local _0 = _C(102, "GetAIBlackboardValue", flow, 0, "bornPos")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tTargetPos", _0)
	flow:setContinue(77)

	return true
end

function _M._to_78_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Proud")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 4)
	flow:setContinue(78)

	return true
end

function _M._to_83_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_106_2(flow)
	local _1 = _M.checkInterrupt(flow, 83)

	if _0 and not _1 then
		flow:setActive()
		_C(83, "DoBehaviour", flow, "PBT_CastSkill")

		local _2 = _M._get_27_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tSkillId", 12930900)
		flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _2)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 0)
		flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
		flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
		flow:setContinue(83)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_85_0(flow)
	return _M._to_77_0(flow)
end

function _M._to_95_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 95)

	if not _1 then
		flow:setActive()
		_C(95, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_27_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 3.5)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 0)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 10)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(95)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_125_0(flow)
	flow:setActive()

	local _0 = _C(126, "GetSelfId", flow)

	_A(flow, "StartNpcDialog", 70009014, _0)
	flow:setActive()

	local _1 = _M._get_27_1(flow)
	local _2 = _C(122, "GetEntPosition", flow, _1)

	_C(123, "SetAIBlackboardValue", flow, 0, "bornPos", _2)

	return _M._to_95_0(flow)
end

function _M._get_22_2(flow)
	local _2 = _M._get_37_2(flow)
	local _0 = _C(19, "HasEntityTag", flow, _2, "TE_Env_SadCloud")

	if not _0 then
		return false
	end

	local _3 = _M._get_37_2(flow)
	local _4 = _C(20, "GetDistance", flow, _3, 0, false)
	local _1 = _4 <= 8

	if not _1 then
		return false
	end

	return true
end

function _M._get_25_1(flow)
	local _0 = _M._get_37_3(flow)

	return _C(25, "SelectOneByRandom", flow, _0)
end

function _M._get_27_1(flow)
	local _0 = flow:getCache(27, "Stone")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_25_1(flow)

	flow:setCache(27, "Stone", _0)

	return _0
end

function _M._get_37_3(flow)
	local _0 = _C(16, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(37, "__iterItem", v)

		if _M._get_22_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_37_2(flow)
	return flow:getCache(37, "__iterItem")
end

function _M._get_40_1(flow)
	local _1 = _M._get_37_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_103_1(flow)
	local _0 = _M._get_27_1(flow)

	return _C(103, "CheckEntityExist", flow, _0)
end

function _M._get_106_2(flow)
	local _0 = _C(105, "CheckCanUseSkill", flow, 0, 12930900)

	if not _0 then
		return false
	end

	local _1 = _M._get_103_1(flow)

	if not _1 then
		return false
	end

	return true
end

function _M._get_111_1(flow)
	local _0 = _M._get_103_1(flow)

	return not _0
end

return _M
