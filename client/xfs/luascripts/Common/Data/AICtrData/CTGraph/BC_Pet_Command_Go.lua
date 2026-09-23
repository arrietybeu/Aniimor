-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_Command_Go.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "CommandGoTrigger" then
		return _M._to_16_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 0 then
		return true
	end

	if nodeId == 2 then
		return true
	end

	if nodeId == 3 then
		return _M._to_70_0(flow)
	end

	if nodeId == 4 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_0_0(flow)
	if not _B(flow, "PBT_Pet_CommandGo_NoTarget") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tNearbyEnvObjActorId", 0)
	flow.__agent:addSubTreeLocalParam("tCommandSkillId", 0)
	flow.__agent:addSubTreeLocalParam("tDistToTgtForSkill", 0)
	flow:setContinue(0)

	return true
end

function _M._to_2_0(flow)
	if not _B(flow, "PBT_Pet_CommandGo_Enemy") then
		return
	end

	local _0 = _M._get_1_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetId", _0)
	flow.__agent:addSubTreeLocalParam("tTeleportDis", 0)
	flow.__agent:addSubTreeLocalParam("CurrentDistToTarget", 0)
	flow:setContinue(2)

	return true
end

function _M._to_3_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_66_3(flow)

	if _0 then
		flow:setActive()
		_C(3, "DoBehaviour", flow, "PBT_Pet_CommandGo_EnvObjCan")

		local _1 = _M._get_1_1(flow)
		local _2 = _M._get_1_2(flow)
		local _3 = flow:getContextValue("partId")

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetId", _1)
		flow.__agent:addSubTreeLocalParam("tSkillId", _2)
		flow.__agent:addSubTreeLocalParam("tTargetEnvPartId", _3)
		flow.__agent:addSubTreeLocalParam("tSpeedMulti", 2)
		flow.__agent:addSubTreeLocalParam("tSkillStopDist", 0)
		flow:setContinue(3)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_4_0(flow)
	if not _B(flow, "PBT_Pet_CommandGo_EnvObjCannot") then
		return
	end

	local _0 = _M._get_1_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetId", _0)
	flow.__agent:addSubTreeLocalParam("tTargetEnvPartId", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedMulti", 0)
	flow:setContinue(4)

	return true
end

function _M._to_16_0(flow)
	local _0 = _M._get_20_2(flow)

	if _0 then
		return _M._to_0_0(flow)
	end

	local _1 = _M._get_21_2(flow)

	if _1 then
		return _M._to_2_0(flow)
	end

	local _2 = _M._get_24_2(flow)

	if _2 then
		return _M._to_31_0(flow)
	end

	local _3 = _M._get_27_2(flow)

	if _3 then
		return _M._to_4_0(flow)
	end
end

function _M._to_31_0(flow)
	flow:addTimer(1, _M, "_to_32_0", flow)

	return _M._to_3_0(flow)
end

function _M._to_32_0(flow)
	local _2 = _M._get_1_1(flow)
	local _0 = _C(30, "CheckHasChemState", flow, _2, "STATE_Flammable_KEY")

	if _0 then
		flow:setActive()

		local _1 = _C(33, "GetSelfId", flow)

		_A(flow, "SendMessageToTrigger", _1, 1004)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_70_0(flow)
	local _0 = _M._get_68_2(flow)

	if _0 then
		flow:setActive()
		_A(flow, "SendMessageToTrigger", 0, 1028201)

		return true
	end

	local _1 = _M._get_69_2(flow)

	if _1 then
		flow:setActive()
		_A(flow, "SendMessageToTrigger", 0, 1045401)

		return true
	end
end

function _M._get_1_1(flow)
	return flow:getContextValue("targetActorId")
end

function _M._get_1_2(flow)
	return flow:getContextValue("skillId")
end

function _M._get_5_2(flow)
	local _0 = _M._get_1_1(flow)

	return _C(5, "IsEntityType", flow, _0, "ACTOR_TYPE_ENVOBJ")
end

function _M._get_8_2(flow)
	local _0 = _M._get_1_1(flow)

	return _0 == 0
end

function _M._get_9_2(flow)
	local _0 = _M._get_1_2(flow)

	return _0 == 0
end

function _M._get_10_3(flow)
	local _0 = _M._get_13_1(flow)

	if not _0 then
		return false
	end

	local _1 = _M._get_5_2(flow)

	if not _1 then
		return false
	end

	local _3 = _M._get_9_2(flow)
	local _2 = not _3

	if not _2 then
		return false
	end

	return true
end

function _M._get_12_3(flow)
	local _0 = _M._get_13_1(flow)

	if not _0 then
		return false
	end

	local _1 = _M._get_5_2(flow)

	if not _1 then
		return false
	end

	local _2 = _M._get_9_2(flow)

	if not _2 then
		return false
	end

	return true
end

function _M._get_13_1(flow)
	local _0 = _M._get_8_2(flow)

	return not _0
end

function _M._get_14_2(flow)
	local _0 = _M._get_13_1(flow)

	if not _0 then
		return false
	end

	local _2 = _M._get_5_2(flow)
	local _1 = not _2

	if not _1 then
		return false
	end

	return true
end

function _M._get_20_2(flow)
	local _0 = _M._get_8_2(flow)

	if not _0 then
		return false
	end

	local _2 = _C(18, "CheckInDialog", flow, 70002000)
	local _1 = not _2

	if not _1 then
		return false
	end

	return true
end

function _M._get_21_2(flow)
	local _0 = _M._get_14_2(flow)

	if not _0 then
		return false
	end

	local _2 = _C(22, "CheckInDialog", flow, 70002000)
	local _1 = not _2

	if not _1 then
		return false
	end

	return true
end

function _M._get_24_2(flow)
	local _0 = _M._get_10_3(flow)

	if not _0 then
		return false
	end

	local _2 = _C(25, "CheckInDialog", flow, 70002000)
	local _1 = not _2

	if not _1 then
		return false
	end

	return true
end

function _M._get_27_2(flow)
	local _0 = _M._get_12_3(flow)

	if not _0 then
		return false
	end

	local _2 = _C(28, "CheckInDialog", flow, 70002000)
	local _1 = not _2

	if not _1 then
		return false
	end

	return true
end

function _M._get_46_1(flow)
	local _0 = flow:getCache(46, "hasEntityTag1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_57_2(flow)

	flow:setCache(46, "hasEntityTag1", _0)

	return _0
end

function _M._get_52_2(flow)
	local _0 = _M._get_1_1(flow)

	return _C(52, "HasEntityTag", flow, _0, "TE_Env_Stone")
end

function _M._get_55_1(flow)
	local _1 = _M._get_1_1(flow)
	local _0 = _C(41, "CheckEntityExist", flow, _1)

	return not _0
end

function _M._get_57_2(flow)
	local _0 = _M._get_1_1(flow)

	return _C(57, "HasEntityTag", flow, _0, "TE_Env_Metal")
end

function _M._get_60_1(flow)
	local _0 = flow:getCache(60, "hasEntityTag2")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_52_2(flow)

	flow:setCache(60, "hasEntityTag2", _0)

	return _0
end

function _M._get_66_3(flow)
	local _0 = _M._get_46_1(flow)

	if _0 then
		return true
	end

	local _1 = _M._get_60_1(flow)

	if _1 then
		return true
	end

	do return true end
	return false
end

function _M._get_68_2(flow)
	local _0 = _M._get_46_1(flow)

	if not _0 then
		return false
	end

	local _1 = _M._get_55_1(flow)

	if not _1 then
		return false
	end

	return true
end

function _M._get_69_2(flow)
	local _0 = _M._get_60_1(flow)

	if not _0 then
		return false
	end

	local _1 = _M._get_55_1(flow)

	if not _1 then
		return false
	end

	return true
end

return _M
