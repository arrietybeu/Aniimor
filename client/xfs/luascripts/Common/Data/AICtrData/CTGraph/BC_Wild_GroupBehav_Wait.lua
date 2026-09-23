-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_Wait.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeEventTrigger(flow, eventName)
	if eventName == "GroupBehavWaitTrigger" then
		return _M._to_1_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 1 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 1 then
		return _M._get_6_1(flow)
	end
end

function _M._to_1_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 1)

	if not _1 then
		flow:setActive()
		_C(1, "DoBehaviour", flow, "PBT_Com_Node_Wait")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 999999)
		flow:setContinue(1)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_6_1(flow)
	local _1 = _C(5, "GetSelfId", flow)
	local _0 = _C(4, "IsInGroupBehaviour", flow, _1, true, "Any")

	return not _0
end

return _M
