-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Npc_Response_TwineTest.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeEventTrigger(flow, eventName)
	if eventName == "PlayerSwitchControllTrigger" then
		return _M._to_2_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 2 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_2_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_3_1(flow)

	if _0 then
		flow:setActive()
		_C(2, "DoBehaviour", flow, "PBT_CustomLoopAnimation")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 0)
		flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Emotion_Applaud_Start")
		flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Emotion_Applaud_Loop")
		flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Emotion_Applaud_End")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
		flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
		flow:setContinue(2)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_3_1(flow)
	local _0 = flow:getContextValue("entityActorId")

	return _C(3, "IsControllingPet", flow, _0)
end

return _M
