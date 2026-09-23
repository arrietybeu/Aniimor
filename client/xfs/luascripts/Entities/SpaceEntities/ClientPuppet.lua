-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientPuppet.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local PlayableConst = require("Common.Const.PlayableConst")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local RigidbodyData = require("Data.rigidbody_data")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local Utils = require("Common.Utils.Utils")
local MessageName = require("Const.MessageName")
local ClientPawnEntity = require("Entities.ClientPawnEntity")
local SkillHitDisplacementControl = require("GameApp.Controller.Utils.SkillHitDisplacementControl")
local PuppetData = require("Data.puppet_data")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local GlobalData = require("Core.Client.GlobalData")
local AudioConst = require("Const.AudioConst")
local EventConst = require("Const.EventConst")
local EffectUtils = require("GameApp.Effect.EffectUtils")
local AIUtils = require("Common.Utils.AIUtils")
local EBTRootState = BaseEnum.EBTRootState
local Bitset = require("Common.Bitset")
local ConflictTypes = require("Common.ConflictTypes")
local CaptureConst = require("Common.Const.CaptureConst")
local NpcAvatarData = require("Data.npc_avatar_data")
local ClientSwitch = require("Common.ClientSwitch")
local AiConst = require("Common.Const.AiConst")
local SceneData = require("Data.scene_data")
local UIConst = require("Const.UIConst")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local AbilityConst = require("Common.Const.AbilityConst")
local FishingCaptureActivityData = require("Data.fishing_capture_activity_data")
local ClientPuppet = class.Class("ClientPuppet", ClientPawnEntity)
local ClientAuthorityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAuthorityComponent")
local ClientTopLogoComponent = require("Entities.SpaceEntities.CommonComponent.ClientTopLogoComponent")
local ClientNpcInteractComponent = require("Entities.SpaceEntities.CommonComponent.ClientNpcInteractComponent")
local ClientTrapEventComponent = require("Entities.SpaceEntities.CommonComponent.ClientTrapEventComponent")
local ClientPhotoIdentifyComponent = require("Entities.SpaceEntities.CommonComponent.ClientPhotoIdentifyComponent")
local ClientCombatEntityComponent = require("Entities.SpaceEntities.CommonComponent.ClientCombatEntityComponent")
local ClientAbilityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAbilityComponent")
local AIComponent = require("Common.Components.AIComponent")
local AIPlanComponent = require("Common.Components.AIPlanComponent")
local AdditiveAIComponent = require("Common.Components.AdditiveAIComponent")
local AIPlanDynamicComponent = require("Common.Components.AIPlanDynamicComponent")
local AIGroupBehaviorComponent = require("Common.Components.AIGroupBehaviorComponent")
local ClientSummonHostComponent = require("Entities.SpaceEntities.CommonComponent.ClientSummonHostComponent")
local ClientSummonedComponent = require("Entities.SpaceEntities.CommonComponent.ClientSummonedComponent")
local PerceptibilityComponent = require("Common.Components.PerceptibilityComponent")
local ClientCombatViewComponent = require("Entities.SpaceEntities.CommonComponent.ClientCombatViewComponent")
local ClientTimeControlComponent = require("Entities.SpaceEntities.CommonComponent.ClientTimeControlComponent")
local ClientMotionComponent = require("Entities.SpaceEntities.CommonComponent.ClientMotionComponent")
local ClientCombatActorPartComponent = require("Entities.SpaceEntities.CommonComponent.ClientCombatActorPartComponent")
local ClientPetInfoComponent = require("Entities.SpaceEntities.CommonComponent.ClientPetInfoComponent")
local ClientSpecialStateRecoverComponent = require("Entities.SpaceEntities.CommonComponent.ClientSpecialStateRecoverComponent")
local ClientSimpleLookAtComponent = require("Entities.SpaceEntities.CommonComponent.ClientSimpleLookAtComponent")
local ClientMiniGameCommonComponent = require("Entities.SpaceEntities.CommonComponent.ClientMiniGameCommonComponent")
local ClientEcologyComponent = require("Entities.SpaceEntities.CommonComponent.ClientEcologyComponent")
local ClientResPointComponent = require("Entities.SpaceEntities.CommonComponent.ClientResPointComponent")
local ClientRVOComponent = require("Entities.SpaceEntities.CommonComponent.ClientRVOComponent")
local ClientBossSpecialInteractionComponent = require("Entities.SpaceEntities.CommonComponent.ClientBossSpecialInteractionComponent")
local ClientAttachComponent = require("Entities.SpaceEntities.CommonComponent.ClientAttachComponent")
local ClientAreaHandlerComponent = require("Entities.SpaceEntities.CommonComponent.ClientAreaHandlerComponent")
local ClientGhostEyeDetectedComponent = require("Entities.SpaceEntities.PlayerComponent.ClientGhostEyeDetectedComponent")
local ClientDynamicFeatureComponent = require("Entities.SpaceEntities.CommonComponent.ClientDynamicFeatureComponent")
local ClientEntityCacheValComponent = require("Entities.SpaceEntities.CommonComponent.ClientEntityCacheValComponent")
local ClientDummyCloneComponent = require("Entities.SpaceEntities.CommonComponent.ClientDummyCloneComponent")
local ClientTrapComponent = require("Entities.SpaceEntities.CommonComponent.ClientTrapComponent")
local ClientNpcAIReactionComponent = require("Entities.SpaceEntities.CommonComponent.ClientNpcAIReactionComponent")
local ClientModelTransmogComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelTransmogComponent")
local ClientEcsComponent = require("Entities.SpaceEntities.CommonComponent.ClientEcsComponent")
local AutoPathFindComponent = require("Common.Components.AutoPathFindComponent")
local CharacterController = require("Common.Components.CharacterController")
local ClientDyingComponent = require("Entities.SpaceEntities.CommonComponent.ClientDyingComponent")
local ClientVoxelComponent = require("Entities.SpaceEntities.CommonComponent.ClientVoxelComponent")
local ClientVehicleOpComponent = require("Entities.SpaceEntities.CommonComponent.ClientVehicleOpComponent")
local ClientStateCheckComponent = require("Entities.SpaceEntities.CommonComponent.ClientStateCheckComponent")
local PuppetComponents = {
	AutoPathFindComponent,
	CharacterController,
	ClientVoxelComponent,
	ClientStateCheckComponent,
	ClientDyingComponent,
	ClientVehicleOpComponent,
	ClientAuthorityComponent,
	ClientSpecialStateRecoverComponent,
	ClientCombatEntityComponent,
	ClientAbilityComponent,
	ClientCombatViewComponent,
	ClientSummonHostComponent,
	ClientSummonedComponent,
	ClientTimeControlComponent,
	ClientTopLogoComponent,
	AIComponent,
	ClientNpcInteractComponent,
	ClientTrapEventComponent,
	ClientMotionComponent,
	ClientCombatActorPartComponent,
	ClientPetInfoComponent,
	PerceptibilityComponent,
	AIPlanComponent,
	AdditiveAIComponent,
	AIPlanDynamicComponent,
	ClientSimpleLookAtComponent,
	ClientPhotoIdentifyComponent,
	ClientMiniGameCommonComponent,
	ClientEcologyComponent,
	ClientResPointComponent,
	ClientRVOComponent,
	AIGroupBehaviorComponent,
	ClientBossSpecialInteractionComponent,
	ClientAttachComponent,
	ClientDynamicFeatureComponent,
	ClientAreaHandlerComponent,
	ClientGhostEyeDetectedComponent,
	ClientEntityCacheValComponent,
	ClientDummyCloneComponent,
	ClientTrapComponent,
	ClientNpcAIReactionComponent,
	ClientModelTransmogComponent,
	ClientEcsComponent
}

