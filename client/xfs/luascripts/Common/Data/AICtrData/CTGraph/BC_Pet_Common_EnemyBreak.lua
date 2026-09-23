-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_Common_EnemyBreak.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Msg_EnemyBreak" then
		return _M._to_266_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 266 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 266 then
		return _M._get_309_1(flow)
	end
end

function _M._to_266_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_297_3(flow)
	local _1 = _M.checkInterrupt(flow, 266)

	if _0 and not _1 then
		flow:setActive()
		_C(266, "DoBehaviour", flow, "PBT_Com_CombatWander")

		local _2 = _M._get_273_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "CatchHint")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tWaitTime", 2)
		flow.__agent:addSubTreeLocalParam("tOccupyTime", _2)
		flow.__agent:addSubTreeLocalParam("goBackDist", 0)
		flow:setContinue(266)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_272_0(flow)
	return _C(272, "GetPetLockedId", flow)
end

function _M._get_273_2(flow)
	local _2 = _M._get_272_0(flow)
	local _0 = _C(270, "GetEntProperty", flow, _2, "breakEndTime")
	local _1 = _C(269, "GetGameTime", flow)

	return _0 - _1
end

function _M._get_295_2(flow)
	local _2 = _M._get_272_0(flow)
	local _0 = _C(303, "CheckTargetLabel", flow, _2, 2)

	if _0 then
		return true
	end

	local _3 = _M._get_272_0(flow)
	local _1 = _C(304, "CheckTargetLabel", flow, _3, 4)

	if _1 then
		return true
	end

	return false
end

function _M._get_297_3(flow)
	local _3 = _M._get_272_0(flow)
	local _0 = _C(275, "CheckEntIsBreak", flow, _3)

	if not _0 then
		return false
	end

	local _4 = _M._get_295_2(flow)
	local _1 = not _4

	if not _1 then
		return false
	end

	local _5 = _C(307, "CheckPetActionMode", flow, 2, 0)
	local _2 = not _5

	if not _2 then
		return false
	end

	return true
end

function _M._get_309_1(flow)
	return _C(309, "CheckPetActionMode", flow, 2, 0)
end

return _M
