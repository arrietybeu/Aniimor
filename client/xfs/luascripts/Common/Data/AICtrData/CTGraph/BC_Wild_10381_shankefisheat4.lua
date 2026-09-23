-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10381_shankefisheat4.lua

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
	if nodeId == 81 then
		return _M._to_82_0(flow)
	end

	if nodeId == 82 then
		return _M._to_83_0(flow)
	end

	if nodeId == 83 then
		return _M._to_84_0(flow)
	end

	if nodeId == 84 then
		return _M._to_85_0(flow)
	end

	if nodeId == 85 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_14_0(flow)
	local _1 = _M._get_72_3(flow)
	local _2 = not _1 or next(_1) == nil
	local _0 = not _2

	if _0 then
		return _M._to_81_0(flow)
	end
end

function _M._to_81_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Think")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow:setContinue(81)

	return true
end

function _M._to_82_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_75_1(flow)

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
	flow:setContinue(82)

	return true
end

function _M._to_83_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 83, 0, "Eat", 5, "Behav_EatStart", "Behav_EatLoop", "Behav_EatEnd", 5, "", false, false)
end

function _M._to_84_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 84, 0, "Happy", 5, "Behav_HappyStart", "Behav_HappyLoop", "Behav_HappyEnd", 5, "", false, false)
end

function _M._to_85_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("firstDialogueId", 1038106)
	flow.__agent:addSubTreeLocalParam("lastDialogueId", 1038109)
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow:setContinue(85)

	return true
end

function _M._get_72_2(flow)
	return flow:getCache(72, "__iterItem")
end

function _M._get_72_3(flow)
	local _0 = _C(76, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(72, "__iterItem", v)

		if _M._get_80_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_74_2(flow)
	local _0 = _M._get_72_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(74, "__iterItem", v)

		_1 = _M._get_79_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_75_1(flow)
	local _0 = flow:getCache(75, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_74_2(flow)

	flow:setCache(75, "1", _0)

	return _0
end

function _M._get_79_3(flow)
	local _0 = flow:getCache(74, "__iterItem")

	return _C(79, "GetDistance", flow, _0, 0, false)
end

function _M._get_80_2(flow)
	local _0 = _M._get_72_2(flow)

	return _C(80, "HasEntityTag", flow, _0, "TE_Env_10381_eat")
end

return _M
