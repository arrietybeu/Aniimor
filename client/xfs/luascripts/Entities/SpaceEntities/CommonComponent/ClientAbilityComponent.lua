-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientAbilityComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ActionTimelineParams = require("Common.Ability.Timeline.ActionTimelineParams")
local MessageName = require("Const.MessageName")
local TimerManager = require("Core.Timer.TimerManager")
local WeakRefCallbackHandle = require("Core.Common.WeakRefCallbackHandle")
local Const = require("Common.Const.Const")
local COMBAT_STATUS_IN_COMBAT = Const.COMBAT_STATUS_IN_COMBAT
local AbilityComponent = require("Common.Components.AbilityComponent")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local TagMask = CS.FunPlus.WorldX.Animations.TagMask
local PhysicsLayerConst = require("Common.Const.PhysicsLayerConst")
local AttributeConst = require("Common.Const.AttributeConst")
local AbilityConst = require("Common.Const.AbilityConst")
local ClientAbilityConst = require("Const.ClientAbilityConst")
local TICK_LOD = ClientAbilityConst.TICK_LOD
local Bitset = require("Common.Bitset")
local ClientDebugUtils = require("Utils.ClientDebugUtils")
local Utils = require("Common.Utils.Utils")
local CalcUtils = require("Common.Utils.CalcUtils")
local Mathf = require("Common.Math.Mathf")
local InputCommand = require("GameApp.Input.InputCommand")
local Time = require("Core.Common.Time")
local ActorBuff = require("Common.Ability.Buff.ActorBuff")
local ActorCombatAttribute = require("Common.Ability.Attribute.ActorCombatAttribute")
local ActorTimeline = require("Common.Ability.Timeline.ActorTimeline")
local EditorActorTimeline = require("Common.Ability.Timeline.EditorActorTimeline")
local CombatContext = require("Common.Ability.CombatContext")
local CombatActionTool = require("Common.Ability.CombatActionTool")
local ClientAbilityUtils = require("Utils.ClientAbilityUtils")
local ClientUtils = require("Utils.ClientUtils")
local ConflictTypes = require("Common.ConflictTypes")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local Layer = require("Common.Const.PhysicsLayerConst")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local EventConst = require("Const.EventConst")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local PuppetData = require("Data.puppet_data")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local ChainAttackBP = require("Common.Data.SkillBPData.chain_attack_BP")
local CombatHitResult = require("Common.Ability.CombatHitResult")
local ClientSwitch = require("Common.ClientSwitch")
local Switch = require("Core.Common.Switch")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local ClientEffectUtils = require("Utils.ClientEffectUtils")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local AiConst = require("Common.Const.AiConst")
local SweepData = require("Common.Ability.SweepData")
local RigidbodyData = require("Data.rigidbody_data")
local SandboxConst = require("Common.Const.SandboxConst")
local ReboundDashControl = require("GameApp.Ability.ReboundDashControl")
local ProjAroundSelfControl = require("GameApp.Ability.ProjAroundSelfControl")
local CollisionHitRecordSet = require("Common.Ability.CollisionHitRecordSet")
local CombatLogger = require("Common.Ability.CombatLogger")
local TriggerConst = require("Common.Const.TriggerConst")
local EffectConst = require("Const.EffectConst")
local ActorInterface = require("Common.Ability.Attribute.ActorInterface")
local ImpulseData = require("Data.impulse_data")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ListPool = require("Common.Container.ListPool")
local AIUtils = require("Common.Utils.AIUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local BuffUIUtils = require("Utils.BuffUIUtils")
local EModelUtils = require("Entities.Utils.EModelUtils")
local EnumAbilityType = AbilityConst.EnumAbilityType
local PhysxComponent = CS.FunPlus.WorldX.Entities.Components.PhysxComponent
local VineRigComponent = CS.FunPlus.WorldX.Animations.VineAbilityComponent
local HookAbilityComponent = CS.FunPlus.WorldX.Animations.HookAbilityComponent
local StableGroundLayers = CS.FunPlus.WorldX.Const.LayerDefine.STABLE_GROUND_LAYERS
local AvatarData = require("Data.avatar_data")
local PetData = require("Data.pet_data")
local SysConfigData = require("Data.sys_config_data")
local BuffTagGroupData = require("Common.Data.SkillBPData.buff_tag_group_data")
local lume = require("Core.Common.lume")
local TablePool = require("Common.Container.TablePool")
local typeof = typeof
local Vector3 = Vector3
local Quaternion = Quaternion
local ToBool = ToBool
local VEC3_CONST_UP = Vector3.constUp
local VEC3_CONST_FORWARD = Vector3.constForward
local pg = pg
local IsNil = IsNil
local bit = bit
local NotNil = NotNil
local lshift = bit.lshift
local EnableBotTest = EnableBotTest
local UIUtils = UIUtils
local ClientAbilityComponent = Class.Component("ClientAbilityComponent", AbilityComponent)

function ClientAbilityComponent:ctor()
	ClientAbilityComponent.super.ctor(self)

	self.projectile2EffectMap = {}
	self.longPressAbilityMap = {}
	self.inSkillAim = false
	self.abilityEffectMap = {}
	self.abilitySoundMap = {}
	self.abilityCameraEventMap = {}
	self.dynamicRigMap = {}
	self.abilitySwitchInfo = {}
	self.abilityCountDownInfo = {}
	self.hitSetGroup = {}
	self.collisionHitRecordSet = CollisionHitRecordSet()
	self.ignoreLockDistanceCheck = false
	self.abilityMotionInfos = {}
	self.sweepRecordMap = {}
	self.projectileIdGen = 0
	self.createProjFromAniCallback = {}
	self.ghostEyeDetected = false
	self.characterStateConditionalEffects = {}
	self.characterStateConditionalVolumes = {}
	self.lastPositionAgentPos = Vector3.zero
	self.dynamicListMap = {}
	self.wonColor = 0
	self.isInBuffControlST = false
	self.isBuffForbidAbility = false
end

function ClientAbilityComponent:init(dict)
	ClientAbilityComponent.super.init(self, dict)

	self.combatContextIdGen = AbilityConst.CLIENT_COMBAT_CONTEXT_ID_MIN
	self.enableAbilityCheck = dict.enableAbilityCheck

	local abilityManager = pg.global.abilityMgr

	self.actorBuff = ActorBuff(self, abilityManager)
	self.buffStates = dict.buffStates
	self.serverAbilityCacheVal = dict.serverAbilityCacheVal

	if Utils.isVirtualEntity(self) then
		VirtualEntUtils.setDefaultAbility(self, dict)

		self.actorCombatAttribute = ActorCombatAttribute(ActorInterface(self), abilityManager.actorAttributeModifier)
	else
		self.actorCombatAttribute = ActorCombatAttribute(ActorInterface(self), abilityManager.actorAttributeModifier)
	end

	self:initAbilityDynamicRigComponentMap()

	self.attachMap = dict.attachMap or {}

	if self.updateAttachMap then
		self:updateAttachMap()
	end

	self.attachInfo = dict.attachInfo

	if dict.baseAttrMap ~= nil then
		for attributeId, value in pairs(dict.baseAttrMap) do
			self.baseAttr[attributeId] = value
		end
	end

	if dict.dynamicListMap ~= nil then
		for listId, value in pairs(dict.dynamicListMap) do
			self.dynamicListMap[listId] = value
		end
	end

	if dict.wonColor ~= nil then
		self.wonColor = dict.wonColor
	end

	if dict.attackTargetActorId then
		self.attackTargetActorId = dict.attackTargetActorId
	end

	self.abilityCompInitTriggerDone = EnableBotTest
	self.dynamicParentRPCStateMap = {}
	self.dynamicRPCStateMap = {}

	if self.hasBornState then
		self:addDynamicRPCState({
			CharacterStateConst.getParentState(self.motionState)
		})
	end

	return true
end

function ClientAbilityComponent:updateHitBoxParam()
	ClientAbilityComponent.super.updateHitBoxParam(self)

	if Switch.EnableDrawHitBox then
		self:enableDrawActorHitBox(true)
	end
end

function ClientAbilityComponent:startAbilityCompTriggers()
	if self.abilityCompInitTriggerDone then
		return
	end

	for abilityId, ability in pairs(self.abilityMap or EMPTY_TABLE) do
		ability:registerCastingInfo()
		ability:onAbilityAdded()
	end

	for abilityId, ability in pairs(self.stolenAbilityMap or EMPTY_TABLE) do
		ability:registerCastingInfo()
		ability:onAbilityAdded()
	end

	for _, ability in pairs(self.callFriendsAbilityMap or EMPTY_TABLE) do
		ability:registerCastingInfo()
		ability:onAbilityAdded(false)
	end

	if self.buffDataList then
		for index, buffData in ipairs(self.buffDataList) do
			if not self.actorBuff:findBuff(buffData.instanceId) then
				self.actorBuff:addBuff(buffData, false)
				self:recordOnAddBuff(buffData)
			end
		end
	end

	if self.buffStates then
		self:doUpdateBuffStates(self.buffStates)
	end

	self.buffStates = nil

	facade:SendMessageCommand(MessageName.BUFF_CHANGE, {
		entId = self.id
	})
	self.eventEmitter:emit(EventConst.ON_BUFF_CHANGE)

	self.abilityCompInitTriggerDone = true

	if self.abilityInitTriggerCallbacks then
		for _, fun in ipairs(self.abilityInitTriggerCallbacks) do
			local result, info = xpcall(fun, debug.traceback)

			if not result then
				CombatLogger.error(info)
			end
		end

		self.abilityInitTriggerCallbacks = nil
	end
end

function ClientAbilityComponent:start()
	ClientAbilityComponent.super.start(self)
	self:initNorAtkAbilityList(CharacterStateConst.isChildOfState(self.characterState, CharacterStateConst.FLYING))

	if not self.curBp then
		self.actorCombatAttribute:registerAttributeNotify(AttributeConst.bp_cur, self.onBpChange)
		self.actorCombatAttribute:registerAttributeNotify(AttributeConst.bp_max_cur, self.onBpChange)
	end

	if self.serverAbilityCacheVal then
		for abilityId, cacheValMap in pairs(self.serverAbilityCacheVal) do
			local ability = self.abilityMap[abilityId]
			local abilityObject = ability:getAbilityObject()

			for k, v in pairs(cacheValMap) do
				abilityObject.cacheValMap[k] = v
			end
		end
	end

	self.serverAbilityCacheVal = nil

	if Switch.EnableDrawRbCollider then
		self:enableDrawRbCollider(true)
	end

	if Switch.EnableDrawRbCatchCollider then
		self:enableDrawRbCatchCollider(true)
	end

	if self.useHitBox then
		pg.me.useHitBoxEntityCnt = (pg.me.useHitBoxEntityCnt or 0) + 1
	end

	if self.attachInfo and self.beStick then
		local targetActor, offsetPos, rotation = unpack(self.attachInfo)
		local targetEntity = pg.getEntityByActorId(targetActor)

		if targetEntity and self.eModel then
			self.eModel:AttachByCurrentPos(Const.COMPONENT_ATTACH, targetEntity.eModel, offsetPos, rotation, 1000)
		end

		self:beStick()
	end

	for actorId, attachInfo in pairs(self.attachMap) do
		local offsetPos, rotation = unpack(attachInfo)
		local targetEntity = pg.getEntityByActorId(actorId)

		if targetEntity and targetEntity.beStick and targetEntity.eModel then
			targetEntity.eModel:AttachByCurrentPos(Const.COMPONENT_ATTACH, self.eModel, offsetPos, rotation, 1000)
			targetEntity:beStick()
		end
	end

	if Utils.isPlayer(self) then
		self.hitTriggerRecord = {}

		if self.authority == Const.AUTHORITY_MASTER then
			self:serverMsg("RPC_CS_StopCombatActionTimeline", false)
		end
	end

	self.isBossElite = Utils.isBoss(self) or Utils.isElite(self)

	self:initBuffControlST()
end

function ClientAbilityComponent:addAbilityInitTriggerCallbacks(fun)
	if not self.abilityInitTriggerCallbacks then
		self.abilityInitTriggerCallbacks = {}
	end

	table.insert(self.abilityInitTriggerCallbacks, fun)
end

function ClientAbilityComponent:DC_OnKCCMove(velocity)
	self:updateProjAroundSelfControl()

	local deltaSeconds = Time.unscaledDeltaTime * self:getSelfTimeScale()

	if velocity > 0 and self.subject:isEventListening(AbilityConst.COMBAT_EVENT_ON_PAWN_MOVED_DISTANCE_REACH_THRESHOLD) then
		local eventData = self:getEntityCacheVal(AbilityConst.COMBAT_EVENT_ON_PAWN_MOVED_DISTANCE_REACH_THRESHOLD)
		local onlyConsiderXZ = eventData.onlyConsiderXZ
		local movedDistance = onlyConsiderXZ and Vector3.HoriDistance(self:getLastPosition(), self:getPosition()) or Vector3.Distance(self:getLastPosition(), self:getPosition())
		local hasMovedDistance = eventData.hasMovedDistance + movedDistance

		eventData.hasMovedDistance = hasMovedDistance

		if hasMovedDistance >= eventData.threshold then
			self:serverMsgNoGC("RPC_CS_OnPawnMovedDistanceReachThreshold")
			self.subject:notify(AbilityConst.COMBAT_EVENT_ON_PAWN_MOVED_DISTANCE_REACH_THRESHOLD)

			eventData.hasMovedDistance = 0
		end
	end

	if ToBool(self.abilityCollisionTestInfo) then
		self:tickAbilityCollisionTest(deltaSeconds)
	end
end

function ClientAbilityComponent:updateProjAroundSelfControl()
	local player = Utils.getMasterPlayer(self)
	local deltaSeconds = Time.unscaledDeltaTime * self:getSelfTimeScale()

	if player and player.projAroundSelfControl then
		player.projAroundSelfControl:tick(deltaSeconds)
	end
end

function ClientAbilityComponent:updateMovingState(deltaSecond)
	local lastIsMoving = self.isPositionMoved

	Vector3.enableCreateFromCache()

	local curPos = self:getPositionAgentPosition()

	self.isPositionMoved = Vector3.SqrDistance(self.lastPositionAgentPos, curPos) > 0.0001

	self.lastPositionAgentPos:Set(curPos.x, curPos.y, curPos.z)
	Vector3.disableCreateFromCache()

	if lastIsMoving ~= self.isPositionMoved then
		self.subject:notify(AbilityConst.COMBAT_EVENT_ON_MOVE_CHANGE, self.isPositionMoved)
	end
end

function ClientAbilityComponent:initAbilityDynamicRigComponentMap()
	if EnableBotTest then
		return
	end

	self.dynamicRigCompTypeMap = {
		[AbilityConst.RIG_TYPE_VINE_CHAIN] = typeof(VineRigComponent),
		[AbilityConst.RIG_TYPE_HOOK_SPRINT] = typeof(HookAbilityComponent)
	}
end

function ClientAbilityComponent:getAbilityTickDelta()
	local positionRef = rawget(self, "posRef")

	if not positionRef then
		return math.huge
	end

	if self.allowLodTick and self.combatStatus ~= COMBAT_STATUS_IN_COMBAT then
		local playerPos = pg.playerPos

		if not playerPos then
			return math.huge
		end

		local disSqr = Vector3.HoriSqrDistance(playerPos, positionRef)

		for idx, dis in ipairs(TICK_LOD[1]) do
			if dis < disSqr then
				return TICK_LOD[2][idx]
			end
		end
	end

	return 0
end

function ClientAbilityComponent:inKnockUp()
	return self.skillStateMgr.states[AbilityConst.SKILL_STATE_KNOCK_UP]:getState() > AbilityConst.KNOCK_STATE_BACK
end

function ClientAbilityComponent:inKnockUpStartLoop()
	local knockState = self.skillStateMgr.states[AbilityConst.SKILL_STATE_KNOCK_UP]:getState()

	return knockState == AbilityConst.KNOCK_STATE_UP_START or knockState == AbilityConst.KNOCK_STATE_UP_LOOP
end

function ClientAbilityComponent:inKnockUpEnd()
	local knockState = self.skillStateMgr.states[AbilityConst.SKILL_STATE_KNOCK_UP]:getState()

	return knockState == AbilityConst.KNOCK_STATE_UP_END
end

function ClientAbilityComponent:checkAbilityTimer()
	local timerMgr = self.abilityTimerMgr

	if EnableBotTest or not timerMgr then
		return
	end

	if next(self.abilityTickRefMap) then
		if not rawget(self, "abilityTimer") then
			self.tickAbilitySecond = self:getGameTime()
			self.abilityTimer = timerMgr:addRepeatTimer(WeakRefCallbackHandle.new(function(self)
				local curTime = self:getGameTime()
				local deltaTime = curTime - self.tickAbilitySecond

				if deltaTime < 0 then
					self.tickAbilitySecond = curTime

					return
				end

				if self.isBossElite ~= true and deltaTime < self:getAbilityTickDelta() then
					return
				end

				self.tickAbilitySecond = curTime

				self:tickAbility(deltaTime)
			end, self))
		end
	else
		self:stopAbilityTimer()
	end
end

function ClientAbilityComponent:stopAbilityTimer()
	local timerId = rawget(self, "abilityTimer")

	if not timerId then
		return
	end

	self.abilityTimer = nil

	if self.abilityTimerMgr then
		self.abilityTimerMgr:removeRepeatTimer(timerId)
	end
end

function ClientAbilityComponent:onEnterSpace()
	AbilityComponent.onEnterSpace(self)

	if EnableBotTest then
		return
	end

	self.abilityTimerMgr = self.space and self.space.abilityTimerMgr

	self:checkAbilityTimer()

	if Utils.isPuppet(self) then
		local lockActorId = AIUtils.getPuppetTarget(self)
		local lockEntity = pg.getEntityByActorId(lockActorId)

		if lockEntity then
			AIUtils.attackTarget(self, lockActorId)
		end
	end

	local preloadMatEffs = self:getConfigData().preloadMatEffs

	if preloadMatEffs then
		for i = 1, 2 do
			local matEff = preloadMatEffs[i]

			if matEff then
				self.eModel.shaderView:AddPreloadMaterialEffect(matEff)
			end
		end
	end
end

function ClientAbilityComponent:onSeamlessPostEnterSpace()
	self:preparePreloadInfo()
end

function ClientAbilityComponent:onSkeletonUnloaded()
	self.abilityCompInitTriggerDone = false
end

function ClientAbilityComponent:EVENT_OnModelRefreshed()
	self:preparePreloadInfo()

	if self.isCamouflage and self.eModel and Utils.isEnemy(self, pg.pawn) then
		self.eModel:HideEffect(Const.COMPONENT_INDEX_EFFECT)
	end

	self:refreshCamouFlageMats(self.isCamouflage, 0)
	self:refreshFootPrintVisible()
	pg.global.abilityMgr:onEntityLoaded(self)

	if self.inShapeShift then
		self.subject:notify(AbilityConst.COMBAT_EVENT_ON_SHAPE_SHIFT_MODEL_REFRESHED)
	end
end

function ClientAbilityComponent:EVENT_OnModelScaleChanged()
	if Switch.EnableDrawHitBox then
		self:enableDrawActorHitBox(true)
	end
end

function ClientAbilityComponent:EVENT_OnEntityBeAttached()
	self:cancelAbility()

	local lockActorId = self:getAttackTargetActorId()
	local attachToEntity = pg.getEntity(self.attachTargetEntId)

	if attachToEntity and lockActorId == attachToEntity.actorId then
		self:unlockTarget(true)
	end
end

function ClientAbilityComponent:getCombatContextFromCache(ctxType, id)
	if self.authority ~= Const.AUTHORITY_MASTER then
		local idGen = id - self.actorId * 32768

		if idGen >= AbilityConst.CLIENT_COMBAT_CONTEXT_ID_MIN and idGen <= AbilityConst.CLIENT_COMBAT_CONTEXT_ID_MAX then
			if idGen + 100 >= AbilityConst.CLIENT_COMBAT_CONTEXT_ID_MAX then
				self.combatContextIdGen = AbilityConst.CLIENT_COMBAT_CONTEXT_ID_MIN + 100
			else
				idGen = self.combatContextIdGen + 100
			end
		end
	end

	return AbilityComponent.getCombatContextFromCache(self, ctxType, id)
end

function ClientAbilityComponent:onEnterCombat()
	if self == pg.me and Utils.isSpaceRogueDungeon(self.space.spaceType) then
		facade:sendMsgToUI(MessageName.REFRESH_SKILL_GRAY)
	end

	if Utils.isPuppet(self) then
		local lockActorId = AIUtils.getPuppetTarget(self)
		local lockEntity = pg.getEntityByActorId(lockActorId)

		if lockEntity then
			AIUtils.attackTarget(self, lockActorId)
		end
	end

	facade:sendMsgToUI(MessageName.ENT_COMBAT_STATUS_CHANGED, {
		switch = true,
		actorId = self.actorId
	})
end

function ClientAbilityComponent:onLeaveCombat()
	if self == pg.me then
		if Utils.isSpaceRogueDungeon(self.space.spaceType) then
			facade:sendMsgToUI(MessageName.REFRESH_SKILL_GRAY)
		end

		pg.game.controller.lockHelper:resetLockDis()
	end

	facade:sendMsgToUI(MessageName.ENT_COMBAT_STATUS_CHANGED, {
		switch = false,
		actorId = self.actorId
	})
end

function ClientAbilityComponent:onLeaveSpace()
	self:stopAbilityTimer()

	self.abilityTimerMgr = nil
end

function ClientAbilityComponent:preDestroy()
	self:stopAbilityTimer()

	self.abilityTimerMgr = nil

	self:removeFlashlightTrigger(nil)
end

function ClientAbilityComponent:destroy()
	self:stopAbilityTimer()

	self.abilityTimerMgr = nil

	ClientAbilityUtils.unPreloadAllAbility(self)
	ClientAbilityComponent.super.destroy(self)

	if self.actorBuff and self.actorBuff.buffMap then
		for _, buff in pairs(self.actorBuff.buffMap) do
			buff:clearObject()
		end
	end

	if self.subject then
		self.subject:clear()
	end

	if self.useHitBox then
		pg.me.useHitBoxEntityCnt = pg.me.useHitBoxEntityCnt - 1
	end

	self.hookSprintData = nil

	self:clearForbidUltimateForAWhile()

	self.projHitPos = nil
end

function ClientAbilityComponent:onAbilityActivate(deltaSeconds)
	if rawget(self, "rotateToData") then
		self:tickRotateTo(deltaSeconds)
	end

	if rawget(self, "moveByInputData") then
		self:tickMoveByInput(deltaSeconds)
	end

	if rawget(self, "scrollWithInputData") then
		self:tickScrollWithInput(deltaSeconds)
	end

	if rawget(self, "moveByDirectionData") then
		self:tickMoveByDirection(deltaSeconds)
	end

	if rawget(self, "skillHitDisplacementCtrl") then
		self.skillHitDisplacementCtrl:update(deltaSeconds)
	end

	if rawget(self, "reboundDashData") and self.authority == Const.AUTHORITY_MASTER then
		self.marblesControl:tick(deltaSeconds)
	end

	AbilityComponent.onAbilityActivate(self, deltaSeconds)
end

function ClientAbilityComponent:checkCanCastAbility(abilityId, targetActorId, castSource, context, cancelStates, extraInfo)
	if extraInfo and extraInfo.isFromServer then
		return true, AbilityConst.ABILITY_CAST_FAILED_NONE
	end

	if self.authority ~= Const.AUTHORITY_MASTER then
		return false, AbilityConst.ABILITY_CAST_FAILED_FAULT
	end

	return AbilityComponent.checkCanCastAbility(self, abilityId, targetActorId, castSource, context, cancelStates, extraInfo)
end

function ClientAbilityComponent:checkAbilityWaterCost(abilityId)
	if AbilityUtils.isUseWaterExploreAbility(self, abilityId) and self.actorCombatAttribute:getCurWater() < AbilityUtils.getAbilityParamWaterCost(self, abilityId) then
		return false, AbilityConst.ABILITY_CAST_ABILITY_NOT_ENOUGH_WATER
	end

	return true, nil
end

function ClientAbilityComponent:checkCanRespondChainChance()
	if self:getSp() < 100 then
		return false
	end

	local curPetEnt = self:getCurPetEntity()

	if not curPetEnt then
		return false
	end

	local ultimateAbilityId = curPetEnt:getSkillIdByType(AbilityConst.ULTIMATE_ABILITY)

	if not ToBool(curPetEnt:checkAbilityCd(ultimateAbilityId)) then
		return false
	end

	return true
end

function ClientAbilityComponent:genCombatContextId()
	for i = 1, 50 do
		local id = self.combatContextIdGen + self.actorId * 32768

		self.combatContextIdGen = self.combatContextIdGen + 1

		if self.combatContextIdGen >= AbilityConst.CLIENT_COMBAT_CONTEXT_ID_MAX then
			self.combatContextIdGen = AbilityConst.CLIENT_COMBAT_CONTEXT_ID_MIN
		end

		if not self:getCombatContext(id) then
			return id
		end
	end
end

function ClientAbilityComponent:onAbilityEnd(ability)
	local combatContext = ability:getAbilityObject().combatContext
	local targetActorId = combatContext and combatContext.constCasterInfo.targetActorId or 0

	AbilityComponent.onAbilityEnd(self, ability)

	local abilityId = ability.abilityId

	self:clearAbilityEffectMap(abilityId)
	self:clearAbilitySound(abilityId)
	self:resetAbilityCameraEvent(abilityId)
	self:clearAbilityAnimState(abilityId)

	self.ignoreLockDistanceCheck = false

	if ability:isStolenAbility() and self.deformData then
		self:deformTo()
	end

	facade:SendMessageCommand(MessageName.ABILITY_END, {
		self,
		ability
	})

	if AbilityUtils.isUltimateAbility(abilityId) then
		AIUtils.resumeBt(self, AiConst.PauseBtReason.UltimateAbility)
	end

	self:sendAbilityNoHit(targetActorId, ability)

	local skillHitDisplacementCtrl = rawget(self, "skillHitDisplacementCtrl")

	if skillHitDisplacementCtrl then
		local skillHitDisplacementAbility = skillHitDisplacementCtrl.combatContext and skillHitDisplacementCtrl.combatContext:ability()

		if skillHitDisplacementAbility == ability then
			skillHitDisplacementCtrl:resetAll()
		end
	end
end

function ClientAbilityComponent:sendAbilityNoHit(targetActorId, ability)
	if self.castingAbilityActOnTargetHit ~= true and ToBool(targetActorId) and (self.isMainPet or Utils.isPuppet(self)) then
		local abilityTemplate = ability:getAbilityTemplate()

		if abilityTemplate.onlyHasActOnTargets then
			AIControllerUtils.sendAIEvent(self, "AbilityNoHit")

			self.castingAbilityActOnTargetHit = true
		end
	end
end

function ClientAbilityComponent:setCastingCombatCcontextId(abilityId, castingCombatContextId)
	if self:isCastingAbility(abilityId) and ToBool(castingCombatContextId) and self.castingCombatContextId ~= castingCombatContextId then
		self.castingCombatContextId = castingCombatContextId
		self.castingAbilityActOnTargetHit = nil
	end
end

function ClientAbilityComponent:addAbilityEffect(targetActorId, casterActorId, abilityId, effectId, isGlobal)
	if not ToBool(effectId) then
		return
	end

	if abilityId and self.actorId == targetActorId and self.actorId == casterActorId then
		if self.abilityEffectMap[abilityId] == nil then
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				self.logger:debug("add abilityEffect map", self.actorId, abilityId, effectId, isGlobal)
			end

			self.abilityEffectMap[abilityId] = {}
		end

		table.insert(self.abilityEffectMap[abilityId], {
			effectId,
			isGlobal
		})
	end
end

function ClientAbilityComponent:clearAbilityEffectMap(abilityId)
	local map = self.abilityEffectMap[abilityId]

	if map ~= nil then
		for _, effectInfo in ipairs(map) do
			local effectId = effectInfo[1]
			local isGlobal = effectInfo[2]

			if not isGlobal then
				if LoggerManager.checkLogger(LoggerConst.DEBUG) then
					self.logger:debug("stopEffect", self.actorId, abilityId, effectId)
				end

				self:stopEffectById(effectId)
			else
				if LoggerManager.checkLogger(LoggerConst.DEBUG) then
					self.logger:debug("stop global Effect", self.actorId, abilityId, effectId)
				end

				pg.game.effect:stopEffect(0, effectId)
			end
		end
	end

	self.abilityEffectMap[abilityId] = {}
end

function ClientAbilityComponent:addAbilitySound(targetActorId, casterActorId, abilityId, soundStr)
	if not ToBool(soundStr) then
		return
	end

	if abilityId and self.actorId == targetActorId and self.actorId == casterActorId then
		if self.abilitySoundMap[abilityId] == nil then
			self.abilitySoundMap[abilityId] = {}
		end

		table.insert(self.abilitySoundMap[abilityId], soundStr)
	end
end

function ClientAbilityComponent:clearAbilitySound(abilityId)
	if not self.abilitySoundMap[abilityId] then
		return
	end

	for k, soundStr in pairs(self.abilitySoundMap[abilityId]) do
		self:stopSoundEvent(soundStr, 0.3)

		self.abilitySoundMap[abilityId][k] = nil
	end
end

function ClientAbilityComponent:addAbilityCameraResetEvent(abilityId, resetEventName)
	if not abilityId then
		return
	end

	self.abilityCameraEventMap[abilityId] = self.abilityCameraEventMap[abilityId] or {}
	self.abilityCameraEventMap[abilityId][resetEventName] = true
end

function ClientAbilityComponent:createFlashlightVisual(state, actionData, triggerCb)
	if not self.eModel then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("createFlashlightVisual: eModel not found", self.actorId)
		end

		return false
	end

	local triggerOffsetXYZ = actionData.triggerOffsetXYZ or {
		0,
		0,
		0
	}
	local centerVec = Vector3(triggerOffsetXYZ[1], triggerOffsetXYZ[2], triggerOffsetXYZ[3])
	local shapeKind = actionData.shapeKind
	local shapeArgs = actionData.shapeArgs
	local requiredArgs = 0

	if shapeKind == "Box" then
		requiredArgs = 3
	elseif shapeKind == "Sphere" then
		requiredArgs = 1
	elseif shapeKind == "Sector3D" then
		requiredArgs = 4
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("createFlashlightVisual: unsupported shapeKind", shapeKind)
		end

		return false
	end

	if not Utils.isTable(shapeArgs) or shapeArgs[requiredArgs] == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("createFlashlightVisual: shapeArgs invalid", shapeKind, requiredArgs, type(shapeArgs))
		end

		return false
	end

	if shapeKind == "Box" then
		local sizeVec = Vector3(shapeArgs[1], shapeArgs[2], shapeArgs[3])

		state.physxComp = PhysxComponent.AddBoxTrigger(self.eModel, triggerCb, centerVec, sizeVec)
	elseif shapeKind == "Sphere" then
		state.physxComp = PhysxComponent.AddSphereTrigger(self.eModel, triggerCb, centerVec, shapeArgs[1])
	elseif shapeKind == "Sector3D" then
		state.physxComp = PhysxComponent.AddSectorTrigger(self.eModel, triggerCb, centerVec, shapeArgs[1], shapeArgs[2], shapeArgs[3], shapeArgs[4])
	end

	if not string.isNilOrEmpty(actionData.entityName) and self.playEffectRaw then
		local resId = actionData.entityName

		if string.sub(resId, 1, 1) ~= "$" then
			resId = "$" .. resId .. ".prefab"
		end

		state.effectOwner = self
		state.effectId = self:playEffectRaw(resId, {
			mountType = EffectConst.MountType.Model,
			followType = EffectConst.FollowType.FollowPosRot,
			position = actionData.offsetXYZ or {
				0,
				0,
				0
			},
			scale = actionData.visualScale or {
				1,
				1,
				1
			}
		})
	end

	if self == pg.me and pg.global.cameraMgr then
		local pushDistance = 0

		if shapeKind == "Sphere" or shapeKind == "Sector3D" then
			pushDistance = shapeArgs[1] or 0
		elseif shapeKind == "Box" then
			pushDistance = math.max(shapeArgs[1] or 0, shapeArgs[3] or 0) * 0.5
		end

		if pushDistance > 0 then
			pg.global.cameraMgr:TryPushFogAway(pushDistance)

			state.fogPushed = true
		end
	end

	return true
end

function ClientAbilityComponent:destroyFlashlightVisual(state)
	if state.physxComp then
		PhysxComponent.RemoveTrigger(state.physxComp)

		state.physxComp = nil
	end

	if state.effectId and state.effectOwner and state.effectOwner.stopEffectById then
		state.effectOwner:stopEffectById(state.effectId)
	end

	state.effectId = nil
	state.effectOwner = nil

	if state.fogPushed and pg.global.cameraMgr then
		pg.global.cameraMgr:TryRestoreFog()

		state.fogPushed = nil
	end
end

function ClientAbilityComponent:addFlashlightTrigger(triggerKey, state, actionData)
	self.flashlightTriggerMap = self.flashlightTriggerMap or {}

	if self.flashlightTriggerMap[triggerKey] then
		self:removeFlashlightTrigger(triggerKey)
	end

	local relation = state.relation

	local function triggerCb(isEnter, otherPhysxComp)
		if state.closed then
			return
		end

		if otherPhysxComp.tagType ~= Const.TAG_ACTOR then
			return
		end

		local actorId = otherPhysxComp.tagId
		local otherEnt = pg.getEntityByActorId(actorId)

		if not otherEnt or otherEnt == self then
			return
		end

		if not Utils.checkRelation(self, otherEnt, relation) then
			return
		end

		if isEnter then
			if state.insideSet[actorId] then
				return
			end

			state.insideSet[actorId] = true

			self.subject:notify(AbilityConst.COMBAT_EVENT_ON_ENTER_TRAP, triggerKey, actorId)
			self:serverMsgNoGC("RPC_CS_EnterTrigger", triggerKey, actorId)
		else
			if not state.insideSet[actorId] then
				return
			end

			state.insideSet[actorId] = nil

			self.subject:notify(AbilityConst.COMBAT_EVENT_ON_LEAVE_TRAP, triggerKey, actorId)
			self:serverMsgNoGC("RPC_CS_LeaveTrigger", triggerKey, actorId)
		end
	end

	if not self:createFlashlightVisual(state, actionData, triggerCb) then
		return false
	end

	self.flashlightTriggerMap[triggerKey] = {
		state = state,
		actionData = actionData
	}

	return true
end

function ClientAbilityComponent:removeFlashlightTrigger(triggerKey)
	local triggerMap = self.flashlightTriggerMap

	if triggerMap == nil then
		return false
	end

	if triggerKey ~= nil then
		local closed = self:_closeFlashlightTrigger(triggerMap[triggerKey])

		triggerMap[triggerKey] = nil

		return closed
	end

	local closed = false

	for key, info in pairs(triggerMap) do
		closed = self:_closeFlashlightTrigger(info) or closed
		triggerMap[key] = nil
	end

	return closed
end

function ClientAbilityComponent:_closeFlashlightTrigger(info)
	if info == nil or info.state == nil or info.state.closed then
		return false
	end

	local state = info.state

	if state.insideSet then
		for actorId in pairs(state.insideSet) do
			self.subject:notify(AbilityConst.COMBAT_EVENT_ON_LEAVE_TRAP, state.triggerKey, actorId)
			self:serverMsgNoGC("RPC_CS_LeaveTrigger", state.triggerKey, actorId)
		end
	end

	state.closed = true

	self:destroyFlashlightVisual(state)

	state.insideSet = nil

	return true
end

function ClientAbilityComponent:removeAbilityCameraResetEvent(abilityId, resetEventName)
	if not abilityId then
		return
	end

	if self.abilityCameraEventMap[abilityId] then
		self.abilityCameraEventMap[abilityId][resetEventName] = nil
	end
end

function ClientAbilityComponent:resetAbilityCameraEvent(abilityId)
	if not self.abilityCameraEventMap[abilityId] then
		return
	end

	for resetEvent, _ in pairs(self.abilityCameraEventMap[abilityId]) do
		pg.game.camera.playerCameraMode:onCameraEvent({
			resetEvent
		})
	end

	self.abilityCameraEventMap[abilityId] = {}
end

function ClientAbilityComponent:clearAbilityAnimState(abilityId)
	if abilityId ~= self.abilityMotionInfos.templateId then
		return
	end

	local controllerComponent = self:getEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER)

	if NotNil(controllerComponent) then
		local abilityCharacterStateInfo = controllerComponent.abilityCharacterStateInfo

		abilityCharacterStateInfo.abilityStateMachine = 0
		abilityCharacterStateInfo.abilityQteInput = false

		self.eModel:SetAbilityMoveAxis(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, 0, 0)
	end

	self.abilityMotionInfos = {}
