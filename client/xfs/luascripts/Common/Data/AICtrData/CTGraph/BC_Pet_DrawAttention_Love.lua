-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_DrawAttention_Love.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_159_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 159 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_159_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_132_4(flow)

	if _0 then
		flow:setActive()
		_C(159, "DoBehaviour", flow, "PBT_Com_Love")

		local _1 = _M._get_155_1(flow)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "Behav_Love")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
		flow.__agent:addSubTreeLocalParam("tTgtId", _1)
		flow.__agent:addSubTreeLocalParam("tTargetAtYawDegree", 0)
		flow:setContinue(159)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_132_4(flow)
	local _6 = _M._get_148_0(flow)
	local _0 = _C(161, "IsInCharState", flow, _6, 1, 4)

	if not _0 then
		return false
	end

	local _4 = _M._get_148_0(flow)
	local _3 = _C(147, "GetAnimTagDuration", flow, _4)
	local _1 = _3 > 4

	if not _1 then
		return false
	end

	local _5 = _C(149, "RandomInteger", flow, 1, 10)
	local _2 = _5 < 2

	if not _2 then
		return false
	end

	if false then
		return false
	end

	return true
end

function _M._get_148_0(flow)
	return _C(148, "GetSelfId", flow)
end

function _M._get_155_1(flow)
	local _0 = _C(154, "GetAoiEntityTableByLevel", flow, 0, 30, 2)

	return _C(155, "SelectOneByRandom", flow, _0)
end

return _M
