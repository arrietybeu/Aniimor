-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10261_IdleInCloud.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_108_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 108 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_108_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_115_2(flow)

	if _0 then
		flow:setActive()
		_C(108, "DoBehaviour", flow, "PBT_Com_Node_Wait")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 100)
		flow:setContinue(108)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_115_2(flow)
	local _3 = _C(116, "GetSelfId", flow)
	local _0 = _C(117, "HasAITag", flow, _3, "TA_InLowGravity")

	if not _0 then
		return false
	end

	local _2 = _C(113, "GetRouteIdFromEntity", flow, 0, 0, 0, 0, "", "", "", "")
	local _1 = _2 == 0

	if not _1 then
		return false
	end

	return true
end

return _M