end

function ClientAbilityComponent:preparePreloadInfo()
	if not self:hasEModelComponent(Const.COMPONENT_INDEX_IK) then
		return
	end

	self:startAbilityCompTriggers()
	ClientAbilityUtils.preloadAllAbility(self)
end

function ClientAbilityComponent:addDynamicRigComponent(rigType, rigBoneData, rigEffectId)
	if not self:hasEModelComponent(Const.COMPONENT_INDEX_IK) then
		return
	end

	local rigCompType = self.dynamicRigCompTypeMap and self.dynamicRigCompTypeMap[rigType]

	if not rigCompType then
		return
	end

	local dynamicRigComp = self.eModel:AddDynamicRigComponent(Const.COMPONENT_INDEX_IK, rigCompType)

	if not dynamicRigComp then
		return
	end

	self.dynamicRigMap[rigType] = dynamicRigComp

	if rigBoneData then
		if rigType == AbilityConst.RIG_TYPE_VINE_CHAIN then
			local rootBone, tipBone = unpack(rigBoneData)

			if not rigEffectId then
				return
			end

			local vineTargetAnimator = self:getEffectAnimator(rigEffectId)

			if NotNil(vineTargetAnimator) then
				dynamicRigComp:Setup(vineTargetAnimator, rootBone, tipBone)
			end
		else
			dynamicRigComp:Setup(unpack(rigBoneData))
		end
	end
end

function ClientAbilityComponent:removeDynamicRigComponent(rigType)
	if IsNil(self.dynamicRigMap[rigType]) then
		return
	end

	if not self:hasEModelComponent(Const.COMPONENT_INDEX_IK) then
		return
	end

	self.eModel:RemoveDynamicRigComponent(Const.COMPONENT_INDEX_IK, self.dynamicRigMap[rigType])

	self.dynamicRigMap[rigType] = nil
end

function ClientAbilityComponent:forbidUltimateForAWhile(duration)
	duration = math.clamp(duration, 0, 1)

	self:clearForbidUltimateForAWhile()

	self.tempForbidUltimateTimer = self:addTimer(duration, function()
		self:clearForbidUltimateForAWhile()
	end)
	self.tempForbidUltimate = true
end

function ClientAbilityComponent:clearForbidUltimateForAWhile()
	if self.tempForbidUltimateTimer ~= nil then
		self:removeTimer(self.tempForbidUltimateTimer)

		self.tempForbidUltimateTimer = nil
	end

	self.tempForbidUltimate = nil
end

function ClientAbilityComponent:onPetSummon()
	self.actorBuff:endUnsummonBuffFreeze()
	self.subject:notify(AbilityConst.COMBAT_EVENT_ON_PET_SUMMON)

	local masterEntity = self:getMasterEntity()

	if masterEntity.inheritEffectMap then
		for effectStr, extraData in pairs(masterEntity.inheritEffectMap) do
			if self:hasEffect(effectStr) then
				self.eModel:SetEffectPlayTime(Const.COMPONENT_INDEX_EFFECT, effectStr, extraData.startTime)
			else
				self:playEffect(effectStr, extraData)
			end
		end
	end
end

function ClientAbilityComponent:onPetUnSummon()
	self.subject:notify(AbilityConst.COMBAT_EVENT_ON_PET_UNSUMMON)
	self:stopForceDisplacement()
	self.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)

	local masterEntity = self:getMasterEntity()

	if masterEntity.inheritEffectMap then
		for effectStr, extraData in pairs(masterEntity.inheritEffectMap) do
			extraData.startTime = self.eModel:GetEffectPlayTime(Const.COMPONENT_INDEX_EFFECT, effectStr)

			self:stopEffect(effectStr)
		end
	end
end

function ClientAbilityComponent:setAbilityDisplacementOffset(deltaPosition, deltaSeconds)
	EModelUtils.setDisplacementVelocitySourceByOffset(self, Const.DisplacementVelocitySource.FollowTarget, deltaPosition, deltaSeconds, true, false)
end

function ClientAbilityComponent:tickRotateTo(deltaSeconds)
	Vector3.enableCreateFromCache()

	self.rotateToData.time = self.rotateToData.time - deltaSeconds

	if self.rotateToData.targetActorId or self.rotateToData.targetPos then
		local targetEntity = pg.getEntityByActorId(self.rotateToData.targetActorId)
		local targetPos = targetEntity and targetEntity:getPosition() or self.rotateToData.targetPos
		local referenceOffsetRotY = self.rotateToData.referenceOffsetRotY

		if targetPos then
			local deltaAngle = self.rotateToData.rotateSpeed * deltaSeconds
			local targetDir = targetPos - self:getPosition()

			targetDir.y = 0

			if Vector3.Magnitude(targetDir) > math.smallNumber then
				local targetRotation = Quaternion.LookRotation(targetDir, VEC3_CONST_UP)
				local referenceRotation = self:getRotation()

				if ToBool(referenceOffsetRotY) then
					local referenceEuler = self:getRotation():ToEulerAngles()

					referenceRotation = Quaternion.Euler(referenceEuler.x, referenceEuler.y + referenceOffsetRotY, referenceEuler.z)
				end

				local curRotation = Quaternion.RotateTowards(referenceRotation, targetRotation, deltaAngle)

				if ToBool(referenceOffsetRotY) then
					local curEuler = curRotation:ToEulerAngles()

					curRotation = Quaternion.Euler(curEuler.x, curEuler.y - referenceOffsetRotY, curEuler.z)
				end

				if self.eModel then
					EModelUtils.setMotionRotation(self, curRotation, true)
				end
			end
		end
	elseif self.rotateToData.isRotateBySelf then
		local rotation = self:getRotation()

		EModelUtils.setMotionRotation(self, rotation * Quaternion.Euler(0, self.rotateToData.rotateSpeed * deltaSeconds, 0), true)
	end

	if self.rotateToData.time < 0 then
		self.rotateToData = nil
	end

	Vector3.disableCreateFromCache()
end

function ClientAbilityComponent:startRotateBySelf(rotateSpeed, time)
	self.rotateToData = {
		isRotateBySelf = true,
		rotateSpeed = rotateSpeed,
		time = time
	}
end

function ClientAbilityComponent:startRotateTo(targetActorId, targetPos, rotateSpeed, time, referenceOffsetRotY)
	self.rotateToData = {
		targetPos = targetPos,
		targetActorId = targetActorId,
		rotateSpeed = rotateSpeed,
		time = time,
		referenceOffsetRotY = referenceOffsetRotY
	}
end

function ClientAbilityComponent:stopRotateTo()
	self.rotateToData = nil
end

function ClientAbilityComponent:startReboundDash(actionData, combatContext)
	EModelUtils.clearDisplacementVelocitySource(self, Const.DisplacementVelocitySource.ReboundDash)
	AbilityComponent.startReboundDash(self, actionData, combatContext)

	if self.authority == Const.AUTHORITY_MASTER then
		if not self.marblesControl then
			self.marblesControl = ReboundDashControl(self)
		end

		self.marblesControl:enter()
	end
end

function ClientAbilityComponent:registerSelfSkillForceDisplacement(sourcePos, targetPos, duration, speed, isInDir, distance)
	local dir = sourcePos - targetPos

	if isInDir then
		dir = -dir
	end

	dir = dir:Normalize()

	self:stopMoveByDirection()
	self:clearScrollWithInputData()
	self:stopMoveByInput()

	self.moveByDirectionData = {
		isLocalDir = false,
		velocity = dir * speed,
		duration = duration
	}

	if distance > 0 then
		self.moveByDirectionData.distance = distance
	end
end

function ClientAbilityComponent:moveByDirection(velocity, duration, isLocalDir, needForceOnGround, collisionTest, targetPos, targetActorId, endCallback)
	EModelUtils.clearDisplacementVelocitySource(self, Const.DisplacementVelocitySource.MoveByDirection)

	velocity = Vector3(velocity[1], velocity[2], velocity[3])
	self.moveByDirectionData = {
		velocity = velocity,
		duration = duration,
		isLocalDir = isLocalDir,
		needForceOnGround = needForceOnGround,
		collisionTest = collisionTest,
		targetPos = targetPos,
		targetActorId = targetActorId,
		endCallback = endCallback
	}

	if self.disableMotion then
		self:disableMotion(ClientConst.DISABLE_MOTION_KEY.SKILL_MOVE, true)
	end
end

function ClientAbilityComponent:tickMoveByDirection(deltaSeconds)
	local moveByDirectionData = self.moveByDirectionData

	Vector3.enableCreateFromCache()

	local delta = Vector3.zero
	local velocity = moveByDirectionData.velocity

	if deltaSeconds < moveByDirectionData.duration then
		delta = velocity * deltaSeconds
		moveByDirectionData.duration = moveByDirectionData.duration - deltaSeconds
	else
		Vector3.disableCreateFromCache()
		self:stopMoveByDirection()

		return
	end

	local needForceOnGround = moveByDirectionData.needForceOnGround
	local collisionTest = moveByDirectionData.collisionTest
	local curPos = self:getPosition()
	local curRot = self:getRotation()

	if collisionTest ~= nil and collisionTest > 0 and not ToBool(needForceOnGround) then
		local layerMask = lshift(1, Layer.eDefault)
		local raycastHit, succ = PhysicsUtils.getRaycastInfo(curPos, curRot:Forward(), collisionTest, layerMask)

		if succ then
			EModelUtils.clearDisplacementVelocitySource(self, Const.DisplacementVelocitySource.MoveByDirection)
			Vector3.disableCreateFromCache()

			return
		end
	end

	local expectedTargetPos

	if moveByDirectionData.targetPos then
		expectedTargetPos = moveByDirectionData.targetPos
	elseif moveByDirectionData.targetActorId then
		local targetEnt = pg.getEntityByActorId(moveByDirectionData.targetActorId)

		expectedTargetPos = targetEnt and targetEnt:getPosition()
	end

	local targetPos = curPos
	local isLocalDir = moveByDirectionData.isLocalDir

	if expectedTargetPos then
		targetPos = CombatActionTool.interpConstantPoint(curPos, expectedTargetPos, deltaSeconds, Vector3.Magnitude(velocity), curRot)
	elseif isLocalDir then
		targetPos = curPos + curRot:MulVec3(delta)
	else
		targetPos = curPos + delta
	end

	if needForceOnGround == true then
		targetPos = PhysicsUtils.getGroundPos(targetPos) or targetPos

		if collisionTest ~= nil and collisionTest > 0 and not self:checkCanClimbStep(curPos, targetPos) then
			EModelUtils.clearDisplacementVelocitySource(self, Const.DisplacementVelocitySource.MoveByDirection)
			Vector3.disableCreateFromCache()

			return
		end
	end

	local displacementOffset = targetPos - curPos
	local shouldStop = false

	if moveByDirectionData.distance ~= nil and delta ~= nil then
		moveByDirectionData.distance = moveByDirectionData.distance - Vector3.Magnitude(delta)

		if moveByDirectionData.distance <= 0 then
			shouldStop = true
		end
	end

	if expectedTargetPos and Vector3.SqrDistance(expectedTargetPos, targetPos) < 0.1 then
		shouldStop = true
	end

	if shouldStop then
		EModelUtils.clearDisplacementVelocitySource(self, Const.DisplacementVelocitySource.MoveByDirection)
		self.eModel:SetDisplacementOffsetEx(displacementOffset[1], displacementOffset[2], displacementOffset[3])
		Vector3.disableCreateFromCache()
		self:stopMoveByDirection()
	else
		EModelUtils.setDisplacementVelocitySourceByOffset(self, Const.DisplacementVelocitySource.MoveByDirection, displacementOffset, deltaSeconds, true, false)
		Vector3.disableCreateFromCache()
	end
end

function ClientAbilityComponent:checkCanClimbStep(curPos, nextPos)
	if nextPos.y - curPos.y > 0.5 then
		return false
	end

	return true
end

function ClientAbilityComponent:stopMoveByDirection()
	EModelUtils.clearDisplacementVelocitySource(self, Const.DisplacementVelocitySource.MoveByDirection)

	if not self.moveByDirectionData then
		return
	end

	local cacheData = self.moveByDirectionData

	self.moveByDirectionData = nil

	if self.disableMotion then
		self:disableMotion(ClientConst.DISABLE_MOTION_KEY.SKILL_MOVE, false)
	end

	if cacheData.endCallback then
		cacheData.endCallback()
	end
end

function ClientAbilityComponent:stopMoveByInput()
	EModelUtils.clearDisplacementVelocitySource(self, Const.DisplacementVelocitySource.MoveByInput)

	self.moveByInputData = nil

	if self.disableMotion then
		self:disableMotion(ClientConst.DISABLE_MOTION_KEY.SKILL_MOVE, false)
	end
end

function ClientAbilityComponent:updateSkillInputData(x, y, z)
	if self.castAbilityNoTargetFrame and self:ATTACK_ST() and Time.unityFrameCount - self.castAbilityNoTargetFrame <= 2 and (x ~= 0 or y ~= 0) then
		Vector3.enableCreateFromCache()

		local cameraFwdX, _, cameraFwdZ = pg.global.cameraMgr:GetWorldCameraForwardEx()
		local forward = Vector3(cameraFwdX, 0, cameraFwdZ)

		Vector3.Normalize(forward)

		local rotation = Quaternion.LookRotation(forward, VEC3_CONST_UP)
		local targetDir = rotation:MulVec3(Vector3(x, 0, y))

		targetDir.y = 0

		local targetRotation = Quaternion.LookRotation(targetDir, VEC3_CONST_UP)

		EModelUtils.setMotionRotation(self, targetRotation, false)

		self.castAbilityNoTargetFrame = nil

		Vector3.disableCreateFromCache()
	end

	if self:SKILL_GLIDING_ST() or self:LATERAL_ATTACK_ST() then
		self.eModel:SetAbilityMoveAxis(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, x, y)
	end

	self:updateMoveByInput(x, y, z)
	self:updateScrollWithInput(x, y, z)
end

function ClientAbilityComponent:handleSkillJump()
	local controllerComponent = self:getEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER)
	local abilityCharacterStateInfo = NotNil(controllerComponent) and controllerComponent.abilityCharacterStateInfo or nil

	if abilityCharacterStateInfo and (abilityCharacterStateInfo.abilityStateMachine == AbilityConst.ABILITY_SKATEBOARD_STATE or self:SKILL_MOTION_ST() or self:HOOK_SPRINT_ST()) then
		self.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.SkillJump)
	end
end

function ClientAbilityComponent:getAbilityMotionAnim(state)
	return self.abilityMotionInfos[state .. AbilityConst.SKILL_MOTION_ANIM_SUFFIX]
end

function ClientAbilityComponent:getSkillJumpCd()
	return self.abilityMotionInfos.jumpCd or -1
end

function ClientAbilityComponent:onAbilityMotionStateEnter(state)
	local actionIds = self.abilityMotionInfos[state .. AbilityConst.SKILL_MOTION_ENTER_ACTION_SUFFIX]

	self:serverMsgNoGC("RPC_CS_OnSkillMotionStateChange", actionIds or {}, state, true)

	if ToBool(actionIds) and self.subject:isEventListening(AbilityConst.COMBAT_EVENT_ON_SKILL_MOTION_STATE_CHANGE) then
		self.subject:notify(AbilityConst.COMBAT_EVENT_ON_SKILL_MOTION_STATE_CHANGE, actionIds)
	end
end

function ClientAbilityComponent:onAbilityMotionStateExit(state)
	local actionIds = self.abilityMotionInfos[state .. AbilityConst.SKILL_MOTION_EXIT_ACTION_SUFFIX]

	if ToBool(actionIds) and self.subject:isEventListening(AbilityConst.COMBAT_EVENT_ON_SKILL_MOTION_STATE_CHANGE) then
		self:serverMsgNoGC("RPC_CS_OnSkillMotionStateChange", actionIds, state, false)
		self.subject:notify(AbilityConst.COMBAT_EVENT_ON_SKILL_MOTION_STATE_CHANGE, actionIds)
	end
end

function ClientAbilityComponent:notifyOtherClientPlayAbilityAnimation(animId)
	animId = AnimationUtils.getID(animId)

	self:serverMsgNoGC("RPC_CS_NotifyPlayAbilityAnimation", animId)
end

function ClientAbilityComponent:syncForceBipRotation(enable, x, y, z, w)
	if self.lastForceBipRotInfo == nil then
		self.lastForceBipRotInfo = {}
	end

	local info = self.lastForceBipRotInfo

	if info.enable ~= enable or info.x ~= x or info.y ~= y or info.z ~= z or info.w ~= w then
		info.enable = enable
		info.x = x
		info.y = y
		info.z = z
		info.w = w

		pg.world.setIsSyncPosThisFrame(self.actorId, true)
		self:serverMsgNoGC("RPC_CS_SyncForceBipRotation", enable, x, y, z, w)
	end
end

function ClientAbilityComponent:RPC_SC_SyncForceBipRotation(enable, x, y, z, w)
	if self.lastForceBipRotInfo == nil then
		self.lastForceBipRotInfo = {}
	end

	local info = self.lastForceBipRotInfo

	if info.enable ~= enable or info.x ~= x or info.y ~= y or info.z ~= z or info.w ~= w then
		info.enable = enable
		info.x = x
		info.y = y
		info.z = z
		info.w = w

		self.eModel:SyncForceBipRotation(Const.COMPONENT_INDEX_IK, enable, x, y, z, w)
	end
end

function ClientAbilityComponent:registerScrollWithInput(actionData, combatContext)
	if not self:hasEModelComponent(Const.COMPONENT_MOTION) then
		return false
	end

	EModelUtils.clearDisplacementVelocitySource(self, Const.DisplacementVelocitySource.Scroll)

	local duration = actionData.duration or 0

	if duration <= 0 then
		return
	end

	local radius = actionData.radius * (self.curModelScale or 1)

	if radius ~= nil and radius > 0 then
		local bodySize = self.bodySize or 0

		radius = math.max(bodySize, radius)
	end

	self.scrollWithInputData = {
		velocity = actionData.velocity,
		isVelocityOverride = actionData.isVelocityOverride or false,
		dir = Vector3(0, 0, 0),
		duration = duration,
		radius = radius,
		hitTriggerCD = actionData.hitTriggerCD,
		angleVelocity = actionData.angleVelocity,
		combatContext = combatContext:clone(),
		hitTriggerActionIds = actionData.actionIds,
		refCameraDir = actionData.refCameraDir,
		hitTriggerSelfActionCD = actionData.hitTriggerSelfActionCD,
		hitTriggerSelfActionIds = actionData.hitTriggerSelfActionIds,
		lastSelfActionTriggerTime = -actionData.hitTriggerSelfActionCD
	}

	if not ToBool(radius) then
		self.eModel:SetIgnoreActorCollision(Const.COMPONENT_MOTION, true)
	end

	if ToBool(actionData.enableScrollCamera) then
		pg.game.camera.playerCameraMode:enableScroll(true)
	end

	self.eModel.enableSkillScrollHitTrigger = true
end

function ClientAbilityComponent:clearScrollWithInputData()
	EModelUtils.clearDisplacementVelocitySource(self, Const.DisplacementVelocitySource.Scroll)

	self.scrollWithInputData = nil
	self.eModel.enableSkillScrollHitTrigger = false

	self.eModel:SetIgnoreActorCollision(Const.COMPONENT_MOTION, false)
	self.collisionHitRecordSet:clear(function(targetActorId, hitData)
		self.eModel:RemoveIgnoreCollider(Const.COMPONENT_MOTION, hitData.collider)

		if type(targetActorId) ~= "string" then
			local targetEntity = pg.getEntityByActorId(targetActorId)

			if targetEntity and targetEntity.eModel then
				targetEntity.eModel:RemoveIgnoreCollider(Const.COMPONENT_MOTION, self.eModel.bodyCollider)
			end
		end
	end)
	pg.game.camera.playerCameraMode:enableScroll(false)
end

function ClientAbilityComponent:updateScrollWithInput(x, y, z)
	local scrollWithInputData = self.scrollWithInputData

	if scrollWithInputData ~= nil then
		scrollWithInputData.dir.x = x
		scrollWithInputData.dir.z = y
	end
end

