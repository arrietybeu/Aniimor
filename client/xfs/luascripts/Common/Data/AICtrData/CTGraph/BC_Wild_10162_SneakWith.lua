-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10162_SneakWith.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_29_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_33_0(flow)

	_A(flow, "HideEmojiOnTarget", _0, "Happy")
	flow:setActive()

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 12 then
		return true
	end

	if nodeId == 29 then
		return _M._to_31_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 12 then
		return _M._get_38_1(flow)
	end
end

function _M._to_12_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 12)

	if not _1 then
		flow:setActive()
		_C(12, "DoBehaviour", flow, "PBT_MoveAroundTarget")

		local _1 = _M._get_41_1(flow)
		local _2 = _C(36, "RandomInteger", flow, 1, 3)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tRadius", _2)
		flow.__agent:addSubTreeLocalParam("tSpeed", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
		flow.__agent:addSubTreeLocalParam("tClockwise", false)
		flow.__agent:addSubTreeLocalParam("tTimeout", 0)
		flow:setContinue(12)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_29_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_16_1(flow)

	if _0 then
		flow:setActive()
		_C(29, "DoBehaviour", flow, "PBT_SwitchState")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tCharacterState", "SNEAK")
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
		flow:setContinue(29)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_31_0(flow)
	flow:setActive()

	local _0 = _M._get_33_0(flow)

	_A(flow, "PlayEmojiOnTarget", _0, "Happy", 0)
	flow:setActive()

	local _1 = _M._get_41_1(flow)

	_A(flow, "SendMessageToTrigger", _1, 2)

	return _M._to_12_0(flow)
end

function _M._get_2_3(flow)
	local _0 = _C(1, "GetAoiEntityTableByLevel", flow, 0, 30, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(2, "__iterItem", v)

		if _M._get_10_3(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_2_2(flow)
	return flow:getCache(2, "__iterItem")
end

function _M._get_10_3(flow)
	local _2 = _M._get_2_2(flow)
	local _0 = _C(4, "IsControllingPet", flow, _2)

	if not _0 then
		return false
	end

	if false then
		return false
	end

	local _4 = _M._get_2_2(flow)
	local _5 = _C(6, "GetControllingPetActorId", flow, _4)
	local _3 = _C(9, "GetPetData", flow, _5, "petPrototypeId", true, 0)
	local _1 = _3 == 1016200

	if not _1 then
		return false
	end

	return true
end

function _M._get_13_1(flow)
	local _0 = _M._get_2_3(flow)

	return _C(13, "SelectOneByRandom", flow, _0)
end

function _M._get_14_1(flow)
	local _0 = flow:getCache(14, "10162")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_13_1(flow)

	flow:setCache(14, "10162", _0)

	return _0
end

function _M._get_16_1(flow)
	local _1 = _M._get_2_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_33_0(flow)
	return _C(33, "GetSelfId", flow)
end

function _M._get_38_1(flow)
	local _1 = _M._get_41_1(flow)
	local _0 = _C(40, "IsChildOrTransitionOfCharState", flow, _1, "SNEAK")

	return not _0
end

function _M._get_41_1(flow)
	local _0 = _M._get_14_1(flow)

	return _C(41, "GetControllingPetActorId", flow, _0)
end

return _M
