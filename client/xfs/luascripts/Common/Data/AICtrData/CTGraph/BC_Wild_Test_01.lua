-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_Test_01.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_90_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 89 then
		return true
	end

	if nodeId == 90 then
		return _M._to_103_0(flow)
	end

	if nodeId == 103 then
		return _M._to_104_0(flow)
	end

	if nodeId == 104 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_89_0(flow)
	if not _B(flow, "PBT_MoveToTargetEntity") then
		return
	end

	local _0 = _M._get_94_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tStopDist", 2)
	flow.__agent:addSubTreeLocalParam("tMaxTimeout", 15)
	flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
	flow.__agent:addSubTreeLocalParam("tSpeed", 0)
	flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
	flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
	flow.__agent:addSubTreeLocalParam("tSpeedRateType", 1)
	flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
	flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
	flow:setContinue(89)

	return true
end

function _M._to_90_0(flow)
	if not _B(flow, "PBT_Node_Com_SwitchToHideMimicryIn") then
		return
	end

	local _0 = _M._get_95_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tTargetPos", _0)
	flow:setContinue(90)

	return true
end

function _M._to_103_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 10)
	flow:setContinue(103)

	return true
end

function _M._to_104_0(flow)
	if not _B(flow, "PBT_Node_Com_SwitchToHideMimicryOut") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tNeedPlayAnim", true)
	flow.__agent:addSubTreeLocalParam("tJumpDistance", 3)
	flow:setContinue(104)

	return true
end

function _M._get_91_2(flow)
	return flow:getCache(91, "__iterItem")
end

function _M._get_91_3(flow)
	local _0 = _C(102, "GetAoiEntityTableByLevel", flow, 0, 10, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(91, "__iterItem", v)

		if _M._get_97_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_93_1(flow)
	local _0 = _M._get_91_3(flow)

	return _C(93, "SelectOneByRandom", flow, _0)
end

function _M._get_94_1(flow)
	local _0 = flow:getCache(94, "FallenLeaves")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_93_1(flow)

	flow:setCache(94, "FallenLeaves", _0)

	return _0
end

function _M._get_95_1(flow)
	local _0 = _M._get_94_1(flow)

	return _C(95, "GetEntPosition", flow, _0)
end

function _M._get_97_2(flow)
	local _2 = _M._get_91_2(flow)
	local _0 = _C(96, "HasEntityTag", flow, _2, "TE_Env_FallenLeaves")

	if not _0 then
		return false
	end

	local _4 = _M._get_91_2(flow)
	local _3 = _C(99, "HasAITag", flow, _4, "Env_BeUsed")
	local _1 = not _3

	if not _1 then
		return false
	end

	return true
end

function _M._get_101_1(flow)
	local _0 = _M._get_91_3(flow)

	return not _0 or next(_0) == nil
end

return _M
