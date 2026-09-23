-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_MoveToEatBait_Interupt.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_31_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 31 then
		return _M._to_37_0(flow)
	end

	if nodeId == 37 then
		return _M._to_45_0(flow)
	end

	if nodeId == 45 then
		return _M._to_46_0(flow)
	end

	if nodeId == 46 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_31_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_43_2(flow)

	if _0 then
		flow:setActive()
		_C(31, "DoBehaviour", flow, "PBT_AlertStare")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tSensorTgtId", 0)
		flow.__agent:addSubTreeLocalParam("tMaxTime", 0)
		flow.__agent:addSubTreeLocalParam("tRandomWaitTime", 0)
		flow:setContinue(31)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_37_0(flow)
	if not _B(flow, "PBT_SwitchToFly") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tFlyHeight", 30)
	flow.__agent:addSubTreeLocalParam("tMaxTime", 5)
	flow:setContinue(37)

	return true
end

function _M._to_45_0(flow)
	if not _B(flow, "PBT_Leave") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", 0)
	flow:setContinue(45)

	return true
end

function _M._to_46_0(flow)
	if not _B(flow, "PBT_DestroySelf") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(46)

	return true
end

function _M._get_43_2(flow)
	local _1 = _C(44, "GetSelfId", flow)
	local _0 = _C(42, "IsInBehavTag", flow, _1, "TB_EatingBait")

	if not _0 then
		return false
	end

	if false then
		return false
	end

	return true
end

return _M
