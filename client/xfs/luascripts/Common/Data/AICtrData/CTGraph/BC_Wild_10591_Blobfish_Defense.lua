-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10591_Blobfish_Defense.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeTickLodTrigger(flow)
	return _M._to_1_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 13 then
		return _M._to_14_0(flow)
	end

	if nodeId == 14 then
		return true
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
		return _M._to_13_0(flow)
	end
end

function _M._to_13_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Angry")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 3)
	flow:setContinue(13)

	return true
end

function _M._to_14_0(flow)
	if not _B(flow, "PBT_AutoCombat") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tShow50PCBubble", false)
	flow.__agent:addSubTreeLocalParam("tShow20PCBubble", false)
	flow.__agent:addSubTreeLocalParam("CurrentDistToTarget", 0)
	flow.__agent:addSubTreeLocalParam("CurrentEP", 0)
	flow.__agent:addSubTreeLocalParam("CurrentHpPercent", 0)
	flow.__agent:addSubTreeLocalParam("Weight_JumpBack", 0)
	flow.__agent:addSubTreeLocalParam("Weight_RunBack", 0)
	flow.__agent:addSubTreeLocalParam("Weight_Skill", 0)
	flow.__agent:addSubTreeLocalParam("Weight_CommonAttack", 0)
	flow.__agent:addSubTreeLocalParam("Weight_NothingToDo", 0)
	flow.__agent:addSubTreeLocalParam("maxSkillDist", 0)
	flow.__agent:addSubTreeLocalParam("skillStopDist", 0)
	flow.__agent:addSubTreeLocalParam("goBackDist", 0)
	flow.__agent:addSubTreeLocalParam("tNewTargetForCatchMode", 0)
	flow.__agent:addSubTreeLocalParam("CurrentBoxDistToTarget", 0)
	flow.__agent:addSubTreeLocalParam("tAngryPrepare", 0)
	flow.__agent:addSubTreeLocalParam("tDrowningDepth", 0)
	flow.__agent:addSubTreeLocalParam("tFlyHeight", 0)
	flow.__agent:addSubTreeLocalParam("tVerticalDistToTgt", 0)
	flow.__agent:addSubTreeLocalParam("tSkillPlan", "0")
	flow.__agent:addSubTreeLocalParam("tSkillUsed", 0)
	flow:setContinue(14)

	return true
end

function _M._get_0_2(flow)
	local _2 = _M._get_3_2(flow)
	local _3 = _C(9, "GetPuppetData", flow, _2, "petPrototypeId", true, 0)
	local _0 = _3 == 1068100

	if not _0 then
		return false
	end

	local _4 = _M._get_3_2(flow)
	local _5 = _C(12, "GetDistance", flow, _4, 0, false)
	local _1 = _5 < 6

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

function _M._get_10_1(flow)
	local _0 = _M._get_3_3(flow)

	return _C(10, "SelectOneByRandom", flow, _0)
end

return _M
