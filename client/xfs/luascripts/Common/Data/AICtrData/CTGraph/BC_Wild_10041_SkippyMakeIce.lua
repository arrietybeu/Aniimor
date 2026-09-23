-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10041_SkippyMakeIce.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6)
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

local function _doBehaviourTail_1(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8)
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
	if eventName == "LevelMsgTrigger1GO" then
		return _M._to_80_0(flow)
	end

	if eventName == "LevelMsgTrigger2GO" then
		return _M._to_82_0(flow)
	end

	if eventName == "LevelMsgTrigger3GO" then
		return _M._to_78_0(flow)
	end

	if eventName == "LevelMsgTriggerT3GO" then
		return _M._to_112_0(flow)
	end

	if eventName == "LevelMsgTriggerT2GO" then
		return _M._to_110_0(flow)
	end

	if eventName == "LevelMsgTriggerT1GO" then
		return _M._to_108_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 27 then
		return true
	end

	if nodeId == 29 then
		return true
	end

	if nodeId == 45 then
		return true
	end

	if nodeId == 46 then
		return _M._to_45_0(flow)
	end

	if nodeId == 57 then
		return _M._to_27_0(flow)
	end

	if nodeId == 68 then
		return _M._to_29_0(flow)
	end

	if nodeId == 78 then
		return _M._to_76_0(flow)
	end

	if nodeId == 80 then
		return _M._to_36_0(flow)
	end

	if nodeId == 82 then
		return _M._to_55_0(flow)
	end

	if nodeId == 87 then
		return true
	end

	if nodeId == 88 then
		return _M._to_87_0(flow)
	end

	if nodeId == 91 then
		return true
	end

	if nodeId == 96 then
		return _M._to_91_0(flow)
	end

	if nodeId == 98 then
		return true
	end

	if nodeId == 102 then
		return _M._to_98_0(flow)
	end

	if nodeId == 108 then
		return _M._to_85_0(flow)
	end

	if nodeId == 110 then
		return _M._to_95_0(flow)
	end

	if nodeId == 112 then
		return _M._to_101_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_27_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _C(81, "GetActorId", flow, 87006297)

	return _doBehaviourTail_0(flow, 27, 0, 10410230, _0, "Happy", 2.5, false, 0)
end

function _M._to_29_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _C(77, "GetActorId", flow, 87006298)

	return _doBehaviourTail_0(flow, 29, 0, 10410230, _0, "Happy", 2.5, false, 0)
end

function _M._to_36_0(flow)
	flow:setActive()

	local _0 = _C(39, "GetSelfId", flow)

	_A(flow, "StartNpcDialog", 70008276, _0)

	return _M._to_46_0(flow)
end

function _M._to_45_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _C(79, "GetActorId", flow, 87006296)

	return _doBehaviourTail_0(flow, 45, 0, 10410230, _0, "Happy", 2.5, false, 0)
end

function _M._to_46_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 46, 0, "Behav_Alert", 3.03, "", 0, "", false, false, false)
end

function _M._to_55_0(flow)
	flow:setActive()

	local _0 = _C(51, "GetSelfId", flow)

	_A(flow, "StartNpcDialog", 70008277, _0)

	return _M._to_57_0(flow)
end

function _M._to_57_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 57, 0, "Behav_Alert", 3.03, "", 0, "", false, false, false)
end

function _M._to_68_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 68, 0, "Behav_Alert", 3.03, "", 0, "", false, false, false)
end

function _M._to_76_0(flow)
	flow:setActive()

	local _0 = _C(62, "GetSelfId", flow)

	_A(flow, "StartNpcDialog", 70008278, _0)

	return _M._to_68_0(flow)
end

function _M._to_78_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 87006281, 1, nil) then
		flow:setContinue(78)

		return true
	end
end

function _M._to_80_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 87006278, 1, nil) then
		flow:setContinue(80)

		return true
	end
end

function _M._to_82_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 87006280, 1, nil) then
		flow:setContinue(82)

		return true
	end
end

function _M._to_85_0(flow)
	flow:setActive()

	local _0 = _C(86, "GetSelfId", flow)

	_A(flow, "StartNpcDialog", 70008276, _0)

	return _M._to_88_0(flow)
end

function _M._to_87_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _C(104, "GetActorId", flow, 79706186)

	return _doBehaviourTail_0(flow, 87, 0, 10410230, _0, "Happy", 2.5, false, 0)
end

function _M._to_88_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 88, 0, "Behav_Alert", 3.03, "", 0, "", false, false, false)
end

function _M._to_91_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _C(105, "GetActorId", flow, 79781527)

	return _doBehaviourTail_0(flow, 91, 0, 10410230, _0, "Happy", 2.5, false, 0)
end

function _M._to_95_0(flow)
	flow:setActive()

	local _0 = _C(94, "GetSelfId", flow)

	_A(flow, "StartNpcDialog", 70008277, _0)

	return _M._to_96_0(flow)
end

function _M._to_96_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 96, 0, "Behav_Alert", 3.03, "", 0, "", false, false, false)
end

function _M._to_98_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _C(106, "GetActorId", flow, 79781528)

	return _doBehaviourTail_0(flow, 98, 0, 10410230, _0, "Happy", 2.5, false, 0)
end

function _M._to_101_0(flow)
	flow:setActive()

	local _0 = _C(100, "GetSelfId", flow)

	_A(flow, "StartNpcDialog", 70008278, _0)

	return _M._to_102_0(flow)
end

function _M._to_102_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 102, 0, "Behav_Alert", 3.03, "", 0, "", false, false, false)
end

function _M._to_108_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 79680836, 1, nil) then
		flow:setContinue(108)

		return true
	end
end

function _M._to_110_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 79780268, 1, nil) then
		flow:setContinue(110)

		return true
	end
end

function _M._to_112_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 79780294, 1, nil) then
		flow:setContinue(112)

		return true
	end
end

return _M