if EnableBotTest then
	local BotClientAbilityComponent = require("Bot.BotEntities.Components.BotClientAbilityComponent")
	local BotClientModelComponent = require("Bot.BotEntities.Components.BotClientModelComponent")

	PuppetComponents = {
		ClientAuthorityComponent,
		BotClientAbilityComponent,
		BotClientModelComponent
	}
end

class.AddComponents(ClientPuppet, PuppetComponents)

function ClientPuppet:ctor(entityId)
	ClientPuppet.super.ctor(self, entityId)

	self.actorType = Const.ACTOR_TYPE_PUPPET
	self.skillHitDisplacementCtrl = SkillHitDisplacementControl(self)
	self.isClientEnt = false
end

function ClientPuppet:init(bdict)
	ClientPuppet.super.init(self, bdict)

	local pdd = PuppetData[self.templateId] or {}
	local topbarHeightValid = true

	if pdd.topbarHeight and pdd.topbarHeight < -10 then
		topbarHeightValid = false
	end

	self.forbiddenTopLogo = pdd.forbidTopLogo or not topbarHeightValid
	self.trapEventId = bdict.trapEventId
	self.spawnerLeaderId = bdict.spawnerLeaderId
	self.spawnerPartnerIds = bdict.spawnerPartnerIds
	self.isFadeIn = bdict.isFadeIn
	self.spriteIdAfterCatch = pdd.spriteIdAfterCatch
	self.useHitBox = pdd.hitBox
	self.bodyMass = pdd.mass
	self.bodyWeight = pdd.weight
	self.isWild = pdd.isWild and pdd.isWild > 0
	self.topLogoType = ClientConst.TopLogoType.Pet
	self.masterActorId = bdict.masterActorId
	self.canSpawnChest = bdict.chestSpawnerStaticId and bdict.chestSpawnerStaticId > 0
	pg.game.map.puppetStaticIdInitRecord[self.staticId] = self.level
	self.bossCatchDestroy = false
	self.notifyMasterAbilityEvent = bdict.notifyMasterAbilityEvent

	return true
