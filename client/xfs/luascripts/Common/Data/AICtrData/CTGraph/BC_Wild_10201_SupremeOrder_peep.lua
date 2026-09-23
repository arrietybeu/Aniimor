-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10201_SupremeOrder_peep.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall

function _M.executeTickLodTrigger(flow)
	return _M._to_155_0(flow)
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 155 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	if nodeId == 155 then
		return _M._get_180_1(flow)
	end
end

function _M._to_155_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_181_1(flow)
	local _1 = _M.checkInterrupt(flow, 155)

	if _0 and not _1 then
		flow:setActive()
		_C(155, "DoBehaviour", flow, "PBT_CustomAnimation")
		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
		flow.__agent:addSubTreeLocalParam("tAnimationKey", "Behav_Alert")
		flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 99999)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
		flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
		flow.__agent:addSubTreeLocalParam("tNeedLoop", true)
		flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
		flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
		flow:setContinue(155)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._get_157_2(flow)
	return flow:getCache(157, "__iterItem")
end

function _M._get_157_3(flow)
	local _0 = _C(172, "GetAoiEntityTableByLevel", flow, 0, 50, 256)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(157, "__iterItem", v)

		if _M._get_179_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_179_2(flow)
	local _3 = _M._get_157_2(flow)
	local _4 = _C(177, "GetDistance", flow, _3, 0, false)
	local _0 = _4 < 6

	if not _0 then
		return false
	end

	local _2 = _M._get_157_2(flow)
	local _1 = _C(159, "HasEntityTag", flow, _2, "TE_Env_UniversalMark_A")

	if not _1 then
		return false
	end

	return true
end

function _M._get_180_1(flow)
	local _0 = _M._get_157_3(flow)

	return not _0 or next(_0) == nil
end

function _M._get_181_1(flow)
	local _0 = _M._get_180_1(flow)

	return not _0
end

return _M
