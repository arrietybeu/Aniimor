-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10131_BoneskyWild.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _P = CTHelper.DoPatrolBehavior

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerHintMakeIce" then
		return _M._to_19_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 19 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_19_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 87706178, 1, nil) then
		flow:setContinue(19)

		return true
	end
end

return _M
