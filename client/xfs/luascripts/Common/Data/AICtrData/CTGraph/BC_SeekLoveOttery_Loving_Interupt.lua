-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_SeekLoveOttery_Loving_Interupt.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Love_Exit" then
		return _M._to_54_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 53 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_53_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Behav_CryStart")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Cry")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(53)

	return true
end

function _M._to_54_0(flow)
	local _2 = _M._get_48_0(flow)
	local _0 = _C(49, "IsInBehavTag", flow, _2, "TB_SeekLove_Loving")

	if _0 then
		flow:setActive()

		local _1 = _M._get_48_0(flow)

		_A(flow, "StopEffectOnTarget", _1, "Eff_Common_EnvBehav_SeekLove")

		return _M._to_53_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._get_48_0(flow)
	return _C(48, "GetSelfId", flow)
end

return _M
