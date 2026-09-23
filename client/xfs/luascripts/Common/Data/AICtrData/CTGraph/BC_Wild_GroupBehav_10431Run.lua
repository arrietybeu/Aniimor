-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_10431Run.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8)
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

local function _doBehaviourTail_1(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8, value9)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value1)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value2)
	agent:addSubTreeLocalParam("tAnimationStartKey", value3)
	agent:addSubTreeLocalParam("tAnimationLoopKey", value4)
	agent:addSubTreeLocalParam("tAnimationEndKey", value5)
	agent:addSubTreeLocalParam("tAnimationTimeout", value6)
	agent:addSubTreeLocalParam("tTimelineTag", value7)
	agent:addSubTreeLocalParam("tNeedLoop", value8)
	agent:addSubTreeLocalParam("tAnimationPlayOnce", value9)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "GBPMsg_ResPoint01" then
		flow:setActive()

		local _0 = _M._get_25_2(flow)
		local _1 = _M._get_25_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _0, _1)

		return _M._to_28_0(flow)
	end

	if eventName == "GBPMsg_Common01" then
		flow:setActive()
		_A(flow, "StartNpcDialog", 70007240, 0)

		return _M._to_138_0(flow)
	end

	if eventName == "GBPMsg_Common02" then
		flow:setActive()
		_A(flow, "StartNpcDialog", 70007241, 0)

		return _M._to_139_0(flow)
	end

	if eventName == "GBPMsg_ResPoint02" then
		return _M._to_132_0(flow)
	end

	if eventName == "GBPMsg_ResPoint03" then
		return _M._to_105_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_25_2(flow)
	local _1 = _M._get_25_3(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 28 then
		return true
	end

	if nodeId == 103 then
		return true
	end

	if nodeId == 106 then
		return true
	end

	if nodeId == 122 then
		return true
	end

	if nodeId == 123 then
		return true
	end

	if nodeId == 124 then
		return true
	end

	if nodeId == 126 then
		return _M._to_112_0(flow)
	end

	if nodeId == 128 then
		return _M._to_130_0(flow)
	end

	if nodeId == 134 then
		return true
	end

	if nodeId == 135 then
		return true
	end

	if nodeId == 136 then
		return true
	end

	if nodeId == 138 then
		return _M._to_126_0(flow)
	end

	if nodeId == 139 then
		return _M._to_128_0(flow)
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

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tPointId", _0)
	flow.__agent:addSubTreeLocalParam("tPortId", _1)
	flow.__agent:addSubTreeLocalParam("tTimeout", 1000)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tInteractDist", 0)
	flow.__agent:addSubTreeLocalParam("tIgnoreSelfBodySize", true)
	flow.__agent:addSubTreeLocalParam("tIgnorePointBodySize", true)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow:setContinue(28)

	return true
end

function _M._to_103_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_102_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(103)

		return true
	end
end

function _M._to_105_0(flow)
	flow:addTimer(5, _M, "_to_107_0", flow)

	return _M._to_106_0(flow)
end

function _M._to_106_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_113_1(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(106)

		return true
	end
end

function _M._to_107_0(flow)
	flow:setActive()
	_A(flow, "StartNpcDialog", 70007243, 0)
	flow:setActive()
	_A(flow, "PlayEmojiOnTarget", 0, "Cry", 12)

	return true
end

function _M._to_112_0(flow)
	flow:setActive()
	_A(flow, "StartNpcDialog", 70007242, 0)

	return _M._to_134_0(flow)
end

function _M._to_124_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 124, 0, "Skill_Smoke", 1.9, "", 5, "", false, true, false)
end

function _M._to_126_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 3)
	flow:setContinue(126)

	return true
end

function _M._to_128_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 1.5)
	flow:setContinue(128)

	return true
end

function _M._to_130_0(flow)
	flow:setActive()
	_A(flow, "StartNpcDialog", 70007241, 0)

	return _M._to_124_0(flow)
end

function _M._to_131_0(flow)
	flow:setActive()
	_A(flow, "StartNpcDialog", 70007244, 0)
	flow:setActive()
	_A(flow, "PlayEmojiOnTarget", 0, "Proud", 12)

	return true
end

function _M._to_132_0(flow)
	flow:addTimer(2, _M, "_to_131_0", flow)

	return _M._to_103_0(flow)
end

function _M._to_134_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 134, 0, "Skill_Smoke", 1.9, "", 5, "", false, true, false)
end

function _M._to_138_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 138, 0, "", 5, "Behav_HappyStart", "Behav_HappyLoop", "Behav_HappyEnd", 3.833, "", false, true)
end

function _M._to_139_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 139, 0, "", 5, "Behav_HappyStart", "Behav_HappyLoop", "Behav_HappyEnd", 3.833, "", false, true)
end

function _M._get_25_2(flow)
	return flow:getContextValue("tPointId")
end

function _M._get_25_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_102_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(102, "GetRouteIdFromResPoint", flow, true, _0, 1)
end

function _M._get_113_1(flow)
	local _0 = flow:getContextValue("tPointId")

	return _C(113, "GetRouteIdFromResPoint", flow, true, _0, 2)
end

return _M
