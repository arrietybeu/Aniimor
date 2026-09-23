-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Components\\AIPlanComponent.lua

local Class = require("Core.Framework.Class")
local AiConst = require("Common.Const.AiConst")
local PatrolPlan = require("Common.AI.BehaviacAgent.Unit.Plan.PatrolPlan")
local SceneUtils = require("Common.Utils.SceneUtils")
local BornEcologyPlan = require("Common.AI.BehaviacAgent.Unit.Plan.BornEcologyPlan")
local Utils = require("Common.Utils.Utils")
local Events = require("Common.Container.Events")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local EBTRootState = BaseEnum.EBTRootState
local ParmonBehaviorGroupData = require("Data.parmon_behavior_group_data")
local ParmonBehaivorData = require("Data.parmon_behavior_data")
local PuppetData = require("Data.puppet_data")
local PetData = require("Data.pet_data")
local ConditionUtils = require("Common.AICt.ConditionUtils")
local EventPlan = require("Common.AI.BehaviacAgent.Unit.Plan.EventPlan")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("AIPlanComponent")
local AIUtils = require("Common.Utils.AIUtils")
local CTUtils = require("Common.AI.ConditionTrigger.CTUtils")
local CTRConst = require("Common.AICt.CTRConst")
local FlowFinishType = CTRConst.FlowFinishType
local CTRFlow = require("Common.AICt.CTRFlow")
local CTFlow = require("Common.AI.ConditionTrigger.CTFlow")
local lume = require("Core.Common.lume")
local AttributeConst = require("Common.Const.AttributeConst")
local CTRPool = require("Common.AICt.CTRPool")
local EventConst = require("Const.EventConst")
local PetBallConfigData = require("Data.pet_ball_config_data")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeLandOperateData = require("Data.homeland_operate_data")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local HomeEventTypeData = require("Data.home_event_type_data")
local HomeObjectData = require("Data.home_object_data")
local HomelandConfigData = require("Data.homeland_config_data")
local AIBehaviorGroupTemplate = require("Common.AI.AIBehaviorGroupTemplate")
local Const = require("Common.Const.Const")
local BehaviorTableSlot = AiConst.BEHAVIOR_TABLE_SLOT
local ipairs = ipairs
local stringNotNilOrEmpty = string.notNilOrEmpty
local pg = pg
local AIPlanComponent = Class.Component("AIPlanComponent")
local AI_TRIGGER_FUNC_NAME = "_onAIEvent"

function AIPlanComponent:ctor()
	local dynamicBehaviorPriorityList = {}

	self.AIPlan = {
		tickLodTriggerBehaviourIdMap = {
			tickLodTriggerCount = 0,
			[AiConst.TICK_TRIGGER_LOD.High] = {},
			[AiConst.TICK_TRIGGER_LOD.Mid] = {},
			[AiConst.TICK_TRIGGER_LOD.Low] = {},
			[AiConst.TICK_TRIGGER_LOD.VeryLow] = {}
		},
		behaviorCdTable = {},
		behaviorPriorityList = dynamicBehaviorPriorityList,
		dynamicBehaviorPriorityList = dynamicBehaviorPriorityList,
		debugRegisteredGraphs = AiConst.AI_DEBUG.REGISTRATION_INFO and {} or nil,
		debugRegisteredBehaviorIds = AiConst.AI_DEBUG.REGISTRATION_INFO and {} or nil
	}
end

function AIPlanComponent:onAICreateAgent()
	self:initAllAIBehaivor()
	self:initAIBornPlan()
	self:registerPlayerVariableTrigger()
end

function AIPlanComponent:onAIStartAgent()
	self:resetAIListener()

	if Utils.isHomePet(self) then
		self:postComponentMethod("onHomelandAIRefresh")
	elseif Utils.isPuppet(self) then
		local pdd = PuppetData[self.templateId]

		if pdd and pdd.canMimicry then
			AIControllerUtils.sendAIEvent(self, "MimicryOutMsgTrigger")
		end
	end

	self:initAIPatrolInfo()
end

function AIPlanComponent:onAIPauseAgent()
	self:removeAIAlListeners()
end

function AIPlanComponent:onAIResumeAgent()
	self:resetAIListener()

	if Utils.isHomePet(self) then
		self:postComponentMethod("onHomelandAIRefresh")
	elseif Utils.isPet(self) and self:isInCombat() then
		local targetActorId = self:getAttackTargetActorId()
		local targetEnt = pg.getEntityByActorId(targetActorId)

		if targetEnt and targetEnt.inBreak and targetEnt:inBreak() then
			AIControllerUtils.sendAIEvent(self, "Msg_EnemyBreak")
		end
	end
