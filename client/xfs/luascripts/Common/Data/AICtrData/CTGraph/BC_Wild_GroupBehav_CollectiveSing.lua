-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_GroupBehav_CollectiveSing.lua

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

function _M.executeEventTrigger(flow, eventName)
	if eventName == "GBPMsg_Common04" then
		return _M._to_84_0(flow)
	end

	if eventName == "GBPMsg_Common03" then
		return _M._to_62_0(flow)
	end

	if eventName == "GBPMsg_Common01" then
		return _M._to_49_0(flow)
	end

	if eventName == "GBPMsg_ResPoint01" then
		flow:setActive()

		local _0 = _M._get_52_2(flow)
		local _1 = _M._get_52_3(flow)

		_A(flow, "PreJoinResPointPort", 0, _0, _1)

		return _M._to_53_0(flow)
	end

	if eventName == "GBPMsg_Common05" then
		return _M._to_124_0(flow)
	end

	if eventName == "GBPMsg_Common06" then
		return _M._to_131_0(flow)
	end

	if eventName == "GBPMsg_Common08" then
		return _M._to_145_0(flow)
	end

	if eventName == "GBPMsg_Common07" then
		return _M._to_138_0(flow)
	end

	if eventName == "GBPMsg_Common02" then
		return _M._to_177_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_52_2(flow)
	local _1 = _M._get_52_3(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 0, 0)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 49 then
		return true
	end

	if nodeId == 53 then
		return true
	end

	if nodeId == 60 then
		return _M._to_120_0(flow)
	end

	if nodeId == 62 then
		return _M._to_80_0(flow)
	end

	if nodeId == 65 then
		return _M._to_118_0(flow)
	end

	if nodeId == 80 then
		return _M._to_60_0(flow)
	end

	if nodeId == 84 then
		return _M._to_65_0(flow)
	end

	if nodeId == 87 then
		return _M._to_179_0(flow)
	end

	if nodeId == 88 then
		return _M._to_180_0(flow)
	end

	if nodeId == 89 then
		return _M._to_88_0(flow)
	end

	if nodeId == 118 then
		return _M._to_119_0(flow)
	end

	if nodeId == 119 then
		return _M._to_122_0(flow)
	end

	if nodeId == 120 then
		return _M._to_121_0(flow)
	end

	if nodeId == 121 then
		return _M._to_87_0(flow)
	end

	if nodeId == 122 then
		return _M._to_89_0(flow)
	end

	if nodeId == 123 then
		return _M._to_125_0(flow)
	end

	if nodeId == 124 then
		return _M._to_123_0(flow)
	end

	if nodeId == 125 then
		return _M._to_126_0(flow)
	end

	if nodeId == 126 then
		return _M._to_127_0(flow)
	end

	if nodeId == 127 then
		return _M._to_128_0(flow)
	end

	if nodeId == 128 then
		return _M._to_129_0(flow)
	end

	if nodeId == 129 then
		return _M._to_181_0(flow)
	end

	if nodeId == 130 then
		return _M._to_132_0(flow)
	end

	if nodeId == 131 then
		return _M._to_130_0(flow)
	end

	if nodeId == 132 then
		return _M._to_133_0(flow)
	end

	if nodeId == 133 then
		return _M._to_134_0(flow)
	end

	if nodeId == 134 then
		return _M._to_135_0(flow)
	end

	if nodeId == 135 then
		return _M._to_136_0(flow)
	end

	if nodeId == 136 then
		return _M._to_182_0(flow)
	end

	if nodeId == 137 then
		return _M._to_139_0(flow)
	end

	if nodeId == 138 then
		return _M._to_137_0(flow)
	end

	if nodeId == 139 then
		return _M._to_140_0(flow)
	end

	if nodeId == 140 then
		return _M._to_141_0(flow)
	end

	if nodeId == 141 then
		return _M._to_142_0(flow)
	end

	if nodeId == 142 then
		return _M._to_143_0(flow)
	end

	if nodeId == 143 then
		return _M._to_183_0(flow)
	end

	if nodeId == 144 then
		return _M._to_146_0(flow)
	end

	if nodeId == 145 then
		return _M._to_144_0(flow)
	end

	if nodeId == 146 then
		return _M._to_147_0(flow)
	end

	if nodeId == 147 then
		return _M._to_148_0(flow)
	end

	if nodeId == 148 then
		return _M._to_149_0(flow)
	end

	if nodeId == 149 then
		return _M._to_150_0(flow)
	end

	if nodeId == 150 then
		return true
	end

	if nodeId == 152 then
		return true
	end

	if nodeId == 177 then
		return true
	end

	if nodeId == 179 then
		return _M._to_152_0(flow)
	end

	if nodeId == 180 then
		return true
	end

	if nodeId == 181 then
		return true
	end

	if nodeId == 182 then
		return true
	end

	if nodeId == 183 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_49_0(flow)
	if not _B(flow, "PBT_Noop") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(49)

	return true
end

function _M._to_53_0(flow)
	if not _B(flow, "PBT_MoveToResPointPortInDist") then
		return
	end

	local _0 = _M._get_52_2(flow)
	local _1 = _M._get_52_3(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tPointId", _0)
	flow.__agent:addSubTreeLocalParam("tPortId", _1)
	flow.__agent:addSubTreeLocalParam("tTimeout", 1000)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 0)
	flow.__agent:addSubTreeLocalParam("tSpeed", 1)
	flow.__agent:addSubTreeLocalParam("tInteractDist", 0.2)
	flow.__agent:addSubTreeLocalParam("tIgnoreSelfBodySize", true)
	flow.__agent:addSubTreeLocalParam("tIgnorePointBodySize", true)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow:setContinue(53)

	return true
