-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10221_CatchBird.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
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

function _M.executeTickLodTrigger(flow)
	return _M._to_59_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 58 then
		return _M._to_63_0(flow)
	end

	if nodeId == 59 then
		return _M._to_58_0(flow)
	end

	if nodeId == 60 then
		return true
	end

	if nodeId == 63 then
		return _M._to_64_0(flow)
	end

	if nodeId == 64 then
		return _M._to_67_0(flow)
	end

	if nodeId == 67 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_58_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 58, 0, "Behav_LoveStart", 0.833, "", 5, "", false, true, false)
end

function _M._to_59_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_5_1(flow)

	if _0 then
		flow:setActive()
		_C(59, "DoBehaviour", flow, "PBT_TurnToTargetAtYaw")

		local _1 = _M._get_10_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTgtId", _1)
		flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
		flow.__agent:addSubTreeLocalParam("tInstant", false)
		flow:setContinue(59)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_63_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntityAtPos") then
		return
	end

	local _0 = _M._get_10_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tStopDist", 2)
	flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
	flow.__agent:addSubTreeLocalParam("tTargetYaw", 0)
	flow.__agent:addSubTreeLocalParam("tTargetDistance", 0)
	flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow:setContinue(63)

	return true
end

function _M._to_64_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 64, 0, "Attack01", 1.967, "", 0, "", false, true, false)
end

function _M._to_67_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 67, 0, "IdleSpecial", 4.3, "Happy", 4, "", false, true, false)
end

function _M._get_2_3(flow)
	local _0 = _C(1, "GetAoiEntityTableByLevel", flow, 0, 10, 14)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(2, "__iterItem", v)

		if _M._get_24_3(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_2_2(flow)
	return flow:getCache(2, "__iterItem")
end

function _M._get_5_1(flow)
	local _1 = _M._get_2_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_9_1(flow)
	local _0 = _M._get_2_3(flow)

	return _C(9, "SelectOneByRandom", flow, _0)
end

function _M._get_10_1(flow)
	local _0 = flow:getCache(10, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_9_1(flow)

	flow:setCache(10, "1", _0)

	return _0
end

function _M._get_24_3(flow)
	local _1 = _M._get_2_2(flow)
	local _0 = _C(62, "HasEntityTag", flow, _1, "TE_Wild_Birds")

	if not _0 then
		return false
	end

	if false then
		return false
	end

	if false then
		return false
	end

	return true
end

return _M
