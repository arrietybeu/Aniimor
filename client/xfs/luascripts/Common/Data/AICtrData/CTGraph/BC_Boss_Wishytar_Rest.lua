-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Boss_Wishytar_Rest.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_59_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 59 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_59_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Mon_IdleSpecial_Loop")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Mon_IdleSpecial_Loop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Mon_IdleSpecial_End")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 99999)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(59)

	return true
end

return _M
