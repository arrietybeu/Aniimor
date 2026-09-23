-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10162_VisionFight.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "VisionValue_Full" then
		return _M._to_28_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 12 then
		return true
	end

	if nodeId == 26 then
		return _M._to_0_0(flow)
	end

	if nodeId == 28 then
		return _M._to_26_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_0_0(flow)
	flow:setActive()
	_A(flow, "SendMessageToTrigger", 0, 1)

	return _M._to_12_0(flow)
end

function _M._to_12_0(flow)
	if not _B(flow, "PBT_ReadyToFight") then
		return
	end

	local _0 = flow:getContextValue("sensorTgtId")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tRandomWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tShowExclamation", false)
	flow:setContinue(12)

	return true
end

function _M._to_26_0(flow)
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
	flow:setContinue(26)

	return true
end

function _M._to_28_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_21_1(flow)

	if _0 then
		flow:setActive()
		_C(28, "DoBehaviour", flow, "PBT_TurnToTargetAtYaw")

		local _1 = _M._get_30_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTgtId", _1)
		flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
		flow.__agent:addSubTreeLocalParam("tInstant", false)
		flow:setContinue(28)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_18_2(flow)
	return flow:getCache(18, "__iterItem")
end

function _M._get_18_3(flow)
	local _0 = _C(17, "GetAoiEntityTableByLevel", flow, 0, 30, 4)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(18, "__iterItem", v)

		if _M._get_23_3(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_21_1(flow)
	local _1 = _M._get_18_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_23_3(flow)
	local _3 = _M._get_18_2(flow)
	local _4 = _C(15, "GetPetData", flow, _3, "petPrototypeId", true, 0)
	local _0 = _4 == 1016200

	if not _0 then
		return false
	end

	local _5 = _M._get_18_2(flow)
	local _1 = _C(22, "IsCurCombatPet", flow, _5)

	if not _1 then
		return false
	end

	local _8 = _M._get_18_2(flow)
	local _6 = _C(32, "GetEntProperty", flow, _8, "gender")
	local _9 = _C(34, "GetSelfId", flow)
	local _7 = _C(35, "GetEntProperty", flow, _9, "gender")
	local _2 = _6 == _7

	if not _2 then
		return false
	end

	return true
end

function _M._get_29_1(flow)
	local _0 = _M._get_18_3(flow)

	return _C(29, "SelectOneByRandom", flow, _0)
end

function _M._get_30_1(flow)
	local _0 = flow:getCache(30, "2131")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_29_1(flow)

	flow:setCache(30, "2131", _0)

	return _0
end

return _M
