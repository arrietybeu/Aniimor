-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Components\\AdditiveAIComponent.lua

local Class = require("Core.Framework.Class")
local AiConst = require("Common.Const.AiConst")
local Utils = require("Common.Utils.Utils")
local ConditionUtils = require("Common.AICt.ConditionUtils")
local Events = require("Common.Container.Events")
local ParmonBehaviorGroupData = require("Data.parmon_behavior_group_data")
local ParmonBehaivorData = require("Data.parmon_behavior_data")
local PuppetData = require("Data.puppet_data")
local BeExpressionData = require("Data.behav_expression_data")
local PetData = require("Data.pet_data")
local AIUtils = require("Common.Utils.AIUtils")
local CTUtils = require("Common.AI.ConditionTrigger.CTUtils")
local AIBehaviorGroupTemplate = require("Common.AI.AIBehaviorGroupTemplate")
local CTRConst = require("Common.AICt.CTRConst")
local CTRFlow = require("Common.AICt.CTRFlow")
local CTFlow = require("Common.AI.ConditionTrigger.CTFlow")
local EventConst = require("Const.EventConst")
local CTRPool = require("Common.AICt.CTRPool")
local SceneUtils = require("Common.Utils.SceneUtils")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local PetBallConfigData = require("Data.pet_ball_config_data")
local AdditiveAIComponent = Class.Component("AdditiveAIComponent")
local ADDITIVE_AI_TRIGGER_FUNC_NAME = "_onDoAdditiveAIEvent"
local BehaviorTableSlot = AiConst.BEHAVIOR_TABLE_SLOT

function AdditiveAIComponent:ctor()
	self.additiveAIPlan = {
		hasInit = false,
		dynamicBehaviorPriorityList = {},
		context = {},
		cdList = {},
		debugRegisteredGraphs = AiConst.AI_DEBUG.REGISTRATION_INFO and {} or nil,
		runningTimerMap = {},
		tickLodTriggerBehaviourIdMap = {
			tickLodTriggerCount = 0,
			[AiConst.TICK_TRIGGER_LOD.High] = {},
			[AiConst.TICK_TRIGGER_LOD.Mid] = {},
			[AiConst.TICK_TRIGGER_LOD.Low] = {},
			[AiConst.TICK_TRIGGER_LOD.VeryLow] = {}
		}
	}
end

function AdditiveAIComponent:init(dict)
	self.additiveAIPlan.context._entActorId = self.actorId

	return true
end

function AdditiveAIComponent:onAIStartAgent()
	self:resetAIAdditiveListener()
end

function AdditiveAIComponent:onAIPauseAgent()
	self:unRegisterListener()
end

function AdditiveAIComponent:onAIResumeAgent()
	self:resetAIAdditiveListener()
end

function AdditiveAIComponent:onAIDestroyAgent()
	self:unRegisterListener()
end

function AdditiveAIComponent:onAIStateChange(oldRootState, newRootState, oldBehaviorState, newBehaviorState)
	if oldRootState ~= newRootState then
		self:resetAIAdditiveListener()
	end
end

function AdditiveAIComponent:EVENT_OnCharacterStateChange(oldState, newState)
	self:resetAIAdditiveListener()
end

function AdditiveAIComponent:EVENT_PostReload()
	self:resetAIAdditiveListener()
end

function AdditiveAIComponent:resetAIAdditiveListener()
	if self:isBTPaused() then
		return
	end

	self:registerListener()
end

function AdditiveAIComponent:registerListener()
	self:unRegisterListener()

	local additiveAIPlan = self.additiveAIPlan
	local groupId = self:getConfigData().behavGroupId
	local staticData

	if Utils.isPuppet(self) then
		local sceneEntityData = SceneUtils.getSceneEntityData(self.space.sceneId, self.space.id)

		staticData = sceneEntityData[self.staticId]

		if staticData and staticData.ReplaceBehavGroupId then
			groupId = staticData.ReplaceBehavGroupId
		end

		if Utils.isCreatePlenty(self) then
			local emergenceOverrideData = Utils.getPuppetEmergenceOverrideData(self)

			if emergenceOverrideData and string.notNilOrEmpty(emergenceOverrideData.behavGroupId) then
				groupId = emergenceOverrideData.behavGroupId
			end
		end
	elseif Utils.isVirtualPet(self) then
		groupId = PetBallConfigData.petBallBehavGroup
	end

	if Utils.checkClient() and FREE_WALK then
		groupId = AiConst.OfflineBehavGroupId
	end

	local behaviorTable
	local behaviorTableSlot = BehaviorTableSlot.Additive

	if groupId ~= nil then
		local cGroupData = ParmonBehaviorGroupData[groupId]

		if cGroupData then
			if Utils.isLabelShiny(self.label) then
				behaviorTable = cGroupData.shinningAdditiveBehavTable
				behaviorTableSlot = BehaviorTableSlot.ShinningAdditive
			elseif Utils.isLabelElite(self.label) then
				behaviorTable = cGroupData.eliteAdditiveBehavTable
				behaviorTableSlot = BehaviorTableSlot.EliteAdditive
			else
				behaviorTable = cGroupData.additiveBehavTable
			end
		end
	end

	local addBehaviorList = staticData and staticData.AddAdditiveBehavList

	if addBehaviorList and #addBehaviorList > 0 then
		local dynamicBehaviorPriorityList = additiveAIPlan.dynamicBehaviorPriorityList

		if not dynamicBehaviorPriorityList then
			dynamicBehaviorPriorityList = {}
			additiveAIPlan.dynamicBehaviorPriorityList = dynamicBehaviorPriorityList
		end

		additiveAIPlan.behaviorGroupTemplate = nil
		additiveAIPlan.behaviorPriorityList = AIBehaviorGroupTemplate.mergeBehaviorPriorityListInto(behaviorTable, addBehaviorList, dynamicBehaviorPriorityList, false)
	elseif behaviorTable then
		local template = AIBehaviorGroupTemplate.getOrCreate(groupId, behaviorTableSlot, behaviorTable)

		additiveAIPlan.behaviorGroupTemplate = template
		additiveAIPlan.behaviorPriorityList = template.sharedBehaviorPriorityList
	else
		local dynamicBehaviorPriorityList = additiveAIPlan.dynamicBehaviorPriorityList

		if not dynamicBehaviorPriorityList then
			dynamicBehaviorPriorityList = {}
			additiveAIPlan.dynamicBehaviorPriorityList = dynamicBehaviorPriorityList
		end

		additiveAIPlan.behaviorGroupTemplate = nil
		additiveAIPlan.behaviorPriorityList = AIBehaviorGroupTemplate.mergeBehaviorPriorityListInto(nil, nil, dynamicBehaviorPriorityList, false)
	end

	local behaviorPriorityList = additiveAIPlan.behaviorPriorityList

	if #behaviorPriorityList > 0 and self.agent then
		local entityMotionState = AIControllerUtils.getMotionStateValue(self, true)
		local agentRootState = self.agent:getRootState()

		if additiveAIPlan.behaviorGroupTemplate then
			additiveAIPlan.eventEmitter = nil
			additiveAIPlan.eventRoutes = AIBehaviorGroupTemplate.bind(self, entityMotionState, agentRootState, additiveAIPlan.behaviorGroupTemplate, additiveAIPlan.tickLodTriggerBehaviourIdMap, additiveAIPlan.debugRegisteredGraphs)
		else
			if additiveAIPlan.eventEmitter == nil then
				additiveAIPlan.eventEmitter = Events.new()
			end

			for i = 1, #behaviorPriorityList do
				AIUtils.registerAITrigger(self, entityMotionState, agentRootState, additiveAIPlan.eventEmitter, behaviorPriorityList[i], additiveAIPlan.tickLodTriggerBehaviourIdMap, additiveAIPlan.debugRegisteredGraphs, ADDITIVE_AI_TRIGGER_FUNC_NAME)
			end
		end

		additiveAIPlan.hasInit = true
	end
