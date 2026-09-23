-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_10031TrickCrab.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
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

local function _doBehaviourTail_1(flow, nodeId, value0, value1, value2, value3, value4, value5, value6)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tSkillId", value1)
	agent:addSubTreeLocalParam("tSkillTargetActorId", value2)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value3)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value4)
	agent:addSubTreeLocalParam("tRaycastOpen", value5)
	agent:addSubTreeLocalParam("tCastAbilitySource", value6)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_2(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value0)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value1)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_3(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tAnimationKey", value1)
	agent:addSubTreeLocalParam("tAnimationTimeout", value2)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value3)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value4)
	agent:addSubTreeLocalParam("tTimelineTag", value5)
	agent:addSubTreeLocalParam("tNeedLoop", value6)
	agent:addSubTreeLocalParam("tAnimationPlayOnce", value7)
	agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", value8)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "GBPMsg_ResPointManitisGoFirst" then
		flow:setActive()

		local _0 = _M._get_2_2(flow)
		local _1 = _M._get_2_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _0, _1)

		return _M._to_16_0(flow)
	end

	if eventName == "GBPMsg_ResPointCrabGoFirst" then
		flow:setActive()

		local _2 = _M._get_23_2(flow)
		local _3 = _M._get_23_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _2, _3)

		return _M._to_24_0(flow)
	end

	if eventName == "GBPMsg_ResPointManitisGoSecond" then
		flow:setActive()

		local _4 = _M._get_27_2(flow)
		local _5 = _M._get_27_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _4, _5)

		return _M._to_31_0(flow)
	end

	if eventName == "GBPMsg_CommonCrabSleep" then
		return _M._to_39_0(flow)
	end

	if eventName == "GBPMsg_ResPointCrabAngry" then
		flow:setActive()

		local _6 = _M._get_61_2(flow)
		local _7 = _M._get_61_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _6, _7)

		return _M._to_116_0(flow)
	end

	if eventName == "GBPMsg_CommonManitisScare" then
		return _M._to_43_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	return _M._to_117_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 16 then
		return _M._to_111_0(flow)
	end

	if nodeId == 24 then
		return _M._to_110_0(flow)
	end

	if nodeId == 29 then
		return _M._to_88_0(flow)
	end

	if nodeId == 30 then
		return _M._to_29_0(flow)
	end

	if nodeId == 31 then
		return _M._to_30_0(flow)
	end

	if nodeId == 39 then
		return _M._to_91_0(flow)
	end

	if nodeId == 43 then
		return true
	end

	if nodeId == 88 then
		return _M._to_109_0(flow)
	end

	if nodeId == 91 then
		return _M._to_98_0(flow)
	end

	if nodeId == 92 then
		return true
	end

	if nodeId == 98 then
		return _M._to_92_0(flow)
	end

	if nodeId == 109 then
		return true
	end

	if nodeId == 110 then
		return true
	end

	if nodeId == 111 then
		return true
	end

	if nodeId == 113 then
		return true
	end

	if nodeId == 116 then
		return _M._to_113_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_16_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_2_2(flow)
	local _1 = _M._get_2_3(flow)

	return _doBehaviourTail_0(flow, 16, _0, _1, 0, 0, 0, false)
end

function _M._to_24_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_23_2(flow)
	local _1 = _M._get_23_3(flow)

	return _doBehaviourTail_0(flow, 24, _0, _1, 0, 0, 0, false)
end

function _M._to_29_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_27_2(flow)
	local _1 = _M._get_27_3(flow)

	return _doBehaviourTail_0(flow, 29, _0, _1, 0, 2, 0, false)
end

function _M._to_30_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_1(flow, 30, 0, 10310900, 0, "", 5, false, 0)
end

function _M._to_31_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_2(flow, 31, "Laugh", 5)
end

function _M._to_39_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Sleep")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "SneakInGround")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "SneakIdle")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "SneakOutGround")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 9)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(39)

	return true
end

function _M._to_43_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_3(flow, 43, 0, "Behav_Happy", 8, "Laugh", 5, "", false, false, false)
end

