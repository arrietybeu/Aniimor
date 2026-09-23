-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10501_AwakeBySnore.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_41_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 18 then
		return _M._to_36_0(flow)
	end

	if nodeId == 36 then
		return _M._to_37_0(flow)
	end

	if nodeId == 37 then
		return true
	end

	if nodeId == 41 then
		return _M._to_47_0(flow)
	end

	if nodeId == 47 then
		return _M._to_18_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_18_0(flow)
	if not _B(flow, "PBT_AddBuff") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tBuffId", 2150102)
	flow.__agent:addSubTreeLocalParam("duration", 7)
	flow:setContinue(18)

	return true
end

function _M._to_36_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 1)
	flow:setContinue(36)

	return true
end

function _M._to_37_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tAnimationKey", "Idle_Sp")
	flow.__agent:addSubTreeLocalParam("tAnimationTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 5)
	flow.__agent:addSubTreeLocalParam("tTimelineTag", "")
	flow.__agent:addSubTreeLocalParam("tNeedLoop", false)
	flow.__agent:addSubTreeLocalParam("tAnimationPlayOnce", false)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", false)
	flow:setContinue(37)

	return true
end

function _M._to_41_0(flow)
	if flow.__isAdditive then
		return
	end

	local _0 = _M._get_50_2(flow)

	if _0 then
		flow:setActive()
		_C(41, "DoBehaviour", flow, "PBT_Com_Node_Wait")

		local _1 = _C(42, "RandomInteger", flow, 0, 2)

		flow.__agent:clearSubTreeLocalParams()
		flow.__agent:addSubTreeLocalParam("tWaitTime", _1)
		flow:setContinue(41)

		return true
	else
		flow:setActiveFail()
	end
end

function _M._to_47_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("firstDialogueId", 70008791)
	flow.__agent:addSubTreeLocalParam("lastDialogueId", 70008794)
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow:setContinue(47)

	return true
end

function _M._get_8_2(flow)
	return flow:getCache(8, "__iterItem")
end

function _M._get_8_3(flow)
	local _0 = _C(12, "GetAoiEntityTableByLevel", flow, 0, 10, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(8, "__iterItem", v)

		if _M._get_9_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_9_2(flow)
	local _0 = _M._get_8_2(flow)

	return _C(9, "HasEntityTag", flow, _0, "TE_Wild_10501_Snore")
end

function _M._get_50_2(flow)
	local _2 = _M._get_8_3(flow)
	local _3 = not _2 or next(_2) == nil
	local _0 = not _3

	if not _0 then
		return false
	end

	local _4 = _C(44, "RandomInteger", flow, 0, 1)
	local _1 = _4 > 0.3

	if not _1 then
		return false
	end

	return true
end

return _M
