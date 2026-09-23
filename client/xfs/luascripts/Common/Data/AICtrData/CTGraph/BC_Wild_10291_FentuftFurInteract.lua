-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\CTGraph\\BC_Wild_10291_FentuftFurInteract.lua

local CTHelper = require("Common.AI.ConditionTrigger.CTHelper")
local _M = {}
local _C = CTHelper.SafeCall
local _P = CTHelper.DoPatrolBehavior
local _B = CTHelper.BeginBehaviourV2

function _M.executeEventTrigger(flow, eventName)
	if eventName == "LevelMsgTriggerActivate" then
		return _M._to_64_0(flow)
	end

	if eventName == "LevelMsgTriggerOff1" then
		return _M._to_65_0(flow)
	end

	if eventName == "LevelMsgTriggerOff2" then
		return _M._to_66_0(flow)
	end

	if eventName == "LevelMsgTriggerOff3" then
		return _M._to_67_0(flow)
	end

	if eventName == "LevelMsgTriggerJump1" then
		return _M._to_70_0(flow)
	end

	if eventName == "LevelMsgTriggerJump2" then
		return _M._to_69_0(flow)
	end

	if eventName == "LevelMsgTriggerJump3" then
		return _M._to_68_0(flow)
	end
end

function _M.executeContinue(flow, nodeId)
	if nodeId == 1 then
		return true
	end

	if nodeId == 64 then
		return _M._to_1_0(flow)
	end

	if nodeId == 65 then
		return true
	end

	if nodeId == 66 then
		return true
	end

	if nodeId == 67 then
		return true
	end

	if nodeId == 68 then
		return true
	end

	if nodeId == 69 then
		return true
	end

	if nodeId == 70 then
		return true
	end
end

function _M.checkInterrupt(flow, nodeId)
	return
end

function _M._to_1_0(flow)
	if not _B(flow, "PBT_CastSkill") then
		return
	end

	local _0 = _C(3, "GetActorId", flow, 83712219)

	flow.__agent:clearSubTreeLocalParams()
	flow.__agent:addSubTreeLocalParam("tWaitTime", 0)
	flow.__agent:addSubTreeLocalParam("tSkillId", 12910200)
	flow.__agent:addSubTreeLocalParam("tSkillTargetActorId", _0)
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleKey", "Happy")
	flow.__agent:addSubTreeLocalParam("tEmojiBubbleTimeout", 3)
	flow.__agent:addSubTreeLocalParam("tRaycastOpen", false)
	flow.__agent:addSubTreeLocalParam("tCastAbilitySource", 0)
	flow:setContinue(1)

	return true
end

function _M._to_64_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 83813172, 1, nil) then
		flow:setContinue(64)

		return true
	end
end

function _M._to_65_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 83809786, 1, nil) then
		flow:setContinue(65)

		return true
	end
end

function _M._to_66_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 83812819, 1, nil) then
		flow:setContinue(66)

		return true
	end
end

function _M._to_67_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 83812931, 1, nil) then
		flow:setContinue(67)

		return true
	end
end

function _M._to_68_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 83813075, 1, nil) then
		flow:setContinue(68)

		return true
	end
end

function _M._to_69_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 83813071, 1, nil) then
		flow:setContinue(69)

		return true
	end
end

function _M._to_70_0(flow)
	if flow.__isAdditive then
		return
	end

	flow:setActive()

	if _P(flow, 1, 83813069, 1, nil) then
		flow:setContinue(70)

		return true
	end
end

return _M
