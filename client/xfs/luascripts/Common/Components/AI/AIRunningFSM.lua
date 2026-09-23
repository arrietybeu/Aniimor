-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Components\\AI\\AIRunningFSM.lua

local Class = require("Core.Framework.Class")
local FiniteStateMachine = require("Common.Container.FSM.FiniteStateMachine")
local AINoneState = require("Common.Components.AI.AINoneState")
local AIInitState = require("Common.Components.AI.AIInitState")
local AIPauseState = require("Common.Components.AI.AIPauseState")
local AIRunningState = require("Common.Components.AI.AIRunningState")
local AIBtLife = require("Common.AI.Behaviac.Enums").AIBtLife
local AIUtils = require("Common.Utils.AIUtils")
local AIRunningFSM = Class.LiteClass("AIRunningFSM", FiniteStateMachine)

function AIRunningFSM:ctor(entity)
	FiniteStateMachine.ctor(self)

	self._attachEntity = entity
end

function AIRunningFSM:start(startStateName)
	self:addState(AINoneState.new(AIBtLife.BT_None))
	self:addState(AIInitState.new(AIBtLife.BT_Init))
	self:addState(AIPauseState.new(AIBtLife.BT_Pause))
	self:addState(AIRunningState.new(AIBtLife.BT_Running))
	self:addTransitionByStateName(AIBtLife.BT_None, AIBtLife.BT_Init)
	self:addTransitionByStateName(AIBtLife.BT_Init, AIBtLife.BT_Running)
	self:addTransitionByStateName(AIBtLife.BT_Running, AIBtLife.BT_Pause)
	self:addTransitionByStateName(AIBtLife.BT_Running, AIBtLife.BT_Init)
	self:addTransitionByStateName(AIBtLife.BT_Pause, AIBtLife.BT_Running)
	self:addTransitionByStateName(AIBtLife.BT_Pause, AIBtLife.BT_Init)
	AIRunningFSM.super.start(self, startStateName)
end

function AIRunningFSM:stop()
	self:reset()
	self._attachEntity:clearAIAgent()

	self._attachEntity = nil

	AIRunningFSM.super.stop(self)
end

function AIRunningFSM:reset()
	if self:checkIsCurState(AIBtLife.BT_Running) then
		self:transitionTo(AIBtLife.BT_Pause)
	end

	AIRunningFSM.super.reset(self)
end

function AIRunningFSM:getAttachEntity()
	return self._attachEntity
end

return AIRunningFSM
