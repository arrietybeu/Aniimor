-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Npc_Common_ActivateLoopState.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "NpcStatusChangeTrigger" then
		return _M._to_21_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 28 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_21_0(flow)
	local _2 = _M._get_31_3(flow)
	local _1 = not _2 or next(_2) == nil
	local _0 = not _1

	if _0 then
		return _M._to_28_0(flow)
	end
end

function _M._to_28_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	local _0 = _M._get_25_2(flow)
	local _1 = _M._get_27_2(flow)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", _0)
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", _1)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", true)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(28)

	return true
end

function _M._get_17_2(flow)
	local _0 = _M._get_31_3(flow)

	if _0 == nil then
		return
	end

	local _1, _2, _3

	for _, v in ipairs(_0) do
		flow:setCache(17, "__iterItem", v)

		_1 = _M._get_18_2(flow)

		if _3 == nil then
			_2, _3 = v, _1
		end

		if _3 < _1 then
			_2, _3 = v, _1
		end
	end

	return _2
end

function _M._get_18_2(flow)
	local _0 = flow:getCache(17, "__iterItem")

	return _C(18, "GetTableValueByKey", flow, _0, "priority")
end

function _M._get_25_2(flow)
	local _1 = _M._get_17_2(flow)
	local _0 = _C(24, "GetTableValueByKey", flow, _1, "behavParams")

	return _C(25, "GetTableValueByKey", flow, _0, 1)
end

function _M._get_27_2(flow)
	local _1 = _M._get_17_2(flow)
	local _0 = _C(26, "GetTableValueByKey", flow, _1, "behavParams")

	return _C(27, "GetTableValueByKey", flow, _0, 2)
end

function _M._get_31_3(flow)
	local _0 = flow:getSubMacro("BCM_Npc_GetRunningStatus")
	local _1 = _C(32, "GetStaticId", flow, 0)

	_0:setContextValue("behavName", "ActivateLoopState")
	_0:setContextValue("staticId", _1)
	_0:setContextValue("status", 1)

	local _2 = _0:getMacroValue("resList")

	flow:clearSubMacro(_0)

	return _2
end

return _M
