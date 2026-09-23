-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_EcoDemo_Node_1_ChemState.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_22_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 22 then
		return _M._to_25_0(flow)
	end

	if nodeId == 25 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_22_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_24_1(flow)

	if _0 then
		flow:setActive()
		_C(22, "DoBehaviour", flow, "PBT_MoveToTargetEntity")

		local _1 = _M._get_20_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tTargetActorId", _1)
		flow.__agent:addSubTreeLocalParam("tStopDist", 2.5)
		flow.__agent:addSubTreeLocalParam("tMaxTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tFaceTarget", true)
		flow.__agent:addSubTreeLocalParam("tSpeed", 3)
		flow.__agent:addSubTreeLocalParam("tMoveUpdateLevel", 99999)
		flow.__agent:addSubTreeLocalParam("tPathFindType", 0)
		flow.__agent:addSubTreeLocalParam("tSpeedRateType", 0)
		flow.__agent:addSubTreeLocalParam("tUseAccurateArrive", false)
		flow.__agent:addSubTreeLocalParam("tNoBodySize", false)
		flow:setContinue(22)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_25_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Behav_Happy")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happt")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(25)

	return true
end

function _M._get_19_3(flow)
	return flow:getCache(19, "__iterItem")
end

function _M._get_19_2(flow)
	local _0 = _C(17, "GetAoiEntityTableByLevel", flow, 0, 30, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(19, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_58_3(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_20_1(flow)
	local _0 = _M._get_19_2(flow)

	return _C(20, "SelectOneByRandom", flow, _0)
end

function _M._get_24_1(flow)
	local _1 = _M._get_19_2(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_58_3(flow)
	local _3 = _M._get_19_3(flow)
	local _0 = _C(18, "CheckHasChemState", flow, _3, nil)

	if _0 then
		return true
	end

	local _4 = _M._get_19_3(flow)
	local _1 = _C(60, "CheckHasChemState", flow, _4, nil)

	if _1 then
		return true
	end

	local _5 = _M._get_19_3(flow)
	local _2 = _C(61, "CheckHasChemState", flow, _5, nil)

	if _2 then
		return true
	end

	return false
end

return _M
