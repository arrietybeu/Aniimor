-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10351_LevelMsg_FlyToFlower.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerFlyToFlower" then
		return _M._to_119_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 119 then
		return _M._to_137_0(flow)
	end

	if nodeId == 140 then
		return true
	end

	if nodeId == 141 then
		return _M._to_140_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_119_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_136_2(flow)

	if _0 then
		flow:setActive()
		_C(119, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_134_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 1)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 6)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 5)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(119)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_137_0(flow)
	flow:setActive()

	local _0 = _M._get_138_1(flow)
	local _1 = flow:getMessageContext()

	_1.sourceActorId = flow.__actorId

	flow:sendMessage(_0, "Msg_PartnerMsg", _1)

	return _M._to_141_0(flow)
end

function _M._to_140_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Alert")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_AlertStart")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_AlertLoop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_AlertEnd")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 0)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", true)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(140)

	return true
end

function _M._to_141_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_138_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(141)

	return true
end

function _M._get_120_3(flow)
	local _0 = _C(126, "GetAoiEntityTableByLevel", flow, 0, 30, 64)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(120, "__iterItem", v)

		if _M._get_127_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_120_2(flow)
	return flow:getCache(120, "__iterItem")
end

function _M._get_125_3(flow)
	local _0 = flow:getCache(130, "__iterItem")

	return _C(125, "GetDistance", flow, _0, 0, false)
end

function _M._get_127_2(flow)
	local _0 = _M._get_120_2(flow)

	return _C(127, "HasEntityTag", flow, _0, "TE_Chest_ChargeTarget")
end

function _M._get_130_2(flow)
	local _0 = _M._get_120_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(130, "__iterItem", v)

		_1 = _M._get_125_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_134_1(flow)
	local _0 = flow:getCache(134, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_130_2(flow)

	flow:setCache(134, "1", _0)

	return _0
end

function _M._get_136_2(flow)
	local _2 = _M._get_120_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _0 = not _3

	if not _0 then
		return false
	end

	local _4 = _M._get_134_1(flow)
	local _1 = _C(135, "CheckEntityExist", flow, _4)

	if not _1 then
		return false
	end

	return true
end

function _M._get_138_1(flow)
	return _C(138, "GetLeaderId", flow, 0)
end

return _M
