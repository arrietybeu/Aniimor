-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10381_shankefishdizzy.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "OnLandStateEnterTrigger" then
		return _M._to_3_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 19 then
		return _M._to_9_0(flow)
	end

	if nodeId == 21 then
		return _M._to_19_0(flow)
	end

	if nodeId == 23 then
		return _M._to_21_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_3_0(flow)
	local _1 = _C(1, "GetSelfId", flow)
	local _2 = _C(0, "GetTargetBuffLayerCount", flow, _1, 11154)
	local _0 = _2 == 1

	if _0 then
		return _M._to_23_0(flow)
	end
end

function _M._to_9_0(flow)
	flow:setActive()
	_A(flow, "RemoveBuff", 0, 11154)

	return true
end

function _M._to_19_0(flow)
	if not _B(flow, "PBT_Wild_10501_Dialogue") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("firstDialogueId", 1039178)
	flow.__agent:addSubTreeLocalParam("lastDialogueId", 1039178)
	flow.__agent:addSubTreeLocalParam("tWaitTime", 3)
	flow:setContinue(19)

	return true
end

function _M._to_21_0(flow)
	if not _B(flow, "PBT_ShowEmojiBubble") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Dizzy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 3)
	flow:setContinue(21)

	return true
end

function _M._to_23_0(flow)
	if not _B(flow, "PBT_Com_Node_Wait") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 1)
	flow:setContinue(23)

	return true
end

return _M
