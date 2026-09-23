-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10351_LeaderMsg_EscapeFromBear.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Msg_LeaderMsg" then
		return _M._to_142_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 119 then
		return true
	end

	if nodeId == 142 then
		return _M._to_119_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_119_0(flow)
	if not _B(flow, "PBT_Behav_Com_LeaveAndStare_ToPuppet") then
		return
	end

	local _0 = _C(138, "GetLeaderId", flow, 0)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tStareCount", 0)
	flow.__agent:addSubTreeLocalParam("LeaveCount", 0)
	flow.__agent:addSubTreeLocalParam("tStareCount", 0)
	flow:setContinue(119)

	return true
end

function _M._to_142_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Cry")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow:setContinue(142)

	return true
end

return _M
