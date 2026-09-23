-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\Plan\\NPCLeadPatrolPlanFsm\\NPCLeadPatrolState.lua

local Class = require("Core.Framework.Class")
local State = require("Common.Container.FSM.State")
local NPCLeadPatrolState = Class.LiteClass("NPCLeadPatrolState", State)
local lume = require("Core.Common.lume")
local BehaviorTreePlanUtils = require("Common.Utils.BehaviorTreePlanUtils")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local PATROL_STATE = require("Common.Const.AiConst").PATROL_STATE
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local AiConst = require("Common.Const.AiConst")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local TablePool = require("Common.Container.TablePool")
local AIUtils = require("Common.Utils.AIUtils")
local routeDefaultValueData = require("Common.Data.Scene.route_default_value_data")
local WAY_POINT_DEFAULTS = routeDefaultValueData and routeDefaultValueData.wayPoints or {}

function NPCLeadPatrolState:ctor(stateEnum)
	NPCLeadPatrolState.super.ctor(self, stateEnum)

	self.patrolPosList = {}
end

function NPCLeadPatrolState:onEnter(controller, oldState)
	NPCLeadPatrolState.super.onEnter(self, controller, oldState)

	self.x_targetRouteIndex = controller.patrolPlan.patrolData.routeIndex

	self:__executeCommonPatrol(controller, oldState and oldState:getStateName() == PATROL_STATE.Wait)
end

function NPCLeadPatrolState:onExit(controller, nextState)
	NPCLeadPatrolState.super.onExit(self, controller, nextState)

	self.x_targetRouteIndex = nil
end

function NPCLeadPatrolState:onRun(controller)
	NPCLeadPatrolState.super.onRun(self, controller)

	local patrolData = controller.patrolPlan.patrolData
	local wayPointData = patrolData.routeData.wayPoints[self.x_targetRouteIndex]
	local patrolWayPoint = wayPointData.position
	local targetPos = controller.patrolPlan.targetEnt:getPosition()

	if not AutoPathFindUtils.isAutoPathFinding(controller.patrolPlan.targetEnt) then
		local closeWayPointFlag = AutoPathFindUtils.checkTwoPosClose(controller.patrolPlan.targetEnt, targetPos[1], targetPos[2], targetPos[3], patrolWayPoint[1], patrolWayPoint[2], patrolWayPoint[3])

		if closeWayPointFlag then
			patrolData.routeIndex = self.x_targetRouteIndex

			local inexecutionAction = wayPointData.inexecutionAction or WAY_POINT_DEFAULTS.inexecutionAction

			if inexecutionAction then
				controller:transitionTo(PATROL_STATE.WayPointBehavior)
			else
				controller:transitionTo(PATROL_STATE.WayPointBehaviorTurn)
			end

			return
		else
			controller:transitionTo(PATROL_STATE.Wait)
		end
	end

	self:__executeCommonPatrol(controller, false)
end

function NPCLeadPatrolState:__executeCommonPatrol(controller, findClose)
	local patrolData = controller.patrolPlan.patrolData
	local wayPointData = patrolData.routeData.wayPoints[patrolData.routeIndex]
	local isFirstPoint = patrolData.routeIndex == 1
	local tLeadTargetActorId = controller.patrolPlan.leadTargetActorId

	if AIUtils.checkWayPointIsContinuity(wayPointData) then
		local splinePosList

		splinePosList, self.x_targetRouteIndex = controller.patrolPlan:getSplinePosList(self.patrolPosList, findClose)

		local extraLongRoute = controller.patrolPlan:checkExtraLongRoute()
		local subtreeParams = TablePool.getTable()

		subtreeParams.patrolStartPos = splinePosList[1]
		subtreeParams.patrolPosList = splinePosList
		subtreeParams.patrolMaxTime = extraLongRoute and AiConst.PATROL_SPLINE_LONG_MAX_TIME or AiConst.PATROL_SPLINE_MAX_TIME
		subtreeParams.tPatrolSpeed = wayPointData.speed or WAY_POINT_DEFAULTS.speed
		subtreeParams.tBehaviorSpeedRateType = wayPointData.behaviorSpeedRateType or WAY_POINT_DEFAULTS.behaviorSpeedRateType or BaseEnum.SpeedRateType.Mid
		subtreeParams.tUseAccurateArrive = controller.patrolPlan:checkUseAccurateArrive()
		subtreeParams.tIsFirstPoint = isFirstPoint
		subtreeParams.tLeadTargetActorId = tLeadTargetActorId

		BehaviorTreePlanUtils.startEcologyPlanByState(controller.patrolPlan.targetEnt.agent, BehaviorPathMapData.EnumNameMap.ST_NPCLeadPatrolSpline, subtreeParams)
		TablePool.returnTable(subtreeParams)
	else
		local patrolWayPoint = wayPointData.position
		local useOnlinePathFinding = wayPointData.useOnlinePathFinding or WAY_POINT_DEFAULTS.useOnlinePathFinding
		local pathFindType = (patrolData.routeIndex == 1 or useOnlinePathFinding) and AutoPathFindUtils.PathFindType.Auto or AutoPathFindUtils.PathFindType.ForceMove
		local subtreeParams = TablePool.getTable()

		subtreeParams.patrolPos = patrolWayPoint
		subtreeParams.patrolMaxTime = AiConst.PATROL_MOVE_MAX_TIME
		subtreeParams.tPatrolSpeed = wayPointData.speed or WAY_POINT_DEFAULTS.speed
		subtreeParams.tBehaviorSpeedRateType = wayPointData.behaviorSpeedRateType or WAY_POINT_DEFAULTS.behaviorSpeedRateType or BaseEnum.SpeedRateType.Mid
		subtreeParams.tPathFindType = pathFindType
		subtreeParams.tUseAccurateArrive = controller.patrolPlan:checkUseAccurateArrive()
		subtreeParams.tLeadTargetActorId = tLeadTargetActorId

		BehaviorTreePlanUtils.startEcologyPlanByState(controller.patrolPlan.targetEnt.agent, BehaviorPathMapData.EnumNameMap.ST_NPCLeadPatrol, subtreeParams)
		TablePool.returnTable(subtreeParams)
	end
end

return NPCLeadPatrolState
