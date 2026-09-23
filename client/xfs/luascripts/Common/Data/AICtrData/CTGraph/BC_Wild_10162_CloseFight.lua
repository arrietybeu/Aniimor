-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10162_CloseFight.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_20_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 11 then
		return true
	end

	if nodeId == 20 then
		return _M._to_47_0(flow)
	end

	if nodeId == 47 then
		return _M._to_48_0(flow)
	end

	if nodeId == 48 then
		return _M._to_23_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_11_0(flow)
	if not _B(flow, "PBT_ReadyToFight") then
		return
	end

	local _0 = _M._get_22_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tRandomWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tShowExclamation", false)
	flow:setContinue(11)

	return true
end

function _M._to_20_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_10_1(flow)

	if _0 then
		flow:setActive()
		_C(20, "DoBehaviour", flow, "PBT_TurnToTargetAtYaw")

		local _1 = _M._get_22_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTgtId", _1)
		flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
		flow.__agent:addSubTreeLocalParam("tInstant", false)
		flow:setContinue(20)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_23_0(flow)
	flow:setActive()
	_A(flow, "SendMessageToTrigger", 0, 1)

	return _M._to_11_0(flow)
end

function _M._to_47_0(flow)
	if not _B(flow, "PBT_ShowQuestionMark") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tMarkType", "DirectFull")
	flow.__agent:addSubTreeLocalParam("tTimeout", 2)
	flow:setContinue(47)

	return true
end

function _M._to_48_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Skill_MagicLeaf")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 1.5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", true)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(48)

	return true
end

function _M._get_1_3(flow)
	local _0 = _C(0, "GetAoiEntityTableByLevel", flow, 0, 10, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(1, "__iterItem", v)

		if _M._get_8_4(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_1_2(flow)
	return flow:getCache(1, "__iterItem")
end

function _M._get_8_4(flow)
	local _4 = _M._get_1_2(flow)
	local _0 = _C(3, "IsControllingPet", flow, _4)

	if not _0 then
		return false
	end

	local _8 = _M._get_18_1(flow)
	local _7 = _C(24, "GetPetData", flow, _8, "petPrototypeId", true, 0)
	local _1 = _7 == 1016200

	if not _1 then
		return false
	end

	local _5 = _M._get_1_2(flow)
	local _6 = _C(6, "GetDistance", flow, _5, 0, false)
	local _2 = _6 <= 10

	if not _2 then
		return false
	end

	local _11 = _M._get_18_1(flow)
	local _9 = _C(44, "GetEntProperty", flow, _11, "gender")
	local _12 = _C(45, "GetSelfId", flow)
	local _10 = _C(46, "GetEntProperty", flow, _12, "gender")
	local _3 = _9 == _10

	if not _3 then
		return false
	end

	return true
end

function _M._get_10_1(flow)
	local _1 = _M._get_1_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_18_1(flow)
	local _0 = _M._get_1_2(flow)

	return _C(18, "GetControllingPetActorId", flow, _0)
end

function _M._get_21_1(flow)
	local _0 = _M._get_1_3(flow)

	return _C(21, "SelectOneByRandom", flow, _0)
end

function _M._get_22_1(flow)
	local _0 = flow:getCache(22, "xx")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_21_1(flow)

	flow:setCache(22, "xx", _0)

	return _0
end

return _M
