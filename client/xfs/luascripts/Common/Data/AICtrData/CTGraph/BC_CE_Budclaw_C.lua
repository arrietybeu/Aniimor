-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_CE_Budclaw_C.lua

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
	if nodeId == 267 then
		return true
	end

	if nodeId == 269 then
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
	local _2 = _M._get_233_2(flow)
	local _3 = _C(232, "SelectOneByRandom", flow, _2)
	local _1 = _C(236, "GetDistance", flow, _3, 0, false)
	local _0 = _1 <= 1.5

	if _0 then
		return _M._to_268_0(flow)
	end
end

function _M._to_267_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_266_1(flow)

	return _doBehaviourTail_0(flow, 267, _0, 0, 5, true, 9, 99999, 0, 0, false, false)
end

function _M._to_268_0(flow)
	local _2 = _M._get_272_3(flow)
	local _3 = _M._get_273_3(flow)
	local _0 = _3 <= _2

	if _0 then
		return _M._to_269_0(flow)
	end

	local _4 = _M._get_272_3(flow)
	local _5 = _M._get_273_3(flow)
	local _1 = _4 <= _5

	if _1 then
		return _M._to_267_0(flow)
	end
end

function _M._to_269_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_261_1(flow)

	return _doBehaviourTail_0(flow, 269, _0, 0, 5, true, 9, 99999, 0, 0, false, false)
end

function _M._get_233_2(flow)
	local _0 = _C(235, "GetAoiEntityTableByLevel", flow, 0, 10, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(233, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_234_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_234_2(flow)
	local _0 = flow:getCache(233, "__iterItem")

	return _C(234, "HasEntityTag", flow, _0, "TE_Env_CE_Budclaw_C")
end

function _M._get_260_2(flow)
	local _0 = _C(270, "GetAoiEntityTableByLevel", flow, 0, 30, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(260, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_275_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_261_1(flow)
	local _0 = _M._get_260_2(flow)

	return _C(261, "SelectOneByRandom", flow, _0)
end

function _M._get_262_2(flow)
	local _0 = _C(265, "GetAoiEntityTableByLevel", flow, 0, 30, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(262, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_276_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_263_1(flow)
	local _0 = _C(264, "GetAoiEntityTableByLevel", flow, 0, 50, 2)

	return _C(263, "SelectOneByRandom", flow, _0)
end

function _M._get_266_1(flow)
	local _0 = _M._get_262_2(flow)

	return _C(266, "SelectOneByRandom", flow, _0)
end

function _M._get_272_3(flow)
	local _0 = _M._get_261_1(flow)
	local _1 = _M._get_263_1(flow)

	return _C(272, "GetDistance", flow, _0, _1, false)
end

function _M._get_273_3(flow)
	local _0 = _M._get_263_1(flow)
	local _1 = _M._get_266_1(flow)

	return _C(273, "GetDistance", flow, _0, _1, false)
end

function _M._get_275_2(flow)
	local _0 = flow:getCache(260, "__iterItem")

	return _C(275, "HasEntityTag", flow, _0, "TE_Env_CE_Budclaw_B")
end

function _M._get_276_2(flow)
	local _0 = flow:getCache(262, "__iterItem")

	return _C(276, "HasEntityTag", flow, _0, "TE_Env_CE_Budclaw_D")
end

return _M
