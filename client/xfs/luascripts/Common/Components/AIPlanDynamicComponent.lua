-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Components\\AIPlanDynamicComponent.lua

local Class = require("Core.Framework.Class")
local AiConst = require("Common.Const.AiConst")
local Events = require("Common.Container.Events")
local AIUtils = require("Common.Utils.AIUtils")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local ParmonBehaivorData = require("Data.parmon_behavior_data")
local Utils = require("Common.Utils.Utils")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local CTRPool = require("Common.AICt.CTRPool")
local AIPlanDynamicComponent = Class.Component("AIPlanDynamicComponent")
local AI_TRIGGER_FUNC_NAME = "_onAIEvent"

function AIPlanDynamicComponent:ctor()
	self.AIPlanDynamic = {
		debugRegisteredGraphs = AiConst.AI_DEBUG.REGISTRATION_INFO and {} or nil,
		tickLodTriggerBehaviourIdMap = {
			tickLodTriggerCount = 0,
			[AiConst.TICK_TRIGGER_LOD.High] = {},
			[AiConst.TICK_TRIGGER_LOD.Mid] = {},
			[AiConst.TICK_TRIGGER_LOD.Low] = {},
			[AiConst.TICK_TRIGGER_LOD.VeryLow] = {}
		},
		dynamicBehavList = {}
	}
end

function AIPlanDynamicComponent:init(dict)
	self.AIPlanDynamic.eventEmitter = Events.new()

	return true
end

function AIPlanDynamicComponent:dynamicAddBehavior(behaviorId)
	local data = ParmonBehaivorData[behaviorId]

	if data == nil then
		return
	end

	for _, key in ipairs(self.AIPlanDynamic.dynamicBehavList) do
		if key == behaviorId then
			return
		end
	end

	table.insert(self.AIPlanDynamic.dynamicBehavList, behaviorId)
	self:resetAIDynamicListener()
end

function AIPlanDynamicComponent:dynamicRemoveBehavior(behaviorId)
	local removeIdx = -1

	for idx, key in ipairs(self.AIPlanDynamic.dynamicBehavList) do
		if key == behaviorId then
			removeIdx = idx

			break
		end
	end

	if removeIdx > 0 then
		table.remove(self.AIPlanDynamic.dynamicBehavList, removeIdx)
	end

	self:resetAIDynamicListener()
end

function AIPlanDynamicComponent:resetAIDynamicListener()
	if self:isBTPaused() then
		return
	end

	self:removeAIDynamicListener()
	self:registerAIDynamicListener()
end

function AIPlanDynamicComponent:registerAIDynamicListener()
	if not self.agent then
		return
	end

	if AiConst.AI_DEBUG.REGISTRATION_INFO and not self.AIPlanDynamic.debugRegisteredGraphs then
		self.AIPlanDynamic.debugRegisteredGraphs = {}
	end

	local entityMotionState = AIControllerUtils.getMotionStateValue(self, true)
	local agentRootState = self.agent:getRootState()

	for _, behavId in ipairs(self.AIPlanDynamic.dynamicBehavList) do
		AIUtils.registerAITrigger(self, entityMotionState, agentRootState, self.AIPlanDynamic.eventEmitter, behavId, self.AIPlanDynamic.tickLodTriggerBehaviourIdMap, self.AIPlanDynamic.debugRegisteredGraphs, AI_TRIGGER_FUNC_NAME)
	end
end

function AIPlanDynamicComponent:removeAIDynamicListener()
	if not AiConst.AI_DEBUG.REGISTRATION_INFO then
		self.AIPlanDynamic.debugRegisteredGraphs = nil
	end

	AIUtils.unregisterAITrigger(self, self.AIPlanDynamic.eventEmitter, self.AIPlanDynamic.tickLodTriggerBehaviourIdMap, self.AIPlanDynamic.debugRegisteredGraphs)
end

function AIPlanDynamicComponent:emitAIDynamicEvent(eventName, context, breakType)
	if self.AIPlanDynamic.eventEmitter then
		self.AIPlanDynamic.eventEmitter:emit(eventName, context, breakType)
	end
end

function AIPlanDynamicComponent:tickLodAIDynamicTriggerExec()
	AIUtils.tickTriggerExec(self, self.AIPlanDynamic.tickLodTriggerBehaviourIdMap, AI_TRIGGER_FUNC_NAME)
end

function AIPlanDynamicComponent:getDebugRegisteredDynamicGraphs()
	return self.AIPlanDynamic.debugRegisteredGraphs or AiConst.DefaultNullTable
end

function AIPlanDynamicComponent:onAIStartAgent()
	self:resetAIDynamicListener()
end

function AIPlanDynamicComponent:onAIPauseAgent()
	self:removeAIDynamicListener()
end

function AIPlanDynamicComponent:onAIResumeAgent()
	self:resetAIDynamicListener()
end

function AIPlanDynamicComponent:onAIDestroyAgent()
	self:removeAIDynamicListener()
end

function AIPlanDynamicComponent:onAIStateChange(oldRootState, newRootState, oldBehaviorState, newBehaviorState)
	if oldRootState ~= newRootState then
		self:resetAIDynamicListener()
	end
end

function AIPlanDynamicComponent:EVENT_OnCharacterStateChange(oldState, newState)
	if not Utils.checkClient() then
		return
	end

	local oldParent = CharacterStateConst.getParentState(oldState)
	local newParent = CharacterStateConst.getParentState(newState)

	if oldParent ~= newParent then
		self:resetAIDynamicListener()

		if oldParent and newParent then
			local context = CTRPool.getContext()

			context.oldState = CharacterStateConst[oldParent].name
			context.newState = CharacterStateConst[newParent].name

			AIControllerUtils.sendAIEvent(self, "OnCharacterStateChange", context)
		end
	end
end

function AIPlanDynamicComponent:onJoinGroupBehaviourFinish()
	self:resetAIDynamicListener()
end

function AIPlanDynamicComponent:onExitGroupBehaviourFinish()
	self:resetAIDynamicListener()
end

return AIPlanDynamicComponent
