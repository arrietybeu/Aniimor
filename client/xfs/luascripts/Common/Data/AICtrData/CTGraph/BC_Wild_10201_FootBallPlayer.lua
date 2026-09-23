-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_FootBallPlayer.lua

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
	return _M._to_19_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 20 then
		return true
	end

	if nodeId == 50 then
		return _M._to_51_0(flow)
	end

	if nodeId == 51 then
		return _M._to_63_0(flow)
	end

	if nodeId == 54 then
		return _M._to_55_0(flow)
	end

	if nodeId == 55 then
		return _M._to_65_0(flow)
	end

	if nodeId == 63 then
		return _M._to_52_0(flow)
	end

	if nodeId == 65 then
		return _M._to_56_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_19_0(flow)
	local _0 = _M._get_18_2(flow)

	if _0 then
		return _M._to_48_0(flow)
	end

	local _2 = _M._get_18_2(flow)
	local _1 = not _2

	if _1 then
		return _M._to_20_0(flow)
	end
end

function _M._to_20_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_15_2(flow)

	return _doBehaviourTail_0(flow, 20, _0, 15, 10, true, 7, 2, 0, 1, false, false)
end

function _M._to_26_0(flow)
	local _0 = _M._get_27_2(flow)

	if _0 then
		flow:setActive()
		_A(flow, "AddAITag", 0, "Attack01")

		return true
	end

	local _1 = _M._get_28_2(flow)

	if _1 then
		return _M._to_50_0(flow)
	end

	local _2 = _M._get_29_2(flow)

	if _2 then
		return _M._to_54_0(flow)
	end

	local _3 = _M._get_30_2(flow)

	if _3 then
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "Attack02")

		return true
	end
end

function _M._to_48_0(flow)
	local _0 = _M._get_47_1(flow)

	if _0 then
		return _M._to_26_0(flow)
	end
end

function _M._to_50_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_44_2(flow)

	return _doBehaviourTail_0(flow, 50, _0, 1.5, 10, true, 7, 2, 0, 1, false, false)
end

function _M._to_51_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_47_1(flow)

	if _0 then
		flow:setActive()
		_C(51, "DoBehaviour", flow, "PBT_CastSkill")

		local _1 = _M._get_44_2(flow)

		return _doBehaviourTail_1(flow, 51, 0, 12010110, _1, "", 0, false, 0)
	else
		flow:setActiveFail()
	end
end

function _M._to_52_0(flow)
	flow:setActive()
	_A(flow, "AddAITag", 0, "Attack01")
	flow:setActive()
	_A(flow, "RemoveAITag", 0, "Attack02")

	return true
end

function _M._to_54_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_44_2(flow)

	return _doBehaviourTail_0(flow, 54, _0, 1.5, 10, true, 7, 2, 0, 1, false, false)
end

function _M._to_55_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_47_1(flow)

	if _0 then
		flow:setActive()
		_C(55, "DoBehaviour", flow, "PBT_CastSkill")

		local _1 = _M._get_44_2(flow)

		return _doBehaviourTail_1(flow, 55, 0, 12010110, _1, "", 0, false, 0)
	else
		flow:setActiveFail()
	end
end

function _M._to_56_0(flow)
	flow:setActive()
	_A(flow, "AddAITag", 0, "Attack02")
	flow:setActive()
	_A(flow, "RemoveAITag", 0, "Attack01")

	return true
end

function _M._to_63_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	local _0 = _C(64, "RandomInteger", flow, 1, 3)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", _0)
	flow:setContinue(63)

	return true
end

function _M._to_65_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	local _0 = _C(66, "RandomInteger", flow, 1, 3)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", _0)
	flow:setContinue(65)

	return true
end

function _M._get_4_2(flow)
	local _1 = _M._get_9_2(flow)
	local _0 = _C(3, "HasEntityTag", flow, _1, "TE_Env_UniversalMark_A")

	if not _0 then
		return false
	end

	if false then
		return false
	end

	return true
end

function _M._get_9_3(flow)
	local _0 = _C(5, "GetAoiEntityTableByLevel", flow, 0, 50, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(9, "__iterItem", v)

		if _M._get_4_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_9_2(flow)
	return flow:getCache(9, "__iterItem")
end

function _M._get_11_2(flow)
	return _C(11, "HasAITag", flow, 0, "Attack01")
end

function _M._get_12_2(flow)
	return _C(12, "HasAITag", flow, 0, "Attack02")
end

function _M._get_15_2(flow)
	local _0 = _M._get_9_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(15, "__iterItem", v)

		_1 = _M._get_16_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_16_3(flow)
	local _0 = flow:getCache(15, "__iterItem")

	return _C(16, "GetDistance", flow, _0, 0, false)
end

function _M._get_18_2(flow)
	local _1 = _M._get_15_2(flow)
	local _0 = _C(17, "GetDistance", flow, _1, 0, false)

	return _0 < 30
end

function _M._get_24_1(flow)
	local _0 = _M._get_11_2(flow)

	return not _0
end

function _M._get_25_1(flow)
	local _0 = _M._get_12_2(flow)

	return not _0
end

function _M._get_27_2(flow)
	local _0 = _M._get_24_1(flow)

	if not _0 then
		return false
	end

	local _1 = _M._get_25_1(flow)

	if not _1 then
		return false
	end

	return true
end

function _M._get_28_2(flow)
	local _0 = _M._get_11_2(flow)

	if not _0 then
		return false
	end

	local _1 = _M._get_25_1(flow)

	if not _1 then
		return false
	end

	return true
end

function _M._get_29_2(flow)
	local _0 = _M._get_24_1(flow)

	if not _0 then
		return false
	end

	local _1 = _M._get_12_2(flow)

	if not _1 then
		return false
	end

	return true
end

function _M._get_30_2(flow)
	local _0 = _M._get_11_2(flow)

	if not _0 then
		return false
	end

	local _1 = _M._get_12_2(flow)

	if not _1 then
		return false
	end

	return true
end

function _M._get_38_2(flow)
	return flow:getCache(38, "__iterItem")
end

function _M._get_38_3(flow)
	local _0 = _C(36, "GetAoiEntityTableByLevel", flow, 0, 50, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(38, "__iterItem", v)

		if _M._get_58_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_44_2(flow)
	local _0 = _M._get_38_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(44, "__iterItem", v)

		_1 = _M._get_45_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_45_3(flow)
	local _0 = flow:getCache(44, "__iterItem")

	return _C(45, "GetDistance", flow, _0, 0, false)
end

function _M._get_47_1(flow)
	local _1 = _M._get_38_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_58_2(flow)
	local _2 = _M._get_38_2(flow)
	local _0 = _C(34, "HasEntityTag", flow, _2, "TE_Env_Ball")

	if not _0 then
		return false
	end

	local _3 = _M._get_38_2(flow)
	local _4 = _C(59, "GetDistance", flow, _3, 0, false)
	local _1 = _4 < 10

	if not _1 then
		return false
	end

	return true
end

return _M
