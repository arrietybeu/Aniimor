-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_PER_Cry_ToPlayer.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Event_PER_Cry" then
		return _M._to_44_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 42 then
		return _M._to_46_0(flow)
	end

	if nodeId == 44 then
		return _M._to_42_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 42 then
		return _M._get_45_3(flow)
	end
end

function _M._to_42_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 42)

	if not _1 then
		flow:setActive()
		_C(42, "DoBehaviour", flow, "PBT_Behav_Com_Cry")

		local _1 = _M._get_43_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow:setContinue(42)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_44_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_45_1(flow)

	if _0 then
		flow:setActive()
		_C(44, "DoBehaviour", flow, "PBT_Node_Com_SensedAlert")

		local _1 = _M._get_43_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow:setContinue(44)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_46_0(flow)
	flow:setActive()
	_A(flow, "SendMessageToTrigger", 0, 1012)

	return true
end

function _M._get_43_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_45_3(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_43_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayerInterrupt")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_45_1(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_43_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayer")

	flow:clearSubMacro(_0)

	return _2
end

return _M
