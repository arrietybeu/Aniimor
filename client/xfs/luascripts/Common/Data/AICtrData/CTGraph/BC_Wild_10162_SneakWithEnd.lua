-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10162_SneakWithEnd.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Msg_10162_SneakWithEnd" then
		return _M._to_37_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 37 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_37_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", "LOCOMOTION")
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(37)

	return true
end

return _M
