-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10011_EatStarFruit.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_37_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_43_1(flow)

	_A(flow, "RemoveEntityTag", _0, "TE_Env_BeUsed")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 37 then
		return _M._to_48_0(flow)
	end

	if nodeId == 42 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 37 then
		return _M._get_54_2(flow)
	end
end

function _M._to_37_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_40_1(flow)
	local _1 = _M.checkInterrupt(flow, 37)

	if _0 and not _1 then
		flow:setActive()
		_C(37, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _2 = _M._get_43_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _2)
		flow.__agent:addSubTreeLocalParam("tStopDist", 0.2)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 0)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(37)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_42_0(flow)
	if not _B(flow, "PBT_Eat") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("eatTimeOut", 5)
	flow:setContinue(42)

	return true
end

function _M._to_48_0(flow)
	flow:setActive()

	local _0 = _M._get_43_1(flow)

	_A(flow, "AddEntityTag", _0, "TE_Env_BeUsed")

	return _M._to_42_0(flow)
end

function _M._get_31_2(flow)
	return flow:getCache(31, "__iterItem")
end

function _M._get_31_3(flow)
	local _0 = _C(29, "GetAoiEntityTableByLevel", flow, 0, 10, 64)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(31, "__iterItem", v)

		if _M._get_36_4(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_36_4(flow)
	local _4 = _M._get_31_2(flow)
	local _0 = _C(30, "HasEntityTag", flow, _4, "TE_Chest_StarFruit")

	if not _0 then
		return false
	end

	local _5 = _M._get_31_2(flow)
	local _6 = _C(34, "GetSelfId", flow)
	local _7 = _C(33, "GetDistance", flow, _5, _6, false)
	local _1 = _7 <= 10

	if not _1 then
		return false
	end

	local _8 = _M._get_31_2(flow)
	local _2 = _C(44, "HasEntityTag", flow, _8, "TE_Chest_Collectible_Starise")

	if not _2 then
		return false
	end

	local _9 = _M._get_31_2(flow)
	local _10 = _C(45, "HasEntityTag", flow, _9, "TE_Env_BeUsed")
	local _3 = not _10

	if not _3 then
		return false
	end

	return true
end

function _M._get_40_1(flow)
	local _1 = _M._get_31_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_41_1(flow)
	local _0 = _M._get_31_3(flow)

	return _C(41, "SelectOneByRandom", flow, _0)
end

function _M._get_43_1(flow)
	local _0 = flow:getCache(43, "id")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_41_1(flow)

	flow:setCache(43, "id", _0)

	return _0
end

function _M._get_54_2(flow)
	local _0 = _M._get_43_1(flow)

	return _C(54, "HasEntityTag", flow, _0, "TE_Env_BeUsed")
end

return _M
