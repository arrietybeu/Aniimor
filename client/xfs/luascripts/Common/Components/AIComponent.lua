-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Components\\AIComponent.lua

local Utils = require("Common.Utils.Utils")
local behaviac = require("Common.AI.Behaviac.Init")
local AgentMeta = behaviac.AgentMeta
local Time = require("Core.Common.Time")
local class = require("Core.Framework.Class")
local behaviacEnums = require("Common.AI.Behaviac.Enums")
local AttributeConst = require("Common.Const.AttributeConst")
local AbilityConst = require("Common.Const.AbilityConst")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local Const = require("Common.Const.Const")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local CommonRepo = require("Core.Common.CommonRepo")
local logger = LoggerManager.getLogger("AI")
local BehaviorTreeFactory = require("Common.AI.Behaviac.Parser.BehaviorTreeFactory")
local AiConst = require("Common.Const.AiConst")
local ServerEventConst = require("Const.ServerEventConst")
local AIRunningFSM = require("Common.Components.AI.AIRunningFSM")
local AIBtLife = behaviacEnums.AIBtLife
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local PuppetData = require("Data.puppet_data")
local AIUtils = require("Common.Utils.AIUtils")
local ParmonBehaivorData = require("Data.parmon_behavior_data")
local ListPool = require("Common.Container.ListPool")
local TablePool = require("Common.Container.TablePool")
local CTRPool = require("Common.AICt.CTRPool")
local TimerManager = require("Core.Timer.TimerManager")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local BaseAgent = require("Common.AI.Behaviac.Agent.BaseAgent")
local Enums = require("Common.AI.Behaviac.Enums")
local AIBaseMethodUtils = require("Common.AI.BehaviacAgent.Unit.AIBaseMethodUtils")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local EntityTagData = require("Data.entity_tag_data")
local SceneUtils = require("Common.Utils.SceneUtils")
local bit = bit
local pg = pg
local table = table
local ipairs = ipairs
local pairs = pairs
local EBTRootState = BaseEnum.EBTRootState
local AIComponent = class.Component("AIComponent")

function AIComponent:ctor()
	self.agent = nil
	self.AI = {
		valid = false,
		ignoreAILod = 0,
		btTickLock = false,
		gmPause = false,
		fsm = AIRunningFSM.new(self),
		btTickLockEvent = {},
		btTickLockEventContext = {},
		tickInterval = AiConst.TICK_INTERVAL.Normal,
		forceRunBtInfo = {},
		aiTags = {}
	}
	self.pauseBtInfo = {}
	self.pauseBtInfo[AiConst.PauseBtReason.SpaceLoading] = true

	self:initAIBtLifeState()
end

function AIComponent:init(dict)
	if AIControllerUtils.checkOpen(self) then
		AIUtils.pauseBt(self, AiConst.PauseBtReason.SkeletonLoaded)
		AIUtils.pauseBt(self, AiConst.PauseBtReason.AnimatorReady)
	end

	return true
end

function AIComponent:start()
	self.AI.tickInterval = AIUtils.getAITickInterval(self)

	if Utils.isPet(self, true) then
		if self.isInControl then
			self:pauseBt(AiConst.PauseBtReason.Control)
		end

		if not self.isSummon then
			self:pauseBt(AiConst.PauseBtReason.Summon)
			AIControllerUtils.pause(self, AiConst.AIControllerDisableReason.Summon)
		end
	end

	self:initAIBtPauseInfo()
end

function AIComponent:aiTick(deltaTime)
	if not Utils.checkIsAuthorityMaster(self) then
		return
	end

	if self.AI.fsm ~= nil then
		self.AI.fsm:onRun()
	end
end

function AIComponent:initAIBtPauseInfo()
	local actorBuff = self.actorBuff

	if actorBuff and (actorBuff:hasTag(AbilityConst.BUFF_TAG_STUN) or actorBuff:hasTag(AbilityConst.BUFF_TAG_SLEEP) or actorBuff:hasTag(AbilityConst.BUFF_TAG_FROZEN) and not Utils.isSemanticallyBoss(self) or actorBuff:hasTag(AbilityConst.BUFF_TAG_CLOUD_CONFINE)) then
		self:pauseBt(AiConst.PauseBtReason.Stun)
	end
end

