-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10132_PutOnFire.lua

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
		return _M._to_17_0(flow)
	end

	if nodeId == 17 then
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

	local _0 = _M._get_14_1(flow)

	if _0 then
		flow:setActive()
		_C(9, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_11_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 3.5)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 3)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 0)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(9)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_15_0(flow)
	flow:setActive()
	_A(flow, "SendMessageToTrigger", 0, 1)

	return true
end

function _M._to_17_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_11_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tSkillId", 11320110)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(17)

	return true
end

function _M._get_1_2(flow)
	return flow:getCache(1, "__iterItem")
end

function _M._get_1_3(flow)
	local _0 = _C(0, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(1, "__iterItem", v)

		if _M._get_7_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_7_2(flow)
	local _2 = _M._get_1_2(flow)
	local _0 = _C(3, "CheckHasChemState", flow, _2, nil)

	if not _0 then
		return false
	end

	local _3 = _M._get_1_2(flow)
	local _4 = _C(5, "GetSelfId", flow)
	local _5 = _C(4, "GetDistance", flow, _3, _4, false)
	local _1 = _5 <= 15

	if not _1 then
		return false
	end

	return true
end

function _M._get_11_1(flow)
	local _0 = flow:getCache(11, "121")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_12_1(flow)

	flow:setCache(11, "121", _0)

	return _0
end

function _M._get_12_1(flow)
	local _0 = _M._get_1_3(flow)

	return _C(12, "SelectOneByRandom", flow, _0)
end

function _M._get_14_1(flow)
	local _1 = _M._get_1_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

return _M
