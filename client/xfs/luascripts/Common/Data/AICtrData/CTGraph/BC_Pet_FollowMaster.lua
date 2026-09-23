-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_FollowMaster.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_6_0(flow)
end

function _M._to_6_0(flow)
	local _0 = _M._get_44_3(flow)

	if _0 then
		flow:setActive()

		local _1 = _C(8, "GetSelfId", flow)
		local _2 = _M._get_7_1(flow)

		_A(flow, "EnterFollow", _1, _2)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_2_3(flow)
	local _0 = _M._get_7_1(flow)

	return _C(2, "GetDistance", flow, _0, 0, false)
end

function _M._get_7_1(flow)
	return _C(7, "GetPetMaster", flow, 0)
end

function _M._get_11_2(flow)
	local _2 = _M._get_31_1(flow)
	local _0 = _2 <= 0.5

	if _0 then
		return true
	end

	local _1 = _M._get_37_4(flow)

	if _1 then
		return true
	end

	return false
end

function _M._get_18_2(flow)
	local _0 = _M._get_19_0(flow)

	return _C(18, "IsInBehavTag", flow, _0, "TB_Pet_ChangeFollowRange_Far2")
end

function _M._get_19_0(flow)
	return _C(19, "GetSelfId", flow)
end

function _M._get_20_2(flow)
	local _0 = _M._get_19_0(flow)

	return _C(20, "IsInBehavTag", flow, _0, "TB_Pet_ChangeFollowRange_Far1")
end

function _M._get_21_2(flow)
	local _0 = _M._get_19_0(flow)

	return _C(21, "IsInBehavTag", flow, _0, "TB_Pet_ChangeFollowRange_Far3")
end

function _M._get_26_2(flow)
	local _0 = _M._get_20_2(flow)

	if not _0 then
		return false
	end

	local _2 = _M._get_31_1(flow)
	local _3 = _C(22, "GlobalBlackBoard", flow, "GC_Pet_Follow_Far1")
	local _1 = _3 <= _2

	if not _1 then
		return false
	end

	return true
end

function _M._get_27_3(flow)
	local _0 = _M._get_20_2(flow)

	if _0 then
		return true
	end

	local _1 = _M._get_18_2(flow)

	if _1 then
		return true
	end

	local _2 = _M._get_21_2(flow)

	if _2 then
		return true
	end

	return false
end

function _M._get_29_2(flow)
	local _2 = _M._get_31_1(flow)
	local _0 = _2 >= 5

	if not _0 then
		return false
	end

	local _3 = _M._get_27_3(flow)
	local _1 = not _3

	if not _1 then
		return false
	end

	return true
end

function _M._get_31_1(flow)
	local _0 = flow:getCache(31, "tempDist")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_2_3(flow)

	flow:setCache(31, "tempDist", _0)

	return _0
end

function _M._get_35_2(flow)
	local _0 = _M._get_18_2(flow)

	if not _0 then
		return false
	end

	local _2 = _M._get_31_1(flow)
	local _3 = _C(23, "GlobalBlackBoard", flow, "GC_Pet_Follow_Far2")
	local _1 = _3 <= _2

	if not _1 then
		return false
	end

	return true
end

function _M._get_36_2(flow)
	local _0 = _M._get_21_2(flow)

	if not _0 then
		return false
	end

	local _2 = _M._get_31_1(flow)
	local _3 = _C(24, "GlobalBlackBoard", flow, "GC_Pet_Follow_Far3")
	local _1 = _3 <= _2

	if not _1 then
		return false
	end

	return true
end

function _M._get_37_4(flow)
	local _0 = _M._get_29_2(flow)

	if _0 then
		return true
	end

	local _1 = _M._get_26_2(flow)

	if _1 then
		return true
	end

	local _2 = _M._get_35_2(flow)

	if _2 then
		return true
	end

	local _3 = _M._get_36_2(flow)

	if _3 then
		return true
	end

	return false
end

function _M._get_42_1(flow)
	return _C(42, "GetPetMaster", flow, 0)
end

function _M._get_44_3(flow)
	local _3 = _M._get_42_1(flow)
	local _4 = _C(40, "GetForbidFollowMasterCharStateList", flow)
	local _5 = _C(39, "IsInCharState", flow, _3, 2, _4)
	local _0 = not _5

	if not _0 then
		return false
	end

	local _6 = _M._get_42_1(flow)
	local _1 = _C(46, "GetEntProperty", flow, _6, "canBeFollowed")

	if not _1 then
		return false
	end

	local _2 = _M._get_11_2(flow)

	if not _2 then
		return false
	end

	return true
end

return _M
