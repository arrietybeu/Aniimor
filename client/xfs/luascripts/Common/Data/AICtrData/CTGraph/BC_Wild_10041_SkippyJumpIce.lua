-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10041_SkippyJumpIce.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _P = CTHelper.DoPatrolBehavior

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTrigger1JUMP" then
		return _M._to_14_0(flow)
	end

	if eventName == "LevelMsgTrigger2JUMP" then
		return _M._to_15_0(flow)
	end

	if eventName == "LevelMsgTrigger3JUMP" then
		return _M._to_13_0(flow)
	end

	if eventName == "LevelMsgTriggerT1JUMP" then
		return _M._to_17_0(flow)
	end

	if eventName == "LevelMsgTriggerT2JUMP" then
		return _M._to_19_0(flow)
	end

	if eventName == "LevelMsgTriggerT3JUMP" then
		return _M._to_21_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 13 then
		return true
	end

	if nodeId == 14 then
		return true
	end

	if nodeId == 15 then
		return true
	end

	if nodeId == 17 then
		return true
	end

	if nodeId == 19 then
		return true
	end

	if nodeId == 21 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_13_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 87006283, 0, nil) then
		flow:setContinue(13)

		return true
	end
end

function _M._to_14_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 87006279, 0, nil) then
		flow:setContinue(14)

		return true
	end
end

function _M._to_15_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 87006282, 0, nil) then
		flow:setContinue(15)

		return true
	end
end

function _M._to_17_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 79680908, 0, nil) then
		flow:setContinue(17)

		return true
	end
end

function _M._to_19_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 79780296, 0, nil) then
		flow:setContinue(19)

		return true
	end
end

function _M._to_21_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 79780297, 0, nil) then
		flow:setContinue(21)

		return true
	end
end

return _M
