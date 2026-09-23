-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10381_shankefisheat3.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_14_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 48 then
		return _M._to_54_0(flow)
	end

	if nodeId == 54 then
		return _M._to_60_0(flow)
	end

	if nodeId == 56 then
		return _M._to_48_0(flow)
	end

	if nodeId == 60 then
		return _M._to_108_0(flow)
	end

	if nodeId == 65 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_14_0(flow)
	local _1 = _M._get_24_3(flow)
	local _2 = not _1 or next(_1) == nil
	local _0 = not _2

	if _0 then
		flow:setActive()
		_A(flow, "AddEntityTag", 0, "TE_Env_10581_eat")

		return _M._to_56_0(flow)
	end
end

function _M._to_48_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_31_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tStopDist", 0.5)
	flow.__agent:addSubTreeLocalParam("tMaxTimeout", 50)
	flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
	flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 0)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
	flow:setContinue(48)

	return true
end

function _M._to_54_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Eat")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_EatStart")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_EatLoop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_EatEnd")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(54)

	return true
end

function _M._to_56_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Think")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow:setContinue(56)

	return true
end

function _M._to_60_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Idle")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Think")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(60)

	return true
end

function _M._to_65_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("firstDialogueId", 1038103)
	flow.__agent:addSubTreeLocalParam("lastDialogueId", 1038105)
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow:setContinue(65)

	return true
end

function _M._to_108_0(flow)
	flow:setActive()

	local _0 = _M._get_31_1(flow)
	local _1 = flow:getMessageContext()

	_1.sourceActorId = flow.__actorId

	flow:sendMessage(_0, "Msg_LeafSheep_eat", _1)

	return _M._to_65_0(flow)
end

function _M._get_24_3(flow)
	local _0 = _C(32, "GetAoiEntityTableByLevel", flow, 0, 30, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(24, "__iterItem", v)

		if _M._get_91_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_24_2(flow)
	return flow:getCache(24, "__iterItem")
end

function _M._get_31_1(flow)
	local _0 = flow:getCache(31, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_86_1(flow)

	flow:setCache(31, "1", _0)

	return _0
end

function _M._get_86_1(flow)
	local _0 = _M._get_24_3(flow)

	return _C(86, "SelectOneByRandom", flow, _0)
end

function _M._get_91_2(flow)
	local _1 = _M._get_24_2(flow)
	local _0 = _C(90, "GetPuppetData", flow, _1, "id", true, 0)

	return _0 == 11058100
end

return _M
