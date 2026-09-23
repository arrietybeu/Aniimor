-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\Plan\\PatrolPlanFsm\\PatrolPlanFsm.lua

local Class = require("Core.Framework.Class")
local FiniteStateMachine = require("Common.Container.FSM.FiniteStateMachine")
local PatrolPlanFSM = Class.LiteClass("PatrolPlanFSM", FiniteStateMachine)
local PATROL_STATE = require("Common.Const.AiConst").PATROL_STATE
local InitState = require("Common.AI.BehaviacAgent.Unit.Plan.PatrolPlanFsm.InitState")
local IntermittentPatrolState = require("Common.AI.BehaviacAgent.Unit.Plan.PatrolPlanFsm.IntermittentPatrolState")
local MovingBehaviorState = require("Common.AI.BehaviacAgent.Unit.Plan.PatrolPlanFsm.MovingBehaviorState")
local PatrolState = require("Common.AI.BehaviacAgent.Unit.Plan.PatrolPlanFsm.PatrolState")
local WayPointBehaviorState = require("Common.AI.BehaviacAgent.Unit.Plan.PatrolPlanFsm.WayPointBehaviorState")
local WayPointBehaviorTurnState = require("Common.AI.BehaviacAgent.Unit.Plan.PatrolPlanFsm.WayPointBehaviorTurnState")
local DisableState = require("Common.AI.BehaviacAgent.Unit.Plan.PatrolPlanFsm.DisableState")
local ClimbState = require("Common.AI.BehaviacAgent.Unit.Plan.PatrolPlanFsm.ClimbState")
local JumpState = require("Common.AI.BehaviacAgent.Unit.Plan.PatrolPlanFsm.JumpState")

function PatrolPlanFSM:ctor(patrolPlan)
	FiniteStateMachine.ctor(self)

	self.patrolPlan = patrolPlan

	self:addState(InitState.new(PATROL_STATE.Init))
	self:addState(PatrolState.new(PATROL_STATE.Patrol))
	self:addState(IntermittentPatrolState.new(PATROL_STATE.IntermittentPatrol))
	self:addState(MovingBehaviorState.new(PATROL_STATE.MovingBehavior))
	self:addState(WayPointBehaviorState.new(PATROL_STATE.WayPointBehavior))
	self:addState(WayPointBehaviorTurnState.new(PATROL_STATE.WayPointBehaviorTurn))
	self:addState(DisableState.new(PATROL_STATE.Disable))
	self:addState(ClimbState.new(PATROL_STATE.Climb))
	self:addState(JumpState.new(PATROL_STATE.Jump))
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
	self:addTransitionByStateName(PATROL_STATE.Patrol, PATROL_STATE.Jump)
	self:addTransitionByStateName(PATROL_STATE.Patrol, PATROL_STATE.Climb)
	self:addTransitionByStateName(PATROL_STATE.Jump, PATROL_STATE.WayPointBehavior)
	self:addTransitionByStateName(PATROL_STATE.Jump, PATROL_STATE.WayPointBehaviorTurn)
	self:addTransitionByStateName(PATROL_STATE.Climb, PATROL_STATE.WayPointBehaviorTurn)
	self:addTransitionByStateName(PATROL_STATE.Climb, PATROL_STATE.WayPointBehavior)
end

function PatrolPlanFSM:start(startStateName)
	PatrolPlanFSM.super.start(self, startStateName)
end

function PatrolPlanFSM:stop()
	FiniteStateMachine.stop(self)
end

return PatrolPlanFSM
