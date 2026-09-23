-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\Plan\\PatrolPlanFsm\\ClimbState.lua

local Class = require("Core.Framework.Class")
local State = require("Common.Container.FSM.State")
local AIUtils = require("Common.Utils.AIUtils")
local AiConst = require("Common.Const.AiConst")
local PlanPool = require("Common.AI.BehaviacAgent.Unit.Plan.PlanPool")
local PATROL_STATE = AiConst.PATROL_STATE
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local TablePool = require("Common.Container.TablePool")
local BehaviorTreePlanUtils = require("Common.Utils.BehaviorTreePlanUtils")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local routeDefaultValueData = require("Common.Data.Scene.route_default_value_data")
local WAY_POINT_DEFAULTS = routeDefaultValueData and routeDefaultValueData.wayPoints or {}
local ClimbState = Class.LiteClass("ClimbState", State)

function ClimbState:onEnter(controller, oldState)
	ClimbState.super.onEnter(self, controller, oldState)

	local patrolPlan = controller.patrolPlan
	local wayPointData = patrolPlan.patrolData.routeData.wayPoints[patrolPlan.patrolData.routeIndex]
	local climbDataId = wayPointData.climbDataId or WAY_POINT_DEFAULTS.climbDataId
	local climbData, posX, posY, posZ, angleX, angleY, angleZ = AIUtils.getPatrolData(patrolPlan.targetEnt, climbDataId)

	if not climbData then
		controller:transitionTo(PATROL_STATE.Patrol)

		return
	end

	self.x_climbPlan = PlanPool.getNewPlan(AiConst.ParmonPlanType.ClimbPlan, posX, posY, posZ, angleX, angleY, angleZ, climbDataId, climbData)

	self.x_climbPlan:initPlan(patrolPlan.targetEnt)
end

function ClimbState:onRun(controller)
	ClimbState.super.onRun(self, controller)

	local ret = self.x_climbPlan:tryRunPlan()

	if not ret then
		local patrolData = controller.patrolPlan.patrolData
		local routeIndex = patrolData.routeIndex
		local wayPointData = patrolData.routeData.wayPoints[routeIndex]
		local patrolWayPoint = wayPointData.position
		local targetPos = controller.patrolPlan.targetEnt:getPosition()

		if not AutoPathFindUtils.checkTwoPosClose(controller.patrolPlan.targetEnt, targetPos[1], targetPos[2], targetPos[3], patrolWayPoint[1], patrolWayPoint[2], patrolWayPoint[3]) then
			local pathFindType = AutoPathFindUtils.PathFindType.ForceMove
			local subtreeParams = TablePool.getTable()

			subtreeParams.patrolPos = patrolWayPoint
			subtreeParams.patrolMaxTime = AiConst.PATROL_MOVE_MAX_TIME
			subtreeParams.tPatrolSpeed = wayPointData.speed or WAY_POINT_DEFAULTS.speed
			subtreeParams.tBehaviorSpeedRateType = wayPointData.behaviorSpeedRateType or WAY_POINT_DEFAULTS.behaviorSpeedRateType or BaseEnum.SpeedRateType.Mid
			subtreeParams.tPathFindType = pathFindType
			subtreeParams.tUseAccurateArrive = controller.patrolPlan:checkUseAccurateArrive()

			BehaviorTreePlanUtils.startEcologyPlanByState(controller.patrolPlan.targetEnt.agent, BehaviorPathMapData.EnumNameMap.ST_PatrolWalk, subtreeParams)
			TablePool.returnTable(subtreeParams)
		else
			local inexecutionAction = wayPointData.inexecutionAction or WAY_POINT_DEFAULTS.inexecutionAction

			if inexecutionAction then
				controller:transitionTo(PATROL_STATE.WayPointBehavior)
			else
				controller:transitionTo(PATROL_STATE.WayPointBehaviorTurn)
			end
		end
	end
end

function ClimbState:onExit(controller, nextState)
	ClimbState.super.onExit(self, controller, nextState)
	PlanPool.returnPlan(self.x_climbPlan)

	self.x_climbPlan = nil
end

return ClimbState
