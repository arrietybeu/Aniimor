-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Npc_HappyHelgonNoAlert.lua

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
	return _M._to_25_0(flow)
end

function _M.executeEventTrigger(flow, eventName)
	return
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 4 then
		return true
	end

	if nodeId == 17 then
		return true
	end

	if nodeId == 36 then
		return true
	end

	if nodeId == 38 then
		return true
	end

	if nodeId == 40 then
		return true
	end

	if nodeId == 41 then
		return true
	end

	if nodeId == 42 then
		return _M._to_15_0(flow)
	end

	if nodeId == 43 then
		return _M._to_35_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_15_0(flow)
	local _2 = _C(8, "GetSelfId", flow)
	local _0 = _C(2, "HasEntityTag", flow, _2, "TE_DragonCry")

	if _0 then
		return _M._to_41_0(flow)
	end

	local _3 = _C(22, "GetSelfId", flow)
	local _1 = _C(20, "HasEntityTag", flow, _3, "TE_DragonHappy")

	if _1 then
		return _M._to_40_0(flow)
	end
end

function _M._to_25_0(flow)
	local _2 = _M._get_26_0(flow)
	local _0 = _C(27, "IsSameDayTime", flow, _2, 1)

	if _0 then
		return _M._to_42_0(flow)
	end

	local _3 = _M._get_26_0(flow)
	local _1 = _C(28, "IsSameDayTime", flow, _3, 2)

	if _1 then
		return _M._to_43_0(flow)
	end
end

function _M._to_35_0(flow)
	return _M._to_38_0(flow)
end

function _M._to_38_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 38, 0, "", 5, "Behav_SleepStart", "Behav_SleepLoop", "Behav_SleepEnd", 5, "", true, false)
end

function _M._to_40_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 40, 0, "", 5, "Behav_LoveStart", "Behav_LoveLoop", "Behav_LoveEnd", 5, "", false, false)
end

function _M._to_41_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 41, 0, "", 5, "Behav_CryStart", "Behav_CryLoop", "Behav_CryEnd", 5, "", true, false)
end

function _M._to_42_0(flow)
	if not _B(flow, "PBT_TriggerBlueprint") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEventName", "StartHappy")
	flow:setContinue(42)

	return true
end

function _M._to_43_0(flow)
	if not _B(flow, "PBT_TriggerBlueprint") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEventName", "StartSleep")
	flow:setContinue(43)

	return true
end

function _M._get_1_1(flow)
	local _1 = _C(7, "GetRouteIdFromEntity", flow, 0, 1, 0, 0, "", "DragonCry", "", "")
	local _0 = _1 == 0

	return not _0
end

function _M._get_19_1(flow)
	local _1 = _C(23, "GetRouteIdFromEntity", flow, 0, 1, 0, 0, "", "DragonHappy", "", "")
	local _0 = _1 == 0

	return not _0
end

function _M._get_26_0(flow)
	return _C(26, "GetDayTime", flow)
end

function _M._get_30_1(flow)
	local _1 = _C(34, "GetRouteIdFromEntity", flow, 0, 2, 0, 0, "", "DragonSleep", "", "")
	local _0 = _1 == 0

	return not _0
end

function _M._get_33_0(flow)
	return _C(33, "GetSelfId", flow)
end

return _M
