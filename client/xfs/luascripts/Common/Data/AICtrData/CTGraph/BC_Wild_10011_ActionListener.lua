-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10011_ActionListener.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _P = CTHelper.DoPatrolBehavior
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tEventName", value0)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerRoute1" then
		return _M._to_7_0(flow)
	end

	if eventName == "LevelMsgTriggerRoute2" then
		return _M._to_16_0(flow)
	end

	if eventName == "LevelMsgTriggerRoute3" then
		return _M._to_17_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 7 then
		return _M._to_20_0(flow)
	end

	if nodeId == 16 then
		return _M._to_18_0(flow)
	end

	if nodeId == 17 then
		return _M._to_22_0(flow)
	end

	if nodeId == 18 then
		return _M._to_21_0(flow)
	end

	if nodeId == 20 then
		return true
	end

	if nodeId == 21 then
		return true
	end

	if nodeId == 22 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_7_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 70131254, 1, nil) then
		flow:setContinue(7)

		return true
	end
end

function _M._to_16_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 70197450, 1, nil) then
		flow:setContinue(16)

		return true
	end
end

function _M._to_17_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 72123313, 1, nil) then
		flow:setContinue(17)

		return true
	end
end

function _M._to_18_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 3, 72105236, nil, nil) then
		flow:setContinue(18)

		return true
	end
end

function _M._to_20_0(flow)
	if not _B(flow, "PBT_TriggerBlueprint") then
		return
	end

	return _doBehaviourTail_0(flow, 20, "FinishRoute1")
end

function _M._to_21_0(flow)
	if not _B(flow, "PBT_TriggerBlueprint") then
		return
	end

	return _doBehaviourTail_0(flow, 21, "FinishRoute2")
end

function _M._to_22_0(flow)
	if not _B(flow, "PBT_TriggerBlueprint") then
		return
	end

	return _doBehaviourTail_0(flow, 22, "FinishRoute3")
end

return _M
