-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_PER_Love.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Event_PER_Love" then
		return _M._to_62_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 54 then
		return true
	end

	if nodeId == 60 then
		return _M._to_63_0(flow)
	end

	if nodeId == 61 then
		return true
	end

	if nodeId == 62 then
		return _M._to_55_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 61 then
		return _M._get_57_3(flow)
	end
end

function _M._to_54_0(flow)
	if not _B(flow, "PBT_Behav_Com_Love") then
		return
	end

	local _0 = _M._get_44_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow:setContinue(54)

	return true
end

function _M._to_55_0(flow)
	local _0 = _M._get_57_1(flow)

	if _0 then
		return _M._to_60_0(flow)
	end

	return _M._to_54_0(flow)
end

function _M._to_59_0(flow)
	flow:setActive()
	_A(flow, "SendMessageToTrigger", 0, 1015)

	return true
end

function _M._to_60_0(flow)
	if not _B(flow, "PBT_MoveAroundTarget") then
		return
	end

	local _0 = _M._get_44_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tRadius", 0.5)
	flow.__agent:addSubTreeLocalParam("tSpeed", 2)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tClockwise", false)
	flow.__agent:addSubTreeLocalParam("tTimeout", 5)
	flow:setContinue(60)

	return true
end

function _M._to_61_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 61)

	if not _1 then
		flow:setActive()
		_C(61, "DoBehaviour", flow, "PBT_Behav_Com_Love")

		local _1 = _M._get_44_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow:setContinue(61)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_62_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Love")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 2)
	flow:setContinue(62)

	return true
end

function _M._to_63_0(flow)
	flow:addTimer(1, _M, "_to_59_0", flow)

	return _M._to_61_0(flow)
end

function _M._get_44_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_57_3(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_44_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayerInterrupt")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_57_1(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_44_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPlayer")

	flow:clearSubMacro(_0)

	return _2
end

return _M
