-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Npc_Sub_PlayRoute.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior

function _M.executeSubFlow(flow)
	return _M._to_3_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 3 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_3_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_2_2(flow)

	if _P(flow, 1, _0, 0, nil) then
		flow:setContinue(3)

		return true
	end
end

function _M._get_2_2(flow)
	local _0 = flow:getContextValue("Params")

	return _C(2, "GetTableValueByKey", flow, _0, 1)
end

return _M
