-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10021_VisionValue_None_MimicryOut.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "VisionValue_None" then
		return _M._to_141_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 141 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_141_0(flow)
	if not _B(flow, "PBT_Behav_Com_MimicryOut") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(141)

	return true
end

return _M
