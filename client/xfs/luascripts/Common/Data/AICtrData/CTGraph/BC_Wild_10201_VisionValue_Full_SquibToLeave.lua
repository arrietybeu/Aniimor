-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_VisionValue_Full_SquibToLeave.lua

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

		local _0 = _C(60, "GetSelfId", flow)

		_A(flow, "HideEmojiOnTarget", _0, "")

		return _M._to_70_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 58 then
		return true
	end

	if nodeId == 63 then
		return _M._to_58_0(flow)
	end

	if nodeId == 71 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_58_0(flow)
	if not _B(flow, "PBT_Leave") then
		return
	end

	local _0 = _M._get_55_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow:setContinue(58)

	return true
end

function _M._to_63_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Behav_Happy")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 6)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", true)
	flow:setContinue(63)

	return true
end

function _M._to_70_0(flow)
	local _1 = _C(64, "RandomInteger", flow, 1, 3)
	local _0 = _1 <= 1

	if _0 then
		return _M._to_63_0(flow)
	end

	return _M._to_71_0(flow)
end

function _M._to_71_0(flow)
	if not _B(flow, "PBT_Leave") then
		return
	end

	local _0 = _M._get_55_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow:setContinue(71)

	return true
end

function _M._get_55_2(flow)
	return flow:getContextValue("sensorTgtId")
end

return _M