end

function ClientPuppet:postInit(dict)
	ClientPuppet.super.postInit(self, dict)

	local pdd = PuppetData[self.templateId]

	if not EnableBotTest and pdd and pdd.bTree then
		self:setBtName(pdd.bTree)
	end
end

function ClientPuppet:initializeComponents()
	ClientPuppet.super.initializeComponents(self)

	if self.eModel == nil then
		return
	end

	self:addEModelComponent(Const.COMPONENT_INDEX_IK)
	self:addEModelComponent(Const.COMPONENT_MOTION)

	if self.authority == Const.AUTHORITY_MASTER then
		self:addEModelComponent(Const.COMPONENT_AI_CONTROLLER)
		self:addEModelComponent(Const.COMPONENT_AUTO_PATH_FIND)
	end
end

function ClientPuppet:postInitializeComponents()
	ClientPuppet.super.postInitializeComponents(self)
	self:initPuppetCapture()
	self:applyMotionProp()

	if Utils.isBoss(self) and self.authority == Const.AUTHORITY_MASTER then
		AIControllerUtils.setUseKCCMove(self, true, Const.KccControlType.BossControl)
	end
end

function ClientPuppet:start()
	ClientPuppet.super.start(self)

	self.bornPosition = self:transferBornPosition()

	if Utils.isBoss(self) then
		self:setSoundRTPCValue(AudioConst.RTPC_PAMON_MOVEMENT, 1)
	end

	local isHide = self:getConfigData().isHide

	if isHide == 1 then
		self:setActive(ClientConst.MODEL_VISIBLE_KEY.CONFIG, false)
	end

	if ClientSwitch.EnableHidePuppet then
		self:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.GM, false)
		self:setCollideEnable(ClientConst.MODEL_VISIBLE_KEY.GM, false)

		if self.pauseBt then
			self:pauseBt(AiConst.PauseBtReason.GM)
		end
	end

	if ToBool(self.staticId) and ClientConst.IGNORE_LOD_WHITE_LIST_BY_STATIC_ID[self.staticId] then
		if self.setIgnoreAILod then
			self:setIgnoreAILod(true, AiConst.IgnoreAILodReason.GamePlay)
		end

		if self.setLodTickEnable then
			self:setLodTickEnable(Const.LOD_TICK_KEY.GAME_PLAY, false)
		end
	end

	self:refresh1P3PAudioRTCP()
	self:refreshSceneFootStepVolumeRTPC()
	self:_tryHideSettledGroupRewardBoss()
