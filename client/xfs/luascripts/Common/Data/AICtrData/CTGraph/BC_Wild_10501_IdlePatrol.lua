-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10501_IdlePatrol.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _A = CTHelper.DoAction
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("firstDialogueId", value0)
	agent:addSubTreeLocalParam("lastDialogueId", value1)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "IdleMsgTrigger" then
		return _M._to_26_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 28 then
		return true
	end

	if nodeId == 29 then
		return true
	end

	if nodeId == 81 then
		return _M._to_28_0(flow)
	end

	if nodeId == 82 then
		return _M._to_29_0(flow)
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_26_0(flow)
	local _2 = _M._get_25_1(flow)
	local _0 = not _2

	if _0 then
		flow:setActive()
		_A(flow, "SetVisionAreaOverride", "visionAreaDefault")

		return _M._to_81_0(flow)
	end

	local _1 = _M._get_25_1(flow)

	if _1 then
		flow:setActive()
		_A(flow, "SetVisionAreaOverride", "visionAreaMid")

		return _M._to_82_0(flow)
	end
end

function _M._to_28_0(flow)
	if not _B(flow, "PBT_Behav_Com_IdlePatrol") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("SpeedRateType", 0)
	flow.__agent:addSubTreeLocalParam("Speed", 1)
	flow:setContinue(28)

	return true
end

function _M._to_29_0(flow)
	if not _B(flow, "PBT_Behav_Com_IdlePatrol") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("SpeedRateType", 2)
	flow.__agent:addSubTreeLocalParam("Speed", 4)
	flow:setContinue(29)

	return true
end

function _M._to_81_0(flow)
	if not _B(flow, "PBT_Wild_10501_DreamDialogue") then
		return
	end

	return _doBehaviourTail_0(flow, 81, 70008552, 70008560)
end

function _M._to_82_0(flow)
	if not _B(flow, "PBT_Wild_10501_DreamDialogue") then
		return
	end

	return _doBehaviourTail_0(flow, 82, 70008547, 70008551)
end

function _M._get_25_1(flow)
	return _C(25, "CheckHasEntityTag", flow, 0, "TE_Wild_10501_Rage")
end

return _M
