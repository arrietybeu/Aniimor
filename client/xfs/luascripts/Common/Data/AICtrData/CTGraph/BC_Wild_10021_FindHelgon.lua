-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10021_FindHelgon.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tTgtId", value0)
	agent:addSubTreeLocalParam("tTargetAtYawDegree", value1)
	agent:addSubTreeLocalParam("tInstant", value2)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_1(flow, nodeId, value0, value1, value2, value3, value4)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tTargetActorId", value0)
	agent:addSubTreeLocalParam("tLeaveDistance", value1)
	agent:addSubTreeLocalParam("tSpeed", value2)
	agent:addSubTreeLocalParam("tSpeedRateType", value3)
	agent:addSubTreeLocalParam("tMaxTime", value4)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_2(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8)
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

local function _doBehaviourTail_3(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value0)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value1)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_4(flow, nodeId, value0)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_5(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tCharacterState", value0)
	agent:addSubTreeLocalParam("tAnimationKey", value1)
	flow:setContinue(nodeId)

	return true
end

function _M.executeTickLodTrigger(flow)
	return _M._to_80_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_89_1(flow)
	local _1 = _M._get_89_2(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 3, 0.5)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 37 then
		return _M._to_63_0(flow)
	end

	if nodeId == 61 then
		return true
	end

	if nodeId == 62 then
		return _M._to_61_0(flow)
	end

	if nodeId == 63 then
		return _M._to_64_0(flow)
	end

	if nodeId == 64 then
		return _M._to_62_0(flow)
	end

	if nodeId == 81 then
		return true
	end

	if nodeId == 92 then
		return true
	end

	if nodeId == 94 then
		return _M._to_110_0(flow)
	end

	if nodeId == 95 then
		return true
	end

	if nodeId == 98 then
		return _M._to_99_0(flow)
	end

	if nodeId == 99 then
		return _M._to_100_0(flow)
	end

	if nodeId == 100 then
		return _M._to_101_0(flow)
	end

	if nodeId == 101 then
		return _M._to_91_0(flow)
	end

	if nodeId == 106 then
		return _M._to_116_0(flow)
	end

	if nodeId == 111 then
		return _M._to_118_0(flow)
	end

	if nodeId == 115 then
		return true
	end

	if nodeId == 116 then
		return _M._to_115_0(flow)
	end

	if nodeId == 118 then
		return _M._to_119_0(flow)
	end

	if nodeId == 119 then
		return true
	end

	if nodeId == 122 then
		return _M._to_123_0(flow)
	end

	if nodeId == 123 then
		return _M._to_124_0(flow)
	end

	if nodeId == 124 then
		return true
	end

	if nodeId == 125 then
		return _M._to_127_0(flow)
	end

	if nodeId == 126 then
		return _M._to_125_0(flow)
	end

	if nodeId == 127 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_37_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_27_1(flow)

	return _doBehaviourTail_0(flow, 37, _0, 0, false)
end

function _M._to_61_0(flow)
	if not _B(flow, "PBT_LeaveTarget") then
		return
	end

	local _0 = _M._get_27_1(flow)

	return _doBehaviourTail_1(flow, 61, _0, 30, 0, 1, 0)
end

function _M._to_62_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_2(flow, 62, 0, "AI_IdleSpecial03", 5, "", 0, "", false, false, false)
end

function _M._to_63_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_3(flow, 63, "Surprise", 2)
end

function _M._to_64_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	return _doBehaviourTail_4(flow, 64, 0.25)
end

function _M._to_80_0(flow)
	local _2 = _M._get_44_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _0 = not _3

	if _0 then
		return _M._to_37_0(flow)
	end

	local _4 = _M._get_76_3(flow)
	local _5 = not _4 or next(_4) == nil
	local _1 = not _5

	if _1 then
		return _M._to_98_0(flow)
	end
end

function _M._to_91_0(flow)
	local _0 = _M._get_86_1(flow)

	if _0 then
		return _M._to_109_0(flow)
	end

	local _2 = _M._get_86_1(flow)
	local _1 = not _2

	if _1 then
		flow:setActive()

		local _3 = _M._get_89_1(flow)
		local _4 = _M._get_89_2(flow)

		_A(flow, "PreJoinResPointPort", 0, _3, _4)

		return _M._to_94_0(flow)
	end
end

function _M._to_92_0(flow)
	if not _B(flow, "PBT_LeaveTarget") then
		return
	end

	local _0 = _M._get_103_1(flow)

	return _doBehaviourTail_1(flow, 92, _0, 30, 0, 1, 0)
end

function _M._to_94_0(flow)
	if not _B(flow, "PBT_MoveToResPointPortInDist") then
		return
	end

	local _0 = _M._get_89_1(flow)
	local _1 = _M._get_89_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tPointId", _0)
	flow.__agent:addSubTreeLocalParam("tPortId", _1)
	flow.__agent:addSubTreeLocalParam("tTimeout", 1000)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tInteractDist", 0)
	flow.__agent:addSubTreeLocalParam("tIgnoreSelfBodySize", true)
	flow.__agent:addSubTreeLocalParam("tIgnorePointBodySize", true)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow:setContinue(94)

	return true
end

function _M._to_95_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "HideStart")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "HideLoop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "HideEnd")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 30)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(95)

	return true
end

function _M._to_98_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_103_1(flow)

	return _doBehaviourTail_0(flow, 98, _0, 0, false)