end

function ClientPuppet:refresh1P3PAudioRTCP()
	if Utils.isBoss(self) or Utils.isElite(self) then
		self:setSoundRTPCValue(AudioConst.RTPC_VOLUME_3P, 1)
	else
		self:setSoundRTPCValue(AudioConst.RTPC_VOLUME_3P, 0)
	end
end

function ClientPuppet:refreshSceneFootStepVolumeRTPC()
	local sceneInfo = self.space and SceneData[self.space.sceneId]
	local footStepVolume = sceneInfo and sceneInfo.footStepVolume

	self:setSoundRTPCValue(AudioConst.RTPC_FOOTSTEP_QIANGDAN, footStepVolume and footStepVolume[2] or 0)
end

function ClientPuppet:tick(deltaTime)
	self:postComponentMethod("tick", deltaTime)
end

function ClientPuppet:onEnterScene()
	ClientPuppet.super.onEnterScene(self)

	if self:inBreak() then
		facade:SendMessageCommand(MessageName.BREAK_STATE_CHANGE, {
			isInit = true,
			isBreak = true,
			ent = self
		})
	end
end

function ClientPuppet:onEnterSpace()
	ClientPuppet.super.onEnterSpace(self)
	self:refreshSceneFootStepVolumeRTPC()

	if self.space:isRogueEnv() and (Utils.isBoss(self) or Utils.isElite(self)) then
		facade:SendMessageCommand(MessageName.ROGUE_BOSS_CHANGE, {
			self,
			true
		})
	end
end

function ClientPuppet:onLeaveSpace()
	ClientPuppet.super.onLeaveSpace(self)

	if self.space:isRogueEnv() and (Utils.isBoss(self) or Utils.isElite(self)) then
		facade:SendMessageCommand(MessageName.ROGUE_BOSS_CHANGE, {
			self,
			false
		})
	end
end

function ClientPuppet:onRefreshAppearance(configData, extraData, forceRefreshPlayable)
	ClientPuppet.super.onRefreshAppearance(self, configData, extraData, forceRefreshPlayable)

	local modelView = self.eModel.modelModelView

	if configData.keepPrefabLayer then
		modelView.keepPrefabLayer = true
	end

	if configData.needWait and not self:modelLoaded() then
		self.waitModelMark = true
		modelView.instPriority = ClientConst.InstantiatePriority.High

		pg.global.scene:markWaitEntity(self.id, true)
	end
end

function ClientPuppet:refreshModel(configData, extraData)
	local modelView = self.eModel.modelModelView
	local result, realPrefabResID = AvatarUtils.refreshNPCModelData(configData)

	if result then
		extraData.prefabResID = realPrefabResID

		ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraData)
	else
		ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraData)

		if configData.appearanceResID then
			local npcAvatarData = NpcAvatarData[configData.appearanceResID] or Const.CACHED_EMPTY_TABLE
			local presetKey = npcAvatarData.avatarId

			if presetKey then
				modelView.modelInfo:ParseAvatarRuntimeData(presetKey)
				modelView.modelInfo:ParseToModelInfo()
			end
		end
	end

	self:postComponentMethod("Event_BeforeRefreshModels", modelView)
	ClientModelUtils.refreshModels(self, modelView)

	if Utils.isElite(self) or Utils.isBoss(self) then
		self:setRendererLod(0)
	end

	self:postComponentMethod("Event_AfterRefreshModels", modelView)
end

function ClientPuppet:getModelExtraData(configData)
	local label = self:getLabel()
	local gender = self:getGender()
	local extraFix

	if configData.useSuitModel then
		local suitId = AbilityUtils.getSuitId(self:getMasterEntity())

		if ToBool(suitId) and (suitId == 4 or suitId == 5) then
			extraFix = string.format("_Suit%02d", suitId)
		end
	end

	local extraInfo = ClientModelUtils.getModelExtraInfo(configData, label or 0, gender or 0, true, extraFix)

	if self.spPrefabResID then
		extraInfo.prefabResID = self.spPrefabResID
	end

	return extraInfo
