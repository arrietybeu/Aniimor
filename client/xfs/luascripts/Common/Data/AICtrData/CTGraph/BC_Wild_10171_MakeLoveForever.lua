-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10171_MakeLoveForever.lua

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

local _tickLodTriggerLevel = 10

function _M.getTickLodTriggerLevel()
	return _tickLodTriggerLevel
end

function _M.executeTickLodTrigger(flow)
	return _M._to_82_0(flow)
end

function _M._to_72_0(flow)
	flow:setActive()

	local _0 = _M._get_71_0(flow)

	_C(72, "DoAction", flow, "LerpProperty", false, 1, _0)

	return true
end

function _M._to_82_0(flow)
	return _M._to_72_0(flow)
end

function _M._get_71_0(flow)
	return _C(71, "GetSelfId", flow)
end

return _M
