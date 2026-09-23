-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_Trampled.lua

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

function _M.executeTickLodTrigger(flow)
	return _M._to_13_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 13 then
		return _M._to_25_0(flow)
	end

	if nodeId == 25 then
		return _M._to_20_0(flow)
	end

	if nodeId == 26 then
		return _M._to_47_0(flow)
	end

	if nodeId == 47 then
		return _M._to_48_0(flow)
	end

	if nodeId == 48 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_13_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_15_1(flow)

	if _0 then
		flow:setActive()
		_C(13, "DoBehaviour", flow, "PBT_SwitchState")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tCharacterState", "LOCOMOTION")
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
		flow:setContinue(13)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_20_0(flow)
	flow:setActive()

	local _0 = _C(21, "GetSelfId", flow)

	_A(flow, "SendMessageToTrigger", _0, 1)

	return _M._to_26_0(flow)
end

function _M._to_25_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_53_1(flow)

	return _doBehaviourTail_0(flow, 25, _0, 0, false)
end

function _M._to_26_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Behav_Angry")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Angry")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", true)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", true)
	flow:setContinue(26)

	return true
end

function _M._to_47_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_53_1(flow)

	return _doBehaviourTail_0(flow, 47, _0, 0, false)
end

function _M._to_48_0(flow)
	if not _B(flow, "PBT_ReadyToFight") then
		return
	end

	local _0 = _M._get_53_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tRandomWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tShowExclamation", false)
	flow:setContinue(48)

	return true
end

function _M._get_2_2(flow)
	return flow:getCache(2, "__iterItem")
end

function _M._get_2_3(flow)
	local _0 = _C(1, "GetAoiEntityTableByLevel", flow, 0, 30, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(2, "__iterItem", v)

		if _M._get_10_3(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_10_3(flow)
	local _3 = _M._get_2_2(flow)
	local _0 = _C(4, "IsControllingPet", flow, _3)

	if not _0 then
		return false
	end

	local _7 = _M._get_2_2(flow)
	local _8 = _C(8, "GetDistance", flow, _7, 0, false)
	local _1 = _8 <= 0.9

	if not _1 then
		return false
	end

	local _5 = _M._get_2_2(flow)
	local _6 = _C(6, "GetControllingPetActorId", flow, _5)
	local _4 = _C(17, "GetPetData", flow, _6, "petPrototypeId", true, 0)
	local _2 = _4 == 1020700

	if not _2 then
		return false
	end

	return true
end

function _M._get_15_1(flow)
	local _1 = _M._get_2_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_51_1(flow)
	local _0 = _M._get_2_3(flow)

	return _C(51, "SelectOneByRandom", flow, _0)
end

function _M._get_52_1(flow)
	local _0 = flow:getCache(52, "tgt")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_51_1(flow)

	flow:setCache(52, "tgt", _0)

	return _0
end

function _M._get_53_1(flow)
	local _0 = _M._get_52_1(flow)

	return _C(53, "GetControllingPetActorId", flow, _0)
end

return _M
