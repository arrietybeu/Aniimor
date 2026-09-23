-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10043_HealPlayer.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "SensedMsgTrigger" then
		return _M._to_14_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 14 then
		return _M._to_22_0(flow)
	end

	if nodeId == 18 then
		return true
	end

	if nodeId == 22 then
		return _M._to_27_0(flow)
	end

	if nodeId == 25 then
		return _M._to_18_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_14_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_16_1(flow)

	if _0 then
		flow:setActive()
		_C(14, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_13_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 4)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 0)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 2)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 0)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(14)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_18_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 1.5)
	flow:setContinue(18)

	return true
end

function _M._to_22_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_13_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(22)

	return true
end

function _M._to_23_0(flow)
	flow:setActive()
	_A(flow, "SendMessageToTrigger", 0, 1004301)

	return true
end

function _M._to_25_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_13_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tSkillId", 10430110)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(25)

	return true
end

function _M._to_27_0(flow)
	flow:addTimer(0.3, _M, "_to_23_0", flow)

	return _M._to_25_0(flow)
end

function _M._get_5_2(flow)
	return flow:getCache(5, "__iterItem")
end

function _M._get_5_3(flow)
	local _0 = _C(1, "GetAoiEntityTableByLevel", flow, 0, 30, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(5, "__iterItem", v)

		if _M._get_11_4(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_11_4(flow)
	local _3 = _M._get_5_2(flow)
	local _0 = _C(4, "IsControllingPet", flow, _3)

	if not _0 then
		return false
	end

	local _4 = _M._get_5_2(flow)
	local _5 = _C(7, "GetControllingPetActorId", flow, _4)
	local _6 = _C(3, "GetHpPercent", flow, _5)
	local _1 = _6 <= 0.5

	if not _1 then
		return false
	end

	if false then
		return false
	end

	local _7 = _M._get_5_2(flow)
	local _8 = _C(20, "GetDistance", flow, _7, 0, false)
	local _2 = _8 <= 15

	if not _2 then
		return false
	end

	return true
end

function _M._get_12_1(flow)
	local _0 = _M._get_5_3(flow)

	return _C(12, "SelectOneByRandom", flow, _0)
end

function _M._get_13_1(flow)
	local _0 = flow:getCache(13, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_12_1(flow)

	flow:setCache(13, "1", _0)

	return _0
end

function _M._get_16_1(flow)
	local _1 = _M._get_5_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

return _M
