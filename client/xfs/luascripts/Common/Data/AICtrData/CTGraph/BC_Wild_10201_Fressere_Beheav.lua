-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_Fressere_Beheav.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
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

function _M.executeTickLodTrigger(flow)
	return _M._to_128_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 138 then
		return true
	end

	if nodeId == 139 then
		return true
	end

	if nodeId == 148 then
		return true
	end

	if nodeId == 149 then
		return true
	end

	if nodeId == 150 then
		return _M._to_163_0(flow)
	end

	if nodeId == 151 then
		return _M._to_139_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 138 then
		return _M._get_145_1(flow)
	end

	if nodeId == 139 then
		return _M._get_152_2(flow)
	end

	if nodeId == 148 then
		return _M._get_146_1(flow)
	end

	if nodeId == 149 then
		return _M._get_153_1(flow)
	end
end

function _M._to_128_0(flow)
	local _0 = _M._get_122_3(flow)

	if _0 then
		return _M._to_149_0(flow)
	end

	local _1 = _M._get_135_3(flow)

	if _1 then
		return _M._to_150_0(flow)
	end

	local _2 = _M._get_127_3(flow)

	if _2 then
		return _M._to_151_0(flow)
	end
end

function _M._to_139_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 139)

	if not _1 then
		flow:setActive()
		_C(139, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_123_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 0.4)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 15)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 7)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 2)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(139)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_148_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 148)

	if not _1 then
		flow:setActive()
		_C(148, "DoBehaviour", flow, "PBT_CustomAnimation")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0.5)
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "Behav_Cry")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 9999)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", true)
		flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
		flow:setContinue(148)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_149_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 149)

	if not _1 then
		flow:setActive()
		_C(149, "DoBehaviour", flow, "PBT_CastSkill")

		return _doBehaviourTail_0(flow, 149, 0, 12010300, 0, "", 0, false, 0)
	else
		flow:setActiveFail()
	end
end

function _M._to_150_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_0(flow, 150, 0, 12010301, 0, "", 0, false, 0)
end

function _M._to_151_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_0(flow, 151, 0, 12010301, 0, "", 5, false, 0)
end

function _M._to_163_0(flow)
	flow:setActive()
	_A(flow, "TriggerBluePrint", "PlayDia")

	return _M._to_148_0(flow)
end

function _M._get_111_2(flow)
	return _C(111, "HasAITag", flow, 0, "Find")
end

function _M._get_112_2(flow)
	local _0 = _M._get_117_2(flow)

	return _C(112, "HasEntityTag", flow, _0, "TE_Chest_BacillusMycoidesRuber")
end

function _M._get_116_2(flow)
	return _C(116, "HasAITag", flow, 0, "Eat")
end

function _M._get_117_2(flow)
	return flow:getCache(117, "__iterItem")
end

function _M._get_117_3(flow)
	local _0 = _C(119, "GetAoiEntityTableByLevel", flow, 0, 30, 64)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(117, "__iterItem", v)

		if _M._get_112_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_120_1(flow)
	local _0 = _M._get_116_2(flow)

	return not _0
end

function _M._get_121_1(flow)
	local _0 = _M._get_111_2(flow)

	return not _0
end

function _M._get_122_3(flow)
	local _0 = _M._get_116_2(flow)

	if not _0 then
		return false
	end

	local _1 = _M._get_134_1(flow)

	if not _1 then
		return false
	end

	local _2 = _M._get_121_1(flow)

	if not _2 then
		return false
	end

	return true
end

function _M._get_123_2(flow)
	local _0 = _M._get_117_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(123, "__iterItem", v)

		_1 = _M._get_124_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_124_3(flow)
	local _0 = flow:getCache(123, "__iterItem")

	return _C(124, "GetDistance", flow, _0, 0, false)
end

function _M._get_127_3(flow)
	local _0 = _M._get_120_1(flow)

	if not _0 then
		return false
	end

	local _1 = _M._get_134_1(flow)

	if not _1 then
		return false
	end

	local _2 = _M._get_111_2(flow)

	if not _2 then
		return false
	end

	return true
end

function _M._get_133_2(flow)
	return _C(133, "HasAITag", flow, 0, "Cry")
end

function _M._get_134_1(flow)
	local _0 = _M._get_133_2(flow)

	return not _0
end

function _M._get_135_3(flow)
	local _0 = _M._get_120_1(flow)

	if not _0 then
		return false
	end

	local _1 = _M._get_133_2(flow)

	if not _1 then
		return false
	end

	local _2 = _M._get_121_1(flow)

	if not _2 then
		return false
	end

	return true
end

function _M._get_145_1(flow)
	local _0 = _C(142, "HasAITag", flow, 0, "Eat")

	return not _0
end

function _M._get_146_1(flow)
	local _0 = _C(147, "HasAITag", flow, 0, "Cry")

	return not _0
end

function _M._get_152_2(flow)
	local _0 = _M._get_122_3(flow)

	if _0 then
		return true
	end

	local _1 = _M._get_135_3(flow)

	if _1 then
		return true
	end

	return false
end

function _M._get_153_1(flow)
	local _0 = _C(154, "HasAITag", flow, 0, "Eat")

	return not _0
end

function _M._get_158_2(flow)
	return _C(158, "HasAITag", flow, 0, "Find")
end

function _M._get_160_2(flow)
	return _C(160, "HasAITag", flow, 0, "Find")
end

return _M
