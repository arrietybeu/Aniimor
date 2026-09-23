-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10351_ReturnHoneytoNest.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6)
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

local function _doBehaviourTail_1(flow, nodeId, value0, value1, value2, value3, value4, value5)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tTargetActorId", value0)
	agent:addSubTreeLocalParam("tRadius", value1)
	agent:addSubTreeLocalParam("tSpeed", value2)
	agent:addSubTreeLocalParam("tSpeedRateType", value3)
	agent:addSubTreeLocalParam("tClockwise", value4)
	agent:addSubTreeLocalParam("tTimeout", value5)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_2(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tFlyHeight", value0)
	agent:addSubTreeLocalParam("tMaxTime", value1)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_3(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tCharacterState", value0)
	agent:addSubTreeLocalParam("tAnimationKey", value1)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_126_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 37 then
		return _M._to_124_0(flow)
	end

	if nodeId == 38 then
		return _M._to_122_0(flow)
	end

	if nodeId == 69 then
		return _M._to_178_0(flow)
	end

	if nodeId == 102 then
		return _M._to_69_0(flow)
	end

	if nodeId == 116 then
		return true
	end

	if nodeId == 118 then
		return _M._to_119_0(flow)
	end

	if nodeId == 119 then
		return _M._to_116_0(flow)
	end

	if nodeId == 124 then
		return _M._to_38_0(flow)
	end

	if nodeId == 140 then
		return _M._to_192_0(flow)
	end

	if nodeId == 169 then
		return true
	end

	if nodeId == 171 then
		return _M._to_172_0(flow)
	end

	if nodeId == 172 then
		return _M._to_169_0(flow)
	end

	if nodeId == 174 then
		return _M._to_150_0(flow)
	end

	if nodeId == 176 then
		return _M._to_174_0(flow)
	end

	if nodeId == 177 then
		return _M._to_125_0(flow)
	end

	if nodeId == 193 then
		return _M._to_37_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
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

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 0.5)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", -1)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 4)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(37)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_38_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_95_1(flow)

	return _doBehaviourTail_0(flow, 38, 0, 10001190, _0, "", 0, false, 0)
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

		return _doBehaviourTail_1(flow, 69, _1, _2, 0, 2, false, 5)
	else
		flow:setActiveFail()
	end
end

function _M._to_102_0(flow)
	if not _B(flow, "PBT_SwitchToFly") then
		return
	end

	return _doBehaviourTail_2(flow, 102, 0, -1)
end

function _M._to_116_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_55_1(flow)

	if _0 then
		flow:setActive()
		_C(116, "DoBehaviour", flow, "PBT_MoveAroundTarget")

		local _1 = _M._get_94_1(flow)
		local _2 = _C(120, "RandomInteger", flow, 5, 10)

		return _doBehaviourTail_1(flow, 116, _1, _2, 0, 2, false, 5)
	else
		flow:setActiveFail()
	end
end

function _M._to_118_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	local _0 = _C(117, "RandomInteger", flow, 0, 3)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", _0)
	flow:setContinue(118)

	return true
end

function _M._to_119_0(flow)
	if not _B(flow, "PBT_SwitchToFly") then
		return
	end

	return _doBehaviourTail_2(flow, 119, 0, -1)
end

function _M._to_122_0(flow)
	flow:setActive()
	_A(flow, "RemoveEntityTag", 0, "TE_Wild_DewyHasHoney")

	return _M._to_118_0(flow)
end

function _M._to_124_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	return _doBehaviourTail_3(flow, 124, "GROUND", "")
end

function _M._to_125_0(flow)
	flow:setActive()

	local _0 = _M._get_94_1(flow)

	_A(flow, "RemoveEntityTag", _0, "TE_Env_BeUsed")

	return _M._to_102_0(flow)
end

function _M._to_126_0(flow)
	local _0 = _M._get_157_2(flow)

	if _0 then
		return _M._to_193_0(flow)
	end

	local _1 = _M._get_161_2(flow)

	if _1 then
		return _M._to_140_0(flow)
	end

	local _2 = _M._get_165_2(flow)

	if _2 then
		return _M._to_177_0(flow)
	end
end

function _M._to_140_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_180_1(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_188_1(flow)

		if _P(flow, 1, _1, 1, nil) then
			flow:setContinue(140)

			return true
		end
	else
		flow:setActiveFail()
	end
end

function _M._to_150_0(flow)
	flow:setActive()
	_A(flow, "RemoveEntityTag", 0, "TE_Wild_DewyInNest")

	return _M._to_171_0(flow)
end

function _M._to_169_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_55_1(flow)

	if _0 then
		flow:setActive()
		_C(169, "DoBehaviour", flow, "PBT_MoveAroundTarget")

		local _1 = _M._get_94_1(flow)
		local _2 = _C(173, "RandomInteger", flow, 5, 10)

		return _doBehaviourTail_1(flow, 169, _1, _2, 0, 2, false, 5)
	else
		flow:setActiveFail()
	end
end

function _M._to_171_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	local _0 = _C(170, "RandomInteger", flow, 0, 3)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", _0)
	flow:setContinue(171)

	return true
end

function _M._to_172_0(flow)
	if not _B(flow, "PBT_SwitchToFly") then
		return
	end

	return _doBehaviourTail_2(flow, 172, 0, -1)
end

function _M._to_174_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_95_1(flow)

	return _doBehaviourTail_0(flow, 174, 0, 10001190, _0, "", 0, false, 0)
end

function _M._to_176_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	return _doBehaviourTail_3(flow, 176, "GROUND", "")
end

function _M._to_177_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_180_1(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_188_1(flow)

		if _P(flow, 1, _1, 1, nil) then
			flow:setContinue(177)

			return true
		end
	else
		flow:setActiveFail()
	end
end

function _M._to_178_0(flow)
	flow:setActive()
	_A(flow, "RemoveEntityTag", 0, "TE_Wild_DewyInNest")

	return true
end

function _M._to_192_0(flow)
	flow:setActive()

	local _0 = _M._get_94_1(flow)

	_A(flow, "RemoveEntityTag", _0, "TE_Env_BeUsed")

	return _M._to_176_0(flow)
end

function _M._to_193_0(flow)
	if not _B(flow, "PBT_SwitchToFly") then
		return
	end

	return _doBehaviourTail_2(flow, 193, 0, -1)
end

function _M._get_31_3(flow)
	local _0 = _C(29, "GetAoiEntityTableByLevel", flow, 0, 50, 256)
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

	return _C(36, "HasEntityTag", flow, _0, "TE_Env_DewyNestPlatform")
end

function _M._get_53_3(flow)
	local _0 = _C(51, "GetAoiEntityTableByLevel", flow, 0, 50, 256)
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

	return _C(58, "HasEntityTag", flow, _0, "TE_Env_DewyNest")
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

function _M._get_157_2(flow)
	local _0 = _C(156, "HasEntityTag", flow, 0, "TE_Wild_DewyHasHoney")

	if not _0 then
		return false
	end

	local _2 = _C(110, "HasEntityTag", flow, 0, "TE_Wild_DewyInNest")
	local _1 = not _2

	if not _1 then
		return false
	end

	return true
end

function _M._get_161_2(flow)
	local _0 = _C(159, "HasEntityTag", flow, 0, "TE_Wild_DewyHasHoney")

	if not _0 then
		return false
	end

	local _1 = _C(160, "HasEntityTag", flow, 0, "TE_Wild_DewyInNest")

	if not _1 then
		return false
	end

	return true
end

function _M._get_165_2(flow)
	local _2 = _C(162, "HasEntityTag", flow, 0, "TE_Wild_DewyHasHoney")
	local _0 = not _2

	if not _0 then
		return false
	end

	local _1 = _C(164, "HasEntityTag", flow, 0, "TE_Wild_DewyInNest")

	if not _1 then
		return false
	end

	return true
end

function _M._get_180_1(flow)
	local _1 = _M._get_182_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_182_3(flow)
	local _0 = _C(181, "GetAoiResPointPortTableByLevel", flow, 0, 30, 0, {
		"TR_NS_GenericTemplate2"
	}, nil)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(182, "__iterItem", v)

		_1[#_1 + 1] = v
	end

	return _1
end

function _M._get_184_2(flow)
	local _0 = _M._get_182_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(184, "__iterItem", v)

		_1 = _M._get_185_2(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_185_2(flow)
	local _0 = flow:getCache(184, "__iterItem")

	return _C(185, "GetDistanceFromEntityToResPointPort", flow, 0, _0)
end

function _M._get_186_1(flow)
	local _0 = flow:getCache(186, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_184_2(flow)

	flow:setCache(186, "1", _0)

	return _0
end

function _M._get_188_1(flow)
	local _1 = _M._get_186_1(flow)
	local _0 = _C(187, "UnpackResPointPort", flow, _1, 1)

	return _C(188, "GetRouteIdFromResPoint", flow, false, _0)
end

function _M._get_191_2(flow)
	local _0 = _M._get_94_1(flow)

	return _C(191, "HasEntityTag", flow, _0, "TE_Env_BeUsed")
end

return _M
