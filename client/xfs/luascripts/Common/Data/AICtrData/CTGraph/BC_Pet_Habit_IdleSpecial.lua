-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_Habit_IdleSpecial.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_159_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 159 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_159_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_149_4(flow)

	if _0 then
		flow:setActive()
		_C(159, "DoBehaviour", flow, "PBT_Node_Com_IdleSpecial")
		flow.__agent:clearSubTreeLocalParams()
		flow:setContinue(159)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_149_4(flow)
	local _6 = _M._get_150_0(flow)
	local _0 = _C(160, "IsInCharState", flow, _6, 1, 4)

	if not _0 then
		return false
	end

	local _3 = _M._get_150_0(flow)
	local _4 = _C(151, "GetAnimTagDuration", flow, _3)
	local _1 = _4 > 4

	if not _1 then
		return false
	end

	local _5 = _C(154, "RandomInteger", flow, 1, 10)
	local _2 = _5 < 5

	if not _2 then
		return false
	end

	if false then
		return false
	end

	return true
end

function _M._get_150_0(flow)
	return _C(150, "GetSelfId", flow)
end

return _M
