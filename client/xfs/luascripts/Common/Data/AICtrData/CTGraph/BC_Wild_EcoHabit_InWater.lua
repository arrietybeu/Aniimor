-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_EcoHabit_InWater.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_21_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 21 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_21_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_19_2(flow)

	if _0 then
		flow:setActive()
		_C(21, "DoBehaviour", flow, "PBT_Wild_InWater")
		flow.__agent:clearSubTreeLocalParams()
		flow:setContinue(21)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_3_0(flow)
	return _C(3, "GetSelfId", flow)
end

function _M._get_19_2(flow)
	local _4 = _M._get_3_0(flow)
	local _6 = _M._get_3_0(flow)
	local _7 = _C(5, "GetBodyHeight", flow, _6)
	local _8 = _C(10, "GetPuppetData", flow, 0, "enterWaterDeathDepthRatio", true, -0.8)
	local _5 = _7 * _8
	local _0 = _C(17, "IsOnWater", flow, _4, _5)

	if not _0 then
		return false
	end

	local _2 = _M._get_3_0(flow)
	local _3 = _C(8, "CheckHasAbility", flow, _2, "Swim")
	local _1 = not _3

	if not _1 then
		return false
	end

	return true
end

return _M
