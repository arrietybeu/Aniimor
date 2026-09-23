-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Npc_Sub_PlayLoopState.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeSubFlow(flow)
	return _M._to_6_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 6 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_6_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	local _0 = _M._get_4_2(flow)
	local _1 = _M._get_2_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", _0)
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", _1)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", true)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(6)

	return true
end

function _M._get_0_1(flow)
	return flow:getContextValue("Params")
end

function _M._get_2_2(flow)
	local _0 = _M._get_0_1(flow)

	return _C(2, "GetTableValueByKey", flow, _0, 2)
end

function _M._get_4_2(flow)
	local _0 = _M._get_0_1(flow)

	return _C(4, "GetTableValueByKey", flow, _0, 1)
end

return _M