function AIComponent:EVENT_OnCharacterStateChange(oldState, newState)
	if not Utils.checkIsAuthorityMaster(self) then
		return
	end

	if Utils.isPet(self) and self:checkPetInControl() then
		return
	end

	if oldState == CharacterStateConst.PLAYANIMATIONSCRIPT then
		self:resumeBt(AiConst.PauseBtReason.PlayAnimationScript)
	end

	if newState == CharacterStateConst.PLAYANIMATIONSCRIPT then
		self:pauseBt(AiConst.PauseBtReason.PlayAnimationScript)
	end

	if oldState == CharacterStateConst.STATICSPAWN or oldState == CharacterStateConst.STATICSPAWNIDLE then
		local tagList = AIControllerUtils.getStaticSpawnEntityTagList(self)

		for _, tag in ipairs(tagList) do
			Utils.removeEntityTag(self, tag)
		end
	end

	if newState == CharacterStateConst.STATICSPAWN or newState == CharacterStateConst.STATICSPAWNIDLE then
		local tagList = AIControllerUtils.getStaticSpawnEntityTagList(self)

		for _, tag in ipairs(tagList) do
			Utils.addEntityTag(self, tag)
		end
	end

	local agentSwitchToState = self.agent and self.agent.x_switchToState_targetState

	if agentSwitchToState and agentSwitchToState ~= CharacterStateConst.NONE and CharacterStateConst.isChildOfState(newState, agentSwitchToState) then
		self.agent.x_switchToState_targetState = CharacterStateConst.NONE
	end
end

function AIComponent:destroy()
	self:detachBt()

	if self.AI.fsm then
		self.AI.fsm:stop()

		self.AI.fsm = nil
	end
end

function AIComponent:EVENT_OnModelScaleChanged(scale)
	AIControllerUtils.refreshAllSpeed(self)
end

function AIComponent:beforePetChangeTemplate()
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:log2Tag("AI", "AI beforePetChangeTemplate")
	end

	self:detachBt()
end

function AIComponent:afterPetChangeTemplate()
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:log2Tag("AI", "AI afterPetChangeTemplate")
	end

	self:attachBt()
end

function AIComponent:onEnterCombat()
	if not Utils.checkIsAuthorityMaster(self) then
		return
	end

	if Utils.checkClient() then
		AIControllerUtils.setUseKCCMove(self, true, Const.KccControlType.InCombat)
	end

	AIUtils.enterCombat(self)
	Utils.addEntityTag(self, EntityTagData.TE_Par_IsInCombat.value)
	AIBaseMethodUtils.Base_HideQuestionMark(self)
end

function AIComponent:onLeaveCombat()
	if not Utils.checkIsAuthorityMaster(self) then
		return
	end

	AIUtils.exitCombat(self)

	if Utils.isPuppet(self) then
		AIUtils.releaseAttackTarget(self)
	end

	if Utils.checkClient() then
		AIControllerUtils.setUseKCCMove(self, false, Const.KccControlType.InCombat)
	end

	Utils.removeEntityTag(self, EntityTagData.TE_Par_IsInCombat.value)
end

function AIComponent:EVENT_OnLifeDead()
	if not Utils.checkIsAuthorityMaster(self) then
		return
	end

	self:pauseBt(AiConst.PauseBtReason.Dead)

	if not Utils.checkClient() then
		AnimationUtils.playAnimationState(self, CharacterStateConst.DEAD)
	end
end

function AIComponent:onLifeRevival()
	self:detachBt()
	self:resumeBt(AiConst.PauseBtReason.Dead, false)
	self:attachBt()
end

function AIComponent:notifyBuffTagChange(changeList, newVal)
	if self.destroyed then
		return
	end

	for _, tagId in pairs(changeList) do
		if tagId == AbilityConst.BUFF_TAG_STUN or tagId == AbilityConst.BUFF_TAG_FROZEN and not Utils.isSemanticallyBoss(self) or tagId == AbilityConst.BUFF_TAG_CLOUD_CONFINE or tagId == AbilityConst.BUFF_TAG_SLEEP then
			if newVal then
				self:pauseBt(AiConst.PauseBtReason.Stun)
			else
				self:resumeBt(AiConst.PauseBtReason.Stun)
			end
		end
	end
end

function AIComponent:onActionMaskChange(mask, value)
	if self.destroyed then
		return
	end

	if mask == AbilityConst.ACTION_MASK_IN_HIT then
		if value then
			self:pauseBt(AiConst.PauseBtReason.InHit)

			if CharacterStateConst.isChildState(CharacterStateConst.CLIMBING) then
				AnimationUtils.playAnimationState(self, CharacterStateConst.LOCOMOTION)
			end
		else
			self:resumeBt(AiConst.PauseBtReason.InHit)
		end
	end
end

function AIComponent:EVENT_OnVoxelRegionChanged()
	self:_refreshVoxelRegionLoadState()
end

function AIComponent:_refreshVoxelRegionLoadState()
	if Utils.checkClient() and FREE_WALK then
		return
	end

	if Utils.isPet(self) or Utils.isVirtualPet(self) then
		return
	end

	if self.voxelRegionLoaded then
		AIControllerUtils.resume(self, AiConst.AIControllerDisableReason.VoxelLoading)
		self:resumeBt(AiConst.PauseBtReason.VoxelLoading)
	else
		self:pauseBt(AiConst.PauseBtReason.VoxelLoading)
		AIControllerUtils.pause(self, AiConst.AIControllerDisableReason.VoxelLoading)
	end
