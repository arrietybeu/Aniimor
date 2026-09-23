-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_SeekLove_Love_Sing.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local CTRConst = require("Common.AICt.CTRConst")
local _M = {}
local _C = CTHelper.SafeCall
local _eventTriggerList = {}

function _M.getEventTriggerList()
	return _eventTriggerList
end

local _messageTriggerList = {}

function _M.getMessageTriggerList()
	return _messageTriggerList
end

local _tickLodTriggerLevel = -1

function _M.getTickLodTriggerLevel()
	return _tickLodTriggerLevel
end

function _M.executeSubFlow(flow)
	return _M._to_8_0(flow)
end

function _M._to_8_0(flow)
	flow:setActive()

	return true
end

return _M
