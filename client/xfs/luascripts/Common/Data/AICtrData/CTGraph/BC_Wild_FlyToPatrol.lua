-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_FlyToPatrol.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_16_0(flow)
	end
end

function _M.executeEndTrigger(flow)
	flow:setActive()
	_A(flow, "SetVisionAreaOverride", "visionAreaDefault")
	flow:setActive()

	local _0 = _C(15, "GetSelfId", flow)

	_A(flow, "HideEmojiOnTarget", _0, "")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 11 then
		return _M._to_18_0(flow)
	end

	if nodeId == 16 then
		return _M._to_11_0(flow)
	end

	if nodeId == 18 then
		return _M._to_19_0(flow)
	end

	if nodeId == 19 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_11_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	local _0 = _M._get_9_8(flow)

	if _P(flow, 1, _0, 1, nil) then
		flow:setContinue(11)

		return true
	end
end

function _M._to_16_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_8_1(flow)

	if _0 then
		flow:setActive()
		_C(16, "DoBehaviour", flow, "PBT_SwitchToFly")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tFlyHeight", 3)
		flow.__agent:addSubTreeLocalParam("tMaxTime", 5)
		flow:setContinue(16)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_18_0(flow)
	if not _B(flow, "PBT_Com_MoveToBornPos") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(18)

	return true
end

function _M._to_19_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", "GROUND")
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(19)

	return true
end

function _M._get_8_1(flow)
	local _1 = _M._get_9_8(flow)
	local _0 = _1 == 0

	return not _0
end

function _M._get_9_8(flow)
	return _C(9, "GetRouteIdFromEntity", flow, 0, 0, 0, 0, "", "", "", "")
end

return _M
