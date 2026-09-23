-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_PER_Follow_ToPuppet.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

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
		return _M._to_61_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 54 then
		return true
	end

	if nodeId == 60 then
		return _M._to_77_0(flow)
	end

	if nodeId == 68 then
		return true
	end

	if nodeId == 78 then
		return true
	end

	if nodeId == 79 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_54_0(flow)
	if not _B(flow, "PBT_Behav_Com_FollowWithFormation") then
		return
	end

	local _0 = _M._get_44_2(flow)

	return _doBehaviourTail_0(flow, 54, _0, 0)
end

function _M._to_60_0(flow)
	if not _B(flow, "PBT_TurnToTargetAtYaw") then
		return
	end

	local _0 = _M._get_44_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
	flow.__agent:addSubTreeLocalParam("tInstant", false)
	flow:setContinue(60)

	return true
end

function _M._to_61_0(flow)
	local _0 = _M._get_57_2(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_44_2(flow)

		_A(flow, "PlayEmojiOnTarget", _1, "Love", 2)

		return _M._to_60_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._to_63_0(flow)
	local _0 = _M._get_67_2(flow)

	if _0 then
		return _M._to_68_0(flow)
	end

	local _2 = _M._get_62_2(flow)
	local _1 = _2 == 2

	if _1 then
		return _M._to_54_0(flow)
	end
end

function _M._to_68_0(flow)
	if not _B(flow, "PBT_Behav_Com_FollowByRelativePos") then
		return
	end

	local _0 = _M._get_44_2(flow)

	return _doBehaviourTail_0(flow, 68, _0, 0)
end

function _M._to_77_0(flow)
	local _0 = _M._get_72_2(flow)

	if _0 then
		return _M._to_63_0(flow)
	end

	return _M._to_80_0(flow)
end

function _M._to_78_0(flow)
	if not _B(flow, "PBT_Behav_Com_FollowWithFormation") then
		return
	end

	local _0 = _M._get_44_2(flow)

	return _doBehaviourTail_0(flow, 78, _0, 0)
end

function _M._to_79_0(flow)
	if not _B(flow, "PBT_Behav_Com_FollowByRelativePos") then
		return
	end

	local _0 = _M._get_44_2(flow)

	return _doBehaviourTail_0(flow, 79, _0, 0)
end

function _M._to_80_0(flow)
	local _0 = _M._get_85_2(flow)

	if _0 then
		return _M._to_79_0(flow)
	end

	local _2 = _M._get_86_2(flow)
	local _1 = _2 == 2

	if _1 then
		return _M._to_78_0(flow)
	end
end

function _M._get_44_2(flow)
	return flow:getContextValue("interactObjectActorId")
end

function _M._get_57_2(flow)
	local _0 = flow:getSubMacro("BCM_Common_CheckPER")
	local _1 = _M._get_44_2(flow)

	_0:setContextValue("tActorId", _1)

	local _2 = _0:getMacroValue("tIsPuppet")

	flow:clearSubMacro(_0)

	return _2
end

function _M._get_62_2(flow)
	local _0 = _M._get_44_2(flow)

	return _C(62, "GetPuppetData", flow, _0, "beFollowMode", true, 0)
end

function _M._get_67_2(flow)
	local _2 = _M._get_62_2(flow)
	local _0 = _2 == 0

	if _0 then
		return true
	end

	local _3 = _M._get_62_2(flow)
	local _1 = _3 == 1

	if _1 then
		return true
	end

	return false
end

function _M._get_69_1(flow)
	local _0 = _M._get_44_2(flow)

	return _C(69, "GetPetMaster", flow, _0)
end

function _M._get_72_2(flow)
	local _2 = _M._get_69_1(flow)
	local _0 = _2 == nil

	if _0 then
		return true
	end

	local _3 = _M._get_69_1(flow)
	local _1 = _3 == 0

	if _1 then
		return true
	end

	return false
end

function _M._get_85_2(flow)
	local _2 = _M._get_86_2(flow)
	local _0 = _2 == 0

	if _0 then
		return true
	end

	local _3 = _M._get_86_2(flow)
	local _1 = _3 == 1

	if _1 then
		return true
	end

	return false
end

function _M._get_86_2(flow)
	local _0 = _M._get_44_2(flow)

	return _C(86, "GetPetData", flow, _0, "beFollowMode", true, 0)
end

return _M
