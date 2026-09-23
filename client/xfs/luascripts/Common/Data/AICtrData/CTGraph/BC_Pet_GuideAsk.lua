-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_GuideAsk.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_42_0(flow)
end

function _M._to_42_0(flow)
	local _1 = _M._get_4_3(flow)
	local _2 = not _1 or next(_1) == nil
	local _0 = not _2

	if _0 then
		flow:setActive()
		_A(flow, "StartNpcDialog", 70002000, 0)
		flow:setActive()

		local _3 = _C(12, "GetSelfId", flow)
		local _4 = _M._get_4_3(flow)
		local _5 = _C(10, "SelectOneByRandom", flow, _4)

		_A(flow, "EnterPetGuide", _3, _5)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_1_1(flow)
	local _0 = _C(51, "GetPetMaster", flow, 0)

	return _C(1, "GetAoiEntityTableByLevel", flow, _0, 50, 64)
end

function _M._get_3_1(flow)
	local _0 = _M._get_4_2(flow)

	return _C(3, "GetChestGuideLevel", flow, _0)
end

function _M._get_4_2(flow)
	return flow:getCache(4, "__iterItem")
end

function _M._get_4_3(flow)
	local _0 = _M._get_1_1(flow)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(4, "__iterItem", v)

		if _M._get_7_3(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_7_3(flow)
	local _3 = _M._get_3_1(flow)
	local _0 = _3 == 1

	if _0 then
		return true
	end

	local _4 = _M._get_3_1(flow)
	local _1 = _4 == 2

	if _1 then
		return true
	end

	local _5 = _M._get_3_1(flow)
	local _2 = _5 == 3

	if _2 then
		return true
	end

	return false
end

return _M
