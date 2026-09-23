-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Npc_Common_ActivateAIRoute.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction

function _M.executeEventTrigger(flow, eventName)
	if eventName == "NpcStatusChangeTrigger" then
		return _M._to_40_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 31 then
		return _M._to_29_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_27_0(flow)
	flow:setActive()
	_A(flow, "DebugVar", "状态过滤", 0, 0, false, nil)
	flow:setActive()
	_A(flow, "DebugVar", "最终行为", 0, 0, false, nil)
	flow:setActive()
	_A(flow, "DebugVar", "读数测试", 0, 0, false, nil)

	return true
end

function _M._to_29_0(flow)
	flow:setActive()

	local _0 = _C(30, "GetStaticId", flow, 0)
	local _2 = _M._get_25_2(flow)
	local _1 = _C(63, "GetTableValueByKey", flow, _2, "id")

	_A(flow, "SetNpcStatus", _0, _1, 2, false)

	return true
end

function _M._to_31_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_35_2(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(31)

		return true
	end
end

function _M._to_40_0(flow)
	local _1 = _M._get_65_3(flow)
	local _2 = not _1 or next(_1) == nil
	local _0 = not _2

	if _0 then
		flow:setActive()
		_A(flow, "DebugVar", "行为debug", 0, 0, false, nil)

		return _M._to_31_0(flow)
	end
end

function _M._get_25_2(flow)
	local _0 = _M._get_65_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(25, "__iterItem", v)

		_1 = _M._get_26_2(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _3 < _1 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_26_2(flow)
	local _0 = flow:getCache(25, "__iterItem")

	return _C(26, "GetTableValueByKey", flow, _0, "priority")
end

function _M._get_35_2(flow)
	local _1 = _M._get_25_2(flow)
	local _0 = _C(32, "GetTableValueByKey", flow, _1, "behavParams")

	return _C(35, "GetTableValueByKey", flow, _0, 1)
end

function _M._get_65_3(flow)
	local _0 = flow:getSubMacro("BCM_Npc_GetRunningStatus")
	local _1 = _C(66, "GetStaticId", flow, 0)

	_0:setContextValue("behavName", "ActivateAIRoute")
	_0:setContextValue("staticId", _1)
	_0:setContextValue("status", 1)

	local _2 = _0:getMacroValue("resList")

	flow:clearSubMacro(_0)

	return _2
end

return _M
