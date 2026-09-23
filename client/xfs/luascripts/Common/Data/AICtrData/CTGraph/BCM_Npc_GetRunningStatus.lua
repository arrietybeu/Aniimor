-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BCM_Npc_GetRunningStatus.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.getMacroValue(flow, valueName)
	if valueName == "resList" then
		return _M._get_14_3(flow)
	end
end

function _M._get_14_3(flow)
	local _0 = _M._get_15_1(flow)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(14, "__iterItem", k)

		if _M._get_22_2(flow) then
			_1[#_1 + 1] = k
		end
	end

	return _1
end

function _M._get_14_2(flow)
	return flow:getCache(14, "__iterItem")
end

function _M._get_15_1(flow)
	local _0 = flow:getContextValue("staticId")

	return _C(15, "GetNpcStatusServerData", flow, _0)
end

function _M._get_22_2(flow)
	local _6 = _M._get_14_2(flow)
	local _7 = _C(24, "GetNpcStatusConfigData", flow, _6)
	local _8 = _C(23, "GetTableValueByKey", flow, _7, "behavName")
	local _9 = flow:getContextValue("behavName")
	local _0 = _8 == _9

	if not _0 then
		return false
	end

	local _4 = _M._get_15_1(flow)
	local _5 = _M._get_14_2(flow)
	local _2 = _C(19, "GetTableValueByKey", flow, _4, _5)
	local _3 = flow:getContextValue("status")
	local _1 = _2 == _3

	if not _1 then
		return false
	end

	return true
end

return _M
