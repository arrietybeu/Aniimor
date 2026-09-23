-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\Plan\\BornEcologyPlan.lua

local Class = require("Core.Framework.Class")
local BaseEcologyPlan = require("Common.AI.BehaviacAgent.Unit.Plan.BaseEcologyPlan")
local BehaviorTreePlanUtils = require("Common.Utils.BehaviorTreePlanUtils")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local AiConst = require("Common.Const.AiConst")
local BornEcologyPlan = Class.LightClass("BornEcologyPlan", BaseEcologyPlan)

function BornEcologyPlan:ctor(rawData)
	self.planLoopTime = 1
	self.priority = rawData.priority or 500
	self.rawData = rawData
end

function BornEcologyPlan:getPriority()
	return self.priority
end

function BornEcologyPlan:initPlan(entity)
	if entity:isBTPaused() then
		return false
	end

	local ret = BehaviorTreePlanUtils.startEcologyPlan(self.rawData.behaviorStateKey, entity.agent)

	if ret then
		self.targetEntity = entity
	end

	return self:tryRunPlan()
end

function BornEcologyPlan:tryRunPlan()
	if self.planLoopTime > 0 then
		self.planLoopTime = self.planLoopTime - 1

		return true
	end

	self:breakPlan()

	return false
end

function BornEcologyPlan:breakPlan()
	local tTargetEntity = self.targetEntity

	if tTargetEntity then
		self.targetEntity = nil

		tTargetEntity:clearCurrentAIParmonPlan(self)
		tTargetEntity:exitAIBornPlan()
	end
end

function BornEcologyPlan:getPlanType()
	return AiConst.ParmonPlanType.BornPlan
end

function BornEcologyPlan:getID()
	return self.rawData.staticId
end

return BornEcologyPlan
