-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10142_KongMingLantern.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tHeight", value0)
	agent:addSubTreeLocalParam("tActorId", value1)
	agent:addSubTreeLocalParam("tWaitTime", value2)
	agent:addSubTreeLocalParam("tSpeed", value3)
	flow:setContinue(nodeId)

	return true
end

local function _doBehaviourTail_1(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tEffectName", value0)
	agent:addSubTreeLocalParam("tTargetActorId", value1)
	flow:setContinue(nodeId)

	return true
end

function _M.executeTickLodTrigger(flow)
	return _M._to_15_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 1 then
		return _M._to_21_0(flow)
	end

	if nodeId == 4 then
		return true
	end

	if nodeId == 23 then
		return _M._to_33_0(flow)
	end

	if nodeId == 28 then
		return _M._to_23_0(flow)
	end

	if nodeId == 33 then
		return _M._to_40_0(flow)
	end

	if nodeId == 40 then
		return _M._to_20_0(flow)
	end

	if nodeId == 41 then
		return _M._to_42_0(flow)
	end

	if nodeId == 42 then
		return _M._to_4_0(flow)
	end

	if nodeId == 45 then
		return _M._to_1_0(flow)
	end

	if nodeId == 47 then
		return _M._to_5_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_1_0(flow)
	if not _B(flow, "PBT_SwitchToFly") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tFlyHeight", 0)
	flow.__agent:addSubTreeLocalParam("tMaxTime", 2)
	flow:setContinue(1)

	return true
end

function _M._to_4_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", "GROUND")
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(4)

	return true
end

function _M._to_5_0(flow)
	flow:setActive()

	local _0 = _M._get_9_3(flow)

	for _, v in ipairs(_0) do
		local _1 = flow:getMessageContext()

		_1.sourceActorId = flow.__actorId

		flow:sendMessage(v, "Msg_KMLantern_come", _1)
	end

	return _M._to_45_0(flow)
end

function _M._to_15_0(flow)
	local _0 = _M._get_55_2(flow)

	if _0 then
		return _M._to_47_0(flow)
	end
end

function _M._to_20_0(flow)
	flow:setActive()

	local _0 = _M._get_9_3(flow)

	for _, v in ipairs(_0) do
		local _1 = flow:getMessageContext()

		_1.sourceActorId = flow.__actorId

		flow:sendMessage(v, "Msg_KMLantern_End", _1)
	end

	return _M._to_41_0(flow)
end

function _M._to_21_0(flow)
	flow:setActive()

	local _0 = _M._get_9_3(flow)

	for _, v in ipairs(_0) do
		local _1 = flow:getMessageContext()

		_1.sourceActorId = flow.__actorId

		flow:sendMessage(v, "Msg_KMLantern_Fly", _1)
	end

	return _M._to_28_0(flow)
end

function _M._to_23_0(flow)
	if not _B(flow, "PBT_10141_FlyToHeight") then
		return
	end

	local _0 = _M._get_29_0(flow)

	return _doBehaviourTail_0(flow, 23, 8, _0, 12, 0.8)
end

function _M._to_28_0(flow)
	if not _B(flow, "PBT_PlayEffectOnTarget") then
		return
	end

	local _0 = _M._get_29_0(flow)

	return _doBehaviourTail_1(flow, 28, "Eff_Parmon_10142_KongMingLight", _0)
end

function _M._to_33_0(flow)
	if not _B(flow, "PBT_10141_FlyToHeight") then
		return
	end

	local _0 = _M._get_35_0(flow)

	return _doBehaviourTail_0(flow, 33, 8, _0, 12, 0.8)
end

function _M._to_40_0(flow)
	if not _B(flow, "PBT_Node_Com_StopEffectOnTarget") then
		return
	end

	local _0 = _M._get_35_0(flow)

	return _doBehaviourTail_1(flow, 40, "Eff_Parmon_10142_KongMingLight", _0)
end

function _M._to_41_0(flow)
	if not _B(flow, "PBT_PlayEffectOnTarget") then
		return
	end

	local _0 = _M._get_44_0(flow)

	return _doBehaviourTail_1(flow, 41, "Eff_Parmon_10142_KongMingLight_End", _0)
end

function _M._to_42_0(flow)
	if not _B(flow, "PBT_10141_FlyToHeight") then
		return
	end

	local _0 = _M._get_44_0(flow)

	return _doBehaviourTail_0(flow, 42, -15, _0, 10, 1.5)
end

function _M._to_45_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 3)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Idle")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 3)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Chat")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 3)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(45)

	return true
end

function _M._to_47_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Chat")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 3)
	flow:setContinue(47)

	return true
end

function _M._get_9_2(flow)
	return flow:getCache(9, "__iterItem")
end

function _M._get_9_3(flow)
	local _0 = _C(13, "GetAoiEntityTableByLevel", flow, 0, 10, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(9, "__iterItem", v)

		if _M._get_17_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_17_2(flow)
	local _1 = _M._get_9_2(flow)
	local _0 = _C(19, "GetPuppetData", flow, _1, "id", true, 0)

	return _0 == 11014100
end

function _M._get_29_0(flow)
	return _C(29, "GetSelfId", flow)
end

function _M._get_35_0(flow)
	return _C(35, "GetSelfId", flow)
end

function _M._get_44_0(flow)
	return _C(44, "GetSelfId", flow)
end

function _M._get_54_2(flow)
	local _4 = _C(48, "GetAoiEntityTableByLevel", flow, 0, 100, 2)
	local _5 = not _4 or next(_4) == nil
	local _0 = not _5

	if _0 then
		return true
	end

	local _3 = _C(49, "GetAoiEntityTableByLevel", flow, 0, 100, 4)
	local _2 = not _3 or next(_3) == nil
	local _1 = not _2

	if _1 then
		return true
	end

	return false
end

function _M._get_55_2(flow)
	local _0 = _M._get_54_2(flow)

	if not _0 then
		return false
	end

	local _3 = _M._get_9_3(flow)
	local _2 = not _3 or next(_3) == nil
	local _1 = not _2

	if not _1 then
		return false
	end

	return true
end

return _M