end

function AIComponent:setBtName(btName)
	self.AI.btName = btName
end

function AIComponent:getBtName()
	return self.AI.btName or ""
end

function AIComponent:initAIBtLifeState()
	self.AI.fsm:start(AIBtLife.BT_None)
end

function AIComponent:resetAIBtLifeState()
	if not self.AI or not self.AI.fsm then
		return
	end

	self.AI.fsm:reset()
end

function AIComponent:setAIBtLifeState(stateName)
	if not self.AI.fsm then
		return
	end

	self.AI.fsm:transitionTo(stateName)
end

function AIComponent:checkBTState(stateName)
	if not self.AI.fsm then
		return false
	end

	return self.AI.fsm:checkIsCurState(stateName)
end

function AIComponent:isAIRunning()
	return self:checkBTState(AIBtLife.BT_Running)
end

function AIComponent:createAIAgent()
	local treeName = self:getBtName()

	if not treeName or treeName == "" then
		return false
	end

	if not self.agent then
		local agentClassName

		if Utils.isVirtualEntity(self) then
			agentClassName = Enums.Entity2Agent[self:getVirtualTemplateClass()]
		else
			agentClassName = Enums.Entity2Agent[self:getClassType()]
		end

		self.AI.agentClassName = agentClassName
		self.agent = AgentMeta.getInstance(self.actorId, agentClassName, self)
	end

	local createResult = false

	if AIUtils.checkOpenCPP() then
		createResult = pg.world.createBXAgent(treeName, self.actorId, self.agent.EAgentType or AiConst.EAgentType.luaAgent)
	else
		createResult = self.agent:btSetCurrent(treeName)
	end

	if createResult then
		self:postComponentMethod("onAICreateAgent")
		self.agent:startAgent()
		self:postComponentMethod("onAIStartAgent")
		self:initNpcStatusTrigger()
		self:initTimePeriodTrigger()

		return true
	else
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:log2Tag("AI", "@cyj:templateId为" .. self.templateId .. " setBtName failed（" .. treeName .. "） not exist")
		end

		self:clearAIAgent()

		return false
	end
end

function AIComponent:resumeAIAgent()
	if self.agent then
		self.agent:resumeRunningAction()
		self:postComponentMethod("onAIResumeAgent")
	end
end

function AIComponent:pauseAIAgent()
	if self.agent then
		self.agent:pauseRunningAction()
		self:postComponentMethod("onAIPauseAgent")
	end
end

function AIComponent:clearAIAgent()
	if self.agent then
		if AIUtils.checkOpenCPP() then
			pg.world.destroyBXAgent(self.actorId)
		end

		self:postComponentMethod("onAIDestroyAgent")
		AgentMeta.releaseInstance(self.AI.agentClassName, self.agent)

		self.agent = nil
	end
end

function AIComponent:attachBt()
	if not self:getBtName() then
		return
	end

	self:resetAIBtLifeState()
	self:refreshBtState()
end

function AIComponent:detachBt()
	self:resetAIBtLifeState()
end

function AIComponent:pauseBt(reason, skipRefreshState)
	reason = reason or AiConst.PauseBtReason.Default
	self.pauseBtInfo[reason] = true

	if AiConst.PauseBtReasonNeedBreakPlan[reason] then
		self:exitCurrentAIParmonPlan()
	end

	if not skipRefreshState then
		self:refreshBtState()
	end
end

function AIComponent:EVENT_OnAnimatorReady()
	AIUtils.resumeBt(self, AiConst.PauseBtReason.AnimatorReady)
end

function AIComponent:resumeBt(reason, skipRefreshState)
	reason = reason or AiConst.PauseBtReason.Default
	self.pauseBtInfo[reason] = nil

	if not skipRefreshState then
		self:refreshBtState()
	end
end

function AIComponent:forceRunBt(reason, skipRefreshState)
	reason = reason or AiConst.ForceRunBtReason.Default
	self.AI.forceRunBtInfo[reason] = true

	if not skipRefreshState then
		self:refreshBtState()
	end
end

function AIComponent:cancelForceRunBt(reason, skipRefreshState)
	reason = reason or AiConst.ForceRunBtReason.Default
	self.AI.forceRunBtInfo[reason] = nil

	if not skipRefreshState then
		self:refreshBtState()
	end
end

