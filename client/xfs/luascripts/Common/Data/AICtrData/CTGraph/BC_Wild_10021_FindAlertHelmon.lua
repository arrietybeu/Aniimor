-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10021_FindAlertHelmon.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_105_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_89_1(flow)
	local _1 = _M._get_89_2(flow)

	_A(flow, "ExitResPointPort", 0, _0, _1, 3, 0.5)

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 92 then
		return true
	end

	if nodeId == 94 then
		return _M._to_95_0(flow)
	end

	if nodeId == 95 then
		return true
	end

	if nodeId == 98 then
		return _M._to_100_0(flow)
	end

	if nodeId == 99 then
		return _M._to_91_0(flow)
	end

	if nodeId == 100 then
		return _M._to_99_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_91_0(flow)
	local _0 = _M._get_86_1(flow)

	if _0 then
		return _M._to_92_0(flow)
	end

	local _2 = _M._get_86_1(flow)
	local _1 = not _2

	if _1 then
		flow:setActive()

		local _3 = _M._get_89_1(flow)
		local _4 = _M._get_89_2(flow)

		_A(flow, "PreJoinResPointPort", 0, _3, _4)

		return _M._to_94_0(flow)
	end
end

function _M._to_92_0(flow)
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
	flow:setContinue(92)

	return true
end

function _M._to_94_0(flow)
	if not _B(flow, "PBT_MoveToResPointPortInDist") then
		return
	end

	local _0 = _M._get_89_1(flow)
	local _1 = _M._get_89_2(flow)

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
	flow:setContinue(94)

	return true
end

function _M._to_95_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "HideStart")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "HideLoop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "HideEnd")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 50)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(95)

	return true
end

function _M._to_98_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_103_1(flow)

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

function _M._to_105_0(flow)
	local _2 = _M._get_76_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _0 = not _3

	if _0 then
		flow:setActive()

		local _1 = _C(104, "GetSelfId", flow)

		_A(flow, "PlayEffectOnTarget", _1, "Eff_Common_Behav_Doubt", 1.5)

		return _M._to_98_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._get_66_3(flow)
	local _7 = _M._get_76_2(flow)
	local _0 = _C(106, "HasEntityTag", flow, _7, "TE_Puppet_Alert10021AlertLine")

	if not _0 then
		return false
	end

	local _5 = _M._get_76_2(flow)
	local _6 = _C(69, "GetPuppetData", flow, _5, "petPrototypeId", true, 0)
	local _1 = _6 == 100210007

	if not _1 then
		return false
	end

	local _3 = _M._get_76_2(flow)
	local _4 = _C(67, "GetDistance", flow, _3, 0, false)
	local _2 = _4 <= 15

	if not _2 then
		return false
	end

	return true
end

function _M._get_76_2(flow)
	return flow:getCache(76, "__iterItem")
end

function _M._get_76_3(flow)
	local _0 = _C(65, "GetAoiEntityTableByLevel", flow, 0, 30, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(76, "__iterItem", v)

		if _M._get_66_3(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_85_3(flow)
	return _C(85, "GetAoiResPointPortTableByLevel", flow, 0, 10, 10, {
		"10021HidePoint"
	}, nil)
end

function _M._get_86_1(flow)
	local _0 = _M._get_85_3(flow)

	return not _0 or next(_0) == nil
end

function _M._get_87_1(flow)
	local _0 = _M._get_85_3(flow)

	return _C(87, "SelectOneByRandom", flow, _0)
end

function _M._get_88_1(flow)
	local _0 = flow:getCache(88, "resPoint")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_87_1(flow)

	flow:setCache(88, "resPoint", _0)

	return _0
end

function _M._get_89_2(flow)
	local _0 = _M._get_88_1(flow)

	return _C(89, "UnpackResPointPort", flow, _0, 2)
end

function _M._get_89_1(flow)
	local _0 = _M._get_88_1(flow)

	return _C(89, "UnpackResPointPort", flow, _0, 1)
end

function _M._get_102_1(flow)
	local _0 = _M._get_76_3(flow)

	return _C(102, "SelectOneByRandom", flow, _0)
end

function _M._get_103_1(flow)
	local _0 = flow:getCache(103, "Puppet10023")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_102_1(flow)

	flow:setCache(103, "Puppet10023", _0)

	return _0
end

return _M
