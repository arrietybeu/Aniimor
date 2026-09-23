-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_HelmonBeChased_MakeGroup.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_23_0(flow)
end

function _M._to_23_0(flow)
	local _0 = _M._get_12_3(flow)

	if _0 then
		flow:setActive()

		local _2 = _M._get_3_3(flow)
		local _3 = _C(5, "SelectOneByRandom", flow, _2)
		local _4 = _C(9, "UnpackResPointPort", flow, _3, 1)

		_A(flow, "JoinResPointBehaviour", 0, _4)

		return true
	end

	local _1 = _M._get_37_3(flow)

	if _1 then
		flow:setActive()

		local _5 = _M._get_32_3(flow)
		local _6 = _C(33, "SelectOneByRandom", flow, _5)
		local _7 = _C(34, "UnpackResPointPort", flow, _6, 1)

		_A(flow, "JoinResPointBehaviour", 0, _7)

		return true
	end
end

function _M._get_3_3(flow)
	return _C(3, "GetAoiResPointPortTableByLevel", flow, 0, 30, 5, {
		"TR_GB_HelmonBeChased"
	}, nil)
end

function _M._get_12_3(flow)
	local _3 = _C(17, "IsInGroupBehaviour", flow, 0, true, "GBP_Wild_HelmonBeChased")
	local _0 = not _3

	if not _0 then
		return false
	end

	local _6 = _M._get_52_2(flow)
	local _1 = _6 == 3

	if not _1 then
		return false
	end

	local _4 = _M._get_3_3(flow)
	local _5 = not _4 or next(_4) == nil
	local _2 = not _5

	if not _2 then
		return false
	end

	return true
end

function _M._get_32_3(flow)
	return _C(32, "GetAoiResPointPortTableByLevel", flow, 0, 30, 5, {
		"TR_GB_SaveHelmon_1V1Chase"
	}, nil)
end

function _M._get_37_3(flow)
	local _5 = _C(39, "IsInGroupBehaviour", flow, 0, true, "GBP_Wild_SaveHelmon_1v1Chase")
	local _0 = not _5

	if not _0 then
		return false
	end

	local _1 = _M._get_45_2(flow)

	if not _1 then
		return false
	end

	local _3 = _M._get_32_3(flow)
	local _4 = not _3 or next(_3) == nil
	local _2 = not _4

	if not _2 then
		return false
	end

	return true
end

function _M._get_45_2(flow)
	local _2 = _M._get_52_2(flow)
	local _0 = _2 > 0

	if not _0 then
		return false
	end

	local _3 = _M._get_52_2(flow)
	local _1 = _3 <= 2

	if not _1 then
		return false
	end

	return true
end

function _M._get_47_2(flow)
	return flow:getCache(47, "__iterItem")
end

function _M._get_47_3(flow)
	local _0 = _C(24, "GetAoiEntityTableByLevel", flow, 0, 30, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(47, "__iterItem", v)

		if _M._get_56_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_51_1(flow)
	local _0 = flow:getCache(51, "EntityList")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_47_3(flow)

	flow:setCache(51, "EntityList", _0)

	return _0
end

function _M._get_52_2(flow)
	local _2 = _M._get_51_1(flow)
	local _0 = _C(30, "GetTableLength", flow, _2)
	local _1 = _M._get_53_3(flow)

	return _0 + _1
end

function _M._get_53_3(flow)
	local _0 = _M._get_59_2(flow)

	if _0 then
		return 1
	end

	return 0
end

function _M._get_55_0(flow)
	return _C(55, "GetSelfId", flow)
end

function _M._get_56_2(flow)
	local _2 = _M._get_47_2(flow)
	local _0 = _C(42, "HasEntityTag", flow, _2, "TE_Wild_HelmonBeChased_10022")

	if not _0 then
		return false
	end

	local _3 = _M._get_47_2(flow)
	local _4 = _C(57, "IsPuppetInCallFriend", flow, _3)
	local _1 = not _4

	if not _1 then
		return false
	end

	return true
end

function _M._get_59_2(flow)
	local _2 = _M._get_55_0(flow)
	local _0 = _C(54, "HasEntityTag", flow, _2, "TE_Wild_HelmonBeChased_10022")

	if not _0 then
		return false
	end

	local _4 = _M._get_55_0(flow)
	local _3 = _C(61, "IsPuppetInCallFriend", flow, _4)
	local _1 = not _3

	if not _1 then
		return false
	end

	return true
end

return _M
