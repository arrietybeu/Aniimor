-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10451_GuGuSisyphus_Rain.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerBC_Wild_10451_GuGuSisyphus_Rain" then
		return _M._to_125_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 120 then
		return _M._to_127_0(flow)
	end

	if nodeId == 127 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_120_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 80283260, 1, nil) then
		flow:setContinue(120)

		return true
	end
end

function _M._to_122_0(flow)
	flow:setActive()

	local _0 = _C(124, "GetSelfId", flow)

	_A(flow, "StartNpcDialog", 70005287, _0)

	return _M._to_128_0(flow)
end

function _M._to_125_0(flow)
	flow:addTimer(5, _M, "_to_122_0", flow)

	return _M._to_120_0(flow)
end

function _M._to_126_0(flow)
	flow:setActive()

	local _0 = _C(123, "GetSelfId", flow)

	_A(flow, "StartNpcDialog", 70005288, _0)

	return true
end

function _M._to_127_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 80283261, 0, nil) then
		flow:setContinue(127)

		return true
	end
end

function _M._to_128_0(flow)
	flow:addTimer(10, _M, "_to_126_0", flow)

	return true
end

return _M
