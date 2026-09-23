-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_EcoDemo_VisionTest_GroupAlertStare.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tSensorTgtId", value0)
	agent:addSubTreeLocalParam("tMaxTime", value1)
	agent:addSubTreeLocalParam("tRandomWaitTime", value2)
	flow:setContinue(nodeId)

	return true
end

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "VisionValue_AlertState" then
		return _M._to_8_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 1 then
		return _M._to_6_0(flow)
	end

	if nodeId == 16 then
		return _M._to_11_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_1_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_14_1(flow)

	if _0 then
		flow:setActive()
		_C(1, "DoBehaviour", flow, "PBT_AlertStare")

		local _1 = _M._get_3_1(flow)

		return _doBehaviourTail_0(flow, 1, _1, 2, 0)
	else
		flow:setActiveFail()
	end
end

function _M._to_6_0(flow)
	flow:setActive()

	local _0 = _C(7, "GetLeaderId", flow, 0)
	local _1 = flow:getMessageContext()
	local _2 = _M._get_3_1(flow)

	_1.sensorTgtId = _2
	_1.sourceActorId = flow.__actorId

	flow:sendMessage(_0, "VisionValue_AlertState", _1)
	flow:setActive()

	local _3 = _C(23, "GetSelfId", flow)
	local _4 = flow:getMessageContext()

	_4.sensorTgtId = 0
	_4.sourceActorId = flow.__actorId

	flow:sendMessage(_3, "VisionValue_Leave", _4)

	return true
end

function _M._to_8_0(flow)
	local _1 = _C(10, "GetSelfId", flow)
	local _2 = flow:getContextValue("sourceActorId")
	local _0 = _1 == _2

	if _0 then
		return _M._to_1_0(flow)
	end

	return _M._to_16_0(flow)
end

function _M._to_11_0(flow)
	flow:setActive()

	local _0 = _C(24, "GetSelfId", flow)
	local _1 = flow:getMessageContext()
	local _2 = _M._get_0_2(flow)

	_1.sensorTgtId = _2
	_1.sourceActorId = flow.__actorId

	flow:sendMessage(_0, "VisionValue_Leave", _1)

	return true
end

function _M._to_16_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_18_1(flow)

	if _0 then
		flow:setActive()
		_C(16, "DoBehaviour", flow, "PBT_AlertStare")

		local _1 = _M._get_0_2(flow)

		return _doBehaviourTail_0(flow, 16, _1, 2, 0)
	else
		flow:setActiveFail()
	end
end

function _M._get_0_2(flow)
	return flow:getContextValue("sensorTgtId")
end

function _M._get_3_1(flow)
	local _0 = _C(2, "GetPerceptibilityTable", flow)

	if _0 == nil then
		return
	end

	local key = next(_0)
	local value = _0[key]

	for k, v in pairs(_0) do
		if value < v then
			key, value = k, v
		end
	end

	return key
end

function _M._get_14_1(flow)
	local _0 = _C(15, "HasAITag", flow, 0, "Alert")

	return not _0
end

function _M._get_18_1(flow)
	local _0 = _C(19, "HasAITag", flow, 0, "Alert")

	return not _0
end

return _M
