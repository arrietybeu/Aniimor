-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_QuestNPC_SaveHelmonAfraid_AdditiveEnd.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction

function _M.executeTickLodTrigger(flow)
	return _M._to_1_0(flow)
end

function _M._to_1_0(flow)
	local _0 = _M._get_5_4(flow)

	if _0 then
		flow:setActive()
		_A(flow, "AddAITag", 0, "TA_SaveHelmon_AfraidEnd")

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_3_3(flow)
	local _0 = _C(2, "GetAoiEntityTableByLevel", flow, 0, 30, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(3, "__iterItem", v)

		if _M._get_40_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_3_2(flow)
	return flow:getCache(3, "__iterItem")
end

function _M._get_5_4(flow)
	local _4 = _C(7, "GetSelfId", flow)
	local _0 = _C(6, "IsInBehavTag", flow, _4, "TB_SaveHelmon_Afraid")

	if not _0 then
		return false
	end

	local _7 = _C(37, "HasAITag", flow, 0, "TA_SaveHelmon_AfraidEnd")
	local _1 = not _7

	if not _1 then
		return false
	end

	local _5 = _C(8, "HasAITag", flow, 0, "TA_SaveHelmon_InBattle", "TA_SaveHelmon_OutRange")
	local _2 = not _5

	if not _2 then
		return false
	end

	local _6 = _M._get_3_3(flow)
	local _3 = not _6 or next(_6) == nil

	if not _3 then
		return false
	end

	return true
end

function _M._get_34_2(flow)
	local _2 = _M._get_3_2(flow)
	local _0 = _C(17, "IsControllingPet", flow, _2)

	if not _0 then
		return false
	end

	local _3 = _M._get_3_2(flow)
	local _4 = _C(11, "GetControllingPetActorId", flow, _3)
	local _1 = _C(29, "IsEthnicGroup", flow, _4, 2002)

	if not _1 then
		return false
	end

	return true
end

function _M._get_40_2(flow)
	local _0 = _M._get_34_2(flow)

	if not _0 then
		return false
	end

	local _2 = _M._get_3_2(flow)
	local _3 = _C(14, "GetDistance", flow, _2, 0, false)
	local _1 = _3 <= 10

	if not _1 then
		return false
	end

	return true
end

return _M
