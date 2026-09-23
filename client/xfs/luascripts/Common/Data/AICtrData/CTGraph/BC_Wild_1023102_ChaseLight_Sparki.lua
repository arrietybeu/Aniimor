-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_1023102_ChaseLight_Sparki.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value0)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value1)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_1(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8, value9)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tTargetActorId", value0)
	agent:addSubTreeLocalParam("tStopDist", value1)
	agent:addSubTreeLocalParam("tMaxTimeout", value2)
	agent:addSubTreeLocalParam("tFaceTarget", value3)
	agent:addSubTreeLocalParam("tSpeed", value4)
	agent:addSubTreeLocalParam("tMoveUpdateLevel", value5)
	agent:addSubTreeLocalParam("tPathFindType", value6)
	agent:addSubTreeLocalParam("tSpeedRateType", value7)
	agent:addSubTreeLocalParam("tUseAccurateArrive", value8)
	agent:addSubTreeLocalParam("tNoBodySize", value9)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_2(flow, nodeId, value0, value1, value2, value3, value4, value5, value6)
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

local function _doBehaviourTail_3(flow, nodeId, value0)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	flow:setContinue(nodeId)

	return true
end

function _M.executeTickLodTrigger(flow)
	return _M._to_34_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "SetVisionAreaOverride", "visionAreaDefault")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 9 then
		return _M._to_14_0(flow)
	end

	if nodeId == 10 then
		return _M._to_17_0(flow)
	end

	if nodeId == 14 then
		return _M._to_16_0(flow)
	end

	if nodeId == 17 then
		return _M._to_35_0(flow)
	end

	if nodeId == 35 then
		return _M._to_60_0(flow)
	end

	if nodeId == 69 then
		return _M._to_70_0(flow)
	end

	if nodeId == 70 then
		return _M._to_72_0(flow)
	end

	if nodeId == 74 then
		return true
	end

	if nodeId == 84 then
		return _M._to_87_0(flow)
	end

	if nodeId == 87 then
		return _M._to_90_0(flow)
	end

	if nodeId == 94 then
		return _M._to_101_0(flow)
	end

	if nodeId == 98 then
		return _M._to_106_0(flow)
	end

	if nodeId == 106 then
		return _M._to_107_0(flow)
	end

	if nodeId == 107 then
		return _M._to_112_0(flow)
	end

	if nodeId == 109 then
		return _M._to_111_0(flow)
	end

	if nodeId == 110 then
		return _M._to_109_0(flow)
	end

	if nodeId == 111 then
		return true
	end

	if nodeId == 112 then
		return _M._to_110_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 9 then
		return _M._get_11_1(flow)
	end

	if nodeId == 10 then
		return _M._get_11_1(flow)
	end

	if nodeId == 14 then
		return _M._get_11_1(flow)
	end

	if nodeId == 35 then
		return _M._get_24_1(flow)
	end

	if nodeId == 69 then
		return _M._get_24_1(flow)
	end

	if nodeId == 84 then
		return _M._get_88_1(flow)
	end

	if nodeId == 87 then
		return _M._get_88_1(flow)
	end

	if nodeId == 94 then
		return _M._get_88_1(flow)
	end
end

function _M._to_9_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 9)

	if not _1 then
		flow:setActive()
		_C(9, "DoBehaviour", flow, "PBT_ShowEmojiBubble")

		return _doBehaviourTail_0(flow, 9, "Surprise", 1)
	else
		flow:setActiveFail()
	end
end

