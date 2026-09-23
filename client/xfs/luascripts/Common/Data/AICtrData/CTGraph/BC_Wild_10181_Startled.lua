-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10181_Startled.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_11_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 11 then
		return _M._to_15_0(flow)
	end

	if nodeId == 15 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_11_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_2_1(flow)

	if _0 then
		flow:setActive()
		_C(11, "DoBehaviour", flow, "PBT_TurnToTargetAtYaw")

		local _1 = _M._get_3_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTgtId", _1)
		flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
		flow.__agent:addSubTreeLocalParam("tInstant", false)
		flow:setContinue(11)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_15_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_22_2(flow)

	if _0 then
		flow:setActive()
		_C(15, "DoBehaviour", flow, "PBT_Perception_Leave")

		local _1 = _M._get_3_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tSensorTgtId", _1)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
		flow.__agent:addSubTreeLocalParam("tSpeed", 3.5)
		flow:setContinue(15)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_1_1(flow)
	local _0 = _M._get_7_3(flow)

	return _C(1, "SelectOneByRandom", flow, _0)
end

function _M._get_2_1(flow)
	local _1 = _M._get_7_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_3_1(flow)
	local _0 = flow:getCache(3, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_1_1(flow)

	flow:setCache(3, "1", _0)

	return _0
end

function _M._get_7_2(flow)
	return flow:getCache(7, "__iterItem")
end

function _M._get_7_3(flow)
	local _0 = _C(6, "GetAoiEntityTableByLevel", flow, 0, 10, 14)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(7, "__iterItem", v)

		if _M._get_20_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_20_2(flow)
	local _2 = _M._get_7_2(flow)
	local _0 = _C(5, "HasEntityTag", flow, _2, "TE_Wild_Mustelidae")

	if not _0 then
		return false
	end

	local _3 = _M._get_7_2(flow)
	local _4 = _C(18, "GetDistance", flow, _3, 0, false)
	local _1 = _4 <= 5

	if not _1 then
		return false
	end

	return true
end

function _M._get_22_2(flow)
	local _1 = _M._get_3_1(flow)
	local _0 = _C(23, "GetDistance", flow, _1, 0, true)

	return _0 <= 3
end

return _M
