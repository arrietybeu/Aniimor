-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Recruit_10231_Dance.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_3_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 3 then
		return _M._to_12_0(flow)
	end

	if nodeId == 11 then
		return true
	end

	if nodeId == 12 then
		return _M._to_19_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_1_0(flow)
	flow:setActive()

	local _0 = _C(18, "GetSelfId", flow)

	_A(flow, "SendMessageToTrigger", _0, 1)

	return true
end

function _M._to_3_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_10_1(flow)

	if _0 then
		flow:setActive()
		_C(3, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_17_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 3)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 0)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(3)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_11_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "IdleSpecial")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 6)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 6)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", true)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(11)

	return true
end

function _M._to_12_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_17_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(12)

	return true
end

function _M._to_19_0(flow)
	flow:addTimer(2, _M, "_to_1_0", flow)

	return _M._to_11_0(flow)
end

function _M._get_0_2(flow)
	local _2 = _M._get_4_2(flow)
	local _0 = _C(6, "IsControllingPet", flow, _2)

	if not _0 then
		return false
	end

	local _3 = _M._get_4_2(flow)
	local _4 = _C(8, "GetControllingPetActorId", flow, _3)
	local _1 = _C(13, "IsInAnimState", flow, _4, "IdleSpecial")

	if not _1 then
		return false
	end

	return true
end

function _M._get_4_3(flow)
	local _0 = _C(2, "GetAoiEntityTableByLevel", flow, 0, 30, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(4, "__iterItem", v)

		if _M._get_0_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_4_2(flow)
	return flow:getCache(4, "__iterItem")
end

function _M._get_10_1(flow)
	local _1 = _M._get_4_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_17_1(flow)
	local _0 = _M._get_4_3(flow)

	if _0 == nil then
		return
	end

	local key = 1
	local value = _0[1]

	for k, v in ipairs(_0) do
		if value < v then
			key, value = k, v
		end
	end

	return value
end

return _M
