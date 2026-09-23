-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_CatchFailure_Leave.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "CatchResult_Failure" then
		return _M._to_48_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 48 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_48_0(flow)
	if not _B(flow, "PBT_Perception_Leave") then
		return
	end

	local _0 = flow:getContextValue("ballMasterActorId")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tSpeed", 3.5)
	flow:setContinue(48)

	return true
end

function _M._get_76_1(flow)
	return _C(76, "GetAoiEntityTableByLevel", flow, 0, 30, 2)
end

return _M
