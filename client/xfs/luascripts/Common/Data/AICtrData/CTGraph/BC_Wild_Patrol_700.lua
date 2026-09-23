-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_Patrol_700.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_85_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "SetVisionAreaOverride", "visionAreaDefault")
	flow:setActive()

	local _0 = _C(15, "GetSelfId", flow)

	_A(flow, "HideEmojiOnTarget", _0, "")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 85 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 85 then
		return _M._get_76_1(flow)
	end
end

function _M._to_85_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_74_1(flow)
	local _1 = _M.checkInterrupt(flow, 85)

	if _0 and not _1 then
		flow:setActive()

		local _2 = _M._get_84_1(flow)

		if _P(flow, 1, _2, 1, nil) then
			flow:setContinue(85)

			return true
		end
	else
		flow:setActiveFail()
	end
end

function _M._get_74_1(flow)
	local _1 = _M._get_84_1(flow)
	local _0 = _1 == 0

	return not _0
end

function _M._get_76_1(flow)
	local _1 = _M._get_84_1(flow)
	local _0 = _C(88, "CheckRouteIdIsValidSimple", flow, _1, 0)

	return not _0
end

function _M._get_80_0(flow)
	return _C(80, "GetDayTime", flow)
end

function _M._get_81_1(flow)
	local _0 = _M._get_83_0(flow)

	return _C(81, "GetCurMeteorologyId", flow, _0)
end

function _M._get_82_1(flow)
	local _0 = _M._get_83_0(flow)

	return _C(82, "GetCurWeatherId", flow, _0)
end

function _M._get_83_0(flow)
	return _C(83, "GetSelfId", flow)
end

function _M._get_84_1(flow)
	local _0 = flow:getCache(84, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_87_1(flow)

	flow:setCache(84, "1", _0)

	return _0
end

function _M._get_87_1(flow)
	return _C(87, "GetRouteIdFromEntitySimple", flow, 0)
end

return _M
