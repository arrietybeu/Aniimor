-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\Plan\\PatrolPlanFsm\\JumpState.lua

local Class = require("Core.Framework.Class")
local State = require("Common.Container.FSM.State")
local AIUtils = require("Common.Utils.AIUtils")
local AiConst = require("Common.Const.AiConst")
local PlanPool = require("Common.AI.BehaviacAgent.Unit.Plan.PlanPool")
local PATROL_STATE = AiConst.PATROL_STATE
local TablePool = require("Common.Container.TablePool")
local BehaviorTreePlanUtils = require("Common.Utils.BehaviorTreePlanUtils")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local routeDefaultValueData = require("Common.Data.Scene.route_default_value_data")
local WAY_POINT_DEFAULTS = routeDefaultValueData and routeDefaultValueData.wayPoints or {}
local JumpState = Class.LiteClass("JumpState", State)

function JumpState:onEnter(controller, oldState)
	JumpState.super.onEnter(self, controller, oldState)

	local patrolData = controller.patrolPlan.patrolData

	self.x_targetRouteIndex = controller.patrolPlan.patrolData.routeIndex

	local wayPointData = patrolData.routeData.wayPoints[self.x_targetRouteIndex]
	local patrolWayPoint = wayPointData.position
	local subtreeParams = TablePool.getTable()

	subtreeParams.tTargetPosX = patrolWayPoint[1]
	subtreeParams.tTargetPosY = patrolWayPoint[2]
	subtreeParams.tTargetPosZ = patrolWayPoint[3]
	subtreeParams.tTimeout = AiConst.PATROL_MOVE_MAX_TIME

	BehaviorTreePlanUtils.startEcologyPlanByState(controller.patrolPlan.targetEnt.agent, BehaviorPathMapData.EnumNameMap.ST_JumpToPos, subtreeParams)
	TablePool.returnTable(subtreeParams)
end

function JumpState:onExit(controller, nextState)
	JumpState.super.onExit(self, controller, nextState)

	self.x_targetRouteIndex = nil
end

function JumpState:onRun(controller)
	JumpState.super.onRun(self, controller)

	local patrolData = controller.patrolPlan.patrolData
	local wayPointData = patrolData.routeData.wayPoints[self.x_targetRouteIndex]
	local inexecutionAction = wayPointData.inexecutionAction or WAY_POINT_DEFAULTS.inexecutionAction

	if inexecutionAction then
		controller:transitionTo(PATROL_STATE.WayPointBehavior)
	else
		controller:transitionTo(PATROL_STATE.WayPointBehaviorTurn)
	end
end

return JumpState
