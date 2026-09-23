-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_CE_Budclaw_B.lua

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
	if nodeId == 144 then
		return true
	end

	if nodeId == 193 then
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

	return _doBehaviourTail_0(flow, 144, _0, 0, 5, true, 9, 99999, 0, 0, false, false)
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

	return _doBehaviourTail_0(flow, 193, _0, 0, 5, true, 9, 99999, 0, 0, false, false)
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
	return _M._to_192_0(flow)
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

function _M._get_225_2(flow)
	local _1 = _M._get_227_2(flow)
	local _2 = _C(226, "SelectOneByRandom", flow, _1)
	local _0 = _C(230, "GetDistance", flow, _2, 0, false)

	return _0 <= 1.5
end

function _M._get_227_2(flow)
	local _0 = _C(229, "GetAoiEntityTableByLevel", flow, 0, 10, 256)

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

return _M
