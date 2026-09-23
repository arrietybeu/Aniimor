-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_VisionValue_Full_CastSkillCharge.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "VisionValue_Full" then
		flow:setActive()
		_A(flow, "AddAITag", 0, "TA_VisionFull")
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "TA_VisionAlert")
		flow:setActive()

		local _0 = _C(69, "GetSelfId", flow)

		_A(flow, "HideEmojiOnTarget", _0, "")

		return _M._to_5_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 1 then
		return _M._to_70_0(flow)
	end

	if nodeId == 5 then
		return _M._to_1_0(flow)
	end

	if nodeId == 70 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_1_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_29_1(flow)

	if _0 then
		flow:setActive()
		_C(1, "DoBehaviour", flow, "PBT_CastSkill")

		local _1 = _M._get_40_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tSkillId", 12010110)
		flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Laugh")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
		flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
		flow:setContinue(1)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_5_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	local _0 = "LOCOMOTION"

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", _0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(5)

	return true
end

function _M._to_70_0(flow)
	if not _B(flow, "PBT_Leave") then
		return
	end

	local _0 = flow:getContextValue("sensorTgtId")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow:setContinue(70)

	return true
end

function _M._get_22_3(flow)
	local _0 = _C(21, "GetAoiEntityTableByLevel", flow, 0, 30, 64)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(22, "__iterItem", v)

		if _M._get_24_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_22_2(flow)
	return flow:getCache(22, "__iterItem")
end

function _M._get_24_2(flow)
	local _0 = _M._get_22_2(flow)

	return _C(24, "HasEntityTag", flow, _0, "TE_Chest_ChargeTarget")
end

function _M._get_29_1(flow)
	local _1 = _M._get_22_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_40_2(flow)
	local _0 = _M._get_22_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(40, "__iterItem", v)

		_1 = _M._get_41_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_41_3(flow)
	local _0 = flow:getCache(40, "__iterItem")

	return _C(41, "GetDistance", flow, _0, 0, false)
end

return _M
