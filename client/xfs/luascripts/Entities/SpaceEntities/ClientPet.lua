-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientPet.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local MessageName = require("Const.MessageName")
local ClientPawnEntity = require("Entities.ClientPawnEntity")
local GlobalData = require("Core.Client.GlobalData")
local PetData = require("Data.pet_data")
local RealPetRobotData = require("Data.real_pet_robot_data")
local AbilityConst = require("Common.Const.AbilityConst")
local EventConst = require("Const.EventConst")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local ClientModelUtils = require("Utils.ClientModelUtils")
local CombatContext = require("Common.Ability.CombatContext")
local AudioConst = require("Const.AudioConst")
local AddressDataConst = require("Const.AddressDataConst")
local CombatActionTool = require("Common.Ability.CombatActionTool")
local SkillHitDisplacementControl = require("GameApp.Controller.Utils.SkillHitDisplacementControl")
local PetInfo = require("CustomTypes.PetInfo")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local SceneData = require("Data.scene_data")
local ClientUtils = require("Utils.ClientUtils")
local Utils = require("Common.Utils.Utils")
local Bitset = require("Common.Bitset")
local TriggerConst = require("Common.Const.TriggerConst")
local UIConst = require("Const.UIConst")
local TagMask = CS.FunPlus.WorldX.Animations.TagMask
local ToBool = ToBool
local ClientPet = class.Class("ClientPet", ClientPawnEntity)
local ClientAuthorityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAuthorityComponent")
local ClientAbilityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAbilityComponent")
local ClientTopLogoComponent = require("Entities.SpaceEntities.CommonComponent.ClientTopLogoComponent")
local AIComponent = require("Common.Components.AIComponent")
local AIPlanComponent = require("Common.Components.AIPlanComponent")
local AdditiveAIComponent = require("Common.Components.AdditiveAIComponent")
local AIPlanDynamicComponent = require("Common.Components.AIPlanDynamicComponent")
local PerceptibilityComponent = require("Common.Components.PerceptibilityComponent")
local AIGroupBehaviorComponent = require("Common.Components.AIGroupBehaviorComponent")
local ClientPetCombatEntityComponent = require("Entities.SpaceEntities.CommonComponent.ClientPetCombatEntityComponent")
local ClientSummonHostComponent = require("Entities.SpaceEntities.CommonComponent.ClientSummonHostComponent")
local ClientSummonedComponent = require("Entities.SpaceEntities.CommonComponent.ClientSummonedComponent")
local ClientTimeControlComponent = require("Entities.SpaceEntities.CommonComponent.ClientTimeControlComponent")
local ClientMotionComponent = require("Entities.SpaceEntities.CommonComponent.ClientMotionComponent")
local ClientInteractComponent = require("Entities.SpaceEntities.CommonComponent.ClientInteractComponent")
local ClientInteractionComponent = require("Entities.SpaceEntities.CommonComponent.ClientInteractionComponent")
local ClientBeCarryComponent = require("Entities.SpaceEntities.CommonComponent.ClientBeCarryComponent")
local ClientPetInfoComponent = require("Entities.SpaceEntities.CommonComponent.ClientPetInfoComponent")
local ClientLookAtComponent = require("Entities.SpaceEntities.CommonComponent.ClientLookAtComponent")
local ClientSimpleLookAtComponent = require("Entities.SpaceEntities.CommonComponent.ClientSimpleLookAtComponent")
local ClientMiniGameCommonComponent = require("Entities.SpaceEntities.CommonComponent.ClientMiniGameCommonComponent")
local ClientLiftComponent = require("Entities.SpaceEntities.CommonComponent.ClientLiftComponent")
local ClientEcologyComponent = require("Entities.SpaceEntities.CommonComponent.ClientEcologyComponent")
local ClientResPointComponent = require("Entities.SpaceEntities.CommonComponent.ClientResPointComponent")
local ClientRVOComponent = require("Entities.SpaceEntities.CommonComponent.ClientRVOComponent")
local ClientDynamicFeatureComponent = require("Entities.SpaceEntities.CommonComponent.ClientDynamicFeatureComponent")
local ClientAreaHandlerComponent = require("Entities.SpaceEntities.CommonComponent.ClientAreaHandlerComponent")
local ClientAttachComponent = require("Entities.SpaceEntities.CommonComponent.ClientAttachComponent")
local ClientPetAccessoryComponent = require("Entities.SpaceEntities.CommonComponent.ClientPetAccessoryComponent")
local ClientEntityCacheValComponent = require("Entities.SpaceEntities.CommonComponent.ClientEntityCacheValComponent")
local ClientTrapComponent = require("Entities.SpaceEntities.CommonComponent.ClientTrapComponent")
local ClientCallFriendsComponent = require("Entities.SpaceEntities.CommonComponent.ClientCallFriendsComponent")
local ClientModelTransmogComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelTransmogComponent")
local ClientTeamFollowComponent = require("Entities.SpaceEntities.CommonComponent.ClientTeamFollowComponent")
local ClientWaterStorageComponent = require("Entities.SpaceEntities.CommonComponent.ClientWaterStorageComponent")
local ClientEcsComponent = require("Entities.SpaceEntities.CommonComponent.ClientEcsComponent")
local AutoPathFindComponent = require("Common.Components.AutoPathFindComponent")
local CharacterController = require("Common.Components.CharacterController")
local ClientDyingComponent = require("Entities.SpaceEntities.CommonComponent.ClientDyingComponent")
local ClientVoxelComponent = require("Entities.SpaceEntities.CommonComponent.ClientVoxelComponent")
local ClientVehicleOpComponent = require("Entities.SpaceEntities.CommonComponent.ClientVehicleOpComponent")
local ClientStateCheckComponent = require("Entities.SpaceEntities.CommonComponent.ClientStateCheckComponent")
local PetComponents = {
	AutoPathFindComponent,
	CharacterController,
	ClientVoxelComponent,
	ClientStateCheckComponent,
	ClientDyingComponent,
	ClientVehicleOpComponent,
	ClientAuthorityComponent,
	ClientAbilityComponent,
	ClientTopLogoComponent,
	ClientPetCombatEntityComponent,
	ClientSummonHostComponent,
	ClientSummonedComponent,
	ClientTimeControlComponent,
	ClientMotionComponent,
	AIComponent,
	ClientInteractComponent,
	ClientInteractionComponent,
	ClientPetInfoComponent,
	AIPlanComponent,
	AdditiveAIComponent,
	AIPlanDynamicComponent,
	PerceptibilityComponent,
	ClientLookAtComponent,
	ClientSimpleLookAtComponent,
	ClientMiniGameCommonComponent,
	ClientLiftComponent,
	ClientEcologyComponent,
	ClientResPointComponent,
	ClientRVOComponent,
	AIGroupBehaviorComponent,
	ClientDynamicFeatureComponent,
	ClientAreaHandlerComponent,
	ClientAttachComponent,
	ClientPetAccessoryComponent,
	ClientBeCarryComponent,
	ClientEntityCacheValComponent,
	ClientTrapComponent,
	ClientCallFriendsComponent,
	ClientModelTransmogComponent,
	ClientTeamFollowComponent,
	ClientWaterStorageComponent,
	ClientEcsComponent
}

