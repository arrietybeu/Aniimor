-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_PvP_EnterCombat.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_1_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 1 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_1_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_5_1(flow)

	if _0 then
		flow:setActive()
		_C(1, "DoBehaviour", flow, "PBT_Monster_PvP_EnterCombat")

		local _1 = _M._get_13_2(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetID", _1)
		flow:setContinue(1)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_0_2(flow)
	return flow:getCache(0, "__iterItem")
end

function _M._get_0_3(flow)
	local _0 = _C(14, "GetAoiEntityTableByLevel", flow, 0, 30, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(0, "__iterItem", v)

		if _M._get_7_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_5_1(flow)
	local _1 = _M._get_0_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_7_2(flow)
	local _0 = _M._get_0_2(flow)
	local _1 = _C(8, "GetSelfId", flow)

	return _C(7, "CheckRelation", flow, _0, _1, 2)
end

function _M._get_11_3(flow)
	local _0 = flow:getCache(13, "__iterItem")

	return _C(11, "GetDistance", flow, _0, 0, true)
end

function _M._get_13_2(flow)
	local _0 = _M._get_0_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(13, "__iterItem", v)

		_1 = _M._get_11_3(flow)

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
