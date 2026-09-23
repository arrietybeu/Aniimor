-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_10031JumpOverRiver.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "GBPMsg_ResPointGO" then
		flow:setActive()

		local _0 = _M._get_133_2(flow)
		local _1 = _M._get_133_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _0, _1)

		return _M._to_117_0(flow)
	end

	if eventName == "GBPMsg_ResPointDoPatrol1" then
		return _M._to_137_0(flow)
	end

	if eventName == "GBPMsg_ResPointDoPatrol2" then
		return _M._to_142_0(flow)
	end

	if eventName == "GBPMsg_ResPointDoPatrol3" then
		return _M._to_145_0(flow)
	end

	if eventName == "GBPMsg_ResPointChat1" then
		return _M._to_148_0(flow)
	end

	if eventName == "GBPMsg_ResPointChat2" then
		return _M._to_151_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_133_2(flow)
	local _1 = _M._get_133_3(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 117 then
		return true
	end

	if nodeId == 137 then
		return true
	end

	if nodeId == 142 then
		return true
	end

	if nodeId == 145 then
		return true
	end

	if nodeId == 148 then
		return true
	end

	if nodeId == 151 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_117_0(flow)
	if not _B(flow, "PBT_MoveToResPointPort") then
		return
	end

	local _0 = _M._get_133_2(flow)
	local _1 = _M._get_133_3(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tPointId", _0)
	flow.__agent:addSubTreeLocalParam("tPortId", _1)
	flow.__agent:addSubTreeLocalParam("tTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", true)
	flow:setContinue(117)

	return true
end

function _M._to_137_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_138_1(flow)

	if _P(flow, 1, _0, -1, nil) then
		flow:setContinue(137)

		return true
	end
end

function _M._to_142_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_143_1(flow)

	if _P(flow, 1, _0, -1, nil) then
		flow:setContinue(142)

		return true
	end
end

function _M._to_145_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_147_1(flow)

	if _P(flow, 1, _0, -1, nil) then
		flow:setContinue(145)

		return true
	end
end

function _M._to_148_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_149_1(flow)

	if _P(flow, 1, _0, -1, nil) then
		flow:setContinue(148)

		return true
	end
end

function _M._to_151_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_152_1(flow)

	if _P(flow, 1, _0, -1, nil) then
		flow:setContinue(151)

		return true
	end
end

function _M._get_133_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_133_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_138_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(138, "GetRouteIdFromResPoint", flow, true, _0, 1)
end

function _M._get_143_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(143, "GetRouteIdFromResPoint", flow, true, _0, 1)
end

function _M._get_147_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(147, "GetRouteIdFromResPoint", flow, true, _0, 1)
end

function _M._get_149_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(149, "GetRouteIdFromResPoint", flow, true, _0, 2)
end

function _M._get_152_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(152, "GetRouteIdFromResPoint", flow, true, _0, 3)
end

return _M
