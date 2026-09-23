-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10181_FlyToTargetAndDestroy.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerLeaveAndFlyAway" then
		return _M._to_0_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 0 then
		return _M._to_32_0(flow)
	end

	if nodeId == 4 then
		return _M._to_5_0(flow)
	end

	if nodeId == 5 then
		return true
	end

	if nodeId == 32 then
		return _M._to_4_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_0_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", "FLYING")
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(0)

	return true
end

function _M._to_4_0(flow)
	if not _B(flow, "PBT_LeaveTarget") then
		return
	end

	local _0 = _M._get_34_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tLeaveDistance", 40)
	flow.__agent:addSubTreeLocalParam("tSpeed", 7)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tMaxTime", 8)
	flow:setContinue(4)

	return true
end

function _M._to_5_0(flow)
	if not _B(flow, "PBT_DestroySelf") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow:setContinue(5)

	return true
end

function _M._to_32_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_23_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tStopDist", 1)
	flow.__agent:addSubTreeLocalParam("tMaxTimeout", 20)
	flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
	flow.__agent:addSubTreeLocalParam("tSpeed", 7)
	flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 2)
	flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
	flow:setContinue(32)

	return true
end

function _M._get_23_2(flow)
	local _0 = _M._get_27_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(23, "__iterItem", v)

		_1 = _M._get_24_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_24_3(flow)
	local _0 = flow:getCache(23, "__iterItem")

	return _C(24, "GetDistance", flow, _0, 0, false)
end

function _M._get_27_3(flow)
	local _0 = _C(18, "GetAoiEntityTableByLevel", flow, 0, 50, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(27, "__iterItem", v)

		if _M._get_28_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_27_2(flow)
	return flow:getCache(27, "__iterItem")
end

function _M._get_28_2(flow)
	local _0 = _M._get_27_2(flow)

	return _C(28, "HasEntityTag", flow, _0, "TE_Env_WayfindingPoint_D")
end

function _M._get_34_1(flow)
	local _0 = _C(33, "GetAoiEntityTableByLevel", flow, 0, 30, 2)

	return _C(34, "SelectOneByRandom", flow, _0)
end

return _M
