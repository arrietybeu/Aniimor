-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_VisionValue_Full_Leave_FlyDestroy.lua

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

		local _0 = _C(72, "GetSelfId", flow)

		_A(flow, "HideEmojiOnTarget", _0, "")

		return _M._to_63_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "RemoveAITag", 0, "TA_VisionFull")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 61 then
		return _M._to_64_0(flow)
	end

	if nodeId == 63 then
		return _M._to_61_0(flow)
	end

	if nodeId == 64 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_61_0(flow)
	if not _B(flow, "PBT_Leave") then
		return
	end

	local _0 = flow:getContextValue("sensorTgtId")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow:setContinue(61)

	return true
end

function _M._to_63_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", "FLYING")
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(63)

	return true
end

function _M._to_64_0(flow)
	if not _B(flow, "PBT_DestroySelf") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(64)

	return true
end

return _M