function ClientAbilityComponent:tickScrollWithInput(deltaSeconds)
	if not self:hasEModelComponent(Const.COMPONENT_MOTION) then
		return
	end

	if self.scrollWithInputData.duration == nil or self.scrollWithInputData.duration <= 0 then
		self:clearScrollWithInputData()

		return
	end

	self.collisionHitRecordSet:updateCollisionHitRecordSet(deltaSeconds, function(targetActorId, hitData)
		self.eModel:RemoveIgnoreCollider(Const.COMPONENT_MOTION, hitData.collider)

		if type(targetActorId) ~= "string" then
			local targetEntity = pg.getEntityByActorId(targetActorId)

			if targetEntity and targetEntity.eModel then
				targetEntity.eModel:RemoveIgnoreCollider(Const.COMPONENT_MOTION, self.eModel.bodyCollider)
			end
		end
	end)
	Vector3.enableCreateFromCache()

	local delta = Vector3.zero
	local deltaAngle = 0

	if deltaSeconds < self.scrollWithInputData.duration then
		delta = self.scrollWithInputData.velocity * deltaSeconds
		deltaAngle = self.scrollWithInputData.angleVelocity * deltaSeconds
		self.scrollWithInputData.duration = self.scrollWithInputData.duration - deltaSeconds
	else
		delta = self.scrollWithInputData.velocity * self.scrollWithInputData.duration
		deltaAngle = self.scrollWithInputData.angleVelocity * self.scrollWithInputData.duration
		self.scrollWithInputData.duration = nil
	end

	local prePosition = self:getPosition()
	local curRotation = self:getRotation()
	local inputAxisX = self.scrollWithInputData.dir.x
	local inputAxisY = self.scrollWithInputData.dir.z

	if ToBool(self.scrollWithInputData.refCameraDir) then
		if ToBool(inputAxisX) or ToBool(inputAxisY) then
			local cameraRotX, cameraRotY, cameraRotZ, cameraRotW = pg.global.cameraMgr:GetWorldCameraRotationEx()
			local cameraRotation = Quaternion(cameraRotX, cameraRotY, cameraRotZ, cameraRotW)
			local targetDir = cameraRotation:MulVec3(self.scrollWithInputData.dir)

			targetDir.y = 0

			local targetRotation = Quaternion.LookRotation(targetDir, VEC3_CONST_UP)

			curRotation = Quaternion.RotateTowards(curRotation, targetRotation, deltaAngle)

			EModelUtils.setMotionRotation(self, curRotation, true)
		end
	elseif ToBool(inputAxisX) then
		local targetRotEuler = curRotation:ToEulerAngles()

		targetRotEuler.y = targetRotEuler.y + inputAxisX * deltaAngle
		curRotation = Quaternion.Euler(targetRotEuler.x, targetRotEuler.y, targetRotEuler.z)

		EModelUtils.setMotionRotation(self, curRotation, true)
	end

	if self.scrollWithInputData.isVelocityOverride then
		self.eModel:SetVelocity(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, VEC3_CONST_FORWARD * self.scrollWithInputData.velocity)
	else
		EModelUtils.setDisplacementVelocitySourceByOffset(self, Const.DisplacementVelocitySource.Scroll, VEC3_CONST_FORWARD * delta, deltaSeconds, false, false)
	end

	if ToBool(self.scrollWithInputData.radius) then
		local dir = curRotation:MulVec3(VEC3_CONST_FORWARD * delta)

		dir = dir:Normalize()

		local rayCastResults, raycastCnt = pg.global.physicsMgr:SphereCastNonAlloc(prePosition, self.scrollWithInputData.radius, dir, delta, 0, false)

		if ClientSwitch.EnableDrawAbilityGizmo then
			local drawDuration = ClientSwitch.OnlyDrawLatestAttackBox and 0 or 1

			ClientDebugUtils.drawDebugHitBoxMesh(prePosition, curRotation, AbilityConst.LX_GEOMETRY_TYPE_SPHERE, {
				self.scrollWithInputData.radius
			}, drawDuration)
		end

		Vector3.disableCreateFromCache()

		for idx = 0, raycastCnt - 1 do
			local raycastHit = rayCastResults[idx]
			local handle = raycastHit.colliderHandle

			if handle:IsDyncmicCollider() then
				self:scrollOnCollision(handle.collider, raycastHit.point, raycastHit.normal)
			end
		end
	else
		Vector3.disableCreateFromCache()
	end
end

function ClientAbilityComponent:onScrollHitCollider(collider, hitPoint)
	if IsNil(collider) then
		return
	end

	local parent = collider.transform.parent

	if NotNil(parent) and parent.gameObject == CSEntityManager:GetGameObjectByActorId(self.actorId) then
		return
	end

	if collider:HasLayer(PhysicsLayerConst.eGround) then
		return
	end

	if self.scrollWithInputData == nil then
		return
	end

	local succ, physxComponent = collider:TryGetPhysxComponent()

	if not succ or physxComponent == nil then
		local ret, hashId = pg.global.physicsMgr:HasValidSensor(collider)

		if ret then
			return true, "sensor_" .. hashId, 0
		end

		return
	end

	local tagType = physxComponent.tagType

	if tagType == Const.TAG_ACTOR then
		local actorId = physxComponent.tagId
		local actorPartIdx = physxComponent.partIdx
		local hitEntity = pg.getEntityByActorId(actorId)

		if hitEntity == nil then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				self.logger:error("@hyj onScrollHitCollider:triggerCallback hitEntity is nil", actorId)
			end

			return
		end

		return true, actorId, actorPartIdx
	end
end

function ClientAbilityComponent:checkScrollHitSelfCd()
	if self.scrollWithInputData == nil then
		return true
	end

	local cd = self.scrollWithInputData.hitTriggerSelfActionCD

	if cd <= 0 then
		return true
	end

	local lastTime = self.scrollWithInputData.lastSelfActionTriggerTime
	local now = self:getGameTime()

	if cd <= now - lastTime then
		self.scrollWithInputData.lastSelfActionTriggerTime = now

		return true
	end

	return false
end

function ClientAbilityComponent:scrollOnCollision(collider, hitPoint, hitNormal)
	if self.scrollWithInputData == nil then
		return
	end

	local isValidHit, actorId, actorPartIdx = self:onScrollHitCollider(collider, hitPoint)

	if isValidHit then
		local isHitActor = type(actorId) ~= "string"

		if isHitActor then
			local hitEntity = pg.getEntityByActorId(actorId)

			if Utils.isEnvObj(hitEntity) then
				isHitActor = false
			end
		end

		local combatContext = self.scrollWithInputData.combatContext

		if self.collisionHitRecordSet:checkCanAddHitTarget(actorId) then
			local actorSetInfo = self.collisionHitRecordSet:addHitTarget(actorId, self.scrollWithInputData.hitTriggerCD)
			local hitCollider = actorSetInfo.collider

			if hitCollider ~= nil and hitCollider ~= collider then
				self.eModel:RemoveIgnoreCollider(Const.COMPONENT_MOTION, hitCollider)
			end

			actorSetInfo.collider = collider

			local triggerActions = self.scrollWithInputData.hitTriggerActionIds

			if isHitActor then
				local targetEntity = pg.getEntityByActorId(actorId)

				self.eModel:AddIgnoreCollider(Const.COMPONENT_MOTION, collider)

				if targetEntity and targetEntity.eModel then
					targetEntity.eModel:AddIgnoreCollider(Const.COMPONENT_MOTION, self.eModel.bodyCollider)
				end

				local finalHitPoint = hitPoint

				if finalHitPoint == nil or finalHitPoint.x == 0 and finalHitPoint.y == 0 and finalHitPoint.z == 0 then
					finalHitPoint = CombatActionTool.getHitPosition(targetEntity, nil, actorPartIdx)
				end

				local combatHitResult = pg.global.abilityMgr.combatHitResultPool:getWithCtor(true, actorId, finalHitPoint, actorPartIdx)

				combatContext.scrollHitNormal = hitNormal

				self:onAbilityCollisionHitTarget(combatHitResult, combatContext, triggerActions)

				combatContext.scrollHitNormal = nil

				pg.global.abilityMgr.combatHitResultPool:returnObject(combatHitResult)
			else
				self:onAbilityCollisionHitTarget(nil, combatContext, triggerActions)
			end
		end

		if isHitActor and self:checkScrollHitSelfCd() then
			local triggerActions = self.scrollWithInputData.hitTriggerSelfActionIds

			if ToBool(triggerActions) then
				self:serverMsgNoGC("RPC_CS_OnTriggerAbilityCollisionHit", combatContext:getRPCDynamicInfo(), triggerActions)

				combatContext.scrollHitNormal = hitNormal

				self.combatAction:doActionIds(triggerActions, combatContext)

				combatContext.scrollHitNormal = nil
			end
		end
	end
end

function ClientAbilityComponent:tickAbilityCollisionTest(deltaSeconds)
	self.collisionHitRecordSet:updateCollisionHitRecordSet(deltaSeconds)

	for _, info in pairs(self.abilityCollisionTestInfo) do
		local data = info.data

		if data.triggerCd and data.triggerCd > 0 then
			data.triggerCd = math.max(data.triggerCd - deltaSeconds, 0)
		end

		if data.triggerCd == nil or data.triggerCd <= 0 then
			local radius = data.radius * self.curModelScale
			local cd = data.actOnTargetCd
			local actorTypes = data.collidableActorTypes
			local offset = data.offset

			Vector3.enableCreateFromCache()

			local rotation = self:getRotation()
			local lastPos = self:getLastPosition() + rotation:MulVec3(offset)
			local curPos = self:getPosition() + rotation:MulVec3(offset)
			local delta = Vector3.Distance(curPos, lastPos)
			local dir = curPos - lastPos

			dir = dir:Normalize()

			local rayCastResults, raycastCnt = pg.global.physicsMgr:SphereCastNonAlloc(lastPos, radius, dir, delta, 0, false)

			if ClientSwitch.EnableDrawAbilityGizmo then
				local drawDuration = ClientSwitch.OnlyDrawLatestAttackBox and 0 or 1

				ClientDebugUtils.drawDebugHitBoxMesh(lastPos, rotation, AbilityConst.LX_GEOMETRY_TYPE_SPHERE, {
					radius
				}, drawDuration)
			end

			Vector3.disableCreateFromCache()

			local needActOnElements = false

			for _, type in ipairs(actorTypes) do
				if type == Const.ACTOR_TYPE_ENVOBJ then
					needActOnElements = true

					break
				end
			end

			local isHitTriggered = false
			local combatContext = info.combatCtx

			for idx = 0, raycastCnt - 1 do
				local raycastHit = rayCastResults[idx]
				local handle = raycastHit.colliderHandle

				if handle:IsDyncmicCollider() then
					local collider = handle.collider
					local hitPoint = raycastHit.point
					local isValidHit, actorId, actorPartIdx = self:checkAbilityCollisionHitValid(collider, actorTypes, needActOnElements)

					if isValidHit then
						local isHitActor = type(actorId) ~= "string"

						if self.collisionHitRecordSet:tryAddHitTarget(actorId, cd) then
							local combatHitResult

							if isHitActor then
								combatHitResult = pg.global.abilityMgr.combatHitResultPool:getWithCtor(true, actorId, hitPoint, actorPartIdx)
								isHitTriggered = self:onAbilityCollisionHitTarget(combatHitResult, combatContext, data.actOnTargetActionIds)

								pg.global.abilityMgr.combatHitResultPool:returnObject(combatHitResult)
							else
								ClientAbilityUtils.actOnEnvObjDirectly(collider, hitPoint, data, combatContext)
							end
						end
					end
				end
			end

			if isHitTriggered then
				local onTriggerHitActionIds = data.onTriggerHitActionIds

				self:serverMsgNoGC("RPC_CS_OnTriggerAbilityCollisionHit", combatContext:getRPCDynamicInfo(), onTriggerHitActionIds)
				self.combatAction:doActionIds(onTriggerHitActionIds, combatContext)
			end
		end
	end
end

function ClientAbilityComponent:checkAbilityCollisionHitValid(collider, actorTypes, needActOnElements)
	if not collider then
		return false
	end

	if collider.transform and collider.transform.parent and collider.transform.parent.gameObject == CSEntityManager:GetGameObjectByActorId(self.actorId) then
		return false
	end

	local physxComponent = collider.transform:GetComponent(typeof(PhysxComponent))

	if physxComponent == nil then
		if needActOnElements then
			local ret, hashId = pg.global.physicsMgr:HasValidSensor(collider)

			if ret then
				return true, "sensor_" .. hashId, 0
			end
		end

		return false
	end

	local tagType = physxComponent.tagType

	if tagType == Const.TAG_ACTOR then
		local actorId = physxComponent.tagId
		local actorPartIdx = physxComponent.partIdx
		local hitEntity = pg.getEntityByActorId(actorId)

		if hitEntity == nil then
			return false
		end

		for _, actorType in ipairs(actorTypes) do
			if Utils.isActorType(hitEntity, actorType) then
				return true, actorId, actorPartIdx
			end
		end
	end
end

function ClientAbilityComponent:onAbilityCollisionHitTarget(combatHitResult, combatContext, triggerActions)
	if not ToBool(triggerActions) then
		return false
	end

	self:serverMsgNoGC("RPC_CS_OnAbilityCollisionHitTarget", combatContext:getRPCDynamicInfo(), combatHitResult or {}, triggerActions)

	if ToBool(combatHitResult) then
		local targetEntity = pg.getEntityByActorId(combatHitResult.hitActorId)

		if targetEntity == nil then
			return
		end

		if not Utils.checkValidTarget(targetEntity, self) then
			return
		end

		combatContext.runtimeTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:get(true)

		combatContext.runtimeTargetInfo:initTarget(combatHitResult.hitActorId, combatHitResult.hitPos, 1, combatHitResult.hitActorPartIdx)
	end

	self.combatAction:doActionIds(triggerActions, combatContext)

	if ToBool(combatHitResult) then
		pg.global.abilityMgr.runtimeTargetInfoPool:returnObject(combatContext.runtimeTargetInfo)

		combatContext.runtimeTargetInfo = nil
	end

	return true
end

function ClientAbilityComponent:registerForceDisplacementWithTarget(targetEntityId, duration, speed, distance)
	local targetEntity = pg.getEntityByActorId(targetEntityId)

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("@hyj on registerForceDisplacementWithTarget: targetEntity not found")
		end

		return
	end

	self.forceDisplacementWithTargetData = {
		targetEntity = targetEntity,
		speed = speed,
		duration = duration,
		distance = distance
	}
end

function ClientAbilityComponent:tickForceDisplacementWithTarget(deltaSeconds)
	if self.forceDisplacementWithTargetData == nil then
		return
	end

	local targetEntity = self.forceDisplacementWithTargetData.targetEntity

	if not self:hasEModelComponent(Const.COMPONENT_MOTION) or not targetEntity:hasEModelComponent(Const.COMPONENT_MOTION) then
		return
	end

	if self.forceDisplacementWithTargetData.duration <= 0 then
		self:clearForceDisplacementWithTarget()

		return
	end

	if self.forceDisplacementWithTargetData.distance ~= nil and self.forceDisplacementWithTargetData.distance <= 0 then
		self.forceDisplacementWithTargetData.distance = nil

		self:clearForceDisplacementWithTarget()

		return
	end

	Vector3.enableCreateFromCache()

	local offset
	local fromTo = self.targetPos - self.owner:getPosition()
	local distance = Vector3.SqrMagnitude(fromTo)

	if distance < self.forceDisplacementWithTargetData.speed * deltaSeconds then
		offset = fromTo
		self.distance = 0

		self:setDisplacement(offset)
	else
		offset = self.forceDisplacementWithTargetData.dir * self.forceDisplacementWithTargetData.speed * deltaSeconds

		self:setDisplacement(offset)
	end

	self.duration = self.duration - deltaSeconds

	Vector3.disableCreateFromCache()
end

function ClientAbilityComponent:clearForceDisplacementWithTarget()
	self.forceDisplacementWithTargetData = nil
end

function ClientAbilityComponent:registerCheckEnclosedRegionEvent()
	self.checkEnclosedRegion = true
	self.routePoint = {}
	self.routePath = {}
end

function ClientAbilityComponent:clearCheckEnclosedRegionEvent()
	self.checkEnclosedRegion = false
	self.routePoint = nil
	self.routePath = nil
end

function ClientAbilityComponent:registerMoveByInput(velocity, angleVelocity, autoMove, refCameraDir, canRotate, extraInfo)
	EModelUtils.clearDisplacementVelocitySource(self, Const.DisplacementVelocitySource.MoveByInput)

	self.moveByInputData = {
		velocity = velocity,
		dir = Vector3.zero,
		angleVelocity = angleVelocity,
		autoMove = autoMove,
		refCameraDir = refCameraDir,
		canRotate = canRotate,
		slopeAcceleration = extraInfo.slopeAcceleration,
		minVelocity = extraInfo.minVelocity or velocity,
		maxVelocity = extraInfo.maxVelocity or velocity
	}

	if self.disableMotion then
		self:disableMotion(ClientConst.DISABLE_MOTION_KEY.SKILL_MOVE, true)
	end
end

function ClientAbilityComponent:updateMoveByInput(x, y, z)
	local moveByInputData = self.moveByInputData

	if moveByInputData ~= nil then
		moveByInputData.dir.x = x
		moveByInputData.dir.y = z
		moveByInputData.dir.z = y
	end
end

function ClientAbilityComponent:tickMoveByInput(deltaSeconds)
	if self.moveByInputData == nil then
		return
	end

	if deltaSeconds <= 0 then
		EModelUtils.clearDisplacementVelocitySource(self, Const.DisplacementVelocitySource.MoveByInput)

		return
	end

	if not self:hasEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER) then
		EModelUtils.clearDisplacementVelocitySource(self, Const.DisplacementVelocitySource.MoveByInput)

		return
	end

	local isZeroDir = CalcUtils.isZeroDir(self.moveByInputData.dir)

	if isZeroDir and not ToBool(self.moveByInputData.autoMove) then
		EModelUtils.clearDisplacementVelocitySource(self, Const.DisplacementVelocitySource.MoveByInput)

		return
	end

	Vector3.enableCreateFromCache()

	local pos = self:getPosition():Clone()
	local moveVelocity = self.moveByInputData.velocity
	local canRotate = self.moveByInputData.canRotate
	local enableSlopVelocityChange = ToBool(self.moveByInputData.slopeAcceleration)

	if ToBool(self.moveByInputData.angleVelocity) and not isZeroDir then
		if canRotate then
			local deltaAngle = self.moveByInputData.angleVelocity * deltaSeconds

			if ToBool(self.moveByInputData.refCameraDir) then
				local cameraRotX, cameraRotY, cameraRotZ, cameraRotW = pg.global.cameraMgr:GetWorldCameraRotationEx()
				local cameraRotation = Quaternion(cameraRotX, cameraRotY, cameraRotZ, cameraRotW)
				local targetDir = cameraRotation:MulVec3(self.moveByInputData.dir)

				targetDir.y = 0

				local targetRotation = Quaternion.LookRotation(targetDir, VEC3_CONST_UP)
				local targetRotEuler = targetRotation:ToEulerAngles()
				local curRotEuler = self:getRotation():ToEulerAngles()
				local rotAngleY = Mathf.DeltaAngle(curRotEuler.y, targetRotEuler.y)

				if rotAngleY == -180 then
					rotAngleY = 180
				end

				targetRotation = Quaternion.RotateTowards(self:getRotation(), targetRotation, deltaAngle)

				self:handleSpecialAbilityAnimStateByRotAngle(rotAngleY)
				EModelUtils.setMotionRotation(self, targetRotation, true)
			else
				local targetRotation = self:getRotation()
				local targetRotEuler = targetRotation:ToEulerAngles()

				targetRotEuler.y = targetRotEuler.y + self.moveByInputData.dir.x * deltaAngle
				targetRotation = Quaternion.Euler(targetRotEuler.x, targetRotEuler.y, targetRotEuler.z)

				self:handleSpecialAbilityAnimStateByDir(self.moveByInputData.dir.x, self.moveByInputData.dir.z)
				EModelUtils.setMotionRotation(self, targetRotation, true)
			end
		end

		self.eModel:OnHandleSkillMove(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, moveVelocity)
	elseif isZeroDir and ToBool(self.moveByInputData.autoMove) then
		self:handleSpecialAbilityAnimStateByDir(0, 0)
		self.eModel:OnHandleSkillMove(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, moveVelocity)
	else
		self.eModel:OnHandleSkillMove(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, self.moveByInputData.dir.x, self.moveByInputData.dir.z, self.moveByInputData.dir.y, moveVelocity, canRotate)
	end

	if enableSlopVelocityChange then
		local newVelocity = self.eModel:UpdateVelocityByGroundState(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, self.moveByInputData.velocity, self.moveByInputData.slopeAcceleration, deltaSeconds)

		self.moveByInputData.velocity = math.clamp(newVelocity, self.moveByInputData.minVelocity, self.moveByInputData.maxVelocity)
	end

	if ToBool(self.checkEnclosedRegion) then
		if self:recordNewPosAndCheckEnclosed(pos, deltaSeconds) then
			self.actorTimeline:resetCombatActionTimeline()
		end

		Vector3.disableCreateFromCache(pos)
	else
		Vector3.disableCreateFromCache()
	end
end

function ClientAbilityComponent:onMovementHitBlocked(targetActorId, hitPoint, hitNormal)
	if self.subject:isEventListening(AbilityConst.COMBAT_EVENT_ON_SKILL_MOVE_BLOCKED) then
		if self.authority == Const.AUTHORITY_MASTER then
			self:serverMsgNoGC("RPC_CS_OnMovementHitBlocked")
		end

		self.subject:notify(AbilityConst.COMBAT_EVENT_ON_SKILL_MOVE_BLOCKED, hitPoint, hitNormal)
	end

	local targetEntity = pg.getEntityByActorId(targetActorId)

	if self.authority == Const.AUTHORITY_MASTER and targetEntity and targetEntity.getConfigData and ToBool(targetEntity:getConfigData().isDestroyByImpulse) and self.eModel.moveImpulseBySkill > 0 then
		self:serverMsgNoGC("RPC_CS_DestroyByImpulse", targetActorId)
	end

	if self.tryRobEggRam then
		self:tryRobEggRam(targetActorId, hitNormal)
	end

	AIControllerUtils.sendAIEvent(self, "SneakColliderTrigger")
end

