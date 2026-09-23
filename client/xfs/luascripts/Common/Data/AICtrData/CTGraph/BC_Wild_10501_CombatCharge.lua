-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10501_CombatCharge.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_40_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 23 then
		return true
	end

	if nodeId == 40 then
		return _M._to_23_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_23_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_38_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tSkillId", 10800351)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(23)

	return true
end

function _M._to_40_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_37_3(flow)

	if _0 then
		flow:setActive()
		_C(40, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_38_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 1.5)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 4)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(40)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_24_3(flow)
	local _0 = _C(30, "GetAoiEntityTableByLevel", flow, 0, 50, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(24, "__iterItem", v)

		_1[#_1 + 1] = v
	end

	return _1
end

function _M._get_29_3(flow)
	local _0 = flow:getCache(34, "__iterItem")

	return _C(29, "GetDistance", flow, _0, 0, false)
end

function _M._get_34_2(flow)
	local _0 = _M._get_24_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(34, "__iterItem", v)

		_1 = _M._get_29_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_37_3(flow)
	local _6 = _C(41, "RandomInteger", flow, 0, 2)
	local _0 = _6 <= 1

	if not _0 then
		return false
	end

	local _3 = _M._get_24_3(flow)
	local _4 = not _3 or next(_3) == nil
	local _1 = not _4

	if not _1 then
		return false
	end

	local _5 = _M._get_38_1(flow)
	local _2 = _C(39, "CheckEntityExist", flow, _5)

	if not _2 then
		return false
	end

	return true
end

function _M._get_38_1(flow)
	local _0 = flow:getCache(38, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_34_2(flow)

	flow:setCache(38, "1", _0)

	return _0
end

return _M
