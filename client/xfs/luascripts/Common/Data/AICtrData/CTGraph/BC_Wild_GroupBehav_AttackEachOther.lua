-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_AttackEachOther.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
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

local function _doBehaviourTail_1(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value0)
	agent:addSubTreeLocalParam("tTimeout", value1)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "GBPMsg_ResPoint01" then
		flow:setActive()

		local _0 = _M._get_123_2(flow)
		local _1 = _M._get_123_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _0, _1)

		return _M._to_126_0(flow)
	end

	if eventName == "GBPMsg_Common03" then
		return _M._to_137_0(flow)
	end

	if eventName == "GBPMsg_Common04" then
		return _M._to_139_0(flow)
	end

	if eventName == "GBPMsg_Common02" then
		return _M._to_158_0(flow)
	end

	if eventName == "GBPMsg_Common01" then
		return _M._to_150_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_123_2(flow)
	local _1 = _M._get_123_3(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 126 then
		return true
	end

	if nodeId == 129 then
		return _M._to_143_0(flow)
	end

	if nodeId == 130 then
		return _M._to_129_0(flow)
	end

	if nodeId == 131 then
		return _M._to_130_0(flow)
	end

	if nodeId == 132 then
		return _M._to_135_0(flow)
	end

	if nodeId == 134 then
		return _M._to_146_0(flow)
	end

	if nodeId == 135 then
		return _M._to_134_0(flow)
	end

	if nodeId == 137 then
		return true
	end

	if nodeId == 139 then
		return true
	end

	if nodeId == 143 then
		return _M._to_144_0(flow)
	end

	if nodeId == 144 then
		return true
	end

	if nodeId == 145 then
		return true
	end

	if nodeId == 146 then
		return _M._to_145_0(flow)
	end

	if nodeId == 150 then
		return _M._to_151_0(flow)
	end

	if nodeId == 151 then
		return _M._to_154_0(flow)
	end

	if nodeId == 152 then
		return _M._to_156_0(flow)
	end

	if nodeId == 153 then
		return _M._to_152_0(flow)
	end

	if nodeId == 154 then
		return _M._to_155_0(flow)
	end

	if nodeId == 155 then
		return true
	end

	if nodeId == 156 then
		return true
	end

	if nodeId == 158 then
		return _M._to_153_0(flow)
	end

	if nodeId == 159 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_126_0(flow)
	if not _B(flow, "PBT_MoveToResPointPortInDist") then
		return
	end

	local _0 = _M._get_123_2(flow)
	local _1 = _M._get_123_3(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tPointId", _0)
	flow.__agent:addSubTreeLocalParam("tPortId", _1)
	flow.__agent:addSubTreeLocalParam("tTimeout", 1000)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tInteractDist", 0)
	flow.__agent:addSubTreeLocalParam("tIgnoreSelfBodySize", true)
	flow.__agent:addSubTreeLocalParam("tIgnorePointBodySize", true)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow:setContinue(126)

	return true
end

function _M._to_129_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 129, 4, "", 0, "Angry", 2, "", false, false, false)
end

function _M._to_130_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 130, 0, "Attack01", 2, "", 0, "", false, false, false)
end

function _M._to_134_0(flow)
	if not _B(flow, "PBT_Com_Node_OnlyShowBubble") then
		return
	end

	return _doBehaviourTail_1(flow, 134, "Angry", 2)
end

function _M._to_135_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 135, 0, "Attack01", 2, "", 0, "", false, false, false)
end

function _M._to_137_0(flow)
	if not _B(flow, "PBT_Com_Node_OnlyShowBubble") then
		return
	end

	return _doBehaviourTail_1(flow, 137, "Happy", 4)
end

function _M._to_139_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Angry")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 3)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_AngryStart")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_AngryLoop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_AngryEnd")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 4)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(139)

	return true
end

function _M._to_143_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 143, 0, "Attack02", 2, "", 0, "", false, false, false)
end

function _M._to_144_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 144, 0, "Attack03", 2, "", 0, "", false, false, false)
end

function _M._to_145_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 145, 0, "Attack04", 2, "", 0, "", false, false, false)
end

function _M._to_146_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 146, 0, "Attack03", 2, "", 0, "", false, false, false)
end

function _M._to_150_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 150, 0, "Attack02", 1, "Furious", 0, "", false, false, false)
end

function _M._to_151_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 151, 0, "Attack01", 2, "", 0, "", false, false, false)
end

function _M._to_152_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 152, 0, "Attack04", 2, "", 0, "", false, false, false)
end

function _M._to_153_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 153, 0, "Attack02", 2, "Furious", 1, "", false, false, false)
end

function _M._to_154_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 154, 0.25, "Hit_L", 2, "", 0, "", false, false, false)
end

function _M._to_155_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 155, 0, "Behav_Cry", 3, "Cry", 2, "", false, false, false)
end

function _M._to_156_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 156, 0, "Behav_Happy", 3, "Happy", 1, "", false, false, false)
end

function _M._to_158_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 158, 2, "Hit_Stand", 2, "", 0, "", false, false, false)
end

function _M._get_123_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_123_2(flow)
	return flow:getContextValue("tPointId")
end

return _M
