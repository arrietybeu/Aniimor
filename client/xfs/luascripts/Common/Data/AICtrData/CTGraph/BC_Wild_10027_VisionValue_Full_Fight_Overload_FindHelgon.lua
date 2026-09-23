-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10027_VisionValue_Full_Fight_Overload_FindHelgon.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "VisionValue_Full" then
		return _M._to_57_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 58 then
		return _M._to_5_0(flow)
	end

	if nodeId == 67 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_5_0(flow)
	flow:setActive()

	local _0 = _C(6, "GetSelfId", flow)

	_A(flow, "HideEmojiOnTarget", _0, "")
	flow:setActive()
	_A(flow, "RemoveAITag", 0, "TA_VisionFull")

	return _M._to_67_0(flow)
end

function _M._to_57_0(flow)
	local _0 = _M._get_71_2(flow)

	if _0 then
		return _M._to_58_0(flow)
	end
end

function _M._to_58_0(flow)
	flow:setActive()

	local _0 = flow:getSubFlow("BCS_Common_VisionFullTag")

	if _0:executeSubFlow() then
		flow:setContinue(58)

		if _0:isFinish() then
			return flow:executeContinue()
		end

		return true
	end
end

function _M._to_67_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Skill_DefMode_Start")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Skill_DefMode_Loop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Skill_DefMode_End")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 10)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(67)

	return true
end

function _M._get_39_2(flow)
	local _1 = flow:getContextValue("sensorTgtId")
	local _0 = _C(38, "GetControllingPetActorId", flow, _1)

	return _C(39, "GetPetData", flow, _0, "petPrototypeId", true, 0)
end

function _M._get_71_2(flow)
	local _2 = _M._get_39_2(flow)
	local _0 = _2 == 1002300

	if _0 then
		return true
	end

	local _3 = _M._get_39_2(flow)
	local _1 = _3 == 1002500

	if _1 then
		return true
	end

	return false
end

return _M
