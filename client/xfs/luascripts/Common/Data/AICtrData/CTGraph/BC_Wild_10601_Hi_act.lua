-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10601_Hi_act.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_21_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 20 then
		return true
	end

	if nodeId == 21 then
		return _M._to_20_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_20_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Idle")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Laugh")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(20)

	return true
end

function _M._to_21_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_7_1(flow)

	if _0 then
		flow:setActive()
		_C(21, "DoBehaviour", flow, "PBT_TurnToTargetAtYaw")

		local _1 = _M._get_4_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTgtId", _1)
		flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
		flow.__agent:addSubTreeLocalParam("tInstant", false)
		flow:setContinue(21)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_2_2(flow)
	return flow:getCache(2, "__iterItem")
end

function _M._get_2_3(flow)
	local _0 = _C(5, "GetAoiEntityTableByLevel", flow, 0, 10, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(2, "__iterItem", v)

		if _M._get_19_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_4_1(flow)
	local _0 = flow:getCache(4, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_12_1(flow)

	flow:setCache(4, "1", _0)

	return _0
end

function _M._get_7_1(flow)
	local _1 = _M._get_2_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_12_1(flow)
	local _0 = _M._get_2_3(flow)

	return _C(12, "SelectOneByRandom", flow, _0)
end

function _M._get_19_2(flow)
	local _4 = _M._get_2_2(flow)
	local _5 = _C(17, "GetDistance", flow, _4, 0, false)
	local _0 = _5 <= 5

	if not _0 then
		return false
	end

	local _2 = _M._get_2_2(flow)
	local _3 = _C(6, "GetPuppetData", flow, _2, "id", true, 0)
	local _1 = _3 == 11060100

	if not _1 then
		return false
	end

	return true
end

return _M
