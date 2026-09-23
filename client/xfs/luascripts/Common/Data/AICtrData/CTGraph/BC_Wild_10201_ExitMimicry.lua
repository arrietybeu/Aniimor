-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_ExitMimicry.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tCharacterState", value0)
	agent:addSubTreeLocalParam("tTgtId", value1)
	agent:addSubTreeLocalParam("tTargetAtYawDegree", value2)
	agent:addSubTreeLocalParam("tInstant", value3)
	agent:addSubTreeLocalParam("tAnimationKey", value4)
	flow:setContinue(nodeId)

	return true
end

function _M.executeTickLodTrigger(flow)
	return _M._to_48_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 30 then
		return true
	end

	if nodeId == 43 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_30_0(flow)
	if not _B(flow, "PBT_Wild_10201_MimicryOutAndLeave") then
		return
	end

	local _0 = "LOCOMOTION"
	local _1 = _M._get_27_1(flow)

	return _doBehaviourTail_0(flow, 30, _0, _1, 0, false, "")
end

function _M._to_43_0(flow)
	if not _B(flow, "PBT_Wild_10201_MimicryOutAndLeave") then
		return
	end

	local _0 = "MIMICRYOUT"
	local _1 = _M._get_27_1(flow)

	return _doBehaviourTail_0(flow, 43, _0, _1, 0, false, "Mimicry_End02")
end

function _M._to_48_0(flow)
	local _0 = _M._get_47_2(flow)

	if _0 then
		return _M._to_56_0(flow)
	end

	local _1 = _M._get_45_2(flow)

	if _1 then
		return _M._to_59_0(flow)
	end
end

function _M._to_56_0(flow)
	flow:addTimer(1, _M, "_to_58_0", flow)

	return _M._to_43_0(flow)
end

function _M._to_58_0(flow)
	flow:setActive()
	_A(flow, "SendMessageToTrigger", 0, 1016)

	return true
end

function _M._to_59_0(flow)
	flow:addTimer(1, _M, "_to_60_0", flow)

	return _M._to_30_0(flow)
end

function _M._to_60_0(flow)
	flow:setActive()
	_A(flow, "SendMessageToTrigger", 0, 1016)

	return true
end

function _M._get_6_3(flow)
	local _0 = _C(5, "GetAoiEntityTableByLevel", flow, 0, 10, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(6, "__iterItem", v)

		if _M._get_16_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_6_2(flow)
	return flow:getCache(6, "__iterItem")
end

function _M._get_11_1(flow)
	local _1 = _M._get_6_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_16_2(flow)
	local _0 = _M._get_23_2(flow)

	if not _0 then
		return false
	end

	local _2 = _M._get_6_2(flow)
	local _3 = _C(8, "GetDistance", flow, _2, 0, false)
	local _1 = _3 <= 5

	if not _1 then
		return false
	end

	return true
end

function _M._get_17_1(flow)
	local _0 = _M._get_6_2(flow)

	return _C(17, "GetControllingPetActorId", flow, _0)
end

function _M._get_20_3(flow)
	local _0 = _M._get_21_1(flow)

	if not _0 then
		return false
	end

	local _3 = _M._get_17_1(flow)
	local _4 = _C(33, "GetSelfId", flow)
	local _5 = _C(18, "IsSameSpecies", flow, _3, _4)
	local _1 = not _5

	if not _1 then
		return false
	end

	local _6 = _M._get_17_1(flow)
	local _7 = _C(54, "GetPetData", flow, _6, "petPrototypeId", true, 0)
	local _8 = _7 == 1020700
	local _2 = not _8

	if not _2 then
		return false
	end

	return true
end

function _M._get_21_1(flow)
	local _0 = _M._get_6_2(flow)

	return _C(21, "IsControllingPet", flow, _0)
end

function _M._get_23_2(flow)
	local _2 = _M._get_21_1(flow)
	local _0 = not _2

	if _0 then
		return true
	end

	local _1 = _M._get_20_3(flow)

	if _1 then
		return true
	end

	return false
end

function _M._get_27_1(flow)
	local _0 = flow:getCache(27, "312")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_28_1(flow)

	flow:setCache(27, "312", _0)

	return _0
end

function _M._get_28_1(flow)
	local _0 = _M._get_6_3(flow)

	return _C(28, "SelectOneByRandom", flow, _0)
end

function _M._get_37_2(flow)
	local _0 = _M._get_39_2(flow)
	local _1 = _C(34, "GetSelfId", flow)

	return _C(37, "IsSameSpecies", flow, _0, _1)
end

function _M._get_39_3(flow)
	local _0 = _C(36, "GetAoiEntityTableByLevel", flow, 0, 10, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(39, "__iterItem", v)

		if _M._get_37_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_39_2(flow)
	return flow:getCache(39, "__iterItem")
end

function _M._get_41_1(flow)
	local _0 = _M._get_39_3(flow)

	return not _0 or next(_0) == nil
end

function _M._get_45_2(flow)
	local _0 = _M._get_41_1(flow)

	if not _0 then
		return false
	end

	local _1 = _M._get_11_1(flow)

	if not _1 then
		return false
	end

	return true
end

function _M._get_47_2(flow)
	local _2 = _M._get_41_1(flow)
	local _0 = not _2

	if not _0 then
		return false
	end

	local _1 = _M._get_11_1(flow)

	if not _1 then
		return false
	end

	return true
end

return _M