end

function ClientPuppet:transferBornPosition()
	return Vector3(self.bornPosition_x, self.bornPosition_y, self.bornPosition_z)
end

function ClientPuppet:refreshBornPosition()
	self.bornPosition = self:transferBornPosition()
end

function ClientPuppet:on_bornPosition_x_changed()
	self:refreshBornPosition()
end

function ClientPuppet:on_bornPosition_y_changed()
	self:refreshBornPosition()
end

function ClientPuppet:on_bornPosition_z_changed()
	self:refreshBornPosition()
end

function ClientPuppet:preDestroy()
	if self.destroyReason == Const.DESTROY_REASON.CAPTURE_SUCCESS or self.destroyReason == Const.DESTROY_REASON.HOMEPET_REFRESH or self.bossCatchDestroy and self.needDoGroupReward then
		-- block empty
	elseif self.destroyReason == Const.DESTROY_REASON.PET_CHALLENGE then
		self:playDestroyEffect()
	elseif not EnableBotTest and (self:isDead() or self:checkAIInDeadState()) then
		self:playDestroyEffect()
	end

	if self.isFadeOut then
		self:playFadeOutEffect()
	end

	ClientPuppet.super.preDestroy(self)
end

function ClientPuppet:destroy()
	self:clearCaptureRestoreFallback()
	ClientPuppet.super.destroy(self)
end

function ClientPuppet:playDestroyEffect()
	local configData = self.isDummyClone and PuppetData[self.templateId] or self:getConfigData()

	if configData.destroyEffect then
		pg.game.effect:playEffectAt(nil, configData.destroyEffect, self:getPosition(), self:getRotation():ToEulerAngles(), self)
	end
end

function ClientPuppet:playBossCatchHide(withEffect)
	if withEffect == nil then
		withEffect = true
	end

	local configData = self.isDummyClone and PuppetData[self.templateId] or self:getConfigData()

	if withEffect and configData.destroyEffect then
		pg.game.effect:playEffectAt(nil, configData.destroyEffect, self:getPosition(), self:getRotation():ToEulerAngles(), self)
	end

	self:setVisible(ClientConst.MODEL_VISIBLE_KEY.BOSS_CATCH, false, false, false)

	self.bossCatchDestroy = true
end

function ClientPuppet:_tryHideSettledGroupRewardBoss()
	if not self.needDoGroupReward or not self:isDead() then
		return
	end

	local player = pg.me

	if not player or not player.groupDropEndTsMap then
		return
	end

	local endTsMap = player.groupDropEndTsMap

	if endTsMap[self.actorId] then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("puppetdrop boss, hide settled boss on rebuild, actorId=%s", self.actorId)
	end

	self:playBossCatchHide(false)
end

function ClientPuppet:repr()
	return string.format("ClientPuppet(entityId=%s, uid=%d)", self.id, self.uid or 0)
end

function ClientPuppet:getTemplateData()
	return PuppetData[self.templateId] or {}
end

function ClientPuppet:canBeLocked()
	if self.isTransparent then
		return false
	end

	if self:isDead() and not self:isFishingCaptureBoss() then
		return false
	end

	if self.visible == false and not self:BURROW_ST() then
		return false
	end

	local configData = self:getConfigData()

	if configData.canNotSelect then
		return false
	end

	if self.isTrapped then
		return false
	end

	return true
end

function ClientPuppet:onDeformed()
	ClientPuppet.super.onDeformed(self)
	self:calcAndRefreshModelScale(true)
end

function ClientPuppet:on_curHp_changed(oldv, newv)
	facade:SendMessageCommand(MessageName.HEALTH_POINT_CHANGE, self)
	self.eventEmitter:emit(EventConst.TOPLOGO_HEALTH_POINT, oldv, newv)
end

