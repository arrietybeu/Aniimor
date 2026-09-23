-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\Plan\\NPCLeadPatrolPlanFsm\\NPCLeadPatrolPlanFsm.lua

local Class = require("Core.Framework.Class")
local FiniteStateMachine = require("Common.Container.FSM.FiniteStateMachine")
local NPCLeadPatrolPlanFsm = Class.LiteClass("NPCLeadPatrolPlanFsm", FiniteStateMachine)
local PATROL_STATE = require("Common.Const.AiConst").PATROL_STATE
local InitState = require("Common.AI.BehaviacAgent.Unit.Plan.PatrolPlanFsm.InitState")
local IntermittentPatrolState = require("Common.AI.BehaviacAgent.Unit.Plan.PatrolPlanFsm.IntermittentPatrolState")
local MovingBehaviorState = require("Common.AI.BehaviacAgent.Unit.Plan.PatrolPlanFsm.MovingBehaviorState")
local NPCLeadPatrolState = require("Common.AI.BehaviacAgent.Unit.Plan.NPCLeadPatrolPlanFsm.NPCLeadPatrolState")
local NPCLeadWaitState = require("Common.AI.BehaviacAgent.Unit.Plan.NPCLeadPatrolPlanFsm.NPCLeadWaitState")
local WayPointBehaviorState = require("Common.AI.BehaviacAgent.Unit.Plan.PatrolPlanFsm.WayPointBehaviorState")
local WayPointBehaviorTurnState = require("Common.AI.BehaviacAgent.Unit.Plan.PatrolPlanFsm.WayPointBehaviorTurnState")
local DisableState = require("Common.AI.BehaviacAgent.Unit.Plan.PatrolPlanFsm.DisableState")

function NPCLeadPatrolPlanFsm:ctor(patrolPlan)
	FiniteStateMachine.ctor(self)

	self.patrolPlan = patrolPlan

	self:addState(InitState.new(PATROL_STATE.Init))
	self:addState(NPCLeadPatrolState.new(PATROL_STATE.Patrol))
	self:addState(IntermittentPatrolState.new(PATROL_STATE.IntermittentPatrol))
	self:addState(MovingBehaviorState.new(PATROL_STATE.MovingBehavior))
	self:addState(WayPointBehaviorState.new(PATROL_STATE.WayPointBehavior))
	self:addState(NPCLeadWaitState.new(PATROL_STATE.Wait))
	self:addState(WayPointBehaviorTurnState.new(PATROL_STATE.WayPointBehaviorTurn))
	self:addState(DisableState.new(PATROL_STATE.Disable))
	self:addTransitionByStateName(PATROL_STATE.Init, PATROL_STATE.Patrol)
	self:addTransitionByStateName(PATROL_STATE.Patrol, PATROL_STATE.WayPointBehaviorTurn)
	self:addTransitionByStateName(PATROL_STATE.Patrol, PATROL_STATE.WayPointBehavior)
	self:addTransitionByStateName(PATROL_STATE.Patrol, PATROL_STATE.Init)
	self:addTransitionByStateName(PATROL_STATE.IntermittentPatrol, PATROL_STATE.MovingBehavior)
	self:addTransitionByStateName(PATROL_STATE.MovingBehavior, PATROL_STATE.IntermittentPatrol)
	self:addTransitionByStateName(PATROL_STATE.IntermittentPatrol, PATROL_STATE.WayPointBehaviorTurn)
	self:addTransitionByStateName(PATROL_STATE.WayPointBehaviorTurn, PATROL_STATE.WayPointBehavior)
	self:addTransitionByStateName(PATROL_STATE.WayPointBehavior, PATROL_STATE.Patrol)
	self:addTransitionByStateName(PATROL_STATE.WayPointBehavior, PATROL_STATE.IntermittentPatrol)
	self:addTransitionByStateName(PATROL_STATE.WayPointBehavior, PATROL_STATE.Disable)
	self:addTransitionByStateName(PATROL_STATE.Wait, PATROL_STATE.Patrol)
	self:addTransitionByStateName(PATROL_STATE.Patrol, PATROL_STATE.Wait)
end

function NPCLeadPatrolPlanFsm:start(startStateName)
	NPCLeadPatrolPlanFsm.super.start(self, startStateName)
end

function NPCLeadPatrolPlanFsm:stop()
	FiniteStateMachine.stop(self)
end

return NPCLeadPatrolPlanFsm
