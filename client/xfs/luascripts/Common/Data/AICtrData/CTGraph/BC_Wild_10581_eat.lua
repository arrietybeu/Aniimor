-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10581_eat.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_20_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 12 then
		return _M._to_18_0(flow)
	end

	if nodeId == 15 then
		return _M._to_12_0(flow)
	end

	if nodeId == 16 then
		return _M._to_15_0(flow)
	end

	if nodeId == 18 then
		return _M._to_19_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_12_0(flow)
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
	flow:setContinue(12)

	return true
end

function _M._to_15_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_5_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tStopDist", 0.8)
	flow.__agent:addSubTreeLocalParam("tMaxTimeout", 50)
	flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
	flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 0)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
	flow:setContinue(15)

	return true
end

function _M._to_16_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Think")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow:setContinue(16)

	return true
end

function _M._to_18_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("firstDialogueId", 1038111)
	flow.__agent:addSubTreeLocalParam("lastDialogueId", 1038112)
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow:setContinue(18)

	return true
end

function _M._to_19_0(flow)
	flow:setActive()

	local _0 = _M._get_5_1(flow)
	local _1 = flow:getMessageContext()

	_1.sourceActorId = flow.__actorId

	flow:sendMessage(_0, "Msg_LeafSheep_eat", _1)

	return true
end

function _M._to_20_0(flow)
	local _1 = _M._get_2_3(flow)
	local _2 = not _1 or next(_1) == nil
	local _0 = not _2

	if _0 then
		flow:setActive()
		_A(flow, "AddEntityTag", 0, "TE_Env_10581_eat")

		return _M._to_16_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._get_2_2(flow)
	return flow:getCache(2, "__iterItem")
end

function _M._get_2_3(flow)
	local _0 = _C(6, "GetAoiEntityTableByLevel", flow, 0, 30, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(2, "__iterItem", v)

		if _M._get_21_3(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_5_1(flow)
	local _0 = flow:getCache(5, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_24_1(flow)

	flow:setCache(5, "1", _0)

	return _0
end

function _M._get_21_3(flow)
	local _5 = _M._get_2_2(flow)
	local _6 = _C(22, "HasEntityTag", flow, _5, "TE_Env_10581_eat")
	local _0 = not _6

	if not _0 then
		return false
	end

	local _3 = _M._get_2_2(flow)
	local _4 = _C(9, "GetPuppetData", flow, _3, "id", true, 0)
	local _1 = _4 == 11058100

	if not _1 then
		return false
	end

	local _2 = _C(25, "IsChildOfCharState", flow, 0, "LOCOMOTION")

	if not _2 then
		return false
	end

	return true
end

function _M._get_24_1(flow)
	local _0 = _M._get_2_3(flow)

	return _C(24, "SelectOneByRandom", flow, _0)
end

return _M
