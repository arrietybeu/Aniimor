-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10131_Fight.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_61_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 29 then
		return _M._to_44_0(flow)
	end

	if nodeId == 61 then
		return _M._to_29_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_29_0(flow)
	if not _B(flow, "PBT_ReadyToFight") then
		return
	end

	local _0 = _M._get_21_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tRandomWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tShowExclamation", false)
	flow:setContinue(29)

	return true
end

function _M._to_44_0(flow)
	flow:setActive()
	_A(flow, "SendMessageToTrigger", 0, 2)

	return true
end

function _M._to_61_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_37_2(flow)

	if _0 then
		flow:setActive()
		_C(61, "DoBehaviour", flow, "PBT_ShowQuestionMark")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tMarkType", "DirectFull")
		flow.__agent:addSubTreeLocalParam("tTimeout", 0)
		flow:setContinue(61)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_18_1(flow)
	local _0 = _C(20, "GetAoiEntityTableByLevel", flow, 0, 30, 2)

	return _C(18, "SelectOneByRandom", flow, _0)
end

function _M._get_21_1(flow)
	local _0 = flow:getCache(21, "PlayerId")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_18_1(flow)

	flow:setCache(21, "PlayerId", _0)

	return _0
end

function _M._get_37_2(flow)
	local _0 = _M._get_54_2(flow)

	if _0 then
		return true
	end

	local _2 = _M._get_74_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _1 = not _3

	if _1 then
		return true
	end

	return false
end

function _M._get_54_2(flow)
	local _3 = _M._get_21_1(flow)
	local _4 = _C(33, "GetControllingPetActorId", flow, _3)
	local _2 = _C(40, "GetPetData", flow, _4, "petPrototypeId", true, 0)
	local _0 = _2 == 1005100

	if not _0 then
		return false
	end

	local _5 = _M._get_21_1(flow)
	local _6 = _C(52, "GetDistance", flow, _5, 0, false)
	local _1 = _6 <= 12

	if not _1 then
		return false
	end

	return true
end

function _M._get_71_3(flow)
	local _4 = _M._get_74_2(flow)
	local _3 = _C(69, "GetPetData", flow, _4, "petPrototypeId", true, 0)
	local _0 = _3 == 1005100

	if not _0 then
		return false
	end

	local _7 = _M._get_74_2(flow)
	local _1 = _C(73, "IsCurCombatPet", flow, _7)

	if not _1 then
		return false
	end

	local _5 = _M._get_74_2(flow)
	local _6 = _C(70, "GetDistance", flow, _5, 0, false)
	local _2 = _6 <= 12

	if not _2 then
		return false
	end

	return true
end

function _M._get_74_2(flow)
	return flow:getCache(74, "__iterItem")
end

function _M._get_74_3(flow)
	local _0 = _C(65, "GetAoiEntityTableByLevel", flow, 0, 30, 4)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(74, "__iterItem", v)

		if _M._get_71_3(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

return _M
