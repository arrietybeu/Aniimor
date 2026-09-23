-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_GrassTrain.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tPointId", value0)
	agent:addSubTreeLocalParam("tPortId", value1)
	agent:addSubTreeLocalParam("tTimeout", value2)
	agent:addSubTreeLocalParam("tSpeedRateType", value3)
	agent:addSubTreeLocalParam("tSpeed", value4)
	agent:addSubTreeLocalParam("tInteractDist", value5)
	agent:addSubTreeLocalParam("tIgnoreSelfBodySize", value6)
	agent:addSubTreeLocalParam("tIgnorePointBodySize", value7)
	agent:addSubTreeLocalParam("tUseAccurateArrive", value8)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_1(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tAnimationKey", value1)
	agent:addSubTreeLocalParam("tAnimationTimeout", value2)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value3)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value4)
	agent:addSubTreeLocalParam("tTimelineTag", value5)
	agent:addSubTreeLocalParam("tNeedLoop", value6)
	agent:addSubTreeLocalParam("tAnimationPlayOnce", value7)
	agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", value8)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "GBPMsg_ResPoint01_1" then
		flow:setActive()

		local _0 = _M._get_25_2(flow)
		local _1 = _M._get_25_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _0, _1)

		return _M._to_28_0(flow)
	end

	if eventName == "GBPMsg_Common02_1" then
		return _M._to_103_0(flow)
	end

	if eventName == "GBPMsg_ResPoint01_2" then
		flow:setActive()

		local _2 = _M._get_122_2(flow)
		local _3 = _M._get_122_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _2, _3)

		return _M._to_124_0(flow)
	end

	if eventName == "GBPMsg_Common02_2" then
		return _M._to_125_0(flow)
	end

	if eventName == "GBPMsg_Common02_3" then
		return _M._to_127_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	return _M._to_137_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 28 then
		return true
	end

	if nodeId == 103 then
		return true
	end

	if nodeId == 108 then
		return _M._to_114_0(flow)
	end

	if nodeId == 114 then
		return _M._to_115_0(flow)
	end

	if nodeId == 115 then
		return _M._to_116_0(flow)
	end

	if nodeId == 116 then
		return true
	end

	if nodeId == 124 then
		return true
	end

	if nodeId == 125 then
		return true
	end

	if nodeId == 127 then
		return _M._to_133_0(flow)
	end

	if nodeId == 133 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_28_0(flow)
	if not _B(flow, "PBT_MoveToResPointPortInDist") then
		return
	end

	local _0 = _M._get_25_2(flow)
	local _1 = _M._get_25_3(flow)

	return _doBehaviourTail_0(flow, 28, _0, _1, 1000, 1, 0, 0, true, true, false)
end

function _M._to_103_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 103, 0, "Attack01", 4, "", 0, "", true, false, false)
end

function _M._to_114_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 114, 0, "Turn90_L", 4, "", 0, "", false, false, false)
end

function _M._to_115_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 115, 0, "Turn90_L", 4, "", 0, "", false, false, false)
end

function _M._to_116_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 116, 0, "Turn90_L", 4, "", 0, "", false, false, false)
end

function _M._to_124_0(flow)
	if not _B(flow, "PBT_MoveToResPointPortInDist") then
		return
	end

	local _0 = _M._get_122_2(flow)
	local _1 = _M._get_122_3(flow)

	return _doBehaviourTail_0(flow, 124, _0, _1, 1000, 1, 0, 0, true, true, false)
end

function _M._to_125_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 125, 0, "Turn90_L", 4, "", 0, "", true, false, false)
end

function _M._to_127_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 127, 0, "Turn90_R", 4, "", 0, "", false, false, false)
end

function _M._to_133_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 133, 0, "Turn90_L", 4, "", 0, "", true, false, false)
end

function _M._to_137_0(flow)
	local _1 = _M._get_139_2(flow)
	local _0 = not _1

	if _0 then
		flow:setActive()

		local _2 = _M._get_25_2(flow)
		local _3 = _M._get_25_3(flow)

		_A(flow, "ExitResPointPort", 0, _2, _3, 0, 0)

		return true
	end

	flow:setActive()

	local _4 = _M._get_122_2(flow)
	local _5 = _M._get_122_3(flow)

	_A(flow, "ExitResPointPort", 0, _4, _5, 0, 0)

	return true
end

function _M._get_25_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_25_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_122_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_122_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_139_2(flow)
	local _2 = _M._get_25_2(flow)
	local _0 = _2 == 0

	if not _0 then
		return false
	end

	local _3 = _M._get_25_3(flow)
	local _1 = _3 == 0

	if not _1 then
		return false
	end

	return true
end

return _M
