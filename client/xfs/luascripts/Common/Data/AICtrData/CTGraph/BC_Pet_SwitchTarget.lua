-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_SwitchTarget.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "MasterSwitchTargetMsgTrigger" then
		return _M._to_2_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 2 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_2_0(flow)
	if not _B(flow, "PBT_Pet_CommandGo_Enemy") then
		return
	end

	local _0 = flow:getContextValue("enemyId")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetId", _0)
	flow.__agent:addSubTreeLocalParam("tTeleportDis", 0)
	flow.__agent:addSubTreeLocalParam("CurrentDistToTarget", 0)
	flow:setContinue(2)

	return true
end

return _M