function AIComponent:checkBtPause()
	if not self.space then
		return true
	end

	if self.isPauseBt then
		return true
	end

	if not Utils.tableIsEmptyOrNil(self.AI.forceRunBtInfo) then
		return false
	end

	if not Utils.tableIsEmptyOrNil(self.pauseBtInfo) then
		return true
	end

	if Utils.isVirtualEntity(self) and not self:checkVirtualAIEnable() then
		return true
	end

	if Utils.isPet(self) then
		local masterEnt = self:getMasterEntity()

		if masterEnt and masterEnt.checkPauseCurPetBt and masterEnt:checkPauseCurPetBt() then
			return true
		end
	end

	return false
end

function AIComponent:refreshBtState()
	if not self:getBtName() then
		return
	end

	if self:checkBtPause() then
		if self:checkBTState(AIBtLife.BT_Running) then
			self:setAIBtLifeState(AIBtLife.BT_Pause)
		end
	else
		self:setAIBtLifeState(AIBtLife.BT_Running)
	end
end

function AIComponent:pauseBtGM()
	self:pauseBt(AiConst.PauseBtReason.GM)

	self.AI.gmPause = true
end

function AIComponent:resumeBtGM()
	self.AI.gmPause = false

	self:resumeBt(AiConst.PauseBtReason.GM)
end

function AIComponent:onBtTickBefore()
	self.AI.btTickLock = true
end

function AIComponent:onBtTickLater()
	self.AI.btTickLock = false

	local eventCount = #self.AI.btTickLockEvent

	if eventCount > 0 then
		for index = 1, eventCount do
			AIControllerUtils.sendAIEvent(self, self.AI.btTickLockEvent[index], self.AI.btTickLockEventContext[index])
		end

		table.clearArray(self.AI.btTickLockEvent)
		table.clearArray(self.AI.btTickLockEventContext)
	end
end

function AIComponent:EVENT_OnAuthorityChanged()
	if Utils.checkClient() then
		if Utils.checkIsAuthorityMaster(self) then
			AIControllerUtils.setAuthority(self, true)
			self:resumeBt(AiConst.PauseBtReason.Authority)
		else
			AIControllerUtils.setAuthority(self, false)
			self:pauseBt(AiConst.PauseBtReason.Authority)
		end
	elseif Utils.checkIsAuthorityMaster(self) then
		self:resumeBt(AiConst.PauseBtReason.Authority)
	else
		self:pauseBt(AiConst.PauseBtReason.Authority)
	end

	self:refreshBtState()
end

function AIComponent:EVENT_EnterScene()
	self.AI.fsm:transitionTo(AIBtLife.BT_Init)
	self:_resetAIAgent()

	if Utils.isPet(self) then
		if not self.isSummon then
			self:pauseBt(AiConst.PauseBtReason.Summon)
		else
			self:resumeBt(AiConst.PauseBtReason.Summon)
			AIControllerUtils.resume(self, AiConst.AIControllerDisableReason.Summon)
		end
	end

	if Utils.checkClient() and Utils.isPet(self, true) then
		clientUtils.exitAfkMode()
	end
end

function AIComponent:EVENT_LeaveScene()
	if Utils.checkClient() and Utils.isPet(self, true) then
		clientUtils.exitAfkMode()
	end
end

function AIComponent:EVENT_ResetScene()
	self:_resetAIAgent()

	if Utils.checkClient() and Utils.isPet(self, true) then
		clientUtils.exitAfkMode()
	end
end

function AIComponent:onEnterSpace()
	self:resumeBt(AiConst.PauseBtReason.SpaceLoading)

	if Utils.checkClient() then
		AIControllerUtils.initEntity(self, CharacterStateConst.getParentState(self.motionState))

		if self.isInCombat and self:isInCombat() then
			AIControllerUtils.setUseKCCMove(self, true, Const.KccControlType.InCombat)
		end

		if clientUtils.checkIsHideEntity(self) then
			self:pauseBt(AiConst.PauseBtReason.HideShowEntityDic)
		else
			self:resumeBt(AiConst.PauseBtReason.HideShowEntityDic)
		end

		AIControllerUtils.resume(self, AiConst.AIControllerDisableReason.SpaceLoading)

		if not Utils.checkIsAuthorityMaster(self) then
			AIControllerUtils.setAuthority(self, false)
			self:pauseBt(AiConst.PauseBtReason.Authority)
		end
	else
		if not Utils.checkIsAuthorityMaster(self) then
			self:pauseBt(AiConst.PauseBtReason.Authority)
		end

		self.AI.fsm:transitionTo(AIBtLife.BT_Init)
		self:_resetAIAgent()
	end
end

function AIComponent:onLeaveSpace()
	self:detachBt()

	if self.AI.fsm then
		self.AI.fsm:stop()

		self.AI.fsm = nil
	end

	if Utils.checkClient() and Utils.isPet(self, true) then
		clientUtils.exitAfkMode()
	end
end

function AIComponent:onPetSummon()
	self:resumeBt(AiConst.PauseBtReason.Summon)
	AIControllerUtils.resume(self, AiConst.AIControllerDisableReason.Summon)
