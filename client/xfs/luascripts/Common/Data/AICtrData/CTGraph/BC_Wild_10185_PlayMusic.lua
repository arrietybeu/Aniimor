-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10185_PlayMusic.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_22_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 12 then
		return true
	end

	if nodeId == 22 then
		return _M._to_30_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_12_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Behav_Sing")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 4)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 4)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", true)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(12)

	return true
end

function _M._to_21_0(flow)
	flow:setActive()

	local _1 = _M._get_23_1(flow)
	local _0 = _C(31, "GetControllingPetActorId", flow, _1)

	_A(flow, "SendMessageToTrigger", _0, 1)

	return true
end

function _M._to_22_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_14_1(flow)

	if _0 then
		flow:setActive()
		_C(22, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_23_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 5)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 0)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(22)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_30_0(flow)
	flow:addTimer(2, _M, "_to_21_0", flow)

	return _M._to_12_0(flow)
end

function _M._get_0_2(flow)
	return flow:getCache(0, "__iterItem")
end

function _M._get_0_3(flow)
	local _0 = _C(3, "GetAoiEntityTableByLevel", flow, 0, 30, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(0, "__iterItem", v)

		if _M._get_7_4(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_4_1(flow)
	local _0 = _M._get_0_2(flow)

	return _C(4, "GetControllingPetActorId", flow, _0)
end

function _M._get_7_4(flow)
	local _8 = _M._get_0_2(flow)
	local _0 = _C(10, "IsControllingPet", flow, _8)

	if not _0 then
		return false
	end

	local _4 = _M._get_4_1(flow)
	local _5 = _C(5, "GetPetData", flow, _4, "petPrototypeId", true, 0)
	local _1 = _5 == 1018400

	if not _1 then
		return false
	end

	local _6 = _M._get_0_2(flow)
	local _7 = _C(8, "GetDistance", flow, _6, 0, false)
	local _2 = _7 <= 15

	if not _2 then
		return false
	end

	local _9 = _M._get_4_1(flow)
	local _3 = _C(26, "IsInSkill", flow, _9, 11840200)

	if not _3 then
		return false
	end

	return true
end

function _M._get_14_1(flow)
	local _1 = _M._get_0_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_23_1(flow)
	local _0 = flow:getCache(23, "211")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_27_1(flow)

	flow:setCache(23, "211", _0)

	return _0
end

function _M._get_27_1(flow)
	local _0 = _M._get_0_3(flow)

	return _C(27, "SelectOneByRandom", flow, _0)
end

return _M
