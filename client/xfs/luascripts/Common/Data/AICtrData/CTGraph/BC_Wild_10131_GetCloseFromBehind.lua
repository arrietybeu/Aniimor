-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10131_GetCloseFromBehind.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_44_0(flow)
end

function _M._to_44_0(flow)
	local _0 = _M._get_73_3(flow)

	if _0 then
		flow:setActive()

		local _1 = _C(76, "GetSelfId", flow)

		_A(flow, "SendMessageToTrigger", _1, 1013101)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_66_1(flow)
	local _0 = _C(64, "GetPerceptibilityTable", flow)

	if _0 == nil then
		return
	end

	local key = next(_0)
	local value = _0[key]

	for k, v in pairs(_0) do
		if value < v then
			key, value = k, v
		end
	end

	return key
end

function _M._get_73_3(flow)
	local _5 = _M._get_66_1(flow)
	local _0 = _C(72, "IsInRange", flow, _5, 0, true, 0, 0, 0, 0, 120, 240, 10, -2, 2)

	if not _0 then
		return false
	end

	local _3 = _M._get_66_1(flow)
	local _4 = _C(65, "GetPerceptibilityValue", flow, _3)
	local _1 = _4 >= 10

	if not _1 then
		return false
	end

	local _6 = _C(77, "GetSelfId", flow)
	local _7 = _C(78, "GetPuppetData", flow, _6, "baseFormPet", true, 0)
	local _2 = _7 == 1013100

	if not _2 then
		return false
	end

	return true
end

function _M._get_74_1(flow)
	return _C(74, "GetAoiEntityTableByLevel", flow, 0, 30, 2)
end

return _M
