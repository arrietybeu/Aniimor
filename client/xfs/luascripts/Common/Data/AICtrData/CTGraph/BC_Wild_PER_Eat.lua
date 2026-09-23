-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_PER_Eat.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "PercpetEntityReactionTriggerEat" then
		return _M._to_5_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_13_1(flow)

	_A(flow, "RemoveEntityTag", _0, "TE_Env_BeUsed")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 5 then
		return _M._to_9_0(flow)
	end

	if nodeId == 6 then
		return _M._to_10_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_5_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_8_1(flow)

	if _0 then
		flow:setActive()
		_C(5, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_0_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 1)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 0)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 2)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(5)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_6_0(flow)
	if not _B(flow, "PBT_Com_Eat") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("eatTimeOut", 30)
	flow:setContinue(6)

	return true
end

function _M._to_9_0(flow)
	flow:setActive()

	local _0 = _M._get_13_1(flow)

	_A(flow, "AddEntityTag", _0, "TE_Env_BeUsed")

	return _M._to_6_0(flow)
end

function _M._to_10_0(flow)
	flow:setActive()

	local _0 = _M._get_13_1(flow)

	_A(flow, "RemoveEntityTag", _0, "TE_Env_BeUsed")

	return true
end

function _M._get_0_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_8_1(flow)
	local _1 = _M._get_13_1(flow)
	local _0 = _C(7, "HasEntityTag", flow, _1, "TE_Env_BeUsed")

	return not _0
end

function _M._get_13_1(flow)
	local _0 = flow:getCache(13, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_0_2(flow)

	flow:setCache(13, "1", _0)

	return _0
end

return _M
