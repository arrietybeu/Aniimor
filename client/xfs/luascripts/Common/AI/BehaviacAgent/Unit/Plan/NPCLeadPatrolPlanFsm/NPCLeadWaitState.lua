-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\Plan\\NPCLeadPatrolPlanFsm\\NPCLeadWaitState.lua

local Class = require("Core.Framework.Class")
local State = require("Common.Container.FSM.State")
local PATROL_STATE = require("Common.Const.AiConst").PATROL_STATE
local TablePool = require("Common.Container.TablePool")
local BehaviorTreePlanUtils = require("Common.Utils.BehaviorTreePlanUtils")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local NPCLeadWaitState = Class.LiteClass("NPCLeadWaitState", State)

function NPCLeadWaitState:onEnter(controller, oldState)
	NPCLeadWaitState.super.onEnter(self, controller, oldState)

	local subtreeParams = TablePool.getTable()

	subtreeParams.tLeadTargetActorId = controller.patrolPlan.leadTargetActorId

	BehaviorTreePlanUtils.startEcologyPlanByState(controller.patrolPlan.targetEnt.agent, BehaviorPathMapData.EnumNameMap.PBT_NPC_LeadPatrol_WaitPlayer, subtreeParams)
	TablePool.returnTable(subtreeParams)
end

function NPCLeadWaitState:onRun(controller)
	NPCLeadWaitState.super.onRun(self, controller)
	controller:transitionTo(PATROL_STATE.Patrol)
end

return NPCLeadWaitState
