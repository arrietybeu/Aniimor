-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Npc_10021_NpcAfraid.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_69_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 69 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 69 then
		return _M._get_25_1(flow)
	end
end

function _M._to_69_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_26_1(flow)
	local _1 = _M.checkInterrupt(flow, 69)

	if _0 and not _1 then
		flow:setActive()
		_C(69, "DoBehaviour", flow, "PBT_LoopAnimAndBreak")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "HideStart")
		flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "HideLoop")
		flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "HideEnd")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", true)
		flow.__agent:addSubTreeLocalParam("tBreakTag", "TA_SaveHelmon_AfraidEnd")
		flow:setContinue(69)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_14_2(flow)
	return flow:getCache(14, "__iterItem")
end

function _M._get_14_3(flow)
	local _0 = _C(16, "GetAoiEntityTableByLevel", flow, 0, 10, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(14, "__iterItem", v)

		if _M._get_82_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_25_1(flow)
	local _0 = _M._get_14_3(flow)

	return not _0 or next(_0) == nil
end

function _M._get_26_1(flow)
	local _0 = _M._get_25_1(flow)

	return not _0
end

function _M._get_82_2(flow)
	local _4 = _M._get_14_2(flow)
	local _5 = _C(83, "IsControllingPet", flow, _4)
	local _0 = not _5

	if not _0 then
		return false
	end

	local _2 = _M._get_14_2(flow)
	local _3 = _C(18, "GetDistance", flow, _2, 0, false)
	local _1 = _3 <= 10

	if not _1 then
		return false
	end

	return true
end

return _M
