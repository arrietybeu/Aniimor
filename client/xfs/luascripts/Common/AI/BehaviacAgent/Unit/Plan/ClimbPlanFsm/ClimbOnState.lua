-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\Plan\\ClimbPlanFsm\\ClimbOnState.lua

local Class = require("Core.Framework.Class")
local State = require("Common.Container.FSM.State")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local CLIMB_STATE = require("Common.Const.AiConst").CLIMB_STATE
local TablePool = require("Common.Container.TablePool")
local BehaviorTreePlanUtils = require("Common.Utils.BehaviorTreePlanUtils")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local Vectorpool = require("Common.Container.VectorPool")
local QuaternionPool = require("Common.Container.QuaternionPool")
local Vector3 = Vector3
local Quaternion = Quaternion
local ClimbOnState = Class.LiteClass("ClimbOnState", State)

function ClimbOnState:onEnter(controller, oldState)
	ClimbOnState.super.onEnter(self, controller, oldState)

	self.x_climbOnPos = Vectorpool.getVector()
	self.x_climbOnRot = QuaternionPool.getQuaternion()

	controller.climbPlan:_selectPosList()
	self:__executeClimbOnPos(controller)
end

function ClimbOnState:onRun(controller)
	ClimbOnState.super.onRun(self, controller)

	if AIControllerUtils.isClimbing(controller.climbPlan.targetEnt) then
		controller:autoTransitClimbPlan()

		return
	end

	self:__executeClimbOnPos(controller)
end

function ClimbOnState:onExit(controller)
	ClimbOnState.super.onExit(self, controller)
	Vectorpool.returnVector(self.x_climbOnPos)
	QuaternionPool.returnQuaternion(self.x_climbOnRot)

	self.x_climbOnRot = nil
	self.x_climbOnPos = nil
end

function ClimbOnState:__executeClimbOnPos(controller)
	local subtreeParams = TablePool.getTable()
	local climbPlan = controller.climbPlan
	local entity = climbPlan.targetEnt
	local climbOnPointData = climbPlan:getNextMovePointData(true)
	local climbOnNextPointData = climbPlan:getNextMovePointData(false)

	Vector3.enableCreateFromCache()

	local pos1 = Vector3.New(climbPlan:_getWorldPos(climbOnPointData.point))
	local normal1 = Vector3.New(climbPlan:_getWorldNormal(climbOnPointData.normal))
	local pos2 = Vector3.New(climbPlan:_getWorldPos(climbOnNextPointData.point))
	local dir = pos2 - pos1
	local climbOnRot = Quaternion.LookRotation(-normal1, dir)
	local climbOnPos = pos1 - dir:Normalize() * entity:getHeight() * 0.5

	Vector3.Copy(self.x_climbOnPos, climbOnPos)
	Quaternion.Copy(self.x_climbOnRot, climbOnRot)

	subtreeParams.tClimbOnPos = self.x_climbOnPos
	subtreeParams.tClimbOnRot = self.x_climbOnRot
	subtreeParams.tClimbYaw = math.deg(Quaternion.ToYaw(climbOnRot))

	Vector3.disableCreateFromCache()
	BehaviorTreePlanUtils.startEcologyPlanByState(controller.climbPlan.targetEnt.agent, BehaviorPathMapData.EnumNameMap.PBT_ClimbOn, subtreeParams)
	TablePool.returnTable(subtreeParams)
end

return ClimbOnState