function ClientAbilityComponent:recordNewPosAndCheckEnclosed(pos, deltaSeconds)
	local safeCount = 5

	if ToBool(self.routePoint) then
		local prePos = self.routePoint[#self.routePoint]

		if prePos == pos then
			return false
		end

		local curPath = {
			prePos,
			pos
		}

		if ToBool(self.routePath) and safeCount < #self.routePath then
			for i = 1, #self.routePath - safeCount do
				local path = self.routePath[i]
				local intersectPos = Vector3(0, 0, 0)

				if Vector3.Intersect(curPath[1], curPath[2], path[1], path[2], intersectPos) then
					if Mathf.IsNan(intersectPos[1]) or Mathf.IsNan(intersectPos[2]) or Mathf.IsNan(intersectPos[3]) then
						return false
					end

					local enclosedPath = {}

					enclosedPath[1] = {
						intersectPos,
						path[2]
					}

					for iter = i + 1, #self.routePath do
						enclosedPath[#enclosedPath + 1] = self.routePath[iter]
					end

					enclosedPath[#enclosedPath + 1] = {
						prePos,
						intersectPos
					}

					local area = CombatActionTool.calc2DEnclosedPathArea(enclosedPath)

					if LoggerManager.checkLogger(LoggerConst.INFO) then
						self.logger:info(string.format("@hyj enclosedRegionArea = %f, intersectPos: {%f, %f, %f}", area, intersectPos[1], intersectPos[2], intersectPos[3]))
					end

					if area < 0.001 then
						return false
					end

					self:onSkillMovePathEnclosed(enclosedPath)

					return true
				end
			end
		end

		self.routePath[#self.routePath + 1] = curPath
	end

	self.routePoint[#self.routePoint + 1] = pos

	return false
end

function ClientAbilityComponent:onSkillMovePathEnclosed(enclosedPath)
	local entities = pg.getEntities()
	local hitResults = {}

	for _, ent in pairs(entities) do
		if Utils.isPuppet(ent) and not Utils.isNpc(ent) then
			local pos = ent:getPosition()

			if CombatActionTool.checkPointInEnclosedPath(pos, enclosedPath, ent:getHeight()) then
				if LoggerManager.checkLogger(LoggerConst.INFO) then
					self.logger:info("@hyj entity is in region ", ent.actorId)
				end

				local hitResult = CombatHitResult.new(ent.actorId, pos, ent.actorPartIdx)

				hitResults[#hitResults + 1] = hitResult
			end
		end
	end

	self:serverMsgNoGC("RPC_CS_OnSkillMovePathEnclosed", enclosedPath, hitResults)
	self.subject:notify(AbilityConst.COMBAT_EVENT_ON_SKILL_MOVE_PATH_ENCLOSED, hitResults)
end

function ClientAbilityComponent:turnToTarget(targetActorId, instant)
	local targetEnt = pg.getEntityByActorId(targetActorId)

	if not targetEnt then
		return
	end

	self:turnToPos(targetEnt:getPosition(), instant)
end

function ClientAbilityComponent:turnToPos(pos, instant)
	if instant == nil then
		instant = false
	end

	local selfEntPos = self:getPosition()
	local direction = pos - selfEntPos

	direction.y = 0

	Vector3.SetNormalize(direction)

	if Vector3.SqrMagnitude(direction) < 0.1 then
		return
	end

	local rotation = Quaternion.LookRotation(direction, VEC3_CONST_UP)

	if rotation then
		EModelUtils.setAgentRotation(self, rotation, instant)

		if self.setPosRot then
			self:setPosRot(selfEntPos, rotation)
		end
	end
end

function ClientAbilityComponent:prepareHookSprint(actionData)
	local emitVelocity = actionData.emitVelocity
	local emitVelocityMin = actionData.emitVelocityMin
	local emitVelocityMax = actionData.emitVelocityMax
	local sprintVelocity = actionData.sprintVelocity
	local sprintVelocityMin = actionData.sprintVelocityMin
	local sprintVelocityMax = actionData.sprintVelocityMax
	local targetActorId = 0
	local targetPos = Vector3.constZero
	local playerCameraMode = pg.game.camera.playerCameraMode
	local isInCameraAimMode = self == pg.pawn and playerCameraMode and playerCameraMode.isInAim

	if not isInCameraAimMode and ToBool(actionData.allowForceLockAsTarget) and ToBool(pg.game.controller.lockHelper.forceLockActorId) then
		local targetEntity = pg.getEntityByActorId(pg.game.controller.lockHelper.forceLockActorId)

		if targetEntity then
			targetActorId = targetEntity.actorId
			targetPos = CombatActionTool.getHitPosition(targetEntity)
		end
	end

	if not isInCameraAimMode and not ToBool(targetActorId) and ToBool(actionData.allowAutoLockAsTarget) and not ToBool(pg.game.controller.lockHelper.forceLockActorId) then
		targetActorId = Utils.getEntityLockedActorId(self)

		local targetEntity = pg.getEntityByActorId(targetActorId)

		if targetEntity then
			targetPos = CombatActionTool.getHitPosition(targetEntity)
		end
	end

	if self.hookSprintData == nil then
		self.hookSprintData = {}
	end

	self.hookSprintData[1] = math.clamp(emitVelocity, emitVelocityMin, emitVelocityMax)
	self.hookSprintData[2] = emitVelocityMin
	self.hookSprintData[3] = emitVelocityMax
	self.hookSprintData[4] = actionData.emitAcceleration
	self.hookSprintData[5] = actionData.emitDuration
	self.hookSprintData[6] = actionData.hookFailRecoverDuration
	self.hookSprintData[7] = math.clamp(sprintVelocity, sprintVelocityMin, sprintVelocityMax)
	self.hookSprintData[8] = sprintVelocityMin
	self.hookSprintData[9] = sprintVelocityMax
	self.hookSprintData[10] = actionData.sprintAcceleration
	self.hookSprintData[11] = targetPos.x
	self.hookSprintData[12] = targetPos.y
	self.hookSprintData[13] = targetPos.z
	self.hookSprintData[14] = actionData.sprintOffset or 0
end

function ClientAbilityComponent:getHookSprintData()
	return self.hookSprintData
end

function ClientAbilityComponent:onHookSprintWait(tgtPosX, tgtPosY, tgtPosZ)
	if self:HOOK_SPRINT_ST() then
		self:serverMsgNoGC("RPC_CS_OnSkillHookWait", tgtPosX, tgtPosY, tgtPosZ)
	end
end

function ClientAbilityComponent:onHookSprintSuccess(hitEntityActorId, hitPoint)
	self:setEntityCacheVal(AbilityConst.HOOK_SPRINT_HIT_POS, hitPoint)

	if self.subject:isEventListening(AbilityConst.COMBAT_EVENT_ON_SKILL_HOOK_SUCCESS) then
		self:serverMsgNoGC("RPC_CS_OnSkillHookSuccess", hitPoint.x, hitPoint.y, hitPoint.z, hitEntityActorId)
		self.subject:notify(AbilityConst.COMBAT_EVENT_ON_SKILL_HOOK_SUCCESS)

		local hitEntity = pg.getEntityByActorId(hitEntityActorId)

		if hitEntity and hitEntity.subject then
			hitEntity.subject:notify(AbilityConst.COMBAT_EVENT_ON_SKILL_HOOK_BE_HIT, self.actorId)
		end
	end
end

function ClientAbilityComponent:onHookSprintFailed()
	if self.subject:isEventListening(AbilityConst.COMBAT_EVENT_ON_SKILL_HOOK_FAIL) then
		self:serverMsgNoGC("RPC_CS_OnSkillHookFail")
		self.subject:notify(AbilityConst.COMBAT_EVENT_ON_SKILL_HOOK_FAIL)
	end
end

function ClientAbilityComponent:onHookSprintEnd()
	if self.subject:isEventListening(AbilityConst.COMBAT_EVENT_ON_SKILL_HOOK_END) then
		self:serverMsgNoGC("RPC_CS_OnSkillHookEnd")
		self.subject:notify(AbilityConst.COMBAT_EVENT_ON_SKILL_HOOK_END)
	end
end

function ClientAbilityComponent:onHookSprintExit()
	if self.subject:isEventListening(AbilityConst.COMBAT_EVENT_ON_SKILL_HOOK_EXIT) then
		self:serverMsgNoGC("RPC_CS_OnSkillHookExit")
		self.subject:notify(AbilityConst.COMBAT_EVENT_ON_SKILL_HOOK_EXIT)
	end

	self:setEntityCacheVal(AbilityConst.HOOK_SPRINT_HIT_POS, nil)
	self:cancelAbility()
end

function ClientAbilityComponent:RPC_SC_OnSkillHookWait(tgtPosX, tgtPosY, tgtPosZ)
	local hookSprintRigComp = self.dynamicRigMap[AbilityConst.RIG_TYPE_HOOK_SPRINT]

	if NotNil(hookSprintRigComp) and self.hookSprintData ~= nil then
		local emitDuration = self.hookSprintData[5]
		local velocity = self.hookSprintData[1]
		local vmin = self.hookSprintData[2]
		local vmax = self.hookSprintData[3]
		local acc = self.hookSprintData[4]

		hookSprintRigComp:StartSimulateHookWait(emitDuration, tgtPosX, tgtPosY, tgtPosZ, velocity, acc, vmin, vmax)
	end
end

function ClientAbilityComponent:RPC_SC_OnSkillHookSuccess(hitPosX, hitPosY, hitPosZ, hitEntityActorId)
	self:setEntityCacheVal(AbilityConst.HOOK_SPRINT_HIT_POS, Vector3(hitPosX, hitPosY, hitPosZ))
	self.subject:notify(AbilityConst.COMBAT_EVENT_ON_SKILL_HOOK_SUCCESS)

	local hitEntity = pg.getEntityByActorId(hitEntityActorId)

	if hitEntity then
		hitEntity.subject:notify(AbilityConst.COMBAT_EVENT_ON_SKILL_HOOK_BE_HIT, self.actorId)
	end
end

function ClientAbilityComponent:RPC_SC_OnSkillHookFail()
	local hookSprintRigComp = self.dynamicRigMap[AbilityConst.RIG_TYPE_HOOK_SPRINT]

	if NotNil(hookSprintRigComp) and self.hookSprintData ~= nil then
		local hookFailDuration = self.hookSprintData[6]

		hookSprintRigComp:StartSimulateHookFail(hookFailDuration)
	end

	self.subject:notify(AbilityConst.COMBAT_EVENT_ON_SKILL_HOOK_FAIL)
end

function ClientAbilityComponent:RPC_SC_OnSkillHookEnd()
	local hookSprintRigComp = self.dynamicRigMap[AbilityConst.RIG_TYPE_HOOK_SPRINT]

	if NotNil(hookSprintRigComp) then
		self.eModel:EnableRigComponent(Const.COMPONENT_INDEX_IK, hookSprintRigComp, false)
	end

	self.subject:notify(AbilityConst.COMBAT_EVENT_ON_SKILL_HOOK_END)
end

function ClientAbilityComponent:RPC_SC_OnSkillHookExit()
	local hookSprintRigComp = self.dynamicRigMap[AbilityConst.RIG_TYPE_HOOK_SPRINT]

	if NotNil(hookSprintRigComp) then
		self.eModel:EnableRigComponent(Const.COMPONENT_INDEX_IK, hookSprintRigComp, false)
	end

	self.subject:notify(AbilityConst.COMBAT_EVENT_ON_SKILL_HOOK_EXIT)
	self:setEntityCacheVal(AbilityConst.HOOK_SPRINT_HIT_POS, nil)
end

function ClientAbilityComponent:handleSpecialAbilityAnimStateByRotAngle(angle)
	local dirX = 0

	if Mathf.Abs(angle) < 0.001 then
		dirX = 0
	elseif angle > 0 then
		dirX = 1
	elseif angle < 0 then
		dirX = -1
	end

	self:handleSpecialAbilityAnimStateByDir(dirX, 0)
end

function ClientAbilityComponent:handleSpecialAbilityAnimStateByDir(dirX, dirY)
	local controllerComponent = self:getEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER)
	local abilityCharacterStateInfo = NotNil(controllerComponent) and controllerComponent.abilityCharacterStateInfo or nil

	if not abilityCharacterStateInfo then
		return
	end

	local abilityAnimState = abilityCharacterStateInfo.abilityStateMachine

	if abilityAnimState == AbilityConst.ABILITY_SKATEBOARD_STATE then
		self.eModel:SetAbilityMoveAxis(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, dirX, dirY)
	end
end

function ClientAbilityComponent:clientCastAbilityOnTarget(abilityId, targetId, castSource, extraInfo)
	if self == pg.me and pg.me.invasionInputDisabled then
		return false, AbilityConst.ABILITY_CAST_FAILED_STATE_CHECK_FAILED
	end

	castSource = castSource or AbilityConst.CAST_SOURCE.NORMAL
	abilityId = self:getSwitchSkill(abilityId)

	local targetEnt = pg.getEntityByActorId(targetId)
	local result, failedReason
	local maxSkillCastDistance = AbilitySettingGlobalConstData.forceLockDis

	if self == pg.pawn and AbilityUtils.isUltimateAbility(abilityId) and pg.game.controller.lockHelper.forceLockActorId == targetId then
		maxSkillCastDistance = AbilitySettingGlobalConstData.leaveForceLockDis
	end

	if Utils.isPuppet(self) and PuppetData[self.templateId] and PuppetData[self.templateId].maxSkillCastDistance then
		maxSkillCastDistance = PuppetData[self.templateId].maxSkillCastDistance
	end

	maxSkillCastDistance = maxSkillCastDistance + 2

	local isFromDialogueGraph = castSource == AbilityConst.CAST_SOURCE.DIALOGUE_GRAPH

	Vector3.enableCreateFromCache()

	if not isFromDialogueGraph and targetEnt and Vector3.HoriSqrDistance(targetEnt:getPosition(), self:getPosition()) > maxSkillCastDistance * maxSkillCastDistance then
		Vector3.disableCreateFromCache()

		if self == pg.pawn then
			extraInfo = pg.game.controller.autoCastController:updateChaseActorId(abilityId, extraInfo)
		end

		result, failedReason = self:castAbilityNoTarget(abilityId, castSource, extraInfo)
	else
		Vector3.disableCreateFromCache()

		result, failedReason = self:castAbilityOnTarget(abilityId, targetId, castSource, extraInfo)
	end

	if result then
		self.castAbilityNoTargetFrame = nil
	end

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:log2Tag("LuaVerbose", "castAbilityOnTarget", abilityId, targetId, castSource, result, AbilityConst.ABILITY_CAST_FAILED_REASONS[failedReason])
	end

	return result, failedReason
end

function ClientAbilityComponent:checkAndTeleportByUltimateAbility(abilityId, combatCasterInfo)
	if AbilityUtils.isUltimateAbility(abilityId) then
		local pos = self:getPosition()

		if self.isMainPet and ToBool(combatCasterInfo.targetActorId) and combatCasterInfo.targetActorId == pg.me.lockedActorId then
			local targetEnt = pg.getEntityByActorId(combatCasterInfo.targetActorId)
			local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(abilityId)
			local autoCastDis
			local lockDis = AbilitySettingGlobalConstData.forceLockDis

			if self == pg.pawn and AbilityUtils.isUltimateAbility(abilityId) then
				lockDis = AbilitySettingGlobalConstData.leaveForceLockDis
			end

			if abilityTemplate.autoCastDisByLockDis then
				autoCastDis = AbilitySettingGlobalConstData.forceLockDis
			else
				autoCastDis = abilityTemplate.overrideAutoCastDis
			end

			if targetEnt and autoCastDis and autoCastDis > 0 then
				local targetEntPos = targetEnt:getPosition()
				local offsetX = targetEntPos.x - pos.x
				local offsetZ = targetEntPos.z - pos.z
				local disSqr = offsetX * offsetX + offsetZ * offsetZ

				if disSqr < lockDis * lockDis and disSqr > autoCastDis * autoCastDis then
					offsetX, offsetZ = Vector2.NormalizeVec2XY(offsetX, offsetZ)

					local initTeleportPosX = targetEntPos.x - offsetX * autoCastDis
					local initTeleportPosY = targetEntPos.y
					local initTeleportPosZ = targetEntPos.z - offsetZ * autoCastDis
					local groundValid, groundPosX, groundPosY, groundPosZ = PhysicsUtils.getGroundPosXYZ(initTeleportPosX, initTeleportPosY, initTeleportPosZ, 5, nil, false, false, 5)

					if groundValid then
						initTeleportPosX = groundPosX
						initTeleportPosY = groundPosY
						initTeleportPosZ = groundPosZ
					end

					local findValidPos, teleportPosX, teleportPosY, teleportPosZ = self.eModel:GetTeleportPosXYZ(Const.COMPONENT_AUTO_PATH_FIND, initTeleportPosX, initTeleportPosY, initTeleportPosZ)

					if findValidPos then
						self:serverMsgNoGC("RPC_CS_NotifyAbilityTeleportByUltimate")
						EModelUtils.setAgentPositionXYZ(self, teleportPosX, teleportPosY, teleportPosZ)

						return
					end
				end
			end
		end

		local succ, px, py, pz = PhysicsUtils.getGroundPosXYZ(pos.x, pos.y, pos.z, 5)

		if pos.y - py > 0.2 then
			EModelUtils.setAgentPositionXYZ(self, px, py, pz)
		end
	end
end

function ClientAbilityComponent:onAbilityStart(abilityId, combatCasterInfo, castSource, extraInfo)
	AbilityComponent.onAbilityStart(self, abilityId, combatCasterInfo, castSource, extraInfo)
	self:startChargeByAbilityId(abilityId)

	if not Utils.checkIsAuthorityMaster(self) then
		return
	end

	local ability = self:getAbility(abilityId)

	self:checkAndTeleportByUltimateAbility(abilityId, combatCasterInfo)

	local isFromServer = extraInfo and extraInfo.isFromServer
	local syncServer = not isFromServer and castSource ~= AbilityConst.CAST_SOURCE.DIALOGUE_GRAPH

	if combatCasterInfo.targetActorId then
		Vector3.enableCreateFromCache()

		local targetEntity = pg.getEntityByActorId(combatCasterInfo.targetActorId)

		if not ability:getAbilityTemplate().notTurnToTarget and targetEntity and not self:SKILL_GLIDING_ST() and Vector3.Distance(targetEntity:getPosition(), self:getPosition()) < AbilitySettingGlobalConstData.forceLockDis then
			Vector3.disableCreateFromCache()
			self:turnToTarget(combatCasterInfo.targetActorId, castSource == AbilityConst.CAST_SOURCE.APPEAR or AbilityUtils.isUltimateAbility(abilityId))
		else
			Vector3.disableCreateFromCache()
		end

		if self == pg.pawn then
			pg.game.camera.playerCameraMode.lockOnExtendCamera:lerpToDeadZoneTriangle()
		end

		if syncServer then
			self:serverMsgNoGC("RPC_CS_CastAbilityOnTarget", abilityId, combatCasterInfo.targetActorId, castSource)
		end

		if self == pg.pawn and self.lockTarget then
			self:lockTarget(combatCasterInfo.targetActorId)
		end
	else
		if combatCasterInfo.chaseActorId then
			self:turnToTarget(combatCasterInfo.chaseActorId, false)
		end

		if syncServer then
			if combatCasterInfo.attackPos and combatCasterInfo.attackRot then
				self:serverMsgNoGC("RPC_CS_CastAbilityOnPosRot", abilityId, combatCasterInfo.attackPos, combatCasterInfo.attackRot, castSource)
			else
				self:serverMsgNoGC("RPC_CS_CastAbilityNoTarget", abilityId, castSource)
			end
		end
	end

	if AbilityUtils.isUltimateAbility(abilityId) then
		AIUtils.pauseBt(self, AiConst.PauseBtReason.UltimateAbility)
		EModelUtils.clearAllVelocity(self)
	end

	self:onAblityStartInNpcDuel(abilityId)

	if self == pg.pawn and not AbilityUtils.isUltimateAbility(abilityId) and not AbilityUtils.isAimAbility(abilityId) and AbilityUtils.isAttackAbility(abilityId) then
		local targetActorId = combatCasterInfo.targetActorId

		if not ToBool(targetActorId) then
			targetActorId = pg.me.lockedActorId
		end

		local targetEntity = ToBool(targetActorId) and pg.getEntityByActorId(targetActorId) or nil

		pg.game.camera.playerCameraMode:onNormalAttackStart(targetEntity)
	end
end

function ClientAbilityComponent:onAblityStartInNpcDuel(abilityId)
	if self.space and self.space:isNpcDuel() then
		facade:sendMsgToSystem(MessageName.NPC_DUEL_START_ABILITY, {
			ent = self,
			abilityId = abilityId
		})
	end
end

function ClientAbilityComponent:clientCastAbilityNoTarget(abilityId, castSource, extraInfo)
	if self == pg.me and pg.me.invasionInputDisabled then
		return false, AbilityConst.ABILITY_CAST_FAILED_STATE_CHECK_FAILED
	end

	castSource = castSource or AbilityConst.CAST_SOURCE.NORMAL
	abilityId = self:getSwitchSkill(abilityId)

	local result, failedReason = self:castAbilityNoTarget(abilityId, castSource, extraInfo)

	if result then
		self.castAbilityNoTargetFrame = Time.unityFrameCount
	end

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:log2Tag("LuaVerbose", "clientCastAbilityNoTarget", abilityId, castSource, result, AbilityConst.ABILITY_CAST_FAILED_REASONS[failedReason])
	end

	return result, failedReason
end

function ClientAbilityComponent:clientCastAbilityOnPosRot(abilityId, pos, rotation, castSource)
	if self == pg.me and pg.me.invasionInputDisabled then
		return false, AbilityConst.ABILITY_CAST_FAILED_STATE_CHECK_FAILED
	end

	castSource = castSource or AbilityConst.CAST_SOURCE.NORMAL
	abilityId = self:getSwitchSkill(abilityId)

	local castResult, failReason = self:castAbilityOnPosRot(abilityId, pos, rotation, castSource)

	if castResult then
		self.castAbilityNoTargetFrame = nil
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("@jqj castAbilityOnPosRot failed, reason", AbilityConst.ABILITY_CAST_FAILED_REASONS[failReason])
	end

	return castResult, failReason
end

function ClientAbilityComponent:cancelAbility(event, force)
	if not EnableBotTest and (self:ABILITY_ST() or force) then
		self:stopAnimationByTag(TagMask.Skill)
		self:serverMsgNoGC("RPC_CS_StopCombatActionTimeline", ClientAbilityConst.HIT_CANCEL_ABILITY_CTS[event] or false)
		self.actorTimeline:stopCombatActionTimeline()
	end
end

function ClientAbilityComponent:stopAbility(event, force)
	if self:ABILITY_ST() then
		if force then
			self:cancelAbility(event, force)
		else
			self.actorTimeline:resetCombatActionTimeline()
		end
	end
end

function ClientAbilityComponent:switchRuntimeDebugMode(active)
	self:serverMsgNoGC("RPC_CS_StopCombatActionTimeline", false)
	self.actorTimeline:stopCombatActionTimeline()

	if active then
		self.actorTimeline = EditorActorTimeline(self)
		self.combatAction = pg.global.abilityMgr.combatAction
	else
		self.actorTimeline = ActorTimeline(self)
		self.combatAction = pg.global.abilityMgr.combatAction
	end

	self.actorTimeline:init()
end

function ClientAbilityComponent:addFollowingPhantom(actionData, petTemplateId)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("addFollowingPhantom", inspect({
			actionData
		}), petTemplateId)
	end

	local ent = ClientUtils.createFollowingPhantom(actionData, petTemplateId, self.actorId)

	table.insert(self.followingPhantomList, ent)

	return ent
end

function ClientAbilityComponent:removeFollowingPhantom(actionData)
	for index, ent in ipairs(self.followingPhantomList) do
		if ent.actionData == actionData then
			table.remove(self.followingPhantomList, index)
			ClientUtils.destroyFollowingPhantom(ent)

			return
		end
	end
end

function ClientAbilityComponent:updateFollowingPhantomList()
	for index, ent in ipairs(self.followingPhantomList) do
		ent:refreshVisible()
	end
end

function ClientAbilityComponent:createProjectileFromAniEvent(projectileTemplateId, startPos, startQua)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("createProjectileFromAniEvent", projectileTemplateId, startPos, startQua)
	end

	if self.createProjFromAniCallback[projectileTemplateId] then
		self.createProjFromAniCallback[projectileTemplateId](projectileTemplateId, startPos, startQua)
	end
end

function ClientAbilityComponent:createCreationFromAniEvent(creationTemplateId, startPos, startQua)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("createCreationFromAniEvent", creationTemplateId, startPos, startQua)
	end

	self:serverMsgNoGC("RPC_CS_CreateCreationFromAniEvent", creationTemplateId, startPos, startQua)
end

function ClientAbilityComponent:startHitTriggerRecord(castingCombatContextId, combatContext)
	if self ~= pg.pawn or not ToBool(pg.game.controller.lockHelper.forceLockActorId) then
		return
	end

	local targetEnt = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_TARGET))

	if not targetEnt or pg.game.controller.lockHelper.forceLockActorId ~= targetEnt.actorId then
		return
	end

	local abilityParamData = pg.global.abilityMgr:getAbilityParamData(combatContext.abilityId)

	if not abilityParamData or not abilityParamData.tags then
		return
	end

	local hasTagTrigger = false

	for _, tagId in ipairs(abilityParamData.tags) do
		if pg.me:hasCondition(TriggerConst.TRIGGER_TARGET_UNHIT_COUNT, tagId) then
			hasTagTrigger = true

			break
		end
	end

	if not hasTagTrigger then
		return
	end

	local distance = Vector3.Distance(self:getPosition(), targetEnt:getPosition())
	local tmpTable = ListPool.getList(2)
	local cnt = self:entitiesInRangeWithTable(distance, Const.SEARCH_USR_TYPE_ACTOR_CREATION, 10, tmpTable)
	local hasCloserEnt = false

	for i = 1, cnt do
		local ent = pg.getEntityByActorId(tmpTable[i])

		if ent and ent ~= self and Utils.isEnemy(self, ent) and Vector3.SqrDistance(self:getPosition(), ent:getPosition()) < distance * distance then
			hasCloserEnt = true

			break
		end
	end

	if hasCloserEnt then
		pg.me.hitTriggerRecord[castingCombatContextId] = targetEnt.actorId

		pg.me:addTimer(5, function()
			if not pg.me then
				return
			end

			if pg.me.hitTriggerRecord[castingCombatContextId] then
				for _, tagId in ipairs(abilityParamData.tags) do
					pg.me:tryClientTrigger(TriggerConst.TRIGGER_TARGET_UNHIT_COUNT, tagId, 1)
				end
			end

			pg.me.hitTriggerRecord[castingCombatContextId] = nil
		end)
	end

	ListPool.returnList(tmpTable, 2)
end

function ClientAbilityComponent:doHitTriggerRecord(castingCombatContextId, targetActorId)
	if not pg.me then
		return
	end

	if self.hitTriggerRecord[castingCombatContextId] == targetActorId then
		self.hitTriggerRecord[castingCombatContextId] = nil
	end
end

function ClientAbilityComponent:setProjAroundSelf(actionData, combatContext)
	self.projAroundSelfControl = ProjAroundSelfControl(actionData, combatContext)

	self.projAroundSelfControl:addProj(self.projAroundSelfCnt)
end

function ClientAbilityComponent:clearProjAroundSelf()
	self.projAroundSelfControl:clear()
end

function ClientAbilityComponent:RPC_SC_DoAction(callbackId, nodeId, dynamicInfo)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_DoAction", nodeId, inspect(dynamicInfo))
	end

	local srcCombatContext = CombatContext.convert(self, dynamicInfo)

	if not srcCombatContext or not srcCombatContext.nodeMap then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("RPC_SC_DoAction failed, srcCombatContext not found", dynamicInfo.id)
		end

		return
	end

	local actionData = srcCombatContext.nodeMap[nodeId]

	if not actionData then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("RPC_SC_DoAction failed, actionData not found", srcCombatContext.ctxType, srcCombatContext:getTemplateId(), nodeId)
		end

		return
	end

	local clientDatas = ListPool.getList(1)

	if actionData.clientDataActionIds then
		for idx, nodeId in ipairs(actionData.clientDataActionIds) do
			clientDatas[idx] = self.combatAction:doActionById(nodeId, srcCombatContext) or 0
		end
	end

	self.combatAction:doActions(actionData, srcCombatContext)

	if actionData.callbackActionIds then
		self:serverMsgNoGC("RPC_CS_DoActionCallback", callbackId, clientDatas)
	end

	ListPool.returnList(clientDatas, 1)
end

function ClientAbilityComponent:RPC_SC_NotifyReceiveDamage(eventName, actorId, dynamicInfo)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_NotifyReceiveDamage", eventName, actorId, inspect(dynamicInfo))
	end

	local combatContextOwner = pg.getEntityByActorId(actorId)

	if combatContextOwner then
		local eventCombatContext = CombatContext.convert(combatContextOwner, dynamicInfo)

		if eventCombatContext then
			self.subject:notify(eventName, eventCombatContext)
		end
	end
end

function ClientAbilityComponent:RPC_SC_SetBasicTimeline(timelineId, playRate)
	local timelineParams = ActionTimelineParams.BasicActionTimelineParam.new()

	self.actorTimeline:setTimeline(timelineId, playRate, timelineParams, false)
end

function ClientAbilityComponent:RPC_SC_SetCombatActionTimeline(timelineId, playRate, combatActionTimelineParam)
	if not self.abilityCompInitTriggerDone then
		self:addAbilityInitTriggerCallbacks(function()
			self:_Rpc_RPC_SC_SetCombatActionTimeline(timelineId, playRate, combatActionTimelineParam)
		end)

		return
	end

	if not self.actorTimeline:setTimeline(timelineId, playRate, combatActionTimelineParam, false) then
		pg.global.abilityMgr.combatParamsPool:returnObject(combatActionTimelineParam)
	end
end

function ClientAbilityComponent:RPC_SC_SetHitActionTimeline(timelineId, playRate, hitActionTimelineParam)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_SetHitActionTimeline", timelineId)
	end

	ActionTimelineParams.HitActionTimelineParam.convert(hitActionTimelineParam)

	if not self.actorTimeline:setTimeline(timelineId, playRate, hitActionTimelineParam) then
		pg.global.abilityMgr.hitParamsPool:returnObject(hitActionTimelineParam)
	end
end

function ClientAbilityComponent:RPC_SC_StopActionTimeline(layer, timelineId)
	self.actorTimeline:stopTimeline(layer, timelineId)
end

function ClientAbilityComponent:RPC_SC_JumpToNextTimeline(layer, timelineId, nextTimelineId)
	local timeline

	if layer == AbilityConst.ACTION_TIMELINE_LAYER_BASE then
		timeline = self.actorTimeline.baseTimeline
	elseif layer == AbilityConst.ACTION_TIMELINE_LAYER_ADDITIVE then
		timeline = self.actorTimeline.additiveTimeline
	elseif layer == AbilityConst.ACTION_TIMELINE_LAYER_PARALLEL then
		for _, iTimeline in ipairs(self.actorTimeline.parallelTimelines) do
			if iTimeline.isPlaying and iTimeline.timelineId == timelineId then
				iTimeline:continueTimeline(nextTimelineId, iTimeline.playRate)
			end
		end
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("@jqj not support layer", layer)
	end

	if timeline and timeline.isPlaying and timeline.timelineId == timelineId then
		timeline:continueTimeline(nextTimelineId, timeline.playRate)
	end

	return true
end

function ClientAbilityComponent:RPC_SC_ChangeDynamicListMap(listId, data)
	self.dynamicListMap[listId] = data

	local master = self:getMasterEntity()

	facade:SendMessageCommand(MessageName.DYNAMIC_LIST_REFRESH, {
		ent = master,
		listId = listId,
		data = data
	})
end

function ClientAbilityComponent:RPC_SC_Octopus_State(eventName, state, wonColor)
	if eventName == "Won" then
		self.wonColor = wonColor
	end

	facade:SendMessageCommand(MessageName.OCTOPUS_STATE_CHANGE, {
		eventName = eventName,
		state = state
	})
end

function ClientAbilityComponent:RPC_SC_StopTimelineByTime(layer, timelineId)
	self.actorTimeline:stopTimelineByTime(AbilityConst.TIMELINE_LAYER_INT_TO_STR[layer], timelineId)
end

function ClientAbilityComponent:RPC_SC_OnOldPetBeSwitched(actorId)
	local newPet = pg.getEntityByActorId(actorId)

	if not newPet then
		self.subject:notify(AbilityConst.COMBAT_EVENT_ON_OLD_PET_SWITCH, newPet)

		return
	end

	self.subject:notify(AbilityConst.COMBAT_EVENT_ON_OLD_PET_SWITCH, newPet)
	newPet:getMasterEntity().subject:notify(AbilityConst.COMBAT_EVENT_ON_OLD_PET_SWITCH, newPet)
end

function ClientAbilityComponent:RPC_SC_OnSwitchToNewPet()
	local masterEntity = self:getMasterEntity()
	local curPetEnt = masterEntity:getCurPetEntity()

	self.subject:notify(AbilityConst.COMBAT_EVENT_ON_NEW_PET_SWITCH, curPetEnt.actorId)
	masterEntity.subject:notify(AbilityConst.COMBAT_EVENT_ON_NEW_PET_SWITCH, curPetEnt.actorId)
end

function ClientAbilityComponent:notifyBuffAddEvent(buffData)
	if self.isMainPlayer or self.isMainPet or Utils.isLabelBoss(self.label) or Utils.isLabelElite(self.label) or self:isNpcDuelBotPet() then
		if buffData.category == AbilityConst.BUFF_CATEGORY_TYPE_SOCIAL then
			facade:SendMessageCommand(MessageName.SOCIAL_BUFF_CHANGE, {
				isAdd = true,
				entId = self.id,
				buffInsId = buffData.instanceId,
				templateId = buffData.templateId
			})
		end

		facade:SendMessageCommand(MessageName.ON_BUFF_ADD, {
			entId = self.id,
			isTeamBuff = buffData.isTeamBuff,
			newBuffData = buffData,
			buffInsId = buffData.instanceId
		})
	end

	local buffInfo = {
		newBuffData = buffData,
		buffInsId = buffData.instanceId,
		isTeamBuff = buffData.isTeamBuff
	}

	self.eventEmitter:emit(EventConst.ON_BUFF_ADD, buffInfo)

	if buffData.isTeamBuff then
		local curPetEnt = self.getCurPetEntity and self:getCurPetEntity() or nil

		if curPetEnt then
			curPetEnt.eventEmitter:emit(EventConst.ON_BUFF_ADD, buffInfo)
		end
	end

	if pg.space and pg.space:isNpcDuel() then
		facade:sendMsgToSystem(MessageName.NPC_DUEL_BUFF_ADD, {
			ent = self,
			buffId = buffData.templateId
		})
	end
end

function ClientAbilityComponent:recordOnAddBuff(buffData, isSendUIEvent)
	if isSendUIEvent then
		if BuffUIUtils.isAppearFromTopLogoBuff(self, buffData) then
			local appearBuffEnt = self

			if buffData.isTeamBuff and Utils.isPlayer(self) then
				local curPetEnt = self:getCurPetEntity()

				if curPetEnt then
					appearBuffEnt = curPetEnt
				end
			end

			facade:SendMessageCommand(MessageName.APPEAR_FROM_TOPLOGO_BUFF, {
				ent = appearBuffEnt,
				buffData = buffData
			})
			appearBuffEnt.eventEmitter:emit(EventConst.APPEAR_FROM_TOPLOGO_BUFF, {
				ent = appearBuffEnt,
				buffData = buffData
			})
		end

		self:notifyBuffAddEvent(buffData)
	end

	self.displayedBuffs = self.displayedBuffs or {}
	self.displayedBuffs[buffData.templateId] = true
end

function ClientAbilityComponent:onAddBuff(index, buffData)
	if EnableBotTest then
		return
	end

	if self.abilityCompInitTriggerDone then
		self.actorBuff:addBuff(buffData, false)
		self:recordOnAddBuff(buffData, true)
	end

	if self == pg.pawn then
		pg.game.effect:setCurrentBuffIdList(self.buffDataList)
	end

	self:onBuffChange(buffData, true)

	if self.updateStateCache and buffData and buffData.templateId == AbilityConst.BUFF_BUBBLE_FREEZE_HP_ID then
		self:updateStateCache("FREEZE_HP_ST")
	end
end

function ClientAbilityComponent:onRemoveBuff(index, buffData)
	local buff = self.actorBuff.buffMap[buffData.instanceId]

	if buff then
		buff:destroy(buffData.destroyReason)

		self.actorBuff.buffMap[buffData.instanceId] = nil
		self.displayedBuffs = self.displayedBuffs or {}

		local isRemoveRecords = buffData.destroyReason ~= Const.DESTROY_REASON.HOMEPET_REFRESH
		local preparePetLsit = ClientUtils.getPetMasterPrepareList(self)

		if isRemoveRecords then
			self.displayedBuffs[buffData.templateId] = nil

			for idx, petId in pairs(preparePetLsit or EMPTY_TABLE) do
				if petId then
					if petId == self.id then
						self.displayedBuffs[buffData.templateId] = false
					else
						local petEnt = pg.getEntity(petId)
						local checkBuffs = petEnt and petEnt.actorBuff and petEnt.actorBuff.buffMap

						if checkBuffs then
							local checkBuffTempIds = {}

							for _, checkBuff in pairs(checkBuffs or EMPTY_TABLE) do
								if checkBuff and checkBuff.buffData and checkBuff.buffData.templateId then
									checkBuffTempIds[#checkBuffTempIds + 1] = checkBuff.buffData.templateId
								end
							end

							if not table.contains(checkBuffTempIds, buffData.templateId) and petEnt.displayedBuffs then
								petEnt.displayedBuffs[buffData.templateId] = false
							end
						end
					end
				end
			end
		end
	end

	if self.isMainPlayer or self.isMainPet or Utils.isLabelBoss(self.label) or Utils.isLabelElite(self.label) or self:isNpcDuelBotPet() then
		facade:SendMessageCommand(MessageName.ON_BUFF_REMOVE, {
			entId = self.id,
			isTeamBuff = buffData.isTeamBuff,
			buffInsId = buffData.instanceId,
			buffData = buffData
		})

		if buffData.category == AbilityConst.BUFF_CATEGORY_TYPE_SOCIAL then
			facade:SendMessageCommand(MessageName.SOCIAL_BUFF_CHANGE, {
				isAdd = false,
				entId = self.id,
				buffInsId = buffData.instanceId,
				templateId = buffData.templateId
			})
		end
	end

	local buffInfo = {
		buffData = buffData,
		buffInsId = buffData.instanceId,
		isTeamBuff = buffData.isTeamBuff
	}

	self.eventEmitter:emit(EventConst.ON_BUFF_REMOVE, buffInfo)

	if buffData.isTeamBuff then
		local curPetEnt = self.getCurPetEntity and self:getCurPetEntity() or nil

		if curPetEnt then
			curPetEnt.eventEmitter:emit(EventConst.ON_BUFF_REMOVE, buffInfo)
		end
	end

	if self == pg.pawn then
		pg.game.effect:setCurrentBuffIdList(self.buffDataList)
	end

	self:onBuffChange(buffData, false)

	if self.updateStateCache and buffData and buffData.templateId == AbilityConst.BUFF_BUBBLE_FREEZE_HP_ID then
		self:updateStateCache("FREEZE_HP_ST")
	end
end

function ClientAbilityComponent:onBuffChange(buffData, isAdd)
	local buffChangeData = TablePool.getTable()

	buffChangeData.templateId = buffData.templateId
	buffChangeData.isRemove = not isAdd

	if self.isMainPlayer or self == pg.pawn then
		for _, petId in pairs(pg.me.petPrepareList or EMPTY_TABLE) do
			local petEnt = pg.getEntity(petId)

			if petEnt then
				petEnt:postComponentMethod("EVENT_onBindBuffChange", buffChangeData)
			end
		end
	end

	if self.isMainPet then
		self:postComponentMethod("EVENT_onBindBuffChange", buffChangeData)
	end

	TablePool.returnTable(buffChangeData)
end

function ClientAbilityComponent:isNpcDuelBotPet()
	return Utils.isBotPet(self) and pg.space and pg.space:isNpcDuel()
end

function ClientAbilityComponent:onBuffFreezeBuffStartTimeChange(oldFreezeBuffStartTime, newFreezeBuffStartTime, buffIdx)
	local instanceId = self.buffDataList[buffIdx].instanceId
	local buff = self.actorBuff.buffMap[instanceId]

	if buff then
		if newFreezeBuffStartTime == 0 then
			local freezeTime = math.max(self:getGameTime() - oldFreezeBuffStartTime, 0)

			buff:recoverFreezeThink(freezeTime)
		else
			buff:freezeThink()
		end
	end
end

function ClientAbilityComponent:onBuffExpiredTimeChange(oldExpireTime, newExpireTime, buffIdx)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onBuffExpiredTimeChange", oldExpireTime, newExpireTime, buffIdx)
	end

	local buffData = self.buffDataList[buffIdx]

	if self.isMainPlayer or self.isMainPet or Utils.isLabelBoss(self.label) or Utils.isLabelElite(self.label) or self:isNpcDuelBotPet() then
		facade:SendMessageCommand(MessageName.ON_BUFF_EXPIRED_TIME_CHANGE, {
			entId = self.id,
			isTeamBuff = buffData.isTeamBuff,
			buffInsId = buffData.instanceId,
			newExpireTime = newExpireTime,
			newDuration = buffData.duration
		})
	end

	local buffInfo = {
		buffInsId = buffData.instanceId,
		newExpireTime = newExpireTime,
		newDuration = buffData.duration,
		isTeamBuff = buffData.isTeamBuff
	}

	self.eventEmitter:emit(EventConst.ON_BUFF_EXPIRED_TIME_CHANGE, buffInfo)

	if buffData.isTeamBuff then
		local curPetEnt = self.getCurPetEntity and self:getCurPetEntity() or nil

		if curPetEnt then
			curPetEnt.eventEmitter:emit(EventConst.ON_BUFF_EXPIRED_TIME_CHANGE, buffInfo)
		end
	end
end

function ClientAbilityComponent:onBuffLayerChange(oldLayer, newLayer, buffIdx)
	local instanceId = self.buffDataList[buffIdx].instanceId
	local buff = self.actorBuff.buffMap[instanceId]

	if not buff then
		CombatLogger.debug("buff not found", buffIdx, instanceId)

		return
	end

	buff:onBuffLayerChange(oldLayer, newLayer)

	local buffData = self.buffDataList[buffIdx]

	if self.isMainPlayer or self.isMainPet or Utils.isLabelBoss(self.label) or Utils.isLabelElite(self.label) or self:isNpcDuelBotPet() then
		facade:SendMessageCommand(MessageName.BUFF_LAYER_CHANGE, {
			entId = self.id,
			isTeamBuff = buffData.isTeamBuff,
			instanceId = instanceId,
			newLayer = newLayer
		})
	end

	local buffInfo = {
		instanceId = instanceId,
		newLayer = newLayer,
		isTeamBuff = buffData.isTeamBuff
	}

	self.eventEmitter:emit(EventConst.BUFF_LAYER_CHANGE, buffInfo)

	if buffData.isTeamBuff then
		local curPetEnt = self.getCurPetEntity and self:getCurPetEntity() or nil

		if curPetEnt then
			curPetEnt.eventEmitter:emit(EventConst.BUFF_LAYER_CHANGE, buffInfo)
		end
	end
end

function ClientAbilityComponent:checkCanShowDmgNumber(beAttackedTagetActorId, attackActorId, hurtType)
	if hurtType == AbilityConst.HURT_TYPE_HP_ADD then
		local targetEnt = pg.getEntityByActorId(beAttackedTagetActorId)

		if targetEnt and targetEnt.space and Utils.isRobEggSceneId(targetEnt.space.sceneId) and Utils.isEnemy(pg.me, targetEnt) then
			return false
		end
	end

	return true
end

function ClientAbilityComponent:RPC_SC_ShowDamageNumber(beAttackedTagetActorId, hurtType, attackResultType, damageValue, damageShowEnum, damageUITags, attackActorId, targetHitPos, abilityId, spaceInfo)
	if not targetHitPos[1] then
		targetHitPos = self:getPosition()
	end

	local beAttackedTarget = pg.getEntityByActorId(beAttackedTagetActorId)

	if beAttackedTarget ~= nil then
		beAttackedTarget:postComponentMethod("onTakeDamage")
	end

	local canShow = self:checkCanShowDmgNumber(beAttackedTagetActorId, attackActorId, hurtType)

	if canShow then
		local source = pg.getEntityByActorId(attackActorId)
		local damageNumberInfo = {
			targetActorId = beAttackedTagetActorId,
			hurtType = hurtType,
			attackResultType = attackResultType,
			damageValue = damageValue,
			damageShowEnum = damageShowEnum or Const.DAMAGE_SHOW_ENUM_NORMAL,
			damageUITags = damageUITags,
			attackActorId = attackActorId,
			targetHitPos = targetHitPos,
			abilityId = abilityId,
			isFromPet = source and ClientUtils.isInPetPrepareList(source) or false,
			spaceInfo = spaceInfo
		}

		facade:SendMessageCommand(MessageName.SHOW_DAMAGE_NUMBER, damageNumberInfo)
	end

	if Utils.isPlayer(self) and beAttackedTagetActorId == self.actorId and hurtType == AbilityConst.HURT_TYPE_HP_REDUCE and AbilityUtils.shouldRumble(abilityId) then
		pg.game.input:playRumbleByName(ClientConst.RumbleLayer.PLAYER_HIT, "CommonLight")
	end

	if Utils.isPlayer(self) then
		facade:SendMessageCommand(MessageName.ON_PLAYER_HURT)
		self:executePetAdditiveAIEvent("HpDamageTrigger", {
			targetId = beAttackedTagetActorId,
			damageSourceId = attackActorId
		})
		facade:sendLuaEvent(pg.me.id .. SandboxConst.COMMON_EVENT.PLAYER_HURT, {})
	end
end

function ClientAbilityComponent:setNextComboAbility(abilityId)
	ClientAbilityComponent.super.setNextComboAbility(self, abilityId)

	if self == pg.pawn then
		local nextSkillAction = pg.game.controller.nextSkillAction

		nextSkillAction:setNextAction(abilityId)
	end
end

function ClientAbilityComponent:setNextComboTimeline(timeline, timelineId, combatContext)
	ClientAbilityComponent.super.setNextComboTimeline(self, timeline, timelineId, combatContext)

	if self == pg.pawn then
		local nextSkillAction = pg.game.controller.nextSkillAction

		nextSkillAction:setNextActionTimeline(timeline, timelineId, combatContext)
	end
end

function ClientAbilityComponent:actorLockTarget(actorId, partId, instantTurn)
	if not self:checkStatus(ConflictTypes.CT_LOCK_TARGET, nil, nil, true) then
		return
	end

	if instantTurn == nil then
		instantTurn = false
	end

	local targetEnt = pg.getEntityByActorId(actorId)

	if targetEnt then
		self:faceToTarget(targetEnt, partId)
	elseif self == pg.pawn then
		local moveAxis = pg.game.controller.moveAxis

		if moveAxis ~= nil and (moveAxis[1] ~= 0 or moveAxis[2] ~= 0) then
			self.eModel:OnHandleMoveDirection(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, moveAxis[1], moveAxis[2], moveAxis[3], instantTurn)
		end
	end
end

function ClientAbilityComponent:lockTarget(actorId, partId, isForceLock, changeAttackTarget)
	if isForceLock == nil then
		if actorId == self.lockedActorId then
			isForceLock = self.isForceLock
		else
			isForceLock = false
		end
	end

	partId = partId or 0

	local oldLockTargetActorId = self.lockedActorId

	if Utils.isPet(self) then
		if not actorId then
			return
		end

		local master = self:getMasterEntity()

		if master then
			if master.petLockedActorId == actorId then
				return
			end

			local oldPetLockedActorId = master.petLockedActorId

			master.petLockedActorId = actorId

			self:postComponentMethod("onLockTargetChange", oldPetLockedActorId, actorId)
		end
	else
		local isForceLockChange = self.isForceLock ~= isForceLock

		if isForceLockChange or oldLockTargetActorId ~= actorId or self.lockedPartId ~= partId then
			self.lockedActorId = actorId
			self.lockedPartId = partId
			self.isForceLock = isForceLock

			self:serverMsgNoGC("RPC_CS_LockTarget", actorId, isForceLock)
			self.subject:notify(AbilityConst.COMBAT_EVENT_ON_LOCKED_TARGET_CHANGE, actorId)
			self:postComponentMethod("onLockTargetChange", oldLockTargetActorId, actorId)

			if self.isMainPlayer then
				facade:SendMessageCommand(MessageName.LOCKED_TARGET_CHANGE, {
					isForceLockChange
				})
			end
		end
	end

	if changeAttackTarget and Utils.isPuppet(self) then
		self:changeAttackTarget(actorId)
	end
end

function ClientAbilityComponent:unlockTarget(changeAttackTarget)
	self:lockTarget(0, 0, nil, changeAttackTarget)
end

function ClientAbilityComponent:changeAttackTarget(actorId)
	if Utils.checkIsAuthorityMaster(self) and self.attackTargetActorId ~= actorId and Utils.checkHateModeEqual(self) then
		local old = self.attackTargetActorId or 0

		self.attackTargetActorId = actorId or 0

		self:serverMsgNoGC("RPC_CS_ChangeAttackTarget", self.attackTargetActorId)
	end
end

function ClientAbilityComponent:getProjectileHitPos()
	return CombatActionTool.getHitPosition(self)
end

function ClientAbilityComponent:RPC_SC_StopCombatActionTimeline()
	self:stopAnimationByTag(TagMask.Skill)
	self.actorTimeline:stopCombatActionTimeline()
end

function ClientAbilityComponent:isInAir(heightOffset)
	return not self:isGrounded(heightOffset)
end

function ClientAbilityComponent:isGrounded(heightOffset)
	heightOffset = heightOffset or 0.2

	local succ, groundHeight = PhysicsUtils.getGroundHeight(self:getPosition())

	return succ and groundHeight >= 0 and groundHeight < heightOffset
end

function ClientAbilityComponent:onAddAbility(abilityId, ability)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("onAddAbility", abilityId, inspect(ability))
	end

	if not self.abilityCompInitTriggerDone then
		return
	end

	ability:registerCastingInfo()
	ability:onAbilityAdded()
	ClientAbilityUtils.preloadAbility(self, abilityId)

	if self.isMainPlayer or self.isMainPet then
		facade:sendMsgToUI(MessageName.SKILL_CD_END_TIME_UPDATE, {
			abilityId = abilityId,
			newCd = ability.cdEndTime,
			owner = self
		})
	end

	self:postComponentMethod("EVENT_onAddAbility", abilityId, ability)
end

function ClientAbilityComponent:onRemoveAbility(abilityId, ability)
	ClientAbilityUtils.unPreloadAbility(self, abilityId)
	ability:clearCastingInfo()
	ability:destroy()
	self:postComponentMethod("EVENT_onRemoveAbility", abilityId, ability)
end

function ClientAbilityComponent:onAddStolenAbility(abilityId, ability)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("onAddStolenAbility", abilityId, ability)
	end

	ability:registerCastingInfo()
	ability:onAbilityAdded()

	if self.isMainPlayer or self.isMainPet then
		facade:SendMessageCommand(MessageName.PLAYER_CUR_SKILL_MAP, {
			self
		})
	end
end

function ClientAbilityComponent:onAddCallFriendAbility(abilityId, ability)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("onAddCallFriendAbility", abilityId, ability)
	end

	ability:registerCastingInfo()
	ability:onAbilityAdded(false)
end

function ClientAbilityComponent:onRemoveStolenAbility(abilityId, ability)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("onRemoveStolenAbility", abilityId, ability)
	end

	ability:clearCastingInfo()
	ability:destroy()

	if self.isMainPlayer or self.isMainPet then
		facade:SendMessageCommand(MessageName.PLAYER_CUR_SKILL_MAP, {
			self
		})
	end
end

function ClientAbilityComponent:onAbilityCdChange(oldCd, newCd, abilityId)
	if self.isMainPlayer or self.isMainPet then
		facade:sendMsgToUI(MessageName.SKILL_CD_END_TIME_UPDATE, {
			abilityId = abilityId,
			newCd = newCd,
			owner = self
		})
	end
end

function ClientAbilityComponent:onAbilityOverrideEpCostChange(old, new, abilityId)
	if self.isMainPlayer or self.isMainPet then
		facade:sendMsgToUI(MessageName.ON_ABILITY_EP_COST_CHANGED)
	end
end

function ClientAbilityComponent:onAbilityFreezeAdd(abilityId, duration)
	if self.isMainPlayer or self.isMainPet then
		facade:sendMsgToUI(MessageName.SKILL_CD_END_TIME_UPDATE, {
			abilityId = abilityId,
			newCd = duration,
			owner = self
		})
	end
end

function ClientAbilityComponent:onAbilityFreezeRemove(abilityId, duration)
	if self.isMainPlayer or self.isMainPet then
		facade:sendMsgToUI(MessageName.SKILL_CD_END_TIME_UPDATE, {
			abilityId = abilityId,
			newCd = duration,
			owner = self
		})
	end
end

function ClientAbilityComponent:RPC_SC_SetAttribute(attributeId, value)
	local oldValue = self.baseAttr[attributeId]

	if value == oldValue then
		return
	end

	self.baseAttr[attributeId] = value

	self.actorCombatAttribute:onAttributeChange(attributeId, oldValue, value)
end

function ClientAbilityComponent:onBreakEndTimeChange(oldValue, newValue)
	if Utils.isPet(self) or Utils.isPuppet(self) then
		local deltaBp = newValue and oldValue and newValue - oldValue or nil

		facade:SendMessageCommand(MessageName.BREAK_POINT_CHANGE, {
			entity = self,
			deltaBp = deltaBp
		})
		self.eventEmitter:emit(EventConst.TOPLOGO_BREAK_POINT, deltaBp)
	end
end

function ClientAbilityComponent:onBreakRecoverTimeChange(oldValue, newValue)
	if Utils.isPet(self) or Utils.isPuppet(self) then
		local deltaBp = newValue and oldValue and newValue - oldValue or nil

		facade:SendMessageCommand(MessageName.BREAK_POINT_CHANGE, {
			entity = self,
			deltaBp = deltaBp
		})
		self.eventEmitter:emit(EventConst.TOPLOGO_BREAK_POINT, deltaBp)
	end
end

function ClientAbilityComponent:onUnSummonBuffFreezeTime(oldValue, newValue)
	if newValue ~= 0 then
		self.actorBuff.unSummonBuffFreezeTime = newValue
	end
end

function ClientAbilityComponent:initBuffControlST()
	local buffTag2GroupMap = BuffTagGroupData.BUFF_TAG_2_GROUP_MAP
	local isInBuffControlST = false
	local isBuffForbidAbility = false

	for tagId = 1, AbilityConst.BUFF_TAG_MAX do
		local hasTag = Bitset.band(self.buffTag, Bitset.lshift(1, tagId - 1))

		if ToBool(hasTag) then
			if AbilityConst.FORBID_SWITCH_PET_BUFF_TAGS[tagId] then
				isInBuffControlST = true
			end

			if AbilityConst.FORBID_ABILITY_BUFF_TAGS[tagId] then
				isBuffForbidAbility = true
			end

			if isBuffForbidAbility and isInBuffControlST then
				break
			end
		end
	end

	if self.isInBuffControlST ~= isInBuffControlST then
		self.isInBuffControlST = isInBuffControlST

		if self == pg.pawn then
			facade:sendMsgToUI(MessageName.ON_BUFF_CONTROL_ST_CHANGED)
		end
	end

	if self.isBuffForbidAbility ~= isBuffForbidAbility then
		self.isBuffForbidAbility = isBuffForbidAbility

		if self == pg.pawn then
			facade:sendMsgToUI(MessageName.ON_BUFF_FORBID_ABILITY_CHANGED)
		end
	end
end

function ClientAbilityComponent:onBuffTagChange(oldValue, newValue)
	local changeTrueList = {}
	local changeFalseList = {}
	local buffTag2GroupMap = BuffTagGroupData.BUFF_TAG_2_GROUP_MAP
	local isInBuffControlST = false
	local isBuffForbidAbility = false

	for tagId = 1, AbilityConst.BUFF_TAG_MAX do
		local tagOld = Bitset.band(oldValue, Bitset.lshift(1, tagId - 1))
		local tagNew = Bitset.band(newValue, Bitset.lshift(1, tagId - 1))

		if ToBool(tagNew) then
			if AbilityConst.FORBID_SWITCH_PET_BUFF_TAGS[tagId] then
				isInBuffControlST = true
			end

			if AbilityConst.FORBID_ABILITY_BUFF_TAGS[tagId] then
				isBuffForbidAbility = true
			end
		end

		if tagOld ~= tagNew then
			local newVal = ToBool(tagNew)

			if newVal then
				changeTrueList[#changeTrueList + 1] = tagId
			else
				changeFalseList[#changeFalseList + 1] = tagId
			end

			self.subject:notify(AbilityConst.COMBAT_EVENT_ON_BUFF_TAG_CHANGE, tagId, newVal)
		end
	end

	if #changeTrueList ~= 0 then
		for _, tagId in pairs(changeTrueList) do
			local checkCmd = ClientUtils.getBuffTag2CheckCmdEvent(tagId)

			if checkCmd ~= nil then
				self:checkStatus(checkCmd)
			end
		end

		self:postComponentMethod("notifyBuffTagChange", changeTrueList, true)
	end

	if #changeFalseList ~= 0 then
		self:postComponentMethod("notifyBuffTagChange", changeFalseList, false)
	end

	if self.isInBuffControlST ~= isInBuffControlST then
		self.isInBuffControlST = isInBuffControlST

		if self == pg.pawn then
			facade:sendMsgToUI(MessageName.ON_BUFF_CONTROL_ST_CHANGED)
		end
	end

	if self.isBuffForbidAbility ~= isBuffForbidAbility then
		self.isBuffForbidAbility = isBuffForbidAbility

		if self == pg.pawn then
			facade:sendMsgToUI(MessageName.ON_BUFF_FORBID_ABILITY_CHANGED)
		end
	end
end

function ClientAbilityComponent:onBuffImmuneTagChange(oldValue, newValue)
	return
end

function ClientAbilityComponent:RPC_SC_CastAbilityByServer(abilityId, targetActorId, castSource)
	if not self.abilityCompInitTriggerDone then
		self:addAbilityInitTriggerCallbacks(function()
			self:_Rpc_RPC_SC_CastAbilityByServer(abilityId, targetActorId, castSource)
		end)

		return
	end

	local castResult, err

	if targetActorId and targetActorId ~= 0 then
		castResult, err = self:clientCastAbilityOnTarget(abilityId, targetActorId, castSource, {
			isFromServer = true
		})
	else
		castResult, err = self:clientCastAbilityNoTarget(abilityId, castSource, {
			isFromServer = true
		})
	end

	if not castResult and LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("CastSkillByServer err", abilityId, castSource, targetActorId, err)
	end
end

function ClientAbilityComponent:RPC_SC_CastAbilityOnTarget(abilityId, targetActorId, castSource)
	local ability = self:getAbility(abilityId)

	if not ability then
		return
	end

	local combatCasterInfo = self.castingMap[abilityId]

	if not combatCasterInfo then
		return
	end

	combatCasterInfo:ctor(self.actorId)

	if targetActorId ~= 0 then
		combatCasterInfo.targetActorId = targetActorId
	end

	self:doAbilityCast(abilityId, ability, combatCasterInfo, castSource)
end

function ClientAbilityComponent:RPC_SC_CastAbilityOnPosRot(abilityId, position, rotation, castSource)
	local ability = self:getAbility(abilityId)

	if not ability then
		return
	end

	local combatCasterInfo = self.castingMap[abilityId]

	if not combatCasterInfo then
		return
	end

	combatCasterInfo:ctor(self.actorId)
	Vector3.Convert(position)
	Quaternion.Convert(rotation)

	combatCasterInfo.attackPos = position
	combatCasterInfo.attackRot = rotation

	self:doAbilityCast(abilityId, ability, combatCasterInfo, castSource)
end

function ClientAbilityComponent:RPC_SC_AddProjectile(projectileParams)
	if self.authority == Const.AUTHORITY_MASTER then
		return
	end

	projectileParams.pos = Vector3.Convert(projectileParams.pos)
	projectileParams.rotation = Quaternion.Convert(projectileParams.rotation)
	projectileParams.targetPosition = Vector3.Convert(projectileParams.targetPosition)

	self.space.projectileMgr:addProjectile(projectileParams)
end

function ClientAbilityComponent:RPC_SC_ProjectileReset(projectileInstanceId, pos, rot)
	if self.authority == Const.AUTHORITY_MASTER then
		return
	end

	pos = Vector3.Convert(pos)
	rot = Quaternion.Convert(rot)

	local projectileMgr = self.space.projectileMgr
	local projectile = projectileMgr:getProjectile(projectileInstanceId)

	if projectile ~= nil then
		projectile.pos:Copy(pos)
		projectile.rot:Copy(rot)
		projectile:onResetToProjectile()
	end
end

function ClientAbilityComponent:RPC_SC_DestroyAllProjectile()
	self:destroyAllProjectile()

	if self.authority == Const.AUTHORITY_MASTER then
		self:serverMsgNoGC("RPC_CS_FinishDestroyAllProjectile")
	end
end

function ClientAbilityComponent:notifyCustomEvent(eventName, customData)
	if string.isNilOrEmpty(eventName) then
		return
	end

	self:serverMsgNoGC("RPC_CS_NotifyCustomEvent", eventName, customData)
	self.subject:notify(eventName, customData)
end

function ClientAbilityComponent:checkAbilityBtnInCharing(checkAbilityId)
	local btnLongPressMap = pg.game.controller.longPressMap

	if btnLongPressMap then
		for abilityId, _ in pairs(btnLongPressMap) do
			local realAbilityId = self:getSwitchSkill(abilityId)

			if realAbilityId == checkAbilityId then
				return true
			end
		end
	end

	return false
end

function ClientAbilityComponent:startChargeByAbilityId(abilityId)
	if self == pg.pawn and not self:checkAbilityBtnInCharing(abilityId) then
		return
	end

	abilityId = self:getSwitchSkill(abilityId)

	local ability = self:getAbility(abilityId)

	if ability and ability:isChargeAbility() then
		local startTime = self:getGameTime()

		self.chargeMap[ability.abilityId] = {
			startTime
		}

		self:serverMsgNoGC("RPC_CS_StartCharge", ability.abilityId, startTime)
	end
end

function ClientAbilityComponent:stopChargeByAbilityId(abilityId)
	abilityId = self:getSwitchSkill(abilityId)

	if not self:isCastingAbility(abilityId) then
		return
	end

	local chargeInfoMap = self.chargeMap ~= nil and self.chargeMap[abilityId]

	if chargeInfoMap then
		chargeInfoMap[2] = self:getGameTime()

		self:serverMsgNoGC("RPC_CS_StopCharge", abilityId, chargeInfoMap[2])

		self.chargeMap[abilityId] = nil

		self.subject:notify(AbilityConst.COMBAT_EVENT_END_CHARGE, chargeInfoMap[2] - chargeInfoMap[1])
	end

	if ToBool(self.slaves) then
		for _, actorId in ipairs(self.slaves) do
			local ent = pg.getEntityByActorId(actorId)

			if ent then
				ent:stopChargeByAbilityId(abilityId)
			end
		end
	end
end

function ClientAbilityComponent:tryStopSwitchAbility(abilityId)
	abilityId = self:getSwitchSkill(abilityId)

	local ability = self:getAbility(abilityId)

	if ability and ability:isSwitchAbility() then
		local switchInfo = self.switchMap ~= nil and self.switchMap[abilityId]

		if switchInfo then
			local curTime = self:getGameTime()

			if curTime - switchInfo > ability:getSwitchAbilitySafeTime() then
				if LoggerManager.checkLogger(LoggerConst.INFO) then
					self.logger:info("@hyj notifyEndSwitch", self.actorId, abilityId)
				end

				self:serverMsgNoGC("RPC_CS_NotifySwitch", ability.abilityId, false)
				self.actorTimeline:resetCombatActionTimeline()

				self.switchMap[ability.abilityId] = nil
			end

			return true
		end
	end

	return false
end

function ClientAbilityComponent:onBpChange(ov, nv)
	local deltaBp = nv and ov and nv - ov or nil

	facade:SendMessageCommand(MessageName.BREAK_POINT_CHANGE, {
		entity = self,
		deltaBp = deltaBp
	})
	self.eventEmitter:emit(EventConst.TOPLOGO_BREAK_POINT, deltaBp)
end

function ClientAbilityComponent:forceUngrounded(value, reason)
	if self.eModel then
		if reason == nil then
			reason = Const.ForceUnGroundReasons.Motion
		end

		if self:hasEModelComponent(Const.COMPONENT_MOTION) then
			if value then
				self.eModel:SetComputeGravity(Const.COMPONENT_MOTION, ClientConst.GravityMask.SKill, false)
			else
				self.eModel:ClearGravityMask(Const.COMPONENT_MOTION, ClientConst.GravityMask.SKill)
			end

			self.eModel:AlwaysForceUnGround(Const.COMPONENT_MOTION, value, reason)
		end
	end
end

function ClientAbilityComponent:onBreakStateChange(inBreak)
	if Utils.isPuppet(self) or Utils.isPet(self) then
		facade:SendMessageCommand(MessageName.BREAK_STATE_CHANGE, {
			isBreak = inBreak,
			ent = self
		})
		facade:SendMessageCommand(MessageName.BREAK_POINT_CHANGE, {
			entity = self
		})
		self.eventEmitter:emit(EventConst.TOPLOGO_BREAK_POINT)
	end

	if inBreak and self.topLogoData then
		self.eventEmitter:emit(EventConst.TOPLOGO_CATCH_LOCK, true)
	end

	if self.pauseBt then
		if inBreak then
			self:pauseBt(AiConst.PauseBtReason.Break)
		else
			self:resumeBt(AiConst.PauseBtReason.Break)
		end
	end

	if not inBreak then
		self.doneEnterBreakAction = nil

		self.eventEmitter:emit(EventConst.TOPLOGO_CATCH_LOCK, false)
	else
		self:stopBurrowByHit()
	end
end

function ClientAbilityComponent:setRePressAbilitySlotInfo(abilityId, endTime, enableCountDown)
	AbilityComponent.setRePressAbilitySlotInfo(self, abilityId, endTime)

	if not enableCountDown then
		return
	end

	if self.isMainPlayer or self.isMainPet then
		if endTime then
			local timeNow = self:getGameTime()
			local totalTime = endTime and endTime - timeNow or 0

			self.abilitySwitchInfo[abilityId] = {
				abilityId,
				true,
				endTime,
				totalTime
			}
		else
			self.abilitySwitchInfo[abilityId] = nil
		end

		facade:SendMessageCommand(MessageName.SKILL_SWITCH_UPDATE, abilityId)
	end
end

function ClientAbilityComponent:notifyOverrideTagChange(abilityId, overrideTagId)
	facade:sendMsgToUI(MessageName.SKILL_TAG_UPDATE, {
		abilityId = abilityId,
		overrideTagId = overrideTagId
	})
end

function ClientAbilityComponent:onActionMaskChange(mask, value, abilityId)
	if mask == AbilityConst.ACTION_MASK_IN_COMBO and value == true then
		local targetActorId = self.castingMap[abilityId].targetActorId

		self:sendAbilityNoHit(targetActorId, self.abilityMap[abilityId])

		if self == pg.pawn then
			pg.game.controller.nextSkillAction:update()

			return
		end
	elseif mask == AbilityConst.ACTION_MASK_IN_BACKSWING and value == true then
		local targetActorId = abilityId and self.castingMap[abilityId].targetActorId

		self:sendAbilityNoHit(targetActorId, self.abilityMap[abilityId])

		if AbilityUtils.isUltimateAbility(abilityId) then
			AIUtils.resumeBt(self, AiConst.PauseBtReason.UltimateAbility)
		end
	end

	if mask == AbilityConst.ACTION_MASK_IN_CAST then
		if Utils.isPlayerPet(self) and not AbilityUtils.isNormalAttack(abilityId) then
			local entityConfigData = self:getConfigData()

			if value == true then
				self.bodyWeight = ((entityConfigData.weight or 1) + AbilitySettingGlobalConstData.inCastWeightValue) * self.curModelScale
				self.rawTp = self.actorCombatAttribute:getTp()

				self:serverMsgNoGC("RPC_CS_ChangeTpInCast", AbilitySettingGlobalConstData.inCastStaminaValue, AbilitySettingGlobalConstData.inCastStaminaValue, value)
				self.actorCombatAttribute:changeTpMaxV(AbilitySettingGlobalConstData.inCastStaminaValue)
				self.actorCombatAttribute:changeTp(AbilitySettingGlobalConstData.inCastStaminaValue)
			else
				self.bodyWeight = (entityConfigData.weight or 1) * self.curModelScale

				if self.rawTp ~= nil then
					local changeValue = self.rawTp - self.actorCombatAttribute:getTp()

					changeValue = math.min(changeValue, 0)

					self:serverMsgNoGC("RPC_CS_ChangeTpInCast", changeValue, -AbilitySettingGlobalConstData.inCastStaminaValue, value)
					self.actorCombatAttribute:changeTp(changeValue)
					self.actorCombatAttribute:changeTpMaxV(-AbilitySettingGlobalConstData.inCastStaminaValue)

					self.rawTp = nil
				end
			end
		end
	elseif mask == AbilityConst.ACTION_MASK_IN_HIT and value then
		self:addTempTPByHit()
	end
end

function ClientAbilityComponent:onSkillSwitched(fromAbilityId, toAbilityId, needShow, endTime)
	local timeNow = self:getGameTime()
	local totalTime = endTime and endTime - timeNow or 0

	self.abilitySwitchInfo[fromAbilityId] = {
		toAbilityId,
		needShow,
		endTime,
		totalTime
	}

	if self.isMainPlayer or self.isMainPet then
		facade:SendMessageCommand(MessageName.SKILL_SWITCH_UPDATE, fromAbilityId)
	end
end

function ClientAbilityComponent:onSwitchSkillFreezeAdd(from, freezeTime)
	local timerId = self.switchSkillTimerMap[from]

	if timerId then
		self:removeTimer(timerId)

		self.switchSkillTimerMap[from] = nil
	end

	if self.isMainPlayer or self.isMainPet then
		facade:SendMessageCommand(MessageName.SKILL_SWITCH_UPDATE, from)
	end
end

function ClientAbilityComponent:onSwitchSkillFreezeRemove(from, freezeTime)
	local endTime = self.switchSkillEndTimeMap[from]
	local timerId = self.switchSkillTimerMap[from]

	if timerId then
		self:removeTimer(timerId)

		self.switchSkillTimerMap[from] = nil
	end

	if ToBool(endTime) then
		local leftTime = endTime - self:getGameTime()

		if leftTime > 0 then
			self.switchSkillTimerMap[from] = self:addTimer(leftTime, function()
				self.switchSkillTimerMap[from] = nil

				self:doSwitchSkillRecover(from)
			end)
		end

		local info = self.abilitySwitchInfo[from]

		if info and ToBool(info[3]) then
			info[3] = endTime
		end
	end

	if self.isMainPlayer or self.isMainPet then
		facade:SendMessageCommand(MessageName.SKILL_SWITCH_UPDATE, from)
	end
end

function ClientAbilityComponent:onTakeDamage()
	self.lastHurtTime = Time.realSecondCache

	if self == pg.pawn and not ToBool(pg.game.controller.lockHelper.forceLockActorId) then
		pg.game.controller.lockHelper:tryLockTarget()
	end
end

function ClientAbilityComponent:onContinuousButtonQteHit()
	local controllerComponent = self:getEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER)
	local abilityCharacterStateInfo = NotNil(controllerComponent) and controllerComponent.abilityCharacterStateInfo or nil

	if abilityCharacterStateInfo and abilityCharacterStateInfo.abilityStateMachine ~= 0 then
		abilityCharacterStateInfo.abilityQteInput = true
	end
end

function ClientAbilityComponent:EVENT_BeTrapped()
	self.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)
	self:stopForceDisplacement()
	EModelUtils.clearAllVelocity(self)
end

function ClientAbilityComponent:getLastHurtInterval()
	if not self.lastHurtTime then
		return -1
	end

	return Time.realSecondCache - self.lastHurtTime
end

function ClientAbilityComponent:showSkillCountDown(abilityId, enable, endTime)
	local timeNow = self:getGameTime()
	local totalTime = endTime and endTime - timeNow or 0

	self.abilityCountDownInfo[abilityId] = {
		enable,
		endTime,
		totalTime
	}

	if self.isMainPlayer or self.isMainPet then
		facade:SendMessageCommand(MessageName.SKILL_COUNT_DOWN_UPDATE, abilityId)
	end
end

function ClientAbilityComponent:stunOnCollision(tag, srcActorId)
	if self.subject:isEventListening(AbilityConst.COMBAT_EVENT_STUN_ON_COLLISION) then
		tag = tag or ""

		self:serverMsgNoGC("RPC_SC_StunOnCollision", tag, srcActorId)
		self.subject:notify(AbilityConst.COMBAT_EVENT_STUN_ON_COLLISION, tag)
	end
end

function ClientAbilityComponent:drawAbilityGizmo(shapeKind, center, rot, shapeArgs)
	center = Vector3.Clone(center)
	rot = Quaternion.Clone(rot)

	ClientDebugUtils.drawDebugHitBoxMesh(center, rot, shapeKind, shapeArgs, 3)
end

function ClientAbilityComponent:drawUniqueAbilityGizmo(uid, shapeKind, center, rot, shapeArgs)
	if string.isNilOrEmpty(uid) then
		return
	end

	center = Vector3.Clone(center)
	rot = Quaternion.Clone(rot)

	ClientDebugUtils.drawUniqueDebugHitBoxMesh(uid, center, rot, shapeKind, shapeArgs, 1)
end

function ClientAbilityComponent:RPC_SC_DrawHitActor(pos)
	pos = Vector3.Clone(pos)

	if Utils.isCreation(self) then
		if self.shapeType == AbilityConst.LX_GEOMETRY_TYPE_SPHERE then
			local lxShape = self:getShape()

			ClientDebugUtils.drawDebugHitBodyMesh(lxShape.center, self:getRotation(), AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D, {
				lxShape.radius,
				lxShape.heightUp,
				lxShape.heightDown
			})
		elseif self.shapeType == AbilityConst.LX_GEOMETRY_TYPE_BOX then
			local lxShape = self:getShape()

			ClientDebugUtils.drawDebugHitBodyMesh(lxShape.center, self:getRotation(), AbilityConst.LX_GEOMETRY_TYPE_BOX, {
				lxShape.extents.x,
				lxShape.extents.y,
				lxShape.extents.z
			})
		end
	else
		ClientDebugUtils.drawDebugHitBodyMesh(pos, self:getRotation(), AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D, {
			self.bodySize,
			self.bodyHeight,
			0
		})
	end
end

function ClientAbilityComponent:enableDrawActorHitBox(enable)
	if not self:hasEModelComponent(Const.COMPONENT_IDX_PHYSX) then
		return
	end

	if Utils.isCreation(self) then
		if self.shapeType == AbilityConst.LX_GEOMETRY_TYPE_SPHERE then
			local lxShape = self:getShape()

			if lxShape.radius == 0 or lxShape.heightUp == 0 and lxShape.heightDown == 0 then
				return
			end

			self.eModel:SetHitBoxMeshActive(Const.COMPONENT_IDX_PHYSX, enable, AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D, {
				lxShape.radius,
				lxShape.heightUp,
				lxShape.heightDown
			}, ClientAbilityConst.MESH_HIT_BODY_COLOR)
		elseif self.shapeType == AbilityConst.LX_GEOMETRY_TYPE_BOX then
			local lxShape = self:getShape()

			if lxShape.extents.x == 0 or lxShape.extents.y == 0 or lxShape.extents.z == 0 then
				return
			end

			self.eModel:SetHitBoxMeshActive(Const.COMPONENT_IDX_PHYSX, enable, AbilityConst.LX_GEOMETRY_TYPE_BOX, {
				lxShape.extents.x,
				lxShape.extents.y,
				lxShape.extents.z
			}, ClientAbilityConst.MESH_HIT_BODY_COLOR)
		end
	else
		if not ToBool(self.bodySize) or not ToBool(self.bodyHeight) then
			return
		end

		self.eModel:SetHitBoxMeshActive(Const.COMPONENT_IDX_PHYSX, enable, AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D, {
			self.bodySize,
			self.bodyHeight,
			0
		}, ClientAbilityConst.MESH_HIT_BODY_COLOR)
	end
end

function ClientAbilityComponent:enableDrawRbCollider(enable)
	if not self:hasEModelComponent(Const.COMPONENT_IDX_PHYSX) then
		return
	end

	local actorInfo = Utils.getEntityConfigData(self)
	local rigidbodyId = actorInfo.rigidbody

	if not rigidbodyId then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			self.logger:warn("enableDrawRbCollider: RigidbodyId is nil", self.actorId)
		end

		return
	end

	local rigidbodyData = RigidbodyData[rigidbodyId]

	if not rigidbodyData then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			self.logger:warn("enableDrawRbCollider: RigidbodyData is nil", self.actorId)
		end

		return
	end

	local scale = self.curModelScale or 1
	local centerY = rigidbodyData.center and (rigidbodyData.center[2] or rigidbodyData.center.y) or rigidbodyData.height * 0.5

	self.eModel:SetRbColliderMeshActive(Const.COMPONENT_IDX_PHYSX, enable, AbilityConst.LX_GEOMETRY_TYPE_CAPSULE, {
		rigidbodyData.radius * scale,
		rigidbodyData.height * scale,
		centerY * scale
	}, ClientAbilityConst.MESH_RB_COLLIDER_COLOR)

	if Utils.isPuppet(self) then
		self.eModel:SetCombatColliderMeshActive(Const.COMPONENT_IDX_PHYSX, enable, ClientAbilityConst.MESH_COMBAT_COLLIDER_COLOR)
	end
end

function ClientAbilityComponent:enableDrawRbCatchCollider(enable)
	if not Utils.isPuppet(self) or not self:hasEModelComponent(Const.COMPONENT_IDX_PHYSX) then
		return
	end

	self.eModel:SetPuppetCatchExpandMeshActive(Const.COMPONENT_IDX_PHYSX, enable, ClientAbilityConst.MESH_RB_CATCH_COLLIDER_COLOR)
end

function ClientAbilityComponent:enterCrouchState()
	pg.game.camera.playerCameraMode:refreshCrouchHeight()

	return true
end

function ClientAbilityComponent:exitCrouchState()
	pg.game.camera.playerCameraMode:refreshTargetPlayer()

	return true
end

function ClientAbilityComponent:callInflateStateChange(inState)
	self:serverMsgNoGC("RPC_CS_InflateStateChange", inState)
	self.subject:notify(AbilityConst.COMBAT_EVENT_ON_INFLATE_STATE_CHANGE, inState)
end

function ClientAbilityComponent:handleSpecialCharacterStateEvents(oldState, newState)
	local isMainActor = self.isMainPlayer or self.isMainPet
	local isSpecialState = false

	if CharacterStateConst.isChildOfState(oldState, CharacterStateConst.FLYING) ~= CharacterStateConst.isChildOfState(newState, CharacterStateConst.FLYING) then
		local isNewStateFlying = CharacterStateConst.isChildOfState(newState, CharacterStateConst.FLYING)

		self.subject:notify(AbilityConst.COMBAT_EVENT_ON_FLY_STATE_CHANGE, isNewStateFlying)
		self:initNorAtkAbilityList(isNewStateFlying)

		isSpecialState = true
	end

	if CharacterStateConst.isChildOfState(oldState, CharacterStateConst.SNEAK) ~= CharacterStateConst.isChildOfState(newState, CharacterStateConst.SNEAK) then
		if CharacterStateConst.isChildOfState(oldState, CharacterStateConst.SNEAK) then
			self:enableSandUndergroundEffect(false)

			local burrowActionData = self:getEntityCacheVal(AbilityConst.COMBAT_EVENT_ON_BURROW_STATE_CHANGE)

			if burrowActionData then
				self:switchSkill(burrowActionData.burrowAbilityId, burrowActionData.burrowAbilityId)
			end
		else
			self:enableSandUndergroundEffect(true)
		end

		isSpecialState = true
	end

	if CharacterStateConst.isChildOfState(oldState, CharacterStateConst.TAKEROOT) ~= CharacterStateConst.isChildOfState(newState, CharacterStateConst.TAKEROOT) then
		if not self.inSwitchToControlMark then
			local takeRootActionData = self:getEntityCacheVal(AbilityConst.COMBAT_EVENT_ON_TAKE_ROOT_STATE_CHANGE)

			if takeRootActionData and ToBool(takeRootActionData.switchToAbilityId) then
				if CharacterStateConst.isChildOfState(oldState, CharacterStateConst.TAKEROOT) then
					self:switchSkill(takeRootActionData.takeRootAbilityId, takeRootActionData.takeRootAbilityId)
				else
					self:switchSkill(takeRootActionData.takeRootAbilityId, takeRootActionData.switchToAbilityId, self:getGameTime() + takeRootActionData.duration)
				end
			end
		end

		isSpecialState = true
	end

	if newState == CharacterStateConst.DEAD or oldState == CharacterStateConst.DEAD or oldState == CharacterStateConst.REVIVE then
		isSpecialState = true
	end

	if isMainActor and isSpecialState then
		facade:SendMessageCommand(MessageName.SPECIAL_STATE_CHANGE)
	end

	self.subject:notify(AbilityConst.COMBAT_EVENT_ON_CHARACTER_STATE_CHANGE, oldState, newState)
end

function ClientAbilityComponent:handleCharacterStateConditionalEffects(newState)
	for effectStr, info in pairs(self.characterStateConditionalEffects) do
		local isInCurState = false

		for _, state in pairs(info.applyInState) do
			if CharacterStateConst.isChildOfState(newState, CharacterStateConst[state]) then
				isInCurState = true

				break
			end
		end

		if isInCurState then
			if info.effectId == nil then
				local effectId = self:playEffect(effectStr, info.extraData)

				info.effectId = effectId
			end
		elseif info.effectId ~= nil then
			self:stopEffectById(info.effectId)

			info.effectId = nil
		end
	end
end

function ClientAbilityComponent:handleCharacterStateConditionalVolumes(newState)
	if pg.pawn ~= self then
		return
	end

	local masterEntity = self

	if Utils.isPet(self) then
		masterEntity = self:getMasterEntity()
	end

	if not masterEntity then
		return
	end

	for index, applyInState in pairs(masterEntity.characterStateConditionalVolumes) do
		local isInCurState = false

		for _, state in pairs(applyInState) do
			if CharacterStateConst.isChildOfState(newState, CharacterStateConst[state]) then
				isInCurState = true

				break
			end
		end

		if isInCurState then
			pg.game.camera:enableVolumeEffect(index, true)
		else
			pg.game.camera:enableVolumeEffect(index, false)
		end
	end
end

function ClientAbilityComponent:addDynamicRPCState(parentStates, states)
	if parentStates then
		for _, parentState in ipairs(parentStates) do
			if type(parentState) == "string" then
				parentState = CharacterStateConst[parentState]
			end

			if parentState then
				self.dynamicParentRPCStateMap[parentState] = (self.dynamicParentRPCStateMap[parentState] or 0) + 1
			end
		end
	end

	if states then
		for _, state in ipairs(states) do
			if type(state) == "string" then
				state = CharacterStateConst[state]
			end

			if state then
				self.dynamicRPCStateMap[state] = (self.dynamicRPCStateMap[state] or 0) + 1
			end
		end
	end
end

function ClientAbilityComponent:removeDynamicRPCState(parentStates, states)
	if parentStates then
		for _, parentState in ipairs(parentStates) do
			if type(parentState) == "string" then
				parentState = CharacterStateConst[parentState]
			end

			if parentState then
				self.dynamicParentRPCStateMap[parentState] = (self.dynamicParentRPCStateMap[parentState] or 0) - 1

				if self.dynamicParentRPCStateMap[parentState] <= 0 then
					self.dynamicParentRPCStateMap[parentState] = nil
				end
			end
		end
	end

	if states then
		for _, state in ipairs(states) do
			if type(state) == "string" then
				state = CharacterStateConst[state]
			end

			if state then
				self.dynamicRPCStateMap[state] = (self.dynamicRPCStateMap[state] or 0) - 1

				if self.dynamicRPCStateMap[state] <= 0 then
					self.dynamicRPCStateMap[state] = nil
				end
			end
		end
	end
end

function ClientAbilityComponent:EVENT_OnCharacterStateChange(oldState, newState)
	if Utils.checkIsAuthorityMaster(self) then
		local rpcCharacterState = CharacterStateConst.getRPCState(self, newState) or CharacterStateConst.IDLE

		if rpcCharacterState ~= self.rpcCharacterState then
			self:serverMsgNoGC("RPC_CS_CharacterStateChange", rpcCharacterState)

			self.rpcCharacterState = rpcCharacterState
		end
	end

	self.considerAsBurrowST = nil

	self:handleSpecialCharacterStateEvents(oldState, newState)
	self:handleCharacterStateConditionalEffects(newState)
	self:handleCharacterStateConditionalVolumes(newState)

	if Utils.isPet(self) then
		self.lastStartDashTime = newState == CharacterStateConst.DASH and self:getGameTime() or nil
	end
end

function ClientAbilityComponent:addAbilityImpulse(impulse, pos)
	local impulseLen = Vector3.Magnitude(impulse)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("addAbilityImpulse", inspect(impulse), impulseLen)
	end

	local mass = self:getConfigData().mass or SysConfigData.avatarMass

	if self.authority == Const.AUTHORITY_MASTER then
		self:serverMsgNoGC("RPC_CS_AddAbilityImpulse", impulse, mass, pos)

		if self.space:isMultiPlayerEnv() then
			return
		end

		local verticalImpulse = math.abs(impulse.y / mass)

		for k, v in ipairs(AbilitySettingGlobalConstData.impulseSquashThresholdMap) do
			local threshold = v[1]

			if threshold <= verticalImpulse then
				return
			end
		end

		local hitActionTimelineParam = pg.global.abilityMgr.hitParamsPool:get(true)

		hitActionTimelineParam.combatContextId = self:genCombatContextId()

		local impulseX = impulse.x
		local impulseY = impulse.y
		local impulseZ = impulse.z
		local forceDir = impulse:SetNormalize()
		local attackForceType = AbilityUtils.getImpulseTypeByForce(impulseLen / mass)
		local timelineName = AbilityConst.ATTACK_FORCE_TO_TIMELINE_NAME[attackForceType]
		local timelineId = AbilitySettingGlobalConstData[timelineName]
		local impulseH, impulseV

		if attackForceType >= AbilityConst.ATTACK_FORCE_KNOCK_UP then
			if impulseLen > SysConfigData.controllerMaxCollisionV * mass then
				impulseH = math.sqrt(forceDir.x * forceDir.x + forceDir.z * forceDir.z) * SysConfigData.controllerMaxCollisionV
				impulseV = forceDir.y * SysConfigData.controllerMaxCollisionV
			else
				impulseH = math.sqrt(impulseX * impulseX + impulseZ * impulseZ) / mass
				impulseV = impulseY / mass
			end
		end

		local direction = forceDir

		direction.y = 0

		direction:SetNormalize()
		hitActionTimelineParam:init(nil, direction, attackForceType, self, nil, nil)

		hitActionTimelineParam.impulseH = impulseH
		hitActionTimelineParam.impulseV = impulseV

		if attackForceType > AbilityConst.ATTACK_FORCE_KNOCK_SHAKE then
			EModelUtils.setMotionDirection(self, -direction)
		end

		if not self.actorTimeline:setTimeline(timelineId, 1, hitActionTimelineParam) then
			pg.global.abilityMgr.hitParamsPool:returnObject(hitActionTimelineParam)
		end

		self.subject:notify(AbilityConst.COMBAT_EVENT_ON_ADD_ABILITY_IMPULSE, impulseLen / mass)
	end
end

function ClientAbilityComponent:onThornsCollision(normal, isSpike, impulseId)
	if self.isRobSpaceEgg then
		local master = self.getMasterEntity and self:getMasterEntity()

		if master and master.onThornsCollision then
			return master:onThornsCollision(normal, isSpike, impulseId)
		end

		return
	end

	if self.authority ~= Const.AUTHORITY_MASTER and (not Utils.isPuppet(self) or not self.space or not Utils.isRobEggSceneId(self.space.sceneId)) then
		return false
	end

	if self:isDead() then
		return
	end

	local cd = AbilitySettingGlobalConstData.thornsCollisionCd or 0.1

	if self.lastThornsCollisionTime ~= nil and cd > self:getGameTime() - self.lastThornsCollisionTime then
		return
	end

	if self:THORNS_HIT_ST() then
		return
	end

	if isSpike == nil then
		isSpike = false
	end

	local characterState = self.characterState

	if Utils.isPlayer(self) or Utils.isPet(self) and self:getMasterEntity().controlState == Const.CONTROL_STATE_CONTROL then
		local exploreEnt = Utils.isPet(self) and self:getMasterEntity():getControllingExploreEnt()
		local conflictType

		if isSpike then
			conflictType = ConflictTypes.CT_SPIKE_HIT
		else
			conflictType = CharacterStateConst.isChildOfState(characterState, CharacterStateConst.SWIMMING) and ConflictTypes.CT_THORNS_HIT_IN_WATER or ConflictTypes.CT_THORNS_HIT
		end

		if self:CLIMB_ST() then
			normal = Quaternion.MulVec3(self:getRotation(), Vector3.constBack)
		end

		if not self:checkStatus(conflictType) then
			return
		end

		if exploreEnt and self:getMasterEntity():getControllingExploreEnt() ~= exploreEnt then
			return
		end

		normal.y = 0

		if Vector3.Magnitude(normal) < 0.01 then
			normal.x = math.random()
			normal.z = 1 - normal.x
		end

		normal:SetNormalize()
		self:playThornsTimeline(characterState, normal, isSpike, impulseId)

		self.lastThornsCollisionTime = self:getGameTime()
	elseif Utils.isPuppet(self) and self.space and Utils.isRobEggSceneId(self.space.sceneId) then
		local conflictType

		if isSpike then
			conflictType = ConflictTypes.CT_SPIKE_HIT
		else
			conflictType = CharacterStateConst.isChildOfState(characterState, CharacterStateConst.SWIMMING) and ConflictTypes.CT_THORNS_HIT_IN_WATER or ConflictTypes.CT_THORNS_HIT
		end

		if not self:checkStatus(conflictType) then
			return
		end

		normal.y = 0

		if Vector3.Magnitude(normal) < 0.01 then
			normal.x = math.random()
			normal.z = 1 - normal.x
		end

		normal:SetNormalize()
		self:playThornsTimeline(characterState, normal, isSpike, impulseId)

		self.lastThornsCollisionTime = self:getGameTime()
	end
end

function ClientAbilityComponent:playThornsTimeline(characterState, normal, isSpike, configImpulseId)
	local isInAir = CharacterStateConst.isChildOfState(characterState, CharacterStateConst.AIRING) or CharacterStateConst.isChildOfState(characterState, CharacterStateConst.CLIMBING) or CharacterStateConst.isChildOfState(characterState, CharacterStateConst.FLYING) or CharacterStateConst.isChildOfState(characterState, CharacterStateConst.GLIDING)
	local isInWater = CharacterStateConst.isChildOfState(characterState, CharacterStateConst.SWIMMING)
	local impulseId = isInAir and AbilitySettingGlobalConstData.thornsInAirImpulseId or AbilitySettingGlobalConstData.thornsImpulseId

	if configImpulseId and configImpulseId > 0 then
		impulseId = configImpulseId
	end

	local impulseData = ImpulseData[impulseId]
	local hitActionTimelineParam = pg.global.abilityMgr.hitParamsPool:get(true)

	hitActionTimelineParam.combatContextId = self:genCombatContextId()

	local impulseH = not isInWater and impulseData.impulseType == AbilityConst.ATTACK_FORCE_KNOCK_UP and impulseData.horizontalImpulse or 0
	local impulseV = not isInWater and impulseData.impulseType == AbilityConst.ATTACK_FORCE_KNOCK_UP and impulseData.verticalImpulse or 0

	hitActionTimelineParam:init(impulseId, normal, impulseData.impulseType, self)

	hitActionTimelineParam.impulseH = impulseH
	hitActionTimelineParam.impulseV = impulseV
	hitActionTimelineParam.isFromThorns = true

	local skipLocalTimeline = self.isControllingEgg and self:isControllingEgg()
	local finalHitTimelineId

	if isInWater == false then
		local timelineName = AbilityConst.ATTACK_FORCE_TO_TIMELINE_NAME[impulseData.impulseType]

		finalHitTimelineId = AbilitySettingGlobalConstData[timelineName]

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("onThornsCollision", self.actorId, inspect(normal), isInAir, timelineName, finalHitTimelineId)
		end
	else
		finalHitTimelineId = AbilitySettingGlobalConstData.thornsHitInWaterTimeline

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("onThornsCollision in water", self.actorId, inspect(normal), isInAir, finalHitTimelineId)
		end
	end

	if Utils.isPuppet(self) then
		if self.space and Utils.isRobEggSceneId(self.space.sceneId) and pg.me and pg.me.serverMsgNoGC then
			pg.me:serverMsgNoGC("RPC_CS_OnPuppetThornsCollision", self.actorId, finalHitTimelineId, hitActionTimelineParam, isSpike)
		end
	else
		self:serverMsgNoGC("RPC_CS_OnThornsCollision", finalHitTimelineId, hitActionTimelineParam, isSpike)
	end

	local isTimelineAccepted = false

	if not skipLocalTimeline then
		isTimelineAccepted = self.actorTimeline:setTimeline(finalHitTimelineId, 1, hitActionTimelineParam)

		if isTimelineAccepted and self.updateStateCache then
			self:updateStateCache("THORNS_HIT_ST")
		end
	end

	if not isTimelineAccepted then
		pg.global.abilityMgr.hitParamsPool:returnObject(hitActionTimelineParam)
	end
end

function ClientAbilityComponent:onConductStart(srcActorId)
	if not ToBool(srcActorId) then
		srcActorId = pg.me.actorId
	end

	local srcEnt = pg.getEntityByActorId(srcActorId)

	if not srcEnt then
		return
	end

	if self.authority ~= Const.AUTHORITY_MASTER then
		return false
	end

	if self:CONDUCT_HIT_ST() then
		return
	end

	if Utils.isPlayer(self) or Utils.isPet(self) and self:getMasterEntity().controlState == Const.CONTROL_STATE_CONTROL or Utils.isPuppet(self) then
		local exploreEnt = Utils.isPet(self) and self:getMasterEntity():getControllingExploreEnt()

		if exploreEnt and self:getMasterEntity():getControllingExploreEnt() ~= exploreEnt then
			return
		end

		local conflictType = CharacterStateConst.isChildOfState(self.characterState, CharacterStateConst.SWIMMING) and ConflictTypes.CT_CONDUCT_HIT_IN_WATER or ConflictTypes.CT_CONDUCT_HIT

		if not self:checkStatus(conflictType) then
			return
		end

		Vector3.enableCreateFromCache()

		local normal = self:getPosition() - srcEnt:getPosition()

		Vector3.SetNormalize(normal)

		normal.y = 0

		if Vector3.Magnitude(normal) < 0.01 then
			normal.x = math.random()
			normal.z = 1 - normal.x
		end

		normal:SetNormalize()
		Vector3.disableCreateFromCache(normal)
		self:playConductTimeline(normal)

		self.lastConductTime = self:getGameTime()
	end
end

function ClientAbilityComponent:playConductTimeline(normal)
	local characterState = self.characterState
	local isInAir = CharacterStateConst.isChildOfState(characterState, CharacterStateConst.AIRING) or CharacterStateConst.isChildOfState(characterState, CharacterStateConst.CLIMBING) or CharacterStateConst.isChildOfState(characterState, CharacterStateConst.FLYING) or CharacterStateConst.isChildOfState(characterState, CharacterStateConst.GLIDING)
	local isInWater = CharacterStateConst.isChildOfState(characterState, CharacterStateConst.SWIMMING)
	local impulseId = isInAir and AbilitySettingGlobalConstData.conductInAirImpulseId or AbilitySettingGlobalConstData.conductImpulseId
	local impulseData = ImpulseData[impulseId]
	local hitActionTimelineParam = pg.global.abilityMgr.hitParamsPool:get(true)

	hitActionTimelineParam.combatContextId = self:genCombatContextId()

	local impulseH = not isInWater and impulseData.impulseType == AbilityConst.ATTACK_FORCE_KNOCK_UP and impulseData.horizontalImpulse or 0
	local impulseV = not isInWater and impulseData.impulseType == AbilityConst.ATTACK_FORCE_KNOCK_UP and impulseData.verticalImpulse or 0

	hitActionTimelineParam:init(impulseId, normal, impulseData.impulseType, self)

	hitActionTimelineParam.impulseH = impulseH
	hitActionTimelineParam.impulseV = impulseV

	local finalHitTimelineId

	if isInWater == false then
		local timelineName = AbilityConst.ATTACK_FORCE_TO_TIMELINE_NAME[impulseData.impulseType]

		finalHitTimelineId = AbilitySettingGlobalConstData[timelineName]

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("playConductTimeline", self.actorId, inspect(normal), isInAir, timelineName, finalHitTimelineId)
		end
	else
		finalHitTimelineId = AbilitySettingGlobalConstData.conductHitInWaterTimeline

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("playConductTimeline in water", self.actorId, inspect(normal), isInAir, finalHitTimelineId)
		end
	end

	self:serverMsgNoGC("RPC_CS_OnConductHit", finalHitTimelineId, hitActionTimelineParam)

	local isTimelineAccepted = self.actorTimeline:setTimeline(finalHitTimelineId, 1, hitActionTimelineParam)

	if not isTimelineAccepted then
		pg.global.abilityMgr.hitParamsPool:returnObject(hitActionTimelineParam)
	end
end

function ClientAbilityComponent:getAbilityOverrideFlyHeight()
	local overrideFlyHeight = self:getEntityCacheVal(AbilityConst.ABILITY_FLY_OVERRIDE_FLY_HEIGHT)

	self:setEntityCacheVal(AbilityConst.ABILITY_FLY_OVERRIDE_FLY_HEIGHT, nil)

	return overrideFlyHeight and overrideFlyHeight or -1
end

function ClientAbilityComponent:enterSandUnderground()
	self:enableSandUndergroundEffect(true)

	local burrowActionData = self:getEntityCacheVal(AbilityConst.COMBAT_EVENT_ON_BURROW_STATE_CHANGE)

	if burrowActionData and ToBool(burrowActionData.switchToAbilityId) then
		local endTime = burrowActionData.duration ~= -1 and self:getGameTime() + burrowActionData.duration or nil

		self:switchSkill(burrowActionData.burrowAbilityId, burrowActionData.switchToAbilityId, endTime)
	end

	local enableTurnInstant = burrowActionData and burrowActionData.enableTurnInstant or false

	return enableTurnInstant
end

function ClientAbilityComponent:exitSandUnderground(enableCastSkill)
	self:enableSandUndergroundEffect(false)

	if enableCastSkill then
		local burrowActionData = self:getEntityCacheVal(AbilityConst.COMBAT_EVENT_ON_BURROW_STATE_CHANGE)

		if burrowActionData and ToBool(burrowActionData.exitCastAbilityId) then
			pg.game.controller:innerUseSkill(burrowActionData.exitCastAbilityId, AbilityConst.WEAPON_SKILL_ABILITY, false)
		end
	end
end

function ClientAbilityComponent:enableSandUndergroundEffect(enable)
	if self.eModel then
		self.eModel:SetCloseToGround(Const.COMPONENT_INDEX_MODEL, enable, 0)
	end

	if self.sandEff then
		self:stopEffectById(self.sandEff)

		self.sandEff = nil
	end

	if enable then
		self.sandEff = self:playEffect("Eff_SandPile_Trace")
	end

	self:refreshFootPrintVisible()
end

function ClientAbilityComponent:onExitTakeRoot()
	if self.inSwitchToControlMark then
		return
	end

	local takeRootActionData = self:getEntityCacheVal(AbilityConst.COMBAT_EVENT_ON_TAKE_ROOT_STATE_CHANGE)

	if takeRootActionData and ToBool(takeRootActionData.exitCastAbilityId) and self.isSummon then
		self:clientCastAbilityNoTarget(takeRootActionData.exitCastAbilityId)
	end
end

function ClientAbilityComponent:getEntityCacheTableVal(cacheKey, tableKey)
	local data = self:getEntityCacheVal(cacheKey)

	if data and data[tableKey] then
		return data[tableKey]
	end

	return nil
end

function ClientAbilityComponent:onSpecialRideClimbOnFinished()
	pg.game.camera.playerCameraMode:enableRideDragonBossCameraMode(true)
end

function ClientAbilityComponent:exitSpecialRideMode()
	if self.authority == Const.AUTHORITY_MASTER then
		self:cancelAbility()

		local switchSkillInfo = AbilityConst.SPECIAL_RIDE_SWITCH_SKILL_INFO[self.templateId]

		if switchSkillInfo then
			self:switchSkill(switchSkillInfo.from, nil)
		end

		self:enableSpecialAttackMode(false)
		pg.game.camera.playerCameraMode:enableRideDragonBossCameraMode(false)
		self:setEntityCacheVal(AbilityConst.COMBAT_EVENT_ON_ENTER_SPECIAL_RIDE_MODE, nil)

		local controllerComponent = self:getEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER)

		if NotNil(controllerComponent) then
			controllerComponent.abilityCharacterStateInfo.abilityStateMachine = AbilityConst.ABILITY_STATE_NONE
		end
	end
end

function ClientAbilityComponent:enableForbidAllUIEvent(enable)
	if enable then
		local whiteList = {}

		whiteList[UIConst.UI_ID_CHAIN_ATTACK] = true

		pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.Skill, whiteList)
	else
		pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.Skill)
	end

	pg.game.input:setBlockNoneUIEvent(ClientConst.BlockNoneUIEventKey.CombatControl, enable)