end

function AIPlanComponent:onAIDestroyAgent()
	self:unregisterPlayerVariableTrigger()
	self:clearAllAIPlanCd()
	self:clearBehaviorPriorityList()
	self:exitCurrentAIParmonPlan()
	self:exitAIPatrolPlan()
	self:exitAIBornPlan()
	self:removeAIAlListeners()
end

function AIPlanComponent:onAIStateChange(oldRootState, newRootState, oldBehaviorState, newBehaviorState)
	if not Utils.checkIsAuthorityMaster(self) then
		return
	end

	if oldRootState ~= newRootState then
		self:resetAIListener()
	end
end

function AIPlanComponent:onAIStateChangeLater(oldRootState, newRootState)
	if not Utils.checkIsAuthorityMaster(self) then
		return
	end

	if oldRootState ~= newRootState then
		if self:getCurrentAIParmonPlan() then
			self:getCurrentAIParmonPlan():breakPlan()
		end

		if newRootState == EBTRootState.ST_Root_Combat then
			AIControllerUtils.sendAIEvent(self, "Combat_Prepare")

			local context = CTRPool.getContext()

			context.tTargetActorId = AIUtils.getCombatTargetByHateList(self)

			AIControllerUtils.sendAIEvent(self, "EnterCombatTrigger", context)

			if Utils.isPet(self) then
				local targetActorId = self:getAttackTargetActorId()
				local targetEnt = pg.getEntityByActorId(targetActorId)

				if targetEnt and targetEnt.inBreak and targetEnt:inBreak() then
					AIControllerUtils.sendAIEvent(self, "Msg_EnemyBreak")
				end
			end
		elseif newRootState == EBTRootState.ST_Root_Recruit then
			local slavesOwner = pg.getEntity(self.slavesOwnerId)
			local context = CTRPool.getContext()

			context.recruitTargetActorId = slavesOwner and slavesOwner.actorId or 0

			AIControllerUtils.sendAIEvent(self, "RecruitBeginTrigger", context)
		elseif newRootState == EBTRootState.ST_Root_Idle then
			-- block empty
		elseif newRootState == EBTRootState.ST_Root_Afk then
			AIControllerUtils.sendAIEvent(self, "Msg_Pet_AfkPrepare")
		elseif newRootState == EBTRootState.ST_Root_Sensed and self.onNoImpPerceptibilityUpdate then
			self:onNoImpPerceptibilityUpdate()
		end

		if self.processRootStateMessage then
			self:processRootStateMessage(true)
		end

		if self.agent then
			self.agent:resetCurrentTreeTick()
		end
	end
end

function AIPlanComponent:notifyBuffTagChange()
	if Utils.checkClient() and self:BREAK_ST() then
		local petEnt = pg.me:getCurPetEntity()

		if petEnt and petEnt:getAttackTargetActorId() == self.actorId then
			AIControllerUtils.sendAIEvent(petEnt, "Msg_EnemyBreak")
		end
	end
end

function AIPlanComponent:onAIPlanFinish(planType, planId, flowFinishType)
	if not self.agent then
		return
	end

	self.agent:clearSubTreeLocalParams()
	self.agent:reset2BaseBehaviorState()

	self.AIPlan.oldAIBehaviorState = self.agent:getBehaviorState()
end

function AIPlanComponent:setCurrentAIParmonPlan(plan, forceBreakCurrentPlan)
	local oldParmonPlan = self:getCurrentAIParmonPlan()
	local breakCurrentPlan = true

	if plan and oldParmonPlan and not forceBreakCurrentPlan and not oldParmonPlan:checkCanBreakByNewPlan(plan) then
		breakCurrentPlan = false
	end

	if breakCurrentPlan then
		if not plan:initPlan(self) then
			plan:breakPlan()

			breakCurrentPlan = false
		end

		if breakCurrentPlan then
			self.AIPlan.parmonCurPlan = plan

			if oldParmonPlan then
				local oldPlanId = oldParmonPlan:getID()

				oldParmonPlan:breakPlan()
			end

			if self.agent and self.agent:getBehaviorState() == self.AIPlan.oldAIBehaviorState then
				self.agent:resetCurrentTreeTick()
			end

			self:postComponentMethod("onAIPlanInit", plan:getPlanType(), plan:getID())
		end
	end

	return breakCurrentPlan
end

