-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_11021103_BornToJump.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_1_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 1 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_1_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_11_1(flow)

	if _0 then
		flow:setActive()
		_C(1, "DoBehaviour", flow, "PBT_CustomAnimation")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "Behav_Jump")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 0)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
		flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", true)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", true)
		flow:setContinue(1)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_3_1(flow)
	local _0 = _M._get_7_3(flow)

	return _C(3, "SelectOneByRandom", flow, _0)
end

function _M._get_5_2(flow)
	local _1 = _M._get_7_2(flow)
	local _0 = _C(6, "GetDistance", flow, _1, 0, false)

	return _0 <= 20
end

function _M._get_7_3(flow)
	local _0 = _C(8, "GetAoiEntityTableByLevel", flow, 0, 30, 2)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(7, "__iterItem", v)

		if _M._get_5_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_7_2(flow)
	return flow:getCache(7, "__iterItem")
end

function _M._get_11_1(flow)
	local _1 = _M._get_7_3(flow)
	local _0 = not _1 or next(_1) == nil

	return not _0
end

return _M