end

function ClientAbilityComponent:doAbilityDeform(ability)
	if ability:isStolenAbility() and ability.actorId == self.actorId then
		local deformInfo
		local stolenAbilityInfo = self.stolenAbilityRef[ability.srcAbilityIdBySteal]

		if stolenAbilityInfo == nil then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				self.logger:error("doAbilityDeform, stolenAbilityInfo not found", self.actorId, ability.srcAbilityIdBySteal, ability.abilityId)
			end

			return false
		end

		if Bitset.band(Const.ACTOR_TYPE_PUPPET, stolenAbilityInfo.actorType) ~= 0 then
			deformInfo = PuppetData[stolenAbilityInfo.templateId]
		elseif Bitset.band(Const.ACTOR_TYPE_PLAYER, stolenAbilityInfo.actorType) ~= 0 then
			deformInfo = AvatarData[stolenAbilityInfo.templateId]
		elseif Bitset.band(Const.ACTOR_TYPE_PET, stolenAbilityInfo.actorType) ~= 0 then
			deformInfo = PetData[stolenAbilityInfo.templateId]
		end

		if deformInfo then
			self:deformTo(deformInfo)
		end
	end
end

function ClientAbilityComponent:recordSweepData(abilityId, nodeId, position, rotation)
	if self.sweepRecordMap[abilityId] == nil then
		self.sweepRecordMap[abilityId] = {}
	end

	self.sweepRecordMap[abilityId][nodeId] = SweepData(position, rotation, self:getGameTime())
