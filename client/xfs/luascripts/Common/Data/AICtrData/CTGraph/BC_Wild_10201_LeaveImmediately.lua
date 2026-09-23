-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_LeaveImmediately.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_27_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 27 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_27_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_1_1(flow)

	if _0 then
		flow:setActive()
		_C(27, "DoBehaviour", flow, "PBT_LeaveTargetAndDestroy")

		local _1 = _M._get_12_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tLeaveDistance", 40)
		flow.__agent:addSubTreeLocalParam("tSpeed", 8)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 2)
		flow.__agent:addSubTreeLocalParam("tMaxTime", 30)
		flow.__agent:addSubTreeLocalParam("tDestroyOnFail", true)
		flow:setContinue(27)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_1_1(flow)
	local _1 = _M._get_3_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_3_3(flow)
	local _0 = _C(2, "GetAoiEntityTableByLevel", flow, 0, 30, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(3, "__iterItem", v)

		if _M._get_5_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_3_2(flow)
	return flow:getCache(3, "__iterItem")
end

function _M._get_5_2(flow)
	local _1 = _M._get_3_2(flow)
	local _0 = _C(4, "GetDistance", flow, _1, 0, false)

	return _0 <= 7
end

function _M._get_12_1(flow)
	local _0 = flow:getCache(12, "312")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_13_1(flow)

	flow:setCache(12, "312", _0)

	return _0
end

function _M._get_13_1(flow)
	local _0 = _M._get_3_3(flow)

	return _C(13, "SelectOneByRandom", flow, _0)
end

return _M
