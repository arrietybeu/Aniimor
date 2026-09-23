-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10043_GlacyShadowCheck.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_11_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 11 then
		return _M._to_12_0(flow)
	end

	if nodeId == 12 then
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

	local _0 = _M._get_3_2(flow)

	if _0 then
		flow:setActive()

		if _P(flow, 1, 91063412, 1, nil) then
			flow:setContinue(11)

			return true
		end
	else
		flow:setActiveFail()
	end
end

function _M._to_12_0(flow)
	if not _B(flow, "PBT_TriggerBlueprint") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEventName", "FINISH")
	flow:setContinue(12)

	return true
end

function _M._get_3_2(flow)
	local _0 = _C(2, "GetAoiEntityTableByLevel", flow, 0, 10, 2)

	if _0 == nil then
		return
	end

	for k, v in ipairs(_0) do
		local _1 = pg.getEntityByActorId(v)

		flow:setCache(3, "__iterItem", _1 and _1.actorId or 0)

		if _M._get_5_2(flow) then
			return true
		end
	end

	return false
end

function _M._get_5_2(flow)
	local _1 = flow:getCache(3, "__iterItem")
	local _0 = _C(4, "GetDistance", flow, _1, 0, false)

	return _0 <= 5
end

return _M
