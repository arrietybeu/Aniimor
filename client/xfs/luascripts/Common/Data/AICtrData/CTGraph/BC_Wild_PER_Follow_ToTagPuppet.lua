-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_PER_Follow_ToTagPuppet.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

local function _doBehaviourTail_0(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tTargetActorId", value0)
	agent:addSubTreeLocalParam("tRandomValue", value1)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "Event_PER_Follow" then
		return _M._to_94_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 66 then
		return true
	end

	if nodeId == 77 then
		return true
	end

	if nodeId == 83 then
		return true
	end

	if nodeId == 84 then
		return true
	end

	if nodeId == 94 then
		return _M._to_82_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 66 then
		return _M._get_68_4(flow)
	end

	if nodeId == 77 then
		return _M._get_68_4(flow)
	end

	if nodeId == 83 then
		return _M._get_68_4(flow)
	end

	if nodeId == 84 then
		return _M._get_68_4(flow)
	end
end

function _M._to_66_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 66)

	if not _1 then
		flow:setActive()
		_C(66, "DoBehaviour", flow, "PBT_Behav_Com_FollowWithFormation")

		local _1 = _M._get_67_2(flow)

		return _doBehaviourTail_0(flow, 66, _1, 0)
	else
		flow:setActiveFail()
	end
end

function _M._to_72_0(flow)
	local _0 = _M._get_76_2(flow)

	if _0 then
		return _M._to_77_0(flow)
	end

	local _2 = _M._get_71_2(flow)
	local _1 = _2 == 2

	if _1 then
		return _M._to_66_0(flow)
	end
end

function _M._to_77_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 77)

	if not _1 then
		flow:setActive()
		_C(77, "DoBehaviour", flow, "PBT_Behav_Com_FollowByRelativePos")

		local _1 = _M._get_67_2(flow)

		return _doBehaviourTail_0(flow, 77, _1, 0)
	else
		flow:setActiveFail()
	end
end

function _M._to_82_0(flow)
	local _0 = _M._get_81_2(flow)

	if _0 then
		return _M._to_72_0(flow)
	end

	return _M._to_85_0(flow)
end

function _M._to_83_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 83)

	if not _1 then
		flow:setActive()
		_C(83, "DoBehaviour", flow, "PBT_Behav_Com_FollowWithFormation")

		local _1 = _M._get_67_2(flow)

		return _doBehaviourTail_0(flow, 83, _1, 0)
	else
		flow:setActiveFail()
	end
end

function _M._to_84_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 84)

	if not _1 then
		flow:setActive()
		_C(84, "DoBehaviour", flow, "PBT_Behav_Com_FollowByRelativePos")

		local _1 = _M._get_67_2(flow)

		return _doBehaviourTail_0(flow, 84, _1, 0)
	else
		flow:setActiveFail()
	end
end

function _M._to_85_0(flow)
	local _0 = _M._get_89_2(flow)

	if _0 then
		return _M._to_84_0(flow)
	end

	local _2 = _M._get_90_2(flow)
	local _1 = _2 == 2

	if _1 then
		return _M._to_83_0(flow)
	end
end

function _M._to_94_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_91_2(flow)

	if _0 then
		flow:setActive()
		_C(94, "DoBehaviour", flow, "PBT_Node_Com_SensedAlert")

		local _1 = _M._get_67_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow:setContinue(94)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_67_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_68_2(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_67_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPuppet")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_68_4(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_67_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tPetNotCurrPet")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_71_2(flow)
	local _0 = _M._get_67_2(flow)

	return _C(71, "GetPuppetData", flow, _0, "beFollowMode", true, 0)
end

function _M._get_76_2(flow)
	local _2 = _M._get_71_2(flow)
	local _0 = _2 == 0

	if _0 then
		return true
	end

	local _3 = _M._get_71_2(flow)
	local _1 = _3 == 1

	if _1 then
		return true
	end

	return false
end

function _M._get_78_1(flow)
	local _0 = _M._get_67_2(flow)

	return _C(78, "GetPetMaster", flow, _0)
end

function _M._get_81_2(flow)
	local _2 = _M._get_78_1(flow)
	local _0 = _2 == nil

	if _0 then
		return true
	end

	local _3 = _M._get_78_1(flow)
	local _1 = _3 == 0

	if _1 then
		return true
	end

	return false
end

function _M._get_89_2(flow)
	local _2 = _M._get_90_2(flow)
	local _0 = _2 == 0

	if _0 then
		return true
	end

	local _3 = _M._get_90_2(flow)
	local _1 = _3 == 1

	if _1 then
		return true
	end

	return false
end

function _M._get_90_2(flow)
	local _0 = _M._get_67_2(flow)

	return _C(90, "GetPetData", flow, _0, "beFollowMode", true, 0)
end

function _M._get_91_2(flow)
	local _0 = _M._get_68_2(flow)

	if not _0 then
		return false
	end

	local _2 = _M._get_67_2(flow)
	local _1 = _C(93, "HasEntityTag", flow, _2, "TE_Wild_CanBeFollowed")

	if not _1 then
		return false
	end

	return true
end

return _M
