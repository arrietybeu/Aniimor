-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10043_Sensed_CastSkill_HealPlayer.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_45_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 32 then
		return _M._to_38_0(flow)
	end

	if nodeId == 38 then
		return _M._to_41_0(flow)
	end

	if nodeId == 39 then
		return true
	end

	if nodeId == 41 then
		return _M._to_40_0(flow)
	end

	if nodeId == 43 then
		return _M._to_39_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 38 then
		return _M._get_56_2(flow)
	end

	if nodeId == 39 then
		return _M._get_56_2(flow)
	end
end

function _M._to_32_0(flow)
	if not _B(flow, "PBT_Behav_Com_Notice") then
		return
	end

	local _0 = _M._get_48_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tWait", true)
	flow:setContinue(32)

	return true
end

function _M._to_38_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 38)

	if not _1 then
		flow:setActive()
		_C(38, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_48_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 4)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 0)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 2)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 0)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", true)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(38)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_39_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 39)

	if not _1 then
		flow:setActive()
		_C(39, "DoBehaviour", flow, "PBT_CustomLoopAnimation")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_LoveStart")
		flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_LoveLoop")
		flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_LoveEnd")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
		flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", true)
		flow:setContinue(39)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_40_0(flow)
	flow:addTimer(0.3, _M, "_to_42_0", flow)

	return _M._to_43_0(flow)
end

function _M._to_41_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_48_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(41)

	return true
end

function _M._to_42_0(flow)
	flow:setActive()
	_A(flow, "SendMessageToTrigger", 0, 1004301)

	return true
end

function _M._to_43_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_48_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tSkillId", 10430110)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(43)

	return true
end

function _M._to_45_0(flow)
	local _0 = _M._get_37_2(flow)

	if _0 then
		return _M._to_32_0(flow)
	end
end

function _M._get_37_2(flow)
	local _3 = _M._get_48_1(flow)
	local _4 = _C(35, "GetControllingPetActorId", flow, _3)
	local _5 = _C(33, "GetHpPercent", flow, _4)
	local _0 = _5 <= 0.5

	if not _0 then
		return false
	end

	local _2 = _M._get_48_1(flow)
	local _1 = _C(34, "IsControllingPet", flow, _2)

	if not _1 then
		return false
	end

	return true
end

function _M._get_48_1(flow)
	local _0 = flow:getCache(48, "tgt")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_50_2(flow)

	flow:setCache(48, "tgt", _0)

	return _0
end

function _M._get_49_2(flow)
	local _1 = _M._get_53_2(flow)
	local _0 = _C(54, "GetDistance", flow, _1, 0, false)

	return _0 <= 15
end

function _M._get_50_2(flow)
	local _0 = _M._get_53_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(50, "__iterItem", v)

		_1 = _M._get_51_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_51_3(flow)
	local _0 = flow:getCache(50, "__iterItem")

	return _C(51, "GetDistance", flow, _0, 0, true)
end

function _M._get_53_3(flow)
	local _0 = _C(46, "GetAoiEntityTableByLevel", flow, 0, 30, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(53, "__iterItem", v)

		if _M._get_49_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_53_2(flow)
	return flow:getCache(53, "__iterItem")
end

function _M._get_56_2(flow)
	local _1 = _M._get_48_1(flow)
	local _0 = _C(55, "GetDistance", flow, _1, 0, false)

	return _0 > 15
end

return _M
