-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_10281Sneak.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tPointId", value0)
	agent:addSubTreeLocalParam("tPortId", value1)
	agent:addSubTreeLocalParam("tTimeout", value2)
	agent:addSubTreeLocalParam("tSpeedRateType", value3)
	agent:addSubTreeLocalParam("tSpeed", value4)
	agent:addSubTreeLocalParam("tUseAccurateArrive", value5)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "GBPMsg_ResPointGO1" then
		flow:setActive()

		local _0 = _M._get_1_2(flow)
		local _1 = _M._get_1_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _0, _1)

		return _M._to_0_0(flow)
	end

	if eventName == "GBPMsg_ResPointGO2" then
		flow:setActive()

		local _2 = _M._get_3_2(flow)
		local _3 = _M._get_3_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _2, _3)

		return _M._to_4_0(flow)
	end

	if eventName == "GBPMsg_ResPointGO3" then
		flow:setActive()

		local _4 = _M._get_71_2(flow)
		local _5 = _M._get_71_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _4, _5)

		return _M._to_72_0(flow)
	end

	if eventName == "GBPMsg_Commonjianghua" then
		flow:setActive()
		_A(flow, "StartNpcDialog", 102810001, 0)

		return true
	end

	if eventName == "GBPMsg_Commonshoudao" then
		flow:setActive()
		_A(flow, "StartNpcDialog", 102810002, 0)

		return true
	end

	if eventName == "GBPMsg_CommonSleep" then
		flow:setActive()
		_A(flow, "StartNpcDialog", 102810003, 0)

		return _M._to_79_0(flow)
	end

	if eventName == "GBPMsg_ResPointGoPatrol1" then
		flow:setActive()
		_A(flow, "StartNpcDialog", 102810004, 0)

		return _M._to_81_0(flow)
	end

	if eventName == "GBPMsg_ResPointGoPatrol2" then
		flow:setActive()
		_A(flow, "StartNpcDialog", 102810005, 0)

		return _M._to_87_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	return _M._to_91_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 0 then
		return true
	end

	if nodeId == 4 then
		return true
	end

	if nodeId == 72 then
		return true
	end

	if nodeId == 79 then
		return true
	end

	if nodeId == 81 then
		return true
	end

	if nodeId == 87 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_0_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_1_2(flow)
	local _1 = _M._get_1_3(flow)

	return _doBehaviourTail_0(flow, 0, _0, _1, 0, 0, 0, false)
end

function _M._to_4_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_3_2(flow)
	local _1 = _M._get_3_3(flow)

	return _doBehaviourTail_0(flow, 4, _0, _1, 0, 2, 0, false)
end

function _M._to_72_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_71_2(flow)
	local _1 = _M._get_71_3(flow)

	return _doBehaviourTail_0(flow, 72, _0, _1, 0, 2, 0, false)
end

function _M._to_79_0(flow)
	if not _B(flow, "PBT_Behav_Com_Sleep") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSleepTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tisLoop", true)
	flow:setContinue(79)

	return true
end

function _M._to_81_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_82_1(flow)

	if _P(flow, 1, _0, -1, nil) then
		flow:setContinue(81)

		return true
	end
end

function _M._to_87_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_88_1(flow)

	if _P(flow, 1, _0, -1, nil) then
		flow:setContinue(87)

		return true
	end
end

function _M._to_91_0(flow)
	local _3 = _M._get_93_2(flow)
	local _0 = not _3

	if _0 then
		flow:setActive()

		local _6 = _M._get_1_2(flow)
		local _7 = _M._get_1_3(flow)

		_A(flow, "ExitResPointPort", 0, _6, _7, 0, 0)

		return true
	end

	local _4 = _M._get_96_2(flow)
	local _1 = not _4

	if _1 then
		flow:setActive()

		local _8 = _M._get_3_2(flow)
		local _9 = _M._get_3_3(flow)

		_A(flow, "ExitResPointPort", 0, _8, _9, 0, 0)

		return true
	end

	local _5 = _M._get_99_2(flow)
	local _2 = not _5

	if _2 then
		flow:setActive()

		local _10 = _M._get_71_2(flow)
		local _11 = _M._get_71_3(flow)

		_A(flow, "ExitResPointPort", 0, _10, _11, 0, 0)

		return true
	end
end

function _M._get_1_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_1_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_3_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_3_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_71_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_71_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_82_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(82, "GetRouteIdFromResPoint", flow, false, _0)
end

function _M._get_88_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(88, "GetRouteIdFromResPoint", flow, false, _0)
end

function _M._get_93_2(flow)
	local _2 = _M._get_1_2(flow)
	local _0 = _2 == 0

	if not _0 then
		return false
	end

	local _3 = _M._get_1_3(flow)
	local _1 = _3 == 0

	if not _1 then
		return false
	end

	return true
end

function _M._get_96_2(flow)
	local _2 = _M._get_3_2(flow)
	local _0 = _2 == 0

	if not _0 then
		return false
	end

	local _3 = _M._get_3_3(flow)
	local _1 = _3 == 0

	if not _1 then
		return false
	end

	return true
end

function _M._get_99_2(flow)
	local _2 = _M._get_71_2(flow)
	local _0 = _2 == 0

	if not _0 then
		return false
	end

	local _3 = _M._get_71_3(flow)
	local _1 = _3 == 0

	if not _1 then
		return false
	end

	return true
end

return _M
