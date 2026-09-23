-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10051_LevelMsg_RunAround.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerStartRunAwayShow" then
		return _M._to_28_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 28 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 28 then
		return _M._get_35_1(flow)
	end
end

function _M._to_28_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_29_1(flow)
	local _1 = _M.checkInterrupt(flow, 28)

	if _0 and not _1 then
		flow:setActive()

		local _2 = _M._get_33_1(flow)

		if _P(flow, 1, _2, 1, nil) then
			flow:setContinue(28)

			return true
		end
	else
		flow:setActiveFail()
	end
end

function _M._get_29_1(flow)
	local _1 = _M._get_33_1(flow)
	local _0 = _1 == 0

	return not _0
end

function _M._get_31_8(flow)
	local _0 = _C(36, "GetDayTime", flow)
	local _4 = _M._get_38_0(flow)
	local _1 = _C(37, "GetCurWeatherId", flow, _4)
	local _3 = _M._get_38_0(flow)
	local _2 = _C(32, "GetCurMeteorologyId", flow, _3)

	return _C(31, "GetRouteIdFromEntity", flow, 0, _0, _1, _2, "", "", "", "")
end

function _M._get_33_1(flow)
	local _0 = flow:getCache(33, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_31_8(flow)

	flow:setCache(33, "1", _0)

	return _0
end

function _M._get_35_1(flow)
	local _1 = _M._get_33_1(flow)
	local _2 = _M._get_31_8(flow)
	local _0 = _1 == _2

	return not _0
end

function _M._get_38_0(flow)
	return _C(38, "GetSelfId", flow)
end

return _M
