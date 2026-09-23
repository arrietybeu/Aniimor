-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_Test_FlyFollow.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_99_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 95 then
		return true
	end

	if nodeId == 99 then
		return _M._to_95_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_95_0(flow)
	if not _B(flow, "PBT_FlyToTarget") then
		return
	end

	local _0 = _M._get_117_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tActorId", _0)
	flow.__agent:addSubTreeLocalParam("tStopDist", 0)
	flow.__agent:addSubTreeLocalParam("tHeight", 0)
	flow.__agent:addSubTreeLocalParam("tTimeout", 10)
	flow.__agent:addSubTreeLocalParam("tNotFaceToPos", false)
	flow.__agent:addSubTreeLocalParam("tMinHoldTime", 0)
	flow.__agent:addSubTreeLocalParam("tIgnoreVertical", false)
	flow.__agent:addSubTreeLocalParam("tIgnoreHorizontal", true)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow:setContinue(95)

	return true
end

function _M._to_99_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_107_1(flow)

	if _0 then
		flow:setActive()
		_C(99, "DoBehaviour", flow, "PBT_SwitchToFly")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tFlyHeight", 1)
		flow.__agent:addSubTreeLocalParam("tMaxTime", 5)
		flow:setContinue(99)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_107_1(flow)
	local _1 = _M._get_115_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_113_2(flow)
	local _2 = _M._get_115_2(flow)
	local _3 = _C(106, "GetPuppetData", flow, _2, "id", true, 0)
	local _0 = _3 == 91018501

	if not _0 then
		return false
	end

	local _4 = _M._get_115_2(flow)
	local _5 = _C(111, "GetDistance", flow, _4, 0, false)
	local _1 = _5 <= 10

	if not _1 then
		return false
	end

	return true
end

function _M._get_115_2(flow)
	return flow:getCache(115, "__iterItem")
end

function _M._get_115_3(flow)
	local _0 = _C(109, "GetAoiEntityTableByLevel", flow, 0, 30, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(115, "__iterItem", v)

		if _M._get_113_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_117_1(flow)
	local _0 = _M._get_115_3(flow)

	return _C(117, "SelectOneByRandom", flow, _0)
end

return _M
