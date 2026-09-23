-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10033_VisionValue_Full_InvisibleAttack.lua

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

		local _0 = _C(64, "GetSelfId", flow)

		_A(flow, "HideEmojiOnTarget", _0, "")

		return _M._to_70_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "RemoveAITag", 0, "TA_VisionFull")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 70 then
		return _M._to_88_0(flow)
	end

	if nodeId == 83 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_70_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_59_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(70)

	return true
end

function _M._to_83_0(flow)
	if not _B(flow, "PBT_ReadyToFight") then
		return
	end

	local _0 = _M._get_59_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tRandomWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tShowExclamation", false)
	flow:setContinue(83)

	return true
end

function _M._to_87_0(flow)
	local _0 = _M._get_94_2(flow)

	if _0 then
		flow:setActive()
		_A(flow, "SendMessageToTrigger", 0, 1002)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_88_0(flow)
	flow:addTimer(3, _M, "_to_87_0", flow)

	return _M._to_83_0(flow)
end

function _M._get_59_2(flow)
	return flow:getContextValue("sensorTgtId")
end

function _M._get_94_2(flow)
	local _3 = _M._get_59_2(flow)
	local _0 = _C(96, "IsControllingPet", flow, _3)

	if not _0 then
		return false
	end

	local _5 = _M._get_59_2(flow)
	local _4 = _C(98, "GetControllingPetActorId", flow, _5)
	local _2 = _C(97, "GetPetData", flow, _4, "baseFormPet", true, 0)
	local _1 = _2 == 1003300

	if not _1 then
		return false
	end

	return true
end

return _M
