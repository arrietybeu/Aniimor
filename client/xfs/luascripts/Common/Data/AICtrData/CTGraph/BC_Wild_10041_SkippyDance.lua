-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10041_SkippyDance.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _P = CTHelper.DoPatrolBehavior

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerShow" then
		return _M._to_10_0(flow)
	end

	if eventName == "LevelMsgTriggerJump" then
		return _M._to_14_0(flow)
	end

	if eventName == "LevelMsgTriggerRest" then
		return _M._to_13_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 9 then
		return true
	end

	if nodeId == 10 then
		return _M._to_9_0(flow)
	end

	if nodeId == 13 then
		return true
	end

	if nodeId == 14 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_9_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 90855927, 0, nil) then
		flow:setContinue(9)

		return true
	end
end

function _M._to_10_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 90857642, 1, nil) then
		flow:setContinue(10)

		return true
	end
end

function _M._to_13_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 90855927, 0, nil) then
		flow:setContinue(13)

		return true
	end
end

function _M._to_14_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 90870950, 0, nil) then
		flow:setContinue(14)

		return true
	end
end

return _M
