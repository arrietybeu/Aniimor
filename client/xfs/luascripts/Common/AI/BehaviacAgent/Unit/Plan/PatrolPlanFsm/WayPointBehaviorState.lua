-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\Plan\\PatrolPlanFsm\\WayPointBehaviorState.lua

local Class = require("Core.Framework.Class")
local State = require("Common.Container.FSM.State")
local PATROL_STATE = require("Common.Const.AiConst").PATROL_STATE
local AiConst = require("Common.Const.AiConst")
local BehaviorTreePlanUtils = require("Common.Utils.BehaviorTreePlanUtils")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local routeDefaultValueData = require("Common.Data.Scene.route_default_value_data")
local WAY_POINT_DEFAULTS = routeDefaultValueData and routeDefaultValueData.wayPoints or {}
local WayPointBehaviorState = Class.LiteClass("WayPointBehaviorState", State)
local WAY_BEHAVIOR = "behaviorTreeTemplate"
local WAY_POSITION = "position"

function WayPointBehaviorState:onEnter(controller, oldState)
	WayPointBehaviorState.super.onEnter(self, controller, oldState)

	local patrolPlan = controller.patrolPlan
	local wayPointInfo = patrolPlan.patrolData.routeData.wayPoints[patrolPlan.patrolData.routeIndex]
	local templateTree = wayPointInfo[WAY_BEHAVIOR]

	self.x_patrolBehaviorCount, self.x_patrolBehaviorIndex = patrolPlan:getPatrolControlBehaviorLoopTime(templateTree)
	self.x_patrolBehaviorEndIndex = self.x_patrolBehaviorIndex + self.x_patrolBehaviorCount - 1
	self.x_firstIn = true
	self.x_inexecutionAction = wayPointInfo.inexecutionAction or WAY_POINT_DEFAULTS.inexecutionAction

	self:executeBehavior(controller)
end

function WayPointBehaviorState:onRun(controller)
	WayPointBehaviorState.super.onRun(self, controller)
	self:executeBehavior(controller)
end

function WayPointBehaviorState:onExit(controller, nextState)
	WayPointBehaviorState.super.onExit(self, controller, nextState)

	self.x_patrolBehaviorCount = nil
	self.x_patrolBehaviorIndex = nil
	self.x_patrolBehaviorEndIndex = nil
	self.x_firstIn = nil
	self.x_inexecutionAction = nil
end

function WayPointBehaviorState:executeBehavior(controller)
	local patrolPlan = controller.patrolPlan

	while not self.x_inexecutionAction and self.x_patrolBehaviorCount > 0 and self.x_patrolBehaviorEndIndex >= self.x_patrolBehaviorIndex do
		local wayPointData = patrolPlan.patrolData.routeData.wayPoints[patrolPlan.patrolData.routeIndex]
		local wayPos = wayPointData[WAY_POSITION]
		local myPos = patrolPlan.targetEnt:getPosition()

		if self.x_firstIn and AIControllerUtils.isInLocomotion(controller.patrolPlan.targetEnt) and math.abs(myPos[2] - wayPos[2]) > patrolPlan.targetEnt:getHeight() then
			controller:transitionTo(PATROL_STATE.Disable)

			return
		end

		self.x_firstIn = false

		local templateTree = wayPointData[WAY_BEHAVIOR]
		local behaviorTreeRawData = templateTree.behaviors[self.x_patrolBehaviorIndex]
		local ret = BehaviorTreePlanUtils.startEcologyPlan(behaviorTreeRawData, patrolPlan.targetEnt.agent)

		self.x_patrolBehaviorIndex = self.x_patrolBehaviorIndex + 1

		if ret then
			return
		end
	end

	patrolPlan:updateRouteIndex()

	if not patrolPlan:isActive() then
		controller:transitionTo(PATROL_STATE.Disable)

		return
	end

	local wayPointData = patrolPlan.patrolData.routeData.wayPoints[patrolPlan.patrolData.routeIndex]
	local tMovingBehaviorTreeData = wayPointData.movingBehaviorTreeTemplate

	if tMovingBehaviorTreeData and tMovingBehaviorTreeData.behaviors and #tMovingBehaviorTreeData.behaviors > 0 then
		controller:transitionTo(PATROL_STATE.IntermittentPatrol)
	else
		controller:transitionTo(PATROL_STATE.Patrol)
	end
end

return WayPointBehaviorState
