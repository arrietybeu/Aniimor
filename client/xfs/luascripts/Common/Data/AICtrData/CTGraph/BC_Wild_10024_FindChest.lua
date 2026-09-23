-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10024_FindChest.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
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
	return _M._to_56_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 29 then
		return _M._to_51_0(flow)
	end

	if nodeId == 32 then
		return true
	end

	if nodeId == 41 then
		return _M._to_29_0(flow)
	end

	if nodeId == 47 then
		return true
	end

	if nodeId == 51 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 29 then
		return _M._get_55_1(flow)
	end

	if nodeId == 51 then
		return _M._get_39_1(flow)
	end
end

function _M._to_29_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_53_2(flow)
	local _1 = _M.checkInterrupt(flow, 29)

	if _0 and not _1 then
		flow:setActive()
		_C(29, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _2 = _M._get_27_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _2)
		flow.__agent:addSubTreeLocalParam("tStopDist", 2)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 0)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 10)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", true)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(29)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_32_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_0(flow, 32, 0, 10240320, 0, "", 5, false, 0)
end

function _M._to_41_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 2.5)
	flow:setContinue(41)

	return true
end

function _M._to_47_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_0(flow, 47, 0, 10240500, 0, "", 5, false, 0)
end

function _M._to_51_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 51)

	if not _1 then
		flow:setActive()
		_C(51, "DoBehaviour", flow, "PBT_CustomLoopAnimation")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_LoveStart")
		flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_LoveLoop")
		flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_LoveEnd")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", true)
		flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
		flow:setContinue(51)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_56_0(flow)
	local _0 = _M._get_54_2(flow)

	if _0 then
		return _M._to_41_0(flow)
	end
end

function _M._get_22_2(flow)
	local _2 = _M._get_37_2(flow)
	local _0 = _C(19, "HasEntityTag", flow, _2, "TE_Chest_10021")

	if not _0 then
		return false
	end

	local _3 = _M._get_37_2(flow)
	local _4 = _C(20, "GetDistance", flow, _3, 0, false)
	local _1 = _4 <= 15

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
	local _0 = _C(16, "GetAoiEntityTableByLevel", flow, 0, 30, 64)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(37, "__iterItem", v)

		if _M._get_22_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_39_1(flow)
	local _0 = _M._get_37_3(flow)

	return not _0 or next(_0) == nil
end

function _M._get_50_1(flow)
	local _0 = _C(45, "CheckCanUseSkill", flow, 0, 10240320)

	return not _0
end

function _M._get_53_2(flow)
	local _0 = _M._get_27_1(flow)

	return _C(53, "CheckCanMoveToTarget", flow, _0, 0.3)
end

function _M._get_54_2(flow)
	local _0 = _M._get_53_2(flow)

	if not _0 then
		return false
	end

	local _2 = _M._get_39_1(flow)
	local _1 = not _2

	if not _1 then
		return false
	end

	return true
end

function _M._get_55_1(flow)
	local _0 = _M._get_53_2(flow)

	return not _0
end

return _M
