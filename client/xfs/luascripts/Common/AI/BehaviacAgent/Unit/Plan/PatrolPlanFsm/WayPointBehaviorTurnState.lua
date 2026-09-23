-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\Plan\\PatrolPlanFsm\\WayPointBehaviorTurnState.lua

local Class = require("Core.Framework.Class")
local State = require("Common.Container.FSM.State")
local BehaviorTreePlanUtils = require("Common.Utils.BehaviorTreePlanUtils")
local PATROL_STATE = require("Common.Const.AiConst").PATROL_STATE
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local TablePool = require("Common.Container.TablePool")
local routeDefaultValueData = require("Common.Data.Scene.route_default_value_data")
local WayPointBehaviorTurnState = Class.LiteClass("WayPointBehaviorTurnState", State)

function WayPointBehaviorTurnState:onEnter(controller, oldState)
	WayPointBehaviorTurnState.super.onEnter(self, controller, oldState)

	local patrolPlan = controller.patrolPlan
	local wayPointData = patrolPlan.patrolData.routeData.wayPoints[patrolPlan.patrolData.routeIndex]
	local wayPointDefaults = routeDefaultValueData and routeDefaultValueData.wayPoints or {}
	local ignoreRotation = wayPointData.ignoreRotation or wayPointDefaults.ignoreRotation

	if ignoreRotation then
		controller:transitionTo(PATROL_STATE.WayPointBehavior)

		return
	end

	local patrolWayPointTurnYaw = wayPointData.yaw or wayPointDefaults.yaw
	local subtreeParams = TablePool.getTable()

	subtreeParams.tTurnYaw = patrolWayPointTurnYaw

	BehaviorTreePlanUtils.startEcologyPlanByState(patrolPlan.targetEnt.agent, BehaviorPathMapData.EnumNameMap.ST_PatrolTurn, subtreeParams)
	TablePool.returnTable(subtreeParams)
end

function WayPointBehaviorTurnState:onRun(controller)
	WayPointBehaviorTurnState.super.onRun(self, controller)
	controller:transitionTo(PATROL_STATE.WayPointBehavior)
end

return WayPointBehaviorTurnState
