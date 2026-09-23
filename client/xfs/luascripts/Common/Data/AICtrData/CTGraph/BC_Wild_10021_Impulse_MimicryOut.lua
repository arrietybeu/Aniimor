-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10021_Impulse_MimicryOut.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "MimicryOutByImpulseTrigger" then
		return _M._to_147_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 142 then
		return _M._to_146_0(flow)
	end

	if nodeId == 144 then
		return true
	end

	if nodeId == 146 then
		return _M._to_144_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_142_0(flow)
	if not _B(flow, "PBT_Behav_Com_MimicryOutAndStun") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(142)

	return true
end

function _M._to_144_0(flow)
	if not _B(flow, "PBT_ReadyToFight") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", 0)
	flow.__agent:addSubTreeLocalParam("tRandomWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tShowExclamation", false)
	flow:setContinue(144)

	return true
end

function _M._to_146_0(flow)
	if not _B(flow, "PBT_Com_Node_OnlyShowBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Angry")
	flow.__agent:addSubTreeLocalParam("tTimeout", 2)
	flow:setContinue(146)

	return true
end

function _M._to_147_0(flow)
	flow:addTimer(1, _M, "_to_148_0", flow)

	return _M._to_142_0(flow)
end

function _M._to_148_0(flow)
	flow:setActive()

	local _0 = _C(149, "GetSelfId", flow)

	_A(flow, "SendMessageToTrigger", _0, 1002104)

	return true
end

return _M