function _M._to_88_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_1(flow, 88, 0, 10310000, 0, "", 5, false, 0)
end

function _M._to_91_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_2(flow, 91, "Surprise", 5)
end

function _M._to_92_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_3(flow, 92, 0, "Behav_Angry", 5, "Angry", 5, "", false, false, false)
end

function _M._to_98_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_107_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(98)

	return true
end

function _M._to_109_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_3(flow, 109, 0, "Behav_Happy", 5, "Laugh", 5, "", false, false, false)
end

function _M._to_110_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_3(flow, 110, 0, "IdleSpecial", 5, "Laugh", 5, "", false, false, false)
end

function _M._to_111_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_3(flow, 111, 0, "IdleSpecial", 5, "Laugh", 5, "", false, false, false)
end

function _M._to_113_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_61_2(flow)
	local _1 = _M._get_61_3(flow)

	return _doBehaviourTail_0(flow, 113, _0, _1, 0, 1, 0, false)
end

function _M._to_116_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_2(flow, 116, "Angry", 10)
end

function _M._to_117_0(flow)
	local _3 = _M._get_118_2(flow)
	local _0 = not _3

	if _0 then
		flow:setActive()

		local _6 = _M._get_2_2(flow)
		local _7 = _M._get_2_3(flow)

		_A(flow, "ExitResPointPort", 0, _6, _7, 0, 0)

		return true
	end

	local _4 = _M._get_121_2(flow)
	local _1 = not _4

	if _1 then
		flow:setActive()

		local _8 = _M._get_23_2(flow)
		local _9 = _M._get_23_3(flow)

		_A(flow, "ExitResPointPort", 0, _8, _9, 0, 0)

		return true
	end

	local _5 = _M._get_124_2(flow)
	local _2 = not _5

	if _2 then
		flow:setActive()

		local _10 = _M._get_61_2(flow)
		local _11 = _M._get_61_3(flow)

		_A(flow, "ExitResPointPort", 0, _10, _11, 0, 0)

		return true
	end
end

function _M._get_2_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_2_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_23_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_23_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_27_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_27_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_61_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_61_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_101_2(flow)
	return flow:getCache(101, "__iterItem")
end

function _M._get_101_3(flow)
	local _0 = _C(100, "GetAoiEntityTableByLevel", flow, 0, 30, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(101, "__iterItem", v)

		if _M._get_104_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_104_2(flow)
	local _2 = _M._get_101_2(flow)
	local _3 = _C(102, "GetPuppetData", flow, _2, "petPrototypeId", true, 0)
	local _0 = _3 == 1003100

	if not _0 then
		return false
	end

	local _4 = _M._get_101_2(flow)
	local _5 = _C(105, "GetDistance", flow, _4, 0, false)
	local _1 = _5 <= 2

	if not _1 then
		return false
	end

	return true
end

function _M._get_107_1(flow)
	local _0 = flow:getCache(107, "Puppet10031")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_108_1(flow)

	flow:setCache(107, "Puppet10031", _0)

	return _0
end

function _M._get_108_1(flow)
	local _0 = _M._get_101_3(flow)

	return _C(108, "SelectOneByRandom", flow, _0)
end

function _M._get_118_2(flow)
	local _2 = _M._get_2_2(flow)
	local _0 = _2 == 0

	if not _0 then
		return false
	end

	local _3 = _M._get_2_3(flow)
	local _1 = _3 == 0

	if not _1 then
		return false
	end

	return true
end

function _M._get_121_2(flow)
	local _2 = _M._get_23_2(flow)
	local _0 = _2 == 0

	if not _0 then
		return false
	end

	local _3 = _M._get_23_3(flow)
	local _1 = _3 == 0

	if not _1 then
		return false
	end

	return true
end

function _M._get_124_2(flow)
	local _2 = _M._get_61_2(flow)
	local _0 = _2 == 0

	if not _0 then
		return false
	end

	local _3 = _M._get_61_3(flow)
	local _1 = _3 == 0

	if not _1 then
		return false
	end

	return true
end

return _M
