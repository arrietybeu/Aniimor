-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10171_SwimIdleSpecial.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_9_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 9 then
		return _M._to_14_0(flow)
	end

	if nodeId == 14 then
		return _M._to_15_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_9_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_11_1(flow)

	if _0 then
		flow:setActive()
		_C(9, "DoBehaviour", flow, "PBT_TurnToTargetAtYaw")

		local _1 = _M._get_12_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTgtId", _1)
		flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
		flow.__agent:addSubTreeLocalParam("tInstant", false)
		flow:setContinue(9)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_14_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Swim_IdleSpecial")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(14)

	return true
end

function _M._to_15_0(flow)
	flow:setActive()

	local _1 = _M._get_12_1(flow)
	local _0 = _C(25, "GetControllingPetActorId", flow, _1)

	_A(flow, "SendMessageToTrigger", _0, 1)

	return true
end

function _M._get_2_3(flow)
	local _0 = _C(1, "GetAoiEntityTableByLevel", flow, 0, 30, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(2, "__iterItem", v)

		if _M._get_5_4(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_2_2(flow)
	return flow:getCache(2, "__iterItem")
end

function _M._get_5_4(flow)
	local _4 = _M._get_2_2(flow)
	local _0 = _C(4, "IsControllingPet", flow, _4)

	if not _0 then
		return false
	end

	local _9 = _C(19, "GetSelfId", flow)
	local _1 = _C(24, "IsChildOfCharState", flow, _9, "SWIMMING")

	if not _1 then
		return false
	end

	local _5 = _M._get_2_2(flow)
	local _6 = _C(6, "GetControllingPetActorId", flow, _5)
	local _7 = _C(16, "GetPetData", flow, _6, "petPrototypeId", true, 0)
	local _2 = _7 == 1017400

	if not _2 then
		return false
	end

	local _8 = _C(21, "RandomInteger", flow, 1, 10)
	local _3 = _8 < 5

	if not _3 then
		return false
	end

	return true
end

function _M._get_11_1(flow)
	local _1 = _M._get_2_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_12_1(flow)
	local _0 = flow:getCache(12, "panta")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_13_1(flow)

	flow:setCache(12, "panta", _0)

	return _0
end

function _M._get_13_1(flow)
	local _0 = _M._get_2_3(flow)

	return _C(13, "SelectOneByRandom", flow, _0)
end

return _M
