-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Recruit_BeCalled_10191.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeEventTrigger(flow, eventName)
	if eventName == "OnCharacterStateChange" then
		return _M._to_49_0(flow)
	end
end

function _M._to_49_0(flow)
	local _2 = _M._get_53_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _0 = not _3

	if _0 then
		flow:setActive()

		local _1 = _C(50, "GetSelfId", flow)

		_A(flow, "SendMessageToTrigger", _1, 1019202)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_46_5(flow)
	local _7 = _M._get_53_2(flow)
	local _0 = _C(42, "IsControllingPet", flow, _7)

	if not _0 then
		return false
	end

	local _8 = _M._get_53_2(flow)
	local _9 = _C(41, "GetControllingPetActorId", flow, _8)
	local _10 = _C(44, "GetPetData", flow, _9, "baseFormPet", true, 0)
	local _1 = _10 == 1019200

	if not _1 then
		return false
	end

	local _5 = flow:getContextValue("oldState")
	local _2 = _5 == "MIMICRYOUT"

	if not _2 then
		return false
	end

	local _6 = flow:getContextValue("newState")
	local _3 = _6 == "LOCOMOTION"

	if not _3 then
		return false
	end

	local _11 = _C(48, "GetSelfId", flow)
	local _4 = _C(47, "IsInBehavTag", flow, _11, "TB_Recuit")

	if not _4 then
		return false
	end

	return true
end

function _M._get_53_3(flow)
	local _0 = _C(51, "GetAoiEntityTableByLevel", flow, 0, 30, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(53, "__iterItem", v)

		if _M._get_46_5(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_53_2(flow)
	return flow:getCache(53, "__iterItem")
end

return _M
