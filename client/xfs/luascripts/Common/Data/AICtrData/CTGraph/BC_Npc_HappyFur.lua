-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Npc_HappyFur.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _P = CTHelper.DoPatrolBehavior
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerSheep2" then
		return _M._to_4_0(flow)
	end

	if eventName == "LevelMsgTriggerYe2" then
		return _M._to_29_0(flow)
	end

	if eventName == "LevelMsgTriggerSheep3" then
		return _M._to_7_0(flow)
	end

	if eventName == "LevelMsgTriggerYe3" then
		return _M._to_30_0(flow)
	end

	if eventName == "LevelMsgTriggerSheepEnd" then
		return _M._to_25_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 4 then
		return _M._to_23_0(flow)
	end

	if nodeId == 7 then
		return _M._to_31_0(flow)
	end

	if nodeId == 21 then
		return true
	end

	if nodeId == 22 then
		return true
	end

	if nodeId == 23 then
		return true
	end

	if nodeId == 24 then
		return true
	end

	if nodeId == 25 then
		return _M._to_26_0(flow)
	end

	if nodeId == 26 then
		return true
	end

	if nodeId == 27 then
		return _M._to_21_0(flow)
	end

	if nodeId == 28 then
		return _M._to_22_0(flow)
	end

	if nodeId == 29 then
		return _M._to_27_0(flow)
	end

	if nodeId == 30 then
		return _M._to_28_0(flow)
	end

	if nodeId == 31 then
		return _M._to_24_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_4_0(flow)
	if not _B(flow, "PBT_Com_Angry") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(4)

	return true
end

function _M._to_7_0(flow)
	if not _B(flow, "PBT_Com_Angry") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(7)

	return true
end

function _M._to_21_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 88097319, 0, nil) then
		flow:setContinue(21)

		return true
	end
end

function _M._to_22_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 88097320, 0, nil) then
		flow:setContinue(22)

		return true
	end
end

function _M._to_23_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 88097318, 0, nil) then
		flow:setContinue(23)

		return true
	end
end

function _M._to_24_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 88097321, 0, nil) then
		flow:setContinue(24)

		return true
	end
end

function _M._to_25_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 88097322, 1, nil) then
		flow:setContinue(25)

		return true
	end
end

function _M._to_26_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 88097323, 0, nil) then
		flow:setContinue(26)

		return true
	end
end

function _M._to_27_0(flow)
	if not _B(flow, "PBT_TriggerBlueprint") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEventName", "Dialog2")
	flow:setContinue(27)

	return true
end

function _M._to_28_0(flow)
	if not _B(flow, "PBT_TriggerBlueprint") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEventName", "Dialog3")
	flow:setContinue(28)

	return true
end

function _M._to_29_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 90830200, 1, nil) then
		flow:setContinue(29)

		return true
	end
end

function _M._to_30_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 90830205, 1, nil) then
		flow:setContinue(30)

		return true
	end
end

function _M._to_31_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 90954734, 1, nil) then
		flow:setContinue(31)

		return true
	end
end

return _M