end

function AIComponent:onPetUnSummon()
	AnimationUtils.forceChangeState(self, CharacterStateConst.LOCOMOTION)
	self:pauseBt(AiConst.PauseBtReason.Summon)
	AIControllerUtils.pause(self, AiConst.AIControllerDisableReason.Summon)
end

function AIComponent:EVENT_Before_BeControlled()
	if Utils.isBotPet(self) then
		return
	end

	self:pauseBt(AiConst.PauseBtReason.Control)
	AutoPathFindUtils.stopAutoPathFind(self)
	AIControllerUtils.pause(self, AiConst.AIControllerDisableReason.BeControlled)
end

function AIComponent:EVENT_LoseControlled()
	self:resumeBt(AiConst.PauseBtReason.Control)
	AutoPathFindUtils.stopAutoPathFind(self)
	AIControllerUtils.resume(self, AiConst.AIControllerDisableReason.BeControlled)
	AnimationUtils.forceChangeState(self, CharacterStateConst.LOCOMOTION)
end

function AIComponent:EVENT_BeStick()
	self:pauseBt(AiConst.PauseBtReason.BeStick)
	AIControllerUtils.pause(self, AiConst.AIControllerDisableReason.BeStick)

	local context = CTRPool.getContext()

	context.tTargetActorId = self.actorId

	AIControllerUtils.sendAIEvent(pg.me:getCurPetEntity(), "DontCombatTrigger", context)
end

function AIComponent:EVENT_BeUnStick()
	self:resumeBt(AiConst.PauseBtReason.BeStick)
	AIControllerUtils.resume(self, AiConst.AIControllerDisableReason.BeStick)
end

function AIComponent:EVENT_OnEntityBeAttached()
	self:pauseBt(AiConst.PauseBtReason.BeStick)
	AIControllerUtils.pause(self, AiConst.AIControllerDisableReason.BeStick)
end

function AIComponent:EVENT_OnEntityBeDetached()
	self:resumeBt(AiConst.PauseBtReason.BeStick)
	AIControllerUtils.resume(self, AiConst.AIControllerDisableReason.BeStick)
end

function AIComponent:EVENT_onAddAbility(abilityId, ability)
	if self.agent and self.agent.onAbilityChange then
		self.agent:onAbilityChange()
	end
end

function AIComponent:EVENT_onRemoveAbility(abilityId, ability)
	if self.agent and self.agent.onAbilityChange then
		self.agent:onAbilityChange()
	end
end

function AIComponent:EVENT_PostReload()
	BehaviorTreeFactory.clearCache()
	AgentMeta.clearInstance()
	BaseAgent.clearAllTreeTickPool()
	self:_resetAIAgent()
end

function AIComponent:isBTPaused()
	return not self:isBTRunning()
end

function AIComponent:isBTRunning()
	return self.AI.fsm and self:checkBTState(AIBtLife.BT_Running)
end

function AIComponent:isBTInit()
	return self.AI.fsm and self:checkBTState(AIBtLife.BT_Init)
end

function AIComponent:_resetAIAgent()
	if Utils.isStaticNpc(self) then
		return
	end

	self:detachBt()
	self:attachBt()
end

function AIComponent:RPC_SC_PauseBtGM()
	self:pauseBtGM()
end

function AIComponent:RPC_SC_ResumeBtGM()
	self:resumeBtGM()
end

function AIComponent:RPC_SC_PauseBt(reason)
	self:pauseBt(reason)
end

function AIComponent:RPC_SC_ResumeBt(reason)
	self:resumeBt(reason)
end

function AIComponent:on_isPauseBt_changed(oldVal, newVal)
	if self.isPauseBt then
		self:pauseBtGM()
	else
		self:resumeBtGM()
	end
end

function AIComponent:RPC_CS_TriggerBlueprint(event)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:log2Tag("AI", "RPC_CS_TriggerBlueprint %s", event, self:repr())
	end

	if string.len(event) > 100 then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:log2Tag("AI", "RPC_CS_TriggerBlueprint event length %s", string.len(event), self:repr())
		end

		return
	end

	self.space:emitSpaceEvent(ServerEventConst.AI_EVENT, {
		aiEvent = event,
		staticId = self.staticId or 0
	})
end

function AIComponent:RPC_SC_AIEvent(eventName, context)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:log2Tag("AI", "RPC_SC_AIEvent %s", eventName, context)
	end

	AIControllerUtils.sendAIEvent(self, eventName, context)
end

function AIComponent:simulateAIAction(methodName, params)
	if Utils.checkClient() then
		AIBaseMethodUtils[methodName](self, table.unpack(params))
	end
end

