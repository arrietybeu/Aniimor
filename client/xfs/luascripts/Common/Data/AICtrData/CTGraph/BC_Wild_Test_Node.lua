-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_Test_Node.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_45_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_41_1(flow)
	local _1 = _M._get_41_2(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 0)
	flow:setActive()
	_A(flow, "playSound", 0, "", 0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 39 then
		return _M._to_53_0(flow)
	end

	if nodeId == 53 then
		return true
	end

	if nodeId == 55 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_39_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_41_1(flow)
	local _1 = _M._get_41_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tPointId", _0)
	flow.__agent:addSubTreeLocalParam("tPortId", _1)
	flow.__agent:addSubTreeLocalParam("tTimeout", 1000)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tSpeed", 6)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow:setContinue(39)

	return true
end

function _M._to_45_0(flow)
	local _0 = _M._get_58_2(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_41_1(flow)
		local _2 = _M._get_41_2(flow)

		_A(flow, "PreJoinResPointPort", 0, _1, _2)

		return _M._to_39_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._to_53_0(flow)
	if not _B(flow, "PBT_CastNormalAtkCombo") then
		return
	end

	local _0 = _M._get_72_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tSkipBackswing", true)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(53)

	return true
end

function _M._get_41_1(flow)
	local _0 = _M._get_49_1(flow)

	return _C(41, "UnpackResPointPort", flow, _0, 1)
end

function _M._get_41_2(flow)
	local _0 = _M._get_49_1(flow)

	return _C(41, "UnpackResPointPort", flow, _0, 2)
end

function _M._get_47_1(flow)
	local _0 = _M._get_50_2(flow)

	return _C(47, "SelectOneByRandom", flow, _0)
end

function _M._get_49_1(flow)
	local _0 = flow:getCache(49, "resPointPort")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_47_1(flow)

	flow:setCache(49, "resPointPort", _0)

	return _0
end

function _M._get_50_2(flow)
	local _0 = _C(46, "GetAoiResPointPortTableByLevel", flow, 0, 30, 0, {
		"TR_Test_Node"
	}, nil)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		flow:setCache(50, "__iterItem", v)

		if _M._get_52_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_52_2(flow)
	local _1 = flow:getCache(50, "__iterItem")
	local _0 = _C(51, "GetDistanceFromEntityToResPointPort", flow, 0, _1)

	return _0 < 30
end

function _M._get_58_2(flow)
	local _5 = _C(67, "GetAoiEntityTableByLevel", flow, 0, 30, 8)
	local _4 = _C(68, "SelectOneByRandom", flow, _5)
	local _0 = _C(66, "CheckEntityExist", flow, _4)

	if not _0 then
		return false
	end

	local _3 = _M._get_50_2(flow)
	local _2 = not _3 or next(_3) == nil
	local _1 = not _2

	if not _1 then
		return false
	end

	return true
end

function _M._get_72_1(flow)
	local _0 = _C(71, "GetAoiEntityTableByLevel", flow, 0, 10, 256)

	return _C(72, "SelectOneByRandom", flow, _0)
end

return _M