if EnableBotTest then
	local BotClientAbilityComponent = require("Bot.BotEntities.Components.BotClientAbilityComponent")
	local BotClientModelComponent = require("Bot.BotEntities.Components.BotClientModelComponent")

	PetComponents = {
		ClientStateCheckComponent,
		ClientAuthorityComponent,
		BotClientAbilityComponent,
		BotClientModelComponent,
		ClientTopLogoComponent,
		ClientPetCombatEntityComponent,
		ClientSummonHostComponent,
		ClientSummonedComponent,
		ClientTimeControlComponent,
		ClientMotionComponent,
		AIComponent,
		ClientInteractComponent,
		ClientPetInfoComponent,
		AIPlanComponent,
		AdditiveAIComponent,
		AIPlanDynamicComponent,
		ClientLookAtComponent,
		ClientMiniGameCommonComponent,
		ClientLiftComponent,
		ClientEcologyComponent,
		ClientResPointComponent,
		ClientRVOComponent,
		AIGroupBehaviorComponent,
		ClientDynamicFeatureComponent,
		ClientAreaHandlerComponent,
		ClientPetAccessoryComponent,
		ClientTeamFollowComponent
	}
end

class.AddComponents(ClientPet, PetComponents)

function ClientPet:ctor(entityId)
	ClientPet.super.ctor(self, entityId)

	self.actorType = Const.ACTOR_TYPE_PET
	self.isMainPet = false
	self.skillHitDisplacementCtrl = SkillHitDisplacementControl(self)
	self.hpPercentLast = 0
	self.hpPercentTsMap = {}
	self.isClientEnt = false