function AIComponent:checkAICanInteract()
	local tCurrentAIParmonPlan = self:getCurrentAIParmonPlan()

	if tCurrentAIParmonPlan then
		local behaviorId = tCurrentAIParmonPlan:getID()
		local tBehaviorData = ParmonBehaivorData[behaviorId]

		if tBehaviorData and tBehaviorData.forbidInteract == 1 then
			return false
		end
	end

	return true
end

function AIComponent:openAINodeDebug()
	AIUtils.setAINodeDebug(self.actorId)
end

function AIComponent:onAIEnterFog()
	Utils.addEntityTag(self, EntityTagData.TE_Par_IsInFog.value)
	self:addAITag("TA_InLowGravity")
end

function AIComponent:onAIExitFog()
	Utils.removeEntityTag(self, EntityTagData.TE_Par_IsInFog.value)
	self:removeAITag("TA_InLowGravity")
end

function AIComponent:initNpcStatusTrigger()
	if Utils.checkClient() then
		local ClientUtils = require("Utils.ClientUtils")
		local statusMap = ClientUtils.getNpcBehavStatusMap(self.staticId)

		if not statusMap then
			return
		end

		for behavId, status in pairs(statusMap) do
			local context = CTRPool.getContext()

			context.tKey = behavId
			context.tOldValue = -1
			context.tNewValue = status
			context.tIsInit = true

			AIControllerUtils.sendAIEvent(self, "NpcStatusChangeTrigger", context)
		end
	end
end

function AIComponent:initTimePeriodTrigger()
	local context = CTRPool.getContext()

	context.tCurTimePeriod = pg.timePeriod
	context.tIsInit = true

	AIControllerUtils.sendAIEvent(self, "TimePeriodChangeTrigger", context)
end

function AIComponent:setIgnoreAILod(state, reason)
	local old = self:checkIgnoreAILod()

	if state then
		self.AI.ignoreAILod = bit.bor(self.AI.ignoreAILod, bit.lshift(1, reason))
	else
		self.AI.ignoreAILod = bit.band(self.AI.ignoreAILod, bit.bnot(bit.lshift(1, reason)))
	end

	if old ~= self:checkIgnoreAILod() then
		AIControllerUtils.ignoreAILod(self, not old)
	end
end

function AIComponent:checkIgnoreAILod()
	return self.AI.ignoreAILod > 0
end

function AIComponent:onAILandStateEnter(height)
	local context = CTRPool.getContext()

	context.height = height

	AIControllerUtils.sendAIEvent(self, "OnLandStateEnterTrigger", context)
end

function AIComponent:onTimePeriodChangeAITrigger(period)
	local context = CTRPool.getContext()

	context.tCurTimePeriod = period
	context.tIsInit = false

	AIControllerUtils.sendAIEvent(self, "TimePeriodChangeTrigger", context)
end

function AIComponent:EVENT_BeTrapped()
	self:pauseBt(AiConst.PauseBtReason.Capture)
	AIControllerUtils.pause(self, AiConst.AIControllerDisableReason.BeCaptured)

	local context = CTRPool.getContext()

	context.tTargetActorId = self.actorId

	AIControllerUtils.sendAIEvent(pg.me:getCurPetEntity(), "DontCombatTrigger", context)

	local entityList = ListPool.getList(3)
	local count = AIUtils.SearchEntitiesInRangeWithCache(self, AiConst.TrapNearBy.distance, Const.SEARCH_USR_TYPE_MONSTER, entityList)

	if entityList then
		local myPos = self:getPosition()

		for i = 1, count do
			local actorId = entityList[i]
			local entity = pg.getEntityByActorId(actorId)

			if entity and math.abs(entity:getPosition().y - myPos.y) < AiConst.TrapNearBy.height then
				local context2 = CTRPool.getContext()

				context2.targetActorId = self.actorId

				AIControllerUtils.sendAIEvent(entity, "OnNearByEntityTrapped", context2)
			end
		end
	end

	ListPool.returnList(entityList, 3)
end

function AIComponent:EVENT_CancelTrapped(ballMasterActorId)
	self:resumeBt(AiConst.PauseBtReason.Capture)
	AIControllerUtils.resume(self, AiConst.AIControllerDisableReason.BeCaptured)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:log2Tag("AI", "CatchResult_Failure 事件已发送")
	end

	local context2 = CTRPool.getContext()

	context2.ballMasterActorId = ballMasterActorId

	AIControllerUtils.sendAIEvent(self, "CatchResult_Failure", context2)
end

function AIComponent:onAIPlanFinish(planType, planId, flowFinishType)
	if Utils.checkClient() and self.staticId and pg.me:getEntityAIEventInfo(self.staticId, planId) then
		facade:sendLuaEvent("SandboxEntityAIEvent", self.staticId, planId, flowFinishType)
	end
end