function ClientPuppet:on_bossMechanismIconMax_changed(oldv, newv)
	facade:SendMessageCommand(MessageName.BOSS_MECHANISM_ICON_SYNC_MAX, {
		actorId = self.actorId,
		max = newv,
		progress = self.bossMechanismIconProgress
	})
end

function ClientPuppet:on_bossMechanismIconProgress_changed(oldv, newv)
	facade:SendMessageCommand(MessageName.BOSS_MECHANISM_ICON_SYNC_PROGRESS, {
		actorId = self.actorId,
		max = self.bossMechanismIconMax,
		progress = newv
	})
end

function ClientPuppet:RPC_SC_BossMechanismIconFlash()
	facade:SendMessageCommand(MessageName.BOSS_MECHANISM_ICON_FLASH, {
		actorId = self.actorId
	})
end

function ClientPuppet:on_level_changed(oldv, newv)
	local component = pg.global.ui.tips:getBossTitleItem()

	if component and self.id == component:getTargetId() then
		component:refreshLevel()
	end

	self:executeTopLogoComponentMethod(UIConst.TOPLOGO_COMPONENT.COMBAT, "refreshLevelAndThreatState")
end

function ClientPuppet:initPuppetCapture()
	local actorInfo = Utils.getEntityConfigData(self)
	local rigidbodyId = actorInfo.rigidbody

	if not rigidbodyId then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			self.logger:warn("initPuppetCapture rigidbodyId is nil", self.templateId)
		end

		return
	end

	local rigidbodyData = RigidbodyData[rigidbodyId]

	if not rigidbodyData then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			self.logger:warn("initPuppetCapture rigidbodyData is nil", self.templateId)
		end

		return
	end

	if self.eModel == nil then
		return
	end

	self.eModel:SetPuppetCatchExpand(Const.COMPONENT_IDX_PHYSX, rigidbodyData.radius * math.max(1.1, rigidbodyData.catch_radius_scale), rigidbodyData.height * 1.1)
end

function ClientPuppet:refreshPuppetCapture(rigidbodyId)
	if not rigidbodyId then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			self.logger:warn("refreshPuppetCapture rigidbodyId is nil", self.templateId)
		end

		return
	end

	local rigidbodyData = RigidbodyData[rigidbodyId]

	if not rigidbodyData then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			self.logger:warn("refreshPuppetCapture rigidbodyData is nil", self.templateId)
		end

		return
	end

	if self.eModel == nil then
		return
	end

	self.eModel:SetPuppetCatchExpand(Const.COMPONENT_IDX_PHYSX, rigidbodyData.radius * math.max(1.1, rigidbodyData.catch_radius_scale), rigidbodyData.height * 1.1)
end

function ClientPuppet:onLuaBallHitNearby(ball)
	self:addBallComingNearbyPerceptibility(ball.master.actorId)
end

function ClientPuppet:trapped(fromBigBall)
	if self.eModel == nil then
		return
	end

	self.isTrapped = true

	AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.IS_TRAPPED, true)

	if self.updateStateCache then
		self:updateStateCache("IN_BALL_ST")
	end

	self.captureTrapped = true
	self.capturePredictSessionId = nil

	if not self:isDead() then
		if fromBigBall then
			self.trappedAnimState = self:playAnimation(PlayableConst.Idle)
		else
			self.trappedAnimState = self:playRawAnimation(PlayableConst.Struggle, 0.6)
		end

		if self.trappedAnimState then
			self:playRaiseUp(0.25, 1.5, 2)
		end
	end

	pg.global.eventEmitter:emit(EventConst.LOCK_ENITY_MSG, "trapped", self)
	self:hideEffect()
	self:postComponentMethod("EVENT_BeTrapped")
	self:stopTick()
	self:closeTopLogo()

	if self.eModel then
		self.eModel:SetColliderEnable(false)
	end

	self:cancelAbility()
	self:checkStatus(ConflictTypes.CT_PUPPET_TRAPPED)
end

