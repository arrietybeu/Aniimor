-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10381_shankefishfight.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Msg_Shankefish_Fight_END" then
		return _M._to_31_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 31 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_31_0(flow)
	if not _B(flow, "PBT_Noop") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(31)

	return true
end

return _M
