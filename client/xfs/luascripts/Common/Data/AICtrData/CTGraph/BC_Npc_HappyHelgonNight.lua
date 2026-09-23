-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Npc_HappyHelgonNight.lua

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

function _M.executeContinue(flow, nodeId)
	if nodeId == 38 then
		return true
	end

	if nodeId == 39 then
		return true
	end

	if nodeId == 43 then
		return _M._to_35_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 39 then
		return _M._get_45_1(flow)
	end
end

function _M._to_25_0(flow)
	local _1 = _C(26, "GetDayTime", flow)
	local _0 = _C(28, "IsSameDayTime", flow, _1, 2)

	if _0 then
		return _M._to_43_0(flow)
	end
end

function _M._to_35_0(flow)
	local _1 = _M._get_33_0(flow)
	local _0 = _C(31, "HasEntityTag", flow, _1, "TE_DragonSleep")

	if _0 then
		return _M._to_39_0(flow)
	end

	return _M._to_38_0(flow)
end

function _M._to_38_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 38, 0, "", 5, "Behav_SleepStart", "Behav_SleepLoop", "Behav_SleepEnd", 5, "", true, false)
end

function _M._to_39_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 39)

	if not _1 then
		flow:setActive()
		_C(39, "DoBehaviour", flow, "PBT_CustomLoopAnimation")

		return _doBehaviourTail_0(flow, 39, 0, "", 5, "Behav_AlertStart", "Behav_AlertLoop", "Behav_AlertEnd", 5, "", false, false)
	else
		flow:setActiveFail()
	end
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

function _M._get_33_0(flow)
	return _C(33, "GetSelfId", flow)
end

function _M._get_45_1(flow)
	local _1 = _M._get_33_0(flow)
	local _0 = _C(44, "HasEntityTag", flow, _1, "TE_DragonSleep")

	return not _0
end

return _M
