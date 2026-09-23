-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_LevelMsg_DoRoute.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _P = CTHelper.DoPatrolBehavior

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsg_Route" then
		return _M._to_95_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 95 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_95_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_97_1(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_94_1(flow)
		local _2 = flow:getContextValue("loopTime")

		if _P(flow, 1, _1, _2, nil) then
			flow:setContinue(95)

			return true
		end
	else
		flow:setActiveFail()
	end
end

function _M._get_94_1(flow)
	return flow:getContextValue("routeId")
end

function _M._get_97_1(flow)
	local _1 = _M._get_94_1(flow)
	local _0 = _1 == 0

	return not _0
end

return _M