end

function ClientAbilityComponent:getSweepData(abilityId, nodeId)
	return self.sweepRecordMap[abilityId] and self.sweepRecordMap[abilityId][nodeId]
end

function ClientAbilityComponent:clearSweepData(abilityId)
	if self.sweepRecordMap[abilityId] then
		self.sweepRecordMap[abilityId] = nil
	end
end

function ClientAbilityComponent:RPC_SC_NotifyStopCharge(abilityId, endTime)
	self:stopChargeByAbilityId(abilityId, endTime)
end

function ClientAbilityComponent:RPC_SC_ForceDisplacement(targetPos, duration, speed, isInDir, distance, targetActorId, extraParams)
	self:enterForceDisplacement(targetPos, duration, speed, isInDir, distance, targetActorId, extraParams)
end

function ClientAbilityComponent:RPC_SC_ForceDisplacementSelf(sourcePos, targetPos, duration, speed, isInDir, distance)
	sourcePos = Vector3.Clone(sourcePos)
	targetPos = Vector3.Clone(targetPos)

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_ForceDisplacementSelf", tostring(sourcePos), tostring(targetPos), duration, speed, isInDir, distance)
	end

	self:registerSelfSkillForceDisplacement(sourcePos, targetPos, duration, speed, isInDir, distance)
