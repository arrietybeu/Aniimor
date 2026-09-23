-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_EcoDemo_VisionTest_LeaderStare.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

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
		return _M._to_10_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 3 then
		return _M._to_4_0(flow)
	end

	if nodeId == 18 then
		return _M._to_19_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_3_0(flow)
	if not _B(flow, "PBT_AlertStare") then
		return
	end

	local _0 = _M._get_5_1(flow)

	return _doBehaviourTail_0(flow, 3, _0, 1000, 0)
end

function _M._to_4_0(flow)
	flow:setActive()

	local _0 = _C(2, "GetSelfId", flow)
	local _1 = flow:getMessageContext()

	_1.sensorTgtId = 0
	_1.sourceActorId = flow.__actorId

	flow:sendMessage(_0, "VisionValue_Leave", _1)

	return true
end

function _M._to_10_0(flow)
	local _4 = _C(11, "HasAITag", flow, 0, "Alert")
	local _0 = not _4

	if _0 then
		flow:setActive()

		local _1 = _M._get_7_2(flow)

		for _, v in ipairs(_1) do
			local _2 = flow:getMessageContext()
			local _3 = _M._get_5_1(flow)

			_2.sensorTgtId = _3
			_2.sourceActorId = flow.__actorId

			flow:sendMessage(v, "VisionValue_AlertState", _2)
		end

		return _M._to_14_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._to_14_0(flow)
	local _1 = _C(16, "GetSelfId", flow)
	local _2 = _M._get_0_1(flow)
	local _0 = _1 == _2

	if _0 then
		return _M._to_3_0(flow)
	end

	return _M._to_18_0(flow)
end

function _M._to_18_0(flow)
	if not _B(flow, "PBT_AlertStare") then
		return
	end

	local _0 = _M._get_0_2(flow)

	return _doBehaviourTail_0(flow, 18, _0, 1000, 0)
end

function _M._to_19_0(flow)
	flow:setActive()

	local _0 = _C(17, "GetSelfId", flow)
	local _1 = flow:getMessageContext()
	local _2 = _M._get_0_2(flow)

	_1.sensorTgtId = _2
	_1.sourceActorId = flow.__actorId

	flow:sendMessage(_0, "VisionValue_Leave", _1)

	return true
end

function _M._get_0_2(flow)
	return flow:getContextValue("sensorTgtId")
end

function _M._get_0_1(flow)
	return flow:getContextValue("sourceActorId")
end

function _M._get_5_1(flow)
	local _0 = _C(1, "GetPerceptibilityTable", flow)

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

function _M._get_7_2(flow)
	local _0 = _C(6, "GetPartnerIds", flow, 0)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		flow:setCache(7, "__iterItem", v)

		if _M._get_9_1(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_9_1(flow)
	local _1 = flow:getCache(7, "__iterItem")
	local _2 = _M._get_0_1(flow)
	local _0 = _1 == _2

	return not _0
end

return _M
