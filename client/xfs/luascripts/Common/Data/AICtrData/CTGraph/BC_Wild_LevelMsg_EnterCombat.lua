-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_LevelMsg_EnterCombat.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsg_EnterCombat" then
		return _M._to_98_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 98 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_98_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_103_1(flow)

	if _0 then
		flow:setActive()
		_C(98, "DoBehaviour", flow, "PBT_ReadyToFightwithoutQuestionMark")

		local _1 = _M._get_100_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tSensorTgtId", _1)
		flow.__agent:addSubTreeLocalParam("tRandomWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tShowExclamation", false)
		flow:setContinue(98)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_99_1(flow)
	return _C(99, "GetAoiEntityTableByLevel", flow, 0, 100, 2)
end

function _M._get_100_2(flow)
	local _0 = _M._get_99_1(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(100, "__iterItem", v)

		_1 = _M._get_101_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_101_3(flow)
	local _0 = flow:getCache(100, "__iterItem")

	return _C(101, "GetDistance", flow, _0, 0, false)
end

function _M._get_103_1(flow)
	local _1 = _M._get_99_1(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

return _M
