-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_910012_CastAbility.lua

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
	if eventName == "Event_Ability_910120001" then
		return _M._to_36_0(flow)
	end

	if eventName == "Event_Ability_910120002" then
		return _M._to_40_0(flow)
	end

	if eventName == "Event_Ability_910120003" then
		return _M._to_44_0(flow)
	end

	if eventName == "Event_Ability_910120000" then
		return _M._to_48_0(flow)
	end

	if eventName == "Event_Ability_910120422" then
		return _M._to_52_0(flow)
	end

	if eventName == "Event_Ability_910120330" then
		return _M._to_56_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 36 then
		return true
	end

	if nodeId == 40 then
		return true
	end

	if nodeId == 44 then
		return true
	end

	if nodeId == 48 then
		return true
	end

	if nodeId == 52 then
		return true
	end

	if nodeId == 56 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_36_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_33_1(flow)

	return _doBehaviourTail_0(flow, 36, 0, 910120001, _0, "", 5, false, 0)
end

function _M._to_40_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_37_1(flow)

	return _doBehaviourTail_0(flow, 40, 0, 910120002, _0, "", 5, false, 0)
end

function _M._to_44_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_41_1(flow)

	return _doBehaviourTail_0(flow, 44, 0, 910120003, _0, "", 5, false, 0)
end

function _M._to_48_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_45_1(flow)

	return _doBehaviourTail_0(flow, 48, 0, 910120000, _0, "", 5, false, 0)
end

function _M._to_52_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_49_1(flow)

	return _doBehaviourTail_0(flow, 52, 0, 910120422, _0, "", 5, false, 0)
end

function _M._to_56_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_53_1(flow)

	return _doBehaviourTail_0(flow, 56, 0, 910120330, _0, "", 5, false, 0)
end

function _M._get_33_1(flow)
	local _0 = _C(34, "GetPetMaster", flow, 0)

	return _C(33, "GetEntityCacheValue", flow, "MasterTgt", _0)
end

function _M._get_37_1(flow)
	local _0 = _C(38, "GetPetMaster", flow, 0)

	return _C(37, "GetEntityCacheValue", flow, "MasterTgt", _0)
end

function _M._get_41_1(flow)
	local _0 = _C(42, "GetPetMaster", flow, 0)

	return _C(41, "GetEntityCacheValue", flow, "MasterTgt", _0)
end

function _M._get_45_1(flow)
	local _0 = _C(46, "GetPetMaster", flow, 0)

	return _C(45, "GetEntityCacheValue", flow, "MasterTgt", _0)
end

function _M._get_49_1(flow)
	local _0 = _C(50, "GetPetMaster", flow, 0)

	return _C(49, "GetEntityCacheValue", flow, "MasterTgt", _0)
end

function _M._get_53_1(flow)
	local _0 = _C(54, "GetPetMaster", flow, 0)

	return _C(53, "GetEntityCacheValue", flow, "MasterTgt", _0)
end

return _M
