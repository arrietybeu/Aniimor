-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_GuideAskAccept.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "CommandGoTrigger" then
		return _M._to_1_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 2 then
		return _M._to_11_0(flow)
	end

	if nodeId == 9 then
		return _M._to_10_0(flow)
	end

	if nodeId == 11 then
		return _M._to_9_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_1_0(flow)
	local _0 = _C(0, "CheckInDialog", flow, 70002000)

	if _0 then
		flow:setActive()

		local _1 = _C(3, "GetSelfId", flow)

		_A(flow, "SetPlayerFaceToTarget", _1, 2)

		return _M._to_2_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._to_2_0(flow)
	if not _B(flow, "PBT_Pet_GuideToChest") then
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
	flow:setContinue(2)

	return true
end

function _M._to_9_0(flow)
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
	flow:setContinue(9)

	return true
end

function _M._to_10_0(flow)
	flow:setActive()
	_A(flow, "ExitPetGuide", 0)

	return true
end

function _M._to_11_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _C(12, "GetPetMaster", flow, 0)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(11)

	return true
end

return _M
