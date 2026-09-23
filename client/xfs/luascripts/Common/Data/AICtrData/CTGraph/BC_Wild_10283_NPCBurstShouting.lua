-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10283_NPCBurstShouting.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTrigger666" then
		return _M._to_5_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 4 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_4_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _C(7, "GetRouteIdFromEntity", flow, 0, 0, 0, 0, "", "Burst", "", "")

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(4)

		return true
	end
end

function _M._to_5_0(flow)
	flow:addTimer(0, _M, "_to_6_0", flow)

	return _M._to_4_0(flow)
end

function _M._to_6_0(flow)
	flow:setActive()

	local _0 = _C(8, "GetActorId", flow, 91128298)

	_A(flow, "StartNpcDialog", 70200001, _0)

	return true
end

return _M
