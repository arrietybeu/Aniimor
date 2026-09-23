-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10141_KongMingLantern_Fly.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
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

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Msg_KMLantern_Fly" then
		return _M._to_13_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _C(16, "GetSelfId", flow)

	_A(flow, "StopEffectOnTarget", _0, "Eff_Parmon_10141_KongMingLight")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 5 then
		return _M._to_8_0(flow)
	end

	if nodeId == 8 then
		return _M._to_10_0(flow)
	end

	if nodeId == 9 then
		return _M._to_5_0(flow)
	end

	if nodeId == 10 then
		return true
	end

	if nodeId == 13 then
		return _M._to_9_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_5_0(flow)
	if not _B(flow, "PBT_10141_FlyToHeight") then
		return
	end

	local _0 = _C(2, "GetSelfId", flow)

	return _doBehaviourTail_0(flow, 5, 6.72, _0, 12, 0.672)
end

function _M._to_8_0(flow)
	if not _B(flow, "PBT_10141_FlyToHeight") then
		return
	end

	local _0 = _C(6, "GetSelfId", flow)

	return _doBehaviourTail_0(flow, 8, 6.72, _0, 12, 0.672)
end

function _M._to_9_0(flow)
	if not _B(flow, "PBT_PlayEffectOnTarget") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEffectName", "Eff_Parmon_10141_KongMingLight")
	flow.__agent:addSubTreeLocalParam("tTargetActorId", 0)
	flow:setContinue(9)

	return true
end

function _M._to_10_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 10)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Idle")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(10)

	return true
end

function _M._to_13_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	local _0 = _C(14, "RandomInteger", flow, 0, 1)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", _0)
	flow:setContinue(13)

	return true
end

return _M
