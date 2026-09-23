-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Npc_Novice_EnterCombat.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_3_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 3 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_3_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_28_1(flow)

	if _0 then
		flow:setActive()
		_C(3, "DoBehaviour", flow, "PBT_NPC_Novice_ReadyToFight")

		local _1 = _M._get_22_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTarget", _1)
		flow:setContinue(3)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_4_1(flow)
	local _0 = _C(14, "GetPetMaster", flow, 0)

	return _C(4, "GetAoiEntityTableByLevel", flow, _0, 50, 8)
end

function _M._get_6_3(flow)
	local _0 = _M._get_4_1(flow)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(6, "__iterItem", v)

		if _M._get_32_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_6_2(flow)
	return flow:getCache(6, "__iterItem")
end

function _M._get_22_1(flow)
	local _0 = _M._get_6_3(flow)

	return _C(22, "SelectOneByRandom", flow, _0)
end

function _M._get_25_1(flow)
	local _0 = _M._get_6_2(flow)

	return _C(25, "GetEntProperty", flow, _0, "petPrototypeId")
end

function _M._get_28_1(flow)
	local _1 = _M._get_6_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_32_2(flow)
	local _2 = _M._get_25_1(flow)
	local _0 = _2 == 1002300

	if _0 then
		return true
	end

	local _3 = _M._get_25_1(flow)
	local _1 = _3 == 9002500

	if _1 then
		return true
	end

	return false
end

return _M
