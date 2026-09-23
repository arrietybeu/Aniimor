-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Burrow_Maku_1.lua

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
	return _M._to_144_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 144 then
		return _M._to_152_0(flow)
	end

	if nodeId == 152 then
		return _M._to_169_0(flow)
	end

	if nodeId == 169 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_144_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_117_2(flow)

	if _0 then
		flow:setActive()
		_C(144, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_114_1(flow)

		return _doBehaviourTail_0(flow, 144, _1, 0, 30, true, 6, 99999, 0, 0, false, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_152_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_150_1(flow)

	return _doBehaviourTail_0(flow, 152, _0, 0, 30, true, 10, 99999, 0, 0, false, false)
end

function _M._to_169_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_167_1(flow)

	return _doBehaviourTail_0(flow, 169, _0, 0, 30, true, 6, 99999, 0, 0, false, false)
end

function _M._get_111_2(flow)
	local _0 = _C(110, "GetAoiEntityTableByLevel", flow, 0, 50, 256)

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

function _M._get_117_2(flow)
	local _2 = _M._get_114_1(flow)
	local _3 = _M._get_129_1(flow)
	local _4 = _C(123, "GetDistance", flow, _2, _3, false)
	local _5 = _M._get_129_1(flow)
	local _6 = _M._get_137_2(flow)
	local _7 = _C(140, "SelectOneByRandom", flow, _6)
	local _8 = _C(142, "GetDistance", flow, _5, _7, false)
	local _0 = _8 <= _4

	if not _0 then
		return false
	end

	local _9 = _M._get_129_1(flow)
	local _10 = _M._get_182_2(flow)
	local _11 = _C(184, "SelectOneByRandom", flow, _10)
	local _12 = _C(186, "GetDistance", flow, _9, _11, false)
	local _1 = _12 <= 7.6

	if not _1 then
		return false
	end

	return true
end

function _M._get_118_2(flow)
	local _0 = flow:getCache(111, "__iterItem")

	return _C(118, "HasEntityTag", flow, _0, "TE_Env_Leave_Maku1_1")
end

function _M._get_129_1(flow)
	local _0 = _C(131, "GetAoiEntityTableByLevel", flow, 0, 50, 2)

	return _C(129, "SelectOneByRandom", flow, _0)
end

function _M._get_137_2(flow)
	local _0 = _C(136, "GetAoiEntityTableByLevel", flow, 0, 50, 256)

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

function _M._get_138_1(flow)
	local _0 = _M._get_137_2(flow)

	return not _0 or next(_0) == nil
end

function _M._get_141_2(flow)
	local _0 = flow:getCache(137, "__iterItem")

	return _C(141, "HasEntityTag", flow, _0, "TE_Env_Leave_Maku2_1")
end

function _M._get_146_2(flow)
	local _0 = _C(147, "GetAoiEntityTableByLevel", flow, 0, 50, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(146, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_151_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_150_1(flow)
	local _0 = _M._get_146_2(flow)

	return _C(150, "SelectOneByRandom", flow, _0)
end

function _M._get_151_2(flow)
	local _0 = flow:getCache(146, "__iterItem")

	return _C(151, "HasEntityTag", flow, _0, "TE_Env_Leave_Maku1_2")
end

function _M._get_165_2(flow)
	local _0 = flow:getCache(166, "__iterItem")

	return _C(165, "HasEntityTag", flow, _0, "TE_Env_Leave_Maku1_3")
end

function _M._get_166_2(flow)
	local _0 = _C(168, "GetAoiEntityTableByLevel", flow, 0, 50, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(166, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_165_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_167_1(flow)
	local _0 = _M._get_166_2(flow)

	return _C(167, "SelectOneByRandom", flow, _0)
end

function _M._get_182_2(flow)
	local _0 = _C(188, "GetAoiEntityTableByLevel", flow, 0, 50, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(182, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_189_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_189_2(flow)
	local _0 = flow:getCache(182, "__iterItem")

	return _C(189, "HasEntityTag", flow, _0, "TE_Env_Leave_Maku_Center")
end

return _M
