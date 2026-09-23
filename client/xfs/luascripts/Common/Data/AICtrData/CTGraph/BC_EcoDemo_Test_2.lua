-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_EcoDemo_Test_2.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_52_0(flow)
end

function _M.executeEndTrigger(flow)
	flow:setActive()

	local _0 = _M._get_51_1(flow)

	_A(flow, "RemoveEntityTag", _0, "TE_Env_BeUsed")

	return true
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 62 then
		return _M._to_63_0(flow)
	end

	if nodeId == 63 then
		return _M._to_65_0(flow)
	end

	if nodeId == 65 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_52_0(flow)
	local _2 = _M._get_48_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _0 = not _3

	if _0 then
		flow:setActive()

		local _1 = _M._get_51_1(flow)

		_A(flow, "AddEntityTag", _1, "TE_Env_BeUsed")

		return _M._to_62_0(flow)
	else
		flow:setActiveFail()
	end
end

function _M._to_62_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_51_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tStopDist", 2)
	flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
	flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
	flow:setContinue(62)

	return true
end

function _M._to_63_0(flow)
	if not _B(flow, "PBT_Node_Com_SwitchToHideMimicryIn") then
		return
	end

	local _0 = _M._get_64_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetPos", _0)
	flow:setContinue(63)

	return true
end

function _M._to_65_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 100)
	flow:setContinue(65)

	return true
end

function _M._get_48_3(flow)
	local _0 = _C(46, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(48, "__iterItem", v)

		if _M._get_59_3(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_48_2(flow)
	return flow:getCache(48, "__iterItem")
end

function _M._get_50_1(flow)
	local _0 = _M._get_48_3(flow)

	return _C(50, "SelectOneByRandom", flow, _0)
end

function _M._get_51_1(flow)
	local _0 = flow:getCache(51, "1")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_50_1(flow)

	flow:setCache(51, "1", _0)

	return _0
end

function _M._get_59_3(flow)
	local _4 = _M._get_48_2(flow)
	local _5 = _C(57, "HasEntityTag", flow, _4, "TE_Env_BeUsed")
	local _0 = not _5

	if not _0 then
		return false
	end

	local _3 = _M._get_48_2(flow)
	local _1 = _C(47, "HasEntityTag", flow, _3, "TE_Env_Food")

	if not _1 then
		return false
	end

	local _6 = _C(69, "GetSelfId", flow)
	local _7 = _M._get_48_2(flow)
	local _8 = _C(68, "GetDistance", flow, _6, _7, false)
	local _2 = _8 <= 20

	if not _2 then
		return false
	end

	return true
end

function _M._get_64_1(flow)
	local _0 = _M._get_51_1(flow)

	return _C(64, "GetEntPosition", flow, _0)
end

return _M
