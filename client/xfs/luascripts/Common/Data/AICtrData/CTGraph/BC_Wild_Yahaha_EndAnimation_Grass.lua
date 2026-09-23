-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_Yahaha_EndAnimation_Grass.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerYahahaEnd" then
		return _M._to_22_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 22 then
		return _M._to_24_0(flow)
	end

	if nodeId == 24 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_22_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	local _0 = "MIMICRY"

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", _0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(22)

	return true
end

function _M._to_24_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Mimicry_Idle")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", true)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(24)

	return true
end

return _M
