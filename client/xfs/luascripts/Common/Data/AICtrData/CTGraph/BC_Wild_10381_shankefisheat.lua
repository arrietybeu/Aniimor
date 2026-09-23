-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10381_shankefisheat.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8, value9)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value1)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value2)
	agent:addSubTreeLocalParam("tAnimationStartKey", value3)
	agent:addSubTreeLocalParam("tAnimationLoopKey", value4)
	agent:addSubTreeLocalParam("tAnimationEndKey", value5)
	agent:addSubTreeLocalParam("tAnimationTimeout", value6)
	agent:addSubTreeLocalParam("tTimelineTag", value7)
	agent:addSubTreeLocalParam("tNeedLoop", value8)
	agent:addSubTreeLocalParam("tAnimationPlayOnce", value9)
	flow:setContinue(nodeId)

	return true
end

function _M.executeTickLodTrigger(flow)
	return _M._to_14_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 46 then
		return _M._to_59_0(flow)
	end

	if nodeId == 58 then
		return _M._to_46_0(flow)
	end

	if nodeId == 59 then
		return _M._to_61_0(flow)
	end

	if nodeId == 61 then
		return _M._to_63_0(flow)
	end

	if nodeId == 63 then
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
		return _M._to_58_0(flow)
	end
end

function _M._to_46_0(flow)
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
	flow:setContinue(46)

	return true
end

function _M._to_58_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Think")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow:setContinue(58)

	return true
end

function _M._to_59_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 59, 0, "Eat", 5, "Behav_EatStart", "Behav_EatLoop", "Behav_EatEnd", 5, "", false, false)
end

function _M._to_61_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 61, 0, "Happy", 5, "Behav_HappyStart", "Behav_HappyLoop", "Behav_HappyEnd", 5, "", false, false)
end

function _M._to_63_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("firstDialogueId", 1038106)
	flow.__agent:addSubTreeLocalParam("lastDialogueId", 1038108)
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow:setContinue(63)

	return true
end

function _M._get_24_3(flow)
	local _0 = _C(32, "GetAoiEntityTableByLevel", flow, 0, 30, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(24, "__iterItem", v)

		if _M._get_67_2(flow) then
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

function _M._get_67_2(flow)
	local _1 = _M._get_24_2(flow)
	local _0 = _C(66, "GetPuppetData", flow, _1, "id", true, 0)

	return _0 == 1062100
end

function _M._get_86_1(flow)
	local _0 = _M._get_24_3(flow)

	return _C(86, "SelectOneByRandom", flow, _0)
end

return _M
