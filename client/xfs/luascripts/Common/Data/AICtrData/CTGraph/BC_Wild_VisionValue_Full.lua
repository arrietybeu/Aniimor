-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_VisionValue_Full.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "VisionValue_Full" then
		flow:setActive()
		_A(flow, "AddAITag", 0, "TA_VisionFull")
		flow:setActive()
		_A(flow, "RemoveAITag", 0, "TA_VisionAlert")

		return _M._to_67_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "RemoveAITag", 0, "TA_VisionFull")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 61 then
		return true
	end

	if nodeId == 74 then
		return true
	end

	if nodeId == 79 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_61_0(flow)
	if not _B(flow, "PBT_Perception_Leave") then
		return
	end

	local _0 = _M._get_55_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tSpeed", 3.5)
	flow:setContinue(61)

	return true
end

function _M._to_67_0(flow)
	local _3 = _M._get_68_2(flow)
	local _0 = _3 == "Leave"

	if _0 then
		return _M._to_61_0(flow)
	end

	local _4 = _M._get_68_2(flow)
	local _1 = _4 == "Fight"

	if _1 then
		return _M._to_74_0(flow)
	end

	local _5 = _M._get_68_2(flow)
	local _2 = _5 == "Stare"

	if _2 then
		return _M._to_79_0(flow)
	end
end

function _M._to_74_0(flow)
	if not _B(flow, "PBT_ReadyToFight") then
		return
	end

	local _0 = _M._get_55_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tRandomWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tShowExclamation", false)
	flow:setContinue(74)

	return true
end

function _M._to_79_0(flow)
	if not _B(flow, "PBT_Perception_Stare") then
		return
	end

	local _0 = _M._get_55_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tMaxTime", 0)
	flow.__agent:addSubTreeLocalParam("tRandomTime", 0)
	flow:setContinue(79)

	return true
end

function _M._get_55_2(flow)
	return flow:getContextValue("sensorTgtId")
end

function _M._get_68_2(flow)
	local _0 = _C(69, "GetSelfId", flow)

	return _C(68, "GetPuppetData", flow, _0, "perceptFullBehavType", true, "")
end

return _M
