-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_10031JumpOverRiver_MakeGroup.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_24_0(flow)
end

function _M._to_24_0(flow)
	local _0 = _M._get_25_2(flow)

	if _0 then
		flow:setActive()

		local _2 = _M._get_21_3(flow)
		local _3 = _C(22, "SelectOneByRandom", flow, _2)
		local _1 = _C(23, "UnpackResPointPort", flow, _3, 1)

		_A(flow, "JoinResPointBehaviour", 0, _1)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_21_3(flow)
	return _C(21, "GetAoiResPointPortTableByLevel", flow, 0, 50, 10, {
		"TR_GB_10031JumpOverRiver"
	}, nil)
end

function _M._get_25_2(flow)
	local _2 = _C(27, "IsInGroupBehaviour", flow, 0, true, nil)
	local _0 = not _2

	if not _0 then
		return false
	end

	local _3 = _M._get_21_3(flow)
	local _4 = not _3 or next(_3) == nil
	local _1 = not _4

	if not _1 then
		return false
	end

	return true
end

return _M
