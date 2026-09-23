-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10021_VisionValue_Full_LeaveHide_RB.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_175_0(flow)
end

function _M._to_175_0(flow)
	local _0 = _M._get_181_2(flow)

	if _0 then
		flow:setActive()

		local _1 = _C(176, "GetSelfId", flow)

		_A(flow, "SendMessageToTrigger", _1, 1002501)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_172_3(flow)
	local _5 = _M._get_180_1(flow)
	local _6 = _5 == 0
	local _0 = not _6

	if not _0 then
		return false
	end

	local _3 = _M._get_180_1(flow)
	local _1 = _C(166, "IsControllingPet", flow, _3)

	if not _1 then
		return false
	end

	local _7 = _M._get_180_1(flow)
	local _8 = _C(169, "GetControllingPetActorId", flow, _7)
	local _4 = _C(184, "GetPetData", flow, _8, "petPrototypeId", true, 0)
	local _2 = _4 == 1002500

	if not _2 then
		return false
	end

	return true
end

function _M._get_180_1(flow)
	local _0 = _C(179, "GetPerceptibilityTable", flow)

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

function _M._get_181_2(flow)
	local _0 = _M._get_172_3(flow)

	if not _0 then
		return false
	end

	local _2 = _C(183, "GetSelfId", flow)
	local _1 = _C(182, "CheckInAIState", flow, _2, "PBT_LeaveTarget")

	if not _1 then
		return false
	end

	return true
end

return _M
