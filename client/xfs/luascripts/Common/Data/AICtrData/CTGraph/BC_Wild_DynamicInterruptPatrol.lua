-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_DynamicInterruptPatrol.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_11_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "SetVisionAreaOverride", "visionAreaDefault")
	flow:setActive()

	local _0 = _C(15, "GetSelfId", flow)

	_A(flow, "HideEmojiOnTarget", _0, "")
	flow:setActive()
	_A(flow, "RemoveBuff", 0, 2126101)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 11 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 11 then
		return _M._get_36_1(flow)
	end
end

function _M._to_11_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_8_1(flow)
	local _1 = _M.checkInterrupt(flow, 11)

	if _0 and not _1 then
		flow:setActive()

		local _2 = _M._get_9_8(flow)

		if _P(flow, 1, _2, 1, nil) then
			flow:setContinue(11)

			return true
		end
	else
		flow:setActiveFail()
	end
end

function _M._get_8_1(flow)
	local _1 = _M._get_32_1(flow)
	local _0 = _1 == 0

	return not _0
end

function _M._get_9_8(flow)
	local _0 = _C(16, "GetDayTime", flow)

	return _C(9, "GetRouteIdFromEntity", flow, 0, _0, 0, 0, "", "", "", "")
end

function _M._get_32_1(flow)
	local _0 = flow:getCache(32, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_9_8(flow)

	flow:setCache(32, "1", _0)

	return _0
end

function _M._get_36_1(flow)
	local _1 = _M._get_32_1(flow)
	local _2 = _C(33, "GetDayTime", flow)
	local _3 = _C(34, "GetRouteIdFromEntity", flow, 0, _2, 0, 0, "", "", "", "")
	local _0 = _1 == _3

	return not _0
end

return _M
