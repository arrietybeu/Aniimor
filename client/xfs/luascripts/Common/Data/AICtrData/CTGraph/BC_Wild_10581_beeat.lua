-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10581_beeat.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_2_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 2 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_2_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_11_1(flow)

	if _0 then
		flow:setActive()
		_C(2, "DoBehaviour", flow, "PBT_CustomAnimation")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "Idle")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 60)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", true)
		flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
		flow:setContinue(2)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_5_3(flow)
	local _0 = _C(14, "GetAoiEntityTableByLevel", flow, 0, 10, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(5, "__iterItem", v)

		if _M._get_17_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_5_2(flow)
	return flow:getCache(5, "__iterItem")
end

function _M._get_9_3(flow)
	local _0 = flow:getCache(12, "__iterItem")

	return _C(9, "GetDistance", flow, _0, 0, false)
end

function _M._get_11_1(flow)
	local _1 = _M._get_5_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_12_2(flow)
	local _0 = _M._get_5_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(12, "__iterItem", v)

		_1 = _M._get_9_3(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _1 < _3 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_17_2(flow)
	local _2 = _M._get_5_2(flow)
	local _0 = _C(7, "HasEntityTag", flow, _2, "TE_Env_10581_eat")

	if not _0 then
		return false
	end

	local _3 = _M._get_5_2(flow)
	local _4 = _C(15, "GetDistance", flow, _3, 0, false)
	local _1 = _4 < 3

	if not _1 then
		return false
	end

	return true
end

return _M
