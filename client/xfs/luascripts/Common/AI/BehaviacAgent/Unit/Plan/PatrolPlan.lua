-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\Plan\\PatrolPlan.lua

local class = require("Core.Framework.Class")
local SceneUtils = require("Common.Utils.SceneUtils")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local enums = require("Common.AI.Behaviac.Enums")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local PatrolConst = require("Common.Const.PatrolConst")
local BaseEcologyPlan = require("Common.AI.BehaviacAgent.Unit.Plan.BaseEcologyPlan")
local AiConst = require("Common.Const.AiConst")
local lume = require("Core.Common.lume")
local common = require("Common.AI.Behaviac.Common")
local BehaviorTreePlanUtils = require("Common.Utils.BehaviorTreePlanUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("PatrolPlan")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local PatrolPlanFsm = require("Common.AI.BehaviacAgent.Unit.Plan.PatrolPlanFsm.PatrolPlanFsm")
local PATROL_STATE = require("Common.Const.AiConst").PATROL_STATE
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local ParmonBehaivorData = require("Data.parmon_behavior_data")
local ListPool = require("Common.Container.ListPool")
local Utils = require("Common.Utils.Utils")
local AIUtils = require("Common.Utils.AIUtils")
local routeDefaultValueData = require("Common.Data.Scene.route_default_value_data")
local WAY_POINT_DEFAULTS = routeDefaultValueData and routeDefaultValueData.wayPoints or {}
local BEHAVIOR_TREE_TEMPLATE_DEFAULTS = WAY_POINT_DEFAULTS.behaviorTreeTemplate or {}
local BEHAVIOR_DEFAULTS = BEHAVIOR_TREE_TEMPLATE_DEFAULTS.behaviors or {}
local PatrolPlan = class.LightClass("PatrolPlan", BaseEcologyPlan)

function PatrolPlan:recycleInit(sceneId, routeId, findNearestPoint, loopTime, behaviorId, spaceId)
	PatrolPlan.super.ctor(self)

	local routeData = SceneUtils.getSceneRouteData(sceneId, spaceId)
	local singleRouteData = routeData[routeId]

	if singleRouteData == nil or Utils.tableIsEmptyOrNil(singleRouteData.wayPoints) then
		if LoggerManager.checkLogger(LoggerConst.WARN, "AI") then
			logger:warn("@布怪路点策划 routeId is not exist", routeId)
		end

		return false
	end

	if AIUtils.isSimpleRoute(singleRouteData) then
		if LoggerManager.checkLogger(LoggerConst.ERROR, "AI") then
			logger:warn("@布怪路点策划 routeId is simple route", routeId)
		end

		return false
	end

	loopTime = (loopTime == nil or loopTime <= 0) and true or loopTime

	local referenceData = ParmonBehaivorData[behaviorId] or AiConst.DefaultNullTable

	if self.patrolData == nil then
		self.patrolData = {
			firstEnter = true,
			canInterrupt = true,
			routeIndex = 1,
			routeData = singleRouteData,
			routeId = routeId,
			behaviorId = behaviorId,
			patrolType = AiConst.PATROL_STATE.Patrol,
			priority = referenceData.priority or PatrolConst.DEFAULT_PRIORITY,
			interruptType = referenceData.interruptType or AiConst.AIBeInterruptedType.CanInterruptedByHighPriority,
			loopTime = loopTime,
			initLoopTime = loopTime,
			findNearestPoint = findNearestPoint
		}
	else
		self.patrolData.routeData = singleRouteData
		self.patrolData.routeId = routeId
		self.patrolData.behaviorId = behaviorId
		self.patrolData.routeIndex = 1
		self.patrolData.patrolType = AiConst.PATROL_STATE.Patrol
		self.patrolData.canInterrupt = true
		self.patrolData.priority = referenceData.priority or PatrolConst.DEFAULT_PRIORITY
		self.patrolData.interruptType = referenceData.interruptType or AiConst.AIBeInterruptedType.CanInterruptedByHighPriority
		self.patrolData.loopTime = loopTime
		self.patrolData.firstEnter = true
		self.patrolData.initLoopTime = loopTime
		self.patrolData.findNearestPoint = findNearestPoint
	end

	self.targetEnt = nil

	return true
end

function PatrolPlan:getPriority()
	return self.patrolData.priority
end

function PatrolPlan:initPlan(entity)
	PatrolPlan.super.initPlan(self, entity)

	if not self.PatrolPlanFsm then
		self.PatrolPlanFsm = PatrolPlanFsm.new(self)
	end

	self:registerEntity(entity)
	self.PatrolPlanFsm:start(PATROL_STATE.Init)
	self.PatrolPlanFsm:transitionTo(PATROL_STATE.Patrol)

	return true
end

function PatrolPlan:tryRunPlan()
	local ret = self:patrolSelector()

	if not ret then
		self:breakPlan()
	end

	return ret
end

function PatrolPlan:breakPlan()
	if self.targetEnt == nil then
		return
	end

	if self:checkResumeLastWaypoint() then
		self.targetEnt:saveLastPatrolInfo(self.patrolData.routeId, self.patrolData.routeIndex)
	end

	local tTargetEnt = self.targetEnt

	self.targetEnt = nil

	PatrolPlan.super.breakPlan(self)
	tTargetEnt:clearCurrentAIParmonPlan(self)
end

function PatrolPlan:checkIgnoreAILod()
	local routeData = self.patrolData.routeData

	if routeData then
		if routeData.ignoreAILod == nil then
			return routeDefaultValueData and routeDefaultValueData.ignoreAILod or false
		end

		return routeData.ignoreAILod
	end

	return nil
end

function PatrolPlan:checkUseAccurateArrive()
	local routeData = self.patrolData.routeData

	if routeData then
		if routeData.useAccurateArrive == nil then
			return routeDefaultValueData and routeDefaultValueData.useAccurateArrive or false
		end

		return routeData.useAccurateArrive
	end

	return nil
end

function PatrolPlan:checkResumeLastWaypoint()
	local routeData = self.patrolData.routeData

	if routeData then
		if routeData.firstWayPointSelectType == nil then
			local firstWayPointSelectType = routeDefaultValueData and routeDefaultValueData.firstWayPointSelectType or PatrolConst.FirstWayPointSelectType.FirstWayPoint

			return firstWayPointSelectType == PatrolConst.FirstWayPointSelectType.ResumeLastWayPoint
		end

		return routeData.firstWayPointSelectType == PatrolConst.FirstWayPointSelectType.ResumeLastWayPoint
	end

	return nil
end

function PatrolPlan:checkUseNearbyWaypoint()
	local routeData = self.patrolData.routeData

	if routeData then
		if routeData.firstWayPointSelectType == nil then
			local firstWayPointSelectType = routeDefaultValueData and routeDefaultValueData.firstWayPointSelectType or PatrolConst.FirstWayPointSelectType.FirstWayPoint

			return firstWayPointSelectType == PatrolConst.FirstWayPointSelectType.NearestWayPoint
		end

		return routeData.firstWayPointSelectType == PatrolConst.FirstWayPointSelectType.NearestWayPoint
	end

	return nil
end

function PatrolPlan:checkExtraLongRoute()
	local routeData = self.patrolData.routeData

	if routeData then
		if routeData.extraLongRoute == nil then
			return routeDefaultValueData and routeDefaultValueData.extraLongRoute or false
		end

		return routeData.extraLongRoute
	end

	return nil
end

function PatrolPlan:getPlanType()
	return AiConst.ParmonPlanType.PatrolPlan
end

function PatrolPlan:getID()
	return self.patrolData.behaviorId
end

function PatrolPlan:destroy()
	self:breakPlan()
end

function PatrolPlan:resetPlan()
	if self:checkResumeLastWaypoint() then
		local lastRouteIsSame, lastRouteIndex = self.targetEnt:checkLastPatrolInfo(self.patrolData.routeId)

		self:setRouteIndex(lastRouteIsSame and AIUtils.findNearestWayPointIndex(self.targetEnt, self.patrolData.routeData.wayPoints, lastRouteIndex) or 1)
	elseif self:checkUseNearbyWaypoint() then
		self:setRouteIndex(AIUtils.findNearestWayPointIndex(self.targetEnt, self.patrolData.routeData.wayPoints, 1))
	else
		self:setRouteIndex(1)
	end

	self.patrolData.loopTime = self.patrolData.initLoopTime
	self.patrolData.firstEnter = true
end

function PatrolPlan:registerEntity(entity)
	self.targetEnt = entity
end

function PatrolPlan:isActive()
	return (self.patrolData.loopTime == true or self.patrolData.loopTime > 0) and self.patrolData.routeData and self.targetEnt
end

function PatrolPlan:patrolSelector()
	if self:isActive() then
		self.PatrolPlanFsm:onRun()

		return not self.PatrolPlanFsm:checkIsCurState(PATROL_STATE.Disable)
	end

	return false
end

function PatrolPlan:getPatrolControlBehaviorLoopTime(behaviorTreeTemplate)
	if not behaviorTreeTemplate or not behaviorTreeTemplate.behaviors then
		return 0, 1
	end

	local compositeType = behaviorTreeTemplate.BehaviourTreeCompositeType or BEHAVIOR_TREE_TEMPLATE_DEFAULTS.BehaviourTreeCompositeType

	if compositeType == AiConst.CompositeType.Sequence then
		return #behaviorTreeTemplate.behaviors, 1
	elseif compositeType == AiConst.CompositeType.SelectorProbability and #behaviorTreeTemplate.behaviors > 0 then
		local weightList = ListPool.getList()

		for i, v in ipairs(behaviorTreeTemplate.behaviors) do
			local t = ListPool.getList()

			table.insert(t, i)

			local probability = v.probability or BEHAVIOR_DEFAULTS.probability

			table.insert(t, probability)
			table.insert(weightList, t)
		end

		local selectIndex = lume.weightedchoicearray(weightList, self.patrolData)

		for _, v in ipairs(weightList) do
			ListPool.returnList(v)
		end

		ListPool.returnList(weightList)

		if selectIndex == nil then
			return 0, 1
		end

		return 1, selectIndex
	end

	return 0, 1
end

function PatrolPlan:updateRouteIndex()
	self.patrolData.routeIndex = self.patrolData.routeIndex >= #self.patrolData.routeData.wayPoints and 1 or self.patrolData.routeIndex + 1

	if self.patrolData.routeIndex == 1 then
		self.patrolData.loopTime = self.patrolData.loopTime == true and true or self.patrolData.loopTime - 1
	end

	return self.patrolData.routeIndex
end

function PatrolPlan:setRouteIndex(routeIndex)
	self.patrolData.routeIndex = routeIndex
end

function PatrolPlan:getSplinePosList(patrolWayPointList, findClose)
	patrolWayPointList = patrolWayPointList or {}

	table.clearArray(patrolWayPointList)

	local wayPointListData = self.patrolData.routeData.wayPoints
	local index = findClose and AIUtils.findCloseIndexInSplinePosList(self.targetEnt, self.patrolData.routeIndex, wayPointListData) or self.patrolData.routeIndex

	return AIUtils.getContinuityWayPointList(index, wayPointListData, patrolWayPointList)
end

return PatrolPlan
