-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_Protect_AlertAround.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tTgtId", value0)
	agent:addSubTreeLocalParam("tTargetAtYawDegree", value1)
	agent:addSubTreeLocalParam("tInstant", value2)
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

local function _doBehaviourTail_2(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8, value9)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tTargetActorId", value0)
	agent:addSubTreeLocalParam("tStopDist", value1)
	agent:addSubTreeLocalParam("tMaxTimeout", value2)
	agent:addSubTreeLocalParam("tFaceTarget", value3)
	agent:addSubTreeLocalParam("tTargetYaw", value4)
	agent:addSubTreeLocalParam("tTargetDistance", value5)
	agent:addSubTreeLocalParam("tNoBodySize", value6)
	agent:addSubTreeLocalParam("tSpeed", value7)
	agent:addSubTreeLocalParam("tSpeedRateType", value8)
	agent:addSubTreeLocalParam("tUseAccurateArrive", value9)
	flow:setContinue(nodeId)

	return true
end

function _M.executeTickLodTrigger(flow)
	return _M._to_239_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _C(238, "GetSelfId", flow)

	_A(flow, "HideEmojiOnTarget", _0, "Alert")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 196 then
		return _M._to_217_0(flow)
	end

	if nodeId == 197 then
		return _M._to_196_0(flow)
	end

	if nodeId == 217 then
		return _M._to_225_0(flow)
	end

	if nodeId == 223 then
		return _M._to_224_0(flow)
	end

	if nodeId == 224 then
		return _M._to_235_0(flow)
	end

	if nodeId == 225 then
		return _M._to_223_0(flow)
	end

	if nodeId == 230 then
		return true
	end

	if nodeId == 235 then
		return _M._to_230_0(flow)
	end

	if nodeId == 239 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_196_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_234_1(flow)

	return _doBehaviourTail_0(flow, 196, _0, 180, false)
end

function _M._to_217_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 217, 0, "Behav_Alert", 0, "Alert", 4, "", false, false, false)
end

function _M._to_223_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_234_1(flow)

	return _doBehaviourTail_0(flow, 223, _0, 180, false)
end

function _M._to_224_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 224, 0, "Behav_Alert", 0, "Alert", 4, "", false, false, false)
end

function _M._to_225_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntityAtPos") then
		return
	end

	local _0 = _M._get_234_1(flow)

	return _doBehaviourTail_2(flow, 225, _0, 0, 30, false, 20, 5, true, 0, 0, false)
end

function _M._to_230_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_234_1(flow)

	return _doBehaviourTail_0(flow, 230, _0, 0, false)
end

function _M._to_235_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntityAtPos") then
		return
	end

	local _0 = _M._get_234_1(flow)

	return _doBehaviourTail_2(flow, 235, _0, 0, 30, false, 20, 2.5, true, 0, 0, false)
end

function _M._to_239_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_204_4(flow)

	if _0 then
		flow:setActive()
		_C(239, "DoBehaviour", flow, "PBT_Com_Alert")

		local _1 = _M._get_234_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow:setContinue(239)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_204_4(flow)
	local _6 = _M._get_205_0(flow)
	local _0 = _C(241, "IsInCharState", flow, _6, 1, 4)

	if not _0 then
		return false
	end

	local _3 = _M._get_205_0(flow)
	local _4 = _C(206, "GetAnimTagDuration", flow, _3)
	local _1 = _4 > 4

	if not _1 then
		return false
	end

	local _5 = _C(209, "RandomInteger", flow, 1, 10)
	local _2 = _5 < 5

	if not _2 then
		return false
	end

	if false then
		return false
	end

	return true
end

function _M._get_205_0(flow)
	return _C(205, "GetSelfId", flow)
end

function _M._get_234_1(flow)
	return _C(234, "GetPetMaster", flow, 0)
end

return _M
