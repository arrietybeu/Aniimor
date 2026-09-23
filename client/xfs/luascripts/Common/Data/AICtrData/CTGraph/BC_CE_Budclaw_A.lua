-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_CE_Budclaw_A.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8, value9)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tTargetActorId", value0)
	agent:addSubTreeLocalParam("tStopDist", value1)
	agent:addSubTreeLocalParam("tMaxTimeout", value2)
	agent:addSubTreeLocalParam("tFaceTarget", value3)
	agent:addSubTreeLocalParam("tSpeed", value4)
	agent:addSubTreeLocalParam("tMoveUpdateLevel", value5)
	agent:addSubTreeLocalParam("tPathFindType", value6)
	agent:addSubTreeLocalParam("tSpeedRateType", value7)
	agent:addSubTreeLocalParam("tUseAccurateArrive", value8)
	agent:addSubTreeLocalParam("tNoBodySize", value9)
	flow:setContinue(nodeId)

	return true
end

function _M.executeTickLodTrigger(flow)
	return _M._to_216_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 249 then
		return true
	end

	if nodeId == 251 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_216_0(flow)
	local _2 = _C(204, "GetAoiEntityTableByLevel", flow, 0, 30, 2)
	local _3 = _C(201, "SelectOneByRandom", flow, _2)
	local _1 = _C(206, "GetDistance", flow, 0, _3, false)
	local _0 = _1 <= 4

	if _0 then
		return _M._to_217_0(flow)
	end
end

function _M._to_217_0(flow)
	local _1 = _M._get_220_2(flow)
	local _2 = _C(222, "SelectOneByRandom", flow, _1)
	local _3 = _C(223, "GetDistance", flow, _2, 0, false)
	local _0 = _3 <= 1.5

	if _0 then
		return _M._to_250_0(flow)
	end
end

function _M._to_249_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_247_1(flow)

	return _doBehaviourTail_0(flow, 249, _0, 0, 5, true, 9, 99999, 0, 0, false, false)
end

function _M._to_250_0(flow)
	local _2 = _M._get_257_3(flow)
	local _3 = _M._get_258_3(flow)
	local _0 = _3 <= _2

	if _0 then
		return _M._to_251_0(flow)
	end

	local _4 = _M._get_257_3(flow)
	local _5 = _M._get_258_3(flow)
	local _1 = _4 <= _5

	if _1 then
		return _M._to_249_0(flow)
	end
end

function _M._to_251_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_255_1(flow)

	return _doBehaviourTail_0(flow, 251, _0, 0, 5, true, 9, 99999, 0, 0, false, false)
end

function _M._get_220_2(flow)
	local _0 = _C(219, "GetAoiEntityTableByLevel", flow, 0, 10, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(220, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_221_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_221_2(flow)
	local _0 = flow:getCache(220, "__iterItem")

	return _C(221, "HasEntityTag", flow, _0, "TE_Env_CE_Budclaw_A")
end

function _M._get_243_2(flow)
	local _0 = _C(246, "GetAoiEntityTableByLevel", flow, 0, 30, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(243, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_248_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_244_1(flow)
	local _0 = _C(245, "GetAoiEntityTableByLevel", flow, 0, 50, 2)

	return _C(244, "SelectOneByRandom", flow, _0)
end

function _M._get_247_1(flow)
	local _0 = _M._get_243_2(flow)

	return _C(247, "SelectOneByRandom", flow, _0)
end

function _M._get_248_2(flow)
	local _0 = flow:getCache(243, "__iterItem")

	return _C(248, "HasEntityTag", flow, _0, "TE_Env_CE_Budclaw_B")
end

function _M._get_253_2(flow)
	local _0 = _C(252, "GetAoiEntityTableByLevel", flow, 0, 30, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(253, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_254_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_254_2(flow)
	local _0 = flow:getCache(253, "__iterItem")

	return _C(254, "HasEntityTag", flow, _0, "TE_Env_CE_Budclaw_D")
end

function _M._get_255_1(flow)
	local _0 = _M._get_253_2(flow)

	return _C(255, "SelectOneByRandom", flow, _0)
end

function _M._get_257_3(flow)
	local _0 = _M._get_255_1(flow)
	local _1 = _M._get_244_1(flow)

	return _C(257, "GetDistance", flow, _0, _1, false)
end

function _M._get_258_3(flow)
	local _0 = _M._get_244_1(flow)
	local _1 = _M._get_247_1(flow)

	return _C(258, "GetDistance", flow, _0, _1, false)
end

return _M
