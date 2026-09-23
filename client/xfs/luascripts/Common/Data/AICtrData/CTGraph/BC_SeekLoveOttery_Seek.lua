-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_SeekLoveOttery_Seek.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tAnimationKey", value1)
	agent:addSubTreeLocalParam("tAnimationTimeout", value2)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value3)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value4)
	agent:addSubTreeLocalParam("tTimelineTag", value5)
	agent:addSubTreeLocalParam("tNeedLoop", value6)
	agent:addSubTreeLocalParam("tAnimationPlayOnce", value7)
	agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", value8)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "SeekLoveMsgTrigger" then
		return _M._to_4_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 0 then
		return _M._to_8_0(flow)
	end

	if nodeId == 4 then
		return _M._to_0_0(flow)
	end

	if nodeId == 8 then
		return _M._to_9_0(flow)
	end

	if nodeId == 9 then
		return _M._to_10_0(flow)
	end

	if nodeId == 10 then
		return _M._to_11_0(flow)
	end

	if nodeId == 11 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_0_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 0, 0, "Behav_Alert", 2, "", 0, "", false, false, false)
end

function _M._to_4_0(flow)
	if not _B(flow, "PBT_PlayEffectOnTarget") then
		return
	end

	local _0 = _C(5, "GetSelfId", flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEffectName", "Eff_Common_EnvBehav_SeekLove")
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow:setContinue(4)

	return true
end

function _M._to_8_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 8, 0, "Behav_Alert", 2, "", 0, "", false, false, false)
end

function _M._to_9_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 9, 0, "Behav_Alert", 2, "", 0, "", false, false, false)
end

function _M._to_10_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 10, 0, "Behav_Alert", 2, "", 0, "", false, false, false)
end

function _M._to_11_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 11, 20, "", 0, "", 0, "", false, false, false)
end

return _M
