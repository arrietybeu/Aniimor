-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\IPuppetStateMachineComponent.lua

local Class = require("Core.Framework.Class")
local IBaseStateMachineComponent = require("Common.AI.BehaviacAgent.Unit.IBaseStateMachineComponent")
local Utils = require("Common.Utils.Utils")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local AIUtils = require("Common.Utils.AIUtils")
local AIBaseMethodUtils = require("Common.AI.BehaviacAgent.Unit.AIBaseMethodUtils")
local EBTRootState = BaseEnum.EBTRootState
local IPuppetStateMachineComponent = Class.Component("IPuppetStateMachineComponent", IBaseStateMachineComponent)

function IPuppetStateMachineComponent:onResumeAgent()
	AIUtils.resetRootState(self.ent)
end

function IPuppetStateMachineComponent:onStartAgent()
	AIUtils.resetRootState(self.ent)
end

function IPuppetStateMachineComponent:OVERRIDE_resetRootState(fromState)
	if fromState and fromState ~= self:getRootState() then
		return false
	end

	if self.ent.hasBornState then
		return self:enterBorn()
	end

	return self:enterIdle()
end

function IPuppetStateMachineComponent:OVERRIDE_enterIdle()
	return self:tryChangeRootState(EBTRootState.ST_Root_Idle, false, true)
end

function IPuppetStateMachineComponent:OVERRIDE_enterCombat(targetActorId)
	if Utils.isVirtualEntity(self.ent) then
		return self:tryChangeRootState(EBTRootState.ST_Root_Combat)
	else
		local combatActorId = targetActorId

		if self.ent:isInCombat() == false then
			AIBaseMethodUtils.Base_AddSelfHate(self.ent, combatActorId)

			return false
		else
			return self:tryChangeRootState(EBTRootState.ST_Root_Combat)
		end
	end
end

function IPuppetStateMachineComponent:OVERRIDE_exitCombat()
	return
end

function IPuppetStateMachineComponent:enterGoHome()
	return self:tryChangeRootState(EBTRootState.ST_Root_GoHome)
end

function IPuppetStateMachineComponent:enterRecruit(masterActorId)
	return self:tryChangeRootState(EBTRootState.ST_Root_Recruit)
end

function IPuppetStateMachineComponent:enterAlert(forceChange)
	return self:tryChangeRootState(EBTRootState.ST_Root_Alert, nil, forceChange)
end

function IPuppetStateMachineComponent:enterSensed(forceChange)
	return self:tryChangeRootState(EBTRootState.ST_Root_Sensed, nil, forceChange)
end

return IPuppetStateMachineComponent
