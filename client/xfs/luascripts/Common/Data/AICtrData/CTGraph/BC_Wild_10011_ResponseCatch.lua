-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10011_ResponseCatch.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_11_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 10 then
		return true
	end

	if nodeId == 11 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_11_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_0_2(flow)

	if _0 then
		flow:setActive()
		_C(11, "DoBehaviour", flow, "PBT_TriggerBlueprint")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tEventName", "TriggerCatch")
		flow:setContinue(11)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_0_2(flow)
	local _0 = _M._get_6_1(flow)

	return _C(0, "IsInAnimState", flow, _0, "HoldBall_Idle")
end

function _M._get_6_1(flow)
	local _0 = _C(2, "GetAoiEntityTableByLevel", flow, 0, 30, 2)

	if _0 == nil then
		return
	end

	local key = 1
	local value = _0[1]

	for k, v in ipairs(_0) do
		if value < v then
			key, value = k, v
		end
	end

	return value
end

return _M
