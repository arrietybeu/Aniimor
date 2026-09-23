-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\Plan\\ClimbPlanFsm\\ClimbWaitState.lua

local Class = require("Core.Framework.Class")
local State = require("Common.Container.FSM.State")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local CLIMB_STATE = require("Common.Const.AiConst").CLIMB_STATE
local TablePool = require("Common.Container.TablePool")
local BehaviorTreePlanUtils = require("Common.Utils.BehaviorTreePlanUtils")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local ClimbType = require("Common.Const.AiConst").ClimbType
local ClimbWaitState = Class.LiteClass("ClimbWaitState", State)

function ClimbWaitState:onEnter(controller, oldState)
	ClimbWaitState.super.onEnter(self, controller, oldState)
	self:__exec(controller)
end

function ClimbWaitState:onRun(controller)
	ClimbWaitState.super.onRun(self, controller)
	self:__exec(controller)
end

function ClimbWaitState:__exec(controller)
	local climbData = controller.climbPlan:getNextPointData(false)

	if climbData and climbData.climbType == ClimbType.ClimbWait then
		local subtreeParams = TablePool.getTable()

		controller.climbPlan:getNextPointData(true)

		subtreeParams.tWaitTime = climbData.time

		BehaviorTreePlanUtils.startEcologyPlanByState(controller.climbPlan.targetEnt.agent, BehaviorPathMapData.EnumNameMap.PBT_Com_Node_Wait, subtreeParams)
		TablePool.returnTable(subtreeParams)
	else
		controller:autoTransitClimbPlan()
	end
end

return ClimbWaitState
