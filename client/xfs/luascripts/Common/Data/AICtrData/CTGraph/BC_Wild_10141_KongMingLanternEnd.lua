-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10141_KongMingLanternEnd.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tEffectName", value0)
	agent:addSubTreeLocalParam("tTargetActorId", value1)
	flow:setContinue(nodeId)

	return true
end

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Msg_KMLantern_End" then
		return _M._to_5_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 1 then
		return true
	end

	if nodeId == 3 then
		return _M._to_4_0(flow)
	end

	if nodeId == 4 then
		return _M._to_1_0(flow)
	end

	if nodeId == 5 then
		return _M._to_3_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_1_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", "GROUND")
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(1)

	return true
end

function _M._to_3_0(flow)
	if not _B(flow, "PBT_PlayEffectOnTarget") then
		return
	end

	local _0 = _M._get_2_0(flow)

	return _doBehaviourTail_0(flow, 3, "Eff_Parmon_10141_KongMingLight_End", _0)
end

function _M._to_4_0(flow)
	if not _B(flow, "PBT_10141_FlyToHeight") then
		return
	end

	local _0 = _M._get_2_0(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tHeight", -13)
	flow.__agent:addSubTreeLocalParam("tActorId", _0)
	flow.__agent:addSubTreeLocalParam("tWaitTime", 10)
	flow.__agent:addSubTreeLocalParam("tSpeed", 1.3)
	flow:setContinue(4)

	return true
end

function _M._to_5_0(flow)
	if not _B(flow, "PBT_Node_Com_StopEffectOnTarget") then
		return
	end

	local _0 = _M._get_2_0(flow)

	return _doBehaviourTail_0(flow, 5, "Eff_Parmon_10141_KongMingLight", _0)
end

function _M._get_2_0(flow)
	return _C(2, "GetSelfId", flow)
end

return _M
