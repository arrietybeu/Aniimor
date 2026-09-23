-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10023_Security_ReadyToFight.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "VisionValue_Full" then
		return _M._to_63_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 57 then
		return true
	end

	if nodeId == 58 then
		return _M._to_55_0(flow)
	end

	if nodeId == 63 then
		return _M._to_58_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_55_0(flow)
	flow:setActive()

	local _0 = _M._get_54_0(flow)

	_A(flow, "StopEffectOnTarget", _0, "Eff_Parmon_10023_Behav_Security_Finding")
	flow:setActive()

	local _1 = _M._get_54_0(flow)

	_A(flow, "PlayEffectOnTarget", _1, "Eff_Parmon_10023_Behav_Security_Locking", -1)

	return _M._to_57_0(flow)
end

function _M._to_57_0(flow)
	if not _B(flow, "PBT_ReadyToFight") then
		return
	end

	local _0 = flow:getContextValue("sensorTgtId")

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tRandomWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tShowExclamation", false)
	flow:setContinue(57)

	return true
end

function _M._to_58_0(flow)
	if not _B(flow, "PBT_ShowQuestionMark") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tMarkType", "DirectFull")
	flow.__agent:addSubTreeLocalParam("tTimeout", 1)
	flow:setContinue(58)

	return true
end

function _M._to_63_0(flow)
	flow:setActive()

	local _0 = flow:getSubFlow("BCS_Common_VisionFullTag")

	if _0:executeSubFlow() then
		flow:setContinue(63)

		if _0:isFinish() then
			return flow:executeContinue()
		end

		return true
	end
end

function _M._get_54_0(flow)
	return _C(54, "GetSelfId", flow)
end

return _M
