-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_kickglowingfruit.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerMove" then
		return _M._to_57_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 31 then
		return _M._to_63_0(flow)
	end

	if nodeId == 54 then
		return _M._to_31_0(flow)
	end

	if nodeId == 57 then
		return _M._to_54_0(flow)
	end

	if nodeId == 63 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_31_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_7_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tSkillId", 12010002)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(31)

	return true
end

function _M._to_54_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_7_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tStopDist", 2)
	flow.__agent:addSubTreeLocalParam("tMaxTimeout", 10)
	flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 2)
	flow.__agent:addSubTreeLocalParam("tPathFindType", 3)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
	flow:setContinue(54)

	return true
end

function _M._to_57_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	local _0 = "LOCOMOTION"

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", _0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(57)

	return true
end

function _M._to_63_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 57257650, 1, nil) then
		flow:setContinue(63)

		return true
	end
end

function _M._get_1_2(flow)
	local _0 = _C(0, "GetAoiEntityTableByLevel", flow, 0, 30, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(1, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_5_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_1_3(flow)
	return flow:getCache(1, "__iterItem")
end

function _M._get_5_2(flow)
	local _2 = _M._get_1_3(flow)
	local _0 = _C(2, "HasEntityTag", flow, _2, "TE_Env_Empty")

	if not _0 then
		return false
	end

	local _3 = _M._get_1_3(flow)
	local _4 = _C(3, "GetDistance", flow, _3, 0, false)
	local _1 = _4 <= 20

	if not _1 then
		return false
	end

	return true
end

function _M._get_6_1(flow)
	local _0 = _M._get_1_2(flow)

	return _C(6, "SelectOneByRandom", flow, _0)
end

function _M._get_7_1(flow)
	local _0 = flow:getCache(7, "Shrub")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_6_1(flow)

	flow:setCache(7, "Shrub", _0)

	return _0
end

function _M._get_13_1(flow)
	local _0 = _M._get_1_2(flow)

	return not _0 or next(_0) == nil
end

return _M
