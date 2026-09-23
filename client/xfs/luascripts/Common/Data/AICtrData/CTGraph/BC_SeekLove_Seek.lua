-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_SeekLove_Seek.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
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

local function _doBehaviourTail_1(flow, nodeId, value0)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tPatrolRange", value0)
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
		return _M._to_14_0(flow)
	end

	if nodeId == 4 then
		return _M._to_0_0(flow)
	end

	if nodeId == 14 then
		return _M._to_16_0(flow)
	end

	if nodeId == 15 then
		return _M._to_18_0(flow)
	end

	if nodeId == 16 then
		return _M._to_15_0(flow)
	end

	if nodeId == 17 then
		return _M._to_20_0(flow)
	end

	if nodeId == 18 then
		return _M._to_17_0(flow)
	end

	if nodeId == 19 then
		return _M._to_22_0(flow)
	end

	if nodeId == 20 then
		return _M._to_19_0(flow)
	end

	if nodeId == 21 then
		return _M._to_24_0(flow)
	end

	if nodeId == 22 then
		return _M._to_21_0(flow)
	end

	if nodeId == 23 then
		return _M._to_25_0(flow)
	end

	if nodeId == 24 then
		return _M._to_23_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_0_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 0, 0, "Behav_Alert", 10, "", 10, "", false, false, false)
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

function _M._to_14_0(flow)
	if not _B(flow, "PBT_PartolInRange") then
		return
	end

	return _doBehaviourTail_1(flow, 14, 2)
end

function _M._to_15_0(flow)
	if not _B(flow, "PBT_PartolInRange") then
		return
	end

	return _doBehaviourTail_1(flow, 15, 2)
end

function _M._to_16_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 16, 0, "Behav_Alert", 10, "Happy", 10, "", false, false, false)
end

function _M._to_17_0(flow)
	if not _B(flow, "PBT_PartolInRange") then
		return
	end

	return _doBehaviourTail_1(flow, 17, 2)
end

function _M._to_18_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 18, 0, "Behav_Alert", 10, "Happy", 10, "", false, false, false)
end

function _M._to_19_0(flow)
	if not _B(flow, "PBT_PartolInRange") then
		return
	end

	return _doBehaviourTail_1(flow, 19, 2)
end

function _M._to_20_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 20, 0, "Behav_Alert", 10, "Happy", 10, "", false, false, false)
end

function _M._to_21_0(flow)
	if not _B(flow, "PBT_PartolInRange") then
		return
	end

	return _doBehaviourTail_1(flow, 21, 2)
end

function _M._to_22_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 22, 0, "Behav_Alert", 10, "Happy", 10, "", false, false, false)
end

function _M._to_23_0(flow)
	if not _B(flow, "PBT_PartolInRange") then
		return
	end

	return _doBehaviourTail_1(flow, 23, 2)
end

function _M._to_24_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 24, 0, "Behav_Alert", 10, "Happy", 10, "", false, false, false)
end

function _M._to_25_0(flow)
	flow:setActive()
	_A(flow, "StopEffectOnTarget", 0, "Eff_Common_EnvBehav_SeekLove")

	return true
end

return _M
