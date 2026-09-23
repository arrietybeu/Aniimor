-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10021_VisionValue_Full_Leave_Overload_FindHelgon.lua

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

local function _doBehaviourTail_2(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tNeedPlayAnim", value0)
	agent:addSubTreeLocalParam("tJumpDistance", value1)
	flow:setContinue(nodeId)

	return true
end

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "VisionValue_Full" then
		return _M._to_87_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "RemoveAITag", 0, "TA_VisionFull")
	flow:setActive()

	local _0 = _M._get_176_1(flow)

	_A(flow, "RemoveEntityTag", _0, "TE_Env_BeUsed")
	flow:setActive()

	local _1 = _M._get_145_1(flow)
	local _2 = _M._get_145_2(flow)

	_A(flow, "ExitResPointPort", 0, _1, _2, 3, 0.5)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 51 then
		return true
	end

	if nodeId == 58 then
		return _M._to_5_0(flow)
	end

	if nodeId == 59 then
		return _M._to_63_0(flow)
	end

	if nodeId == 62 then
		return _M._to_60_0(flow)
	end

	if nodeId == 136 then
		return true
	end

	if nodeId == 137 then
		return _M._to_139_0(flow)
	end

	if nodeId == 152 then
		return _M._to_178_0(flow)
	end

	if nodeId == 156 then
		return true
	end

	if nodeId == 157 then
		return true
	end

	if nodeId == 160 then
		return true
	end

	if nodeId == 163 then
		return true
	end

	if nodeId == 164 then
		return true
	end

	if nodeId == 181 then
		return _M._to_199_0(flow)
	end

	if nodeId == 196 then
		return true
	end

	if nodeId == 200 then
		return _M._to_201_0(flow)
	end

	if nodeId == 201 then
		return _M._to_202_0(flow)
	end

	if nodeId == 202 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 137 then
		return _M._get_183_1(flow)
	end

	if nodeId == 200 then
		return _M._get_194_1(flow)
	end
end

function _M._to_5_0(flow)
	flow:setActive()

	local _0 = _C(6, "GetSelfId", flow)

	_A(flow, "HideEmojiOnTarget", _0, "")

	return _M._to_51_0(flow)
end

function _M._to_51_0(flow)
	if not _B(flow, "PBT_LeaveTarget") then
		return
	end

	return _doBehaviourTail_0(flow, 51, 0, 30, 0, 1, 0)
end

function _M._to_58_0(flow)
	flow:setActive()

	local _0 = flow:getSubFlow("BCS_Common_VisionFullTag")

	if _0:executeSubFlow() then
		flow:setContinue(58)

		if _0:isFinish() then
			return flow:executeContinue()
		end

		return true
	end
end

function _M._to_59_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 59, 0, "", 5, "HideStart", "HideLoop", "HideEnd", 10, "", false, false)
end

function _M._to_60_0(flow)
	flow:setActive()

	local _0 = _C(61, "GetSelfId", flow)

	_A(flow, "HideEmojiOnTarget", _0, "")

	return _M._to_59_0(flow)
end

function _M._to_62_0(flow)
	flow:setActive()

	local _0 = flow:getSubFlow("BCS_Common_VisionFullTag")

	if _0:executeSubFlow() then
		flow:setContinue(62)

		if _0:isFinish() then
			return flow:executeContinue()
		end

		return true
	end
end

function _M._to_63_0(flow)
	flow:setActive()
	_A(flow, "RemoveAITag", 0, "TA_VisionFull")

	return true
end

function _M._to_87_0(flow)
	local _0 = _M._get_85_4(flow)

	if _0 then
		return _M._to_171_0(flow)
	end
end

function _M._to_136_0(flow)
	if not _B(flow, "PBT_LeaveTarget") then
		return
	end

	local _0 = _M._get_56_2(flow)

	return _doBehaviourTail_0(flow, 136, _0, 30, 0, 1, 0)
end

function _M._to_137_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 137)

	if not _1 then
		flow:setActive()
		_C(137, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_176_1(flow)

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
		flow:setContinue(137)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_139_0(flow)
	flow:setActive()

	local _0 = _M._get_176_1(flow)

	_A(flow, "AddEntityTag", _0, "TE_Env_BeUsed")

	return _M._to_181_0(flow)
end

function _M._to_152_0(flow)
	if not _B(flow, "PBT_MoveToResPointPortInDist") then
		return
	end

	local _0 = _M._get_145_1(flow)
	local _1 = _M._get_145_2(flow)

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
	flow:setContinue(152)

	return true
end

function _M._to_156_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 156, 0, "", 5, "HideStart", "HideLoop", "HideEnd", 10, "", false, false)
end