end

function ClientPet:init(bdict)
	ClientPet.super.init(self, bdict)

	if bdict.masterId ~= nil then
		self.masterId = bdict.masterId

		if self.masterId == pg.me.id then
			self.isMainPet = true
		end

		local master = pg.getEntity(bdict.masterId)

		if master ~= nil then
			self:setMaster(master)

			if bdict.summonHostActorId or self:isExtraTempPet() then
				self.petInfo = PetInfo(bdict.petInfo)
			else
				self.petInfo = master.pets and master:getPetInfo(self.id) or bdict.petInfo and PetInfo(bdict.petInfo)
			end
		end
	end

	if bdict.masterActorId ~= nil then
		self.masterActorId = bdict.masterActorId
	end

	local pdd = self:getConfigData()

	if pdd ~= nil and pdd.bTree then
		self:setBtName(pdd.bTree)
	elseif LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("pot@ClientPet:init, bTree not exist!")
	end

	self.forbiddenTopLogo = false
	self.flyEndSkill = pdd.flyEndSkill
	self.isMonsterAbilityMode = bdict.isMonsterAbilityMode
	self.bodyMass = pdd.mass
	self.bodyWeight = pdd.weight
	self.playerName = bdict.playerName or ""
	self.topLogoType = ClientConst.TopLogoType.Pet
	self.hungryState = Const.PET_HUNGRY_STATE.FirstHungry
	self.showPetExtraData = bdict.showPetExtraData

	return true
end

function ClientPet:tick(deltaTime)
	self:postComponentMethod("tick", deltaTime)
end

function ClientPet:getAppearDashFadeTime()
	return AbilitySettingGlobalConstData.appearDashFadeTime
end

function ClientPet:getName()
	if not string.isNilOrEmpty(self.customName) then
		return self.customName
	end

	return pg.getLocalizationText(self:getConfigData().name)
end

function ClientPet:initializeComponents()
	ClientPet.super.initializeComponents(self)

	if self.eModel then
		self:addEModelComponent(Const.COMPONENT_INDEX_IK)
		self:addEModelComponent(Const.COMPONENT_MOTION)

		if self.authority == Const.AUTHORITY_MASTER then
			self:addEModelComponent(Const.COMPONENT_AI_CONTROLLER)
			self:addEModelComponent(Const.COMPONENT_AUTO_PATH_FIND)
			self:addEModelComponent(Const.COMPONENT_FOLLOW_OTHER)
		end
	end
end

function ClientPet:postInitializeComponents()
	ClientPet.super.postInitializeComponents(self)

	if self.authority == Const.AUTHORITY_MASTER then
		AIControllerUtils.setUseKCCMove(self, true, Const.KccControlType.PetControl)
		self:addEModelComponent(Const.COMPONENT_INDEX_FOLLOW)
		self:refreshFollowState()
	end

	self:applyMotionProp()
end

function ClientPet:onEnterSpace()
	ClientPet.super.onEnterSpace(self)

	if SceneData[self.space.sceneId].enableCreateShadowEntity then
		local ent = ClientUtils.createShadow(self, SceneData[self.space.sceneId].shadowEntityOffset)

		if not self.isSummon and ent.eModel then
			ent.eModel:SetActive(false)
		end
	end

	if self.isMainPet then
		local masterEnt = self:getMasterEntity()

		if masterEnt and masterEnt.onPetReady then
			masterEnt:onPetReady(self)
		end
	end

	self:refreshHpPercentTsMap()

	if self.isMainPet then
		facade:sendMsgToUI(MessageName.MAIN_PET_ENTER_SPACE, self)
		facade:SendMessageCommand(MessageName.PET_CHANGE_REFRESH, {
			isPet = true,
			ent = self
		})
	end

	if self.space:isBossRushEnv() and Utils.isBotPet(self) then
		self:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)
	end
end

function ClientPet:onLeaveSpace()
	ClientPet.super.onLeaveSpace(self)

	if self.virtualShadowEntity then
		ClientUtils.destoryShadow(self)
	end

	if self.isMainPet then
		facade:SendMessageCommand(MessageName.MAIN_PET_LEAVE_SPACE, {
			isPet = true,
			ent = self
		})
	end
end

function ClientPet:beAttached()
	ClientPet.super.beAttached(self)

	if self.isMainPet and self:checkPetInControl() then
		local attachToEntity = pg.getEntity(self.attachTargetEntId)

		if attachToEntity then
			pg.game.camera:setTargetPlayer(attachToEntity, 0)
		end
	end
