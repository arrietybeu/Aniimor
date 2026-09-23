-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10011_StarFruit_Behav.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_11_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 15 then
		return true
	end

	if nodeId == 19 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 15 then
		return _M._get_14_1(flow)
	end
end

function _M._to_11_0(flow)
	local _0 = _M._get_4_3(flow)

	if _0 then
		return _M._to_15_0(flow)
	end

	local _1 = _M._get_0_3(flow)

	if _1 then
		return _M._to_19_0(flow)
	end
end

function _M._to_15_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 15)

	if not _1 then
		flow:setActive()
		_C(15, "DoBehaviour", flow, "PBT_LoopAnimAndBreak")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Eat")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_EatStart")
		flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_EatLoop")
		flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_EatEnd")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 99999)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", true)
		flow.__agent:addSubTreeLocalParam("tBreakTag", "Cry")
		flow:setContinue(15)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_19_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Behav_Cry")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 99999)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Cry")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", true)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", true)
	flow:setContinue(19)

	return true
end

function _M._get_0_3(flow)
	if false then
		return false
	end

	if false then
		return false
	end

	local _0 = _C(18, "HasAITag", flow, 0, "Cry")

	if not _0 then
		return false
	end

	return true
end

function _M._get_4_3(flow)
	local _0 = _C(10, "HasAITag", flow, 0, "Eat")

	if not _0 then
		return false
	end

	if false then
		return false
	end

	if false then
		return false
	end

	return true
end

function _M._get_14_1(flow)
	local _0 = _C(13, "HasAITag", flow, 0, "Eat")

	return not _0
end

return _M
