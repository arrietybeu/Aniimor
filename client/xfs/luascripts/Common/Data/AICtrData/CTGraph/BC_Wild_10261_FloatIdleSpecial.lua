-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10261_FloatIdleSpecial.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_131_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 131 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_131_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_149_4(flow)

	if _0 then
		flow:setActive()
		_C(131, "DoBehaviour", flow, "PBT_CustomAnimation")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "Float_IdleSpecial")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 0)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 0)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
		flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
		flow:setContinue(131)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_149_4(flow)
	local _8 = _M._get_150_0(flow)
	local _0 = _C(163, "IsInCharState", flow, _8, 1, 21)

	if not _0 then
		return false
	end

	local _4 = _M._get_150_0(flow)
	local _5 = _C(151, "GetAnimTagDuration", flow, _4)
	local _1 = _5 > 4

	if not _1 then
		return false
	end

	local _6 = _C(154, "RandomInteger", flow, 1, 10)
	local _2 = _6 < 5

	if not _2 then
		return false
	end

	local _7 = _M._get_150_0(flow)
	local _3 = _C(161, "IsChildOfCharState", flow, _7, "FLYHOVER")

	if not _3 then
		return false
	end

	return true
end

function _M._get_150_0(flow)
	return _C(150, "GetSelfId", flow)
end

return _M
