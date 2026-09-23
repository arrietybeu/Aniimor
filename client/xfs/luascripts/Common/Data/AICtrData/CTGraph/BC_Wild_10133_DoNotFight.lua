-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10133_DoNotFight.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "SensedMsgTrigger" then
		return _M._to_101_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 98 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_98_0(flow)
	if not _B(flow, "PBT_Perception_Stare") then
		return
	end

	local _0 = _M._get_132_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tSensorTgtId", _0)
	flow.__agent:addSubTreeLocalParam("tMaxTime", 0)
	flow.__agent:addSubTreeLocalParam("tRandomTime", 0)
	flow:setContinue(98)

	return true
end

function _M._to_101_0(flow)
	local _0 = _M._get_114_2(flow)

	if _0 then
		flow:setActive()

		local _1 = _C(128, "GetSelfId", flow)

		_A(flow, "SendMessageToTrigger", _1, 1013301)

		return _M._to_98_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._get_73_2(flow)
	local _2 = _M._get_132_1(flow)
	local _0 = _C(81, "IsControllingPet", flow, _2)

	if not _0 then
		return false
	end

	local _4 = _C(83, "GetSelfId", flow)
	local _5 = _C(84, "GetEntProperty", flow, _4, "level")
	local _6 = _M._get_132_1(flow)
	local _7 = _C(82, "GetControllingPetActorId", flow, _6)
	local _8 = _C(77, "GetEntProperty", flow, _7, "level")
	local _3 = _5 - _8
	local _1 = _3 >= 1

	if not _1 then
		return false
	end

	return true
end

function _M._get_114_2(flow)
	local _0 = _M._get_73_2(flow)

	if _0 then
		return true
	end

	local _1 = _M._get_135_2(flow)

	if _1 then
		return true
	end

	return false
end

function _M._get_121_2(flow)
	return flow:getCache(121, "__iterItem")
end

function _M._get_121_3(flow)
	local _0 = _C(136, "GetAoiEntityTableByLevel", flow, 0, 30, 4)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(121, "__iterItem", v)

		if _M._get_124_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_124_2(flow)
	local _2 = _M._get_121_2(flow)
	local _0 = _C(113, "IsCurCombatPet", flow, _2)

	if not _0 then
		return false
	end

	local _4 = _C(117, "GetSelfId", flow)
	local _5 = _C(118, "GetEntProperty", flow, _4, "level")
	local _6 = _M._get_121_2(flow)
	local _7 = _C(116, "GetEntProperty", flow, _6, "level")
	local _3 = _5 - _7
	local _1 = _3 >= 1

	if not _1 then
		return false
	end

	return true
end

function _M._get_132_1(flow)
	local _0 = _C(131, "GetPerceptibilityTable", flow)

	if _0 == nil then
		return
	end

	local key = next(_0)
	local value = _0[key]

	for k, v in pairs(_0) do
		if value < v then
			key, value = k, v
		end
	end

	return key
end

function _M._get_135_2(flow)
	local _4 = _M._get_132_1(flow)
	local _5 = _C(133, "IsControllingPet", flow, _4)
	local _0 = not _5

	if not _0 then
		return false
	end

	local _2 = _M._get_121_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _1 = not _3

	if not _1 then
		return false
	end

	return true
end

return _M
