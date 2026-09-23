-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Npc_DailyCommon.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeEventTrigger(flow, eventName)
	if eventName == "TimePeriodChangeTrigger" then
		return _M._to_6_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 17 then
		return true
	end

	if nodeId == 18 then
		return true
	end

	if nodeId == 21 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_6_0(flow)
	local _1 = _M._get_5_1(flow)
	local _2 = not _1 or next(_1) == nil
	local _0 = not _2

	if _0 then
		return _M._to_7_0(flow)
	end
end

function _M._to_7_0(flow)
	local _3 = _M._get_11_2(flow)
	local _0 = _3 == "ActivateAIRoute"

	if _0 then
		return _M._to_17_0(flow)
	end

	local _4 = _M._get_11_2(flow)
	local _1 = _4 == "ActivateLoopState"

	if _1 then
		return _M._to_18_0(flow)
	end

	local _5 = _M._get_11_2(flow)
	local _2 = _5 == "ActivateRandomState"

	if _2 then
		return _M._to_21_0(flow)
	end
end

function _M._to_17_0(flow)
	flow:setActive()

	local _0 = flow:getSubFlow("BC_Npc_Sub_PlayRoute")
	local _1 = _M._get_19_2(flow)

	_0:setContextValue("Params", _1)

	if _0:executeSubFlow() then
		flow:setContinue(17)

		if _0:isFinish() then
			return flow:executeContinue()
		end

		return true
	end
end

function _M._to_18_0(flow)
	flow:setActive()

	local _0 = flow:getSubFlow("BC_Npc_Sub_PlayLoopState")
	local _1 = _M._get_19_2(flow)

	_0:setContextValue("Params", _1)

	if _0:executeSubFlow() then
		flow:setContinue(18)

		if _0:isFinish() then
			return flow:executeContinue()
		end

		return true
	end
end

function _M._to_21_0(flow)
	flow:setActive()

	local _0 = flow:getSubFlow("BC_Npc_Sub_PlayLoopState")
	local _1 = _M._get_19_2(flow)

	_0:setContextValue("Params", _1)

	if _0:executeSubFlow() then
		flow:setContinue(21)

		if _0:isFinish() then
			return flow:executeContinue()
		end

		return true
	end
end

function _M._get_5_1(flow)
	local _1 = _C(1, "GetEntConfigData", flow, 0, "npcDailyBehaviorStatus")
	local _2 = _C(3, "GetDayTime", flow)
	local _0 = _C(2, "GetTableValueByKey", flow, _1, _2)

	return _C(5, "GetNpcStatusConfigData", flow, _0)
end

function _M._get_11_2(flow)
	local _0 = _M._get_5_1(flow)

	return _C(11, "GetTableValueByKey", flow, _0, "behavName")
end

function _M._get_19_2(flow)
	local _0 = _M._get_5_1(flow)

	return _C(19, "GetTableValueByKey", flow, _0, "behavParams")
end

return _M
