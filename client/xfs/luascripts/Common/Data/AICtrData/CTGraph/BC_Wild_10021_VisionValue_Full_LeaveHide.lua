-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10021_VisionValue_Full_LeaveHide.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4)
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

local function _doBehaviourTail_1(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tNeedPlayAnim", value0)
	agent:addSubTreeLocalParam("tJumpDistance", value1)
	flow:setContinue(nodeId)

	return true
end

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "VisionValue_Full" then
		flow:setActive()
		_A(flow, "AddAITag", 0, "TA_VisionFull")
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "TA_VisionAlert")
		flow:setActive()

		local _0 = _C(90, "GetSelfId", flow)

		_A(flow, "HideEmojiOnTarget", _0, "")

		return _M._to_113_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "RemoveAITag", 0, "TA_VisionFull")
	flow:setActive()

	local _0 = _M._get_125_1(flow)

	_A(flow, "RemoveEntityTag", _0, "TE_Env_BeUsed")
	flow:setActive()

	local _1 = _M._get_96_1(flow)
	local _2 = _M._get_96_2(flow)

	_A(flow, "ExitResPointPort", 0, _1, _2, 3, 0.5)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 104 then
		return _M._to_146_0(flow)
	end

	if nodeId == 105 then
		return true
	end

	if nodeId == 112 then
		return true
	end

	if nodeId == 126 then
		return _M._to_157_0(flow)
	end

	if nodeId == 127 then
		return _M._to_192_0(flow)
	end

	if nodeId == 147 then
		return true
	end

	if nodeId == 151 then
		return true
	end

	if nodeId == 152 then
		return true
	end

	if nodeId == 155 then
		return true
	end

	if nodeId == 188 then
		return true
	end

	if nodeId == 193 then
		return _M._to_194_0(flow)
	end

	if nodeId == 194 then
		return _M._to_195_0(flow)
	end

	if nodeId == 195 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 126 then
		return _M._get_158_1(flow)
	end

	if nodeId == 193 then
		return _M._get_186_1(flow)
	end
end

function _M._to_104_0(flow)
	if not _B(flow, "PBT_MoveToResPointPortInDist") then
		return
	end

	local _0 = _M._get_96_1(flow)
	local _1 = _M._get_96_2(flow)

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
	flow:setContinue(104)

	return true
end

function _M._to_105_0(flow)
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
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 10)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(105)

	return true
end

function _M._to_112_0(flow)
	if not _B(flow, "PBT_LeaveTarget") then
		return
	end

	local _0 = _M._get_85_2(flow)

	return _doBehaviourTail_0(flow, 112, _0, 30, 0, 1, 0)
end

function _M._to_113_0(flow)
	local _8 = _M._get_85_2(flow)
	local _9 = _C(141, "GetDistance", flow, _8, 0, false)
	local _0 = _9 <= 3

	if _0 then
		return _M._to_156_0(flow)
	end

	local _1 = _M._get_132_2(flow)

	if _1 then
		return _M._to_150_0(flow)
	end

	local _4 = _M._get_118_3(flow)
	local _5 = not _4 or next(_4) == nil
	local _2 = not _5

	if _2 then
		return _M._to_126_0(flow)
	end

	local _7 = _M._get_94_3(flow)
	local _6 = not _7 or next(_7) == nil
	local _3 = not _6

	if _3 then
		flow:setActive()

		local _10 = _M._get_96_1(flow)
		local _11 = _M._get_96_2(flow)

		_A(flow, "PreJoinResPointPort", 0, _10, _11)

		return _M._to_104_0(flow)
	end
end

function _M._to_126_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 126)

	if not _1 then
		flow:setActive()
		_C(126, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_125_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 2)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 15)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 0)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(126)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_127_0(flow)
	if not _B(flow, "PBT_Node_Com_SwitchToHideMimicryIn") then
		return
	end

	local _0 = _M._get_128_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetPos", _0)
	flow:setContinue(127)

	return true
end

function _M._to_146_0(flow)
	local _1 = _M._get_85_2(flow)
	local _2 = _C(144, "GetDistance", flow, _1, 0, false)
	local _0 = _2 <= 12

	if _0 then
		return _M._to_147_0(flow)
	end

	return _M._to_105_0(flow)
end

function _M._to_147_0(flow)
	if not _B(flow, "PBT_Behav_Com_MimicryIn") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(147)

	return true
end

function _M._to_150_0(flow)
	local _1 = _C(148, "RandomInteger", flow, 0, 9)
	local _0 = _1 <= 6

	if _0 then
		return _M._to_151_0(flow)
	end

	return _M._to_112_0(flow)
end

function _M._to_151_0(flow)
	if not _B(flow, "PBT_Behav_Com_MimicryIn") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(151)

	return true
end

function _M._to_152_0(flow)
	if not _B(flow, "PBT_LeaveTarget") then
		return
	end

	local _0 = _M._get_85_2(flow)

	return _doBehaviourTail_0(flow, 152, _0, 30, 0, 1, 0)
end

function _M._to_155_0(flow)
	if not _B(flow, "PBT_Behav_Com_MimicryIn") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(155)

	return true
