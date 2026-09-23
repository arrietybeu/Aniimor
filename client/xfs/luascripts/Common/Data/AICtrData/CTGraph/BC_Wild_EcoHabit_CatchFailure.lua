-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_EcoHabit_CatchFailure.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "CatchResult_Failure" then
		return _M._to_14_0(flow)
	end
end

function _M._to_14_0(flow)
	local _3 = _C(29, "HasEntityTag", flow, 0, "TE_Wild_CatchFailure_1", "TE_Wild_CatchFailure_2")
	local _0 = not _3

	if _0 then
		flow:setActive()
		_A(flow, "AddEntityTag", 0, "TE_Wild_CatchFailure_1")
		flow:setActive()
		_C(38, "SetAIBlackboardValue", flow, 0, "catchFailureLeaveTimeout", 3)

		return true
	end

	local _1 = _M._get_19_2(flow)

	if _1 then
		flow:setActive()
		_A(flow, "AddEntityTag", 0, "TE_Wild_CatchFailure_2")
		flow:setActive()
		_C(39, "SetAIBlackboardValue", flow, 0, "catchFailureLeaveTimeout", 1.5)

		return true
	end

	local _2 = _M._get_24_2(flow)

	if _2 then
		flow:setActive()
		_A(flow, "AddEntityTag", 0, "TE_Wild_CatchFailure_3")
		flow:setActive()
		_C(40, "SetAIBlackboardValue", flow, 0, "catchFailureLeaveTimeout", 0.5)

		return true
	end
end

function _M._get_19_2(flow)
	local _0 = _C(30, "HasEntityTag", flow, 0, "TE_Wild_CatchFailure_1")

	if not _0 then
		return false
	end

	local _2 = _C(31, "HasEntityTag", flow, 0, "TE_Wild_CatchFailure_2")
	local _1 = not _2

	if not _1 then
		return false
	end

	return true
end

function _M._get_24_2(flow)
	local _0 = _C(32, "HasEntityTag", flow, 0, "TE_Wild_CatchFailure_1")

	if not _0 then
		return false
	end

	local _1 = _C(33, "HasEntityTag", flow, 0, "TE_Wild_CatchFailure_2")

	if not _1 then
		return false
	end

	return true
end

return _M
