-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\Plan\\PatrolPlanFsm\\MovingBehaviorState.lua

local Class = require("Core.Framework.Class")
local State = require("Common.Container.FSM.State")
local BehaviorTreePlanUtils = require("Common.Utils.BehaviorTreePlanUtils")
local lume = require("Core.Common.lume")
local PATROL_STATE = require("Common.Const.AiConst").PATROL_STATE
local MovingBehaviorState = Class.LiteClass("MovingBehaviorState", State)
local MOVING_BEHAVIOR = "movingBehaviorTreeTemplate"

function MovingBehaviorState:onEnter(controller, oldState)
	MovingBehaviorState.super.onEnter(self, controller, oldState)

	local patrolPlan = controller.patrolPlan
	local templateTree = patrolPlan.patrolData.routeData.wayPoints[patrolPlan.patrolData.routeIndex][MOVING_BEHAVIOR]

	self.x_patrolBehaviorCount, self.x_patrolBehaviorIndex = patrolPlan:getPatrolControlBehaviorLoopTime(templateTree)
	self.x_patrolBehaviorEndIndex = self.x_patrolBehaviorIndex + self.x_patrolBehaviorCount - 1

	self:executeBehavior(controller)
end

function MovingBehaviorState:onRun(controller)
	MovingBehaviorState.super.onRun(self, controller)
	self:executeBehavior(controller)
end

function MovingBehaviorState:onExit(controller, nextState)
	MovingBehaviorState.super.onExit(self, controller, nextState)

	self.x_patrolBehaviorCount = nil
	self.x_patrolBehaviorIndex = nil
	self.x_patrolBehaviorEndIndex = nil
end

function MovingBehaviorState:executeBehavior(controller)
	local patrolPlan = controller.patrolPlan

	while self.x_patrolBehaviorCount > 0 and self.x_patrolBehaviorEndIndex >= self.x_patrolBehaviorIndex do
		local templateTree = patrolPlan.patrolData.routeData.wayPoints[patrolPlan.patrolData.routeIndex][MOVING_BEHAVIOR]
		local behaviorTreeRawData = templateTree.behaviors[self.x_patrolBehaviorIndex]
		local ret = BehaviorTreePlanUtils.startEcologyPlan(behaviorTreeRawData, patrolPlan.targetEnt.agent)

		self.x_patrolBehaviorIndex = self.x_patrolBehaviorIndex + 1

		if ret then
			return
		end
	end

	controller:transitionTo(PATROL_STATE.IntermittentPatrol)
end

return MovingBehaviorState
