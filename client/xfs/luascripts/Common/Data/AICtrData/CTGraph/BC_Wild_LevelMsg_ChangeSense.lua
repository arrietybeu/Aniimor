-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_LevelMsg_ChangeSense.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerChangeSense" then
		return _M._to_23_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 23 then
		return _M._to_37_0(flow)
	end

	if nodeId == 37 then
		return _M._to_20_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_20_0(flow)
	flow:setActive()
	_A(flow, "SetVisionAreaOverride", "visionAreaMid")

	return true
end

function _M._to_23_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	local _0 = "LOCOMOTION"

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", _0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(23)

	return true
end

function _M._to_37_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 1)
	flow:setContinue(37)

	return true
end

return _M
