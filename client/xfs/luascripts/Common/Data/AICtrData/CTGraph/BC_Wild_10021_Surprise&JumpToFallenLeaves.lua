-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10021_Surprise&JumpToFallenLeaves.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerGoToFallenLeaves" then
		return _M._to_98_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 98 then
		return _M._to_100_0(flow)
	end

	if nodeId == 99 then
		return _M._to_111_0(flow)
	end

	if nodeId == 100 then
		return _M._to_99_0(flow)
	end

	if nodeId == 111 then
		return _M._to_129_0(flow)
	end

	if nodeId == 123 then
		return _M._to_140_0(flow)
	end

	if nodeId == 140 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_98_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_139_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(98)

	return true
end

function _M._to_99_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Surprise")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 2)
	flow:setContinue(99)

	return true
end

function _M._to_100_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0.25)
	flow:setContinue(100)

	return true
end

function _M._to_111_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "AI_IdleSpecial03")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(111)

	return true
end

function _M._to_123_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_133_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tStopDist", 2)
	flow.__agent:addSubTreeLocalParam("tMaxTimeout", 15)
	flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
	flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
	flow:setContinue(123)

	return true
end

function _M._to_129_0(flow)
	local _1 = _M._get_130_3(flow)
	local _2 = not _1 or next(_1) == nil
	local _0 = not _2

	if _0 then
		flow:setActive()

		local _3 = _M._get_133_1(flow)

		_A(flow, "AddAITag", _3, "Env_BeUsed")

		return _M._to_123_0(flow)
	end
end

function _M._to_140_0(flow)
	if not _B(flow, "PBT_Node_Com_SwitchToHideMimicryIn") then
		return
	end

	local _0 = _M._get_134_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetPos", _0)
	flow:setContinue(140)

	return true
end

function _M._get_120_2(flow)
	local _2 = _M._get_130_2(flow)
	local _0 = _C(119, "HasEntityTag", flow, _2, "TE_Env_FallenLeaves")

	if not _0 then
		return false
	end

	local _4 = _M._get_130_2(flow)
	local _3 = _C(122, "HasAITag", flow, _4, "Env_BeUsed")
	local _1 = not _3

	if not _1 then
		return false
	end

	return true
end

function _M._get_130_2(flow)
	return flow:getCache(130, "__iterItem")
end

function _M._get_130_3(flow)
	local _0 = _C(135, "GetAoiEntityTableByLevel", flow, 0, 10, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(130, "__iterItem", v)

		if _M._get_120_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_132_1(flow)
	local _0 = _M._get_130_3(flow)

	return _C(132, "SelectOneByRandom", flow, _0)
end

function _M._get_133_1(flow)
	local _0 = flow:getCache(133, "FallenLeaves")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_132_1(flow)

	flow:setCache(133, "FallenLeaves", _0)

	return _0
end

function _M._get_134_1(flow)
	local _0 = _M._get_133_1(flow)

	return _C(134, "GetEntPosition", flow, _0)
end

function _M._get_139_1(flow)
	local _0 = _C(138, "GetAoiEntityTableByLevel", flow, 0, 30, 2)

	return _C(139, "SelectOneByRandom", flow, _0)
end

return _M
