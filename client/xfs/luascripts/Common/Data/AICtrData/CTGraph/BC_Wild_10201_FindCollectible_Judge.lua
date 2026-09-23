-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_FindCollectible_Judge.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_141_0(flow)
end

function _M._to_141_0(flow)
	local _2 = _M._get_140_1(flow)
	local _0 = not _2

	if _0 then
		return _M._to_220_0(flow)
	end

	local _1 = _M._get_140_1(flow)

	if _1 then
		return _M._to_151_0(flow)
	end
end

function _M._to_151_0(flow)
	local _1 = _M._get_145_3(flow)
	local _2 = not _1 or next(_1) == nil
	local _0 = not _2

	if _0 then
		return _M._to_230_0(flow)
	end
end

function _M._to_220_0(flow)
	local _1 = _C(219, "HasAITag", flow, 0, "Eat")
	local _0 = not _1

	if _0 then
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "Find")
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "EatBreak")
		flow:setActive()
		_A(flow, "AddAITag", 0, "Eat")

		return true
	end
end

function _M._to_230_0(flow)
	local _1 = _C(229, "HasAITag", flow, 0, "Find")
	local _0 = not _1

	if _0 then
		return _M._to_261_0(flow)
	end
end

function _M._to_261_0(flow)
	local _0 = _M._get_263_2(flow)

	if _0 then
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "Eat")
		flow:setActive()
		_A(flow, "AddAITag", 0, "Find")

		return true
	end

	local _2 = _M._get_263_2(flow)
	local _1 = not _2

	if _1 then
		flow:setActive()
		_A(flow, "AddAITag", 0, "EatBreak")
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "Eat")
		flow:setActive()
		_A(flow, "AddAITag", 0, "Find")

		return true
	end
end

function _M._get_126_3(flow)
	local _0 = _C(128, "GetAoiEntityTableByLevel", flow, 0, 30, 64)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(126, "__iterItem", v)

		if _M._get_138_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_126_2(flow)
	return flow:getCache(126, "__iterItem")
end

function _M._get_138_2(flow)
	local _2 = _M._get_126_2(flow)
	local _0 = _C(125, "HasEntityTag", flow, _2, "TE_Chest_Collectible")

	if not _0 then
		return false
	end

	local _3 = _M._get_126_2(flow)
	local _4 = _C(131, "GetDistance", flow, _3, 0, false)
	local _1 = _4 <= 0.8

	if not _1 then
		return false
	end

	return true
end

function _M._get_140_1(flow)
	local _0 = _M._get_126_3(flow)

	return not _0 or next(_0) == nil
end

function _M._get_143_2(flow)
	local _2 = _M._get_145_2(flow)
	local _0 = _C(144, "HasEntityTag", flow, _2, "TE_Chest_Collectible")

	if not _0 then
		return false
	end

	local _4 = _M._get_145_2(flow)
	local _3 = _C(148, "GetDistance", flow, _4, 0, false)
	local _1 = _3 <= 15

	if not _1 then
		return false
	end

	return true
end

function _M._get_145_2(flow)
	return flow:getCache(145, "__iterItem")
end

function _M._get_145_3(flow)
	local _0 = _C(142, "GetAoiEntityTableByLevel", flow, 0, 30, 64)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(145, "__iterItem", v)

		if _M._get_143_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_263_2(flow)
	return _C(263, "HasAITag", flow, 0, "EatBreak")
end

return _M
