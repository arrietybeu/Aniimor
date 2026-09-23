-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10027_FindHelgon.lua

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

function _M.executeTickLodTrigger(flow)
	return _M._to_80_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 37 then
		return _M._to_91_0(flow)
	end

	if nodeId == 82 then
		return _M._to_92_0(flow)
	end

	if nodeId == 87 then
		return _M._to_82_0(flow)
	end

	if nodeId == 88 then
		return true
	end

	if nodeId == 91 then
		return true
	end

	if nodeId == 92 then
		return _M._to_88_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_37_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_27_1(flow)

	return _doBehaviourTail_0(flow, 37, _0, 0, false)
end

function _M._to_80_0(flow)
	local _2 = _M._get_44_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _0 = not _3

	if _0 then
		flow:setActive()

		local _6 = _C(89, "GetSelfId", flow)

		_A(flow, "PlayEffectOnTarget", _6, "Eff_Common_Behav_Doubt", 4)

		return _M._to_37_0(flow)
	end

	local _4 = _M._get_76_3(flow)
	local _5 = not _4 or next(_4) == nil
	local _1 = not _5

	if _1 then
		return _M._to_87_0(flow)
	end
end

function _M._to_82_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_84_1(flow)

	return _doBehaviourTail_0(flow, 82, _0, 0, false)
end

function _M._to_87_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Surprise")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 4)
	flow:setContinue(87)

	return true
end

function _M._to_88_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 88, 0, "", 5, "Skill_DefMode_Start", "Skill_DefMode_Loop", "Skill_DefMode_End", 8, "", false, false)
end

function _M._to_91_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 91, 0, "", 5, "Behav_AngryStart", "Behav_AngryLoop", "Behav_AngryEnd", 8, "", false, false)
end

function _M._to_92_0(flow)
	if not _B(flow, "PBT_LeaveTarget") then
		return
	end

	local _0 = _M._get_84_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tLeaveDistance", 15)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tMaxTime", 0)
	flow:setContinue(92)

	return true
end

function _M._get_25_1(flow)
	local _0 = _M._get_44_3(flow)

	return _C(25, "SelectOneByRandom", flow, _0)
end

function _M._get_27_1(flow)
	local _0 = flow:getCache(27, "Puppet10022&10024")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_25_1(flow)

	flow:setCache(27, "Puppet10022&10024", _0)

	return _0
end

function _M._get_39_2(flow)
	local _0 = _M._get_44_2(flow)

	return _C(39, "GetPuppetData", flow, _0, "petPrototypeId", true, 0)
end

function _M._get_44_2(flow)
	return flow:getCache(44, "__iterItem")
end

function _M._get_44_3(flow)
	local _0 = _C(16, "GetAoiEntityTableByLevel", flow, 0, 30, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(44, "__iterItem", v)

		if _M._get_46_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_46_2(flow)
	local _0 = _M._get_77_2(flow)

	if not _0 then
		return false
	end

	local _2 = _M._get_44_2(flow)
	local _3 = _C(20, "GetDistance", flow, _2, 0, false)
	local _1 = _3 <= 10

	if not _1 then
		return false
	end

	return true
end

function _M._get_66_2(flow)
	local _4 = _M._get_76_2(flow)
	local _5 = _C(69, "GetPuppetData", flow, _4, "petPrototypeId", true, 0)
	local _0 = _5 == 1002300

	if not _0 then
		return false
	end

	local _2 = _M._get_76_2(flow)
	local _3 = _C(67, "GetDistance", flow, _2, 0, false)
	local _1 = _3 <= 10

	if not _1 then
		return false
	end

	return true
end

function _M._get_76_3(flow)
	local _0 = _C(65, "GetAoiEntityTableByLevel", flow, 0, 30, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(76, "__iterItem", v)

		if _M._get_66_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_76_2(flow)
	return flow:getCache(76, "__iterItem")
end

function _M._get_77_2(flow)
	local _2 = _M._get_39_2(flow)
	local _0 = _2 == 1002200

	if _0 then
		return true
	end

	local _3 = _M._get_39_2(flow)
	local _1 = _3 == 1002400

	if _1 then
		return true
	end

	return false
end

function _M._get_83_1(flow)
	local _0 = _M._get_76_3(flow)

	return _C(83, "SelectOneByRandom", flow, _0)
end

function _M._get_84_1(flow)
	local _0 = flow:getCache(84, "Puppet10023")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_83_1(flow)

	flow:setCache(84, "Puppet10023", _0)

	return _0
end

return _M
