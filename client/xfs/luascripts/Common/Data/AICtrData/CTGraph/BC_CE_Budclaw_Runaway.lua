-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_CE_Budclaw_Runaway.lua

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
	return _M._to_399_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 144 then
		return true
	end

	if nodeId == 193 then
		return true
	end

	if nodeId == 249 then
		return true
	end

	if nodeId == 251 then
		return true
	end

	if nodeId == 267 then
		return true
	end

	if nodeId == 269 then
		return true
	end

	if nodeId == 284 then
		return true
	end

	if nodeId == 286 then
		return true
	end

	if nodeId == 443 then
		return true
	end

	if nodeId == 444 then
		return true
	end

	if nodeId == 445 then
		return true
	end

	if nodeId == 446 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_144_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_114_1(flow)

	return _doBehaviourTail_0(flow, 144, _0, 0.3, 5, true, 9, 99999, 0, 0, false, false)
end

function _M._to_192_0(flow)
	local _2 = _M._get_123_3(flow)
	local _3 = _M._get_142_3(flow)
	local _0 = _3 <= _2

	if _0 then
		return _M._to_144_0(flow)
	end

	local _4 = _M._get_123_3(flow)
	local _5 = _M._get_142_3(flow)
	local _1 = _4 <= _5

	if _1 then
		return _M._to_193_0(flow)
	end
end

function _M._to_193_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_140_1(flow)

	return _doBehaviourTail_0(flow, 193, _0, 0.3, 5, true, 9, 99999, 0, 0, false, false)
end

function _M._to_216_0(flow)
	local _2 = _C(204, "GetAoiEntityTableByLevel", flow, 0, 30, 2)
	local _3 = _C(201, "SelectOneByRandom", flow, _2)
	local _1 = _C(206, "GetDistance", flow, 0, _3, false)
	local _0 = _1 <= 5.4

	if _0 then
		return _M._to_217_0(flow)
	end
end

function _M._to_217_0(flow)
	local _4 = _M._get_223_3(flow)
	local _0 = _4 <= 1.5

	if _0 then
		return _M._to_250_0(flow)
	end

	local _5 = _M._get_230_3(flow)
	local _1 = _5 <= 1.5

	if _1 then
		return _M._to_192_0(flow)
	end

	local _6 = _M._get_236_3(flow)
	local _2 = _6 <= 1.5

	if _2 then
		return _M._to_268_0(flow)
	end

	local _7 = _M._get_242_3(flow)
	local _3 = _7 <= 1.5

	if _3 then
		return _M._to_285_0(flow)
	end
end

function _M._to_249_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_247_1(flow)

	return _doBehaviourTail_0(flow, 249, _0, 0.3, 5, true, 9, 99999, 0, 0, false, false)
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

	return _doBehaviourTail_0(flow, 251, _0, 0.3, 5, true, 9, 99999, 0, 0, false, false)
end

function _M._to_267_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_266_1(flow)

	return _doBehaviourTail_0(flow, 267, _0, 0.3, 5, true, 9, 99999, 0, 0, false, false)
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

	return _doBehaviourTail_0(flow, 269, _0, 0.3, 5, true, 9, 99999, 0, 0, false, false)
end

function _M._to_284_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_283_1(flow)

	return _doBehaviourTail_0(flow, 284, _0, 0.3, 5, true, 9, 99999, 0, 0, false, false)
end

function _M._to_285_0(flow)
	local _2 = _M._get_289_3(flow)
	local _3 = _M._get_290_3(flow)
	local _0 = _3 <= _2

	if _0 then
		return _M._to_286_0(flow)
	end

	local _4 = _M._get_289_3(flow)
	local _5 = _M._get_290_3(flow)
	local _1 = _4 <= _5

	if _1 then
		return _M._to_284_0(flow)
	end
end

function _M._to_286_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_278_1(flow)

	return _doBehaviourTail_0(flow, 286, _0, 0.3, 5, true, 9, 99999, 0, 0, false, false)
end

function _M._to_399_0(flow)
	local _0 = _M._get_397_2(flow)

	if _0 then
		return _M._to_442_0(flow)
	end

	local _2 = _M._get_397_2(flow)
	local _1 = not _2

	if _1 then
		return _M._to_216_0(flow)
	end
end

function _M._to_442_0(flow)
	local _0 = _M._get_438_3(flow)

	if _0 then
		return _M._to_443_0(flow)
	end

	local _1 = _M._get_439_3(flow)

	if _1 then
		return _M._to_444_0(flow)
	end

	local _2 = _M._get_440_3(flow)

	if _2 then
		return _M._to_445_0(flow)
	end

	local _3 = _M._get_441_3(flow)

	if _3 then
		return _M._to_446_0(flow)
	end
