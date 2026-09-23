-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\Plan\\PatrolPlanFsm\\PatrolState.lua

local Class = require("Core.Framework.Class")
local State = require("Common.Container.FSM.State")
local PatrolState = Class.LiteClass("PatrolState", State)
local lume = require("Core.Common.lume")
local BehaviorTreePlanUtils = require("Common.Utils.BehaviorTreePlanUtils")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local routeDefaultValueData = require("Common.Data.Scene.route_default_value_data")
local WAY_POINT_DEFAULTS = routeDefaultValueData and routeDefaultValueData.wayPoints or {}
local PATROL_STATE = require("Common.Const.AiConst").PATROL_STATE
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local AiConst = require("Common.Const.AiConst")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local TablePool = require("Common.Container.TablePool")
local AIUtils = require("Common.Utils.AIUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("PatrolState")
local MAX_BLOCK_TIME = 3

function PatrolState:ctor(stateEnum)
	PatrolState.super.ctor(self, stateEnum)

	self.patrolPosList = {}
	self.x_blockTime = 0
	self.x_blockIndex = 0
end

function PatrolState:onEnter(controller, oldState)
	PatrolState.super.onEnter(self, controller, oldState)

	self.x_targetRouteIndex = controller.patrolPlan.patrolData.routeIndex

	self:executePatrol(controller)

	self.x_blockTime = 0
	self.x_blockIndex = 0
end

function PatrolState:onRun(controller)
	PatrolState.super.onRun(self, controller)

	local patrolData = controller.patrolPlan.patrolData
	local wayPointData = patrolData.routeData.wayPoints[self.x_targetRouteIndex]
	local patrolWayPoint = wayPointData.position
	local targetPos = controller.patrolPlan.targetEnt:getPosition()

	if not AutoPathFindUtils.isAutoPathFinding(controller.patrolPlan.targetEnt) then
		local closeWayPointFlag = AutoPathFindUtils.checkTwoPosClose(controller.patrolPlan.targetEnt, targetPos[1], targetPos[2], targetPos[3], patrolWayPoint[1], patrolWayPoint[2], patrolWayPoint[3])

		if closeWayPointFlag then
			controller.patrolPlan:setRouteIndex(self.x_targetRouteIndex)

			local inexecutionAction = wayPointData.inexecutionAction or WAY_POINT_DEFAULTS.inexecutionAction

			if inexecutionAction then
				controller:transitionTo(PATROL_STATE.WayPointBehavior)
			else
				controller:transitionTo(PATROL_STATE.WayPointBehaviorTurn)
			end

			return
		else
			if self.x_blockIndex == self.x_targetRouteIndex then
				self.x_blockTime = self.x_blockTime + 1
			else
				self.x_blockIndex = self.x_targetRouteIndex
				self.x_blockTime = 0
			end

			if self.x_blockTime >= MAX_BLOCK_TIME and LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:log2Tag("AI", "这个路径点被堵住", controller.patrolPlan.targetEnt.actorId, self.x_targetRouteIndex)
			end
		end
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:log2Tag("AI", "这个路径点 不可能出现这种情况@cyj", controller.patrolPlan.targetEnt.actorId)
	end

	self:executePatrol(controller)
end

function PatrolState:onExit(controller, nextState)
	PatrolState.super.onExit(self, controller, nextState)

	self.x_targetRouteIndex = nil
	self.x_blockTime = nil
	self.x_blockIndex = nil
end

function PatrolState:executePatrol(controller)
	local patrolData = controller.patrolPlan.patrolData
	local wayPointData = patrolData.routeData.wayPoints[self.x_targetRouteIndex]
	local currentEBehaviorMoveType = wayPointData.behaviorPatrolMoveType or WAY_POINT_DEFAULTS.behaviorPatrolMoveType or AiConst.EBehaviorPatrolMoveType.Common

	if currentEBehaviorMoveType == AiConst.EBehaviorPatrolMoveType.Jump then
		controller:transitionTo(PATROL_STATE.Jump)
	elseif currentEBehaviorMoveType == AiConst.EBehaviorPatrolMoveType.Climb then
		controller:transitionTo(PATROL_STATE.Climb)
	elseif AIControllerUtils.isInGliding(controller.patrolPlan.targetEnt) then
		self:_executeGlidePatrol(controller)
	else
		self:_executeCommonPatrol(controller)
	end
end

function PatrolState:_executeCommonPatrol(controller)
	local patrolData = controller.patrolPlan.patrolData
	local wayPointData = patrolData.routeData.wayPoints[self.x_targetRouteIndex]
	local isFirstPoint = self.x_targetRouteIndex == 1

	if AIUtils.checkWayPointIsContinuity(wayPointData) then
		local splinePosList

		splinePosList, self.x_targetRouteIndex = AIUtils.getContinuityWayPointList(self.x_targetRouteIndex, patrolData.routeData.wayPoints, self.patrolPosList)

		local extraLongRoute = controller.patrolPlan:checkExtraLongRoute()
		local subtreeParams = TablePool.getTable()

		subtreeParams.patrolStartPos = splinePosList[1]
		subtreeParams.patrolPosList = splinePosList
		subtreeParams.patrolMaxTime = extraLongRoute and AiConst.PATROL_SPLINE_LONG_MAX_TIME or AiConst.PATROL_SPLINE_MAX_TIME
		subtreeParams.tPatrolSpeed = wayPointData.speed or WAY_POINT_DEFAULTS.speed
		subtreeParams.tBehaviorSpeedRateType = wayPointData.behaviorSpeedRateType or WAY_POINT_DEFAULTS.behaviorSpeedRateType or BaseEnum.SpeedRateType.Mid
		subtreeParams.tUseAccurateArrive = controller.patrolPlan:checkUseAccurateArrive()
		subtreeParams.tIsFirstPoint = isFirstPoint

		BehaviorTreePlanUtils.startEcologyPlanByState(controller.patrolPlan.targetEnt.agent, BehaviorPathMapData.EnumNameMap.ST_PatrolSplineWalk, subtreeParams)
		TablePool.returnTable(subtreeParams)
	else
		local patrolWayPoint = wayPointData.position
		local useOnlinePathFinding = wayPointData.useOnlinePathFinding or WAY_POINT_DEFAULTS.useOnlinePathFinding
		local pathFindType = (self.x_targetRouteIndex == 1 or useOnlinePathFinding) and AutoPathFindUtils.PathFindType.Auto or AutoPathFindUtils.PathFindType.ForceMove
		local subtreeParams = TablePool.getTable()

		subtreeParams.patrolPos = patrolWayPoint
		subtreeParams.patrolMaxTime = AiConst.PATROL_MOVE_MAX_TIME
		subtreeParams.tPatrolSpeed = wayPointData.speed or WAY_POINT_DEFAULTS.speed
		subtreeParams.tBehaviorSpeedRateType = wayPointData.behaviorSpeedRateType or WAY_POINT_DEFAULTS.behaviorSpeedRateType or BaseEnum.SpeedRateType.Mid
		subtreeParams.tPathFindType = pathFindType
		subtreeParams.tUseAccurateArrive = controller.patrolPlan:checkUseAccurateArrive()

		BehaviorTreePlanUtils.startEcologyPlanByState(controller.patrolPlan.targetEnt.agent, BehaviorPathMapData.EnumNameMap.ST_PatrolWalk, subtreeParams)
		TablePool.returnTable(subtreeParams)
	end
end

function PatrolState:_executeGlidePatrol(controller)
	local patrolData = controller.patrolPlan.patrolData
	local wayPointData = patrolData.routeData.wayPoints[self.x_targetRouteIndex]

	if self.x_targetRouteIndex == 1 then
		local patrolWayPoint = wayPointData.position
		local subtreeParams = TablePool.getTable()

		subtreeParams.patrolPos = patrolWayPoint
		subtreeParams.patrolMaxTime = AiConst.PATROL_MOVE_MAX_TIME
		subtreeParams.tPatrolSpeed = -1
		subtreeParams.tBehaviorSpeedRateType = wayPointData.behaviorSpeedRateType or WAY_POINT_DEFAULTS.behaviorSpeedRateType or BaseEnum.SpeedRateType.Mid
		subtreeParams.tPathFindType = AutoPathFindUtils.PathFindType.Auto
		subtreeParams.tUseAccurateArrive = controller.patrolPlan:checkUseAccurateArrive()

		BehaviorTreePlanUtils.startEcologyPlanByState(controller.patrolPlan.targetEnt.agent, BehaviorPathMapData.EnumNameMap.ST_PatrolWalk, subtreeParams)
		TablePool.returnTable(subtreeParams)
	else
		local glidePosList

		glidePosList, self.x_targetRouteIndex = AIUtils.getContinuityWayPointList(self.x_targetRouteIndex, patrolData.routeData.wayPoints, self.patrolPosList)

		local extraLongRoute = controller.patrolPlan:checkExtraLongRoute()
		local subtreeParams = TablePool.getTable()

		subtreeParams.patrolPosList = glidePosList
		subtreeParams.patrolMaxTime = extraLongRoute and AiConst.PATROL_SPLINE_LONG_MAX_TIME or AiConst.PATROL_SPLINE_MAX_TIME
		subtreeParams.tBehaviorSpeedRateType = wayPointData.behaviorSpeedRateType or WAY_POINT_DEFAULTS.behaviorSpeedRateType or BaseEnum.SpeedRateType.Mid
		subtreeParams.tPatrolSpeed = -1
		subtreeParams.tUseAccurateArrive = controller.patrolPlan:checkUseAccurateArrive()

		BehaviorTreePlanUtils.startEcologyPlanByState(controller.patrolPlan.targetEnt.agent, BehaviorPathMapData.EnumNameMap.ST_PatrolGlideStart, subtreeParams)
		TablePool.returnTable(subtreeParams)
	end
end

return PatrolState
