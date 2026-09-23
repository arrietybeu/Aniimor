-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Burrow_Maku_Leave_01.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_17_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 17 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_17_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_66_2(flow)

	if _0 then
		flow:setActive()
		_C(17, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_7_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 0)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 30)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 3)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 0)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(17)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_1_2(flow)
	local _0 = _C(0, "GetAoiEntityTableByLevel", flow, 0, 50, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(1, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_15_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_7_1(flow)
	local _0 = _M._get_1_2(flow)

	return _C(7, "SelectOneByRandom", flow, _0)
end

function _M._get_15_2(flow)
	local _0 = flow:getCache(1, "__iterItem")

	return _C(15, "HasEntityTag", flow, _0, "TE_Env_Leave_Maku_Mark_A")
end

function _M._get_59_2(flow)
	local _0 = _C(67, "GetAoiEntityTableByLevel", flow, 0, 50, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(59, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_68_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_66_2(flow)
	local _1 = _C(64, "GetAoiEntityTableByLevel", flow, 0, 50, 2)
	local _2 = _C(60, "SelectOneByRandom", flow, _1)
	local _3 = _M._get_59_2(flow)
	local _4 = _C(63, "SelectOneByRandom", flow, _3)
	local _0 = _C(65, "GetDistance", flow, _2, _4, false)

	return _0 <= 7.6
end

function _M._get_68_2(flow)
	local _0 = flow:getCache(59, "__iterItem")

	return _C(68, "HasEntityTag", flow, _0, "TE_Env_Leave_Maku_Center")
end

return _M
