-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_10042_LeaveFire.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_8_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 8 then
		return _M._to_13_0(flow)
	end

	if nodeId == 13 then
		return _M._to_16_0(flow)
	end

	if nodeId == 15 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_8_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_12_1(flow)

	if _0 then
		flow:setActive()
		_C(8, "DoBehaviour", flow, "PBT_TurnToTargetAtYaw")

		local _1 = _M._get_10_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTgtId", _1)
		flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
		flow.__agent:addSubTreeLocalParam("tInstant", false)
		flow:setContinue(8)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_13_0(flow)
	if not _B(flow, "PBT_Com_Angry") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(13)

	return true
end

function _M._to_15_0(flow)
	if not _B(flow, "PBT_LeaveTarget") then
		return
	end

	local _0 = _M._get_10_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tLeaveDistance", 12)
	flow.__agent:addSubTreeLocalParam("tSpeed", 6)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tMaxTime", 10)
	flow:setContinue(15)

	return true
end

function _M._to_16_0(flow)
	flow:setActive()
	_A(flow, "SendMessageToTrigger", 0, 1)

	return _M._to_15_0(flow)
end

function _M._get_3_2(flow)
	return flow:getCache(3, "__iterItem")
end

function _M._get_3_3(flow)
	local _0 = _C(1, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(3, "__iterItem", v)

		if _M._get_7_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_7_2(flow)
	local _2 = _M._get_3_2(flow)
	local _0 = _C(2, "CheckHasChemState", flow, _2, nil)

	if not _0 then
		return false
	end

	local _3 = _M._get_3_2(flow)
	local _4 = _C(5, "GetDistance", flow, _3, 0, false)
	local _1 = _4 <= 7

	if not _1 then
		return false
	end

	return true
end

function _M._get_9_1(flow)
	local _0 = _M._get_3_3(flow)

	return _C(9, "SelectOneByRandom", flow, _0)
end

function _M._get_10_1(flow)
	local _0 = flow:getCache(10, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_9_1(flow)

	flow:setCache(10, "1", _0)

	return _0
end

function _M._get_12_1(flow)
	local _1 = _M._get_3_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

return _M