function AIComponent:onExitAfkMode()
	if Utils.checkClient() then
		AIControllerUtils.sendAIEvent(self, "Msg_Pet_AfkExit")
		AIUtils.enterIdle(self)
		self:cancelForceRunBt(AiConst.ForceRunBtReason.AFKMode)
	end
end

function AIComponent:onEnterAfkMode()
	if Utils.checkClient() then
		self:forceRunBt(AiConst.ForceRunBtReason.AFKMode)
		AIUtils.enterAfk(self)
	end
end

function AIComponent:onAIStateChange(oldRootState, newRootState, oldBehaviorState, newBehaviorState)
	self.aiState = newRootState
	self.behaviorState = newBehaviorState

	if Utils.checkClient() and self.agent and not Utils.isVirtualEntity(self) and Utils.checkIsAuthorityMaster(self) and oldRootState ~= newRootState then
		self:serverMsgNoGC("RPC_CS_SyncAIState", newRootState)
	end
end

function AIComponent:Event_OnLeaveTeam()
	if Utils.checkClient() and Utils.isPet(self, true) then
		clientUtils.exitAfkMode()
	end
end

function AIComponent:Event_OnJoinTeam()
	if Utils.checkClient() and Utils.isPet(self, true) then
		clientUtils.exitAfkMode()
	end
end

function AIComponent:EVENT_OnHideShowEntityDictChange()
	if Utils.checkClient() then
		if clientUtils.checkIsHideEntity(self) then
			AIUtils.pauseBt(self, AiConst.PauseBtReason.HideShowEntityDic)
		else
			AIUtils.resumeBt(self, AiConst.PauseBtReason.HideShowEntityDic)
		end
	end
end

function AIComponent:EVENT_ConfigDataChange()
	if not AIControllerUtils.checkOpen(self) then
		AIUtils.resumeBt(self, AiConst.PauseBtReason.SkeletonLoaded)
	end
end

function AIComponent:onSkeletonLoaded()
	AIUtils.resumeBt(self, AiConst.PauseBtReason.SkeletonLoaded)
end

function AIComponent:onSkeletonUnloaded()
	AIUtils.pauseBt(self, AiConst.PauseBtReason.SkeletonLoaded)
end

function AIComponent:saveLastPatrolInfo(patrolId, patrolIndex)
	self.AI.lastPatrolId = patrolId
	self.AI.lastPatrolIndex = patrolIndex
end

function AIComponent:checkLastPatrolInfo(patrolId)
	if self.AI.lastPatrolId == patrolId then
		return true, self.AI.lastPatrolIndex
	end

	return false
end

function AIComponent:processRootStateMessage(force)
	local currentRootState = self.agent:getRootState()

	if Utils.isPet(self) then
		if currentRootState == EBTRootState.ST_Root_Idle then
			self:_sendStateFreeMessage("IdleMsgTrigger", force)
		end
	elseif Utils.isPuppet(self) then
		if currentRootState == EBTRootState.ST_Root_Idle then
			self:_tempSendMsgVision()
			self:_sendStateFreeMessage("IdleMsgTrigger", force)
			self:_perceptFullSendMsgToBrother()
		elseif currentRootState == EBTRootState.ST_Root_Alert then
			self:_sendStateFreeMessage("AlertMsgTrigger", force)
			self:_perceptFullSendMsgToBrother()
		elseif currentRootState == EBTRootState.ST_Root_Sensed then
			self:_sendStateFreeMessage("SensedMsgTrigger", force)
			self:_perceptFullSendMsgToBrother()
		end
	elseif Utils.isVirtualEntity(self) and currentRootState == EBTRootState.ST_Root_Idle then
		self:_sendStateFreeMessage("IdleMsgTrigger", force)
	end
end

function AIComponent:_sendStateFreeMessage(msgName, force)
	if force or self.getCurrentAIParmonPlan and not self:getCurrentAIParmonPlan() then
		AIControllerUtils.sendAIEvent(self, msgName)
	end
end

function AIComponent:_perceptFullSendMsgToBrother()
	if not self.getMaxPerceptibility then
		return
	end

	local _, perceptVal = self:getMaxPerceptibility()
	local configData = self:getConfigData()
	local stage = configData and configData.stage
	local ethnicGroup = configData and configData.ethnicGroup or 0
	local partnerEnterCombatDis = configData and configData.partnerEnterCombatDis or 0

	if perceptVal >= 100 and stage == 1 and partnerEnterCombatDis > 0 then
		local entityList = ListPool.getList(3)
		local count = AIUtils.SearchEntitiesInRangeWithCache(self, partnerEnterCombatDis, Const.SEARCH_USR_TYPE_MONSTER, entityList)

		for i = 1, count do
			local actorId = entityList[i]
			local targetEntity = pg.getEntityByActorId(actorId)

			if targetEntity then
				local targetConfigData = targetEntity:getConfigData()
				local targetStage = targetConfigData and targetConfigData.stage or 0
				local targetEthnicGroup = targetConfigData and targetConfigData.ethnicGroup or 0

				if ethnicGroup == targetEthnicGroup and targetStage >= 2 then
					local context = CTRPool.getContext()

					context.sourceActorId = self.actorId

					AIControllerUtils.sendAIEvent(targetEntity, "Msg_Full_ToBrother", context)
				end
			end
		end

		ListPool.returnList(entityList, 3)
	end
