-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_PER_10291_PlaySnow.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_19_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "HideQuestionMark", 0)
	flow:setActive()

	local _0 = _C(32, "GetSelfId", flow)

	_A(flow, "HideEmojiOnTarget", _0, "")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 18 then
		return true
	end

	if nodeId == 19 then
		return _M._to_43_0(flow)
	end

	if nodeId == 22 then
		return _M._to_39_0(flow)
	end

	if nodeId == 23 then
		return _M._to_50_0(flow)
	end

	if nodeId == 27 then
		return _M._to_44_0(flow)
	end

	if nodeId == 28 then
		return true
	end

	if nodeId == 44 then
		return true
	end

	if nodeId == 50 then
		return _M._to_22_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 22 then
		return _M._get_41_1(flow)
	end

	if nodeId == 23 then
		return _M._get_41_1(flow)
	end
end

function _M._to_19_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_17_1(flow)

	if _0 then
		flow:setActive()
		_C(19, "DoBehaviour", flow, "PBT_TurnToTargetAtYaw")

		local _1 = _M._get_35_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTgtId", _1)
		flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
		flow.__agent:addSubTreeLocalParam("tInstant", false)
		flow:setContinue(19)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_22_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_26_2(flow)
	local _1 = _M.checkInterrupt(flow, 22)

	if _0 and not _1 then
		flow:setActive()
		_C(22, "DoBehaviour", flow, "PBT_CastSkill")

		local _2 = _M._get_35_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tSkillId", 12930900)
		flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _2)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 0)
		flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
		flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
		flow:setContinue(22)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_23_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 23)

	if not _1 then
		flow:setActive()
		_C(23, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_35_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 3)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 4)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 0)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 10)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(23)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_27_0(flow)
	if not _B(flow, "PBT_TurnToTargetPos") then
		return
	end

	local _0 = _C(40, "GetAIBlackboardValue", flow, 0, "bornPos")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tTargetPos", _0)
	flow:setContinue(27)

	return true
end

function _M._to_39_0(flow)
	return _M._to_27_0(flow)
end

function _M._to_43_0(flow)
	flow:setActive()

	local _1 = _M._get_35_1(flow)
	local _0 = _C(42, "GetEntPosition", flow, _1)

	_C(43, "SetAIBlackboardValue", flow, 0, "bornPos", _0)

	return _M._to_23_0(flow)
end

function _M._to_44_0(flow)
	if not _B(flow, "PBT_Behav_Com_Happy") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", 0)
	flow:setContinue(44)

	return true
end

function _M._to_50_0(flow)
	if not _B(flow, "PBT_MoveAroundTarget") then
		return
	end

	local _0 = _M._get_35_1(flow)
	local _1 = _C(49, "RandomInteger", flow, 0, 1)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tRadius", 3)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
	flow.__agent:addSubTreeLocalParam("tClockwise", false)
	flow.__agent:addSubTreeLocalParam("tTimeout", _1)
	flow:setContinue(50)

	return true
end

function _M._get_13_2(flow)
	local _2 = _M._get_37_2(flow)
	local _0 = _C(12, "HasEntityTag", flow, _2, "TE_Env_10291_SnowBall")

	if not _0 then
		return false
	end

	local _4 = _M._get_37_2(flow)
	local _3 = _C(15, "GetDistance", flow, _4, 0, false)
	local _1 = _3 <= 12

	if not _1 then
		return false
	end

	return true
end

function _M._get_17_1(flow)
	local _1 = _M._get_37_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_21_0(flow)
	return _C(21, "GetSelfId", flow)
end

function _M._get_24_1(flow)
	local _0 = _M._get_35_1(flow)

	return _C(24, "CheckEntityExist", flow, _0)
end

function _M._get_26_2(flow)
	local _0 = _C(25, "CheckCanUseSkill", flow, 0, 12930900)

	if not _0 then
		return false
	end

	local _1 = _M._get_24_1(flow)

	if not _1 then
		return false
	end

	return true
end

function _M._get_34_1(flow)
	local _0 = _M._get_37_3(flow)

	return _C(34, "SelectOneByRandom", flow, _0)
end

function _M._get_35_1(flow)
	local _0 = flow:getCache(35, "Stone")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_34_1(flow)

	flow:setCache(35, "Stone", _0)

	return _0
end

function _M._get_37_3(flow)
	local _0 = _C(33, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(37, "__iterItem", v)

		if _M._get_13_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_37_2(flow)
	return flow:getCache(37, "__iterItem")
end

function _M._get_41_1(flow)
	local _0 = _M._get_24_1(flow)

	return not _0
end

return _M
