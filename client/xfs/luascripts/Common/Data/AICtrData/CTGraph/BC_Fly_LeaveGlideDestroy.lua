-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Fly_LeaveGlideDestroy.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tTargetActorId", value0)
	agent:addSubTreeLocalParam("tLeaveDistance", value1)
	agent:addSubTreeLocalParam("tSpeed", value2)
	agent:addSubTreeLocalParam("tSpeedRateType", value3)
	agent:addSubTreeLocalParam("tMaxTime", value4)
	flow:setContinue(nodeId)

	return true
end

function _M.executeTickLodTrigger(flow)
	return _M._to_122_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 101 then
		return _M._to_111_0(flow)
	end

	if nodeId == 111 then
		return true
	end

	if nodeId == 115 then
		return _M._to_116_0(flow)
	end

	if nodeId == 116 then
		return _M._to_121_0(flow)
	end

	if nodeId == 117 then
		return _M._to_118_0(flow)
	end

	if nodeId == 118 then
		return true
	end

	if nodeId == 121 then
		return true
	end

	if nodeId == 122 then
		return _M._to_115_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_111_0(flow)
	if not _B(flow, "PBT_DestroySelf") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(111)

	return true
end

function _M._to_115_0(flow)
	if not _B(flow, "PBT_SwitchToFly") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tFlyHeight", 3)
	flow.__agent:addSubTreeLocalParam("tMaxTime", 1)
	flow:setContinue(115)

	return true
end

function _M._to_116_0(flow)
	if not _B(flow, "PBT_LeaveTarget") then
		return
	end

	local _0 = _M._get_123_1(flow)

	return _doBehaviourTail_0(flow, 116, _0, 35, 5, 1, 10)
end

function _M._to_118_0(flow)
	if not _B(flow, "PBT_LeaveTarget") then
		return
	end

	return _doBehaviourTail_0(flow, 118, 0, 40, 12, 1, 10)
end

function _M._to_121_0(flow)
	if not _B(flow, "PBT_DestroySelf") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(121)

	return true
end

function _M._to_122_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_106_1(flow)

	if _0 then
		flow:setActive()
		_C(122, "DoBehaviour", flow, "PBT_TurnToTargetAtYaw")

		local _1 = _M._get_123_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTgtId", _1)
		flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 180)
		flow.__agent:addSubTreeLocalParam("tInstant", false)
		flow:setContinue(122)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_104_2(flow)
	local _2 = _M._get_110_3(flow)
	local _3 = _C(103, "GetPerceptibilityValue", flow, _2)
	local _0 = _3 >= 120

	if not _0 then
		return false
	end

	local _4 = _M._get_110_3(flow)
	local _1 = _C(108, "IsEntityType", flow, _4, "ACTOR_TYPE_PLAYER")

	if not _1 then
		return false
	end

	return true
end

function _M._get_106_1(flow)
	local _1 = _M._get_110_2(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_110_3(flow)
	return flow:getCache(110, "__iterItem")
end

function _M._get_110_2(flow)
	local _0 = _C(109, "GetPerceptibilityTable", flow)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(110, "__iterItem", k)

		if _M._get_104_2(flow) then
			_1[#_1 + 1] = k
		end
	end

	return _1
end

function _M._get_114_1(flow)
	local _0 = _M._get_110_2(flow)

	return _C(114, "SelectOneByRandom", flow, _0)
end

function _M._get_123_1(flow)
	local _0 = flow:getCache(123, "targetActorId")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_114_1(flow)

	flow:setCache(123, "targetActorId", _0)

	return _0
end

return _M
