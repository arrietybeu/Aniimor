-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_PER_Chase_ToPuppet.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Event_PER_Chase" then
		return _M._to_18_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 16 then
		return true
	end

	if nodeId == 18 then
		return _M._to_16_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_16_0(flow)
	if not _B(flow, "PBT_Behav_Com_Chase") then
		return
	end

	local _0 = _M._get_17_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("", 1)
	flow.__agent:addSubTreeLocalParam("Speed", 0)
	flow:setContinue(16)

	return true
end

function _M._to_18_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_19_2(flow)

	if _0 then
		flow:setActive()
		_C(18, "DoBehaviour", flow, "PBT_Node_Com_SensedAlert")

		local _1 = _M._get_17_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow:setContinue(18)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_17_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_19_2(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_17_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPuppet")

	flow:clearSubMacro(_0)

	return _2
end

return _M