function AIPlanComponent:clearCurrentAIParmonPlan(plan)
	if plan ~= self:getCurrentAIParmonPlan() then
		return
	end

	local curParmonPlan = self.AIPlan.parmonCurPlan

	if curParmonPlan then
		curParmonPlan:breakPlan()

		self.AIPlan.parmonCurPlan = nil
	end
end

function AIPlanComponent:getCurrentAIParmonPlan()
	return self.AIPlan.parmonCurPlan
end

function AIPlanComponent:checkAIParmonPlanTag(planTag)
	local tCurrentAIParmonPlan = self:getCurrentAIParmonPlan()

	if tCurrentAIParmonPlan == nil then
		return false
	end

	return tCurrentAIParmonPlan:checkPlanBehavTag(planTag)
end

function AIPlanComponent:tickCheckAIParmonPlanInterrupt()
	local tCurrentAIParmonPlan = self:getCurrentAIParmonPlan()

	if tCurrentAIParmonPlan and tCurrentAIParmonPlan:tickCheckPlanInterrupt() then
		tCurrentAIParmonPlan:breakPlan()
	end
end

function AIPlanComponent:tickCheckAIParmonPlanContinue()
	local tCurrentAIParmonPlan = self:getCurrentAIParmonPlan()

	if tCurrentAIParmonPlan and tCurrentAIParmonPlan:tickCheckPlanContinue() then
		local ret = tCurrentAIParmonPlan:tryFlowContinue()

		if not ret then
			tCurrentAIParmonPlan:breakPlan()
		end
	end
end

function AIPlanComponent:exitCurrentAIParmonPlan(resetAgentTick)
	if not self.AIPlan then
		return
	end

	local tCurrentAIParmonPlan = self.AIPlan.parmonCurPlan

	if tCurrentAIParmonPlan then
		tCurrentAIParmonPlan:breakPlan()
	end

	if resetAgentTick and self.agent then
		self.agent:resetCurrentTreeTick()
	end
end

function AIPlanComponent:exitCurrentAIGroupPlan()
	if not self.AIPlan then
		return
	end

	local tCurrentAIParmonPlan = self.AIPlan.parmonCurPlan

	if tCurrentAIParmonPlan and tCurrentAIParmonPlan:isGroupBehav() then
		tCurrentAIParmonPlan:breakPlan()
	end
end

function AIPlanComponent:resetAIListener()
	if self:isBTPaused() then
		return
	end

	if AiConst.AI_DEBUG.REGISTRATION_INFO then
		self.AIPlan.debugRegisteredGraphs = self.AIPlan.debugRegisteredGraphs or {}
		self.AIPlan.debugRegisteredBehaviorIds = self.AIPlan.debugRegisteredBehaviorIds or {}
	else
		self.AIPlan.debugRegisteredGraphs = nil
		self.AIPlan.debugRegisteredBehaviorIds = nil
	end

	self:removeAIAlListeners()

	if not self.agent then
		return
	end

	if not self.AIPlan.behaviorGroupTemplate and #self.AIPlan.behaviorPriorityList == 0 then
		self.AIPlan.eventEmitter = nil

		return
	end

	local entityMotionState = AIControllerUtils.getMotionStateValue(self, true)
	local agentRootState = self.agent:getRootState()

	if self.AIPlan.behaviorGroupTemplate then
		self.AIPlan.eventEmitter = nil
		self.AIPlan.eventRoutes = AIBehaviorGroupTemplate.bind(self, entityMotionState, agentRootState, self.AIPlan.behaviorGroupTemplate, self.AIPlan.tickLodTriggerBehaviourIdMap, self.AIPlan.debugRegisteredGraphs, self.AIPlan.debugRegisteredBehaviorIds)
	else
		if self.AIPlan.eventEmitter == nil then
			self.AIPlan.eventEmitter = Events.new()
		end

		for i = 1, #self.AIPlan.behaviorPriorityList do
			AIUtils.registerAITrigger(self, entityMotionState, agentRootState, self.AIPlan.eventEmitter, self.AIPlan.behaviorPriorityList[i], self.AIPlan.tickLodTriggerBehaviourIdMap, self.AIPlan.debugRegisteredGraphs, AI_TRIGGER_FUNC_NAME, nil, self.AIPlan.debugRegisteredBehaviorIds)
		end
	end
end

function AIPlanComponent:tickLodAITriggerExec()
	AIUtils.tickTriggerExec(self, self.AIPlan.tickLodTriggerBehaviourIdMap, AI_TRIGGER_FUNC_NAME)
