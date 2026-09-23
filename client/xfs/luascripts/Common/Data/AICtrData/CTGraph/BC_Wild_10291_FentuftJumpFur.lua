-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10291_FentuftJumpFur.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _B = CTHelper.BeginBehaviourV2

local function _doBehaviourTail_0(flow, nodeId, value0, value1, value2, value3, value4, value5, value6)
	local agent = flow.__agent

	agent:clearSubTreeLocalParams()
	agent:addSubTreeLocalParam("tWaitTime", value0)
	agent:addSubTreeLocalParam("tSkillId", value1)
	agent:addSubTreeLocalParam("tSkillTargetActorId", value2)
	agent:addSubTreeLocalParam("tEmojiBubbleKey", value3)
	agent:addSubTreeLocalParam("tEmojiBubbleTimeout", value4)
	agent:addSubTreeLocalParam("tRaycastOpen", value5)
	agent:addSubTreeLocalParam("tCastAbilitySource", value6)
	flow:setContinue(nodeId)

	return true
end

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerCharge1" then
		return _M._to_25_0(flow)
	end

	if eventName == "LevelMsgTriggerCharge2" then
		return _M._to_26_0(flow)
	end

	if eventName == "LevelMsgTriggerJump1" then
		return _M._to_31_0(flow)
	end

	if eventName == "LevelMsgTriggerJump2" then
		return _M._to_33_0(flow)
	end

	if eventName == "LevelMsgTriggerBack1" then
		return _M._to_38_0(flow)
	end

	if eventName == "LevelMsgTriggerBack2" then
		return _M._to_39_0(flow)
	end

	if eventName == "LevelMsgTriggerBigJump1" then
		return _M._to_42_0(flow)
	end

	if eventName == "LevelMsgTriggerBigGo1" then
		return _M._to_45_0(flow)
	end

	if eventName == "LevelMsgTriggerBigJump2" then
		return _M._to_47_0(flow)
	end

	if eventName == "LevelMsgTriggerBigGo2" then
		return _M._to_49_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 25 then
		return true
	end

	if nodeId == 26 then
		return true
	end

	if nodeId == 31 then
		return true
	end

	if nodeId == 33 then
		return true
	end

	if nodeId == 38 then
		return _M._to_40_0(flow)
	end

	if nodeId == 39 then
		return _M._to_41_0(flow)
	end

	if nodeId == 40 then
		return true
	end

	if nodeId == 41 then
		return true
	end

	if nodeId == 42 then
		return true
	end

	if nodeId == 45 then
		return true
	end

	if nodeId == 47 then
		return true
	end

	if nodeId == 49 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_25_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _C(27, "GetActorId", flow, 89184171)

	return _doBehaviourTail_0(flow, 25, 0, 12910200, _0, "Happy", 2, false, 0)
end

function _M._to_26_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _C(28, "GetActorId", flow, 89184169)

	return _doBehaviourTail_0(flow, 26, 0, 12910200, _0, "Happy", 2, false, 0)
end

function _M._to_31_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 89224244, 1, nil) then
		flow:setContinue(31)

		return true
	end
end

function _M._to_33_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 89224243, 1, nil) then
		flow:setContinue(33)

		return true
	end
end

function _M._to_38_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 90876715, 1, nil) then
		flow:setContinue(38)

		return true
	end
end

function _M._to_39_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 90876719, 1, nil) then
		flow:setContinue(39)

		return true
	end
end

function _M._to_40_0(flow)
	if not _B(flow, "PBT_TriggerBlueprint") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEventName", "isBack1")
	flow:setContinue(40)

	return true
end

function _M._to_41_0(flow)
	if not _B(flow, "PBT_TriggerBlueprint") then
		return
	end

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tEventName", "isBack2")
	flow:setContinue(41)

	return true
end

function _M._to_42_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 91017133, 1, nil) then
		flow:setContinue(42)

		return true
	end
end

function _M._to_45_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 91017339, 1, nil) then
		flow:setContinue(45)

		return true
	end
end

function _M._to_47_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 91017132, 1, nil) then
		flow:setContinue(47)

		return true
	end
end

function _M._to_49_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 91017343, 1, nil) then
		flow:setContinue(49)

		return true
	end
end

return _M
