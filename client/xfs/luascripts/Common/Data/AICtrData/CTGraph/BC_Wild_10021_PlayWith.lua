-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10021_PlayWith.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Event_PER_StareFriendly" then
		return _M._to_12_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 12 then
		return _M._to_55_0(flow)
	end

	if nodeId == 43 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 12 then
		return _M._get_66_2(flow)
	end

	if nodeId == 43 then
		return _M._get_66_2(flow)
	end
end

function _M._to_1_0(flow)
	local _0 = _M._get_63_1(flow)

	if _0 then
		flow:setActive()
		_A(flow, "SendMessageToTrigger", 0, 1002701)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_12_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_61_4(flow)
	local _1 = _M.checkInterrupt(flow, 12)

	if _0 and not _1 then
		flow:setActive()
		_C(12, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _2 = _M._get_62_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _2)
		flow.__agent:addSubTreeLocalParam("tStopDist", 1.5)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 2)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 0)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(12)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_43_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 43)

	if not _1 then
		flow:setActive()
		_C(43, "DoBehaviour", flow, "PBT_MoveAroundTarget")

		local _1 = _M._get_62_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tRadius", 2)
		flow.__agent:addSubTreeLocalParam("tSpeed", 5)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
		flow.__agent:addSubTreeLocalParam("tClockwise", false)
		flow.__agent:addSubTreeLocalParam("tTimeout", 10)
		flow:setContinue(43)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_55_0(flow)
	flow:addTimer(1, _M, "_to_1_0", flow)

	return _M._to_43_0(flow)
end

function _M._get_61_4(flow)
	local _4 = _M._get_62_2(flow)
	local _0 = _C(52, "IsInAnimState", flow, _4, "Skill_DefMode_Start01")

	if _0 then
		return true
	end

	local _5 = _M._get_62_2(flow)
	local _1 = _C(57, "IsInAnimState", flow, _5, "Skill_DefMode_Start02")

	if _1 then
		return true
	end

	local _6 = _M._get_62_2(flow)
	local _2 = _C(58, "IsInAnimState", flow, _6, "Skill_DefMode_Start03")

	if _2 then
		return true
	end

	local _7 = _M._get_62_2(flow)
	local _3 = _C(59, "IsInAnimState", flow, _7, "Skill_DefMode_Loop")

	if _3 then
		return true
	end

	return false
end

function _M._get_62_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_63_1(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_62_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayer")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_63_3(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_62_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayerInterrupt")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_66_2(flow)
	local _2 = _M._get_62_2(flow)
	local _3 = _C(64, "GetDistance", flow, _2, 0, false)
	local _0 = _3 > 10

	if _0 then
		return true
	end

	local _1 = _M._get_63_3(flow)

	if _1 then
		return true
	end

	return false
end

return _M
