-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\Plan\\ClimbPlanFsm\\ClimbPlanFsm.lua

local Class = require("Core.Framework.Class")
local CLIMB_STATE = require("Common.Const.AiConst").CLIMB_STATE
local ClimbType = require("Common.Const.AiConst").ClimbType
local FiniteStateMachine = require("Common.Container.FSM.FiniteStateMachine")
local ClimbOnState = require("Common.AI.BehaviacAgent.Unit.Plan.ClimbPlanFsm.ClimbOnState")
local ClimbMoveState = require("Common.AI.BehaviacAgent.Unit.Plan.ClimbPlanFsm.ClimbMoveState")
local ClimbOffState = require("Common.AI.BehaviacAgent.Unit.Plan.ClimbPlanFsm.ClimbOffState")
local ClimbWaitState = require("Common.AI.BehaviacAgent.Unit.Plan.ClimbPlanFsm.ClimbWaitState")
local ClimbEmojiState = require("Common.AI.BehaviacAgent.Unit.Plan.ClimbPlanFsm.ClimbEmojiState")
local ClimbDisableState = require("Common.AI.BehaviacAgent.Unit.Plan.ClimbPlanFsm.ClimbDisableState")
local ClimbPlanFsm = Class.LiteClass("ClimbPlanFsm", FiniteStateMachine)

function ClimbPlanFsm:ctor(climbPlan)
	FiniteStateMachine.ctor(self)

	self.climbPlan = climbPlan

	self:addState(ClimbOnState.new(CLIMB_STATE.ClimbOn))
	self:addState(ClimbMoveState.new(CLIMB_STATE.ClimbMove))
	self:addState(ClimbOffState.new(CLIMB_STATE.ClimbOff))
	self:addState(ClimbWaitState.new(CLIMB_STATE.ClimbWait))
	self:addState(ClimbEmojiState.new(CLIMB_STATE.ClimbEmoji))
	self:addState(ClimbDisableState.new(CLIMB_STATE.ClimbDisable))
	self:addAnyState2StateTransition(CLIMB_STATE.ClimbMove)
	self:addAnyState2StateTransition(CLIMB_STATE.ClimbEmoji)
	self:addAnyState2StateTransition(CLIMB_STATE.ClimbWait)
	self:addAnyState2StateTransition(CLIMB_STATE.ClimbOff)
	self:addTransitionByStateName(CLIMB_STATE.ClimbOff, CLIMB_STATE.ClimbDisable)
	self:addTransitionByStateName(CLIMB_STATE.ClimbDisable, CLIMB_STATE.ClimbOn)
end

function ClimbPlanFsm:autoTransitClimbPlan()
	local nextPointData = self.climbPlan:getNextPointData()

	if nextPointData then
		if nextPointData.climbType == ClimbType.ClimbEmoji then
			self:transitionTo(CLIMB_STATE.ClimbEmoji)
		elseif nextPointData.climbType == ClimbType.ClimbWait then
			self:transitionTo(CLIMB_STATE.ClimbWait)
		else
			self:transitionTo(CLIMB_STATE.ClimbMove)
		end
	else
		self:transitionTo(CLIMB_STATE.ClimbOff)
	end
end

return ClimbPlanFsm