function ClientPuppet:cancelTrapped(ballMasterActorId)
	if self.eModel == nil then
		return
	end

	if self:isDead() then
		return
	end

	self.isTrapped = false

	AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.IS_TRAPPED, false)

	if self.updateStateCache then
		self:updateStateCache("IN_BALL_ST")
	end

	self.captureTrapped = nil

	if self.trappedAnimState then
		self.trappedAnimState:Stop()

		self.trappedAnimState = nil
	end

	self:startTick()
	self:openTopLogo()
	self:showEffect()
	self:postComponentMethod("EVENT_CancelTrapped", ballMasterActorId)

	if self.eModel then
		self.eModel:SetColliderEnable(true)
	end
end

function ClientPuppet:beginCapturePredictTrap(captureSessionId)
	if self.eModel == nil then
		return
	end

	if self.captureTrapped then
		return
	end

	self.capturePredictSessionId = captureSessionId

	self:pauseBt(AiConst.PauseBtReason.Capture)
	AIControllerUtils.pause(self, AiConst.AIControllerDisableReason.BeCaptured)
end

function ClientPuppet:cancelCapturePredictTrap(captureSessionId)
	if self.capturePredictSessionId == nil or self.capturePredictSessionId ~= captureSessionId then
		return
	end

	self.capturePredictSessionId = nil

	if self.captureTrapped or self.isInCapture then
		return
	end

	self:resumeBt(AiConst.PauseBtReason.Capture)
	AIControllerUtils.resume(self, AiConst.AIControllerDisableReason.BeCaptured)
end

function ClientPuppet:scheduleCaptureRestoreFallback()
	self:clearCaptureRestoreFallback()

	self.captureRestoreFallbackTimer = self:addTimer(CaptureConst.HOST_CAPTURE_RESTORE_FALLBACK_DELAY, function()
		self:tryRestoreFromCaptureFallback()
	end)
end

function ClientPuppet:clearCaptureRestoreFallback()
	if self.captureRestoreFallbackTimer ~= nil then
		self:removeTimer(self.captureRestoreFallbackTimer)

		self.captureRestoreFallbackTimer = nil
	end
end

function ClientPuppet:tryRestoreFromCaptureFallback()
	self.captureRestoreFallbackTimer = nil

	if self.eModel == nil then
		return
	end

	if self:isDead() then
		return
	end

	if self.isInCapture then
		return
	end

	if self.captureTrapped then
		self:cancelTrapped()
	elseif self.capturePredictSessionId == nil then
		self:resumeBt(AiConst.PauseBtReason.Capture)
		AIControllerUtils.resume(self, AiConst.AIControllerDisableReason.BeCaptured)
	end

	self:_restoreCaptureDissolve()
end

function ClientPuppet:_restoreCaptureDissolve()
	local eModel = self.eModel
	local shaderView = eModel and eModel.modelShaderView

	if shaderView == nil then
		return
	end

	if not shaderView:IsCaptureDissolveActive() then
		return
	end

	shaderView:StopCaptureDissolveEffect()
end

function ClientPuppet:beStick()
	self.isTrapped = true

	AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.IS_TRAPPED, true)

	if self.updateStateCache then
		self:updateStateCache("IN_BALL_ST")
	end

	self:playAnimation(PlayableConst.StickLoop)
	pg.global.eventEmitter:emit(EventConst.LOCK_ENITY_MSG, "trapped", self)
	self:stopTick()
	self:closeTopLogo()
	self:cancelAbility()
	self:postComponentMethod("EVENT_BeStick")
end

function ClientPuppet:beUnstick()
	self.isTrapped = false

	AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.IS_TRAPPED, false)

	if self.updateStateCache then
		self:updateStateCache("IN_BALL_ST")
	end

	if self:isDead() then
		return
	end

	self:stopAnimation(PlayableConst.StickLoop)
	self:startTick()
	self:openTopLogo()
	self:postComponentMethod("EVENT_BeUnStick")
end

function ClientPuppet:addFakeDeadTrigger()
	if self.authority ~= Const.AUTHORITY_MASTER then
		return false
	end
end

function ClientPuppet:removeFakeDeadTrigger()
	if self.authority ~= Const.AUTHORITY_MASTER then
		return false
	end
