-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_GuideToChest.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_65_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 38 then
		return _M._to_61_0(flow)
	end

	if nodeId == 60 then
		return _M._to_59_0(flow)
	end

	if nodeId == 61 then
		return _M._to_60_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_38_0(flow)
	if not _B(flow, "PBT_Pet_GuideToChestNoHappy") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", 0)
	flow.__agent:addSubTreeLocalParam("tStopDist", 1.5)
	flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tFaceTarget", false)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
	flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
	flow:setContinue(38)

	return true
end

function _M._to_59_0(flow)
	flow:setActive()
	_A(flow, "ExitPetGuide", 0)

	return true
end

function _M._to_60_0(flow)
	if not _B(flow, "PBT_Com_Happy") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Behav_Happy")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 4)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow:setContinue(60)

	return true
end

function _M._to_61_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _C(63, "GetPetMaster", flow, 0)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(61)

	return true
end

function _M._to_65_0(flow)
	local _2 = _C(33, "GetPetMaster", flow, 0)
	local _3 = _C(32, "GetDistance", flow, 0, _2, false)
	local _4 = _3 >= 10
	local _0 = not _4

	if _0 then
		flow:setActive()

		local _1 = _C(66, "GetSelfId", flow)

		_A(flow, "ShowQuestionMark", _1, "DirectFull")

		return _M._to_38_0(flow)
	else
		flow:setActiveFail()
	end
end

return _M
