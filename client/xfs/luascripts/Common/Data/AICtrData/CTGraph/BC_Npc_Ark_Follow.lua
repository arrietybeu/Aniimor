-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Npc_Ark_Follow.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_3_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 3 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_3_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_23_1(flow)

	if _0 then
		flow:setActive()
		_C(3, "DoBehaviour", flow, "PBT_FollowOneByOne")

		local _1 = _M._get_24_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tFollowEntActorID", _1)
		flow.__agent:addSubTreeLocalParam("tFollowStopDist", 1)
		flow.__agent:addSubTreeLocalParam("tStartFollowDist", 0)
		flow:setContinue(3)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_23_1(flow)
	local _0 = _M._get_24_1(flow)

	return _C(23, "CheckEntityExist", flow, _0)
end

function _M._get_24_1(flow)
	return _C(24, "GetLeaderId", flow, 0)
end

return _M