end

function ClientPuppet:onModelRefreshed()
	if self.isWild then
		EffectUtils.playRedEyeEffect(self)
	end

	self:setNightShine()
	self:setShinyStyle()
	ClientPuppet.super.onModelRefreshed(self)
end

function ClientPuppet:hideTitleAndEffs()
	local hideShowDic = GlobalData.Player.hideShowTitleDict

	if hideShowDic ~= nil and hideShowDic[self.templateId] ~= nil then
		return hideShowDic[self.templateId]
	end

	return false
end

function ClientPuppet:refreshAttachEffects()
	local configData = self:getConfigData()
	local label = self:getLabel()
	local extraData = ClientModelUtils.getModelExtraInfo(configData, label or 0, self.gender, not self:hideTitleAndEffs())

	if self.attachBaseEffects then
		self:attachBaseEffects(extraData.attachEffects)
	end
end

function ClientPuppet:faceToTarget(target)
	local configData = self:getConfigData()

	if configData.lockDirection then
		return
	end

	ClientPuppet.super.faceToTarget(self, target)
end

function ClientPuppet:checkAIInDeadState()
	if self.aiState == EBTRootState.ST_Root_Dead then
		return true
	end

	return false
end

function ClientPuppet:onSlavesOwnerIdChanged(old, new)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("ClientPuppet onSlavesOwnerIdChanged: ", old, " >> ", new)
	end

	if string.isNilOrEmpty(new) then
		self:exitCurrentGroupBehaviour()
		AIUtils.resetRootState(self)

		self.callFriendsFollowActor = nil

		local ownerEnt = pg.getEntity(old)

		if ownerEnt and ownerEnt:isInCombat() then
			AIControllerUtils.sendAIEvent(self, "SlaveOwnerEnterCombatTrigger")
		end
	else
		local masterEntity = pg.getEntity(new)

		AIUtils.enterRecruit(self, masterEntity and masterEntity.actorId or 0)

		if self.canInteractCallFriend ~= nil then
			local interactId = self.canInteractCallFriend.interactId
			local doOnce = self.canInteractCallFriend.doOnce

			pg.me:serverMsg("RPC_CS_InteractNpcSandboxCustomEvent", interactId, self.canInteractCallFriend.sandBoxId, doOnce)
			self.canInteractCallFriend.callback()

			if doOnce then
				self:enableInteractCallFriend(interactId, false)
			end
		end
	end
end

function ClientPuppet:onTimePeriodChange()
	self:setNightShine()
end

function ClientPuppet:getMasterEntity()
	return pg.getEntityByActorId(self.masterActorId)
end

function ClientPuppet:queryModelVisible()
	if Bitset.any(ClientConst.PUPPET_VISIBLE_FLAG) then
		return true, false
	end

	return ClientPuppet.super.queryModelVisible(self)
end

function ClientPuppet:getCsEntityType()
	return ClientConst.ENTITY_CS_TYPE.PUPPET
end

function ClientPuppet:needLimitCount()
	if Utils.isInteractNpc(self) then
		return false
	end

	return true
end

function ClientPuppet:getConfigData()
	if self.isDummyClone then
		return self.deformData
	end

	return ClientPuppet.super.getConfigData(self)
end

function ClientPuppet:getPreloadEffects()
	local configData = self:getConfigData()
	local preloadEffects

	if configData.preloadEffects then
		preloadEffects = {}

		for i, effectId in ipairs(configData.preloadEffects) do
			preloadEffects[#preloadEffects + 1] = effectId
		end
	end

	return preloadEffects
end

function ClientPuppet:isFishingCaptureBoss()
	if not pg.me or not pg.me:isInFishingCapture() then
		return
	end

	local activityData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.FishingCapture)
	local phase = activityData and activityData:getCurPhase()

	if not phase or phase <= 0 then
		return
	end

	local config = FishingCaptureActivityData and FishingCaptureActivityData[phase]

	return config and config.bossStaticId == self.staticId
end

return ClientPuppet