function _M._to_157_0(flow)
	if not _B(flow, "PBT_Behav_Com_MimicryIn") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(157)

	return true
end

function _M._to_160_0(flow)
	if not _B(flow, "PBT_Behav_Com_MimicryIn") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(160)

	return true
end

function _M._to_163_0(flow)
	if not _B(flow, "PBT_Behav_Com_MimicryIn") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(163)

	return true
end

function _M._to_164_0(flow)
	if not _B(flow, "PBT_LeaveTarget") then
		return
	end

	local _0 = _M._get_56_2(flow)

	return _doBehaviourTail_0(flow, 164, _0, 30, 0, 1, 0)
end

function _M._to_171_0(flow)
	local _8 = _M._get_56_2(flow)
	local _9 = _C(146, "GetDistance", flow, _8, 0, false)
	local _0 = _9 <= 3

	if _0 then
		return _M._to_180_0(flow)
	end

	local _1 = _M._get_130_2(flow)

	if _1 then
		return _M._to_179_0(flow)
	end

	local _4 = _M._get_172_3(flow)
	local _5 = not _4 or next(_4) == nil
	local _2 = not _5

	if _2 then
		return _M._to_137_0(flow)
	end

	local _7 = _M._get_166_3(flow)
	local _6 = not _7 or next(_7) == nil
	local _3 = not _6

	if _3 then
		flow:setActive()

		local _10 = _M._get_145_1(flow)
		local _11 = _M._get_145_2(flow)

		_A(flow, "PreJoinResPointPort", 0, _10, _11)

		return _M._to_152_0(flow)
	end
end

function _M._to_178_0(flow)
	local _1 = _M._get_56_2(flow)
	local _2 = _C(154, "GetDistance", flow, _1, 0, false)
	local _0 = _2 <= 12

	if _0 then
		return _M._to_157_0(flow)
	end

	return _M._to_156_0(flow)
end

function _M._to_179_0(flow)
	local _1 = _C(158, "RandomInteger", flow, 0, 9)
	local _0 = _1 <= 6

	if _0 then
		return _M._to_160_0(flow)
	end

	return _M._to_136_0(flow)
end

function _M._to_180_0(flow)
	local _1 = _C(161, "RandomInteger", flow, 0, 9)
	local _0 = _1 <= 2

	if _0 then
		return _M._to_163_0(flow)
	end

	return _M._to_164_0(flow)
end

function _M._to_181_0(flow)
	if not _B(flow, "PBT_Node_Com_SwitchToHideMimicryIn") then
		return
	end

	local _0 = _M._get_177_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetPos", _0)
	flow:setContinue(181)

	return true
end

function _M._to_196_0(flow)
	if not _B(flow, "PBT_Node_Com_SwitchToHideMimicryOut") then
		return
	end

	return _doBehaviourTail_2(flow, 196, false, 0)
end

function _M._to_199_0(flow)
	local _0 = _M._get_194_1(flow)

	if _0 then
		flow:setActive()

		local _3 = _C(198, "GetSelfId", flow)

		_A(flow, "PlayEffectOnTarget", _3, "Eff_Common_Behav_Doubt", 2)

		return _M._to_196_0(flow)
	end

	local _2 = _M._get_194_1(flow)
	local _1 = not _2

	if _1 then
		return _M._to_200_0(flow)
	end
end

function _M._to_200_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 200)

	if not _1 then
		flow:setActive()
		_C(200, "DoBehaviour", flow, "PBT_Com_Node_Wait")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 15)
		flow:setContinue(200)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_201_0(flow)
	if not _B(flow, "PBT_Node_Com_SwitchToHideMimicryOut") then
		return
	end

	return _doBehaviourTail_2(flow, 201, true, 3)
end

function _M._to_202_0(flow)
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
	flow:setContinue(202)

	return true
end

function _M._get_37_2(flow)
	local _1 = _C(38, "GetControllingPetActorId", flow, 0)
	local _0 = _C(39, "GetPetData", flow, _1, "petPrototypeId", true, 0)

	return _0 == 1002300
end

function _M._get_48_2(flow)
	local _0 = _C(47, "GetControllingPetActorId", flow, 0)

	return _C(48, "GetPetData", flow, _0, "petPrototypeId", true, 0)
end

