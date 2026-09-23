-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_Habit_Sleep.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_280_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _C(279, "GetSelfId", flow)

	_A(flow, "HideEmojiOnTarget", _0, "Sleep")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 280 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_280_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_273_5(flow)

	if _0 then
		flow:setActive()
		_C(280, "DoBehaviour", flow, "PBT_Behav_Com_Sleep")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tSleepTimeout", 30)
		flow.__agent:addSubTreeLocalParam("tisLoop", false)
		flow:setContinue(280)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_263_0(flow)
	return _C(263, "GetDayTime", flow)
end

function _M._get_272_0(flow)
	return _C(272, "GetSelfId", flow)
end

function _M._get_273_5(flow)
	local _6 = _M._get_272_0(flow)
	local _0 = _C(282, "IsInCharState", flow, _6, 1, 4)

	if not _0 then
		return false
	end

	local _5 = _M._get_272_0(flow)
	local _4 = _C(271, "GetAnimTagDuration", flow, _5)
	local _1 = _4 > 30

	if not _1 then
		return false
	end

	if false then
		return false
	end

	local _3 = _C(268, "RandomInteger", flow, 1, 10)
	local _2 = _3 < 4

	if not _2 then
		return false
	end

	if false then
		return false
	end

	return true
end

return _M
