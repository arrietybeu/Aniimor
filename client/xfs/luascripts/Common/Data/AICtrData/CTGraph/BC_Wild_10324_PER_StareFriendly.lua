-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10324_PER_StareFriendly.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Event_PER_StareFriendly" then
		return _M._to_82_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 78 then
		return true
	end

	if nodeId == 80 then
		return true
	end

	if nodeId == 82 then
		return _M._to_81_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 80 then
		return _M._get_83_3(flow)
	end
end

function _M._to_78_0(flow)
	if not _B(flow, "PBT_Behav_Com_Happy") then
		return
	end

	local _0 = _M._get_79_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow:setContinue(78)

	return true
end

function _M._to_80_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 80)

	if not _1 then
		flow:setActive()
		_C(80, "DoBehaviour", flow, "PBT_IdleSpecial")

		local _1 = _M._get_79_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tSensorTgtId", _1)
		flow:setContinue(80)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_81_0(flow)
	local _0 = _M._get_83_1(flow)

	if _0 then
		return _M._to_84_0(flow)
	end

	return _M._to_78_0(flow)
end

function _M._to_82_0(flow)
	if not _B(flow, "PBT_Node_Com_SensedAlert") then
		return
	end

	local _0 = _M._get_79_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow:setContinue(82)

	return true
end

function _M._to_84_0(flow)
	flow:addTimer(1, _M, "_to_85_0", flow)

	return _M._to_80_0(flow)
end

function _M._to_85_0(flow)
	flow:setActive()
	_A(flow, "SendMessageToTrigger", 0, 1032402)

	return true
end

function _M._get_79_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_83_3(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_79_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayerInterrupt")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_83_1(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_79_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayer")

	flow:clearSubMacro(_0)

	return _2
end

return _M