end

function _M._to_443_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_222_1(flow)

	return _doBehaviourTail_0(flow, 443, _0, 0.3, 5, true, 9, 99999, 0, 0, false, false)
end

function _M._to_444_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_226_1(flow)

	return _doBehaviourTail_0(flow, 444, _0, 0.3, 5, true, 9, 99999, 0, 0, false, false)
end

function _M._to_445_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_232_1(flow)

	return _doBehaviourTail_0(flow, 445, _0, 0.3, 5, true, 9, 99999, 0, 0, false, false)
end

function _M._to_446_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_238_1(flow)

	return _doBehaviourTail_0(flow, 446, _0, 0.3, 5, true, 9, 99999, 0, 0, false, false)
end

function _M._get_111_2(flow)
	local _0 = _C(110, "GetAoiEntityTableByLevel", flow, 0, 30, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(111, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_118_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_114_1(flow)
	local _0 = _M._get_111_2(flow)

	return _C(114, "SelectOneByRandom", flow, _0)
end

function _M._get_118_2(flow)
	local _0 = flow:getCache(111, "__iterItem")

	return _C(118, "HasEntityTag", flow, _0, "TE_Env_CE_Budclaw_A")
end

function _M._get_123_3(flow)
	local _0 = _M._get_114_1(flow)
	local _1 = _M._get_129_1(flow)

	return _C(123, "GetDistance", flow, _0, _1, false)
end

function _M._get_129_1(flow)
	local _0 = _C(131, "GetAoiEntityTableByLevel", flow, 0, 50, 2)

	return _C(129, "SelectOneByRandom", flow, _0)
end

function _M._get_137_2(flow)
	local _0 = _C(136, "GetAoiEntityTableByLevel", flow, 0, 30, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(137, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_141_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_140_1(flow)
	local _0 = _M._get_137_2(flow)

	return _C(140, "SelectOneByRandom", flow, _0)
end

function _M._get_141_2(flow)
	local _0 = flow:getCache(137, "__iterItem")

	return _C(141, "HasEntityTag", flow, _0, "TE_Env_CE_Budclaw_C")
end

function _M._get_142_3(flow)
	local _0 = _M._get_129_1(flow)
	local _1 = _M._get_140_1(flow)

	return _C(142, "GetDistance", flow, _0, _1, false)
end

function _M._get_220_2(flow)
	local _0 = _C(219, "GetAoiEntityTableByLevel", flow, 0, 30, 256)

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

function _M._get_222_1(flow)
	local _0 = _M._get_220_2(flow)

	return _C(222, "SelectOneByRandom", flow, _0)
end

function _M._get_223_3(flow)
	local _0 = _M._get_222_1(flow)

	return _C(223, "GetDistance", flow, _0, 0, false)
end

function _M._get_226_1(flow)
	local _0 = _M._get_227_2(flow)

	return _C(226, "SelectOneByRandom", flow, _0)
end

function _M._get_227_2(flow)
	local _0 = _C(229, "GetAoiEntityTableByLevel", flow, 0, 30, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(227, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_228_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_228_2(flow)
	local _0 = flow:getCache(227, "__iterItem")

	return _C(228, "HasEntityTag", flow, _0, "TE_Env_CE_Budclaw_B")
end

function _M._get_230_3(flow)
	local _0 = _M._get_226_1(flow)

	return _C(230, "GetDistance", flow, _0, 0, false)
end

function _M._get_232_1(flow)
	local _0 = _M._get_233_2(flow)

	return _C(232, "SelectOneByRandom", flow, _0)
end

function _M._get_233_2(flow)
	local _0 = _C(235, "GetAoiEntityTableByLevel", flow, 0, 30, 256)

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

function _M._get_236_3(flow)
	local _0 = _M._get_232_1(flow)

	return _C(236, "GetDistance", flow, _0, 0, false)
end

function _M._get_238_1(flow)
	local _0 = _M._get_239_2(flow)

	return _C(238, "SelectOneByRandom", flow, _0)
end

function _M._get_239_2(flow)
	local _0 = _C(241, "GetAoiEntityTableByLevel", flow, 0, 30, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(239, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_240_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_240_2(flow)
	local _0 = flow:getCache(239, "__iterItem")

	return _C(240, "HasEntityTag", flow, _0, "TE_Env_CE_Budclaw_D")
end

function _M._get_242_3(flow)
	local _0 = _M._get_238_1(flow)

	return _C(242, "GetDistance", flow, _0, 0, false)
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

function _M._get_277_2(flow)
	local _0 = _C(287, "GetAoiEntityTableByLevel", flow, 0, 30, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(277, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_292_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_278_1(flow)
	local _0 = _M._get_277_2(flow)

	return _C(278, "SelectOneByRandom", flow, _0)
end

function _M._get_279_2(flow)
	local _0 = _C(282, "GetAoiEntityTableByLevel", flow, 0, 30, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(279, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_293_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_280_1(flow)
	local _0 = _C(281, "GetAoiEntityTableByLevel", flow, 0, 50, 2)

	return _C(280, "SelectOneByRandom", flow, _0)
end

function _M._get_283_1(flow)
	local _0 = _M._get_279_2(flow)

	return _C(283, "SelectOneByRandom", flow, _0)
end

function _M._get_289_3(flow)
	local _0 = _M._get_278_1(flow)
	local _1 = _M._get_280_1(flow)

	return _C(289, "GetDistance", flow, _0, _1, false)
end

function _M._get_290_3(flow)
	local _0 = _M._get_280_1(flow)
	local _1 = _M._get_283_1(flow)

	return _C(290, "GetDistance", flow, _0, _1, false)
end

function _M._get_292_2(flow)
	local _0 = flow:getCache(277, "__iterItem")

	return _C(292, "HasEntityTag", flow, _0, "TE_Env_CE_Budclaw_A")
end

function _M._get_293_2(flow)
	local _0 = flow:getCache(279, "__iterItem")

	return _C(293, "HasEntityTag", flow, _0, "TE_Env_CE_Budclaw_C")
end

function _M._get_396_2(flow)
	local _0 = flow:getCache(397, "__iterItem")

	return _C(396, "HasEntityTag", flow, _0, "TE_Env_EndMark")
end

function _M._get_397_2(flow)
	local _0 = _C(395, "GetAoiEntityTableByLevel", flow, 0, 50, 256)

	if _0 == nil then
		return
	end

	for k, v in ipairs(_0) do
		local _1 = pg.getEntityByActorId(v)

		flow:setCache(397, "__iterItem", _1 and _1.actorId or 0)

		if _M._get_396_2(flow) then
			return true
		end
	end

	return false
end

function _M._get_438_3(flow)
	local _3 = _M._get_223_3(flow)
	local _4 = _M._get_230_3(flow)
	local _0 = _3 <= _4

	if not _0 then
		return false
	end

	local _5 = _M._get_223_3(flow)
	local _6 = _M._get_236_3(flow)
	local _1 = _5 <= _6

	if not _1 then
		return false
	end

	local _7 = _M._get_223_3(flow)
	local _8 = _M._get_242_3(flow)
	local _2 = _7 <= _8

	if not _2 then
		return false
	end

	return true
end

function _M._get_439_3(flow)
	local _3 = _M._get_230_3(flow)
	local _4 = _M._get_223_3(flow)
	local _0 = _3 <= _4

	if not _0 then
		return false
	end

	local _5 = _M._get_230_3(flow)
	local _6 = _M._get_236_3(flow)
	local _1 = _5 <= _6

	if not _1 then
		return false
	end

	local _7 = _M._get_230_3(flow)
	local _8 = _M._get_242_3(flow)
	local _2 = _7 <= _8

	if not _2 then
		return false
	end

	return true
end

function _M._get_440_3(flow)
	local _3 = _M._get_236_3(flow)
	local _4 = _M._get_223_3(flow)
	local _0 = _3 <= _4

	if not _0 then
		return false
	end

	local _5 = _M._get_236_3(flow)
	local _6 = _M._get_230_3(flow)
	local _1 = _5 <= _6

	if not _1 then
		return false
	end

	local _7 = _M._get_236_3(flow)
	local _8 = _M._get_242_3(flow)
	local _2 = _7 <= _8

	if not _2 then
		return false
	end

	return true
end

function _M._get_441_3(flow)
	local _3 = _M._get_242_3(flow)
	local _4 = _M._get_223_3(flow)
	local _0 = _3 <= _4

	if not _0 then
		return false
	end

	local _5 = _M._get_242_3(flow)
	local _6 = _M._get_230_3(flow)
	local _1 = _5 <= _6

	if not _1 then
		return false
	end

	local _7 = _M._get_242_3(flow)
	local _8 = _M._get_236_3(flow)
	local _2 = _7 <= _8

	if not _2 then
		return false
	end

	return true
end

return _M
