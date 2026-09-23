-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10041_VisionValue_Full_EnterMimicry.lua

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

		local _0 = _C(55, "GetSelfId", flow)

		_A(flow, "HideEmojiOnTarget", _0, "")

		return _M._to_59_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 52 then
		return true
	end

	if nodeId == 59 then
		return _M._to_52_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_52_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", "SWIMMIMICRY")
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(52)

	return true
end

function _M._to_59_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Surprise")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow:setContinue(59)

	return true
end

return _M
