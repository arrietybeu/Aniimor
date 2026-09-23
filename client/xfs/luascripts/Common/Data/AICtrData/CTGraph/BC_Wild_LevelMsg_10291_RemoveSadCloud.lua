-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_LevelMsg_10291_RemoveSadCloud.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerDoRemoveSadCloud" then
		return _M._to_131_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 131 then
		return _M._to_138_0(flow)
	end

	if nodeId == 132 then
		return _M._to_135_0(flow)
	end

	if nodeId == 133 then
		return _M._to_134_0(flow)
	end

	if nodeId == 134 then
		return _M._to_162_0(flow)
	end

	if nodeId == 138 then
		return _M._to_132_0(flow)
	end

	if nodeId == 146 then
		return true
	end

	if nodeId == 155 then
		return true
	end

	if nodeId == 162 then
		return _M._to_155_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_131_0(flow)
	if not _B(flow, "PBT_ShowQuestionMark") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tMarkType", "DirectFull")
	flow.__agent:addSubTreeLocalParam("tTimeout", 1)
	flow:setContinue(131)

	return true
end

function _M._to_132_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_27_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tSkillId", 12930900)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(132)

	return true
end

function _M._to_133_0(flow)
	if not _B(flow, "PBT_TurnToTargetPos") then
		return
	end

	local _0 = _M._get_137_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tTargetPos", _0)
	flow:setContinue(133)

	return true
end

function _M._to_134_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Proud")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 4)
	flow:setContinue(134)

	return true
end

function _M._to_135_0(flow)
	return _M._to_133_0(flow)
end

function _M._to_138_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 1)
	flow:setContinue(138)

	return true
end

function _M._to_155_0(flow)
	if not _B(flow, "PBT_Com_Happy_New") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tPlayOnce", true)
	flow:setContinue(155)

	return true
end

function _M._to_162_0(flow)
	if not _B(flow, "PBT_Com_MoveToBornPos") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(162)

	return true
end

function _M._get_25_1(flow)
	local _0 = _C(129, "GetAoiResPointPortTableByLevel", flow, 0, 10, 0, {
		"TE_Env_SadCloud_01"
	}, {
		""
	})

	return _C(25, "SelectOneByRandom", flow, _0)
end

function _M._get_27_1(flow)
	local _0 = flow:getCache(27, "Stone")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_25_1(flow)

	flow:setCache(27, "Stone", _0)

	return _0
end

function _M._get_137_1(flow)
	local _0 = _M._get_27_1(flow)

	return _C(137, "GetEntPosition", flow, _0)
end

function _M._get_143_1(flow)
	local _0 = _C(147, "GetSelfId", flow)

	return _C(143, "GetAIBlackboardValue", flow, _0, "bornPos")
end

return _M
