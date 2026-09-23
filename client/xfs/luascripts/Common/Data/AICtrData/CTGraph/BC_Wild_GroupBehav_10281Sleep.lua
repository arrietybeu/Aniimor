-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_10281Sleep.lua

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

local function _doBehaviourTail_1(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8, value9)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value1)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value2)
	agent:addSubTreeLocalParam("tAnimationStartKey", value3)
	agent:addSubTreeLocalParam("tAnimationLoopKey", value4)
	agent:addSubTreeLocalParam("tAnimationEndKey", value5)
	agent:addSubTreeLocalParam("tAnimationTimeout", value6)
	agent:addSubTreeLocalParam("tTimelineTag", value7)
	agent:addSubTreeLocalParam("tNeedLoop", value8)
	agent:addSubTreeLocalParam("tAnimationPlayOnce", value9)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "GBPMsg_ResPointGotosleep" then
		flow:setActive()

		local _0 = _M._get_1_2(flow)
		local _1 = _M._get_1_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _0, _1)

		return _M._to_0_0(flow)
	end

	if eventName == "GBPMsg_ResPointgo1" then
		flow:setActive()

		local _2 = _M._get_3_2(flow)
		local _3 = _M._get_3_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _2, _3)

		return _M._to_4_0(flow)
	end

	if eventName == "GBPMsg_CommonStartSleep" then
		return _M._to_35_0(flow)
	end

	if eventName == "GBPMsg_CommonAwake" then
		return _M._to_51_0(flow)
	end

	if eventName == "GBPMsg_CommonLeave" then
		return _M._to_53_0(flow)
	end

	if eventName == "GBPMsg_ResPoint02" then
		return _M._to_67_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	return _M._to_68_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 0 then
		return true
	end

	if nodeId == 4 then
		return _M._to_47_0(flow)
	end

	if nodeId == 35 then
		return true
	end

	if nodeId == 51 then
		return true
	end

	if nodeId == 53 then
		return _M._to_54_0(flow)
	end

	if nodeId == 54 then
		return true
	end

	if nodeId == 67 then
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

function _M._to_35_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 35, 0, "", 5, "Behav_SleepStart", "Behav_SleepLoop", "Behav_SleepEnd", 20, "", false, false)
end

function _M._to_47_0(flow)
	flow:setActive()
	_C(47, "AddEntityTag", flow, 0, "TE_DragonSleep")

	return true
end

function _M._to_51_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 51, 0, "", 5, "Behav_DoubtStart", "Behav_DoubtLoop", "Behav_DoubtEnd", 5, "", false, false)
end

function _M._to_53_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Jump")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", true)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(53)

	return true
end

function _M._to_54_0(flow)
	if not _B(flow, "PBT_LeaveTarget") then
		return
	end

	local _0 = _M._get_63_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tLeaveDistance", 5)
	flow.__agent:addSubTreeLocalParam("tSpeed", 4)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
	flow.__agent:addSubTreeLocalParam("tMaxTime", 10)
	flow:setContinue(54)

	return true
end

function _M._to_67_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_66_1(flow)

	if _P(flow, 1, _0, 0, nil) then
		flow:setContinue(67)

		return true
	end
end

function _M._to_68_0(flow)
	local _2 = _M._get_70_2(flow)
	local _0 = not _2

	if _0 then
		flow:setActive()

		local _4 = _M._get_1_2(flow)
		local _5 = _M._get_1_3(flow)

		_A(flow, "ExitResPointPort", 0, _4, _5, 0, 0)

		return true
	end

	local _3 = _M._get_73_2(flow)
	local _1 = not _3

	if _1 then
		flow:setActive()

		local _6 = _M._get_3_2(flow)
		local _7 = _M._get_3_3(flow)

		_A(flow, "ExitResPointPort", 0, _6, _7, 0, 0)

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

function _M._get_58_3(flow)
	local _0 = _C(55, "GetAoiEntityTableByLevel", flow, 0, 10, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(58, "__iterItem", v)

		if _M._get_60_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_58_2(flow)
	return flow:getCache(58, "__iterItem")
end

function _M._get_60_2(flow)
	local _2 = _M._get_58_2(flow)
	local _3 = _C(56, "GetPuppetData", flow, _2, "petPrototypeId", true, 0)
	local _0 = _3 == 1028100

	if not _0 then
		return false
	end

	local _4 = _M._get_58_2(flow)
	local _5 = _C(61, "GetDistance", flow, _4, 0, false)
	local _1 = _5 <= 2

	if not _1 then
		return false
	end

	return true
end

function _M._get_63_1(flow)
	local _0 = flow:getCache(63, "Puppet10031")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_64_1(flow)

	flow:setCache(63, "Puppet10031", _0)

	return _0
end

function _M._get_64_1(flow)
	local _0 = _M._get_58_3(flow)

	return _C(64, "SelectOneByRandom", flow, _0)
end

function _M._get_66_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(66, "GetRouteIdFromResPoint", flow, false, _0)
end

function _M._get_70_2(flow)
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

function _M._get_73_2(flow)
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

return _M
