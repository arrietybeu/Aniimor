-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_VisionValue_Ful_ExitMimicryToDestroy.lua

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

		local _0 = _C(73, "GetSelfId", flow)

		_A(flow, "HideEmojiOnTarget", _0, "")

		return _M._to_67_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 65 then
		return true
	end

	if nodeId == 67 then
		return _M._to_65_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_65_0(flow)
	if not _B(flow, "PBT_LeaveTargetAndDestroy") then
		return
	end

	local _0 = flow:getContextValue("sensorTgtId")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tLeaveDistance", 50)
	flow.__agent:addSubTreeLocalParam("tSpeed", 8)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
	flow.__agent:addSubTreeLocalParam("tMaxTime", 10)
	flow.__agent:addSubTreeLocalParam("tDestroyOnFail", true)
	flow:setContinue(65)

	return true
end

function _M._to_67_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	local _0 = "LOCOMOTION"

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", _0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(67)

	return true
end

return _M
