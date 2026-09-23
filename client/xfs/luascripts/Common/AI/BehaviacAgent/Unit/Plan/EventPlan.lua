-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\Plan\\EventPlan.lua

local class = require("Core.Framework.Class")
local BaseEcologyPlan = require("Common.AI.BehaviacAgent.Unit.Plan.BaseEcologyPlan")
local AiConst = require("Common.Const.AiConst")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("EventPlan")
local ConditionUtils = require("Common.AICt.ConditionUtils")
local AIUtils = require("Common.Utils.AIUtils")
local TimerManager = require("Core.Timer.TimerManager")
local CallbackHandlerNoGC = require("Core.Common.CallbackHandlerNoGC")
local CTRConst = require("Common.AICt.CTRConst")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local PlanPool = require("Common.AI.BehaviacAgent.Unit.Plan.PlanPool")
local EventPlan = class.LightClass("EventPlan", BaseEcologyPlan)

function EventPlan:recycleInit(flow, rawData, behaviourID)
	self.rawData = rawData
	self.targetEntity = nil
	self.behaviourID = behaviourID
	self.flow = flow

	if not AIUtils.checkOpenBCOptimize() then
		function flow._finishedFunc()
			self:breakPlan()
		end
	else
		flow:setFinishFunc(self.breakPlan, self)
	end

	return true
end

function EventPlan:getPriority()
	return self.rawData.priority or 0
end

function EventPlan:initPlan(entity)
	if not entity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("event plan init error: entity is nil")
		end

		return false
	end

	self.targetEntity = entity

	if not AIUtils.checkOpenBCOptimize() then
		return not self.flow:checkIsFinished()
	else
		return not self.flow:isFinish()
	end
end

function EventPlan:tryRunPlan()
	if not AIUtils.checkOpenBCOptimize() then
		self.flow:setContinueFlag(true)
	else
		self.flow:setContinueFlag()
	end

	return true
end

function EventPlan:breakPlan()
	local tTargetEntity = self.targetEntity

	if tTargetEntity == nil then
		return
	end

	self.targetEntity = nil

	tTargetEntity:clearCurrentAIParmonPlan(self)
	TimerManager.addNextFrameCb(CallbackHandlerNoGC.new(self, self.destroy))

	local tPlanType = self:getPlanType()
	local tPlanId = self:getID()
	local flowFinishType = self:getFlowFinishType()

	tTargetEntity:postComponentMethod("onAIPlanFinish", tPlanType, tPlanId, flowFinishType)
	self.flow:dispose()

	self.flow = nil

	EventPlan.ReturnEventPlan(self)
end

function EventPlan:destroy()
	return
end

function EventPlan:getInterruptType()
	return self.rawData.interruptType or AiConst.AIBeInterruptedType.CanInterruptedByHighPriority
end

function EventPlan:checkAbortPlan()
	if not AIUtils.checkOpenBCOptimize() then
		return self.flow:checkInterruptable()
	else
		return self.flow:checkInterrupt()
	end
end

function EventPlan.GetEventPlan(flow, rawData, behaviourID)
	return PlanPool.getNewPlan(AiConst.ParmonPlanType.EventPlan, flow, rawData, behaviourID)
end

function EventPlan.ReturnEventPlan(plan)
	PlanPool.returnPlan(plan)
end

function EventPlan:getPlanType()
	return AiConst.ParmonPlanType.EventPlan
end

function EventPlan:getPlanTagList()
	return self.rawData.behavTag
end

function EventPlan:getID()
	return self.behaviourID
end

function EventPlan:getPlanCD()
	return self.rawData.coolDown
end

function EventPlan:isGroupBehav()
	return self.rawData.isGroupBehav == 1
end

function EventPlan:getFlowFinishType()
	if not AIUtils.checkOpenBCOptimize() then
		return self.flow and self.flow.__flowFinishType
	else
		return self.flow and self.flow.__finishType
	end
end

function EventPlan:tickCheckPlanInterrupt()
	if not AIUtils.checkOpenBCOptimize() then
		return self.flow and self.flow:checkInterruptable()
	else
		return self.flow and self.flow:checkInterrupt()
	end
end

function EventPlan:tickCheckPlanContinue()
	return self.flow and self.flow:checkCanContinue()
end

function EventPlan:tryFlowContinue()
	if not AIUtils.checkOpenBCOptimize() then
		return self.flow:continue()
	else
		return self.flow:executeContinue()
	end
end

return EventPlan
