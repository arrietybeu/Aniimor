-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10041_NSExitSwimMimicry.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_17_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 17 then
		return _M._to_20_0(flow)
	end

	if nodeId == 20 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_17_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_1_1(flow)

	if _0 then
		flow:setActive()
		_C(17, "DoBehaviour", flow, "PBT_SwitchState")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tCharacterState", "SWIMMIMICRYOUT")
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "")
		flow:setContinue(17)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_20_0(flow)
	if not _B(flow, "PBT_Leave") then
		return
	end

	local _0 = _M._get_18_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow:setContinue(20)

	return true
end

function _M._get_1_1(flow)
	local _1 = _M._get_4_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_4_3(flow)
	local _0 = _C(3, "GetAoiEntityTableByLevel", flow, 0, 10, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(4, "__iterItem", v)

		if _M._get_11_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_4_2(flow)
	return flow:getCache(4, "__iterItem")
end

function _M._get_11_2(flow)
	local _0 = _M._get_16_2(flow)

	if not _0 then
		return false
	end

	local _2 = _M._get_4_2(flow)
	local _3 = _C(6, "GetDistance", flow, _2, 0, false)
	local _1 = _3 <= 10

	if not _1 then
		return false
	end

	return true
end

function _M._get_13_2(flow)
	local _0 = _M._get_14_1(flow)

	if not _0 then
		return false
	end

	local _2 = _M._get_4_2(flow)
	local _3 = _C(10, "GetControllingPetActorId", flow, _2)
	local _4 = _C(9, "IsSameSpecies", flow, _3, 0)
	local _1 = not _4

	if not _1 then
		return false
	end

	return true
end

function _M._get_14_1(flow)
	local _0 = _M._get_4_2(flow)

	return _C(14, "IsControllingPet", flow, _0)
end

function _M._get_16_2(flow)
	local _2 = _M._get_14_1(flow)
	local _0 = not _2

	if _0 then
		return true
	end

	local _1 = _M._get_13_2(flow)

	if _1 then
		return true
	end

	return false
end

function _M._get_18_1(flow)
	local _0 = flow:getCache(18, "312")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_19_1(flow)

	flow:setCache(18, "312", _0)

	return _0
end

function _M._get_19_1(flow)
	local _0 = _M._get_4_3(flow)

	return _C(19, "SelectOneByRandom", flow, _0)
end

return _M
