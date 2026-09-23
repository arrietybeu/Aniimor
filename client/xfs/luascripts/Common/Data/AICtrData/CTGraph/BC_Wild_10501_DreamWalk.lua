-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10501_DreamWalk.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_49_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 48 then
		return _M._to_53_0(flow)
	end

	if nodeId == 49 then
		return _M._to_50_0(flow)
	end

	if nodeId == 53 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_48_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	local _0 = _C(52, "RandomInteger", flow, 30, 60)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "AI_Walk")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", _0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Dout")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", true)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(48)

	return true
end

function _M._to_49_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_46_3(flow)

	if _0 then
		flow:setActive()
		_C(49, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_42_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 0.1)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 0)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 3)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 0)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", true)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(49)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_50_0(flow)
	flow:setActive()

	local _0 = _C(51, "GetSelfId", flow)

	_A(flow, "StartNpcDialog", 70008544, _0)

	return _M._to_48_0(flow)
end

function _M._to_53_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_55_2(flow)

	if _0 then
		flow:setActive()
		_C(53, "DoBehaviour", flow, "PBT_CastSkill")

		local _1 = _M._get_42_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tSkillId", 10800351)
		flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
		flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
		flow:setContinue(53)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_37_3(flow)
	local _0 = _C(36, "GetAoiEntityTableByLevel", flow, 0, 10, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(37, "__iterItem", v)

		_1[#_1 + 1] = v
	end

	return _1
end

function _M._get_40_2(flow)
	local _0 = _M._get_37_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(40, "__iterItem", v)

		_1 = _M._get_41_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_41_3(flow)
	local _0 = flow:getCache(40, "__iterItem")

	return _C(41, "GetDistance", flow, _0, 0, false)
end

function _M._get_42_1(flow)
	local _0 = flow:getCache(42, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_40_2(flow)

	flow:setCache(42, "1", _0)

	return _0
end

function _M._get_46_3(flow)
	local _5 = _C(44, "RandomInteger", flow, 0, 30)
	local _0 = _5 <= 2

	if not _0 then
		return false
	end

	local _3 = _M._get_37_3(flow)
	local _4 = not _3 or next(_3) == nil
	local _1 = not _4

	if not _1 then
		return false
	end

	local _6 = _C(57, "CheckHasEntityTag", flow, 0, "TE_Wild_10501_Rage")
	local _2 = not _6

	if not _2 then
		return false
	end

	return true
end

function _M._get_55_2(flow)
	local _0 = _C(54, "RandomInteger", flow, 0, 40)

	return _0 <= 2
end

return _M
