-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_MiserBro_Judge.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_135_0(flow)
end

function _M._to_135_0(flow)
	local _0 = _M._get_133_3(flow)

	if _0 then
		return _M._to_138_0(flow)
	end

	local _2 = _M._get_133_3(flow)
	local _1 = not _2

	if _1 then
		return _M._to_145_0(flow)
	end
end

function _M._to_138_0(flow)
	local _1 = _C(136, "HasAITag", flow, 0, "ChestExist")
	local _0 = not _1

	if _0 then
		flow:setActive()
		_A(flow, "AddAITag", 0, "ChestExist")

		return true
	end
end

function _M._to_145_0(flow)
	local _0 = _M._get_122_2(flow)

	if _0 then
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "ChestExist")

		return true
	end
end

function _M._get_121_1(flow)
	local _0 = _M._get_122_2(flow)

	return not _0
end

function _M._get_122_2(flow)
	return _C(122, "HasAITag", flow, 0, "ChestExist")
end

function _M._get_125_3(flow)
	local _0 = _C(123, "GetAoiEntityTableByLevel", flow, 0, 30, 64)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(125, "__iterItem", v)

		if _M._get_126_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_125_2(flow)
	return flow:getCache(125, "__iterItem")
end

function _M._get_126_2(flow)
	local _0 = _M._get_125_2(flow)

	return _C(126, "HasEntityTag", flow, _0, "TE_Chest_Metal")
end

function _M._get_131_2(flow)
	local _0 = _M._get_125_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(131, "__iterItem", v)

		_1 = _M._get_132_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_132_3(flow)
	local _0 = flow:getCache(131, "__iterItem")

	return _C(132, "GetDistance", flow, _0, 0, false)
end

function _M._get_133_3(flow)
	local _3 = _M._get_125_3(flow)
	local _4 = not _3 or next(_3) == nil
	local _0 = not _4

	if not _0 then
		return false
	end

	local _6 = _M._get_147_3(flow)
	local _7 = not _6 or next(_6) == nil
	local _1 = not _7

	if not _1 then
		return false
	end

	local _8 = _M._get_131_2(flow)
	local _9 = _M._get_151_2(flow)
	local _5 = _C(153, "GetDistance", flow, _8, _9, false)
	local _2 = _5 < 3

	if not _2 then
		return false
	end

	return true
end

function _M._get_147_3(flow)
	local _0 = _C(144, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(147, "__iterItem", v)

		if _M._get_148_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_147_2(flow)
	return flow:getCache(147, "__iterItem")
end

function _M._get_148_2(flow)
	local _0 = _M._get_147_2(flow)

	return _C(148, "HasEntityTag", flow, _0, "TE_Env_UniversalMark_B")
end

function _M._get_151_2(flow)
	local _0 = _M._get_147_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(151, "__iterItem", v)

		_1 = _M._get_152_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_152_3(flow)
	local _0 = flow:getCache(151, "__iterItem")

	return _C(152, "GetDistance", flow, _0, 0, false)
end

return _M
