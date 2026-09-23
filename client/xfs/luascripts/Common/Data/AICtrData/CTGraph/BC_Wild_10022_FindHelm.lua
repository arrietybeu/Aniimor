-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10022_FindHelm.lua

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

local function _doBehaviourTail_2(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value0)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value1)
	flow:setContinue(nodeId)

	return true
end

function _M.executeTickLodTrigger(flow)
	return _M._to_80_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 93 then
		return _M._to_111_0(flow)
	end

	if nodeId == 96 then
		return true
	end

	if nodeId == 98 then
		return _M._to_101_0(flow)
	end

	if nodeId == 100 then
		return true
	end

	if nodeId == 101 then
		return _M._to_100_0(flow)
	end

	if nodeId == 107 then
		return _M._to_93_0(flow)
	end

	if nodeId == 110 then
		return _M._to_112_0(flow)
	end

	if nodeId == 111 then
		return _M._to_110_0(flow)
	end

	if nodeId == 112 then
		return _M._to_96_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_80_0(flow)
	local _2 = _M._get_44_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _0 = not _3

	if _0 then
		return _M._to_107_0(flow)
	end

	local _4 = _M._get_76_3(flow)
	local _5 = not _4 or next(_4) == nil
	local _1 = not _5

	if _1 then
		flow:setActive()

		local _6 = _C(106, "GetSelfId", flow)

		_A(flow, "PlayEffectOnTarget", _6, "Eff_Common_Behav_Doubt", 1.5)

		return _M._to_98_0(flow)
	end
end

function _M._to_93_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_103_1(flow)

	return _doBehaviourTail_0(flow, 93, _0, 0, false)
end

function _M._to_96_0(flow)
	if not _B(flow, "PBT_LeaveTarget") then
		return
	end

	local _0 = _M._get_103_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tLeaveDistance", 30)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tMaxTime", 0)
	flow:setContinue(96)

	return true
end

function _M._to_98_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_84_1(flow)

	return _doBehaviourTail_0(flow, 98, _0, 0, false)
end

function _M._to_100_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0.75)
	flow:setContinue(100)

	return true
end

function _M._to_101_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 101, 0, "Skill_Breath", 1.2, "0", 0, "", false, false, false)
end

function _M._to_107_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_2(flow, 107, "Surprise", 2)
end

function _M._to_110_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 110, 0, "Skill_Breath", 1, "0", 0, "", false, false, false)
end

function _M._to_111_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 111, 0, "JumpBack", 0.6, "", 0, "", false, false, false)
end

function _M._to_112_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	return _doBehaviourTail_2(flow, 112, "Proud", 2)
end

function _M._get_25_1(flow)
	local _0 = _M._get_44_3(flow)

	return _C(25, "SelectOneByRandom", flow, _0)
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
	local _1 = _3 <= 8

	if not _1 then
		return false
	end

	return true
end

function _M._get_66_2(flow)
	local _4 = _M._get_76_2(flow)
	local _5 = _C(69, "GetPuppetData", flow, _4, "petPrototypeId", true, 0)
	local _0 = _5 == 1002100

	if not _0 then
		return false
	end

	local _2 = _M._get_76_2(flow)
	local _3 = _C(67, "GetDistance", flow, _2, 0, false)
	local _1 = _3 <= 8

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
	local _0 = _2 == 1002600

	if _0 then
		return true
	end

	local _3 = _M._get_39_2(flow)
	local _1 = _3 == 1002700

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
	local _0 = flow:getCache(84, "Puppet10021")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_83_1(flow)

	flow:setCache(84, "Puppet10021", _0)

	return _0
end

function _M._get_103_1(flow)
	local _0 = flow:getCache(103, "Puppet10026&10027")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_25_1(flow)

	flow:setCache(103, "Puppet10026&10027", _0)

	return _0
end

return _M
