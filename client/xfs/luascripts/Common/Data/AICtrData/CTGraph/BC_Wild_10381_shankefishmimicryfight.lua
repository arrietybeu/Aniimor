-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10381_shankefishmimicryfight.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_18_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 7 then
		return _M._to_11_0(flow)
	end

	if nodeId == 11 then
		return _M._to_16_0(flow)
	end

	if nodeId == 16 then
		return true
	end

	if nodeId == 18 then
		return _M._to_7_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_7_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_6_1(flow)

	if _0 then
		flow:setActive()
		_C(7, "DoBehaviour", flow, "PBT_SwitchState")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tCharacterState", "LOCOMOTION")
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
		flow:setContinue(7)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_11_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_17_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tSkillId", 13810300)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(11)

	return true
end

function _M._to_16_0(flow)
	if not _B(flow, "PBT_ReadyToFight") then
		return
	end

	local _0 = _M._get_17_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tRandomWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tShowExclamation", false)
	flow:setContinue(16)

	return true
end

function _M._to_18_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_6_1(flow)

	if _0 then
		flow:setActive()
		_C(18, "DoBehaviour", flow, "PBT_ShowEmojiBubble")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Angry")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
		flow:setContinue(18)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_0_2(flow)
	return flow:getCache(0, "__iterItem")
end

function _M._get_0_3(flow)
	local _0 = _C(1, "GetAoiEntityTableByLevel", flow, 0, 10, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(0, "__iterItem", v)

		if _M._get_13_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_6_1(flow)
	local _1 = _M._get_0_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_9_3(flow)
	local _0 = flow:getCache(10, "__iterItem")

	return _C(9, "GetDistance", flow, _0, 0, false)
end

function _M._get_10_2(flow)
	local _0 = _M._get_0_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(10, "__iterItem", v)

		_1 = _M._get_9_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_13_2(flow)
	local _2 = _M._get_0_2(flow)
	local _3 = _C(3, "GetDistance", flow, _2, 0, false)
	local _0 = _3 <= 5

	if not _0 then
		return false
	end

	local _1 = _C(12, "IsChildOfCharState", flow, 0, "MIMICRY")

	if not _1 then
		return false
	end

	return true
end

function _M._get_17_1(flow)
	local _0 = flow:getCache(17, "TargetId")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_10_2(flow)

	flow:setCache(17, "TargetId", _0)

	return _0
end

return _M
