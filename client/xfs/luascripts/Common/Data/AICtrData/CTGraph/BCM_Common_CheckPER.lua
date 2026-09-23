-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BCM_Common_CheckPER.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.getMacroValue(flow, valueName)
	if valueName == "tIsPlayer" then
		return _M._get_31_2(flow)
	end

	if valueName == "tIsPuppet" then
		return _M._get_42_2(flow)
	end

	if valueName == "tIsPlayerInterrupt" then
		return _M._get_55_2(flow)
	end

	if valueName == "tPetNotCurrPet" then
		return _M._get_58_2(flow)
	end
end

function _M._get_14_0(flow)
	return flow:getContextValue("tActorId")
end

function _M._get_31_2(flow)
	local _2 = _M._get_14_0(flow)
	local _0 = _C(28, "IsEntityType", flow, _2, "ACTOR_TYPE_PLAYER")

	if _0 then
		return true
	end

	local _1 = _M._get_35_2(flow)

	if _1 then
		return true
	end

	return false
end

function _M._get_35_2(flow)
	local _2 = _M._get_14_0(flow)
	local _0 = _C(29, "IsEntityType", flow, _2, "ACTOR_TYPE_PET")

	if not _0 then
		return false
	end

	local _4 = _M._get_14_0(flow)
	local _3 = _C(34, "GetPetMaster", flow, _4)
	local _1 = _C(33, "IsControllingPet", flow, _3)

	if not _1 then
		return false
	end

	return true
end

function _M._get_41_2(flow)
	local _2 = _M._get_14_0(flow)
	local _0 = _C(36, "IsEntityType", flow, _2, "ACTOR_TYPE_PET")

	if not _0 then
		return false
	end

	local _3 = _M._get_14_0(flow)
	local _4 = _C(37, "GetPetMaster", flow, _3)
	local _5 = _C(39, "IsControllingPet", flow, _4)
	local _1 = not _5

	if not _1 then
		return false
	end

	return true
end

function _M._get_42_2(flow)
	local _2 = _M._get_14_0(flow)
	local _0 = _C(32, "IsEntityType", flow, _2, "ACTOR_TYPE_PUPPET")

	if _0 then
		return true
	end

	local _1 = _M._get_41_2(flow)

	if _1 then
		return true
	end

	return false
end

function _M._get_46_2(flow)
	local _2 = _M._get_14_0(flow)
	local _0 = _C(43, "IsEntityType", flow, _2, "ACTOR_TYPE_PLAYER")

	if not _0 then
		return false
	end

	local _3 = _M._get_14_0(flow)
	local _1 = _C(44, "IsControllingPet", flow, _3)

	if not _1 then
		return false
	end

	return true
end

function _M._get_47_2(flow)
	local _0 = _M._get_14_0(flow)

	return _C(47, "IsEntityType", flow, _0, "ACTOR_TYPE_PET")
end

function _M._get_49_1(flow)
	local _0 = _M._get_14_0(flow)

	return _C(49, "GetPetMaster", flow, _0)
end

function _M._get_53_2(flow)
	local _0 = _M._get_47_2(flow)

	if not _0 then
		return false
	end

	local _2 = _M._get_61_2(flow)
	local _1 = not _2

	if not _1 then
		return false
	end

	return true
end

function _M._get_55_2(flow)
	local _0 = _M._get_46_2(flow)

	if _0 then
		return true
	end

	local _1 = _M._get_53_2(flow)

	if _1 then
		return true
	end

	return false
end

function _M._get_58_2(flow)
	local _0 = _M._get_47_2(flow)

	if not _0 then
		return false
	end

	local _2 = _M._get_14_0(flow)
	local _3 = _C(57, "IsCurCombatPet", flow, _2)
	local _1 = not _3

	if not _1 then
		return false
	end

	return true
end

function _M._get_61_2(flow)
	local _2 = _M._get_49_1(flow)
	local _0 = _C(50, "IsControllingPet", flow, _2)

	if not _0 then
		return false
	end

	local _3 = _M._get_14_0(flow)
	local _4 = _M._get_49_1(flow)
	local _5 = _C(51, "GetControllingPetActorId", flow, _4)
	local _1 = _3 == _5

	if not _1 then
		return false
	end

	return true
end

return _M
