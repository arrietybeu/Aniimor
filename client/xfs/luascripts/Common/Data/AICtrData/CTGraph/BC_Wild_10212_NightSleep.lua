-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10212_NightSleep.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_9_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 9 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_9_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_6_2(flow)

	if _0 then
		flow:setActive()
		_C(9, "DoBehaviour", flow, "PBT_Sleep")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("sleepTimeOut", 30)
		flow.__agent:addSubTreeLocalParam("tShowEmojiBubble", true)
		flow.__agent:addSubTreeLocalParam("tisLoop", false)
		flow:setContinue(9)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_6_2(flow)
	local _0 = _C(5, "GetDayTime", flow)

	return _C(6, "IsSameDayTime", flow, _0, 2)
end

return _M
