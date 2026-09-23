-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10041_SkippyReturn.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _P = CTHelper.DoPatrolBehavior

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTrigger1HOME" then
		return _M._to_1_0(flow)
	end

	if eventName == "LevelMsgTrigger2HOME" then
		return _M._to_4_0(flow)
	end

	if eventName == "LevelMsgTrigger3HOME" then
		return _M._to_6_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 1 then
		return true
	end

	if nodeId == 4 then
		return true
	end

	if nodeId == 6 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_1_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 79792395, 1, nil) then
		flow:setContinue(1)

		return true
	end
end

function _M._to_4_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 79792396, 1, nil) then
		flow:setContinue(4)

		return true
	end
end

function _M._to_6_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 79792397, 1, nil) then
		flow:setContinue(6)

		return true
	end
end

return _M
