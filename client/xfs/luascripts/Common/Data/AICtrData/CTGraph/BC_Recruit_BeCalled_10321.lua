-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Recruit_BeCalled_10321.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_49_0(flow)
end

function _M._to_49_0(flow)
	local _2 = _M._get_53_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _0 = not _3

	if _0 then
		flow:setActive()

		local _1 = _C(50, "GetSelfId", flow)

		_A(flow, "SendMessageToTrigger", _1, 1032101)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_46_5(flow)
	local _3 = _M._get_53_2(flow)
	local _0 = _C(42, "IsControllingPet", flow, _3)

	if not _0 then
		return false
	end

	local _4 = _M._get_53_2(flow)
	local _5 = _C(41, "GetControllingPetActorId", flow, _4)
	local _6 = _C(44, "GetPetData", flow, _5, "baseFormPet", true, 0)
	local _1 = _6 == 1032300

	if not _1 then
		return false
	end

	if false then
		return false
	end

	if false then
		return false
	end

	local _7 = _C(48, "GetSelfId", flow)
	local _2 = _C(47, "IsInBehavTag", flow, _7, "TB_Recuit")

	if not _2 then
		return false
	end

	return true
end

function _M._get_53_3(flow)
	local _0 = _C(51, "GetAoiEntityTableByLevel", flow, 0, 30, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(53, "__iterItem", v)

		if _M._get_46_5(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_53_2(flow)
	return flow:getCache(53, "__iterItem")
end

return _M
