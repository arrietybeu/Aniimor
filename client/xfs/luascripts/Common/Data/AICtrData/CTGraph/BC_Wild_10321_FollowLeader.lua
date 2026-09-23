-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10321_FollowLeader.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_10_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 10 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_10_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_12_1(flow)

	if _0 then
		flow:setActive()
		_C(10, "DoBehaviour", flow, "PBT_Wild_10321_FollowOneByOne")

		local _1 = _M._get_11_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tFollowEntActorID", _1)
		flow.__agent:addSubTreeLocalParam("tFollowStopDist", 2)
		flow:setContinue(10)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_11_1(flow)
	return _C(11, "GetLeaderId", flow, 0)
end

function _M._get_12_1(flow)
	local _0 = _M._get_11_1(flow)

	return _C(12, "CheckEntityExist", flow, _0)
end

return _M
