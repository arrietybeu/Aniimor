-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10351_PER_CatchHoney.lua

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

local function _doBehaviourTail_2(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tCharacterState", value0)
	agent:addSubTreeLocalParam("tAnimationKey", value1)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_43_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_112_1(flow)

	_A(flow, "RemoveEntityTag", _0, "TE_Env_BeUsed")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 11 then
		return _M._to_63_0(flow)
	end

	if nodeId == 37 then
		return _M._to_100_0(flow)
	end

	if nodeId == 38 then
		return _M._to_91_0(flow)
	end

	if nodeId == 39 then
		return _M._to_118_0(flow)
	end

	if nodeId == 69 then
		return _M._to_46_0(flow)
	end

	if nodeId == 91 then
		return _M._to_102_0(flow)
	end

	if nodeId == 96 then
		return _M._to_37_0(flow)
	end

	if nodeId == 100 then
		return _M._to_38_0(flow)
	end

	if nodeId == 102 then
		return _M._to_69_0(flow)
	end

	if nodeId == 116 then
		return _M._to_39_0(flow)
	end

	if nodeId == 118 then
		return _M._to_113_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_11_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_115_1(flow)

	if _0 then
		flow:setActive()
		_C(11, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_112_1(flow)

		return _doBehaviourTail_0(flow, 11, _1, 0.6, 6, true, 5, 99999, 0, 2, false, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_37_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_33_1(flow)

	if _0 then
		flow:setActive()
		_C(37, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_95_1(flow)

		return _doBehaviourTail_0(flow, 37, _1, 0.2, -1, true, 4, 99999, 0, 2, false, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_38_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_95_1(flow)

	return _doBehaviourTail_1(flow, 38, 0, 10001190, _0, "Eat", 0, false, 0)
end

function _M._to_39_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_1(flow, 39, 0, 10001180, 0, "", 1, false, 0)
end

function _M._to_43_0(flow)
	local _0 = _M._get_110_2(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_112_1(flow)

		_A(flow, "AddEntityTag", _1, "TE_Env_BeUsed")

		return _M._to_11_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._to_46_0(flow)
	flow:setActive()
	_A(flow, "RemoveEntityTag", 0, "TE_Env_BeUsed")

	return true
end

function _M._to_63_0(flow)
	flow:setActive()
	_A(flow, "SetVisionAreaOverride", "visionAreaLow")

	return _M._to_116_0(flow)
end

function _M._to_69_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_55_1(flow)

	if _0 then
		flow:setActive()
		_C(69, "DoBehaviour", flow, "PBT_MoveAroundTarget")

		local _1 = _M._get_94_1(flow)
		local _2 = _C(103, "RandomInteger", flow, 5, 10)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tRadius", _2)
		flow.__agent:addSubTreeLocalParam("tSpeed", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
		flow.__agent:addSubTreeLocalParam("tClockwise", false)
		flow.__agent:addSubTreeLocalParam("tTimeout", 5)
		flow:setContinue(69)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_91_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	local _0 = _C(92, "RandomInteger", flow, 0, 3)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", _0)
	flow:setContinue(91)

	return true
end

function _M._to_100_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	return _doBehaviourTail_2(flow, 100, "GROUND", "")
end

function _M._to_102_0(flow)
	if not _B(flow, "PBT_SwitchToFly") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tFlyHeight", 0)
	flow.__agent:addSubTreeLocalParam("tMaxTime", -1)
	flow:setContinue(102)

	return true
end

function _M._to_113_0(flow)
	flow:setActive()
	_A(flow, "AddEntityTag", 0, "TE_Wild_DewyHasHoney")
	flow:setActive()
	_A(flow, "SetVisionAreaOverride", "visionAreaDefault")

	return true
end

function _M._to_116_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	return _doBehaviourTail_2(flow, 116, "GROUND", "")
end

function _M._to_118_0(flow)
	if not _B(flow, "PBT_SwitchToFly") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tFlyHeight", 0)
	flow.__agent:addSubTreeLocalParam("tMaxTime", -1)
	flow:setContinue(118)

	return true
end

function _M._get_31_3(flow)
	local _0 = _C(29, "GetAoiEntityTableByLevel", flow, 0, 50, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(31, "__iterItem", v)

		if _M._get_36_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_31_2(flow)
	return flow:getCache(31, "__iterItem")
end

function _M._get_33_1(flow)
	local _1 = _M._get_31_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_34_2(flow)
	local _0 = _M._get_31_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(34, "__iterItem", v)

		_1 = _M._get_35_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_35_3(flow)
	local _0 = flow:getCache(34, "__iterItem")

	return _C(35, "GetDistance", flow, _0, 0, false)
end

function _M._get_36_2(flow)
	local _0 = _M._get_31_2(flow)

	return _C(36, "HasEntityTag", flow, _0, "TE_Wild_DewyNestPlatform")
end

function _M._get_53_3(flow)
	local _0 = _C(51, "GetAoiEntityTableByLevel", flow, 0, 50, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(53, "__iterItem", v)

		if _M._get_58_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_53_2(flow)
	return flow:getCache(53, "__iterItem")
end

function _M._get_55_1(flow)
	local _1 = _M._get_53_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_56_2(flow)
	local _0 = _M._get_53_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(56, "__iterItem", v)

		_1 = _M._get_57_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_57_3(flow)
	local _0 = flow:getCache(56, "__iterItem")

	return _C(57, "GetDistance", flow, _0, 0, false)
end

function _M._get_58_2(flow)
	local _0 = _M._get_53_2(flow)

	return _C(58, "HasEntityTag", flow, _0, "TE_Wild_DewyNest")
end

function _M._get_77_3(flow)
	local _0 = _C(83, "GetAoiEntityTableByLevel", flow, 0, 50, 64)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(77, "__iterItem", v)

		if _M._get_79_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_77_2(flow)
	return flow:getCache(77, "__iterItem")
end

function _M._get_79_2(flow)
	local _4 = _M._get_77_2(flow)
	local _0 = _C(84, "HasEntityTag", flow, _4, "TE_Chest_SpiceFlower")

	if not _0 then
		return false
	end

	local _2 = _M._get_77_2(flow)
	local _3 = _C(78, "HasEntityTag", flow, _2, "TE_Env_BeUsed")
	local _1 = not _3

	if not _1 then
		return false
	end

	return true
end

function _M._get_82_3(flow)
	local _0 = flow:getCache(87, "__iterItem")

	return _C(82, "GetDistance", flow, _0, 0, false)
end

function _M._get_87_2(flow)
	local _0 = _M._get_77_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(87, "__iterItem", v)

		_1 = _M._get_82_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_94_1(flow)
	local _0 = flow:getCache(94, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_56_2(flow)

	flow:setCache(94, "1", _0)

	return _0
end

function _M._get_95_1(flow)
	local _0 = flow:getCache(95, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_34_2(flow)

	flow:setCache(95, "1", _0)

	return _0
end

function _M._get_110_2(flow)
	local _4 = _C(109, "HasEntityTag", flow, 0, "TE_Wild_DewyHasHoney")
	local _0 = not _4

	if not _0 then
		return false
	end

	local _2 = _M._get_77_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _1 = not _3

	if not _1 then
		return false
	end

	return true
end

function _M._get_112_1(flow)
	local _0 = flow:getCache(112, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_87_2(flow)

	flow:setCache(112, "1", _0)

	return _0
end

function _M._get_115_1(flow)
	local _0 = _M._get_112_1(flow)

	return _C(115, "CheckEntityExist", flow, _0)
end

return _M
