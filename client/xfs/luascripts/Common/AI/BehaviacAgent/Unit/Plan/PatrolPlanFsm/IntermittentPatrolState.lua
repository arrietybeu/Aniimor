-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\Plan\\PatrolPlanFsm\\IntermittentPatrolState.lua

local Class = require("Core.Framework.Class")
local State = require("Common.Container.FSM.State")
local IntermittentPatrolState = Class.LiteClass("IntermittentPatrolState", State)
local BehaviorTreePlanUtils = require("Common.Utils.BehaviorTreePlanUtils")
local lume = require("Core.Common.lume")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local routeDefaultValueData = require("Common.Data.Scene.route_default_value_data")
local PATROL_STATE = require("Common.Const.AiConst").PATROL_STATE
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local AiConst = require("Common.Const.AiConst")
local TablePool = require("Common.Container.TablePool")

function IntermittentPatrolState:onEnter(controller, oldState)
	IntermittentPatrolState.super.onEnter(self, controller, oldState)

	local patrolPlan = controller.patrolPlan
	local wayPointData = patrolPlan.patrolData.routeData.wayPoints[patrolPlan.patrolData.routeIndex]
	local patrolWayPoint = wayPointData.position
	local wayPointDefaults = routeDefaultValueData and routeDefaultValueData.wayPoints or {}
	local movingMinMaxTime = wayPointData.movingMinMaxTime or wayPointDefaults.movingMinMaxTime
	local tPatrolMaxTime = lume.random(movingMinMaxTime[1], movingMinMaxTime[2])
	local subtreeParams = TablePool.getTable()

	subtreeParams.patrolPos = patrolWayPoint
	subtreeParams.patrolMaxTime = tPatrolMaxTime
	subtreeParams.tPatrolSpeed = wayPointData.speed or wayPointDefaults.speed
	subtreeParams.tBehaviorSpeedRateType = wayPointData.behaviorSpeedRateType or wayPointDefaults.behaviorSpeedRateType or BaseEnum.SpeedRateType.Mid

	BehaviorTreePlanUtils.startEcologyPlanByState(patrolPlan.targetEnt.agent, BehaviorPathMapData.EnumNameMap.ST_PatrolIntermittentWalk, subtreeParams)
	TablePool.returnTable(subtreeParams)
end

function IntermittentPatrolState:onRun(controller)
	IntermittentPatrolState.super.onRun(self, controller)

	local patrolPlan = controller.patrolPlan
	local wayPointData = patrolPlan.patrolData.routeData.wayPoints[patrolPlan.patrolData.routeIndex]
	local patrolWayPoint = wayPointData.position
	local targetPos = patrolPlan.targetEnt:getPosition()
	local closeWayPointFlag = AutoPathFindUtils.checkTwoPosClose(patrolPlan.targetEnt, targetPos[1], targetPos[2], targetPos[3], patrolWayPoint[1], patrolWayPoint[2], patrolWayPoint[3])

	if closeWayPointFlag then
		controller:transitionTo(PATROL_STATE.WayPointBehaviorTurn)
	else
		controller:transitionTo(PATROL_STATE.MovingBehavior)
	end
end

return IntermittentPatrolState
