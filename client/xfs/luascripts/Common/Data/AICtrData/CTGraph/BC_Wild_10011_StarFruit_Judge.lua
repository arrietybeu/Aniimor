-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10011_StarFruit_Judge.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_6_0(flow)
end

function _M._to_6_0(flow)
	local _2 = _M._get_7_1(flow)
	local _0 = not _2

	if _0 then
		return _M._to_31_0(flow)
	end

	local _1 = _M._get_7_1(flow)

	if _1 then
		return _M._to_69_0(flow)
	end
end

function _M._to_31_0(flow)
	local _1 = _C(36, "HasAITag", flow, 0, "Eat")
	local _0 = not _1

	if _0 then
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "Cry")
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "EatBreak")
		flow:setActive()
		_A(flow, "AddAITag", 0, "Eat")
		flow:setActive()
		_A(flow, "AddAITag", 0, "CanCry")

		return true
	end
end

function _M._to_58_0(flow)
	local _0 = _M._get_52_2(flow)

	if _0 then
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "Eat")
		flow:setActive()
		_A(flow, "AddAITag", 0, "Cry")

		return true
	end

	local _2 = _M._get_52_2(flow)
	local _1 = not _2

	if _1 then
		flow:setActive()
		_A(flow, "AddAITag", 0, "EatBreak")
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "Eat")
		flow:setActive()
		_A(flow, "AddAITag", 0, "Cry")

		return true
	end
end

function _M._to_59_0(flow)
	local _1 = _C(57, "HasAITag", flow, 0, "Cry")
	local _0 = not _1

	if _0 then
		return _M._to_58_0(flow)
	end
end

function _M._to_69_0(flow)
	local _0 = _M._get_71_2(flow)

	if _0 then
		return _M._to_59_0(flow)
	end
end

function _M._get_1_2(flow)
	return flow:getCache(1, "__iterItem")
end

function _M._get_1_3(flow)
	local _0 = _C(3, "GetAoiEntityTableByLevel", flow, 0, 30, 64)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(1, "__iterItem", v)

		if _M._get_10_3(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_7_1(flow)
	local _0 = _M._get_1_3(flow)

	return not _0 or next(_0) == nil
end

function _M._get_10_3(flow)
	local _2 = _M._get_1_2(flow)
	local _0 = _C(0, "HasEntityTag", flow, _2, "TE_Chest_StarFruit")

	if not _0 then
		return false
	end

	local _4 = _M._get_1_2(flow)
	local _3 = _C(5, "GetDistance", flow, _4, 0, false)
	local _1 = _3 <= 1

	if not _1 then
		return false
	end

	if false then
		return false
	end

	return true
end

function _M._get_52_2(flow)
	return _C(52, "HasAITag", flow, 0, "EatBreak")
end

function _M._get_70_1(flow)
	local _0 = _M._get_71_2(flow)

	return not _0
end

function _M._get_71_2(flow)
	return _C(71, "HasAITag", flow, 0, "CanCry")
end

return _M
