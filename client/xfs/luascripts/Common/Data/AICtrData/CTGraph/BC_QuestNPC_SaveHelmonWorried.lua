-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_QuestNPC_SaveHelmonWorried.lua

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

local function _doBehaviourTail_1(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8, value9)
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

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_27_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 11 then
		return true
	end

	if nodeId == 28 then
		return _M._to_29_0(flow)
	end

	if nodeId == 29 then
		return _M._to_31_0(flow)
	end

	if nodeId == 30 then
		return _M._to_28_0(flow)
	end

	if nodeId == 31 then
		return true
	end

	if nodeId == 35 then
		return true
	end

	if nodeId == 39 then
		return _M._to_35_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_27_0(flow)
	local _0 = _M._get_34_2(flow)

	if _0 then
		return _M._to_30_0(flow)
	end

	local _2 = _M._get_34_2(flow)
	local _1 = not _2

	if _1 then
		return _M._to_39_0(flow)
	end
end

function _M._to_28_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 28, 0, "Behav_Love", 6, "Laugh", 5, "", false, false, false)
end

function _M._to_29_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 29, 0, "Behav_Happy", 6, "Happy", 5, "", false, false, false)
end

function _M._to_30_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 30, 0, "AI_IdleSpecial02", 6, "", 5, "", false, false, false)
end

function _M._to_31_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 31, 0, "AI_IdleSpecial02", 6, "", 5, "", false, false, false)
end

function _M._to_35_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 35, 0, "Cry", 4.8, "Behav_CryStart", "Behav_CryLoop", "Behav_CryEnd", 6, "", false, false)
end

function _M._to_39_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 39, 0, "Cry", 4.8, "EnvBehav_WorryStart", "EnvBehav_WorryLoop", "EnvBehav_WorryEnd", 5.083, "", false, false)
end

function _M._get_34_2(flow)
	local _1 = _C(38, "GetStaticId", flow, 0)
	local _0 = _C(33, "GetPlayerVar", flow, _1)

	return _0 == 999
end

return _M
