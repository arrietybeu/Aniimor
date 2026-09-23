-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_Leave_RB.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_64_0(flow)
end

function _M._to_64_0(flow)
	local _0 = _M._get_68_2(flow)

	if _0 then
		flow:setActive()

		local _1 = _C(63, "GetSelfId", flow)

		_A(flow, "SendMessageToTrigger", _1, 1033302)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_60_1(flow)
	local _0 = _C(61, "GetPerceptibilityTable", flow)

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

function _M._get_67_3(flow)
	local _8 = _M._get_60_1(flow)
	local _6 = _8 == 0
	local _0 = not _6

	if not _0 then
		return false
	end

	local _3 = _M._get_60_1(flow)
	local _1 = _C(57, "IsControllingPet", flow, _3)

	if not _1 then
		return false
	end

	local _7 = _M._get_60_1(flow)
	local _4 = _C(69, "GetControllingPetActorId", flow, _7)
	local _5 = _C(56, "GetPetData", flow, _4, "baseFormPet", true, 0)
	local _2 = _5 == 1033300

	if not _2 then
		return false
	end

	return true
end

function _M._get_68_2(flow)
	local _0 = _M._get_67_3(flow)

	if not _0 then
		return false
	end

	local _2 = _C(62, "GetSelfId", flow)
	local _1 = _C(65, "CheckInAIState", flow, _2, "PBT_Wild_10201_Perception_Leave")

	if not _1 then
		return false
	end

	return true
end

return _M