end

function ClientPet:beDetached()
	ClientPet.super.beDetached(self)

	if self.isMainPet and self:checkPetInControl() then
		pg.game.camera:setTargetPlayer(self, 0)
	end
end

function ClientPet:onActiveChange()
	ClientPet.super.onActiveChange(self)

	if self.virtualShadowEntity and self.virtualShadowEntity.eModel then
		self.virtualShadowEntity:setActive(ClientConst.MODEL_VISIBLE_KEY.SHADOW, self.active)
	end
end

function ClientPet:refreshVisible()
	self:refreshSummonVisible()
	self:refreshSpaceHidePetVisible()
	self:refreshBasePetVisible()
	self:refreshUISceneVisible()
	ClientPet.super.refreshVisible(self)
end

function ClientPet:setModelLayer()
	if self.eModel then
		self.eModel:SetModelLayer(Utils.isBotPet(self) and ClientConst.LayerDefine.LAYER_ENTITY or ClientConst.LayerDefine.LAYER_PET)
	end
end

function ClientPet:onModelRefreshed()
	if self.master == GlobalData.Player then
		local collider = self.eModel:GetCollider(Const.COMPONENT_IDX_PHYSX)

		if collider then
			self.master.eModel:AddIgnoreCollider(Const.COMPONENT_MOTION, collider)
		end

		collider = self.master.eModel:GetCollider(Const.COMPONENT_IDX_PHYSX)

		if collider then
			self.eModel:AddIgnoreCollider(Const.COMPONENT_MOTION, collider)
		end
	end

	self:setNightShine()
	self:setShinyStyle()
	ClientPet.super.onModelRefreshed(self)

	if self.attachTargetId then
		local target = pg.getEntity(self.attachTargetId)

		if target and target.carryEnt ~= self then
			target:carryEntImp(self)
		end
	end
end

function ClientPet:refreshAppearance(forceRefreshPlayable)
	local master = Utils.isBotPet(self) and self:getMasterEntity()
	local configData = self:getConfigData()

	if not master or not master.isDungeonBot or string.isNilOrEmpty(configData.prefabResID) then
		ClientPet.super.refreshAppearance(self, forceRefreshPlayable)

		return
	end

	if not self.eModel then
		return
	end

	self:setModelLayer()
	self.eModel:SetClientReady(true)

	local modelView = self.eModel.modelModelView
	local modelInfo = modelView.modelInfo

	modelInfo:ClearInfo()

	modelInfo.height = configData.topbarHeight or configData.modelHeight or 1.5
	modelInfo.physiqueModelInfo.modelPathID = configData.prefabResID or ""
	modelInfo.physiqueModelInfo.modelInfoPathID = ""
	modelInfo.physiqueModelInfo.animControllerAssetID = ClientModelUtils.getAnimController(configData)
	modelInfo.physiqueModelInfo.modelScale = configData.modelScale or 1
	modelInfo.physiqueModelInfo.modelNeedBones = false
	modelInfo.physiqueModelInfo.isAlwaysAnimate = true

	self.eModel:AddShadowComp(ClientConst.ShadowPriority.Appearance)
	ClientModelUtils.refreshModels(self, modelView)
end

function ClientPet:refreshModel(configData, extraData)
	local modelView = self.eModel.modelModelView

	ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraData)
	self:postComponentMethod("Event_BeforeRefreshModels", modelView)
	ClientModelUtils.refreshModels(self, modelView)
	self:postComponentMethod("Event_AfterRefreshModels", modelView)
end

function ClientPet:getCanAttachEffs()
	return not self:hideTitleAndEffs()
end

function ClientPet:getModelExtraData(configData)
	local extraData = ClientPet.super.getModelExtraData(self, configData, self.petInfo)

	if extraData and PetTransmogUtils.isTemplateTransmogable(self.templateId) then
		local noShinyLabel = bit.band(self:getLabel() or 0, bit.bnot(Const.PET_LABEL_MASK.SHINY))

		extraData.prefabResID = ClientModelUtils.getModelPrefabResId(configData, noShinyLabel, self:getGender() or 0)
	end

	return extraData
end

function ClientPet:destroy()
	local masterEnt = self:getMasterEntity()

	if masterEnt then
		masterEnt:onPetDestroy(self)
	end

	self.master = nil

	ClientUtils.destoryShadow(self)

	if self:isExtraTempPet() then
		pg.me:cancelAbility()
	end

	ClientPet.super.destroy(self)
