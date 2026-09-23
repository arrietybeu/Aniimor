-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Npc_TaskCommon.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "NpcStatusChangeTrigger" then
		return _M._to_45_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 48 then
		return true
	end

	if nodeId == 54 then
		return true
	end

	if nodeId == 55 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_45_0(flow)
	local _2 = _M._get_47_1(flow)
	local _0 = not _2

	if _0 then
		return _M._to_49_0(flow)
	end

	local _1 = _M._get_47_1(flow)

	if _1 then
		return _M._to_48_0(flow)
	end
end

function _M._to_48_0(flow)
	if not _B(flow, "PBT_Noop") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(48)

	return true
end

function _M._to_49_0(flow)
	local _2 = _M._get_43_2(flow)
	local _0 = _2 == "ActivateAIRoute"

	if _0 then
		return _M._to_54_0(flow)
	end

	local _3 = _M._get_43_2(flow)
	local _1 = _3 == "ActivateFollowEntity"

	if _1 then
		return _M._to_55_0(flow)
	end
end

function _M._to_54_0(flow)
	flow:setActive()

	local _0 = flow:getSubFlow("BC_Npc_CommonSub_ActivateAIRoute")
	local _1 = _M._get_58_1(flow)
	local _2 = _M._get_60_1(flow)

	_0:setContextValue("stateTable", _1)
	_0:setContextValue("stateKey", _2)

	if _0:executeSubFlow() then
		flow:setContinue(54)

		if _0:isFinish() then
			return flow:executeContinue()
		end

		return true
	end
end

function _M._to_55_0(flow)
	flow:setActive()

	local _0 = flow:getSubFlow("BC_Npc_CommonSub_ActivateFollowEntity")
	local _1 = _M._get_58_1(flow)

	_0:setContextValue("stateTable", _1)

	if _0:executeSubFlow() then
		flow:setContinue(55)

		if _0:isFinish() then
			return flow:executeContinue()
		end

		return true
	end
end

function _M._get_34_2(flow)
	local _1 = _M._get_56_1(flow)
	local _2 = _M._get_39_2(flow)
	local _0 = _C(62, "GetTableValueByKey", flow, _1, _2)

	return _0 == 1
end

function _M._get_39_3(flow)
	local _0 = _M._get_56_1(flow)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(39, "__iterItem", k)

		if _M._get_34_2(flow) then
			_1[#_1 + 1] = k
		end
	end

	return _1
end

function _M._get_39_2(flow)
	return flow:getCache(39, "__iterItem")
end

function _M._get_43_2(flow)
	local _0 = _M._get_58_1(flow)

	return _C(43, "GetTableValueByKey", flow, _0, "behavName")
end

function _M._get_47_1(flow)
	local _0 = _M._get_39_3(flow)

	return not _0 or next(_0) == nil
end

function _M._get_56_1(flow)
	local _0 = _C(57, "GetStaticId", flow, 0)

	return _C(56, "GetNpcStatusServerData", flow, _0)
end

function _M._get_58_1(flow)
	local _0 = _M._get_60_1(flow)

	return _C(58, "GetNpcStatusConfigData", flow, _0)
end

function _M._get_60_1(flow)
	local _0 = _M._get_39_3(flow)

	if _0 == nil then
		return
	end

	local key = next(_0)
	local value = _0[key]

	for k, v in pairs(_0) do
		if key < k then
			key, value = k, v
		end
	end

	return value
end

return _M