end

function AIPlanComponent:emitAIEvent(eventName, context)
	if self.AIPlan.eventRoutes then
		AIBehaviorGroupTemplate.emitRoutes(self, self.AIPlan, AI_TRIGGER_FUNC_NAME, eventName, context)
	elseif self.AIPlan.eventEmitter then
		self.AIPlan.eventEmitter:emit(eventName, context)
	end
end

function AIPlanComponent:_getPlanCd(behaviourID)
	local tParmonBehaivorData = ParmonBehaivorData[behaviourID]

	if stringNotNilOrEmpty(tParmonBehaivorData.cdAttribute) then
		return self.actorCombatAttribute:getAttribValue(AttributeConst[tParmonBehaivorData.cdAttribute])
	end

	return tParmonBehaivorData.coolDown or 0
end

local function flowCheckAction(flow)
	if not AIUtils.checkOpenBCOptimize() then
		local self = flow.__owner
		local tParmonBehaivorData = ParmonBehaivorData[flow._behaviourID]

		if AiConst.AI_DEBUG.EVENT_LOG and LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("@cyj、shd、zqd - [" .. self.actorId .. " 触发蓝图]: 【" .. flow.graphId .. "】 : " .. inspect(flow.context))
		end

		local eventPlan = EventPlan.GetEventPlan(flow, tParmonBehaivorData, flow._behaviourID)

		self:setCurrentAIParmonPlan(eventPlan, true)
		self:setAIPlanCd(flow._behaviourID, self:_getPlanCd(flow._behaviourID), AiConst.BEHAVIOR_CD_REASON.StartCD)
	else
		local self = flow.__owner
		local tParmonBehaivorData = ParmonBehaivorData[flow.__behaviourId]

		if AiConst.AI_DEBUG.EVENT_LOG and LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("@cyj、shd、zqd - [" .. self.actorId .. " 触发蓝图]: 【" .. flow.__graphId .. "】 : " .. inspect(flow.__context))
		end

		local eventPlan = EventPlan.GetEventPlan(flow, tParmonBehaivorData, flow.__behaviourId)

		self:setCurrentAIParmonPlan(eventPlan, true)
		self:setAIPlanCd(flow.__behaviourId, self:_getPlanCd(flow.__behaviourId), AiConst.BEHAVIOR_CD_REASON.StartCD)
	end
end

local function flowCheckFailAction(flow)
	if not AIUtils.checkOpenBCOptimize() then
		local self = flow.__owner
		local tParmonBehaivorData = ParmonBehaivorData[flow._behaviourID]

		self:setAIPlanCd(flow._behaviourID, tParmonBehaivorData.coolDownFailImmediately, AiConst.BEHAVIOR_CD_REASON.ActiveFailCD)
	else
		local self = flow.__owner
		local tParmonBehaivorData = ParmonBehaivorData[flow.__behaviourId]

		self:setAIPlanCd(flow.__behaviourId, tParmonBehaivorData.coolDownFailImmediately, AiConst.BEHAVIOR_CD_REASON.ActiveFailCD)
	end
end