end

function ClientPet:getPetHeight()
	return self.height
end

function ClientPet:setMaster(player)
	local oldMaster = self.master

	self.masterId = player.id
	self.masterActorId = player.actorId
	self.master = player

	if oldMaster ~= player then
		self:postComponentMethod("EVENT_PerceptibilitySearchEntityChanged")
	end
end

function ClientPet:getMasterEntity()
	return self.master or pg.getEntity(self.masterId)
end

function ClientPet:start()
	ClientPet.super.start(self)

	if FREE_WALK then
		return
	end

	self:setSoundRTPCValue(AudioConst.RTPC_PAMON_MOVEMENT, 0)
	self:setSoundRTPCValue(AudioConst.RTPC_VOLUME_3P, 0)
	self:setSoundRTPCValue(AudioConst.RTPC_FOOTSTEP_QIANGDAN, 0)

	local masterEnt = self:getMasterEntity()

	if masterEnt then
		masterEnt:onPetStart(self)
	end

	if self.isMainPet == true then
		self:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)
	end
end

function ClientPet:repr()
	return string.format("ClientPet(entityId=%s, uid=%d)", self.id, self.uid or 0)
end

function ClientPet:refreshSceneFootStepVolumeRTPC()
	local sceneInfo = self.space and SceneData[self.space.sceneId]
	local footStepVolume = sceneInfo and sceneInfo.footStepVolume

	self:setSoundRTPCValue(AudioConst.RTPC_FOOTSTEP_QIANGDAN, footStepVolume and footStepVolume[1] or 0)
end

function ClientPet:canBeLocked()
	return true
end

function ClientPet:onBeControlled(oldEnt)
	if self.showPetExtraData and self.showPetExtraData.isShowAppearDash then
		local masterEntity = self:getMasterEntity()

		pg.game.controller:forceSaveControllerState(false, CharacterStateConst.APPEARDASH, masterEntity.lastPetInfo.animation, masterEntity.lastPetInfo.time)
	end

	self:calcAndRefreshModelScale()
	self:refreshVisible()
	self:setSoundRTPCValue(AudioConst.RTPC_PAMON_MOVEMENT, 1)

	if self.isMainPet then
		self:setSoundRTPCValue(AudioConst.RTPC_VOLUME_3P, 1)
	end

	self:refreshSceneFootStepVolumeRTPC()

	if Utils.isPlayer(oldEnt) then
		self.master:forceExitCaptureMode()
	end

	self.master:refreshGhostEyeBuff()
	ClientPawnEntity.onBeControlled(self, oldEnt)
	self.subject:notify(AbilityConst.COMBAT_EVENT_ON_PET_ENTER_CONTROL)
end

function ClientPet:getCsEntityType()
	if self.master == GlobalData.Player then
		return ClientConst.ENTITY_CS_TYPE.MAIN_PET
	end

	return ClientConst.ENTITY_CS_TYPE.PET
end

function ClientPet:onLoseControlled()
	self:calcAndRefreshModelScale()
	self:refreshVisible()
	self:setSoundRTPCValue(AudioConst.RTPC_PAMON_MOVEMENT, 0)
	self:setSoundRTPCValue(AudioConst.RTPC_VOLUME_3P, 0)
	self:setSoundRTPCValue(AudioConst.RTPC_FOOTSTEP_QIANGDAN, 0)
	self.master:forceExitGhostEyeState()
	ClientPawnEntity.onLoseControlled(self)
	self.subject:notify(AbilityConst.COMBAT_EVENT_ON_PET_LEAVE_CONTROL)
	self:resetControlledMotionProp()
end

function ClientPet:onDeformed()
	ClientPet.super.onDeformed(self)
	self:calcAndRefreshModelScale(true)
end

function ClientPet:checkSummon()
	if self.isMainPet then
		if pg.me.clientExploreEntId then
			return self.id == pg.me.clientExploreEntId
		end

		if pg.me.clientExploreCancelEntId then
			return self.id == pg.me.clientExploreCancelEntId
		end
	end

	return self.isSummon
end

function ClientPet:checkPetInControl()
	if self.isMainPet and (pg.me.clientExploreEntId or pg.me.clientExploreCancelEntId) then
		return pg.pawn == self
	end

	return self.isInControl
end

