-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_Braveman_MakeGroup.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_78_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 67 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_78_0(flow)
	local _0 = _M._get_79_2(flow)

	if _0 then
		flow:setActive()

		local _2 = _M._get_75_3(flow)
		local _3 = _C(76, "SelectOneByRandom", flow, _2)
		local _1 = _C(77, "UnpackResPointPort", flow, _3, 1)

		_A(flow, "JoinResPointBehaviour", 0, _1)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_71_1(flow)
	local _0 = _C(70, "GetAoiResPointPortTableByLevel", flow, 0, 30, 0, {
		"TR_GB_Braveman"
	}, {
		""
	})

	return _C(71, "SelectOneByRandom", flow, _0)
end

function _M._get_75_3(flow)
	return _C(75, "GetAoiResPointPortTableByLevel", flow, 0, 30, 2, {
		"TR_GB_Braveman"
	}, nil)
end

function _M._get_79_2(flow)
	local _2 = _C(81, "IsInGroupBehaviour", flow, 0, true, nil)
	local _0 = not _2

	if not _0 then
		return false
	end

	local _3 = _M._get_75_3(flow)
	local _4 = not _3 or next(_3) == nil
	local _1 = not _4

	if not _1 then
		return false
	end

	return true
end

return _M
