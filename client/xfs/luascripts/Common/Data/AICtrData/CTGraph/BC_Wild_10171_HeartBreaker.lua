-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10171_HeartBreaker.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_26_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 26 then
		return _M._to_19_0(flow)
	end

	if nodeId == 27 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 27 then
		return _M._get_17_1(flow)
	end
end

function _M._to_19_0(flow)
	flow:setActive()

	local _0 = _C(24, "GetSelfId", flow)

	_A(flow, "LerpProperty", true, 2, _0)

	return _M._to_37_0(flow)
end

function _M._to_22_0(flow)
	flow:setActive()
	_A(flow, "SendMessageToTrigger", 0, 1001)

	return _M._to_27_0(flow)
end

function _M._to_26_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_18_1(flow)

	if _0 then
		flow:setActive()
		_C(26, "DoBehaviour", flow, "PBT_Behav_Com_Notice")

		local _1 = _M._get_16_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tWait", true)
		flow:setContinue(26)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_27_0(flow)
	if flow.__isAdditive then
		return
	end

	local _1 = _M.checkInterrupt(flow, 27)

	if not _1 then
		flow:setActive()
		_C(27, "DoBehaviour", flow, "PBT_Behav_Com_FollowByRelativePos")

		local _1 = _M._get_16_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tRandomValue", 0)
		flow:setContinue(27)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_29_0(flow)
	local _0 = _M._get_48_2(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_38_1(flow)

		_A(flow, "SendMessageToTrigger", _1, 101720001)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_37_0(flow)
	flow:addTimer(0, _M, "_to_29_0", flow)

	return _M._to_22_0(flow)
end

function _M._get_1_3(flow)
	local _0 = _C(0, "GetAoiEntityTableByLevel", flow, 0, 30, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(1, "__iterItem", v)

		if _M._get_6_4(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_1_2(flow)
	return flow:getCache(1, "__iterItem")
end

function _M._get_4_2(flow)
	local _0 = _M._get_23_1(flow)

	return _C(4, "GetPetData", flow, _0, "baseFormPet", true, 0)
end

function _M._get_6_4(flow)
	local _4 = _M._get_1_2(flow)
	local _0 = _C(3, "IsControllingPet", flow, _4)

	if not _0 then
		return false
	end

	local _1 = _M._get_30_2(flow)

	if not _1 then
		return false
	end

	local _7 = _M._get_23_1(flow)
	local _8 = _C(9, "GetEntProperty", flow, _7, "gender")
	local _11 = _M._get_11_0(flow)
	local _9 = _C(25, "GetEntProperty", flow, _11, "gender")
	local _10 = _8 == _9
	local _2 = not _10

	if not _2 then
		return false
	end

	local _5 = _M._get_1_2(flow)
	local _6 = _C(7, "GetDistance", flow, _5, 0, false)
	local _3 = _6 <= 20

	if not _3 then
		return false
	end

	return true
end

function _M._get_11_0(flow)
	return _C(11, "GetSelfId", flow)
end

function _M._get_15_1(flow)
	local _0 = _M._get_1_3(flow)

	return _C(15, "SelectOneByRandom", flow, _0)
end

function _M._get_16_1(flow)
	local _0 = flow:getCache(16, "haaiwang")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_15_1(flow)

	flow:setCache(16, "haaiwang", _0)

	return _0
end

function _M._get_17_1(flow)
	local _0 = _M._get_1_3(flow)

	return not _0 or next(_0) == nil
end

function _M._get_18_1(flow)
	local _0 = _M._get_17_1(flow)

	return not _0
end

function _M._get_23_1(flow)
	local _0 = _M._get_1_2(flow)

	return _C(23, "GetControllingPetActorId", flow, _0)
end

function _M._get_30_2(flow)
	local _2 = _M._get_4_2(flow)
	local _0 = _2 == 1017300

	if _0 then
		return true
	end

	local _1 = _M._get_35_2(flow)

	if _1 then
		return true
	end

	return false
end

function _M._get_35_2(flow)
	local _2 = _M._get_4_2(flow)
	local _0 = _2 == 1017200

	if not _0 then
		return false
	end

	local _3 = _M._get_11_0(flow)
	local _4 = _C(33, "GetPuppetData", flow, _3, "baseFormPet", true, 0)
	local _5 = _4 == 1017200
	local _1 = not _5

	if not _1 then
		return false
	end

	return true
end

function _M._get_38_1(flow)
	local _0 = _M._get_16_1(flow)

	return _C(38, "GetControllingPetActorId", flow, _0)
end

function _M._get_48_2(flow)
	local _2 = _M._get_38_1(flow)
	local _3 = _C(39, "GetPetData", flow, _2, "baseFormPet", true, 0)
	local _0 = _3 == 1017200

	if not _0 then
		return false
	end

	local _4 = _C(44, "GetSelfId", flow)
	local _5 = _C(45, "GetPuppetData", flow, _4, "baseFormPet", true, 0)
	local _6 = _5 == 1017200
	local _1 = not _6

	if not _1 then
		return false
	end

	return true
end

return _M
