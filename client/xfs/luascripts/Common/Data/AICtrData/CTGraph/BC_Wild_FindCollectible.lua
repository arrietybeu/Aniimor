-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_FindCollectible.lua

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
		return _M._to_64_0(flow)
	end

	if nodeId == 42 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_37_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_63_2(flow)

	if _0 then
		flow:setActive()
		_C(37, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_43_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
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

function _M._to_64_0(flow)
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

		if _M._get_36_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_36_2(flow)
	local _2 = _M._get_31_2(flow)
	local _0 = _C(30, "HasEntityTag", flow, _2, "TE_Chest_Collectible")

	if not _0 then
		return false
	end

	local _3 = _M._get_31_2(flow)
	local _4 = _C(34, "GetSelfId", flow)
	local _5 = _C(33, "GetDistance", flow, _3, _4, false)
	local _1 = _5 <= 10

	if not _1 then
		return false
	end

	return true
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

function _M._get_50_2(flow)
	return flow:getCache(50, "__iterItem")
end

function _M._get_50_3(flow)
	local _0 = _C(48, "GetAoiEntityTableByLevel", flow, 0, 10, 64)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(50, "__iterItem", v)

		if _M._get_55_3(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_55_3(flow)
	local _3 = _M._get_50_2(flow)
	local _0 = _C(49, "HasEntityTag", flow, _3, "TE_Chest_Collectible")

	if not _0 then
		return false
	end

	local _4 = _M._get_50_2(flow)
	local _5 = _C(53, "GetSelfId", flow)
	local _6 = _C(52, "GetDistance", flow, _4, _5, false)
	local _1 = _6 <= 10

	if not _1 then
		return false
	end

	local _7 = _M._get_50_2(flow)
	local _2 = _C(61, "HasEntityTag", flow, _7, "TE_Chest_Collectible_Starise")

	if not _2 then
		return false
	end

	return true
end

function _M._get_60_2(flow)
	local _2 = _C(44, "GetSelfId", flow)
	local _3 = _C(45, "GetPuppetData", flow, _2, "baseFormPet", true, 0)
	local _0 = _3 == 1001100

	if not _0 then
		return false
	end

	local _4 = _M._get_50_3(flow)
	local _5 = not _4 or next(_4) == nil
	local _1 = not _5

	if not _1 then
		return false
	end

	return true
end

function _M._get_63_2(flow)
	local _4 = _M._get_60_2(flow)
	local _0 = not _4

	if not _0 then
		return false
	end

	local _2 = _M._get_31_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _1 = not _3

	if not _1 then
		return false
	end

	return true
end

return _M
