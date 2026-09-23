-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Npc_10031_idlemsg.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_20_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 22 then
		return true
	end

	if nodeId == 23 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_20_0(flow)
	local _0 = _C(21, "HasEntityTag", flow, 0, "TE_MantisGuard")

	if _0 then
		return _M._to_22_0(flow)
	end

	return _M._to_23_0(flow)
end

function _M._to_22_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 77657350, -1, nil) then
		flow:setContinue(22)

		return true
	end
end

function _M._to_23_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 77657349, -1, nil) then
		flow:setContinue(23)

		return true
	end
end

return _M