end

function _M._to_99_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_3(flow, 99, "Surprise", 2)
end

function _M._to_100_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	return _doBehaviourTail_4(flow, 100, 0.25)
end

function _M._to_101_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_2(flow, 101, 0, "AI_IdleSpecial03", 5, "", 0, "", false, false, false)
end

function _M._to_109_0(flow)
	local _1 = _C(107, "RandomInteger", flow, 0, 9)
	local _0 = _1 <= 2

	if _0 then
		return _M._to_122_0(flow)
	end

	return _M._to_92_0(flow)
end

function _M._to_110_0(flow)
	local _1 = _C(112, "RandomInteger", flow, 0, 9)
	local _0 = _1 <= 2

	if _0 then
		return _M._to_126_0(flow)
	end

	return _M._to_95_0(flow)
end

function _M._to_115_0(flow)
	if not _B(flow, "PBT_Behav_Com_MimicryOut") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(115)

	return true
end

function _M._to_116_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	return _doBehaviourTail_4(flow, 116, 30)
end

function _M._to_118_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	return _doBehaviourTail_4(flow, 118, 30)
end

function _M._to_119_0(flow)
	if not _B(flow, "PBT_Behav_Com_MimicryOut") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(119)

	return true
end

function _M._to_122_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	return _doBehaviourTail_5(flow, 122, "MIMICRY", "")
end

function _M._to_123_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	return _doBehaviourTail_4(flow, 123, 30)
end

function _M._to_124_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	return _doBehaviourTail_5(flow, 124, "LOCOMOTION", "")
end

function _M._to_125_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	return _doBehaviourTail_4(flow, 125, 30)
end

function _M._to_126_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	return _doBehaviourTail_5(flow, 126, "MIMICRY", "")
end

function _M._to_127_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	return _doBehaviourTail_5(flow, 127, "LOCOMOTION", "")
end

function _M._get_25_1(flow)
	local _0 = _M._get_44_3(flow)

	return _C(25, "SelectOneByRandom", flow, _0)
end

function _M._get_27_1(flow)
	local _0 = flow:getCache(27, "Puppet10022&10024")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_25_1(flow)

	flow:setCache(27, "Puppet10022&10024", _0)

	return _0
end

function _M._get_39_2(flow)
	local _0 = _M._get_44_2(flow)

	return _C(39, "GetPuppetData", flow, _0, "petPrototypeId", true, 0)
end

function _M._get_44_3(flow)
	local _0 = _C(16, "GetAoiEntityTableByLevel", flow, 0, 30, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(44, "__iterItem", v)

		if _M._get_46_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_44_2(flow)
	return flow:getCache(44, "__iterItem")
end

function _M._get_46_2(flow)
	local _0 = _M._get_77_2(flow)

	if not _0 then
		return false
	end

	local _2 = _M._get_44_2(flow)
	local _3 = _C(20, "GetDistance", flow, _2, 0, false)
	local _1 = _3 <= 8

	if not _1 then
		return false
	end

	return true
end

function _M._get_66_2(flow)
	local _4 = _M._get_76_2(flow)
	local _5 = _C(69, "GetPuppetData", flow, _4, "petPrototypeId", true, 0)
	local _0 = _5 == 1002300

	if not _0 then
		return false
	end

	local _2 = _M._get_76_2(flow)
	local _3 = _C(67, "GetDistance", flow, _2, 0, false)
	local _1 = _3 <= 15

	if not _1 then
		return false
	end

	return true
end

function _M._get_76_2(flow)
	return flow:getCache(76, "__iterItem")
end

function _M._get_76_3(flow)
	local _0 = _C(65, "GetAoiEntityTableByLevel", flow, 0, 30, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(76, "__iterItem", v)

		if _M._get_66_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_77_2(flow)
	local _2 = _M._get_39_2(flow)
	local _0 = _2 == 1002200

	if _0 then
		return true
	end

	local _3 = _M._get_39_2(flow)
	local _1 = _3 == 1002400

	if _1 then
		return true
	end

	return false
end

function _M._get_85_3(flow)
	return _C(85, "GetAoiResPointPortTableByLevel", flow, 0, 10, 10, {
		"10021HidePoint"
	}, nil)
end

function _M._get_86_1(flow)
	local _0 = _M._get_85_3(flow)

	return not _0 or next(_0) == nil
end

function _M._get_87_1(flow)
	local _0 = _M._get_85_3(flow)

	return _C(87, "SelectOneByRandom", flow, _0)
end

function _M._get_88_1(flow)
	local _0 = flow:getCache(88, "resPoint")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_87_1(flow)

	flow:setCache(88, "resPoint", _0)

	return _0
end

function _M._get_89_1(flow)
	local _0 = _M._get_88_1(flow)

	return _C(89, "UnpackResPointPort", flow, _0, 1)
end

function _M._get_89_2(flow)
	local _0 = _M._get_88_1(flow)

	return _C(89, "UnpackResPointPort", flow, _0, 2)
end

function _M._get_102_1(flow)
	local _0 = _M._get_76_3(flow)

	return _C(102, "SelectOneByRandom", flow, _0)
end

function _M._get_103_1(flow)
	local _0 = flow:getCache(103, "Puppet10023")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_102_1(flow)

	flow:setCache(103, "Puppet10023", _0)

	return _0
end

return _M