function _M._to_10_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 10)

	if not _1 then
		flow:setActive()
		_C(10, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_8_1(flow)

		return _doBehaviourTail_1(flow, 10, _1, 2, 5, true, 0, 0, 0, 2, false, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_14_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 14)

	if not _1 then
		flow:setActive()
		_C(14, "DoBehaviour", flow, "PBT_ShowEmojiBubble")

		return _doBehaviourTail_0(flow, 14, "Love", 10)
	else
		flow:setActiveFail()
	end
end

function _M._to_16_0(flow)
	flow:setActive()
	_A(flow, "SetVisionAreaOverride", "visionAreaMid")
	flow:setActive()

	local _0 = _C(57, "GetSelfId", flow)

	_A(flow, "AddEntityTag", _0, "TE_Wild_10231_GetClose")

	return _M._to_10_0(flow)
end

function _M._to_17_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_2(flow, 17, 0, 10600151, 0, "", 5, false, 0)
end

function _M._to_34_0(flow)
	local _2 = _M._get_0_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _0 = not _3

	if _0 then
		return _M._to_9_0(flow)
	end

	local _4 = _M._get_75_3(flow)
	local _5 = not _4 or next(_4) == nil
	local _1 = not _5

	if _1 then
		return _M._to_84_0(flow)
	end
end

function _M._to_35_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 35)

	if not _1 then
		flow:setActive()
		_C(35, "DoBehaviour", flow, "PBT_ShowEmojiBubble")

		return _doBehaviourTail_0(flow, 35, "Love", 1)
	else
		flow:setActiveFail()
	end
end

function _M._to_60_0(flow)
	flow:setActive()

	local _0 = _M._get_8_1(flow)
	local _1 = flow:getMessageContext()

	_1.sourceActorId = flow.__actorId

	flow:sendMessage(_0, "Msg_NeedToScare", _1)

	return _M._to_69_0(flow)
end

function _M._to_69_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 69)

	if not _1 then
		flow:setActive()
		_C(69, "DoBehaviour", flow, "PBT_Com_Node_Wait")

		return _doBehaviourTail_3(flow, 69, 2)
	else
		flow:setActiveFail()
	end
end

function _M._to_70_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_0(flow, 70, "Think", 1)
end

function _M._to_72_0(flow)
	flow:setActive()

	local _0 = _C(73, "GetSelfId", flow)

	_A(flow, "RemoveEntityTag", _0, "TE_Wild_10231_GetClose")

	return _M._to_74_0(flow)
end

function _M._to_74_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_2(flow, 74, 0, 10600152, 0, "", 5, false, 0)
end

function _M._to_84_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 84)

	if not _1 then
		flow:setActive()
		_C(84, "DoBehaviour", flow, "PBT_ShowEmojiBubble")

		return _doBehaviourTail_0(flow, 84, "Surprise", 1)
	else
		flow:setActiveFail()
	end
end

function _M._to_87_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 87)

	if not _1 then
		flow:setActive()
		_C(87, "DoBehaviour", flow, "PBT_ShowEmojiBubble")

		return _doBehaviourTail_0(flow, 87, "Love", 10)
	else
		flow:setActiveFail()
	end
end

function _M._to_90_0(flow)
	flow:setActive()
	_A(flow, "SetVisionAreaOverride", "visionAreaMid")

	return _M._to_94_0(flow)
end

