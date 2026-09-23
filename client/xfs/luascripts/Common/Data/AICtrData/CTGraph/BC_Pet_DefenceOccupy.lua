-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_DefenceOccupy.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_1_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 1 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_1_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_8_2(flow)

	if _0 then
		flow:setActive()
		_C(1, "DoBehaviour", flow, "PBT_Pet_DefenseOccupy")
		flow.__agent:clearSubTreeLocalParams()
		flow:setContinue(1)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_6_0(flow)
	return _C(6, "GetSelfId", flow)
end

function _M._get_8_2(flow)
	local _2 = _M._get_6_0(flow)
	local _3 = _C(5, "IsPlayerInCombat", flow, _2)
	local _0 = not _3

	if not _0 then
		return false
	end

	local _1 = _M._get_14_3(flow)

	if not _1 then
		return false
	end

	return true
end

function _M._get_14_3(flow)
	local _3 = _M._get_6_0(flow)
	local _4 = _C(7, "GetTargetBuffLayerCount", flow, _3, 2102704)
	local _0 = _4 == 1

	if _0 then
		return true
	end

	local _6 = _M._get_6_0(flow)
	local _5 = _C(11, "GetTargetBuffLayerCount", flow, _6, 2102705)
	local _1 = _5 == 1

	if _1 then
		return true
	end

	local _8 = _M._get_6_0(flow)
	local _7 = _C(13, "GetTargetBuffLayerCount", flow, _8, 2102706)
	local _2 = _7 == 1

	if _2 then
		return true
	end

	return false
end

return _M
