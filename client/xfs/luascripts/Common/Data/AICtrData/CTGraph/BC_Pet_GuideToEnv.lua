-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_GuideToEnv.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_74_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _C(77, "GetSelfId", flow)

	_A(flow, "StopEffectOnTarget", _0, "Eff_Common_Behav_Notice")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 38 then
		return _M._to_72_0(flow)
	end

	if nodeId == 42 then
		return true
	end

	if nodeId == 72 then
		return _M._to_70_0(flow)
	end

	if nodeId == 73 then
		return _M._to_42_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 42 then
		return _M._get_66_2(flow)
	end
end

function _M._to_38_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_41_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tStopDist", 1.5)
	flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tFaceTarget", false)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 2)
	flow.__agent:addSubTreeLocalParam("tPathFindType", 5)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
	flow:setContinue(38)

	return true
end

function _M._to_42_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 42)

	if not _1 then
		flow:setActive()
		_C(42, "DoBehaviour", flow, "PBT_Pet_GuideToEnvWait")

		local _1 = _C(64, "GetPetMaster", flow, 0)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow:setContinue(42)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_70_0(flow)
	flow:setActive()

	local _0 = _C(71, "GetSelfId", flow)

	_A(flow, "ShowQuestionMark", _0, "DirectFull")

	return _M._to_73_0(flow)
end

function _M._to_72_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_41_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(72)

	return true
end

function _M._to_73_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0.3)
	flow:setContinue(73)

	return true
end

function _M._to_74_0(flow)
	local _0 = _M._get_51_5(flow)

	if _0 then
		flow:setActive()
		_A(flow, "ClearNotTargetLetGoCD")

		return _M._to_38_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._get_35_1(flow)
	local _0 = _C(37, "GetSelfId", flow)

	return _C(35, "GetInteractEnvObj", flow, _0)
end

function _M._get_41_1(flow)
	local _0 = flow:getCache(41, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_35_1(flow)

	flow:setCache(41, "1", _0)

	return _0
end

function _M._get_51_5(flow)
	local _12 = _M._get_82_1(flow)
	local _0 = _C(89, "IsInCharState", flow, _12, 1, 4)

	if not _0 then
		return false
	end

	local _8 = _M._get_82_1(flow)
	local _7 = _C(49, "GetAnimTagDuration", flow, _8)
	local _1 = _7 > 2

	if not _1 then
		return false
	end

	local _5 = _M._get_41_1(flow)
	local _6 = _5 == 0
	local _2 = not _6

	if not _2 then
		return false
	end

	local _11 = _M._get_87_0(flow)
	local _3 = _C(88, "IsInCharState", flow, _11, 1, 4)

	if not _3 then
		return false
	end

	local _10 = _M._get_87_0(flow)
	local _9 = _C(85, "GetAnimTagDuration", flow, _10)
	local _4 = _9 > 2

	if not _4 then
		return false
	end

	return true
end

function _M._get_66_2(flow)
	local _1 = _C(67, "GetPetMaster", flow, 0)
	local _0 = _C(65, "GetDistance", flow, 0, _1, false)

	return _0 >= 15
end

function _M._get_82_1(flow)
	return _C(82, "GetPetMaster", flow, 0)
end

function _M._get_87_0(flow)
	return _C(87, "GetSelfId", flow)
end

return _M
