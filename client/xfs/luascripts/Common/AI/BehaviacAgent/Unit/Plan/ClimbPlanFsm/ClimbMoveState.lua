-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\Plan\\ClimbPlanFsm\\ClimbMoveState.lua

local Class = require("Core.Framework.Class")
local State = require("Common.Container.FSM.State")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local CLIMB_STATE = require("Common.Const.AiConst").CLIMB_STATE
local ListPool = require("Common.Container.ListPool")
local TablePool = require("Common.Container.TablePool")
local BehaviorTreePlanUtils = require("Common.Utils.BehaviorTreePlanUtils")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local Vectorpool = require("Common.Container.VectorPool")
local QuaternionPool = require("Common.Container.QuaternionPool")
local ClimbType = require("Common.Const.AiConst").ClimbType
local ClimbMoveState = Class.LiteClass("ClimbMoveState", State)

function ClimbMoveState:onEnter(controller, oldState)
	ClimbMoveState.super.onEnter(self, controller, oldState)

	self.x_climbPointList = ListPool.getList(3)
	self.x_climbNormalList = ListPool.getList(3)

	local climbPlan = controller.climbPlan
	local nextMovePointData = climbPlan:getNextPointData(true)

	Vector3.enableCreateFromCache()

	while nextMovePointData do
		table.insert(self.x_climbPointList, Vectorpool.getVector(3, Vector3.New(climbPlan:_getWorldPos(nextMovePointData.point))))
		table.insert(self.x_climbNormalList, Vectorpool.getVector(3, Vector3.New(climbPlan:_getWorldNormal(nextMovePointData.normal))))

		nextMovePointData = climbPlan:getNextPointData(false)

		if nextMovePointData and (nextMovePointData.climbType == nil or nextMovePointData.climbType == ClimbType.ClimbMove) then
			climbPlan:getNextPointData(true)
		else
			break
		end
	end

	Vector3.disableCreateFromCache()

	local subtreeParams = TablePool.getTable()

	subtreeParams.tTargetPosList = self.x_climbPointList
	subtreeParams.tNormalList = self.x_climbNormalList

	BehaviorTreePlanUtils.startEcologyPlanByState(climbPlan.targetEnt.agent, BehaviorPathMapData.EnumNameMap.PBT_ClimbMove, subtreeParams)
	TablePool.returnTable(subtreeParams)
end

function ClimbMoveState:onRun(controller)
	ClimbMoveState.super.onRun(self, controller)
	controller:autoTransitClimbPlan()
end

function ClimbMoveState:onExit(controller)
	ClimbMoveState.super.onExit(self, controller)

	for i = #self.x_climbNormalList, 1, -1 do
		Vectorpool.returnVector(self.x_climbNormalList[i])

		self.x_climbNormalList[i] = nil
	end

	for i = #self.x_climbPointList, 1, -1 do
		Vectorpool.returnVector(self.x_climbPointList[i])

		self.x_climbPointList[i] = nil
	end

	ListPool.returnList(self.x_climbPointList, 3)
	ListPool.returnList(self.x_climbNormalList, 3)

	self.x_climbPointList = nil
	self.x_climbNormalList = nil
end

return ClimbMoveState
