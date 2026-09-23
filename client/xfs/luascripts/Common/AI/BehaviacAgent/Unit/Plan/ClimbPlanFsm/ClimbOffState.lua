-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\Plan\\ClimbPlanFsm\\ClimbOffState.lua

local Class = require("Core.Framework.Class")
local State = require("Common.Container.FSM.State")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local CLIMB_STATE = require("Common.Const.AiConst").CLIMB_STATE
local TablePool = require("Common.Container.TablePool")
local BehaviorTreePlanUtils = require("Common.Utils.BehaviorTreePlanUtils")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local Vectorpool = require("Common.Container.VectorPool")
local QuaternionPool = require("Common.Container.QuaternionPool")
local ClimbOffState = Class.LiteClass("ClimbOffState", State)

function ClimbOffState:onEnter(controller, oldState)
	ClimbOffState.super.onEnter(self, controller, oldState)

	local subtreeParams = TablePool.getTable()

	subtreeParams.tCharacterState = CharacterStateConst[CharacterStateConst.LOCOMOTION].name

	BehaviorTreePlanUtils.startEcologyPlanByState(controller.climbPlan.targetEnt.agent, BehaviorPathMapData.EnumNameMap.PBT_SwitchState, subtreeParams)
	TablePool.returnTable(subtreeParams)
end

function ClimbOffState:onRun(controller)
	ClimbOffState.super.onRun(self, controller)
	controller:transitionTo(CLIMB_STATE.ClimbDisable)
end

return ClimbOffState
