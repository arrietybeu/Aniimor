-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10051_FireShrub.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_29_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 12 then
		return _M._to_24_0(flow)
	end

	if nodeId == 24 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_12_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _M._get_7_1(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tSkillId", 10510500)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(12)

	return true
end

function _M._to_24_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_28_1(flow)

	if _0 then
		flow:setActive()

		local _1 = _M._get_25_8(flow)

		if _P(flow, 1, _1, 0, nil) then
			flow:setContinue(24)

			return true
		end
	else
		flow:setActiveFail()
	end
end

function _M._to_29_0(flow)
	return _M._to_12_0(flow)
end

function _M._get_1_2(flow)
	local _0 = _C(0, "GetAoiEntityTableByLevel", flow, 0, 30, 256)

	if _0 == nil then
		return
	end

	local _1 = flow:getTempList()

	for k, v in ipairs(_0) do
		local _2 = pg.getEntityByActorId(v)

		flow:setCache(1, "__iterItem", _2 and _2.actorId or 0)

		if _M._get_5_2(flow) then
			_1[#_1 + 1] = _2.actorId
		end
	end

	return _1
end

function _M._get_1_3(flow)
	return flow:getCache(1, "__iterItem")
end

function _M._get_5_2(flow)
	local _2 = _M._get_1_3(flow)
	local _0 = _C(2, "HasEntityTag", flow, _2, "TE_Env_10051_FireShrub")

	if not _0 then
		return false
	end

	local _3 = _M._get_1_3(flow)
	local _4 = _C(3, "GetDistance", flow, _3, 0, false)
	local _1 = _4 <= 10

	if not _1 then
		return false
	end

	return true
end

function _M._get_6_1(flow)
	local _0 = _M._get_1_2(flow)

	return _C(6, "SelectOneByRandom", flow, _0)
end

function _M._get_7_1(flow)
	local _0 = flow:getCache(7, "Shrub")

	if _0 ~= nil then
		return _0
	end

	_0 = _M._get_6_1(flow)

	flow:setCache(7, "Shrub", _0)

	return _0
end

function _M._get_13_1(flow)
	local _0 = _M._get_1_2(flow)

	return not _0 or next(_0) == nil
end

function _M._get_25_8(flow)
	return _C(25, "GetRouteIdFromEntity", flow, 0, 0, 0, 0, "", "", "", "")
end

function _M._get_28_1(flow)
	local _1 = _M._get_25_8(flow)
	local _0 = _1 == 0

	return not _0
end

return _M
