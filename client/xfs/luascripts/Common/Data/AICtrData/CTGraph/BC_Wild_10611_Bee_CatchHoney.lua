-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10611_Bee_CatchHoney.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_19_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_14_1(flow)

	_A(flow, "RemoveEntityTag", _0, "TE_Env_BeUsed")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 18 then
		return _M._to_17_0(flow)
	end

	if nodeId == 27 then
		return _M._to_21_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_17_0(flow)
	flow:setActive()
	_A(flow, "SetVisionAreaOverride", "visionAreaLow")

	return _M._to_27_0(flow)
end

function _M._to_18_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_15_1(flow)

	if _0 then
		flow:setActive()
		_C(18, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_14_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 1)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 6)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 5)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(18)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_19_0(flow)
	local _0 = _M._get_13_2(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_14_1(flow)

		_A(flow, "AddEntityTag", _1, "TE_Env_BeUsed")

		return _M._to_18_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._to_21_0(flow)
	flow:setActive()
	_A(flow, "AddEntityTag", 0, "TE_Wild_BeeHasHoney")
	flow:setActive()
	_A(flow, "SetVisionAreaOverride", "visionAreaDefault")

	return true
end

function _M._to_27_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "IdleSpecial02")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(27)

	return true
end

function _M._get_0_2(flow)
	return flow:getCache(0, "__iterItem")
end

function _M._get_0_3(flow)
	local _0 = _C(6, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(0, "__iterItem", v)

		if _M._get_2_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_2_2(flow)
	local _4 = _M._get_0_2(flow)
	local _0 = _C(7, "HasEntityTag", flow, _4, "TE_Env_NightFlower")

	if not _0 then
		return false
	end

	local _2 = _M._get_0_2(flow)
	local _3 = _C(1, "HasEntityTag", flow, _2, "TE_Env_BeUsed")
	local _1 = not _3

	if not _1 then
		return false
	end

	return true
end

function _M._get_5_3(flow)
	local _0 = flow:getCache(10, "__iterItem")

	return _C(5, "GetDistance", flow, _0, 0, false)
end

function _M._get_10_2(flow)
	local _0 = _M._get_0_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(10, "__iterItem", v)

		_1 = _M._get_5_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_13_2(flow)
	local _4 = _C(11, "HasEntityTag", flow, 0, "TE_Wild_BeeHasHoney")
	local _0 = not _4

	if not _0 then
		return false
	end

	local _2 = _M._get_0_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _1 = not _3

	if not _1 then
		return false
	end

	return true
end

function _M._get_14_1(flow)
	local _0 = flow:getCache(14, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_10_2(flow)

	flow:setCache(14, "1", _0)

	return _0
end

function _M._get_15_1(flow)
	local _0 = _M._get_14_1(flow)

	return _C(15, "CheckEntityExist", flow, _0)
end

return _M
