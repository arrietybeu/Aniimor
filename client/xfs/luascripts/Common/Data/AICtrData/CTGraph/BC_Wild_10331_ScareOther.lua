-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10331_ScareOther.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6, value7, value8)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tAnimationKey", value1)
	agent:addSubTreeLocalParam("tAnimationTimeout", value2)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value3)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value4)
	agent:addSubTreeLocalParam("tTimelineTag", value5)
	agent:addSubTreeLocalParam("tNeedLoop", value6)
	agent:addSubTreeLocalParam("tAnimationPlayOnce", value7)
	agent:addSubTreeLocalParam("tEmojiBubbleMustPlayFull", value8)
	flow:setContinue(nodeId)

	return true
end

function _M.executeMessageTrigger(flow, eventName)
	if eventName == "Msg_NeedToScare" then
		return _M._to_48_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 12 then
		return _M._to_37_0(flow)
	end

	if nodeId == 37 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_12_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 12, 0, "IdleSpecial", 10, "Angry", 5, "", false, true, false)
end

function _M._to_37_0(flow)
	if not _B(flow, "PBT_CustomAnimation") then
		return
	end

	return _doBehaviourTail_0(flow, 37, 0, "Behav_Happy", 5, "Laugh", 5, "", false, false, false)
end

function _M._to_48_0(flow)
	local _1 = _M._get_39_3(flow)
	local _2 = not _1 or next(_1) == nil
	local _0 = not _2

	if _0 then
		return _M._to_55_0(flow)
	end
end

function _M._to_55_0(flow)
	flow:setActive()

	local _0 = _M._get_39_3(flow)

	for _, v in ipairs(_0) do
		local _1 = flow:getMessageContext()

		_1.sourceActorId = flow.__actorId

		flow:sendMessage(v, "Msg_NeedToRunAway", _1)
	end

	return _M._to_12_0(flow)
end

function _M._get_39_2(flow)
	return flow:getCache(39, "__iterItem")
end

function _M._get_39_3(flow)
	local _0 = _C(47, "GetAoiEntityTableByLevel", flow, 0, 10, 8)
	local _1 = flow:getTempList()

	for k, v in pairs(_0) do
		flow:setCache(39, "__iterItem", v)

		if _M._get_40_2(flow) then
			_1[#_1 + 1] = v
		end
	end

	return _1
end

function _M._get_40_2(flow)
	local _0 = _M._get_39_2(flow)

	return _C(40, "HasEntityTag", flow, _0, "TE_Wild_10231_GetClose")
end

return _M
