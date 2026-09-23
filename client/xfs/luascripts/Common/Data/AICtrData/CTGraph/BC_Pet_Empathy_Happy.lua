-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_Empathy_Happy.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "MasterOpenChestTrigger" then
		return _M._to_121_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _C(135, "GetSelfId", flow)

	_A(flow, "HideEmojiOnTarget", _0, "Happy")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 121 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_121_0(flow)
	if not _B(flow, "PBT_Com_Happy") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Behav_Happy")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 4)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow:setContinue(121)

	return true
end

return _M
