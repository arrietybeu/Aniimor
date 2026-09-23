-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Pet_Accompany_MoveClose.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_89_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 89 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_89_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_99_4(flow)

	if _0 then
		flow:setActive()
		_C(89, "DoBehaviour", flow, "PBT_CustomAnimation")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "AI_IdleSpecial02")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 0)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 0)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
		flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
		flow:setContinue(89)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_99_4(flow)
	local _8 = _M._get_100_0(flow)
	local _0 = _C(109, "IsInCharState", flow, _8, 1, 4)

	if not _0 then
		return false
	end

	local _4 = _M._get_100_0(flow)
	local _5 = _C(101, "GetAnimTagDuration", flow, _4)
	local _1 = _5 > 4

	if not _1 then
		return false
	end

	local _7 = _C(106, "GetAnimTagDuration", flow, 0)
	local _2 = _7 > 5

	if not _2 then
		return false
	end

	local _6 = _C(104, "RandomInteger", flow, 1, 10)
	local _3 = _6 < 4

	if not _3 then
		return false
	end

	return true
end

function _M._get_100_0(flow)
	return _C(100, "GetSelfId", flow)
end

return _M
