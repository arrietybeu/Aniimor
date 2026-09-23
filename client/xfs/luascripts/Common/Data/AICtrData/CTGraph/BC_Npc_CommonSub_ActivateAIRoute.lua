-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Npc_CommonSub_ActivateAIRoute.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction

function _M.executeSubFlow(flow)
	return _M._to_11_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 4 then
		return _M._to_2_0(flow)
	end

	if nodeId == 9 then
		return _M._to_12_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_2_0(flow)
	flow:setActive()

	local _0 = _M._get_3_1(flow)
	local _1 = _M._get_7_2(flow)

	_A(flow, "SetNpcStatus", _0, _1, 2, false)

	return true
end

function _M._to_4_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_1_2(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(4)

		return true
	end
end

function _M._to_9_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_1_2(flow)

	if _P(flow, 4, _0, nil, 0) then
		flow:setContinue(9)

		return true
	end
end

function _M._to_11_0(flow)
	local _2 = _M._get_10_2(flow)
	local _0 = not _2

	if _0 then
		return _M._to_4_0(flow)
	end

	local _1 = _M._get_10_2(flow)

	if _1 then
		return _M._to_9_0(flow)
	end
end

function _M._to_12_0(flow)
	flow:setActive()

	local _0 = _M._get_3_1(flow)
	local _1 = _M._get_7_2(flow)

	_A(flow, "SetNpcStatus", _0, _1, 2, false)

	return true
end

function _M._get_0_2(flow)
	local _0 = flow:getContextValue("stateTable")

	return _C(0, "GetTableValueByKey", flow, _0, "behavParams")
end

function _M._get_1_2(flow)
	local _0 = _M._get_0_2(flow)

	return _C(1, "GetTableValueByKey", flow, _0, 1)
end

function _M._get_3_1(flow)
	return _C(3, "GetStaticId", flow, 0)
end

function _M._get_7_2(flow)
	return flow:getContextValue("stateKey")
end

function _M._get_10_2(flow)
	local _1 = _M._get_0_2(flow)
	local _0 = _C(8, "GetTableValueByKey", flow, _1, 2)

	return _0 == 1
end

return _M