end

function AIComponent:_tempSendMsgVision()
	if not self.getMaxPerceptibility or not self.hasAITag or not self.removeAITag then
		return
	end

	local perceptActorId, perceptVal = self:getMaxPerceptibility()
	local hasTA_VisionAlert = self:hasAITag("TA_VisionAlert")
	local hasTA_VisionFull = self:hasAITag("TA_VisionFull")

	if perceptVal <= 0 then
		if hasTA_VisionAlert or hasTA_VisionFull then
			self:removeAITag("TA_VisionAlert")
			self:removeAITag("TA_VisionFull")
		else
			local context = CTRPool.getContext()

			context.sourceActorId = self.actorId

			AIControllerUtils.sendAIEvent(self, "VisionValue_None", context)
		end
	elseif perceptVal > 10 and perceptVal <= 99 and not hasTA_VisionAlert and not hasTA_VisionFull then
		local context = CTRPool.getContext()

		context.sourceActorId = self.actorId
		context.sensorTgtId = perceptActorId

		AIControllerUtils.sendAIEvent(self, "VisionValue_Alert", context)
	elseif perceptVal >= 100 and not hasTA_VisionFull then
		local context = CTRPool.getContext()

		context.sourceActorId = self.actorId
		context.sensorTgtId = perceptActorId

		AIControllerUtils.sendAIEvent(self, "VisionValue_Full", context)
	end
end

function AIComponent:addAITag(tagName)
	if not Utils.checkIsAuthorityMaster(self) then
		return
	end

	self.AI.aiTags[tagName] = true

	local context = CTRPool.getContext()

	context.tag = tagName

	AIControllerUtils.sendAIEvent(self, "OnAITagAddMsgTrigger", context)
end

function AIComponent:removeAITag(tagName)
	if not Utils.checkIsAuthorityMaster(self) then
		return
	end

	self.AI.aiTags[tagName] = nil

	local context = CTRPool.getContext()

	context.tag = tagName

	AIControllerUtils.sendAIEvent(self, "OnAITagRemoveMsgTrigger", context)
end

function AIComponent:hasAITag(tagName)
	return self.AI.aiTags[tagName] == true
end

function AIComponent:getAITagInfo()
	local tags = {}

	if self.AI.aiTags then
		for tag, _ in pairs(self.AI.aiTags) do
			tags[#tags + 1] = tag
		end
	end

	return tags
end

function AIComponent:updateAIHatredList(hatredList)
	for _, hatredInfo in pairs(self.hatredMap) do
		hatredList:Add(string.format("actorId %d hatredValue %.1f", hatredInfo.actorId, hatredInfo.hatredValue))
	end
end

function AIComponent:EVENT_OnEnterVehicle(vehicle, seatId)
	self:pauseBt(AiConst.PauseBtReason.Vehicle)
end

function AIComponent:EVENT_OnExitVehicle(vehicle, seatId)
	self:resumeBt(AiConst.PauseBtReason.Vehicle)
end

function AIComponent:getBubbleRoutePoints()
	local sceneId = self.space and self.space.sceneId
	local spaceId = self.space and self.space.id
	local sceneEntityData = SceneUtils.getSceneEntityData(sceneId, spaceId)
	local bubbleRouteId = table.safe_get(sceneEntityData, self.staticId, "bubbleRouteId")

	if not bubbleRouteId then
		return
	end

	local sceneRouteData = SceneUtils.getSceneRouteData(sceneId, spaceId)
	local waypoints = table.safe_get(sceneRouteData, bubbleRouteId, "wayPoints") or {}

	if not waypoints then
		return
	end

	local ret = {}

	for _, waypoint in pairs(waypoints) do
		table.insert(ret, waypoint.position[1])
		table.insert(ret, waypoint.position[2])
		table.insert(ret, waypoint.position[3])
	end

	return ret
end

function AIComponent:tryTickPerception()
	if self.perceptibility then
		local visionSensor = self.perceptibility.visionSensor
		local noImpVisionSensor = self.perceptibility.noImpVisionSensor

		if visionSensor then
			visionSensor:updateVisionByAI()
		end

		if noImpVisionSensor then
			noImpVisionSensor:updateNoImpVisionByAI()
		end
	end
end

return AIComponent