end

function ClientAbilityComponent:RPC_SC_StopForceDisplacement()
	if not rawget(self, "forceDisplacementData") then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_StopForceDisplacement")
	end

	self:stopForceDisplacement()
end

function ClientAbilityComponent:RPC_SC_SkillScrollHitTarget(dynamicInfo, combatHitResult, triggerActions)
	local combatContext = CombatContext.convert(self, dynamicInfo)

	if not ToBool(triggerActions) then
		return false
	end

	local rawInfo = combatContext.runtimeTargetInfo
	local runtimeTargetInfo

	if ToBool(combatHitResult) then
		combatHitResult.hitPos = Vector3.Convert(combatHitResult.hitPos)
		combatHitResult.hitDir = Vector3.Convert(combatHitResult.hitDir)
		runtimeTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:get(true)
		combatContext.runtimeTargetInfo = runtimeTargetInfo

		combatContext.runtimeTargetInfo:initTarget(combatHitResult.hitActorId, combatHitResult.hitPos, 1, combatHitResult.hitActorPartIdx)
	end

	pg.global.abilityMgr.combatAction:doActionIds(triggerActions, combatContext)

	combatContext.runtimeTargetInfo = rawInfo

	pg.global.abilityMgr.runtimeTargetInfoPool:returnObject(runtimeTargetInfo)
end

function ClientAbilityComponent:RPC_SC_SetIsMonsterAbilityMode(value)
	self.isMonsterAbilityMode = value
end

function ClientAbilityComponent:RPC_SC_NotifyKeyFrameBackswing(abilityId)
	local curCastingAbilityId = self:getCastingAbilityId()

	if curCastingAbilityId == abilityId and abilityId ~= 0 and AbilityUtils.isNormalSkill(abilityId) and not self:getActionMask(AbilityConst.ACTION_MASK_IN_BACKSWING) then
		self:setActionMask(AbilityConst.ACTION_MASK_KEY_FRAME_BACKSWING, true, abilityId)
	end
end

function ClientAbilityComponent:onKnockStateChange(old, new)
	if self.authority == Const.AUTHORITY_MASTER then
		return
	end

	if self.skillStateMgr.currentState == AbilityConst.SKILL_STATE_KNOCK_UP and new == AbilityConst.KNOCK_STATE_NONE then
		self.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)
	end

	if Utils.isPet(self, true) then
		self:updateKnockUpInvincibleState(new)
	end

	if self.refreshKnockGroup then
		self:refreshKnockGroup(new)
	end
end

function ClientAbilityComponent:EVENT_OnEntityCacheValChanged(key, val, oldVal)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("EVENT_OnEntityCacheValChanged", key, val)
	end

	if key == Const.TravelState then
		if val == Const.TimeTravel.Now then
			facade:sendLuaEvent(SandboxConst.COMMON_EVENT.TIME_TRAVEL_TO_NOW, val)
			appFacade.pipelineManager:TravelToNow()
		elseif val == Const.TimeTravel.Past then
			facade:sendLuaEvent(SandboxConst.COMMON_EVENT.TIME_TRAVEL_TO_LAST, val)
			appFacade.pipelineManager:TravelToLast()
		end
	end

	self.subject:notify(AbilityConst.COMBAT_EVENT_ON_SERVER_CACHE_VAL_CHANGE, key)
end

function ClientAbilityComponent:doUpdateBuffStates(buffStates)
	if not buffStates then
		return
	end

	for _, buffState in ipairs(buffStates) do
		local buff = self.actorBuff:findBuff(buffState.instanceId)

		if not buff then
			CombatLogger.error("doUpdateBuffStates, buff not found, instanceId = ", buffState.instanceId)
		else
			local delay = buffState.nextTickTime - self:getGameTime()

			delay = math.max(0, delay)

			buff:startThink(delay, buffState.tickInterval)

			buff.thinkCount = buffState.thinkCount
		end
	end
end

function ClientAbilityComponent:EVENT_LoseControlled()
	self:cancelAbility()

	if self.actorTimeline then
		self.actorTimeline:stopAll()
	end

	self.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)
	self:stopForceDisplacement()
	self:cancelAbilityIndicator()
end

function ClientAbilityComponent:addBuffEvent(buffTemplateId)
	local buffTemplate = pg.global.abilityMgr:getBuffTemplate(buffTemplateId)

	if buffTemplate then
		self:addDynamicRPCState(buffTemplate.parentDynamicRPCStates, buffTemplate.dynamicRPCStates)
	end
end

function ClientAbilityComponent:removeBuffEvent(buffTemplateId)
	local buffTemplate = pg.global.abilityMgr:getBuffTemplate(buffTemplateId)

	if buffTemplate then
		self:removeDynamicRPCState(buffTemplate.parentDynamicRPCStates, buffTemplate.dynamicRPCStates)
	end
end

function ClientAbilityComponent:RPC_SC_UpdateBuffInheritStates(buffStates)
	self:doUpdateBuffStates(buffStates)
end

function ClientAbilityComponent:RPC_SC_BuffStartThink(instanceId, tickInterval, nextTickTime)
	if not self.abilityCompInitTriggerDone then
		self:addAbilityInitTriggerCallbacks(function()
			self:_Rpc_RPC_SC_BuffStartThink(instanceId, tickInterval, nextTickTime)
		end)

		return
	end

	local buff = self.actorBuff:findBuff(instanceId)

	if not buff then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("RPC_SC_BuffStartThink buff not found", self.actorId, instanceId)
		end

		return
	end

	local delay = nextTickTime - self:getGameTime()

	buff:startThink(delay, tickInterval)
end

function ClientAbilityComponent:RPC_SC_StopThink(instanceId)
	local buff = self.actorBuff:findBuff(instanceId)

	if not buff then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("RPC_SC_BuffStartThink buff not found", instanceId)
		end

		return
	end

	buff:stopThink()
end

function ClientAbilityComponent:RPC_SC_AttackHpZero(targetActorId)
	CombatActionTool.notifyCasterEvent(self, AbilityConst.COMBAT_EVENT_ON_ATTACK_HP_ZERO, targetActorId)
end

function ClientAbilityComponent:RPC_SC_AddRandomTimer(duration, actionData, dynamicInfo)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_AddRandomTimer", duration, actionData, inspect(dynamicInfo))
	end

	local combatContext = CombatContext.convert(self, dynamicInfo)

	if not combatContext then
		return
	end

	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	abilityObject:addTimer(actionData.key, duration, function()
		self.combatAction:doActions(actionData, combatContext)
	end)
end

function ClientAbilityComponent:RPC_SC_SetAbilityCacheValKey2(actorId, abilityId, key, key2, cacheData)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_SetAbilityCacheValKey2", actorId, abilityId, key, key2, inspect(cacheData))
	end

	local entity = pg.getEntityByActorId(actorId)

	if entity == nil then
		return
	end

	local ability = entity.abilityMap[abilityId]

	if not ability then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("ability not found", actorId, abilityId)
		end

		return
	end

	local abilityObject = ability:getAbilityObject()

	if not abilityObject.cacheValMap[key] then
		abilityObject.cacheValMap[key] = {}
	end

	abilityObject.cacheValMap[key][key2] = cacheData.cacheVal
end

function ClientAbilityComponent:RPC_SC_SetIsPetShareDmg(value)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_SetIsPetShareDmg", value)
	end

	self.isPetShareDmg = value
end

function ClientAbilityComponent:RPC_SC_SetIsPetLinkHeal(value)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_SetIsPetLinkHeal", value)
	end

	self.isPetLinkHeal = value
end

function ClientAbilityComponent:onIsVisibleByAbilityChange(old, new)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("onIsVisibleByStateChange", old, new)
	end

	self:setVisible(ClientConst.MODEL_VISIBLE_KEY.VISIBLE_BY_ABILITY, new, true)
end

function ClientAbilityComponent:onEnableLockTargetChange(old, new)
	if new == false then
		self:unlockTarget()

		if self.isMainPlayer then
			facade:SendMessageCommand(MessageName.LOCKED_TARGET_CHANGE)
		end

		pg.game.controller.lockHelper:cancelLockTarget()
	end
end

function ClientAbilityComponent:onBreakBuffFreezeTimeChange(old, new)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("onBreakBuffFreezeTimeChange", old, new)
	end

	if new ~= 0 and (Utils.isPet(self) or Utils.isPuppet(self)) then
		local deltaBp = 0

		facade:SendMessageCommand(MessageName.BREAK_POINT_CHANGE, {
			entity = self,
			deltaBp = deltaBp
		})
		self.eventEmitter:emit(EventConst.TOPLOGO_BREAK_POINT, deltaBp)
	end
end

function ClientAbilityComponent:onBreakRecoverFreezeTimeChange(old, new)
	if new ~= 0 and (Utils.isPet(self) or Utils.isPuppet(self)) then
		local deltaBp = 0

		facade:SendMessageCommand(MessageName.BREAK_POINT_CHANGE, {
			entity = self,
			deltaBp = deltaBp
		})
		self.eventEmitter:emit(EventConst.TOPLOGO_BREAK_POINT, deltaBp)
	end
end

function ClientAbilityComponent:onCurBpChange(old, new)
	self:onBpChange(old, new)
end

function ClientAbilityComponent:onMaxBpChange(old, new)
	self:onBpChange()
end

function ClientAbilityComponent:onIsCamouflageChange(old, new)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("onIsCamouflageChange", old, new)
	end

	if self.updateStateCache then
		self:updateStateCache("CAMOUFLAGE_ST")
	end

	if not new then
		self:refreshCamouFlageMats(false, 0)

		if self.eModel and Utils.isEnemy(self, pg.pawn) then
			self.eModel:ShowEffect(Const.COMPONENT_INDEX_EFFECT)
			self:refreshFootPrintVisible()
		end
	else
		if self.eModel and Utils.isEnemy(self, pg.pawn) then
			self.eModel:HideEffect(Const.COMPONENT_INDEX_EFFECT)
			self:refreshFootPrintVisible()
		end

		self:refreshCamouFlageMats(true, 0)
	end

	self.eventEmitter:emit(EventConst.ON_CAMOUFLAGE_CHANGE, new)
end

function ClientAbilityComponent:setGhostEyeDetected(value)
	self.ghostEyeDetected = value

	self:refreshCamouFlageMats(self.isCamouflage, 0)
end

function ClientAbilityComponent:refreshCamouFlageMats(enable, lerpTime, leaveTime)
	if not self.eModel or IsNil(self.eModel.modelView) then
		return
	end

	if enable then
		local isEnemy = Utils.isEnemy(self, pg.pawn)
		local from = isEnemy and 0.5 or 0.7
		local to = isEnemy and 0.15 or 0.3
		local mode = isEnemy and (self.ghostEyeDetected and AbilityConst.CAMOU_FLAGE_MODE.ENEMY_DETECTED or AbilityConst.CAMOU_FLAGE_MODE.ENEMY) or AbilityConst.CAMOU_FLAGE_MODE.FRIEND
		local materialEffectName

		materialEffectName = not isEnemy and (self.ghostEyeDetected and "EnemyInvisibility" or "FriendInvisibility") or self.ghostEyeDetected and "EnemyInvisibility" or "NormalInvisibility"

		if self.camouFlagMatEffName and self.camouFlagMatEffName ~= materialEffectName then
			ClientEffectUtils.StopMaterialEffect(self, self.camouFlagMatEffName)
		end

		self.camouFlagMatEffName = materialEffectName

		ClientEffectUtils.ApplyMaterialEffect(self, materialEffectName, true, false)

		if self.authority == Const.AUTHORITY_MASTER and mode == AbilityConst.CAMOU_FLAGE_MODE.ENEMY_DETECTED then
			self:serverMsgNoGC("RPC_CS_CamouFlagEnemyDetected", true)
		end

		if self.authority == Const.AUTHORITY_MASTER and self.ghostEyeDetected and Utils.isPuppet(self) then
			pg.me:tryClientTrigger(TriggerConst.TRIGGER_TARGET_CAMOU_DETECTED, self.basePetPrototypeId, 1, Utils.getRelation(pg.me, self))
		end

		if not self.isShowCamouthFlage then
			self.camouFlagLeaveTime = leaveTime or 0
			self.isShowCamouthFlage = true
		end
	else
		if self.isShowCamouthFlage then
			self.isShowCamouthFlage = false

			if self.camouFlagMatEffName then
				ClientEffectUtils.StopMaterialEffect(self, self.camouFlagMatEffName)

				self.camouFlagMatEffName = nil
			end

			if ToBool(self.camouFlagLeaveTime) then
				ClientEffectUtils.PlayPreset(self, "DitheringFadeReverse", self.camouFlagLeaveTime, true)
			end
		end

		if self.authority == Const.AUTHORITY_MASTER then
			self:serverMsgNoGC("RPC_CS_CamouFlagEnemyDetected", false)
		end
	end
end

function ClientAbilityComponent:enterAimSense(actionData, enterActorIdMap)
	if self ~= pg.pawn then
		return
	end

	self.aimParam = actionData

	pg.game.camera.playerCameraMode:setInAim(true, actionData)
	self.eModel:SetAimOffset(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, true, nil, nil, actionData.maxPitch, nil)

	self.eModel.AlwaysLookScreenCenter = true

	self:enableLookAtCameraCenter(true)

	if not actionData.isFullScreen then
		facade:sendMsgToUI(MessageName.ENTER_AIM_SENSE)
	end

	self.aimSenseData = {
		actionData = actionData,
		enterActorIdMap = enterActorIdMap,
		inAimMap = {}
	}

	if self.aimSenseTimer then
		self:removeTimer(self.aimSenseTimer)
	end

	self.aimSenseTimer = self:addRepeatTimer(0.1, WeakRefCallbackHandle.new(function(self)
		self:tickEnterAimSense()
	end, self))
end

function ClientAbilityComponent:leaveAimSense(actionData)
	if self.aimSenseTimer then
		self:removeTimer(self.aimSenseTimer)

		self.aimSenseTimer = nil
	end

	if self.aimSenseData then
		for actorId, _ in pairs(self.aimSenseData.inAimMap) do
			local ent = pg.getEntityByActorId(actorId)

			if ent then
				ent:stopEffect(actionData.aimEffect)
			end
		end
	end

	self.aimSenseData = nil

	if self.aimParam == nil then
		return
	end

	self.aimParam = nil

	pg.game.camera.playerCameraMode:setInAim(false, actionData)
	self:enableLookAtCameraCenter(false)
	facade:sendMsgToUI(MessageName.LEAVE_AIM_SENSE)
end

function ClientAbilityComponent:tickEnterAimSense()
	if not self.aimSenseData then
		return
	end

	Vector3.enableCreateFromCache()

	local actionData = self.aimSenseData.actionData
	local enterActorIdMap = self.aimSenseData.enterActorIdMap
	local inAimMap = self.aimSenseData.inAimMap
	local actorIdList = ListPool.getList(3)
	local distance = actionData.distance
	local aimEffect = actionData.aimEffect
	local aimDuration = actionData.aimDuration
	local count = self:entitiesInRangeWithTable(actionData.distance + 5, Const.SEARCH_USR_TYPE_ACTOR, 30, actorIdList)
	local selfPos = self:getPosition()
	local now = self:getGameTime()
	local curEnterMap = {}

	for i = 1, count do
		local actorId = actorIdList[i]

		if not enterActorIdMap[actorId] then
			local ent = pg.getEntityByActorId(actorId)

			if ent and Utils.isEnemy(ent, self) and Utils.checkValidLock(ent) then
				local entPos = ent:getPosition()
				local isInAim = false

				if Vector3.HoriSqrDistance(selfPos, entPos) < distance * distance then
					local mountData = ClientEffectUtils.getBestFitCommonMount(ent, "CM_Common_Buff")
					local centerPos

					if mountData then
						centerPos = ent:getCommonMountPosition(mountData)
					else
						centerPos = Vector3(entPos.x, ent.eModel.height + entPos.y, entPos.z)
					end

					if UIUtils.CheckInViewPort(centerPos) and (actionData.isFullScreen or pg.me.checkAimSenseFun and pg.me.checkAimSenseFun(centerPos)) then
						isInAim = true
						curEnterMap[actorId] = true

						if not inAimMap[actorId] then
							ent:playEffect(aimEffect)

							inAimMap[actorId] = now
						end
					end
				end
			end
		end
	end

	Vector3.disableCreateFromCache()

	for actorId, enterTime in pairs(inAimMap) do
		if not curEnterMap[actorId] then
			local ent = pg.getEntityByActorId(actorId)

			if ent then
				ent:stopEffect(aimEffect)
			end

			inAimMap[actorId] = nil
		elseif aimDuration < now - enterTime then
			self:serverMsgNoGC("RPC_CS_OnEnterAimSense", actorId)
			self.subject:notify(AbilityConst.COMBAT_EVENT_ON_ENTER_AIM_SENSE, actorId)

			local ent = pg.getEntityByActorId(actorId)

			if ent then
				ent:stopEffect(aimEffect)
			end

			inAimMap[actorId] = nil
		end
	end

	ListPool.returnList(actorIdList, 3)
end

