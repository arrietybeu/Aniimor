-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10501_ChargeTreeToEatSleepFruit.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
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

local function _doBehaviourTail_1(flow, nodeId, value0, value1, value2, value3, value4, value5, value6)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tSkillId", value1)
	agent:addSubTreeLocalParam("tSkillTargetActorId", value2)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value3)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value4)
	agent:addSubTreeLocalParam("tRaycastOpen", value5)
	agent:addSubTreeLocalParam("tCastAbilitySource", value6)
	flow:setContinue(nodeId)

	return true
end

function _M.executeTickLodTrigger(flow)
	return _M._to_159_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 102 then
		return _M._to_152_0(flow)
	end

	if nodeId == 113 then
		return _M._to_144_0(flow)
	end

	if nodeId == 117 then
		return true
	end

	if nodeId == 129 then
		return _M._to_117_0(flow)
	end

	if nodeId == 144 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_102_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_103_3(flow)

	if _0 then
		flow:setActive()
		_C(102, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_104_1(flow)

		return _doBehaviourTail_0(flow, 102, _1, 1, 4, true, 6, 99999, 0, 2, false, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_108_0(flow)
	local _2 = _M._get_109_1(flow)
	local _0 = not _2

	if _0 then
		return _M._to_113_0(flow)
	end

	local _1 = _M._get_109_1(flow)

	if _1 then
		return _M._to_102_0(flow)
	end
end

function _M._to_113_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_158_2(flow)

	if _0 then
		flow:setActive()
		_C(113, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_104_1(flow)

		return _doBehaviourTail_0(flow, 113, _1, 1, 6, true, 1, 99999, 0, 0, false, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_117_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_128_3(flow)

	if _0 then
		flow:setActive()
		_C(117, "DoBehaviour", flow, "PBT_CastSkill")

		local _1 = _M._get_126_1(flow)

		return _doBehaviourTail_1(flow, 117, 0, 10800351, _1, "", 5, false, 0)
	else
		flow:setActiveFail()
	end
end

function _M._to_129_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	local _0 = _C(151, "RandomInteger", flow, 10, 30)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", _0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Ai_Walk")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "Think")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", true)
	flow:setContinue(129)

	return true
end

function _M._to_144_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_143_3(flow)

	if _0 then
		flow:setActive()
		_C(144, "DoBehaviour", flow, "PBT_CastSkill")

		local _1 = _M._get_140_1(flow)

		return _doBehaviourTail_1(flow, 144, 0, 10800351, _1, "", 5, false, 0)
	else
		flow:setActiveFail()
	end
end

function _M._to_152_0(flow)
	flow:setActive()

	local _0 = _C(153, "GetSelfId", flow)

	_A(flow, "StartNpcDialog", 70008556, _0)

	return _M._to_129_0(flow)
end

function _M._to_159_0(flow)
	local _0 = _M._get_163_2(flow)

	if _0 then
		return _M._to_108_0(flow)
	end
end

function _M._get_93_2(flow)
	local _0 = _M._get_101_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(93, "__iterItem", v)

		_1 = _M._get_96_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_96_3(flow)
	local _0 = flow:getCache(93, "__iterItem")

	return _C(96, "GetDistance", flow, _0, 0, false)
end

function _M._get_98_3(flow)
	local _0 = _M._get_101_2(flow)

	return _C(98, "HasEntityTag", flow, _0, "TE_Env_SleepFruit", "TE_Env_Attaching")
end

function _M._get_101_3(flow)
	local _0 = _C(97, "GetAoiEntityTableByLevel", flow, 0, 10, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(101, "__iterItem", v)

		if _M._get_98_3(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_101_2(flow)
	return flow:getCache(101, "__iterItem")
end

function _M._get_103_3(flow)
	local _3 = _M._get_101_3(flow)
	local _4 = not _3 or next(_3) == nil
	local _0 = not _4

	if not _0 then
		return false
	end

	local _5 = _M._get_104_1(flow)
	local _1 = _C(105, "CheckEntityExist", flow, _5)

	if not _1 then
		return false
	end

	local _6 = _C(154, "RandomInteger", flow, 0, 30)
	local _2 = _6 <= 2

	if not _2 then
		return false
	end

	return true
end

function _M._get_104_1(flow)
	local _0 = flow:getCache(104, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_93_2(flow)

	flow:setCache(104, "1", _0)

	return _0
end

function _M._get_109_1(flow)
	return _C(109, "CheckHasEntityTag", flow, 0, "TE_Wild_10501_Rage")
end

function _M._get_118_2(flow)
	local _0 = _M._get_124_2(flow)

	return _C(118, "HasEntityTag", flow, _0, "TE_Env_BlastTree")
end

function _M._get_122_3(flow)
	local _0 = flow:getCache(125, "__iterItem")

	return _C(122, "GetDistance", flow, _0, 0, false)
end

function _M._get_124_3(flow)
	local _0 = _C(121, "GetAoiEntityTableByLevel", flow, 0, 10, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(124, "__iterItem", v)

		if _M._get_118_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_124_2(flow)
	return flow:getCache(124, "__iterItem")
end

function _M._get_125_2(flow)
	local _0 = _M._get_124_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(125, "__iterItem", v)

		_1 = _M._get_122_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_126_1(flow)
	local _0 = flow:getCache(126, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_125_2(flow)

	flow:setCache(126, "1", _0)

	return _0
end

function _M._get_128_3(flow)
	local _6 = _C(147, "RandomInteger", flow, 0, 30)
	local _0 = _6 <= 5

	if not _0 then
		return false
	end

	local _4 = _M._get_124_3(flow)
	local _3 = not _4 or next(_4) == nil
	local _1 = not _3

	if not _1 then
		return false
	end

	local _5 = _M._get_126_1(flow)
	local _2 = _C(127, "CheckEntityExist", flow, _5)

	if not _2 then
		return false
	end

	return true
end

function _M._get_135_3(flow)
	local _0 = flow:getCache(137, "__iterItem")

	return _C(135, "GetDistance", flow, _0, 0, false)
end

function _M._get_136_3(flow)
	local _0 = _C(134, "GetAoiEntityTableByLevel", flow, 0, 10, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(136, "__iterItem", v)

		if _M._get_139_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_136_2(flow)
	return flow:getCache(136, "__iterItem")
end

function _M._get_137_2(flow)
	local _0 = _M._get_136_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(137, "__iterItem", v)

		_1 = _M._get_135_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_139_2(flow)
	local _0 = _M._get_136_2(flow)

	return _C(139, "HasEntityTag", flow, _0, "TE_Env_BlastTree")
end

function _M._get_140_1(flow)
	local _0 = flow:getCache(140, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_137_2(flow)

	flow:setCache(140, "1", _0)

	return _0
end

function _M._get_143_3(flow)
	local _3 = _M._get_136_3(flow)
	local _4 = not _3 or next(_3) == nil
	local _0 = not _4

	if not _0 then
		return false
	end

	local _5 = _M._get_140_1(flow)
	local _1 = _C(142, "CheckEntityExist", flow, _5)

	if not _1 then
		return false
	end

	local _6 = _C(150, "RandomInteger", flow, 0, 30)
	local _2 = _6 <= 5

	if not _2 then
		return false
	end

	return true
end

function _M._get_158_2(flow)
	local _2 = _C(156, "RandomInteger", flow, 0, 30)
	local _0 = _2 <= 2

	if not _0 then
		return false
	end

	local _1 = _M._get_103_3(flow)

	if not _1 then
		return false
	end

	return true
end

function _M._get_163_2(flow)
	local _0 = _M._get_166_2(flow)

	if not _0 then
		return false
	end

	local _2 = _C(164, "RandomInteger", flow, 0, 10)
	local _1 = _2 <= 8

	if not _1 then
		return false
	end

	return true
end

function _M._get_166_2(flow)
	local _2 = _C(162, "GetAoiEntityTableByLevel", flow, 0, 10, 2)
	local _3 = not _2 or next(_2) == nil
	local _0 = not _3

	if _0 then
		return true
	end

	local _4 = _C(168, "GetAoiEntityTableByLevel", flow, 0, 10, 4)
	local _5 = not _4 or next(_4) == nil
	local _1 = not _5

	if _1 then
		return true
	end

	return false
end

return _M
