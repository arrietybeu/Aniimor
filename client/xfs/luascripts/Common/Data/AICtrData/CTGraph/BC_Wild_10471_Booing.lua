-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10471_Booing.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8, value9)
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

local function _doBehaviourTail_1(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("firstDialogueId", value0)
	agent:addSubTreeLocalParam("lastDialogueId", value1)
	flow:setContinue(nodeId)

	return true
end

function _M.executeTickLodTrigger(flow)
	return _M._to_34_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 2 then
		return true
	end

	if nodeId == 27 then
		return true
	end

	if nodeId == 28 then
		return _M._to_22_0(flow)
	end

	if nodeId == 34 then
		return _M._to_28_0(flow)
	end

	if nodeId == 36 then
		return _M._to_41_0(flow)
	end

	if nodeId == 38 then
		return _M._to_43_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 2 then
		return _M._get_35_1(flow)
	end

	if nodeId == 27 then
		return _M._get_35_1(flow)
	end

	if nodeId == 28 then
		return _M._get_35_1(flow)
	end

	if nodeId == 34 then
		return _M._get_35_1(flow)
	end
end

function _M._to_2_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 2)

	if not _1 then
		flow:setActive()
		_C(2, "DoBehaviour", flow, "PBT_CustomLoopAnimation")

		return _doBehaviourTail_0(flow, 2, 0, "Happy", 5, "Behav_HappyStart", "Behav_HappyLoop", "Behav_HappyEnd", 9999, "", true, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_22_0(flow)
	local _0 = _M._get_25_2(flow)

	if _0 then
		return _M._to_36_0(flow)
	end

	local _2 = _M._get_25_2(flow)
	local _1 = not _2

	if _1 then
		return _M._to_38_0(flow)
	end
end

function _M._to_27_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 27)

	if not _1 then
		flow:setActive()
		_C(27, "DoBehaviour", flow, "PBT_CustomLoopAnimation")

		return _doBehaviourTail_0(flow, 27, 0, "Happy", 5, "Behav_LoveStart", "Behav_LoveLoop", "Behav_LoveEnd", 9999, "", true, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_28_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_33_2(flow)
	local _1 = _M.checkInterrupt(flow, 28)

	if _0 and not _1 then
		flow:setActive()
		_C(28, "DoBehaviour", flow, "PBT_TurnToTargetAtYaw")

		local _2 = _M._get_13_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTgtId", _2)
		flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
		flow.__agent:addSubTreeLocalParam("tInstant", false)
		flow:setContinue(28)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_34_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_33_2(flow)
	local _1 = _M.checkInterrupt(flow, 34)

	if _0 and not _1 then
		flow:setActive()
		_C(34, "DoBehaviour", flow, "PBT_CustomAnimation")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "SprintStop")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 1.75)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Surprise")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 1.75)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
		flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
		flow:setContinue(34)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_36_0(flow)
	if not _B(flow, "PBT_Wild_10501_DreamDialogue") then
		return
	end

	return _doBehaviourTail_1(flow, 36, 70008749, 70008753)
end

function _M._to_38_0(flow)
	if not _B(flow, "PBT_Wild_10501_DreamDialogue") then
		return
	end

	return _doBehaviourTail_1(flow, 38, 70008749, 70008753)
end

function _M._to_40_0(flow)
	flow:setActive()
	_A(flow, "SendMessageToTrigger", 0, 1047101)

	return true
end

function _M._to_41_0(flow)
	flow:addTimer(1, _M, "_to_40_0", flow)

	return _M._to_2_0(flow)
end

function _M._to_42_0(flow)
	flow:setActive()
	_A(flow, "SendMessageToTrigger", 0, 1047101)

	return true
end

function _M._to_43_0(flow)
	flow:addTimer(1, _M, "_to_42_0", flow)

	return _M._to_27_0(flow)
end

function _M._get_3_2(flow)
	return flow:getCache(3, "__iterItem")
end

function _M._get_3_3(flow)
	local _0 = _C(9, "GetAoiEntityTableByLevel", flow, 0, 30, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(3, "__iterItem", v)

		if _M._get_4_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_4_2(flow)
	local _0 = _M._get_3_2(flow)

	return _C(4, "HasEntityTag", flow, _0, "TE_Par_IsInCombat")
end

function _M._get_8_3(flow)
	local _0 = flow:getCache(13, "__iterItem")

	return _C(8, "GetDistance", flow, _0, 0, false)
end

function _M._get_13_2(flow)
	local _0 = _M._get_3_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(13, "__iterItem", v)

		_1 = _M._get_8_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_25_2(flow)
	local _0 = _C(23, "RandomInteger", flow, 1, 2)

	return _0 < 2
end

function _M._get_33_2(flow)
	local _2 = _M._get_3_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _0 = not _3

	if not _0 then
		return false
	end

	local _4 = _M._get_13_2(flow)
	local _5 = _C(31, "GetDistance", flow, _4, 0, false)
	local _1 = _5 <= 30

	if not _1 then
		return false
	end

	return true
end

function _M._get_35_1(flow)
	local _0 = _M._get_33_2(flow)

	return not _0
end

return _M