function ClientPet:isPetActiveForCombat()
	if self.master and self.master.curCombatPetId == self.id then
		return true
	end

	return false
end

function ClientPet:refreshVisibleByMasterExploreState()
	if EnableBotTest then
		return
	end

	local masterEnt = self:getMasterEntity()
	local visible = false

	if masterEnt and not masterEnt:checkInBlockCurPetState() then
		visible = true
	end

	self:setVisibleWithDissolveEffect(ClientConst.MODEL_VISIBLE_KEY.MATER_EXPLORE_STATE, 0.5, visible)
end

function ClientPet:checkExploreVisible()
	local masterEnt = self:getMasterEntity()

	if masterEnt and not masterEnt:checkCurPetVisible() then
		return false
	end

	return true
end

function ClientPet:refreshSummonVisible()
	self:setActive(ClientConst.MODEL_VISIBLE_KEY.SUMMON, self:checkSummon())
end

function ClientPet:refreshSpaceHidePetVisible()
	local active = true

	if not self.isMainPet and self.space and self.space:checkHidePet() then
		active = false
	end

	self:setActive(ClientConst.MODEL_VISIBLE_KEY.SPACE_HIDE_PET, active)
end

function ClientPet:refreshUISceneVisible()
	local active = true

	if pg.game.uiScene and pg.game.uiScene:checkNeedPawnHide() then
		active = false
	end

	self:setActive(ClientConst.MODEL_VISIBLE_KEY.UIScene, active)
end

function ClientPet:refreshBasePetVisible()
	local masterEnt = self:getMasterEntity()
	local baseVisible = true

	if masterEnt then
		baseVisible = masterEnt:checkCurPetVisible()
	end

	baseVisible = baseVisible and pg.game:getPetVisible(self)

	self:setActive(ClientConst.MODEL_VISIBLE_KEY.BASE_PET, baseVisible)
end

function ClientPet:queryModelVisible()
	local masterEnt = self:getMasterEntity()

	if masterEnt ~= pg.me and Bitset.any(ClientConst.PET_VISIBLE_FLAG) then
		return true, false
	end

	return ClientPet.super.queryModelVisible(self)
end

function ClientPet:on_maxHp_changed(oldv, newv)
	if self.isMainPet or self.isExplorePet then
		facade:SendMessageCommand(MessageName.PET_HP_CHANGE, self.partnerIndex, oldv, newv)
	else
		facade:SendMessageCommand(MessageName.TEAM_PET_MAX_HP_CHANGED, {
			uid = self.master and self.master.uid
		})
	end

	self:refreshHpPercentTsMap()
end

function ClientPet:on_curHp_changed(oldv, newv)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientPet:on_curHp_changed>> " .. newv .. "MaxHp>> " .. self.maxHp)
	end

	facade:SendMessageCommand(MessageName.HEALTH_POINT_CHANGE, self)
	facade:SendMessageCommand(MessageName.HEALTH_POINT_CHANGE_ALTER, {
		entity = self,
		oldValue = oldv,
		newValue = newv
	})
	self.eventEmitter:emit(EventConst.TOPLOGO_HEALTH_POINT, oldv, newv)

	if self.isMainPet or self.isExplorePet then
		facade:SendMessageCommand(MessageName.PET_HP_CHANGE, self.partnerIndex, oldv, newv)
	else
		facade:SendMessageCommand(MessageName.TEAM_PET_HP_CHANGED, {
			uid = self.master and self.master.uid
		})
	end

	self:refreshHpPercentTsMap()
end

function ClientPet:applyTransmogScheme(scheme, force)
	if not PetTransmogUtils.isTemplateTransmogable(self.templateId) then
		self:setTransmogData(nil, nil, "empty", force)

		return
	end

	local effective = scheme or self.selectTransmogScheme or PetTransmogUtils.getSelectedScheme(self.petInfo)
	local signature = PetTransmogUtils.getSchemeModelCacheKey(self.templateId, effective)
	local transmogData, shinyEffects = PetTransmogUtils.getSchemeTransmogData(self.templateId, effective)

	self:setTransmogData(transmogData, shinyEffects, signature, force, effective)
end

function ClientPet:on_isSummon_changed(oldv, newv)
	if newv == false then
		self:getMasterEntity():recordLastPetInfo(self.id)
		self:cancelAbility()
	end

	self:refreshSummonVisible()
	self:refreshFollowState()

	if self.updateStateCache then
		self:updateStateCache("NOT_SUMMON_ST")
	end
