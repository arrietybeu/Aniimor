-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_QuestNPC_SaveHelmonHurt.lua

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
	if eventName == "IdleMsgTrigger" then
		return _M._to_47_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 30 then
		return true
	end

	if nodeId == 53 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_30_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 30, 0, "HitFlyLoop", 6, "Fear", 5, "", true, false, false)
end

function _M._to_47_0(flow)
	local _0 = _M._get_51_2(flow)

	if _0 then
		return _M._to_53_0(flow)
	end

	local _2 = _M._get_51_2(flow)
	local _1 = not _2

	if _1 then
		return _M._to_30_0(flow)
	end
end

function _M._to_53_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 53, 0, "Behav_Happy", 6, "", 5, "", true, false, false)
end

function _M._get_51_2(flow)
	local _1 = _C(49, "GetStaticId", flow, 0)
	local _0 = _C(50, "GetPlayerVar", flow, _1)

	return _0 == 888
end

return _M
