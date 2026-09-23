-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_10281Sleep_MakeGroup.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_34_0(flow)
end

function _M._to_34_0(flow)
	local _0 = _M._get_39_2(flow)

	if _0 then
		flow:setActive()

		local _3 = _M._get_37_3(flow)
		local _2 = _C(36, "SelectOneByRandom", flow, _3)
		local _1 = _C(35, "UnpackResPointPort", flow, _2, 1)

		_A(flow, "JoinResPointBehaviour", 0, _1)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_37_3(flow)
	return _C(37, "GetAoiResPointPortTableByLevel", flow, 0, 30, 10, {
		"TR_GB_10281Sleep"
	}, nil)
end

function _M._get_39_2(flow)
	local _2 = _C(41, "IsInGroupBehaviour", flow, 0, true, nil)
	local _0 = not _2

	if not _0 then
		return false
	end

	local _3 = _M._get_37_3(flow)
	local _4 = not _3 or next(_3) == nil
	local _1 = not _4

	if not _1 then
		return false
	end

	return true
end

return _M