end

function _M._to_60_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 60, 0, "Behav_Happy", 4, "Happy", 4, "", true, false, false)
end

function _M._to_62_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 62, 0, "Behav_Sing", 4, "", 4, "", true, false, false)
end

function _M._to_65_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 65, 0, "Behav_Sing", 4, "", 0, "", true, false, false)
end

function _M._to_80_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 80, 0, "Ground_Idle", 4, "", 0, "", true, false, false)
end

function _M._to_84_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 84, 0, "Ground_Idle", 4, "", 0, "", true, false, false)
end

function _M._to_87_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 87, 0, "Behav_Happy", 4, "Happy", 4, "", true, false, false)
end

function _M._to_88_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 88, 0, "Behav_Love", 4, "", 0, "", true, false, false)
end

function _M._to_89_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 89, 0, "Behav_Happy", 4, "Happy", 4, "", true, false, false)
end

function _M._to_118_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 118, 0, "Ground_Idle", 4, "", 0, "", true, false, false)
end

function _M._to_119_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 119, 0, "Behav_Happy", 4, "Happy", 4, "", true, false, false)
end

function _M._to_120_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 120, 0, "Ground_Idle", 4, "", 0, "", true, false, false)
end

function _M._to_121_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 121, 0, "Behav_Sing", 4, "", 4, "", true, false, false)
end

function _M._to_122_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 122, 0, "Ground_Idle", 4, "", 0, "", true, false, false)
end

function _M._to_123_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 123, 0, "Behav_Sing", 4, "", 0, "", true, false, false)
end

function _M._to_124_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 124, 0, "Ground_Idle", 4, "", 0, "", true, false, false)
end

function _M._to_125_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 125, 0, "Ground_Idle", 4, "", 0, "", true, false, false)
end

function _M._to_126_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 126, 0, "Behav_Happy", 4, "Happy", 4, "", true, false, false)
end

function _M._to_127_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 127, 0, "Ground_Idle", 4, "", 0, "", true, false, false)
end

function _M._to_128_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 128, 0, "Behav_Happy", 4, "Happy", 4, "", true, false, false)
end

function _M._to_129_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 129, 0, "Behav_Love", 4, "", 0, "", true, false, false)
end

function _M._to_130_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 130, 0, "Behav_Sing", 4, "", 0, "", true, false, false)
end

function _M._to_131_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 131, 0, "Ground_Idle", 4, "", 0, "", true, false, false)
end

function _M._to_132_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 132, 0, "Ground_Idle", 4, "", 0, "", true, false, false)
end

function _M._to_133_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 133, 0, "Behav_Happy", 4, "Happy", 4, "", true, false, false)
end

function _M._to_134_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 134, 0, "Ground_Idle", 4, "", 0, "", true, false, false)
end

function _M._to_135_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 135, 0, "Behav_Happy", 4, "Happy", 4, "", true, false, false)
end

function _M._to_136_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 136, 0, "Behav_Love", 4, "", 0, "", true, false, false)
end

function _M._to_137_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 137, 0, "Behav_Sing", 4, "", 0, "", true, false, false)
end

function _M._to_138_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 138, 0, "Ground_Idle", 4, "", 0, "", true, false, false)
end

function _M._to_139_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 139, 0, "Ground_Idle", 4, "", 0, "", true, false, false)
end

function _M._to_140_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 140, 0, "Behav_Happy", 4, "Happy", 4, "", true, false, false)
end

function _M._to_141_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 141, 0, "Ground_Idle", 4, "", 0, "", true, false, false)
end

function _M._to_142_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 142, 0, "Behav_Happy", 4, "Happy", 4, "", true, false, false)
end

function _M._to_143_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 143, 0, "Behav_Love", 4, "", 0, "", true, false, false)
end

function _M._to_144_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 144, 0, "Behav_Sing", 4, "", 0, "", true, false, false)
end

function _M._to_145_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 145, 0, "Ground_Idle", 4, "", 0, "", true, false, false)
end

function _M._to_146_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 146, 0, "Ground_Idle", 4, "", 0, "", true, false, false)
end

function _M._to_147_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 147, 0, "Behav_Happy", 4, "Happy", 4, "", true, false, false)
end

function _M._to_148_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 148, 0, "Ground_Idle", 4, "", 0, "", true, false, false)
end

function _M._to_149_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 149, 0, "Behav_Happy", 4, "Happy", 8, "", true, false, false)
end

function _M._to_150_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 150, 0, "IdleSpecial", 8, "", 0, "", true, false, false)
end

function _M._to_152_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 152, 0, "Skill_Conjure", 3, "", 0, "", true, false, false)
end

function _M._to_177_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	local _0 = "GROUND"

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", _0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Behav_Sing")
	flow:setContinue(177)

	return true
end

function _M._to_179_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 179, 0, "Behav_Love", 4, "", 0, "", true, false, false)
end

function _M._to_180_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 180, 0, "Skill_Conjure", 3, "", 0, "", true, false, false)
end

function _M._to_181_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 181, 0, "Skill_Conjure", 3, "", 0, "", true, false, false)
end

function _M._to_182_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 182, 0, "Skill_Conjure", 3, "", 0, "", true, false, false)
end

function _M._to_183_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 183, 0, "Skill_Conjure", 3, "", 0, "", true, false, false)
end

function _M._get_52_3(flow)
	return flow:getContextValue("tPortId")
end

function _M._get_52_2(flow)
	return flow:getContextValue("tPointId")
end

return _M