end

function _M._to_156_0(flow)
	local _1 = _C(153, "RandomInteger", flow, 0, 9)
	local _0 = _1 <= 2

	if _0 then
		return _M._to_155_0(flow)
	end

	return _M._to_152_0(flow)
end

function _M._to_157_0(flow)
	flow:setActive()

	local _0 = _M._get_125_1(flow)

	_A(flow, "AddEntityTag", _0, "TE_Env_BeUsed")

	return _M._to_127_0(flow)
end

function _M._to_188_0(flow)
	if not _B(flow, "PBT_Node_Com_SwitchToHideMimicryOut") then
		return
	end

	return _doBehaviourTail_1(flow, 188, false, 0)
end

function _M._to_192_0(flow)
	local _0 = _M._get_186_1(flow)

	if _0 then
		flow:setActive()

		local _3 = _C(190, "GetSelfId", flow)

		_A(flow, "PlayEffectOnTarget", _3, "Eff_Common_Behav_Doubt", 2)

		return _M._to_188_0(flow)
	end

	local _2 = _M._get_186_1(flow)
	local _1 = not _2

	if _1 then
		return _M._to_193_0(flow)
	end
end

function _M._to_193_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 193)

	if not _1 then
		flow:setActive()
		_C(193, "DoBehaviour", flow, "PBT_Com_Node_Wait")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 15)
		flow:setContinue(193)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_194_0(flow)
	if not _B(flow, "PBT_Node_Com_SwitchToHideMimicryOut") then
		return
	end

	return _doBehaviourTail_1(flow, 194, true, 3)
end

function _M._to_195_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "AI_IdleSpecial01")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", true)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(195)

	return true
end

function _M._get_85_2(flow)
	return flow:getContextValue("sensorTgtId")
end

function _M._get_94_3(flow)
	return _C(94, "GetAoiResPointPortTableByLevel", flow, 0, 30, 10, {
		"10021HidePoint"
	}, nil)
end

function _M._get_95_1(flow)
	local _0 = _M._get_94_3(flow)

	return _C(95, "SelectOneByRandom", flow, _0)
end

function _M._get_96_2(flow)
	local _0 = _M._get_110_1(flow)

	return _C(96, "UnpackResPointPort", flow, _0, 2)
end

function _M._get_96_1(flow)
	local _0 = _M._get_110_1(flow)

	return _C(96, "UnpackResPointPort", flow, _0, 1)
end

function _M._get_110_1(flow)
	local _0 = flow:getCache(110, "resPoint")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_95_1(flow)

	flow:setCache(110, "resPoint", _0)

	return _0
end

function _M._get_118_3(flow)
	local _0 = _C(117, "GetAoiEntityTableByLevel", flow, 0, 10, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(118, "__iterItem", v)

		if _M._get_122_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_118_2(flow)
	return flow:getCache(118, "__iterItem")
end

function _M._get_122_2(flow)
	local _2 = _M._get_118_2(flow)
	local _0 = _C(121, "HasEntityTag", flow, _2, "TE_Env_FallenLeaves")

	if not _0 then
		return false
	end

	local _4 = _M._get_118_2(flow)
	local _3 = _C(159, "HasEntityTag", flow, _4, "TE_Env_BeUsed")
	local _1 = not _3

	if not _1 then
		return false
	end

	return true
end

function _M._get_124_1(flow)
	local _0 = _M._get_118_3(flow)

	return _C(124, "SelectOneByRandom", flow, _0)
end

function _M._get_125_1(flow)
	local _0 = flow:getCache(125, "FallenLeaves")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_124_1(flow)

	flow:setCache(125, "FallenLeaves", _0)

	return _0
end

function _M._get_128_1(flow)
	local _0 = _M._get_125_1(flow)

	return _C(128, "GetEntPosition", flow, _0)
end

function _M._get_132_2(flow)
	local _2 = _M._get_94_3(flow)
	local _0 = not _2 or next(_2) == nil

	if not _0 then
		return false
	end

	local _3 = _M._get_118_3(flow)
	local _1 = not _3 or next(_3) == nil

	if not _1 then
		return false
	end

	return true
end

function _M._get_158_1(flow)
	local _0 = _M._get_124_1(flow)

	return _C(158, "CheckHasEntityTag", flow, _0, "TE_Env_BeUsed")
end

function _M._get_180_2(flow)
	return flow:getCache(180, "__iterItem")
end

function _M._get_180_3(flow)
	local _0 = _C(179, "GetAoiEntityTableByLevel", flow, 0, 10, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(180, "__iterItem", v)

		if _M._get_181_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_181_2(flow)
	local _2 = _M._get_180_2(flow)
	local _0 = _C(182, "HasEntityTag", flow, _2, "TE_Env_FallenLeaves")

	if not _0 then
		return false
	end

	local _3 = _M._get_180_2(flow)
	local _4 = _C(183, "GetDistance", flow, _3, 0, false)
	local _1 = _4 <= 2

	if not _1 then
		return false
	end

	return true
end

function _M._get_186_1(flow)
	local _0 = _M._get_180_3(flow)

	return not _0 or next(_0) == nil
end

return _M