end

function ClientPet:refreshFollowState()
	if self.refreshPosSyncState then
		self.entityCanMove = self.isSummon

		self:refreshPosSyncState()
	end

	if not self:hasEModelComponent(Const.COMPONENT_INDEX_FOLLOW) then
		return
	end

	self.eModel.followEntity = self:getMasterEntity().eModel
	self.eModel.enableFollow = not self.isSummon
end

function ClientPet:RPC_SC_TestFunc(number)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_TestFunc %s", number)
	end
end

function ClientPet:RPC_SC_BeforePetChangeTemplate(reason)
	self:postComponentMethod("beforePetChangeTemplate", reason)
end

function ClientPet:RPC_SC_AfterPetChangeTemplate(reason)
	self:onTemplateIdChange()
	self:postComponentMethod("afterPetChangeTemplate", reason)
end

function ClientPet:onTemplateIdChange()
	self:onConfigDataChange()

	if self.isMainPet then
		facade:SendMessageCommand(MessageName.PLAYER_CUR_SKILL_MAP, {
			self
		})
	end
end

function ClientPet:getBattlePetInfo()
	if self.inShapeShift then
		return self.shapeShiftPetInfo
	else
		return self.petInfo
	end
end

function ClientPet:getSkillIdByType(abilityType)
	local petInfo = self:getBattlePetInfo()

	if not petInfo then
		return 0
	end

	if abilityType == AbilityConst.EXPLORE_ABILITY then
		return petInfo.exploreAbilityList and petInfo.exploreAbilityList[1] or 0
	elseif abilityType == AbilityConst.EXPLORE_ABILITY2 then
		return petInfo.exploreAbilityList and petInfo.exploreAbilityList[2] or 0
	end

	if not petInfo.curAbilityMap then
		return 0
	end

	local skillData = petInfo.curAbilityMap[abilityType] or {}
	local skillId = skillData.abilityId or 0

	return skillId
end

function ClientPet:getCarrySkillMap(excludeUltimate)
	local carrySkillMap = {}
	local carrySkillId1, carrySkillId2 = self:getSkillIdByType(AbilityConst.WEAPON_SKILL_ABILITY), self:getSkillIdByType(AbilityConst.WEAPON_SKILL_ABILITY2)

	carrySkillMap[carrySkillId1] = self:getAbility(carrySkillId1)
	carrySkillMap[carrySkillId2] = self:getAbility(carrySkillId2)

	if not excludeUltimate then
		local carryUltimateId = self:getSkillIdByType(AbilityConst.ULTIMATE_ABILITY)

		carrySkillMap[carryUltimateId] = self:getAbility(carryUltimateId)
	end

	return carrySkillMap
end

function ClientPet:getSkillByType(abilityType)
	local petInfo = self:getBattlePetInfo()

	if not petInfo or not petInfo.curAbilityMap then
		return {}
	end

	local skillData = petInfo.curAbilityMap[abilityType] or {}

	return skillData
end

function ClientPet:getRealSkillIdBySkillType(skillType)
	local petInfo = self:getBattlePetInfo()
	local skillInfo = petInfo.curAbilityMap[skillType]
	local skillId = skillInfo and skillInfo.abilityId or 0

	if ToBool(self.switchSkillData[skillId]) then
		skillId = self.switchSkillData[skillId]
	end

	return skillId
end

local emptyTable = {}

function ClientPet:getTemplateData()
	if Utils.isBotPet(self) then
		return self.botTemplateId and RealPetRobotData[self.botTemplateId] or emptyTable
	end

	if self.inShapeShift then
		return PetData[self.shapeShiftTemplateId] or emptyTable
	end

	return PetData[self.templateId] or emptyTable
end

function ClientPet:quickCapture(entId)
	if not entId then
		return false
	end

	if not ClientCaptureUtils.hasBall(true) then
		return false
	end

	self.master.quickCaptureAfterControlled = entId
	self.master.captureSwitchFlag = true

	if pg.me:requestSwitchToPlayer(Const.CLIENT_SWITCH_REASON.Catch) then
		if not pg.game.controller:isInControlMainPlayer() then
			self.master.enterCaptureModeFromPet = true
			self.master.captureSwitchFlag = true
		end

		return true
	end

	self.master.quickCaptureAfterControlled = nil
	self.master.captureSwitchFlag = false

	pg.global.showBubbleMessageRaw(pg.getGameString("CANT_CATCH"))

	return false