function ClientAbilityComponent:showAbilityIndicatorSelPos(abilityId, selectPosTarget)
	self:hideAbilityIndicatorSelPos(false, false)
	self:hideAbilityIndicatorAim(false, false)
	self:hideAbilityIndicatorAimWalk(false, false)

	self.abilityIndicatorSelPosData = {
		abilityId = abilityId,
		selectPosTarget = selectPosTarget,
		lastValidPos = Vector3.Clone(self:getPosition())
	}

	local ability = self.abilityMap[abilityId]

	if not ability then
		CombatLogger.error("ability not found", abilityId)

		return
	end

	local shapeKind = AbilityConst.LX_GEOMETRY_TYPE_PARSER[selectPosTarget.shapeKind]
	local scale = self.curModelScale or 1
	local shapeArgs = selectPosTarget.shapeArgs
	local combatContext = ability:getAbilityObject().combatContext

	if shapeArgs.name then
		shapeArgs = self.combatAction:doAction(shapeArgs, combatContext)
	end

	local stayTime = 999999
	local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(abilityId)
	local searchRangeRadius = abilityTemplate.searchTargetRangeRadius
	local searchRangeUp = abilityTemplate.searchTargetRangeUp
	local searchTargetRangeDown = abilityTemplate.searchTargetRangeDown
	local sectorBackDistance = 0
	local color = Color(AbilitySettingGlobalConstData.abilityIndicatorColor[1] or 0, AbilitySettingGlobalConstData.abilityIndicatorColor[2] or 1, AbilitySettingGlobalConstData.abilityIndicatorColor[3] or 0)

	pg.game.input:setLockCursor(ClientConst.LockCursorKey.AbilityIndicator, false)

	local extInfo = {
		position = self:getPosition(),
		rotation = Quaternion.ToEulerAngles(self:getRotation()),
		mountType = EffectConst.MountType.World,
		followType = EffectConst.FollowType.Global,
		stayTime,
		loadCallback = function(effectItem)
			if not effectItem then
				return
			end

			if shapeKind == AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D then
				local radius, _, _ = unpack(shapeArgs)

				effectItem:IndicatorDisp(0, 0, stayTime, radius * scale, 0, 180, false, color)
			elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_SECTOR3D then
				local radius, theta, heightUp, heightDown = unpack(shapeArgs)

				effectItem:IndicatorDisp(0, 0, stayTime, radius * scale, 0, theta, false, color)
			elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_TRAPEZOID3D then
				local startRadius, endRadius, distance, heightUp, heightDown = unpack(shapeArgs)

				if math.abs(startRadius - endRadius) < 0.01 then
					effectItem:IndicatorDisp(0, 0, stayTime, distance * scale, startRadius * scale * 2, -181, false, color)
				else
					if endRadius < startRadius then
						local swap = startRadius

						startRadius = endRadius
						endRadius = swap
					end

					local innerRadius = startRadius * distance / (endRadius - startRadius)
					local outerRadius = innerRadius + distance

					sectorBackDistance = innerRadius

					local angle = math.atan((endRadius - startRadius) / distance) * math.rad2Deg

					effectItem:IndicatorDisp(0, 0, stayTime, outerRadius, innerRadius, angle, true, color)
				end
			elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_ANNULARSECTOR3D then
				local innerRadius, outerRadius, theta, heightUp, heightDown = unpack(shapeArgs)

				effectItem:IndicatorDisp(0, 0, stayTime, outerRadius * scale, innerRadius * scale, theta, false, color)
			end
		end,
		customUpdateCallback = function(effectItem)
			local _, mouseWorldPos = pg.global.physicsMgr:GetMouseWorldPosition(StableGroundLayers)
			local effectPos, effectRotation

			if selectPosTarget.center == AbilityConst.COMBAT_TARGET_TYPE_POS_OR_TARGET then
				effectPos = mouseWorldPos
				effectRotation = self:getRotation()
			else
				effectPos = self:getPosition()

				local dir = mouseWorldPos - self:getPosition()

				dir.y = 0

				Vector3.SetNormalize(dir)

				if Vector3.SqrMagnitude(dir) == 0 then
					effectRotation = self:getRotation()
				else
					effectRotation = Quaternion.LookRotation(dir, VEC3_CONST_UP)
				end

				local offsetXYZ = selectPosTarget.offsetXYZ.name == nil and Vector3.New(unpack(selectPosTarget.offsetXYZ)) or pg.global.abilityMgr.combatAction:doAction(selectPosTarget.offsetXYZ, combatContext)

				effectPos = CombatActionTool.translatePoint(effectPos, effectRotation, offsetXYZ * scale)
			end

			local selfPos = self:getPosition()

			if Vector3.HoriSqrDistance(selfPos, effectPos) > searchRangeRadius * searchRangeRadius then
				local horiOffset = Vector3(mouseWorldPos.x - selfPos.x, 0, mouseWorldPos.z - selfPos.z)
				local horiDir = Vector3.Normalize(horiOffset)

				effectPos = selfPos + horiDir * searchRangeRadius
				effectPos = PhysicsUtils.getGroundPos(effectPos, nil, self.eModel.rigidbody)
			end

			effectPos.y = math.clamp(effectPos.y, selfPos.y - searchTargetRangeDown, selfPos.y + searchRangeUp)

			if shapeKind == AbilityConst.LX_GEOMETRY_TYPE_TRAPEZOID3D then
				if selectPosTarget.center == AbilityConst.COMBAT_TARGET_TYPE_POS_OR_TARGET then
					effectPos = effectPos + effectRotation:MulVec3(Vector3.constBack) * (shapeArgs[3] * 0.5)
				end

				effectPos = effectPos + effectRotation:MulVec3(Vector3.constBack) * sectorBackDistance
			end

			self.abilityIndicatorSelPosData.lastValidPos:Copy(effectPos)

			self.abilityIndicatorSelPosData.mouseWorldPos = mouseWorldPos

			effectItem:SetEffectPosRot(self.abilityIndicatorSelPosData.lastValidPos, effectRotation)
		end
	}

	if self.updateStateCache then
		self:updateStateCache("ABILITY_INDICATOR_SEL_POS_ST")
	end

	self.abilityIndicatorSelPosData.effectId = self:playEffect("Eff_SkillIndicator_Precast", extInfo, true)
end

function ClientAbilityComponent:hideAbilityIndicatorSelPos(needCastAbility, clearData)
	if self.abilityIndicatorSelPosData and self.abilityIndicatorSelPosData.valid ~= false then
		if self.abilityIndicatorSelPosData.effectId then
			self:stopEffectById(self.abilityIndicatorSelPosData.effectId)
		end

		if needCastAbility then
			local dir = self.abilityIndicatorSelPosData.mouseWorldPos - self:getPosition()

			dir.y = 0

			Vector3.SetNormalize(dir)

			if Vector3.SqrMagnitude(dir) ~= 0 then
				self:forceSetRot(Quaternion.LookRotation(dir, Vector3.constUp))
			end

			self:disableMotion(ClientConst.DISABLE_MOTION_KEY.ABILITY_INDICATOR, true, true)
			self:addTimer(0.1, function()
				self:disableMotion(ClientConst.DISABLE_MOTION_KEY.ABILITY_INDICATOR, false)
			end)
			self:clientCastAbilityOnPosRot(self.abilityIndicatorSelPosData.abilityId, self.abilityIndicatorSelPosData.lastValidPos, self:getRotation())
		end

		pg.game.input:setLockCursor(ClientConst.LockCursorKey.AbilityIndicator, true)

		if clearData ~= false then
			self.abilityIndicatorSelPosData = nil

			if self.updateStateCache then
				self:updateStateCache("ABILITY_INDICATOR_SEL_POS_ST")
			end
		else
			self.abilityIndicatorSelPosData.valid = false

			if self.updateStateCache then
				self:updateStateCache("ABILITY_INDICATOR_SEL_POS_ST")
			end
		end
	end
end

function ClientAbilityComponent:showAbilityIndicatorAim(abilityId, aimData)
	self:hideAbilityIndicatorSelPos(false, false)
	self:hideAbilityIndicatorAim(false, false)
	self:hideAbilityIndicatorAimWalk(false, false)

	self.abilityIndicatorAimData = {
		abilityId = abilityId,
		aimData = aimData
	}

	if self.updateStateCache then
		self:updateStateCache("ABILITY_INDICATOR_AIM_ST")
	end

	local ability = self.abilityMap[abilityId]

	if not ability then
		CombatLogger.error("ability not found", abilityId)

		return
	end

	self.aimParam = aimData

	pg.global.ui.hudV2:setIsInAim(true, abilityId)
	pg.game.camera.playerCameraMode:setInAim(true, aimData)
	self.eModel:SetAimOffset(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, true, aimData.aimOffsetAnim, aimData.aimOffsetParam, aimData.aimOffsetMaxPitch, aimData.aimAnim)

	self.eModel.AlwaysLookScreenCenter = true

	if ToBool(pg.game.controller.lockHelper.forceLockActorId) and pg.game.controller.lockHelper.isUseLockOnExtendCamera then
		local targetEnt = pg.getEntityByActorId(pg.game.controller.lockHelper.forceLockActorId)

		if targetEnt then
			pg.game.camera.playerCameraMode.aimCamera.cameraMode:SetControlDir(targetEnt.eModel)
		end
	end

	self:enableLookAtCameraCenter(true)
	facade:sendMsgToUI(MessageName.ENTER_SKILL_AIM)
end

function ClientAbilityComponent:hideAbilityIndicatorAim(needCastAbility, clearData)
	if self.abilityIndicatorAimData and self.abilityIndicatorAimData.valid ~= false then
		pg.global.ui.hudV2:setIsInAim(false, self.abilityIndicatorAimData.abilityId)

		local aimData = self.abilityIndicatorAimData.aimData

		pg.game.camera.playerCameraMode:setInAim(false)
		self.eModel:SetAimOffset(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, false, aimData.aimOffsetAnim, aimData.aimOffsetParam, aimData.aimOffsetMaxPitch, aimData.aimAnim)

		self.eModel.AlwaysLookScreenCenter = false

		self:enableLookAtCameraCenter(false)
		facade:sendMsgToUI(MessageName.LEAVE_SKILL_AIM)

		if needCastAbility then
			self:clientCastAbilityNoTarget(self.abilityIndicatorAimData.abilityId)
		end

		if clearData ~= false then
			self.abilityIndicatorAimData = nil

			if self.updateStateCache then
				self:updateStateCache("ABILITY_INDICATOR_AIM_ST")
			end
		else
			self.abilityIndicatorAimData.valid = false

			if self.updateStateCache then
				self:updateStateCache("ABILITY_INDICATOR_AIM_ST")
			end
		end
	end
end

function ClientAbilityComponent:showAbilityIndicatorAimWalk(abilityId, aimWalkData)
	self:hideAbilityIndicatorSelPos(false, false)
	self:hideAbilityIndicatorAim(false, false)
	self:hideAbilityIndicatorAimWalk(false, false)

	self.abilityIndicatorAimWalkData = {
		abilityId = abilityId
	}

	if self.updateStateCache then
		self:updateStateCache("ABILITY_INDICATOR_AIM_WALK_ST")
	end

	local ability = self.abilityMap[abilityId]

	if not ability then
		CombatLogger.error("ability not found", abilityId)

		return
	end

	local shapeKind = AbilityConst.LX_GEOMETRY_TYPE_PARSER[aimWalkData.shapeKind]
	local scale = self.curModelScale or 1
	local shapeArgs = aimWalkData.shapeArgs
	local stayTime = 999999
	local combatContext = ability:getAbilityObject().combatContext

	if shapeArgs.name then
		shapeArgs = self.combatAction:doAction(shapeArgs, ability:getAbilityObject().combatContext)
	end

	local center = Vector3.Clone(self:getPosition())

	CombatActionTool.parsePosition(combatContext, aimWalkData.center, center)
	pg.global.ui.hudV2:setIsInAim(true, abilityId)

	self.eModel.AlwaysLookScreenCenter = true

	local extInfo = {
		position = center,
		rotation = Quaternion.ToEulerAngles(self:getRotation()),
		mountType = EffectConst.MountType.World,
		followType = EffectConst.FollowType.Global,
		stayTime,
		loadCallback = function(effectItem)
			if not effectItem then
				return
			end

			if shapeKind == AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D then
				local radius, _, _ = unpack(shapeArgs)

				effectItem:IndicatorDisp(0, 0, stayTime, radius * scale, 0, 180)
			elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_SECTOR3D then
				local radius, theta, heightUp, heightDown = unpack(shapeArgs)

				effectItem:IndicatorDisp(0, 0, stayTime, radius * scale, 0, theta)
			elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_TRAPEZOID3D then
				local startRadius, endRadius, distance, heightUp, heightDown = unpack(shapeArgs)

				effectItem:IndicatorDisp(0, 0, stayTime, distance * scale, startRadius * scale * 2, -181)
			elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_ANNULARSECTOR3D then
				local innerRadius, outerRadius, theta, heightUp, heightDown = unpack(shapeArgs)

				effectItem:IndicatorDisp(0, 0, stayTime, outerRadius * scale, innerRadius * scale, theta)
			end
		end,
		customUpdateCallback = function(effectItem)
			CombatActionTool.parsePosition(combatContext, aimWalkData.center, center)
			effectItem:SetEffectPosRot(center, self:getRotation())
		end
	}

	self.abilityIndicatorAimWalkData.effectId = self:playEffect("Eff_SkillIndicator_Precast", extInfo, true)
end

function ClientAbilityComponent:hideAbilityIndicatorAimWalk(needCastAbility, clearData)
	if self.abilityIndicatorAimWalkData and self.abilityIndicatorAimWalkData.valid ~= false then
		if self.abilityIndicatorAimWalkData.effectId then
			self:stopEffectById(self.abilityIndicatorAimWalkData.effectId)
		end

		if needCastAbility then
			self:clientCastAbilityNoTarget(self.abilityIndicatorAimWalkData.abilityId)
		end

		pg.global.ui.hudV2:setIsInAim(false)

		if clearData ~= false then
			self.abilityIndicatorAimWalkData = nil

			if self.updateStateCache then
				self:updateStateCache("ABILITY_INDICATOR_AIM_WALK_ST")
			end
		else
			self.abilityIndicatorAimWalkData.valid = false

			if self.updateStateCache then
				self:updateStateCache("ABILITY_INDICATOR_AIM_WALK_ST")
			end
		end

		self.eModel.AlwaysLookScreenCenter = false
	end
end

function ClientAbilityComponent:switchSkill(from, to, endTime)
	if self == pg.pawn and self.switchSkillData[from] and self.switchSkillData[from] ~= to then
		ClientAbilityUtils.checkHideAbilityIndicator(self.switchSkillData[from])
	end

	AbilityComponent.switchSkill(self, from, to, endTime)
end

function ClientAbilityComponent:RPC_SC_ShowEpNumber(value)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_ShowEpNumber", self.actorId, value)
	end

	local data = {
		targetActorId = self.actorId,
		targetId = self.id,
		value = value
	}

	facade:SendMessageCommand(MessageName.SHOW_ENERGY_NUMBER, data)
end

function ClientAbilityComponent:RPC_SC_ShowPetHealEffect(petId)
	facade:SendMessageCommand(MessageName.PET_SHOW_HEAL_EFFECT, petId)
end

function ClientAbilityComponent:RPC_SC_OnPawnMovedDistanceReachThreshold()
	self.subject:notify(AbilityConst.COMBAT_EVENT_ON_PAWN_MOVED_DISTANCE_REACH_THRESHOLD)
end

function ClientAbilityComponent:RPC_SC_SyncEnableAbilityCheck(value)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_SyncEnableAbilityCheck", self.actorId, value)
	end

	self.enableAbilityCheck = value
end

function ClientAbilityComponent:RPC_SC_ContinueTimelineByCombo(oldTimelineId, newTimelineId)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_ContinueTimelineByCombo", self.actorId, oldTimelineId, newTimelineId)
	end

	if self.nextComboTimeline and self.nextComboTimeline[2] == oldTimelineId then
		local timeline = self.nextComboTimeline[1]

		timeline:continueTimeline(newTimelineId)
	end
end

function ClientAbilityComponent:RPC_SC_TeleportBySnapshot(posX, posY, posZ)
	EModelUtils.setMotionPositionByNumber(self, posX, posY, posZ)
end

function ClientAbilityComponent:RPC_SC_GenRandomIntForAsyncActions(actorId, combatContextId, key, randomInt, eventName)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_SetAbilityCacheVal", actorId, combatContextId, key, randomInt)
	end

	local entity = pg.getEntityByActorId(actorId)

	if entity == nil then
		return
	end

	local combatContext = self:getCombatContext(combatContextId)

	if not combatContext then
		return
	end

	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		CombatLogger.error("RPC_SC_GenRandomIntForAsyncActions abilityObject not found", actorId, combatContextId, key, randomInt, eventName)

		return
	end

	abilityObject.cacheValMap[key] = randomInt

	if self.subject and ToBool(eventName) then
		self.subject:notify(eventName, nil)
	end

	if self.authority == Const.AUTHORITY_MASTER then
		self:serverMsgNoGC("RPC_CS_ClientGotRandomInt", actorId, combatContextId, key, eventName)
	end
end

function ClientAbilityComponent:RPC_SC_NotifyClientCustomEvent(eventName, customData)
	self.subject:notify(eventName, customData)
end

function ClientAbilityComponent:RPC_SC_OnTargetAttachToSelf(attachedActorId)
	local lockActorId = self:getAttackTargetActorId()

	if lockActorId == attachedActorId then
		self:unlockTarget(true)
	end
end

function ClientAbilityComponent:on_shieldPoint_changed(oldv, newv, index)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("ClientAbilityComponent:on_shieldPoint_changed>> ", newv)
	end

	if Utils.isPlayer(self) then
		local pets = self.petPrepareList or {}

		for idx, petId in pairs(pets) do
			if petId then
				local petEnt = pg.getEntity(petId)

				if petEnt then
					petEnt:on_shieldPoint_changed(oldv, newv, index)
				end
			end
		end
	end

	if Utils.isPuppet(self) or Utils.isPet(self) then
		facade:SendMessageCommand(MessageName.SHIELD_CHANGE, self)
		self.eventEmitter:emit(EventConst.TOPLOGO_SHIELD_POINT)

		if newv == 0 and newv < oldv then
			facade:SendMessageCommand(MessageName.SHIELD_BREAK, self)
			self.eventEmitter:emit(EventConst.TOPLOGO_SHIELD_BREAK)
		end
	end
end

function ClientAbilityComponent:onShieldDataAdd(index, shieldData)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("ClientAbilityComponent:onShieldDataAdd>>")
	end

	if Utils.isPlayer(self) then
		local pets = self.petPrepareList or {}

		for idx, petId in pairs(pets) do
			if petId then
				local petEnt = pg.getEntity(petId)

				if petEnt then
					local curPoint = self.shieldDataList:getCurPoint(petEnt)

					petEnt:on_shieldPoint_changed(curPoint, curPoint, index)
				end
			end
		end
	end

	if Utils.isPuppet(self) or Utils.isPet(self) then
		facade:SendMessageCommand(MessageName.SHIELD_CHANGE, self)
		self.eventEmitter:emit(EventConst.TOPLOGO_SHIELD_POINT)
	end
end

function ClientAbilityComponent:onShieldDataRemove(index, shieldData)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("ClientAbilityComponent:onShieldDataRemove>>")
	end

	if Utils.isPlayer(self) then
		facade:SendMessageCommand(MessageName.SHIELD_CHANGE, self)

		local pets = self.petPrepareList or {}

		for idx, petId in pairs(pets) do
			if petId then
				local petEnt = pg.getEntity(petId)

				if petEnt then
					petEnt:onShieldDataRemove(index, shieldData)
				end
			end
		end
	elseif Utils.isPuppet(self) or Utils.isPet(self) then
		self.eventEmitter:emit(EventConst.TOPLOGO_SHIELD_POINT)
		facade:SendMessageCommand(MessageName.SHIELD_CHANGE, self)
		facade:SendMessageCommand(MessageName.SHIELD_BREAK, self)
		self.eventEmitter:emit(EventConst.TOPLOGO_SHIELD_BREAK)
	end

	if self.shieldMaxPointMap and #self.shieldDataList <= 0 then
		lume.clear(self.shieldMaxPointMap)
	end
end

function ClientAbilityComponent:RPC_SC_StopBurrowByHit()
	self:stopBurrowByHit()
end

function ClientAbilityComponent:RPC_SC_SetAppearDash(enable)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_SetAppearDash", enable)
	end

	if enable then
		self.skillStateMgr:switchState(AbilityConst.SKILL_STATE_APPEAR_DASH)
	elseif self.skillStateMgr.currentState == AbilityConst.SKILL_STATE_APPEAR_DASH then
		self.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)
	end
end

function ClientAbilityComponent:RPC_SC_OnBuffRefresh(instanceId)
	local buff = self.actorBuff.buffMap[instanceId]

	if buff then
		buff:refresh()
	end
end

function ClientAbilityComponent:RPC_SC_RePressSkillSlot(abilityId)
	self.subject:notify(AbilityConst.COMBAT_EVENT_ON_RE_PRESS_SKILL_SLOT, abilityId)
end

function ClientAbilityComponent:RPC_SC_OnSkillMotionStateChange(actionIds, state, isEnter)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_OnSkillMotionStateChange", state, isEnter)
	end

	if isEnter then
		local animId = self.abilityMotionInfos[state .. AbilityConst.SKILL_MOTION_ANIM_SUFFIX]

		if ToBool(animId) then
			self:playAnimation(animId)
		end
	end

	self.subject:notify(AbilityConst.COMBAT_EVENT_ON_SKILL_MOTION_STATE_CHANGE, actionIds)
end

function ClientAbilityComponent:RPC_SC_LeaveAppearDash()
	if self.skillStateMgr.currentState == AbilityConst.SKILL_STATE_APPEAR_DASH then
		self.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)
	end
end

function ClientAbilityComponent:RPC_SC_KeepChainBurstDamage(duration)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_KeepChainBurstDamage", duration)
	end

	facade:sendMsgToUI(MessageName.CHAIN_ATTACK_KEEP_DAMAGE, duration)
end

function ClientAbilityComponent:RPC_SC_OnEnterSpecialRideMode(bossActorId)
	local bossEntity = pg.getEntityByActorId(bossActorId)

	if not bossEntity then
		return
	end

	local valid, pos = bossEntity.eModel.skeletonView:TryGetBonePos(AbilityConst.SPECIAL_RIDE_HOOK_BONE_NAME)

	if not valid then
		return
	end

	self:cancelAbility()
	self:setEntityCacheVal(AbilityConst.COMBAT_EVENT_ON_ENTER_SPECIAL_RIDE_MODE, {
		targetActorId = bossEntity.actorId,
		attachBone = AbilityConst.SPECIAL_RIDE_HOOK_BONE_NAME
	})

	local switchSkillInfo = AbilityConst.SPECIAL_RIDE_SWITCH_SKILL_INFO[self.templateId]

	if switchSkillInfo then
		self:switchSkill(switchSkillInfo.from, switchSkillInfo.to)
	end

	self:enableSpecialAttackMode(true, -1, {})

	local controllerComponent = self:getEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER)

	if NotNil(controllerComponent) then
		controllerComponent.abilityCharacterStateInfo.abilityStateMachine = AbilityConst.ABILITY_SPECIAL_RIDE_STATE
	end
end

function ClientAbilityComponent:RPC_SC_OnForceLeaveSpecialRideMode()
	AnimationUtils.playAnimationState(self, CharacterStateConst.LOCOMOTION)
	self:exitSpecialRideMode()
end

function ClientAbilityComponent:RPC_SC_ReboundDashHitActor(hitActorId, hitPos)
	self:onReboundDashHitActor(hitActorId, hitPos)
end

function ClientAbilityComponent:RPC_SC_ReboundDashEnd()
	self:endReboundDash()
end

function ClientAbilityComponent:RPC_CS_MoveByDirectionEnd(nodeId, dynamicInfo)
	local combatContext = CombatContext.convert(self, dynamicInfo)
	local actionData = combatContext.nodeMap[nodeId]

	pg.global.abilityMgr.combatAction:doActionIds(actionData.endActionIds, combatContext)
end

function ClientAbilityComponent:RPC_SC_AttachToEntity(targetActor, offsetPos, rotation, tweenSpeed)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_AttachToEntity", targetActor, inspect(offsetPos), inspect(rotation), tweenSpeed)
	end

	if not self.beStick then
		return
	end

	local targetEntity = pg.getEntityByActorId(targetActor)

	self:beStick()

	if targetEntity and self:hasEModelComponent(Const.COMPONENT_ATTACH) then
		self.eModel:AttachByCurrentPos(Const.COMPONENT_ATTACH, targetEntity.eModel, offsetPos, rotation, tweenSpeed)

		targetEntity.attachMap[self.actorId] = {
			offsetPos,
			rotation
		}

		if targetEntity.updateAttachMap then
			targetEntity:updateAttachMap()
		end
	end

	self.attachInfo = {
		targetActor,
		offsetPos,
		rotation
	}
end

function ClientAbilityComponent:RPC_SC_DetachFromEntity(targetActor)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_DetachFromEntity", targetActor)
	end

	if not self.beUnstick then
		return
	end

	local targetEntity = pg.getEntityByActorId(targetActor)

	if targetEntity then
		targetEntity.attachMap[self.actorId] = nil

		if targetEntity.updateAttachMap then
			targetEntity:updateAttachMap()
		end
	end

	if self.eModel then
		self.eModel:Detach(Const.COMPONENT_ATTACH)
	end

	local rotation = self:getRotation()
	local angles = Quaternion.ToEulerAngles(rotation)

	self:setRotation(Quaternion.Euler(0, angles.y, 0), true)

	self.attachInfo = nil

	self:beUnstick()
end

function ClientAbilityComponent:RPC_SC_DoTagReaction(nodeId, dynamicInfo, combatContextId)
	local combatContext = CombatContext.convert(self, dynamicInfo)
	local actionData = combatContext.nodeMap[nodeId]

	if not actionData then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("action data not found", inspect(combatContext.id), nodeId)
		end

		return
	end

	local conditionTypes = self.combatAction:getConditionTypes(combatContext, actionData)

	if not ToBool(conditionTypes) then
		return
	end

	local entity = pg.getEntityByActorId(combatContext.runtimeTargetInfo.actorId)

	if not entity then
		return
	end
end

function ClientAbilityComponent:RPC_SC_SyncCombatContextTarget(combatContextId, targetActorId)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_SyncCombatContextTarget", combatContextId)
	end

	local combatContext = self:getCombatContext(combatContextId)

	if not combatContext then
		return
	end

	if combatContext.runtimeTargetInfo then
		combatContext.runtimeTargetInfo.actorId = targetActorId
	else
		combatContext.runtimeTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:getWithCtor(true, targetActorId)
	end
end

function ClientAbilityComponent:RPC_SC_StartWaterBeAbsorb(waterAbsorbList, delayTime, duration, commonMount)
	if not self.eModel then
		return
	end

	local bone

	if commonMount then
		local mountData = ClientEffectUtils.getBestFitCommonMount(self, commonMount)

		bone = mountData and mountData.bone or commonMount
	end

	if not bone then
		return
	end

	self:addTimer(delayTime, function()
		for _, waterAbsorbPos in ipairs(waterAbsorbList) do
			waterAbsorbPos = Vector3.Clone(waterAbsorbPos)

			local effectConfig = {
				commonMount = "",
				duration = duration,
				mountType = EffectConst.MountType.World,
				followType = EffectConst.FollowType.Global,
				position = waterAbsorbPos,
				loadCallback = function(effectItem)
					local trans = effectItem.effectTrans

					if NotNil(trans) then
						local comp = trans:GetComponent(typeof(CS.FunPlus.WorldX.Effect.WaterAbsorbEffectPlayer))

						if NotNil(comp) then
							comp:PlayAbsorbEffect(self.eModel, bone, duration, -1, delayTime, 0, 2, 2)
						end
					end
				end
			}

			self:playEffect("Eff_Parmon_10194_Skill_waterPolishing", effectConfig)
		end
	end)
end

function ClientAbilityComponent:RPC_SC_NotifyPlayAbilityAnimation(animId)
	self:playAbilityAnimation(animId, -1, -1)
end

function ClientAbilityComponent:RPC_SC_DoTeamExtremeChainActions(abilityId, combatContextId, lockedActorId, chainAttackCnt)
	local actionData = ChainAttackBP[chainAttackCnt]
	local elementType = pg.global.abilityMgr:getAbilityParamData(abilityId).elementType or 0
	local actionIds = actionData.elementActionIdsMap[elementType]

	self.chainAttackInfo:doPlayerTeamExtremeChainActions(self, actionIds, abilityId, combatContextId, lockedActorId, chainAttackCnt)
end

function ClientAbilityComponent:onProjAroundSelfCnt(old, new)
	self.logger:debug("onProjAroundSelfCnt", self.actorId, old, new)

	local changeVal = new - old

	if changeVal > 0 and self.projAroundSelfControl then
		self.projAroundSelfControl:addProj(changeVal)
	end
end

function ClientAbilityComponent:RPC_SC_LaunchProjAroundSelf(count, dynamicInfo)
	if not self.authority == Const.AUTHORITY_MASTER then
		if self.projAroundSelfControl then
			for i = count, 1, -1 do
				if self.projAroundSelfControl.projList[i] then
					self.projAroundSelfControl.projList[i]:clear()
					table.remove(self.projAroundSelfControl.projList, i)
				end
			end
		end

		return
	end

	local combatContext = CombatContext.convert(self, dynamicInfo)

	if not combatContext then
		return
	end

	if self.projAroundSelfControl then
		self.projAroundSelfControl:launch(count, combatContext)
	end
end

function ClientAbilityComponent:on_hatredMap_deleted(entityActorId, value)
	local lockActorId = self:getAttackTargetActorId()

	if lockActorId == entityActorId then
		self:unlockTarget(true)
	end
end

function ClientAbilityComponent:RPC_SC_ForceSetAuthority(authority)
	self.authority = authority
end

function ClientAbilityComponent:onLoadedCntChange(oldCnt, newCnt, abilityId)
	if self.isMainPlayer or self.isMainPet then
		local data = {}

		data.newCnt = newCnt
		data.abilityId = abilityId
		data.oldCnt = oldCnt

		facade:sendMsgToUI(MessageName.BACK_LIST_CHANGED, data)
	end
end

function ClientAbilityComponent:RPC_SC_FastForwardTimeline(timelineId, time)
	local timeline = self.actorTimeline:getTimelineInstance(timelineId)

	if not timeline then
		return
	end

	timeline:tick(time)
end

function ClientAbilityComponent:RPC_SC_DisableReturnAbilityConsumes(combatContextId)
	local castingCombatContext = CombatActionTool.getCombatContextById(combatContextId)

	if not castingCombatContext then
		return
	end

	self.subject:notify(AbilityConst.COMBAT_EVENT_ON_ABILITY_DISABLE_RETURN, castingCombatContext)
end

return ClientAbilityComponent
