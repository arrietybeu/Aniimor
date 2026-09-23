-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_10291CrossRiver.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior

function _M.executeEventTrigger(flow, eventName)
	if eventName == "GBPMsg_ResPointJump" then
		return _M._to_5_0(flow)
	end

	if eventName == "GBPMsg_ResPointWatch" then
		return _M._to_8_0(flow)
	end

	if eventName == "GBPMsg_ResPointGO1" then
		return _M._to_11_0(flow)
	end

	if eventName == "GBPMsg_ResPointGO2" then
		return _M._to_14_0(flow)
	end

	if eventName == "GBPMsg_ResPointGO3" then
		return _M._to_17_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 5 then
		return true
	end

	if nodeId == 8 then
		return true
	end

	if nodeId == 11 then
		return true
	end

	if nodeId == 14 then
		return true
	end

	if nodeId == 17 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_5_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_6_1(flow)

	if _P(flow, 1, _0, -1, nil) then
		flow:setContinue(5)

		return true
	end
end

function _M._to_8_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_10_1(flow)

	if _P(flow, 1, _0, -1, nil) then
		flow:setContinue(8)

		return true
	end
end

function _M._to_11_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_12_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(11)

		return true
	end
end

function _M._to_14_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_15_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(14)

		return true
	end
end

function _M._to_17_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_18_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(17)

		return true
	end
end

function _M._get_6_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(6, "GetRouteIdFromResPoint", flow, true, _0, 1)
end

function _M._get_10_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(10, "GetRouteIdFromResPoint", flow, true, _0, 2)
end

function _M._get_12_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(12, "GetRouteIdFromResPoint", flow, true, _0, 3)
end

function _M._get_15_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(15, "GetRouteIdFromResPoint", flow, true, _0, 4)
end

function _M._get_18_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(18, "GetRouteIdFromResPoint", flow, true, _0, 5)
end

return _M
