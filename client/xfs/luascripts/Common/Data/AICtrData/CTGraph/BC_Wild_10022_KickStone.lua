-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10022_KickStone.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_41_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 29 then
		return _M._to_32_0(flow)
	end

	if nodeId == 32 then
		return true
	end

	if nodeId == 41 then
		return _M._to_42_0(flow)
	end

	if nodeId == 42 then
		return _M._to_29_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_29_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_27_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tStopDist", 0.2)
	flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 10)
	flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
	flow:setContinue(29)

	return true
end

function _M._to_32_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_27_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tSkillId", 10220300)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(32)

	return true
end

function _M._to_41_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_40_1(flow)

	if _0 then
		flow:setActive()
		_C(41, "DoBehaviour", flow, "PBT_ShowEmojiBubble")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 2.5)
		flow:setContinue(41)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_42_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 1)
	flow:setContinue(42)

	return true
end

function _M._get_22_2(flow)
	local _2 = _M._get_37_2(flow)
	local _0 = _C(19, "HasEntityTag", flow, _2, "TE_Env_10023_KickStone")

	if not _0 then
		return false
	end

	local _3 = _M._get_37_2(flow)
	local _4 = _C(20, "GetDistance", flow, _3, 0, false)
	local _1 = _4 <= 10

	if not _1 then
		return false
	end

	return true
end

function _M._get_25_1(flow)
	local _0 = _M._get_37_3(flow)

	return _C(25, "SelectOneByRandom", flow, _0)
end

function _M._get_27_1(flow)
	local _0 = flow:getCache(27, "Stone")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_25_1(flow)

	flow:setCache(27, "Stone", _0)

	return _0
end

function _M._get_37_2(flow)
	return flow:getCache(37, "__iterItem")
end

function _M._get_37_3(flow)
	local _0 = _C(16, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(37, "__iterItem", v)

		if _M._get_22_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_40_1(flow)
	local _1 = _M._get_37_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

return _M
