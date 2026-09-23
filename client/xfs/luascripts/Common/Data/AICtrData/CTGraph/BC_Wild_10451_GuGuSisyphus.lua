-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10451_GuGuSisyphus.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerBC_Wild_10451_GuGuSisyphus" then
		return _M._to_106_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 30 then
		return _M._to_126_0(flow)
	end

	if nodeId == 126 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_30_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 80070074, 1, nil) then
		flow:setContinue(30)

		return true
	end
end

function _M._to_94_0(flow)
	flow:setActive()

	local _0 = _C(100, "GetSelfId", flow)

	_A(flow, "StartNpcDialog", 70005285, _0)

	return _M._to_127_0(flow)
end

function _M._to_106_0(flow)
	flow:addTimer(5, _M, "_to_94_0", flow)

	return _M._to_30_0(flow)
end

function _M._to_121_0(flow)
	flow:setActive()

	local _0 = _C(122, "GetSelfId", flow)

	_A(flow, "StartNpcDialog", 70005286, _0)

	return true
end

function _M._to_126_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 79780567, 0, nil) then
		flow:setContinue(126)

		return true
	end
end

function _M._to_127_0(flow)
	flow:addTimer(10, _M, "_to_121_0", flow)

	return true
end

return _M