local function flowDisposeAction(flow, flowFinishType)
	if not AIUtils.checkOpenBCOptimize() then
		local self = flow.__owner

		if flow.context._plan then
			flow.context._plan:destroy()

			flow.context._plan = nil
		end

		local tParmonBehaivorData = ParmonBehaivorData[flow._behaviourID]

		if flowFinishType ~= FlowFinishType.Finish then
			self:setAIPlanCd(flow._behaviourID, tParmonBehaivorData.coolDownFail, AiConst.BEHAVIOR_CD_REASON.FailCD)
		else
			self:setAIPlanCd(flow._behaviourID, tParmonBehaivorData.coolDownSuccess, AiConst.BEHAVIOR_CD_REASON.SuccessCD)
		end

		local tBehavGcdTagList = tParmonBehaivorData.behavGcdTag

		if tBehavGcdTagList then
			for _, tBehavGcdTag in ipairs(tBehavGcdTagList) do
				for _, tbBehaviorID in ipairs(self.AIPlan.behaviorPriorityList) do
					if tbBehaviorID ~= flow._behaviourID and lume.findInList(ParmonBehaivorData[tbBehaviorID].behavGcdTag, tBehavGcdTag) then
						if flowFinishType ~= FlowFinishType.Finish then
							self:setAIPlanCd(tbBehaviorID, tParmonBehaivorData.behavGcdFail, AiConst.BEHAVIOR_CD_REASON.FailGCD, flow._behaviourID)
						else
							self:setAIPlanCd(tbBehaviorID, tParmonBehaivorData.behavGcdSuccess, AiConst.BEHAVIOR_CD_REASON.SuccessGCD, flow._behaviourID)
						end
					end
				end
			end
		end
	else
		local self = flow.__owner
		local tParmonBehaivorData = ParmonBehaivorData[flow.__behaviourId]

		if flowFinishType ~= FlowFinishType.Finish then
			self:setAIPlanCd(flow.__behaviourId, tParmonBehaivorData.coolDownFail, AiConst.BEHAVIOR_CD_REASON.FailCD)
		else
			self:setAIPlanCd(flow.__behaviourId, tParmonBehaivorData.coolDownSuccess, AiConst.BEHAVIOR_CD_REASON.SuccessCD)
		end

		local tBehavGcdTagList = tParmonBehaivorData.behavGcdTag

		if tBehavGcdTagList then
			for _, tBehavGcdTag in ipairs(tBehavGcdTagList) do
				for _, tbBehaviorID in ipairs(self.AIPlan.behaviorPriorityList) do
					if tbBehaviorID ~= flow.__behaviourId and lume.findInList(ParmonBehaivorData[tbBehaviorID].behavGcdTag, tBehavGcdTag) then
						if flowFinishType ~= FlowFinishType.Finish then
							self:setAIPlanCd(tbBehaviorID, tParmonBehaivorData.behavGcdFail, AiConst.BEHAVIOR_CD_REASON.FailGCD, flow.__behaviourId)
						else
							self:setAIPlanCd(tbBehaviorID, tParmonBehaivorData.behavGcdSuccess, AiConst.BEHAVIOR_CD_REASON.SuccessGCD, flow.__behaviourId)
						end
					end
				end
			end
		end
	end
end

function AIPlanComponent:_onAIEvent(behaviourID, name, type, context)
	local tParmonBehaivorData = ParmonBehaivorData[behaviourID]
	local tCurrentAIParmonPlan = self:getCurrentAIParmonPlan()

	if not AIUtils.checkAIPlanCanBreak(self, tCurrentAIParmonPlan, tParmonBehaivorData, behaviourID) then
		return
	end

	local ctrGraphId = tParmonBehaivorData.triggerAndCondition

	if not AIUtils.checkOpenBCOptimize() then
		local runGraph = ConditionUtils.getGraph(ctrGraphId)
		local flow = CTRFlow.GetFlow(context, runGraph)

		flow:bindActorAndBehavior(self.actorId, behaviourID)

		flow.__triggerName = name
		flow.__triggerType = type
		flow.__owner = self
		flow.__checkAction = flowCheckAction
		flow.__checkFailAction = flowCheckFailAction
		flow.__disposeFunc = flowDisposeAction

		flow:startFlow()
	else
		local flow = CTUtils.GetFlow(self, behaviourID, ctrGraphId, false)

		flow.__activeCallback = flowCheckAction
		flow.__activeFailCallback = flowCheckFailAction
		flow.__inactiveCallback = flowDisposeAction

		flow:execute(type, name, context)
	end
end

function AIPlanComponent:removeAIAlListeners()
	self.AIPlan.eventRoutes = nil

	AIUtils.unregisterAITrigger(self, self.AIPlan.eventEmitter, self.AIPlan.tickLodTriggerBehaviourIdMap, self.AIPlan.debugRegisteredGraphs, self.AIPlan.debugRegisteredBehaviorIds)
end

function AIPlanComponent:EVENT_OnCharacterStateChange(oldState, newState)
	if not Utils.checkClient() then
		return
	end

	if CharacterStateConst[oldState].parent ~= CharacterStateConst[newState].parent then
		self:resetAIListener()
	end
end

function AIPlanComponent:exitAIPatrolPlan()
	local tPatrolPlan = self.AIPlan.patrolPlan

	if tPatrolPlan then
		self.AIPlan.patrolPlan = nil

		tPatrolPlan:breakPlan()
		tPatrolPlan:destroy()
	end
end

function AIPlanComponent:tryClearAIPatrolPlan()
	if self.AIPlan.patrolPlan ~= nil and self.AIPlan.patrolPlan == self.AIPlan.parmonCurPlan then
		return false
	end

	if self.AIPlan.patrolPlan ~= nil then
		self.AIPlan.patrolPlan:destroy()
	end

	self.AIPlan.patrolPlan = nil

	return true
end

