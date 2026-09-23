-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10191_DayNightMimicryIdle.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

local function _doBehaviourTail_0(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tCharacterState", value0)
	agent:addSubTreeLocalParam("tAnimationKey", value1)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_5_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 1 then
		return true
	end

	if nodeId == 7 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 1 then
		return _M._get_8_1(flow)
	end

	if nodeId == 7 then
		return _M._get_9_1(flow)
	end
end

function _M._to_1_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 1)

	if not _1 then
		flow:setActive()
		_C(1, "DoBehaviour", flow, "PBT_SwitchState")

		return _doBehaviourTail_0(flow, 1, "MIMICRY", "")
	else
		flow:setActiveFail()
	end
end

function _M._to_5_0(flow)
	local _0 = _M._get_4_2(flow)

	if _0 then
		return _M._to_1_0(flow)
	end

	local _1 = _M._get_6_2(flow)

	if _1 then
		return _M._to_7_0(flow)
	end
end

function _M._to_7_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 7)

	if not _1 then
		flow:setActive()
		_C(7, "DoBehaviour", flow, "PBT_SwitchState")

		return _doBehaviourTail_0(flow, 7, "LOCOMOTION", "")
	else
		flow:setActiveFail()
	end
end

function _M._get_3_0(flow)
	return _C(3, "GetDayTime", flow)
end

function _M._get_4_2(flow)
	local _0 = _M._get_3_0(flow)

	return _C(4, "IsSameDayTime", flow, _0, 1)
end

function _M._get_6_2(flow)
	local _0 = _M._get_3_0(flow)

	return _C(6, "IsSameDayTime", flow, _0, 2)
end

function _M._get_8_1(flow)
	local _0 = _M._get_4_2(flow)

	return not _0
end

function _M._get_9_1(flow)
	local _0 = _M._get_6_2(flow)

	return not _0
end

return _M
