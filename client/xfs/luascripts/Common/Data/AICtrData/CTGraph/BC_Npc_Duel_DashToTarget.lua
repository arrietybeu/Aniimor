-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Npc_Duel_DashToTarget.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_28_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 28 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 28 then
		return _M._get_58_2(flow)
	end
end

function _M._to_28_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_57_2(flow)
	local _1 = _M.checkInterrupt(flow, 28)

	if _0 and not _1 then
		flow:setActive()
		_C(28, "DoBehaviour", flow, "PBT_DashToTarget")
		flow.__agent:clearSubTreeLocalParams()
		flow:setContinue(28)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_55_3(flow)
	local _0 = _M._get_56_1(flow)

	return _C(55, "GetDistance", flow, _0, 0, false)
end

function _M._get_56_1(flow)
	local _0 = _C(54, "GetAoiEntityTableByLevel", flow, 0, 30, 2)

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

function _M._get_57_2(flow)
	local _0 = _M._get_55_3(flow)

	return _0 >= 10
end

function _M._get_58_2(flow)
	local _0 = _M._get_55_3(flow)

	return _0 <= 5
end

return _M
