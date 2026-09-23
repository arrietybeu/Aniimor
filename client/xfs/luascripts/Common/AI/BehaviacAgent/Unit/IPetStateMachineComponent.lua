-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\IPetStateMachineComponent.lua

local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local Const = require("Common.Const.Const")
local puppetStateConflictData = require("Data.puppet_state_conflict_data")
local Utils = require("Common.Utils.Utils")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local enums = require("Common.AI.Behaviac.Enums")
local AiConst = require("Common.Const.AiConst")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local AIUtils = require("Common.Utils.AIUtils")
local EBTRootState = BaseEnum.EBTRootState
local IBaseStateMachineComponent = require("Common.AI.BehaviacAgent.Unit.IBaseStateMachineComponent")
local IPetStateMachineComponent = Class.Component("IPetStateMachineComponent", IBaseStateMachineComponent)

function IPetStateMachineComponent:onResumeAgent()
	AIUtils.resetRootState(self.ent)
end

function IPetStateMachineComponent:onStartAgent()
	AIUtils.resetRootState(self.ent)
end

function IPetStateMachineComponent:OVERRIDE_resetRootState(fromRootState)
	if fromRootState and fromRootState ~= self:getRootState() then
		return false
	end

	return self:enterIdle(true)
end

function IPetStateMachineComponent:OVERRIDE_enterIdle(force)
	return self:tryChangeRootState(EBTRootState.ST_Root_Idle, false, force)
end

function IPetStateMachineComponent:OVERRIDE_enterCombat(targetActorId)
	if not targetActorId or targetActorId == nil then
		targetActorId = self.ent:getAttackTargetActorId()
	end

	AIUtils.attackTarget(self.ent, targetActorId)

	if self:getRootState() == EBTRootState.ST_Root_Combat then
		return true
	end

	return self:tryChangeRootState(EBTRootState.ST_Root_Combat, false, true, true)
end

function IPetStateMachineComponent:OVERRIDE_exitCombat()
	AIUtils.releaseAttackTarget(self.ent)
end

function IPetStateMachineComponent:enterAfk()
	return self:tryChangeRootState(EBTRootState.ST_Root_Afk)
end

return IPetStateMachineComponent
