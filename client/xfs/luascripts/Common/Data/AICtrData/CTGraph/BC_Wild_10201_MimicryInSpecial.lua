-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_MimicryInSpecial.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_37_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 34 then
		return true
	end

	if nodeId == 37 then
		return _M._to_42_0(flow)
	end

	if nodeId == 42 then
		return _M._to_34_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_34_0(flow)
	if not _B(flow, "PBT_SwitchState") then
		return
	end

	local _0 = "MIMICRY"

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tCharacterState", _0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
	flow:setContinue(34)

	return true
end

function _M._to_37_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_36_1(flow)

	if _0 then
		flow:setActive()
		_C(37, "DoBehaviour", flow, "PBT_TurnToTargetAtYaw")

		local _1 = _M._get_40_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTgtId", _1)
		flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
		flow.__agent:addSubTreeLocalParam("tInstant", false)
		flow:setContinue(37)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_42_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Surprise")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 2)
	flow:setContinue(42)

	return true
end

function _M._get_27_2(flow)
	return flow:getCache(27, "__iterItem")
end

function _M._get_27_3(flow)
	local _0 = _C(26, "GetAoiEntityTableByLevel", flow, 0, 10, 14)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(27, "__iterItem", v)

		if _M._get_45_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_36_1(flow)
	local _1 = _M._get_27_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_39_1(flow)
	local _0 = _M._get_27_3(flow)

	return _C(39, "SelectOneByRandom", flow, _0)
end

function _M._get_40_1(flow)
	local _0 = flow:getCache(40, "312")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_39_1(flow)

	flow:setCache(40, "312", _0)

	return _0
end

function _M._get_45_2(flow)
	local _4 = _M._get_27_2(flow)
	local _5 = _C(43, "GetDistance", flow, _4, 0, false)
	local _0 = _5 <= 8

	if not _0 then
		return false
	end

	local _2 = _M._get_27_2(flow)
	local _3 = _C(28, "GetPuppetData", flow, _2, "petPrototypeId", true, 0)
	local _1 = _3 == 1022100

	if not _1 then
		return false
	end

	return true
end

return _M