function _M._get_50_2(flow)
	local _2 = _M._get_48_2(flow)
	local _0 = _2 == 1002400

	if _0 then
		return true
	end

	local _3 = _M._get_48_2(flow)
	local _1 = _3 == 1002200

	if _1 then
		return true
	end

	return false
end

function _M._get_56_2(flow)
	return flow:getContextValue("sensorTgtId")
end

function _M._get_83_2(flow)
	local _1 = _M._get_56_2(flow)
	local _0 = _C(82, "GetControllingPetActorId", flow, _1)

	return _C(83, "GetPetData", flow, _0, "petPrototypeId", true, 0)
end

function _M._get_85_4(flow)
	local _4 = _M._get_83_2(flow)
	local _0 = _4 == 1002400

	if _0 then
		return true
	end

	local _5 = _M._get_83_2(flow)
	local _1 = _5 == 1002200

	if _1 then
		return true
	end

	local _6 = _M._get_83_2(flow)
	local _2 = _6 == 1002300

	if _2 then
		return true
	end

	local _7 = _M._get_83_2(flow)
	local _3 = _7 == 1002500

	if _3 then
		return true
	end

	return false
end

function _M._get_130_2(flow)
	local _2 = _M._get_166_3(flow)
	local _0 = not _2 or next(_2) == nil

	if not _0 then
		return false
	end

	local _3 = _M._get_172_3(flow)
	local _1 = not _3 or next(_3) == nil

	if not _1 then
		return false
	end

	return true
end

function _M._get_143_1(flow)
	local _0 = _M._get_166_3(flow)

	return _C(143, "SelectOneByRandom", flow, _0)
end

function _M._get_144_1(flow)
	local _0 = flow:getCache(144, "resPoint")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_143_1(flow)

	flow:setCache(144, "resPoint", _0)

	return _0
end

function _M._get_145_1(flow)
	local _0 = _M._get_144_1(flow)

	return _C(145, "UnpackResPointPort", flow, _0, 1)
end

function _M._get_145_2(flow)
	local _0 = _M._get_144_1(flow)

	return _C(145, "UnpackResPointPort", flow, _0, 2)
end

function _M._get_149_2(flow)
	local _2 = _M._get_172_2(flow)
	local _0 = _C(148, "HasEntityTag", flow, _2, "TE_Env_FallenLeaves")

	if not _0 then
		return false
	end

	local _4 = _M._get_172_2(flow)
	local _3 = _C(184, "HasEntityTag", flow, _4, "TE_Env_BeUsed")
	local _1 = not _3

	if not _1 then
		return false
	end

	return true
end

function _M._get_166_3(flow)
	return _C(166, "GetAoiResPointPortTableByLevel", flow, 0, 30, 10, {
		"10021HidePoint"
	}, nil)
end

function _M._get_172_2(flow)
	return flow:getCache(172, "__iterItem")
end

function _M._get_172_3(flow)
	local _0 = _C(173, "GetAoiEntityTableByLevel", flow, 0, 10, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(172, "__iterItem", v)

		if _M._get_149_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_175_1(flow)
	local _0 = _M._get_172_3(flow)

	return _C(175, "SelectOneByRandom", flow, _0)
end

function _M._get_176_1(flow)
	local _0 = flow:getCache(176, "FallenLeaves")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_175_1(flow)

	flow:setCache(176, "FallenLeaves", _0)

	return _0
end

function _M._get_177_1(flow)
	local _0 = _M._get_176_1(flow)

	return _C(177, "GetEntPosition", flow, _0)
end

function _M._get_183_1(flow)
	local _0 = _M._get_175_1(flow)

	return _C(183, "CheckHasEntityTag", flow, _0, "TE_Env_BeUsed")
end

function _M._get_188_2(flow)
	return flow:getCache(188, "__iterItem")
end

function _M._get_188_3(flow)
	local _0 = _C(187, "GetAoiEntityTableByLevel", flow, 0, 10, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(188, "__iterItem", v)

		if _M._get_189_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_189_2(flow)
	local _2 = _M._get_188_2(flow)
	local _0 = _C(190, "HasEntityTag", flow, _2, "TE_Env_FallenLeaves")

	if not _0 then
		return false
	end

	local _3 = _M._get_188_2(flow)
	local _4 = _C(191, "GetDistance", flow, _3, 0, false)
	local _1 = _4 <= 2

	if not _1 then
		return false
	end

	return true
end

function _M._get_194_1(flow)
	local _0 = _M._get_188_3(flow)

	return not _0 or next(_0) == nil
end

return _M
