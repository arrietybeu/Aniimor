-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_GlassSong.lua

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

local function _doBehaviourTail_1(flow, nodeId, value0, value1, value2, value3, value4, value5)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tTargetActorId", value0)
	agent:addSubTreeLocalParam("tRadius", value1)
	agent:addSubTreeLocalParam("tSpeed", value2)
	agent:addSubTreeLocalParam("tSpeedRateType", value3)
	agent:addSubTreeLocalParam("tClockwise", value4)
	agent:addSubTreeLocalParam("tTimeout", value5)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_2(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8)
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
	return _M._to_4_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 4 then
		return _M._to_5_0(flow)
	end

	if nodeId == 5 then
		return _M._to_9_0(flow)
	end

	if nodeId == 6 then
		return _M._to_7_0(flow)
	end

	if nodeId == 7 then
		return _M._to_30_0(flow)
	end

	if nodeId == 8 then
		return true
	end

	if nodeId == 29 then
		return _M._to_6_0(flow)
	end

	if nodeId == 30 then
		return _M._to_8_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_4_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_17_1(flow)

	if _0 then
		flow:setActive()
		_C(4, "DoBehaviour", flow, "PBT_TurnToTargetAtYaw")

		local _1 = _M._get_19_1(flow)

		return _doBehaviourTail_0(flow, 4, _1, 0, false)
	else
		flow:setActiveFail()
	end
end

function _M._to_5_0(flow)
	if not _B(flow, "PBT_MoveAroundTarget") then
		return
	end

	local _0 = _M._get_19_1(flow)

	return _doBehaviourTail_1(flow, 5, _0, 2, 0, 1, true, 1)
end

function _M._to_6_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_2(flow, 6, 0, "IdleSpecial", 5, "Happy", 5, "", false, true, false)
end

function _M._to_7_0(flow)
	if not _B(flow, "PBT_MoveAroundTarget") then
		return
	end

	local _0 = _M._get_19_1(flow)

	return _doBehaviourTail_1(flow, 7, _0, 2, 0, 1, false, 1)
end

function _M._to_8_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_2(flow, 8, 0, "IdleSpecial02", 5, "Happy", 5, "", false, true, false)
end

function _M._to_9_0(flow)
	flow:setActive()

	local _1 = _M._get_19_1(flow)
	local _0 = _C(31, "GetControllingPetActorId", flow, _1)

	_A(flow, "SendMessageToTrigger", _0, 2)

	return _M._to_29_0(flow)
end

function _M._to_29_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_19_1(flow)

	return _doBehaviourTail_0(flow, 29, _0, 0, false)
end

function _M._to_30_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_19_1(flow)

	return _doBehaviourTail_0(flow, 30, _0, 0, false)
end

function _M._get_1_3(flow)
	local _0 = _C(0, "GetAoiEntityTableByLevel", flow, 0, 30, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(1, "__iterItem", v)

		if _M._get_14_3(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_1_2(flow)
	return flow:getCache(1, "__iterItem")
end

function _M._get_11_1(flow)
	local _0 = _M._get_1_2(flow)

	return _C(11, "GetControllingPetActorId", flow, _0)
end

function _M._get_14_3(flow)
	local _3 = _M._get_1_2(flow)
	local _0 = _C(10, "IsControllingPet", flow, _3)

	if not _0 then
		return false
	end

	local _5 = _M._get_11_1(flow)
	local _4 = _C(20, "GetPetData", flow, _5, "petPrototypeId", true, 0)
	local _1 = _4 == 1020100

	if not _1 then
		return false
	end

	local _2 = _M._get_27_2(flow)

	if not _2 then
		return false
	end

	return true
end

function _M._get_17_1(flow)
	local _1 = _M._get_1_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_18_1(flow)
	local _0 = _M._get_1_3(flow)

	return _C(18, "SelectOneByRandom", flow, _0)
end

function _M._get_19_1(flow)
	local _0 = flow:getCache(19, "sg")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_18_1(flow)

	flow:setCache(19, "sg", _0)

	return _0
end

function _M._get_27_2(flow)
	local _2 = _M._get_11_1(flow)
	local _0 = _C(25, "IsInAnimState", flow, _2, "IdleSpecial")

	if _0 then
		return true
	end

	local _3 = _M._get_11_1(flow)
	local _1 = _C(26, "IsInAnimState", flow, _3, "IdleSpecial02")

	if _1 then
		return true
	end

	return false
end

return _M
