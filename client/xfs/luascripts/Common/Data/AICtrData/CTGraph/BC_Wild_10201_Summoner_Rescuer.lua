-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_Summoner_Rescuer.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

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

local function _doBehaviourTail_1(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tAnimationKey", value1)
	agent:addSubTreeLocalParam("tAnimationTimeout", value2)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value3)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value4)
	agent:addSubTreeLocalParam("tTimelineTag", value5)
	agent:addSubTreeLocalParam("tNeedLoop", value6)
	agent:addSubTreeLocalParam("tAnimationPlayOnce", value7)
	agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", value8)
	flow:setContinue(nodeId)

	return true
end

function _M.executeTickLodTrigger(flow)
	return _M._to_93_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 95 then
		return _M._to_160_0(flow)
	end

	if nodeId == 140 then
		return _M._to_164_0(flow)
	end

	if nodeId == 160 then
		return true
	end

	if nodeId == 164 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 95 then
		return _M._get_162_1(flow)
	end

	if nodeId == 160 then
		return _M._get_162_1(flow)
	end

	if nodeId == 164 then
		return _M._get_163_1(flow)
	end
end

function _M._to_93_0(flow)
	local _0 = _M._get_138_2(flow)

	if _0 then
		return _M._to_95_0(flow)
	end

	local _1 = _M._get_139_2(flow)

	if _1 then
		return _M._to_140_0(flow)
	end
end

function _M._to_95_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 95)

	if not _1 then
		flow:setActive()
		_C(95, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_142_2(flow)

		return _doBehaviourTail_0(flow, 95, _1, 0.6, 10, true, 7, 2, 0, 1, false, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_140_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_163_1(flow)

	if _0 then
		flow:setActive()
		_C(140, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_149_2(flow)

		return _doBehaviourTail_0(flow, 140, _1, 0.6, 10, true, 7, 2, 0, 1, false, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_160_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 160)

	if not _1 then
		flow:setActive()
		_C(160, "DoBehaviour", flow, "PBT_CustomAnimation")

		return _doBehaviourTail_1(flow, 160, 0, "Behav_Cry", 9999, "", 5, "", true, false, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_164_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 164)

	if not _1 then
		flow:setActive()
		_C(164, "DoBehaviour", flow, "PBT_CustomAnimation")

		return _doBehaviourTail_1(flow, 164, 0, "Behav_Cry", 9999, "", 5, "", true, false, false)
	else
		flow:setActiveFail()
	end
end

function _M._get_3_2(flow)
	local _0 = _M._get_9_2(flow)

	return _C(3, "HasEntityTag", flow, _0, "TE_Env_UniversalMark_A")
end

function _M._get_9_3(flow)
	local _0 = _C(5, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(9, "__iterItem", v)

		if _M._get_3_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_9_2(flow)
	return flow:getCache(9, "__iterItem")
end

function _M._get_104_3(flow)
	local _0 = flow:getCache(105, "__iterItem")

	return _C(104, "GetDistance", flow, _0, 0, false)
end

function _M._get_105_2(flow)
	local _0 = _M._get_9_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(105, "__iterItem", v)

		_1 = _M._get_104_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_108_3(flow)
	local _0 = _C(112, "GetAoiEntityTableByLevel", flow, 0, 50, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(108, "__iterItem", v)

		if _M._get_110_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_108_2(flow)
	return flow:getCache(108, "__iterItem")
end

function _M._get_109_2(flow)
	local _1 = _M._get_108_2(flow)
	local _0 = _C(106, "HasEntityTag", flow, _1, "TE_Env_BreakableStone")

	if not _0 then
		return false
	end

	if false then
		return false
	end

	return true
end

function _M._get_110_2(flow)
	local _0 = _M._get_109_2(flow)

	if not _0 then
		return false
	end

	local _3 = _M._get_108_2(flow)
	local _4 = _M._get_105_2(flow)
	local _2 = _C(113, "GetDistance", flow, _3, _4, false)
	local _1 = _2 < 15

	if not _1 then
		return false
	end

	return true
end

function _M._get_114_2(flow)
	local _0 = _C(83, "GetAoiEntityTableByLevel", flow, 0, 30, 2)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(114, "__iterItem", v)

		_1 = _M._get_115_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_115_3(flow)
	local _0 = flow:getCache(114, "__iterItem")

	return _C(115, "GetDistance", flow, _0, 0, false)
end

function _M._get_124_2(flow)
	return flow:getCache(124, "__iterItem")
end

function _M._get_124_3(flow)
	local _0 = _C(123, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(124, "__iterItem", v)

		if _M._get_128_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_126_2(flow)
	local _0 = _M._get_124_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(126, "__iterItem", v)

		_1 = _M._get_127_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_127_3(flow)
	local _0 = flow:getCache(126, "__iterItem")

	return _C(127, "GetDistance", flow, _0, 0, false)
end

function _M._get_128_2(flow)
	local _0 = _M._get_124_2(flow)

	return _C(128, "HasEntityTag", flow, _0, "TE_Env_UniversalMark_A")
end

function _M._get_132_1(flow)
	local _1 = _M._get_108_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_133_2(flow)
	local _1 = _M._get_114_2(flow)
	local _2 = _M._get_126_2(flow)
	local _0 = _C(116, "GetDistance", flow, _1, _2, true)

	return _0 < 5
end

function _M._get_138_2(flow)
	local _0 = _M._get_132_1(flow)

	if not _0 then
		return false
	end

	local _1 = _M._get_133_2(flow)

	if not _1 then
		return false
	end

	return true
end

function _M._get_139_2(flow)
	local _0 = _M._get_132_1(flow)

	if not _0 then
		return false
	end

	local _2 = _M._get_133_2(flow)
	local _1 = not _2

	if not _1 then
		return false
	end

	return true
end

function _M._get_142_2(flow)
	local _0 = _M._get_145_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(142, "__iterItem", v)

		_1 = _M._get_143_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_143_3(flow)
	local _0 = flow:getCache(142, "__iterItem")

	return _C(143, "GetDistance", flow, _0, 0, false)
end

function _M._get_145_3(flow)
	local _0 = _C(144, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(145, "__iterItem", v)

		if _M._get_146_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_145_2(flow)
	return flow:getCache(145, "__iterItem")
end

function _M._get_146_2(flow)
	local _0 = _M._get_145_2(flow)

	return _C(146, "HasEntityTag", flow, _0, "TE_Env_UniversalMark_B")
end

function _M._get_149_2(flow)
	local _0 = _M._get_152_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(149, "__iterItem", v)

		_1 = _M._get_150_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_150_3(flow)
	local _0 = flow:getCache(149, "__iterItem")

	return _C(150, "GetDistance", flow, _0, 0, false)
end

function _M._get_152_3(flow)
	local _0 = _C(151, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(152, "__iterItem", v)

		if _M._get_153_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_152_2(flow)
	return flow:getCache(152, "__iterItem")
end

function _M._get_153_2(flow)
	local _0 = _M._get_152_2(flow)

	return _C(153, "HasEntityTag", flow, _0, "TE_Env_UniversalMark_C")
end

function _M._get_162_1(flow)
	local _0 = _M._get_138_2(flow)

	return not _0
end

function _M._get_163_1(flow)
	local _0 = _M._get_139_2(flow)

	return not _0
end

return _M
