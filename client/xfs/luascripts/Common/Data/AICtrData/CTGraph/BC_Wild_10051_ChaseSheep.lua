-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10051_ChaseSheep.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_30_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 30 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_30_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_27_1(flow)

	if _0 then
		flow:setActive()
		_C(30, "DoBehaviour", flow, "PBT_10051_ChaseSheep")

		local _1 = _M._get_29_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("Speed", 3)
		flow.__agent:addSubTreeLocalParam("StopDist", 1)
		flow:setContinue(30)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_21_3(flow)
	local _0 = _C(25, "GetAoiEntityTableByLevel", flow, 0, 30, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(21, "__iterItem", v)

		if _M._get_22_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_21_2(flow)
	return flow:getCache(21, "__iterItem")
end

function _M._get_22_2(flow)
	local _0 = _M._get_21_2(flow)

	return _C(22, "HasEntityTag", flow, _0, "TE_Wild_BeChasedSheep")
end

function _M._get_24_3(flow)
	local _0 = flow:getCache(28, "__iterItem")

	return _C(24, "GetDistance", flow, _0, 0, false)
end

function _M._get_27_1(flow)
	local _1 = _M._get_21_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_28_2(flow)
	local _0 = _M._get_21_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(28, "__iterItem", v)

		_1 = _M._get_24_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_29_1(flow)
	local _0 = flow:getCache(29, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_28_2(flow)

	flow:setCache(29, "1", _0)

	return _0
end

return _M
