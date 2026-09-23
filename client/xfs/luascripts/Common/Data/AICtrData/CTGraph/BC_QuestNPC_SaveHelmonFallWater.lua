-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_QuestNPC_SaveHelmonFallWater.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_2_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 2 then
		return _M._to_4_0(flow)
	end

	if nodeId == 9 then
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

	local _0 = _M._get_1_2(flow)

	if _0 then
		flow:setActive()
		_C(2, "DoBehaviour", flow, "PBT_TeleportToPos")
		flow.__agent:clearSubTreeLocalParams()
		flow:setContinue(2)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_4_0(flow)
	flow:addTimer(1, _M, "_to_5_0", flow)

	return true
end

function _M._to_5_0(flow)
	flow:setActive()

	local _0 = _C(6, "GetSelfId", flow)

	_A(flow, "PlayEffectOnTarget", _0, "Eff_Parmon_Die", 5)

	return _M._to_9_0(flow)
end

function _M._to_9_0(flow)
	if not _B(flow, "PBT_TriggerBlueprint") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEventName", "HelmonFallWater")
	flow:setContinue(9)

	return true
end

function _M._get_1_2(flow)
	local _0 = _C(7, "GetSelfId", flow)

	return _C(1, "IsOnWater", flow, _0, -0.5)
end

return _M