function _M._to_94_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 94)

	if not _1 then
		flow:setActive()
		_C(94, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_83_1(flow)

		return _doBehaviourTail_1(flow, 94, _1, 1, 5, true, 0, 0, 0, 2, false, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_97_0(flow)
	flow:addTimer(0, _M, "_to_102_0", flow)

	return _M._to_100_0(flow)
end

function _M._to_98_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	return _doBehaviourTail_2(flow, 98, 0, 10600151, 0, "", 5, false, 0)
end

function _M._to_100_0(flow)
	flow:addTimer(0, _M, "_to_105_0", flow)

	return _M._to_98_0(flow)
end

function _M._to_101_0(flow)
	flow:addTimer(0, _M, "_to_103_0", flow)

	return _M._to_97_0(flow)
end

function _M._to_102_0(flow)
	flow:setActive()

	local _0 = _C(95, "GetSelfId", flow)

	_A(flow, "SendMessageToTrigger", _0, 1023101)

	return true
end

function _M._to_103_0(flow)
	local _2 = _M._get_92_2(flow)
	local _0 = _2 == 1014200

	if _0 then
		flow:setActive()

		local _1 = _C(96, "GetSelfId", flow)

		_A(flow, "SendMessageToTrigger", _1, 1014202)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_105_0(flow)
	local _2 = _M._get_92_2(flow)
	local _0 = _2 == 1033100

	if _0 then
		flow:setActive()

		local _1 = _C(104, "GetSelfId", flow)

		_A(flow, "SendMessageToTrigger", _1, 1033102)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_106_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_0(flow, 106, "Love", 1)
end

function _M._to_107_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	return _doBehaviourTail_3(flow, 107, 1)
end

function _M._to_109_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_0(flow, 109, "Cry", 10)
end

function _M._to_110_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	return _doBehaviourTail_3(flow, 110, 0.8)
end

function _M._to_111_0(flow)
	if not _B(flow, "PBT_Wild_10231_Leave") then
		return
	end

	local _0 = _M._get_83_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tLeaveDistance", 60)
	flow.__agent:addSubTreeLocalParam("tSpeed", 6)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
	flow.__agent:addSubTreeLocalParam("tMaxTime", 5)
	flow:setContinue(111)

	return true
end

function _M._to_112_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_0(flow, 112, "Surprise", 0.8)
end

function _M._get_0_2(flow)
	return flow:getCache(0, "__iterItem")
end

function _M._get_0_3(flow)
	local _0 = _C(4, "GetAoiEntityTableByLevel", flow, 0, 30, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(0, "__iterItem", v)

		if _M._get_1_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_1_2(flow)
	local _0 = _M._get_0_2(flow)

	return _C(1, "HasEntityTag", flow, _0, "TE_Wild_Light")
end

function _M._get_3_3(flow)
	local _0 = flow:getCache(7, "__iterItem")

	return _C(3, "GetDistance", flow, _0, 0, false)
end

function _M._get_7_2(flow)
	local _0 = _M._get_0_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(7, "__iterItem", v)

		_1 = _M._get_3_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_8_1(flow)
	local _0 = flow:getCache(8, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_7_2(flow)

	flow:setCache(8, "1", _0)

	return _0
end

function _M._get_11_1(flow)
	local _0 = _M._get_15_2(flow)

	return not _0
end

function _M._get_15_2(flow)
	local _3 = _M._get_8_1(flow)
	local _0 = _C(13, "CheckEntityExist", flow, _3)

	if not _0 then
		return false
	end

	local _2 = _M._get_8_1(flow)
	local _1 = _C(12, "HasEntityTag", flow, _2, "TE_Wild_Light")

	if not _1 then
		return false
	end

	return true
end

function _M._get_22_2(flow)
	local _4 = _M._get_8_1(flow)
	local _0 = _C(25, "CheckEntityExist", flow, _4)

	if not _0 then
		return false
	end

	local _3 = _M._get_8_1(flow)
	local _2 = _C(23, "GetPuppetData", flow, _3, "id", true, 0)
	local _1 = _2 == 11033103

	if not _1 then
		return false
	end

	return true
end

function _M._get_24_1(flow)
	local _0 = _M._get_22_2(flow)

	return not _0
end

function _M._get_75_2(flow)
	return flow:getCache(75, "__iterItem")
end

function _M._get_75_3(flow)
	local _0 = _C(79, "GetAoiEntityTableByLevel", flow, 0, 30, 4)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(75, "__iterItem", v)

		if _M._get_76_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_76_2(flow)
	local _0 = _M._get_75_2(flow)

	return _C(76, "HasEntityTag", flow, _0, "TE_Par_Light")
end

function _M._get_78_3(flow)
	local _0 = flow:getCache(82, "__iterItem")

	return _C(78, "GetDistance", flow, _0, 0, false)
end

function _M._get_82_2(flow)
	local _0 = _M._get_75_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(82, "__iterItem", v)

		_1 = _M._get_78_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_83_1(flow)
	local _0 = flow:getCache(83, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_82_2(flow)

	flow:setCache(83, "1", _0)

	return _0
end

function _M._get_88_1(flow)
	local _0 = _M._get_89_2(flow)

	return not _0
end

function _M._get_89_2(flow)
	local _2 = _M._get_83_1(flow)
	local _0 = _C(85, "CheckEntityExist", flow, _2)

	if not _0 then
		return false
	end

	local _3 = _M._get_83_1(flow)
	local _1 = _C(86, "HasEntityTag", flow, _3, "TE_Par_Light")

	if not _1 then
		return false
	end

	return true
end

function _M._get_92_2(flow)
	local _0 = _M._get_83_1(flow)

	return _C(92, "GetPetData", flow, _0, "baseFormPet", true, 0)
end

return _M
