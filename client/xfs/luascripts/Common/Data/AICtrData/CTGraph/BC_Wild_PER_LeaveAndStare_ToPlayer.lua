-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_PER_LeaveAndStare_ToPlayer.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Event_PER_LeaveAndStare" then
		return _M._to_11_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 11 then
		return _M._to_18_0(flow)
	end

	if nodeId == 12 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 12 then
		return _M._get_13_3(flow)
	end
end

function _M._to_11_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_13_1(flow)

	if _0 then
		flow:setActive()
		_C(11, "DoBehaviour", flow, "PBT_Node_Com_SensedAlert")

		local _1 = _M._get_10_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow:setContinue(11)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_12_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 12)

	if not _1 then
		flow:setActive()
		_C(12, "DoBehaviour", flow, "PBT_Behav_Com_LeaveAndStare_ToPlayer")

		local _1 = _M._get_10_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("LeaveCount", 0)
		flow.__agent:addSubTreeLocalParam("tStareCount", 0)
		flow:setContinue(12)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_18_0(flow)
	flow:addTimer(1, _M, "_to_19_0", flow)

	return _M._to_12_0(flow)
end

function _M._to_19_0(flow)
	flow:setActive()

	local _0 = _C(20, "GetSelfId", flow)
	local _1 = _M._get_10_2(flow)

	_A(flow, "SendMessageToTriggerSpecial", _0, _1)

	return true
end

function _M._get_10_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_13_3(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_10_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayerInterrupt")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_13_1(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_10_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayer")

	flow:clearSubMacro(_0)

	return _2
end

return _M
