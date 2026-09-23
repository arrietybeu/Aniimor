-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Components\\AI\\AIRunningState.lua

local Class = require("Core.Framework.Class")
local State = require("Common.Container.FSM.State")
local AIRunningState = Class.LiteClass("AIRunningState", State)
local Utils = require("Common.Utils.Utils")
local AiConst = require("Common.Const.AiConst")
local AIBtLife = require("Common.AI.Behaviac.Enums").AIBtLife
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("AI")
local CommonRepo = require("Core.Common.CommonRepo")
local AIUtils = require("Common.Utils.AIUtils")
local Time = require("Core.Common.Time")

local function tryBtExecDebug(entity)
	SampleUtils.beginSample("AIRunningState.tryBtExec")
	SampleUtils.beginSample("AIRunningState.tickCheckAIParmonPlanInterrupt")
	entity:tickCheckAIParmonPlanInterrupt()
	SampleUtils.endSample()
	SampleUtils.beginSample("AIRunningState.tickCheckAIParmonPlanContinue")
	entity:tickCheckAIParmonPlanContinue()
	SampleUtils.endSample()
	SampleUtils.beginSample("AIRunningState.processRootStateMessage")
	entity:processRootStateMessage()
	SampleUtils.endSample()
	SampleUtils.beginSample("AIRunningState.tickLodAIDynamicTriggerExec")
	entity:tickLodAIDynamicTriggerExec()
	SampleUtils.endSample()
	SampleUtils.beginSample("AIRunningState.tickLodAdditiveAITriggerExec")
	entity:tickLodAdditiveAITriggerExec()
	SampleUtils.endSample()
	SampleUtils.beginSample("AIRunningState.tickLodAITriggerExec")
	entity:tickLodAITriggerExec()
	SampleUtils.endSample()
	SampleUtils.beginSample("AIRunningState.onBtTickBefore")
	entity:onBtTickBefore()
	SampleUtils.endSample()
	SampleUtils.beginSample("AIRunningState.btExec")

	if AIUtils.checkOpenCPP() then
		pg.world.tickBXAgent(entity.actorId, entity:getCurrScaledTime() * 1000, AiConst.AI_DEBUG.MODE)
	else
		entity.agent:btExec()
	end

	SampleUtils.endSample()
	SampleUtils.beginSample("AIRunningState.onBtTickLater")
	entity:onBtTickLater()
	SampleUtils.endSample()
	SampleUtils.endSample()
end

local function tryBtExec(entity)
	entity:tickCheckAIParmonPlanInterrupt()
	entity:tickCheckAIParmonPlanContinue()
	entity:processRootStateMessage()
	entity:tickLodAIDynamicTriggerExec()
	entity:tickLodAdditiveAITriggerExec()
	entity:tickLodAITriggerExec()
	entity:onBtTickBefore()

	if AIUtils.checkOpenCPP() then
		entity.agent.inBtExec = true

		pg.world.tickBXAgent(entity.actorId, entity:getCurrScaledTime() * 1000, AiConst.AI_DEBUG.MODE)

		entity.agent.inBtExec = false
	else
		entity.agent:btExec()
	end

	entity:onBtTickLater()
end

function AIRunningState:ctor(stateEnum)
	AIRunningState.super.ctor(self, stateEnum)
end

function AIRunningState:onEnter(controller, oldState)
	AIRunningState.super.onEnter(self, controller, oldState)

	local attachEntity = controller:getAttachEntity()

	if attachEntity.agent == nil then
		attachEntity:createAIAgent()
	else
		attachEntity:resumeAIAgent()
	end

	if attachEntity.space and attachEntity.space.aiMgr then
		attachEntity.space.aiMgr:registerAgent(attachEntity)
	end

	if not attachEntity.agent then
		controller:transitionTo(AIBtLife.BT_Init)
	end
end

function AIRunningState:onRun(controller)
	AIRunningState.super.onRun(self, controller)

	local attachEntity = controller:getAttachEntity()

	if attachEntity.agent == nil then
		return
	end

	self:_onRun(attachEntity)
end

function AIRunningState:_onRun(attachEntity)
	if jit then
		local status, err = xpcall(tryBtExec, debug.traceback, attachEntity)

		if not status then
			local ex = err or "unknown error occurred"
			local stack = ((attachEntity or AiConst.DefaultNullTable).agent or AiConst.DefaultNullTable).m_behaviorTreeTickStack or AiConst.DefaultNullTable
			local btName = (stack[#stack] or AiConst.DefaultNullTable).m_relativeTreePath

			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error(string.format("AIComponent traceback occurred, actorId: %s, btName: %s", attachEntity.actorId, btName), ex)
			end

			CommonRepo.exceptionFunc(ex)
		end
	else
		local status, err = xpcall(function()
			attachEntity:tickCheckAIParmonPlanInterrupt()
			attachEntity:tickCheckAIParmonPlanContinue()
			attachEntity:processRootStateMessage()
			attachEntity:tickLodAIDynamicTriggerExec()
			attachEntity:tickLodAdditiveAITriggerExec()
			attachEntity:tickLodAITriggerExec()
			attachEntity:onBtTickBefore()

			if AIUtils.checkOpenCPP() then
				pg.world.tickBXAgent(attachEntity.actorId, attachEntity:getCurrScaledTime() * 1000, AiConst.AI_DEBUG.MODE)
			else
				attachEntity.agent:btExec()
			end

			attachEntity:onBtTickLater()
		end, debug.traceback)

		if not status then
			local ex = err or "unknown error occurred"

			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("AIComponent traceback occurred")
			end

			CommonRepo.exceptionFunc(ex)
		end
	end
end

function AIRunningState:onExit(controller, nextState)
	AIRunningState.super.onExit(self, controller, nextState)

	local attachEntity = controller:getAttachEntity()

	attachEntity:postComponentMethod("onAIStopAgent")

	if attachEntity.space and attachEntity.space.aiMgr then
		attachEntity.space.aiMgr:unregisterAgent(attachEntity)
	end
end

return AIRunningState
