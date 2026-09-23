-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_1023102_ChaseLight.lua

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

local function _doBehaviourTail_1(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value0)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value1)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_2(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8, value9)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value1)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value2)
	agent:addSubTreeLocalParam("tAnimationStartKey", value3)
	agent:addSubTreeLocalParam("tAnimationLoopKey", value4)
	agent:addSubTreeLocalParam("tAnimationEndKey", value5)
	agent:addSubTreeLocalParam("tAnimationTimeout", value6)
	agent:addSubTreeLocalParam("tTimelineTag", value7)
	agent:addSubTreeLocalParam("tNeedLoop", value8)
	agent:addSubTreeLocalParam("tAnimationPlayOnce", value9)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_3(flow, nodeId, value0, value1, value2, value3, value4, value5, value6)
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
	return _M._to_23_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "SetVisionAreaOverride", "visionAreaDefault")
	flow:setActive()

	local _0 = _C(209, "GetSelfId", flow)

	_A(flow, "PlayEmojiOnTarget", _0, "Think", 5)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 70 then
		return _M._to_115_0(flow)
	end

	if nodeId == 71 then
		return _M._to_91_0(flow)
	end

	if nodeId == 72 then
		return true
	end

	if nodeId == 91 then
		return _M._to_110_0(flow)
	end

	if nodeId == 96 then
		return true
	end

	if nodeId == 97 then
		return _M._to_114_0(flow)
	end

	if nodeId == 98 then
		return _M._to_99_0(flow)
	end

	if nodeId == 99 then
		return _M._to_109_0(flow)
	end

	if nodeId == 114 then
		return _M._to_96_0(flow)
	end

	if nodeId == 115 then
		return _M._to_72_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 70 then
		return _M._get_73_1(flow)
	end

	if nodeId == 71 then
		return _M._get_73_1(flow)
	end

	if nodeId == 72 then
		return _M._get_73_1(flow)
	end

	if nodeId == 96 then
		return _M._get_68_1(flow)
	end

	if nodeId == 97 then
		return _M._get_68_1(flow)
	end

	if nodeId == 98 then
		return _M._get_68_1(flow)
	end

	if nodeId == 99 then
		return _M._get_68_1(flow)
	end
end

function _M._to_23_0(flow)
	local _2 = _M._get_31_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _0 = not _3

	if _0 then
		return _M._to_98_0(flow)
	end

	local _4 = _M._get_39_3(flow)
	local _5 = not _4 or next(_4) == nil
	local _1 = not _5

	if _1 then
		return _M._to_71_0(flow)
	end
end

function _M._to_70_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 70)

	if not _1 then
		flow:setActive()
		_C(70, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_57_1(flow)

		return _doBehaviourTail_0(flow, 70, _1, 1, 5, true, 0, 0, 0, 2, false, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_71_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 71)

	if not _1 then
		flow:setActive()
		_C(71, "DoBehaviour", flow, "PBT_ShowEmojiBubble")

		return _doBehaviourTail_1(flow, 71, "Surprise", 1)
	else
		flow:setActiveFail()
	end
end

function _M._to_72_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 72)

	if not _1 then
		flow:setActive()
		_C(72, "DoBehaviour", flow, "PBT_CustomLoopAnimation")

		return _doBehaviourTail_2(flow, 72, 0, "Love", 5, "Behav_HappyStart", "Behav_HappyLoop", "Behav_HappyEnd", 10, "", true, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_91_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_1(flow, 91, "Love", 10)
end

function _M._to_96_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 96)

	if not _1 then
		flow:setActive()
		_C(96, "DoBehaviour", flow, "PBT_CustomLoopAnimation")

		return _doBehaviourTail_2(flow, 96, 0, "Love", 5, "Behav_HappyStart", "Behav_HappyLoop", "Behav_HappyEnd", 10, "", true, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_97_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 97)

	if not _1 then
		flow:setActive()
		_C(97, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_55_1(flow)

		return _doBehaviourTail_0(flow, 97, _1, 1, 5, true, 0, 0, 0, 2, false, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_98_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 98)

	if not _1 then
		flow:setActive()
		_C(98, "DoBehaviour", flow, "PBT_ShowEmojiBubble")

		return _doBehaviourTail_1(flow, 98, "Surprise", 1)
	else
		flow:setActiveFail()
	end
end

function _M._to_99_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 99)

	if not _1 then
		flow:setActive()
		_C(99, "DoBehaviour", flow, "PBT_ShowEmojiBubble")

		return _doBehaviourTail_1(flow, 99, "Love", 10)
	else
		flow:setActiveFail()
	end
