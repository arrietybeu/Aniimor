-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10052_Morphling_VisionValue_Full_Alert.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_6_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 1 then
		return true
	end

	if nodeId == 6 then
		return _M._to_8_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_1_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Behav_Happy")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Proud")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", true)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", true)
	flow:setContinue(1)

	return true
end

function _M._to_6_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_4_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(6)

	return true
end

function _M._to_8_0(flow)
	flow:setActive()

	local _0 = _C(9, "GetPartnerIds", flow, 0)

	for _, v in ipairs(_0) do
		local _1 = flow:getMessageContext()

		_1.sourceActorId = flow.__actorId

		flow:sendMessage(v, "Msg_Leader2Partners", _1)
	end

	return _M._to_1_0(flow)
end

function _M._get_4_1(flow)
	local _0 = _C(3, "GetAoiEntityTableByLevel", flow, 0, 10, 2)

	return _C(4, "SelectOneByRandom", flow, _0)
end

return _M
