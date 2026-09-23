-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10022_VisionValue_Full_Leave_Overload_FindHelm.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "VisionValue_Full" then
		return _M._to_83_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 75 then
		return _M._to_74_0(flow)
	end

	if nodeId == 77 then
		return _M._to_84_0(flow)
	end

	if nodeId == 78 then
		return _M._to_79_0(flow)
	end

	if nodeId == 80 then
		return _M._to_85_0(flow)
	end

	if nodeId == 84 then
		return true
	end

	if nodeId == 85 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_74_0(flow)
	flow:setActive()

	local _0 = _C(81, "GetSelfId", flow)

	_A(flow, "HideEmojiOnTarget", _0, "")

	return _M._to_80_0(flow)
end

function _M._to_75_0(flow)
	flow:setActive()

	local _0 = flow:getSubFlow("BCS_Common_VisionAlertTag")

	if _0:executeSubFlow() then
		flow:setContinue(75)

		if _0:isFinish() then
			return flow:executeContinue()
		end

		return true
	end
end

function _M._to_77_0(flow)
	if not _B(flow, "PBT_ShowQuestionMark") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tMarkType", "Normal")
	flow.__agent:addSubTreeLocalParam("tTimeout", 1.8)
	flow:setContinue(77)

	return true
end

function _M._to_78_0(flow)
	flow:setActive()

	local _0 = flow:getSubFlow("BCS_Common_VisionAlertTag")

	if _0:executeSubFlow() then
		flow:setContinue(78)

		if _0:isFinish() then
			return flow:executeContinue()
		end

		return true
	end
end

function _M._to_79_0(flow)
	flow:setActive()

	local _0 = _C(76, "GetSelfId", flow)

	_A(flow, "HideEmojiOnTarget", _0, "")

	return _M._to_77_0(flow)
end

function _M._to_80_0(flow)
	if not _B(flow, "PBT_ShowQuestionMark") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tMarkType", "Normal")
	flow.__agent:addSubTreeLocalParam("tTimeout", 1.8)
	flow:setContinue(80)

	return true
end

function _M._to_83_0(flow)
	local _0 = _M._get_66_2(flow)

	if _0 then
		return _M._to_78_0(flow)
	end

	local _2 = _M._get_82_2(flow)
	local _3 = _C(71, "GetControllingPetActorId", flow, _2)
	local _4 = _C(72, "GetPetData", flow, _3, "petPrototypeId", true, 0)
	local _1 = _4 == 1002100

	if _1 then
		return _M._to_75_0(flow)
	end
end

function _M._to_84_0(flow)
	if not _B(flow, "PBT_LeaveTarget") then
		return
	end

	local _0 = _M._get_82_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tLeaveDistance", 30)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tMaxTime", 0)
	flow:setContinue(84)

	return true
end

function _M._to_85_0(flow)
	if not _B(flow, "PBT_ReadyToFight") then
		return
	end

	local _0 = _M._get_82_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tRandomWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tShowExclamation", false)
	flow:setContinue(85)

	return true
end

function _M._get_66_2(flow)
	local _3 = _M._get_68_2(flow)
	local _0 = _3 == 1002600

	if _0 then
		return true
	end

	local _2 = _M._get_68_2(flow)
	local _1 = _2 == 1002700

	if _1 then
		return true
	end

	return false
end

function _M._get_68_2(flow)
	local _1 = _M._get_82_2(flow)
	local _0 = _C(69, "GetControllingPetActorId", flow, _1)

	return _C(68, "GetPetData", flow, _0, "petPrototypeId", true, 0)
end

function _M._get_82_2(flow)
	return flow:getContextValue("sensorTgtId")
end

return _M
