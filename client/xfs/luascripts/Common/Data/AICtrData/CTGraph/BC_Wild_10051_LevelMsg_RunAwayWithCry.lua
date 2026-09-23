-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10051_LevelMsg_RunAwayWithCry.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value0)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value1)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerRunAwayWithCry" then
		return _M._to_1_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 1 then
		return _M._to_15_0(flow)
	end

	if nodeId == 2 then
		return _M._to_17_0(flow)
	end

	if nodeId == 15 then
		return _M._to_2_0(flow)
	end

	if nodeId == 16 then
		return true
	end

	if nodeId == 17 then
		return _M._to_16_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_1_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_0(flow, 1, "Surprise", 1)
end

function _M._to_2_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_11_1(flow)

	if _0 then
		flow:setActive()
		_C(2, "DoBehaviour", flow, "PBT_LeaveTarget")

		local _1 = _M._get_12_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tLeaveDistance", 10)
		flow.__agent:addSubTreeLocalParam("tSpeed", 5)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
		flow.__agent:addSubTreeLocalParam("tMaxTime", 10)
		flow:setContinue(2)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_15_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_0(flow, 15, "Cry", 10)
end

function _M._to_16_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Cry")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_CryStart")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_CryLoop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_CryEnd")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", true)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(16)

	return true
end

function _M._to_17_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_12_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(17)

	return true
end

function _M._get_8_3(flow)
	local _0 = _C(14, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(8, "__iterItem", v)

		if _M._get_10_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_8_2(flow)
	return flow:getCache(8, "__iterItem")
end

function _M._get_10_2(flow)
	local _0 = _M._get_8_2(flow)

	return _C(10, "HasEntityTag", flow, _0, "TE_Env_10051_FireShrub")
end

function _M._get_11_1(flow)
	local _1 = _M._get_8_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_12_2(flow)
	local _0 = _M._get_8_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(12, "__iterItem", v)

		_1 = _M._get_13_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_13_3(flow)
	local _0 = flow:getCache(12, "__iterItem")

	return _C(13, "GetDistance", flow, _0, 0, false)
end

return _M
