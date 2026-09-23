-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10291_FentuftJumpFurEvent.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _P = CTHelper.DoPatrolBehavior
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "GBPMsg_CommonChargeFur" then
		return _M._to_5_0(flow)
	end

	if eventName == "GBPMsg_CommonHappyTest" then
		return _M._to_6_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 5 then
		return true
	end

	if nodeId == 6 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_5_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 82761347, 1, nil) then
		flow:setContinue(5)

		return true
	end
end

function _M._to_6_0(flow)
	if not _B(flow, "PBT_Com_Angry") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(6)

	return true
end

return _M
