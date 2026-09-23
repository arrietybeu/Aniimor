-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_PetActionMode_Invade.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_7_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 7 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_7_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_11_4(flow)

	if _0 then
		flow:setActive()
		_C(7, "DoBehaviour", flow, "PBT_PetActionMode_Invade")

		local _1 = _M._get_33_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetID", _1)
		flow.__agent:addSubTreeLocalParam("CurrentDistToTarget", 0)
		flow:setContinue(7)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_11_4(flow)
	local _0 = _C(8, "CheckPetActionMode", flow, 2, 0)

	if not _0 then
		return false
	end

	local _4 = _M._get_17_3(flow)
	local _5 = not _4 or next(_4) == nil
	local _1 = not _5

	if not _1 then
		return false
	end

	local _6 = _M._get_33_2(flow)
	local _2 = _C(20, "CheckCanMoveToTarget", flow, _6, 2)

	if not _2 then
		return false
	end

	local _8 = _M._get_33_2(flow)
	local _9 = _C(40, "GetAuthorityPlayer", flow)
	local _7 = _C(39, "GetDistance", flow, _8, _9, true)
	local _3 = _7 <= 20

	if not _3 then
		return false
	end

	return true
end

function _M._get_15_2(flow)
	local _0 = _M._get_17_2(flow)
	local _1 = _C(16, "GetSelfId", flow)

	return _C(15, "CheckRelation", flow, _0, _1, 2)
end

function _M._get_17_3(flow)
	local _0 = _C(34, "GetAoiEntityTableByLevel", flow, 0, 20, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(17, "__iterItem", v)

		if _M._get_15_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_17_2(flow)
	return flow:getCache(17, "__iterItem")
end

function _M._get_22_3(flow)
	local _0 = flow:getCache(33, "__iterItem")
	local _1 = _C(29, "GetAuthorityPlayer", flow)

	return _C(22, "GetDistance", flow, _0, _1, true)
end

function _M._get_33_2(flow)
	local _0 = _M._get_17_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(33, "__iterItem", v)

		_1 = _M._get_22_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

return _M
