-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10681_PirateCrab_Loot.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_1_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 9 then
		return true
	end

	if nodeId == 16 then
		return _M._to_9_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_1_0(flow)
	local _1 = _M._get_3_3(flow)
	local _2 = not _1 or next(_1) == nil
	local _0 = not _2

	if _0 then
		return _M._to_16_0(flow)
	end
end

function _M._to_9_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_7_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tStopDist", 0.2)
	flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
	flow.__agent:addSubTreeLocalParam("tSpeed", 5)
	flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
	flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
	flow:setContinue(9)

	return true
end

function _M._to_16_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Strong")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 3)
	flow:setContinue(16)

	return true
end

function _M._get_0_2(flow)
	local _2 = _M._get_3_2(flow)
	local _3 = _C(13, "GetPuppetData", flow, _2, "petPrototypeId", true, 0)
	local _0 = _3 == 1059100

	if not _0 then
		return false
	end

	local _4 = _M._get_3_2(flow)
	local _5 = _C(12, "GetDistance", flow, _4, 0, false)
	local _1 = _5 >= 6

	if not _1 then
		return false
	end

	return true
end

function _M._get_3_2(flow)
	return flow:getCache(3, "__iterItem")
end

function _M._get_3_3(flow)
	local _0 = _C(8, "GetAoiEntityTableByLevel", flow, 0, 30, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(3, "__iterItem", v)

		if _M._get_0_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_7_1(flow)
	local _0 = flow:getCache(7, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_15_1(flow)

	flow:setCache(7, "1", _0)

	return _0
end

function _M._get_15_1(flow)
	local _0 = _M._get_3_3(flow)

	return _C(15, "SelectOneByRandom", flow, _0)
end

return _M
