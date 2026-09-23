-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BCM_Budclaw_Select_Target.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.getMacroValue(flow, valueName)
	if valueName == "result1" then
		return _M._get_10_2(flow)
	end

	if valueName == "result2" then
		return _M._get_13_2(flow)
	end

	if valueName == "entity1" then
		return _M._get_9_1(flow)
	end

	if valueName == "entity2" then
		return _M._get_4_1(flow)
	end
end

function _M._get_0_2(flow)
	local _0 = _C(3, "GetAoiEntityTableByLevel", flow, 0, 30, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(0, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_5_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_1_1(flow)
	local _0 = _C(2, "GetAoiEntityTableByLevel", flow, 0, 50, 2)

	return _C(1, "SelectOneByRandom", flow, _0)
end

function _M._get_4_1(flow)
	local _0 = _M._get_0_2(flow)

	return _C(4, "SelectOneByRandom", flow, _0)
end

function _M._get_5_2(flow)
	local _0 = flow:getCache(0, "__iterItem")
	local _1 = flow:getContextValue("entityTag2")

	return _C(5, "HasEntityTag", flow, _0, _1)
end

function _M._get_7_2(flow)
	local _0 = _C(6, "GetAoiEntityTableByLevel", flow, 0, 30, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(7, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_8_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_8_2(flow)
	local _0 = flow:getCache(7, "__iterItem")
	local _1 = flow:getContextValue("entityTag1")

	return _C(8, "HasEntityTag", flow, _0, _1)
end

function _M._get_9_1(flow)
	local _0 = _M._get_7_2(flow)

	return _C(9, "SelectOneByRandom", flow, _0)
end

function _M._get_10_2(flow)
	local _0 = _M._get_11_3(flow)
	local _1 = _M._get_12_3(flow)

	return _1 <= _0
end

function _M._get_11_3(flow)
	local _0 = _M._get_9_1(flow)
	local _1 = _M._get_1_1(flow)

	return _C(11, "GetDistance", flow, _0, _1, false)
end

function _M._get_12_3(flow)
	local _0 = _M._get_1_1(flow)
	local _1 = _M._get_4_1(flow)

	return _C(12, "GetDistance", flow, _0, _1, false)
end

function _M._get_13_2(flow)
	local _0 = _M._get_11_3(flow)
	local _1 = _M._get_12_3(flow)

	return _0 <= _1
end

return _M
