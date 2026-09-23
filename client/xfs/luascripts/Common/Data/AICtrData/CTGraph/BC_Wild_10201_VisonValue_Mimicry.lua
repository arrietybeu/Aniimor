-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_VisonValue_Mimicry.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_0_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 0 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_0_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_25_1(flow)

	if _0 then
		flow:setActive()
		_C(0, "DoBehaviour", flow, "PBT_LoopAnimAndBreak")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tAnimationStartKey", "HeadOut_Start")
		flow.__agent:addSubTreeLocalParam("tAnimationLoopKey", "HeadOut_Loop")
		flow.__agent:addSubTreeLocalParam("tAnimationEndKey", "HeadOut_End")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 60)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", true)
		flow.__agent:addSubTreeLocalParam("tBreakTag", "AnimationEnd")
		flow:setContinue(0)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_23_2(flow)
	local _4 = _M._get_31_2(flow)
	local _0 = _C(22, "HasEntityTag", flow, _4, "TE_Env_CE_Budclaw_B")

	if not _0 then
		return false
	end

	local _3 = _M._get_31_2(flow)
	local _2 = _C(21, "GetDistance", flow, _3, 0, false)
	local _1 = _2 <= 4

	if not _1 then
		return false
	end

	return true
end

function _M._get_25_1(flow)
	local _1 = _M._get_31_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

function _M._get_31_3(flow)
	local _0 = _C(24, "GetAoiEntityTableByLevel", flow, 0, 30, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(31, "__iterItem", v)

		if _M._get_23_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_31_2(flow)
	return flow:getCache(31, "__iterItem")
end

return _M
