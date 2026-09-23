-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_PetActionMode_InvadeInterrupt.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_39_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 39 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_39_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_22_3(flow)

	if _0 then
		flow:setActive()
		_C(39, "DoBehaviour", flow, "PBT_PetActionMode_InvadeInterrupt")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetID", 0)
		flow:setContinue(39)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_21_2(flow)
	local _0 = _C(19, "CheckPetActionMode", flow, 1, 0)

	if _0 then
		return true
	end

	local _1 = _C(20, "CheckPetActionMode", flow, 0, 0)

	if _1 then
		return true
	end

	return false
end

function _M._get_22_3(flow)
	local _0 = _M._get_21_2(flow)

	if not _0 then
		return false
	end

	local _5 = _C(35, "GetSelfId", flow)
	local _3 = _C(32, "GetAIBlackboardValue", flow, _5, "tgt")
	local _4 = _C(23, "IsPlayerInCombat", flow, _3)
	local _1 = not _4

	if not _1 then
		return false
	end

	local _6 = _C(37, "GetSelfId", flow)
	local _7 = _C(36, "GetAIBlackboardValue", flow, _6, "isEnterCombatByInvadeMode")
	local _2 = _7 == true

	if not _2 then
		return false
	end

	return true
end

return _M
