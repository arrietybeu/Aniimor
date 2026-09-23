-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_SeekLoveOttery_LoveResponse.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8, value9)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tTargetActorId", value0)
	agent:addSubTreeLocalParam("tStopDist", value1)
	agent:addSubTreeLocalParam("tMaxTimeout", value2)
	agent:addSubTreeLocalParam("tFaceTarget", value3)
	agent:addSubTreeLocalParam("tSpeed", value4)
	agent:addSubTreeLocalParam("tMoveUpdateLevel", value5)
	agent:addSubTreeLocalParam("tPathFindType", value6)
	agent:addSubTreeLocalParam("tSpeedRateType", value7)
	agent:addSubTreeLocalParam("tUseAccurateArrive", value8)
	agent:addSubTreeLocalParam("tNoBodySize", value9)
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

function _M.executeEventTrigger(flow, eventName)
	if eventName == "SeekLoveStartMsgTrigger" then
		return _M._to_53_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	return _M._to_25_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 18 then
		return _M._to_21_0(flow)
	end

	if nodeId == 21 then
		return _M._to_51_0(flow)
	end

	if nodeId == 22 then
		return _M._to_23_0(flow)
	end

	if nodeId == 23 then
		return _M._to_36_0(flow)
	end

	if nodeId == 25 then
		return true
	end

	if nodeId == 36 then
		return _M._to_39_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_18_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_31_1(flow)

	return _doBehaviourTail_0(flow, 18, _0, 4, 10, true, 3, 99999, 0, 0, false, false)
end

function _M._to_21_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 21, 0, "Behav_Alert", 6, "Shy", 1, "", false, false, false)
end

function _M._to_22_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_31_1(flow)

	return _doBehaviourTail_0(flow, 22, _0, 0.65, 5, true, 0.6, 99999, 0, 0, false, false)
end

function _M._to_23_0(flow)
	if not _B(flow, "PBT_CustomLoopAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Strong")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 1)
	flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "Behav_MakeLove_Start")
	flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "Behav_MakeLove_Loop")
	flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "Behav_MakeLove_End")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 1.5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow:setContinue(23)

	return true
end

function _M._to_25_0(flow)
	flow:setActive()

	local _0 = flow:getSubFlow("BC_SeekLove_Love_Exit")
	local _1 = _C(26, "GetSelfId", flow)
	local _2 = _M._get_31_1(flow)

	_0:setContextValue("myActorId", _1)
	_0:setContextValue("targetActorId", _2)

	if _0:executeSubFlow() then
		flow:setContinue(25)

		if _0:isFinish() then
			return flow:executeContinue()
		end

		return true
	end
end

function _M._to_36_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_1(flow, 36, 0.5, "AI_Idle", 0.3, "", 0, "", false, false, false)
end

function _M._to_39_0(flow)
	flow:setActive()

	local _0 = _C(40, "GetSelfId", flow)

	_A(flow, "StopEffectOnTarget", _0, "Eff_Common_EnvBehav_SeekLove")

	return true
end

function _M._to_51_0(flow)
	flow:setActive()

	local _0 = _C(52, "GetAoiEntityTableByLevel", flow, 0, 50, 8)

	for _, v in ipairs(_0) do
		local _1 = flow:getMessageContext()

		_1.sourceActorId = flow.__actorId

		flow:sendMessage(v, "Love_Song", _1)
	end

	return _M._to_22_0(flow)
end

function _M._to_53_0(flow)
	flow:setActive()

	local _0 = _M._get_58_2(flow)

	for _, v in ipairs(_0) do
		local _1 = flow:getMessageContext()

		_1.sourceActorId = flow.__actorId

		flow:sendMessage(v, "Love_Song", _1)
	end

	return _M._to_18_0(flow)
end

function _M._get_2_1(flow)
	return flow:getContextValue("targetActorId")
end

function _M._get_31_1(flow)
	local _0 = flow:getCache(31, "LovePartnerId")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_2_1(flow)

	flow:setCache(31, "LovePartnerId", _0)

	return _0
end

function _M._get_55_2(flow)
	local _0 = flow:getCache(58, "__iterItem")

	return _C(55, "HasEntityTag", flow, _0, "TE_Par_Whistle")
end

function _M._get_58_2(flow)
	local _0 = _C(54, "GetAoiEntityTableByLevel", flow, 0, 30, 8)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(58, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_55_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

return _M