end

function AdditiveAIComponent:unRegisterListener()
	self.additiveAIPlan.eventRoutes = nil

	if not AiConst.AI_DEBUG.REGISTRATION_INFO then
		self.additiveAIPlan.debugRegisteredGraphs = nil
	elseif not self.additiveAIPlan.debugRegisteredGraphs then
		self.additiveAIPlan.debugRegisteredGraphs = {}
	end

	AIUtils.unregisterAITrigger(self, self.additiveAIPlan.eventEmitter, self.additiveAIPlan.tickLodTriggerBehaviourIdMap, self.additiveAIPlan.debugRegisteredGraphs)

	self.additiveAIPlan.hasInit = false
end

function AdditiveAIComponent:tickLodAdditiveAITriggerExec()
	if not self.additiveAIPlan.hasInit then
		return
	end

	AIUtils.tickTriggerExec(self, self.additiveAIPlan.tickLodTriggerBehaviourIdMap, ADDITIVE_AI_TRIGGER_FUNC_NAME)
end

function AdditiveAIComponent:emitAdditiveAIEvent(eventName, context)
	if self.additiveAIPlan.eventRoutes then
		AIBehaviorGroupTemplate.emitRoutes(self, self.additiveAIPlan, ADDITIVE_AI_TRIGGER_FUNC_NAME, eventName, context)
	elseif self.additiveAIPlan.eventEmitter then
		self.additiveAIPlan.eventEmitter:emit(eventName, context)
	end
end

function AdditiveAIComponent:_onDoAdditiveAIEvent(behaviourID, name, type, context)
	if not self.additiveAIPlan.hasInit then
		return
	end

	local tParmonBehaivorData = ParmonBehaivorData[behaviourID]

	if AIUtils.checkAdditiveAIPlanCanRun(self) == false then
		return
	end

	local ctrGraphId = tParmonBehaivorData.triggerAndCondition

	if not self:checkAdditiveAIPlanCD(ctrGraphId) then
		return
	end

	self:setAdditiveAIPlanCd(ctrGraphId, tParmonBehaivorData.coolDown or 0)

	if not AIUtils.checkOpenBCOptimize() then
		local flow = CTRFlow.GetFlow(context, ConditionUtils.getGraph(ctrGraphId))

		flow:bindActorAndBehavior(self.actorId)

		flow.__triggerName = name
		flow.__triggerType = type
		flow._AdditiveFlow = true

		flow:startFlow()
	else
		local flow = CTUtils.GetFlow(self, behaviourID, ctrGraphId, true)

		flow:execute(type, name, context)
	end
end

function AdditiveAIComponent:destroy()
	self:unRegisterListener()

	self.isDestroyed = true
end

function AdditiveAIComponent:checkAdditiveAIPlanCD(key)
	return self.additiveAIPlan.cdList[key] == nil or self.additiveAIPlan.cdList[key] < self:getCurrScaledTime()
end

function AdditiveAIComponent:setAdditiveAIPlanCd(key, cd)
	if cd == nil or cd < math.epsilon then
		return
	end

	self.additiveAIPlan.cdList[key] = self:getCurrScaledTime() + cd
end

function AdditiveAIComponent:clearAllAdditiveAIPlanCd()
	self.additiveAIPlan.cdList = {}
end

function AdditiveAIComponent:getDebugRegisteredAdditiveGraphs()
	return self.additiveAIPlan.debugRegisteredGraphs or AiConst.DefaultNullTable
end

return AdditiveAIComponent
