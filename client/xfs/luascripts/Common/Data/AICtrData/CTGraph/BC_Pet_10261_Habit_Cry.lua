-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_10261_Habit_Cry.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_3_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_9_0(flow)

	_A(flow, "StopEffectOnTarget", _0, "Eff_Env_Level_IOT_Meadow_Sadclouds_Looping_10261")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 1 then
		return true
	end

	if nodeId == 3 then
		return _M._to_1_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_1_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Cry")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 10)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_CryStart")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_CryLoop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_CryEnd")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 10)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(1)

	return true
end

function _M._to_3_0(flow)
	if not _B(flow, "PBT_PlayEffectOnTarget") then
		return
	end

	local _0 = _M._get_9_0(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEffectName", "Eff_Env_Level_IOT_Meadow_Sadclouds_Looping_10261")
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow:setContinue(3)

	return true
end

function _M._get_9_0(flow)
	return _C(9, "GetSelfId", flow)
end

return _M
