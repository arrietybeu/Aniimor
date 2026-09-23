-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_CourtshipAngry_MakeGroup.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_45_0(flow)
end

function _M._to_45_0(flow)
	local _0 = _M._get_44_2(flow)

	if _0 then
		flow:setActive()

		local _3 = _M._get_42_3(flow)
		local _2 = _C(47, "SelectOneByRandom", flow, _3)
		local _1 = _C(43, "UnpackResPointPort", flow, _2, 1)

		_A(flow, "JoinResPointBehaviour", 0, _1)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_42_3(flow)
	return _C(42, "GetAoiResPointPortTableByLevel", flow, 0, 30, 2, {
		"TR_GB_CourtshipAngry"
	}, nil)
end

function _M._get_44_2(flow)
	local _4 = _C(51, "IsInGroupBehaviour", flow, 0, true, nil)
	local _0 = not _4

	if not _0 then
		return false
	end

	local _3 = _M._get_42_3(flow)
	local _2 = not _3 or next(_3) == nil
	local _1 = not _2

	if not _1 then
		return false
	end

	return true
end

return _M
