-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BCM_Budclaw_Check_Dis.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.getMacroValue(flow, valueName)
	if valueName == "result" then
		return _M._get_5_2(flow)
	end
end

function _M._get_3_2(flow)
	local _0 = flow:getCache(4, "__iterItem")
	local _1 = flow:getContextValue("entityTag")

	return _C(3, "HasEntityTag", flow, _0, _1)
end

function _M._get_4_2(flow)
	local _0 = _C(0, "GetAoiEntityTableByLevel", flow, 0, 10, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(4, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_3_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_5_2(flow)
	local _2 = _M._get_4_2(flow)
	local _1 = _C(2, "SelectOneByRandom", flow, _2)
	local _0 = _C(1, "GetDistance", flow, _1, 0, false)

	return _0 <= 1.5
end

return _M
