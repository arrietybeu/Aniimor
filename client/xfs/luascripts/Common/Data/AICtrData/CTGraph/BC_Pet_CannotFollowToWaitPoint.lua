-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_CannotFollowToWaitPoint.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "EnterCannotFollowAreaMsg" then
		return _M._to_1_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 1 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_1_0(flow)
	if not _B(flow, "PBT_MoveToPoint") then
		return
	end

	local _0 = flow:getContextValue("waitPos")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tMovePos", _0)
	flow.__agent:addSubTreeLocalParam("tMoveMaxTime", 15)
	flow.__agent:addSubTreeLocalParam("tMoveSpeed", -1)
	flow.__agent:addSubTreeLocalParam("tBehaviorSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow.__agent:addSubTreeLocalParam("tTeleportIfCannotMove", true)
	flow:setContinue(1)

	return true
end

return _M