function AIPlanComponent:initAIBornPlan()
	if self.AIPlan.bornPlan then
		self:exitAIBornPlan()
	end

	local sceneEntityData = SceneUtils.getSceneEntityData(self.space.sceneId, self.space.id)
	local tEntityData = sceneEntityData[self.staticId]

	if tEntityData and tEntityData.behaviorStateKey and stringNotNilOrEmpty(tEntityData.behaviorStateKey.templateKey) then
		self.AIPlan.bornPlan = BornEcologyPlan.new(tEntityData)
	end
end

function AIPlanComponent:exitAIBornPlan()
	local tBornPlan = self.AIPlan.bornPlan

	if tBornPlan then
		self.AIPlan.bornPlan = nil

		tBornPlan:breakPlan()
		tBornPlan:destroy()
	end
end

function AIPlanComponent:trySetAIBornPlan()
	local curParmonPlan = self:getCurrentAIParmonPlan()

	if not curParmonPlan and self:checkCanDoIdleParmonPlan() and self.AIPlan.bornPlan then
		self:setCurrentAIParmonPlan(self.AIPlan.bornPlan)

		return true
	end

	return false
end

function AIPlanComponent:checkCanDoIdleParmonPlan()
	if self.agent == nil then
		return false
	end

	return self.agent:getRootState() == EBTRootState.ST_Root_Idle
end

function AIPlanComponent:checkAIPlanCD(key)
	local cd = self.AIPlan.behaviorCdTable[key] or 0

	return cd < math.epsilon or cd < self:getCurrScaledTime()
end

function AIPlanComponent:setAIPlanCd(key, cd, reason, otherInfo)
	if cd == nil or cd < math.epsilon then
		return
	end

	self.AIPlan.behaviorCdTable[key] = math.max(self:getCurrScaledTime() + cd, self.AIPlan.behaviorCdTable[key] or 0)
end

function AIPlanComponent:setAIPlanDefaultCd(key)
	self.AIPlan.behaviorCdTable[key] = 0
end

function AIPlanComponent:clearAllAIPlanCd()
	self.AIPlan.behaviorCdTable = {}
end

function AIPlanComponent:initAllAIBehaivor()
	local behaviourGroupId = self:getConfigData().behavGroupId
	local sceneEntityData = SceneUtils.getSceneEntityData(self.space.sceneId, self.space.id)

	if Utils.isHomePet(self) then
		behaviourGroupId = "BG_Wild_HomeLand"
	elseif Utils.isPuppet(self) then
		local staticId = self.staticId
		local staticData = sceneEntityData[staticId]

		if staticData and staticData.ReplaceBehavGroupId then
			behaviourGroupId = staticData.ReplaceBehavGroupId
		end

		if Utils.isCreatePlenty(self) then
			local emergenceOverrideData = Utils.getPuppetEmergenceOverrideData(self)

			if emergenceOverrideData and stringNotNilOrEmpty(emergenceOverrideData.behavGroupId) then
				behaviourGroupId = emergenceOverrideData.behavGroupId
			end
		end
	elseif Utils.isVirtualPet(self) then
		behaviourGroupId = PetBallConfigData.petBallBehavGroup
	end

	if Utils.checkClient() and FREE_WALK then
		behaviourGroupId = AiConst.OfflineBehavGroupId
	end

	local behaviorTable
	local behaviorTableSlot = BehaviorTableSlot.All

	if behaviourGroupId ~= nil then
		local behaviourGroupData = ParmonBehaviorGroupData[behaviourGroupId]

		if behaviourGroupData ~= nil then
			behaviorTable = behaviourGroupData.allBehavTable

			if Utils.isLabelShiny(self.label) and behaviourGroupData.allShinningBehavTable then
				behaviorTable = behaviourGroupData.allShinningBehavTable
				behaviorTableSlot = BehaviorTableSlot.AllShinning
			elseif Utils.isLabelElite(self.label) and behaviourGroupData.allEliteBehavTable then
				behaviorTable = behaviourGroupData.allEliteBehavTable
				behaviorTableSlot = BehaviorTableSlot.AllElite
			end
		end
	end

	local addBehaviorList

	if Utils.isPuppet(self) then
		local staticId = self.staticId
		local staticData = sceneEntityData[staticId]

		addBehaviorList = staticData and staticData.AddBehavList
	end

	if addBehaviorList and #addBehaviorList > 0 then
		local dynamicBehaviorPriorityList = self.AIPlan.dynamicBehaviorPriorityList

		if not dynamicBehaviorPriorityList then
			dynamicBehaviorPriorityList = {}
			self.AIPlan.dynamicBehaviorPriorityList = dynamicBehaviorPriorityList
		end

		self.AIPlan.behaviorGroupTemplate = nil
		self.AIPlan.behaviorPriorityList = AIBehaviorGroupTemplate.createBehaviorPriorityList(behaviorTable, addBehaviorList, dynamicBehaviorPriorityList)
	elseif behaviorTable then
		local template = AIBehaviorGroupTemplate.getOrCreate(behaviourGroupId, behaviorTableSlot, behaviorTable)

		self.AIPlan.behaviorGroupTemplate = template
		self.AIPlan.behaviorPriorityList = template.sharedBehaviorPriorityList
	else
		self:clearBehaviorPriorityList()
	end
