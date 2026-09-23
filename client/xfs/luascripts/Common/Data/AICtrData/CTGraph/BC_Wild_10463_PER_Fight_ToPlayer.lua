-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10463_PER_Fight_ToPlayer.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Event_PER_Fight" then
		return _M._to_34_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 34 then
		return _M._to_37_0(flow)
	end

	if nodeId == 36 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 36 then
		return _M._get_35_3(flow)
	end
end

function _M._to_34_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_60_2(flow)

	if _0 then
		flow:setActive()
		_C(34, "DoBehaviour", flow, "PBT_Node_Com_SensedAlert")

		local _1 = _M._get_33_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow:setContinue(34)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_36_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 36)

	if not _1 then
		flow:setActive()
		_C(36, "DoBehaviour", flow, "PBT_ReadyToFight")

		local _1 = _M._get_33_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tSensorTgtId", _1)
		flow.__agent:addSubTreeLocalParam("tRandomWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tShowExclamation", false)
		flow:setContinue(36)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_37_0(flow)
	flow:setActive()
	_A(flow, "SendMessageToTrigger", 0, 1046301)

	return _M._to_36_0(flow)
end

function _M._get_33_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_35_3(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_33_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayerInterrupt")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_35_1(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_33_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayer")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_60_2(flow)
	local _2 = _M._get_33_2(flow)
	local _3 = _C(51, "GetEntProperty", flow, _2, "gender")
	local _5 = _C(55, "GetSelfId", flow)
	local _4 = _C(56, "GetEntProperty", flow, _5, "gender")
	local _0 = _3 == _4

	if not _0 then
		return false
	end

	local _1 = _M._get_35_1(flow)

	if not _1 then
		return false
	end

	return true
end

return _M
