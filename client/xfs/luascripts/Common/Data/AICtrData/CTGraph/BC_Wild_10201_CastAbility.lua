-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_CastAbility.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tSkillId", value1)
	agent:addSubTreeLocalParam("tSkillTargetActorId", value2)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value3)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value4)
	agent:addSubTreeLocalParam("tRaycastOpen", value5)
	agent:addSubTreeLocalParam("tCastAbilitySource", value6)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Event_Ability_12010111" then
		return _M._to_13_0(flow)
	end

	if eventName == "Event_Ability_12010221" then
		return _M._to_25_0(flow)
	end

	if eventName == "Event_Ability_12010131" then
		return _M._to_29_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 13 then
		return true
	end

	if nodeId == 25 then
		return true
	end

	if nodeId == 29 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_13_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_23_1(flow)

	return _doBehaviourTail_0(flow, 13, 0, 12010111, _0, "", 5, false, 0)
end

function _M._to_25_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_27_1(flow)

	return _doBehaviourTail_0(flow, 25, 0, 12010221, _0, "", 5, false, 0)
end

function _M._to_29_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_31_1(flow)

	return _doBehaviourTail_0(flow, 29, 0, 12010131, _0, "", 5, false, 0)
end

function _M._get_23_1(flow)
	local _0 = _C(24, "GetPetMaster", flow, 0)

	return _C(23, "GetEntityCacheValue", flow, "MasterTgt", _0)
end

function _M._get_27_1(flow)
	local _0 = _C(28, "GetPetMaster", flow, 0)

	return _C(27, "GetEntityCacheValue", flow, "MasterTgt", _0)
end

function _M._get_31_1(flow)
	local _0 = _C(32, "GetPetMaster", flow, 0)

	return _C(31, "GetEntityCacheValue", flow, "MasterTgt", _0)
end

return _M
