-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10441_DiscoverInvisible.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_231_0(flow)
end

function _M._to_231_0(flow)
	local _0 = _M._get_239_4(flow)

	if _0 then
		flow:setActive()

		local _1 = _C(230, "GetSelfId", flow)

		_A(flow, "SendMessageToTrigger", _1, 1044102)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_239_4(flow)
	local _5 = _M._get_244_1(flow)
	local _6 = _5 == 0
	local _0 = not _6

	if not _0 then
		return false
	end

	local _9 = _M._get_244_1(flow)
	local _10 = _C(249, "GetPerceptibilityValue", flow, _9)
	local _1 = _10 >= 10

	if not _1 then
		return false
	end

	local _4 = _M._get_244_1(flow)
	local _2 = _C(238, "IsControllingPet", flow, _4)

	if not _2 then
		return false
	end

	local _7 = _M._get_244_1(flow)
	local _8 = _C(235, "GetControllingPetActorId", flow, _7)
	local _3 = _C(247, "CheckIsCamouflage", flow, _8)

	if not _3 then
		return false
	end

	return true
end

function _M._get_244_1(flow)
	local _0 = _C(243, "GetPerceptibilityTable", flow)

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

return _M
