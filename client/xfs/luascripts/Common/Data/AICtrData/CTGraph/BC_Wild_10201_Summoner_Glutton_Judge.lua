-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_Summoner_Glutton_Judge.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_24_0(flow)
end

function _M._to_1_0(flow)
	local _1 = _C(4, "HasAITag", flow, 0, "Eat")
	local _0 = not _1

	if _0 then
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "Find")
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "GoHome")
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "EatBreak")
		flow:setActive()
		_A(flow, "AddAITag", 0, "Eat")

		return true
	end
end

function _M._to_8_0(flow)
	local _1 = _C(6, "HasAITag", flow, 0, "Find")
	local _0 = not _1

	if _0 then
		return _M._to_11_0(flow)
	end
end

function _M._to_11_0(flow)
	local _0 = _M._get_13_2(flow)

	if _0 then
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "Eat")
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "GoHome")
		flow:setActive()
		_A(flow, "AddAITag", 0, "Find")

		return true
	end

	local _2 = _M._get_13_2(flow)
	local _1 = not _2

	if _1 then
		flow:setActive()
		_A(flow, "AddAITag", 0, "EatBreak")
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "Eat")
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "GoHome")
		flow:setActive()
		_A(flow, "AddAITag", 0, "Find")

		return true
	end
end

function _M._to_24_0(flow)
	local _2 = _M._get_25_1(flow)
	local _0 = not _2

	if _0 then
		return _M._to_1_0(flow)
	end

	local _1 = _M._get_25_1(flow)

	if _1 then
		return _M._to_50_0(flow)
	end
end

function _M._to_50_0(flow)
	local _2 = _M._get_51_1(flow)
	local _0 = not _2

	if _0 then
		return _M._to_8_0(flow)
	end

	local _1 = _M._get_51_1(flow)

	if _1 then
		return _M._to_62_0(flow)
	end
end

function _M._to_62_0(flow)
	local _1 = _C(71, "HasAITag", flow, 0, "GoHome")
	local _0 = not _1

	if _0 then
		return _M._to_64_0(flow)
	end
end

function _M._to_64_0(flow)
	local _0 = _M._get_66_2(flow)

	if _0 then
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "Eat")
		flow:setActive()
		_A(flow, "AddAITag", 0, "Find")
		flow:setActive()
		_A(flow, "AddAITag", 0, "GoHome")

		return true
	end

	local _2 = _M._get_66_2(flow)
	local _1 = not _2

	if _1 then
		flow:setActive()
		_A(flow, "AddAITag", 0, "EatBreak")
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "Eat")
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "Find")
		flow:setActive()
		_A(flow, "AddAITag", 0, "GoHome")

		return true
	end
end

function _M._get_13_2(flow)
	return _C(13, "HasAITag", flow, 0, "EatBreak")
end

function _M._get_17_3(flow)
	local _3 = _M._get_19_2(flow)
	local _0 = _C(18, "HasEntityTag", flow, _3, "TE_Chest_Collectible")

	if not _0 then
		return false
	end

	local _5 = _M._get_19_2(flow)
	local _4 = _C(23, "GetDistance", flow, _5, 0, false)
	local _1 = _4 <= 0.8

	if not _1 then
		return false
	end

	local _7 = _M._get_19_2(flow)
	local _9 = _M._get_41_2(flow)
	local _8 = _C(42, "SelectOneByRandom", flow, _9)
	local _6 = _C(39, "GetDistance", flow, _7, _8, false)
	local _2 = _6 <= 15

	if not _2 then
		return false
	end

	return true
end

function _M._get_19_3(flow)
	local _0 = _C(21, "GetAoiEntityTableByLevel", flow, 0, 30, 64)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(19, "__iterItem", v)

		if _M._get_17_3(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_19_2(flow)
	return flow:getCache(19, "__iterItem")
end

function _M._get_25_1(flow)
	local _0 = _M._get_19_3(flow)

	return not _0 or next(_0) == nil
end

function _M._get_41_2(flow)
	local _0 = _C(40, "GetAoiEntityTableByLevel", flow, 0, 30, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(41, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_77_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_45_3(flow)
	local _0 = _C(47, "GetAoiEntityTableByLevel", flow, 0, 30, 64)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(45, "__iterItem", v)

		if _M._get_54_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_45_2(flow)
	return flow:getCache(45, "__iterItem")
end

function _M._get_51_1(flow)
	local _0 = _M._get_45_3(flow)

	return not _0 or next(_0) == nil
end

function _M._get_54_2(flow)
	local _2 = _M._get_45_2(flow)
	local _0 = _C(44, "HasEntityTag", flow, _2, "TE_Chest_Collectible")

	if not _0 then
		return false
	end

	local _4 = _M._get_45_2(flow)
	local _6 = _M._get_58_2(flow)
	local _5 = _C(59, "SelectOneByRandom", flow, _6)
	local _3 = _C(56, "GetDistance", flow, _4, _5, false)
	local _1 = _3 <= 23

	if not _1 then
		return false
	end

	return true
end

function _M._get_58_2(flow)
	local _0 = _C(57, "GetAoiEntityTableByLevel", flow, 0, 30, 64)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(58, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_78_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_66_2(flow)
	return _C(66, "HasAITag", flow, 0, "EatBreak")
end

function _M._get_77_2(flow)
	local _0 = flow:getCache(41, "__iterItem")

	return _C(77, "HasEntityTag", flow, _0, "TE_Env_UniversalMark_D")
end

function _M._get_78_2(flow)
	local _0 = flow:getCache(58, "__iterItem")

	return _C(78, "HasEntityTag", flow, _0, "TE_Env_UniversalMark_D")
end

return _M
