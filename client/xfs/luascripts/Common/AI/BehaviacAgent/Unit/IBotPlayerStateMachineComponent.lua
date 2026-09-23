-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\IBotPlayerStateMachineComponent.lua

local Class = require("Core.Framework.Class")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local AIUtils = require("Common.Utils.AIUtils")
local AIBaseMethodUtils = require("Common.AI.BehaviacAgent.Unit.AIBaseMethodUtils")
local EBTRootState = BaseEnum.EBTRootState
local IBaseStateMachineComponent = require("Common.AI.BehaviacAgent.Unit.IBaseStateMachineComponent")
local IBotPlayerStateMachineComponent = Class.Component("IBotPlayerStateMachineComponent", IBaseStateMachineComponent)

function IBotPlayerStateMachineComponent:OVERRIDE_enterCombat(targetActorId)
	local combatActorId = targetActorId

	if self.ent:isInCombat() == false then
		AIBaseMethodUtils.Base_AddSelfHate(self.ent, combatActorId)

		return false
	else
		return self:tryChangeRootState(EBTRootState.ST_Root_Combat)
	end
end

function IBotPlayerStateMachineComponent:onResumeAgent()
	AIUtils.resetRootState(self.ent)
end

function IBotPlayerStateMachineComponent:onStartAgent()
	AIUtils.resetRootState(self.ent)
end

return IBotPlayerStateMachineComponent
