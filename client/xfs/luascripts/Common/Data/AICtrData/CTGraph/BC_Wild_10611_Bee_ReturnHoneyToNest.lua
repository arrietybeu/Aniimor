-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10611_Bee_ReturnHoneyToNest.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_23_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 23 then
		return _M._to_31_0(flow)
	end

	if nodeId == 24 then
		return true
	end

	if nodeId == 26 then
		return _M._to_27_0(flow)
	end

	if nodeId == 27 then
		return _M._to_24_0(flow)
	end

	if nodeId == 31 then
		return _M._to_30_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_23_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_69_3(flow)

	if _0 then
		flow:setActive()
		_C(23, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_13_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 1)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 20)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 4)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(23)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_24_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_20_1(flow)

	if _0 then
		flow:setActive()
		_C(24, "DoBehaviour", flow, "PBT_MoveAroundTarget")

		local _1 = _M._get_22_1(flow)
		local _2 = _C(28, "RandomInteger", flow, 5, 10)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tRadius", _2)
		flow.__agent:addSubTreeLocalParam("tSpeed", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
		flow.__agent:addSubTreeLocalParam("tClockwise", false)
		flow.__agent:addSubTreeLocalParam("tTimeout", 5)
		flow:setContinue(24)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_26_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	local _0 = _C(25, "RandomInteger", flow, 0, 3)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", _0)
	flow:setContinue(26)

	return true
end

function _M._to_27_0(flow)
	if not _B(flow, "PBT_SwitchToFly") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tFlyHeight", 0)
	flow.__agent:addSubTreeLocalParam("tMaxTime", -1)
	flow:setContinue(27)

	return true
end

function _M._to_30_0(flow)
	flow:setActive()
	_A(flow, "RemoveEntityTag", 0, "TE_Wild_BeeHasHoney")

	return _M._to_26_0(flow)
end

function _M._to_31_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", "GROUND")
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(31)

	return true
end

function _M._get_7_3(flow)
	local _0 = _C(5, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(7, "__iterItem", v)

		if _M._get_12_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_7_2(flow)
	return flow:getCache(7, "__iterItem")
end

function _M._get_10_2(flow)
	local _0 = _M._get_7_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(10, "__iterItem", v)

		_1 = _M._get_11_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_11_3(flow)
	local _0 = flow:getCache(10, "__iterItem")

	return _C(11, "GetDistance", flow, _0, 0, false)
end

function _M._get_12_2(flow)
	local _0 = _M._get_7_2(flow)

	return _C(12, "HasEntityTag", flow, _0, "TE_Env_BeeNestPlatform")
end

function _M._get_13_1(flow)
	local _0 = flow:getCache(13, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_10_2(flow)

	flow:setCache(13, "1", _0)

	return _0
end

function _M._get_14_2(flow)
	local _0 = _M._get_18_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(14, "__iterItem", v)

		_1 = _M._get_15_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_15_3(flow)
	local _0 = flow:getCache(14, "__iterItem")

	return _C(15, "GetDistance", flow, _0, 0, false)
end

function _M._get_18_3(flow)
	local _0 = _C(16, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(18, "__iterItem", v)

		if _M._get_21_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_18_2(flow)
	return flow:getCache(18, "__iterItem")
end

function _M._get_20_1(flow)
	local _1 = _M._get_18_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_21_2(flow)
	local _0 = _M._get_18_2(flow)

	return _C(21, "HasEntityTag", flow, _0, "TE_Env_BeeNest")
end

function _M._get_22_1(flow)
	local _0 = flow:getCache(22, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_14_2(flow)

	flow:setCache(22, "1", _0)

	return _0
end

function _M._get_69_3(flow)
	local _0 = _C(34, "HasEntityTag", flow, 0, "TE_Wild_BeeHasHoney")

	if not _0 then
		return false
	end

	local _5 = _C(32, "HasEntityTag", flow, 0, "TE_Wild_BeeInNest")
	local _1 = not _5

	if not _1 then
		return false
	end

	local _3 = _M._get_7_3(flow)
	local _4 = not _3 or next(_3) == nil
	local _2 = not _4

	if not _2 then
		return false
	end

	return true
end

return _M