end

function ClientPet:toggleCatchMode()
	local itemId = ClientCaptureUtils.getEnterCatchModeItemId()

	if not ClientCaptureUtils.hasBall(true, itemId) then
		return false
	end

	if not self:checkEnterCatchMode() then
		return false
	end

	local master = self:getMasterEntity()

	master.enterCaptureModeFromPet = true
	master.captureSwitchFlag = true

	if not master:requestSwitchToPlayer(Const.CLIENT_SWITCH_REASON.Catch) then
		master.enterCaptureModeFromPet = false
		master.captureSwitchFlag = false

		return false
	end

	if not pg.game.controller:isInControlMainPlayer() then
		master.enterCaptureModeFromPet = true
		master.captureSwitchFlag = true
	end

	return true
end

function ClientPet:getEModelResId()
	return AddressDataConst.Ent_Pet
end

function ClientPet:PRC_SC_SetPetPos(pos, rot)
	self:forceSetPosRot(Vector3.Clone(pos), Quaternion.Clone(rot), false, true)
end

function ClientPet:onIsInControlChange(old, new)
	self:calcAndRefreshModelScale()
	self:postComponentMethod("EVENT_IsInControlChange")
end

function ClientPet:on_level_changed(oldv, newv)
	if ClientUtils.isInPetPrepareList(self) then
		ClientUtils.updateMaxPreparedPetLevel(self.master)
	end

	self:executeTopLogoComponentMethod(UIConst.TOPLOGO_COMPONENT.COMBAT, "refreshLevelAndThreatState")
end

function ClientPet:canBeLookAt()
	return self.isSummon and self:getConfigData().canBeLookAt
end

function ClientPet:onTimePeriodChange()
	self:setNightShine()
end

function ClientPet:canGlide()
	return AIControllerUtils.checkCanGlide(self)
end

function ClientPet:needLimitCount()
	return not self.isMainPet
end

function ClientPet:refreshHpPercentTsMap()
	if not self.isBattlePet then
		return
	end

	local curPercent = math.ceil(self.actorCombatAttribute:getHpPercent())

	if self.hpPercentLast == curPercent then
		return
	end

	for i = 1, 100 do
		self.hpPercentTsMap[i] = curPercent <= i and Time.realSecondCache or nil
	end

	if self.isMainPet then
		if curPercent < self.hpPercentLast then
			pg.me:tryClientTriggerAll(TriggerConst.TRIGGER_TARGET_PET_HP_LE_PERCENT, 1, {
				curPercent,
				pg.me.curCombatPetId == self.id
			})
		elseif curPercent > self.hpPercentLast then
			pg.me:tryClientTriggerAll(TriggerConst.TRIGGER_TARGET_PET_HP_GE_PERCENT, 1, {
				curPercent,
				pg.me.curCombatPetId == self.id
			})
		end
	end

	self.hpPercentLast = curPercent

	if self.isMainPet then
		pg.me:tryClientTriggerAll(TriggerConst.TRIGGER_TARGET_PET_HP_PERCENT_TIME)
		pg.me:tryClientTriggerAll(TriggerConst.TRIGGER_TARGET_PET_HP_PERCENT)
	end
end

function ClientPet:isExtraTempPet()
	return ToBool(self:getConfigData().isExtraTempPet)
end

function ClientPet:getPreloadEffects()
	if self.isMainPet then
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

	return nil
end

function ClientPet:RPC_SC_ListenShapeShiftModelRefreshed(dynamicInfo)
	local combatContext = CombatContext.convert(self, dynamicInfo)

	if not combatContext then
		return
	end

	local actionData = combatContext.nodeMap[combatContext.nodeStack[#combatContext.nodeStack]]

	if not actionData.afterModelRefreshedActionIds then
		return
	end

	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if abilityObject then
		abilityObject:getObserver():listen(abilityObject.owner.subject, AbilityConst.COMBAT_EVENT_ON_SHAPE_SHIFT_MODEL_REFRESHED, function()
			self:stopAnimationByTag(TagMask.Skill)
			self.combatAction:doActionIds(actionData.afterModelRefreshedActionIds, combatContext)
		end)
	end
end

function ClientPet:onShapeShiftChange(old, new)
	self:updateStateCache("SHAPE_SHIFT_ST")
end

function ClientPet:onShinyStyleChange(ov, nv)
	self:refreshParmonDye()
end

return ClientPet