end

function _M._to_109_0(flow)
	flow:setActive()
	_A(flow, "SetVisionAreaOverride", "visionAreaMid")

	return _M._to_97_0(flow)
end

function _M._to_110_0(flow)
	flow:setActive()
	_A(flow, "SetVisionAreaOverride", "visionAreaMid")

	return _M._to_70_0(flow)
end

function _M._to_114_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_3(flow, 114, 0, 10600151, 0, "", 5, false, 0)
end

function _M._to_115_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_3(flow, 115, 0, 10600151, 0, "", 5, false, 0)
end

function _M._get_31_2(flow)
	return flow:getCache(31, "__iterItem")
end

function _M._get_31_3(flow)
	local _0 = _C(35, "GetAoiEntityTableByLevel", flow, 0, 30, 16)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(31, "__iterItem", v)

		if _M._get_32_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_32_2(flow)
	local _0 = _M._get_31_2(flow)

	return _C(32, "HasEntityTag", flow, _0, "TE_Cre_Light")
end

function _M._get_34_3(flow)
	local _0 = flow:getCache(38, "__iterItem")

	return _C(34, "GetDistance", flow, _0, 0, false)
end

function _M._get_38_2(flow)
	local _0 = _M._get_31_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(38, "__iterItem", v)

		_1 = _M._get_34_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_39_2(flow)
	return flow:getCache(39, "__iterItem")
end

function _M._get_39_3(flow)
	local _0 = _C(43, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(39, "__iterItem", v)

		if _M._get_40_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_40_2(flow)
	local _0 = _M._get_39_2(flow)

	return _C(40, "HasEntityTag", flow, _0, "TE_Env_Light")
end

function _M._get_42_3(flow)
	local _0 = flow:getCache(46, "__iterItem")

	return _C(42, "GetDistance", flow, _0, 0, false)
end

function _M._get_46_2(flow)
	local _0 = _M._get_39_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(46, "__iterItem", v)

		_1 = _M._get_42_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_55_1(flow)
	local _0 = flow:getCache(55, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_38_2(flow)

	flow:setCache(55, "1", _0)

	return _0
end

function _M._get_57_1(flow)
	local _0 = flow:getCache(57, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_46_2(flow)

	flow:setCache(57, "1", _0)

	return _0
end

function _M._get_68_1(flow)
	local _0 = _M._get_106_2(flow)

	return not _0
end

function _M._get_73_1(flow)
	local _0 = _M._get_105_2(flow)

	return not _0
end

function _M._get_105_2(flow)
	local _3 = _M._get_57_1(flow)
	local _0 = _C(76, "CheckEntityExist", flow, _3)

	if not _0 then
		return false
	end

	local _2 = _M._get_57_1(flow)
	local _1 = _C(74, "HasEntityTag", flow, _2, "TE_Env_Light")

	if not _1 then
		return false
	end

	return true
end

function _M._get_106_2(flow)
	local _3 = _M._get_55_1(flow)
	local _0 = _C(69, "CheckEntityExist", flow, _3)

	if not _0 then
		return false
	end

	local _2 = _M._get_55_1(flow)
	local _1 = _C(66, "HasEntityTag", flow, _2, "TE_Cre_Light")

	if not _1 then
		return false
	end

	return true
end

return _M