end

function AIPlanComponent:clearBehaviorPriorityList()
	self.AIPlan.behaviorGroupTemplate = nil

	local dynamicBehaviorPriorityList = self.AIPlan.dynamicBehaviorPriorityList

	if not dynamicBehaviorPriorityList then
		dynamicBehaviorPriorityList = {}
		self.AIPlan.dynamicBehaviorPriorityList = dynamicBehaviorPriorityList
	end

	AIBehaviorGroupTemplate.mergeBehaviorPriorityListInto(nil, nil, dynamicBehaviorPriorityList, false)

	self.AIPlan.behaviorPriorityList = dynamicBehaviorPriorityList
end

function AIPlanComponent:addBehaviorPriorityList(key, isDynamic)
	local tBehaviorPriorityList = self.AIPlan.behaviorPriorityList

	if isDynamic then
		if ParmonBehaivorData[key] == nil then
			if LoggerManager.checkLogger(LoggerConst.WARN, "AI") then
				logger:warn("行为不存在,请检查配置, key: %s", key)
			end

			return
		end

		for _, k in ipairs(tBehaviorPriorityList) do
			if k == key then
				return
			end
		end
	end

	tBehaviorPriorityList[#tBehaviorPriorityList + 1] = key
end

function AIPlanComponent:onJoinGroupBehaviourFinish()
	self:resetAIListener()
end

function AIPlanComponent:onExitGroupBehaviourFinish()
	self:resetAIListener()
end

function AIPlanComponent:setRouteId(routeId)
	self.AIPlan.curRouteId = routeId
end

function AIPlanComponent:registerPlayerVariableTrigger()
	if self.onPlayerVariableChanged == nil then
		function self.onPlayerVariableChanged(key, oldVal, newVal)
			local context = CTRPool.getContext()

			context.filtKey = key
			context.tOldValue = oldVal
			context.tNewValue = newVal
			context.tIsInit = false

			AIControllerUtils.sendAIEvent(self, "PlayerVarChangeTrigger", context)
		end
	end

	if Utils.checkClient() then
		pg.me.eventEmitter:addEventListener(EventConst.ON_MAIN_PLAYER_CUSTOM_VARIABLE_CHANGED, self.onPlayerVariableChanged)
	end
end

function AIPlanComponent:unregisterPlayerVariableTrigger()
	if Utils.checkClient() and self.onPlayerVariableChanged ~= nil then
		pg.me.eventEmitter:removeEventListener(EventConst.ON_MAIN_PLAYER_CUSTOM_VARIABLE_CHANGED, self.onPlayerVariableChanged)
	end
end

function AIPlanComponent:EVENT_onAudioBgmEventCallback(eventType, extraInfo)
	local AudioConst = require("Const.AudioConst")

	if AudioConst.checkCallbackType(eventType, AudioConst.AkCallbackType.AK_MusicSyncBeat) then
		AIControllerUtils.sendAIEvent(self, "Msg_AudioBeat")
	elseif AudioConst.checkCallbackType(eventType, AudioConst.AkCallbackType.AK_MusicSyncBar) then
		AIControllerUtils.sendAIEvent(self, "Msg_AudioBar")
	end
end

function AIPlanComponent:EVENT_OnEcsStateChange(state)
	if CharacterStateConst.isMimicryState(self.characterState) then
		local chemList = self:getConfigData().mimicryOutByChemList or AiConst.DefaultNullTable

		for _, stateName in ipairs(chemList) do
			if not AIUtils.checkChemStateAndAbility(self, stateName, self.lastEcsState or 0) and AIUtils.checkChemStateAndAbility(self, stateName) then
				local context = CTRPool.getContext()

				context.tStateName = stateName

				AIControllerUtils.sendAIEvent(self, "MimicryOutByEcsStateChangeTrigger", context)
			end
		end
	end
end

function AIPlanComponent:EVENT_OnHit(srcActorId, abilityId)
	if CharacterStateConst.isMimicryState(self.characterState) then
		local abilityParamId = AbilityUtils.getAbilityParamId(abilityId)
		local abilityElementType = AbilityUtils.getAbilityElementType(abilityParamId) or 0
		local elementList = self:getConfigData().mimicryOutBySkillElementList or AiConst.DefaultNullTable

		if abilityElementType > 0 and table.contains(elementList, abilityElementType) then
			local context = CTRPool.getContext()

			context.tSrcActorId = srcActorId
			context.tSrcAbilityId = abilityId
			context.tAbilityElementType = abilityElementType

			AIControllerUtils.sendAIEvent(self, "MimicryOutByElementAbilityTrigger", context)
		end
	end
end

function AIPlanComponent:EVENT_OnReachImpulseThreshold(impulse)
	if CharacterStateConst.isMimicryState(self.characterState) then
		local impulseThreshold = self:getConfigData().mimicryOutImpulseThreshold or 0
		local impulseValue = Vector3.Magnitude(impulse)

		if impulseThreshold <= impulseValue then
			local context = CTRPool.getContext()

			context.tImpulseValue = impulseValue

			AIControllerUtils.sendAIEvent(self, "MimicryOutByImpulseTrigger", context)
		end
	end
end

function AIPlanComponent:getAIPlanDebugInfo()
	local debugInfo = ""
	local tEcologyPlan = self:getCurrentAIParmonPlan()

	if tEcologyPlan then
		debugInfo = debugInfo .. "EcologyPlan: " .. tEcologyPlan.className .. "," .. tEcologyPlan:getPriority() .. "," .. tostring(tEcologyPlan:getInterruptType()) .. "\n"
	end

	return debugInfo
end

function AIPlanComponent:initAIPatrolInfo(forceRefresh)
	if self.AIPlan.patrolRouteRefList ~= nil and not forceRefresh then
		return
	end

	local sceneEntityData = SceneUtils.getSceneEntityData(self.space.sceneId, self.space.id)
	local entityData = sceneEntityData[self.staticId or 0] or AiConst.DefaultNullTable
	local routeRefs = entityData.routeRefs or AiConst.DefaultNullTable

	self.AIPlan.patrolRouteRefList = routeRefs
end

function AIPlanComponent:getPatrolRouteRefList()
	return self.AIPlan.patrolRouteRefList or AiConst.DefaultNullTable
end

function AIPlanComponent:EVENT_PostReload()
	local tCurrentAIParmonPlan = self:getCurrentAIParmonPlan()

	if tCurrentAIParmonPlan then
		tCurrentAIParmonPlan:breakPlan()
	end

	self:clearAllAIPlanCd()
	self:clearBehaviorPriorityList()
	self:initAllAIBehaivor()
	self:resetAIListener()
	self:postComponentMethod("onHomelandAIRefresh")
	self:initAIPatrolInfo(true)
end

function AIPlanComponent:getDebugRegisteredGraphs()
	return self.AIPlan.debugRegisteredGraphs or AiConst.DefaultNullTable
end

function AIPlanComponent:getDebugRegisteredBehaviorInfos()
	if not AiConst.AI_DEBUG.REGISTRATION_INFO then
		return AiConst.DefaultNullTable
	end

	local debugInfos = self.AIPlan.debugRegisteredBehaviorInfos

	if not debugInfos then
		debugInfos = {}
		self.AIPlan.debugRegisteredBehaviorInfos = debugInfos
	end

	local behaviorIds = self.AIPlan.debugRegisteredBehaviorIds

	if not behaviorIds then
		behaviorIds = {}
		self.AIPlan.debugRegisteredBehaviorIds = behaviorIds
	end

	local graphIds = self.AIPlan.debugRegisteredGraphs
	local behaviorCount = #behaviorIds

	for i = 1, behaviorCount do
		local info = debugInfos[i]

		if not info then
			info = {}
			debugInfos[i] = info
		end

		local behaviorId = behaviorIds[i]
		local behaviorData = ParmonBehaivorData[behaviorId]

		info.behaviorId = behaviorId
		info.graphId = graphIds[i]
		info.priority = behaviorData and behaviorData.priority or 0
	end

	for i = #debugInfos, behaviorCount + 1, -1 do
		debugInfos[i] = nil
	end

	return debugInfos
end

return AIPlanComponent
