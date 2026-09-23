-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientEnvObject.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ClientModelEntity = require("Entities.ClientModelEntity")
local ClientConst = require("Const.ClientConst")
local AddressDataConst = require("Const.AddressDataConst")
local InteractData = require("Data.interact_data")
local Const = require("Common.Const.Const")
local InteractionConst = require("Common.Const.InteractionConst")
local ConflictTypes = require("Common.ConflictTypes")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local EnvObjData = require("Data.envobj_data")
local SceneUtils = require("Common.Utils.SceneUtils")
local Utils = require("Common.Utils.Utils")
local ClientActorComponent = require("Entities.SpaceEntities.CommonComponent.ClientActorComponent")
local ecs_editor_export_chem_material_data = require("Data.ecs_editor_export_chem_material_data")
local ecs_module_data = require("Data.ecs_module_data")
local Time = require("Core.Common.Time")
local EventBus = require("Common.Ability.Buff.EventBus")
local NoticeDef = require("Common.NoticeDef")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientEnvObject = Class.Class("ClientEnvObject", ClientModelEntity)
local ClientEffectComponent = require("Entities.SpaceEntities.PlayerComponent.ClientEffectComponent")
local ClientAuthorityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAuthorityComponent")
local ClientInteractionComponent = require("Entities.SpaceEntities.CommonComponent.ClientInteractionComponent")
local ClientLiftComponent = require("Entities.SpaceEntities.CommonComponent.ClientLiftComponent")
local ClientAttachComponent = require("Entities.SpaceEntities.CommonComponent.ClientAttachComponent")
local ClientPhysicsComponent = require("Entities.SpaceEntities.CommonComponent.ClientPhysicsComponent")
local AbilityConst = require("Common.Const.AbilityConst")
local PerceptibilityResponseComponent = require("Common.Components.PerceptibilityResponseComponent")
local ClientTopLogoComponent = require("Entities.SpaceEntities.CommonComponent.ClientTopLogoComponent")
local ClientAnimatorComponent = require("Entities.SpaceEntities.CommonComponent.ClientAnimatorComponent")
local ClientCustomEventComponent = require("Entities.SpaceEntities.DynamicComponent.ClientCustomEventComponent")
local ClientEcologyComponent = require("Entities.SpaceEntities.CommonComponent.ClientEcologyComponent")
local ClientResPointComponent = require("Entities.SpaceEntities.CommonComponent.ClientResPointComponent")
local ClientAudioComponent = require("Entities.SpaceEntities.CommonComponent.ClientAudioComponent")
local ClientDynamicFeatureComponent = require("Entities.SpaceEntities.CommonComponent.ClientDynamicFeatureComponent")
local ClientVoxelComponent = require("Entities.SpaceEntities.CommonComponent.ClientVoxelComponent")
local ClientRVOComponent = require("Entities.SpaceEntities.CommonComponent.ClientRVOComponent")
local ClientGhostEyeDetectedComponent = require("Entities.SpaceEntities.PlayerComponent.ClientGhostEyeDetectedComponent")
local ClientMagneticComponent = require("Entities.SpaceEntities.CommonComponent.ClientMagneticComponent")
local ClientVehicleOpComponent = require("Entities.SpaceEntities.CommonComponent.ClientVehicleOpComponent")
local ClientModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelComponent")
local ClientPrefabModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientPrefabModelComponent")
local ClientEcsComponent = require("Entities.SpaceEntities.CommonComponent.ClientEcsComponent")
local ClientEnvObjectComponents = {
	ClientActorComponent,
	ClientAuthorityComponent,
	ClientEffectComponent,
	ClientAnimatorComponent,
	ClientInteractionComponent,
	PerceptibilityResponseComponent,
	ClientPhysicsComponent,
	ClientAttachComponent,
	ClientTopLogoComponent,
	ClientCustomEventComponent,
	ClientLiftComponent,
	ClientEcologyComponent,
	ClientResPointComponent,
	ClientAudioComponent,
	ClientVoxelComponent,
	ClientDynamicFeatureComponent,
	ClientRVOComponent,
	ClientGhostEyeDetectedComponent,
	ClientMagneticComponent,
	ClientVehicleOpComponent,
	ClientModelComponent,
	ClientPrefabModelComponent,
	ClientEcsComponent
}

if EnableBotTest then
	ClientEnvObjectComponents = {
		ClientActorComponent
	}
end

Class.AddComponents(ClientEnvObject, ClientEnvObjectComponents)

function ClientEnvObject:ctor(entityId)
	ClientEnvObject.super.ctor(self, entityId)

	self.actorType = Const.ACTOR_TYPE_ENVOBJ
	self.createTime = Time.realSecondCache
	self.combatAction = pg.global.abilityMgr.combatAction
	self.subject = EventBus.EventSubject(self.actorId)
	self.lastChemSkillHitActorId = 0
	self.throwPlayer = nil
end

function ClientEnvObject:preInit(bdict)
	ClientEnvObject.super.preInit(self, bdict)
end

function ClientEnvObject:init(bdict)
	ClientEnvObject.super.init(self, bdict)

	self.envId = bdict.envId
	self.envData = bdict.envData

	local configData = self:getConfigData()

	self.isLockAsPuppet = configData.isLockAsPuppet
	self.topLogoType = ClientConst.TopLogoType.EnvObj
	self.entityCanMove = configData.nonKinematic and true or false

	if self.entityCanMove then
		self.isClientEnt = false
	end

	return true
end

function ClientEnvObject:getConfigData()
	return EnvObjData[self.templateId] or {}
end

function ClientEnvObject:postInit(bdict)
	local config = self:getConfigData()

	if config.BodySize then
		self.bodySize = config.BodySize
		self.bodyHeight = config.BodyHeight

		self.aoi:setHitBoxParam(AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D, 3, {
			self.bodySize,
			self.bodyHeight,
			0
		})
	end

	self.forbiddenTopLogo = not ToBool(config.isShowTopLogo)

	if self.forbiddenTopLogo and config.callFriend and self.camp ~= nil then
		self.forbiddenTopLogo = false
	end

	ClientEnvObject.super.postInit(self, bdict)
end

function ClientEnvObject:start()
	ClientEnvObject.super.start(self)
	self:initEnvObj()
	self:initFeatureByData()
end

function ClientEnvObject:initFeatureByData()
	return
end

function ClientEnvObject:preDestroy()
	local configData = self:getConfigData()

	for _, key in ipairs(configData.effBeforeInteract or EMPTY_TABLE) do
		self:stopEffect(key)
	end

	for _, key in ipairs(configData.effAfterInteract or EMPTY_TABLE) do
		self:stopEffect(key)
	end

	self:playDestroyEffect()
	ClientEnvObject.super.preDestroy(self)
end

function ClientEnvObject:destroy()
	if self.throwPlayer == pg.me then
		pg.me:forceExitCaptureMode()
	end

	self.pushComponent = nil

	ClientEnvObject.super.destroy(self)
end

function ClientEnvObject:onEnterSpace()
	ClientEnvObject.super.onEnterSpace(self)
	self:refreshEnvObjScale()
end

function ClientEnvObject:getGlobalId()
	return self.envId
end

function ClientEnvObject:getChunkKey()
	local position = self:getPosition()
	local chunkKey, tileX, tileZ = Utils.getSpaceTile(self.sceneId, position.x, position.z)

	return chunkKey
end

function ClientEnvObject:getCsEntityType()
	return ClientConst.ENTITY_CS_TYPE.ENV_OBJ
end

function ClientEnvObject:needLimitCount()
	return true
end

function ClientEnvObject:getEModelResId()
	return AddressDataConst.Ent_EnvObj
end

function ClientEnvObject:getDetectionMode()
	return self:getConfigData().detectionMode
end

function ClientEnvObject:onPrefabModelLoaded()
	self:refreshChestOpened()
	self:setNightShine()
	self:setEnvObjDecalLayer()
	self:refreshEnvObjScale()
	self:onModelRefreshed()
	self:refreshEnvObjAttachEffects()
end

function ClientEnvObject:isConfigKinematic()
	local configData = self:getConfigData()

	return not configData.nonKinematic
end

function ClientEnvObject:refreshEnvObjScale()
	if not self.space or not self.isModelLoaded then
		return
	end

	local scale = self:getConfigData().envobjectScale or 0

	if self.staticId and self.staticId ~= 0 then
		local sceneEntityData = SceneUtils.getSceneEntityData(self.space.sceneId, self.space.id)
		local tEntityData = sceneEntityData[self.staticId] or {}
		local sceneScale = tEntityData.envobjectScale or 0

		if sceneScale ~= 0 then
			scale = sceneScale
		end

		if tEntityData.fixedScale and tEntityData.fixedScale ~= 0 then
			scale = tEntityData.fixedScale
		end
	end

	if scale ~= 0 then
		if self.eModel == nil then
			return
		end

		self:setScaleNumber(scale)
	end
end

function ClientEnvObject:refreshEnvObjAttachEffects()
	local configData = self:getConfigData()
	local attachEffects = ClientModelUtils.getEnvObjectAttachEffects(configData)

	self:attachBaseEffects(attachEffects)
end

function ClientEnvObject:postInitializeComponents()
	ClientEnvObject.super.postInitializeComponents(self)
end

function ClientEnvObject:initEnvObj()
	self:applyEnvData(self.envData)
	self:initInteraction()

	local configData = self:getConfigData()

	if self.eModel == nil then
		return
	end

	self:loadPrefabModel(configData.prefabResID or "")
	self.eModel:SetEnvId(self.envId)

	if configData.effBeforeInteract then
		for _, key in ipairs(configData.effBeforeInteract) do
			self:stopEffect(key)
		end

		for _, key in ipairs(configData.effBeforeInteract) do
			self:playEffect(key)
		end
	end
end

function ClientEnvObject:isSceneObject()
	return self.staticId and self.staticId ~= 0
end

function ClientEnvObject:refreshVisible()
	self:refreshEnvDestroyVisible()
	ClientEnvObject.super.refreshVisible(self)
end

function ClientEnvObject:refreshEnvDestroyVisible()
	if self.isDestroying then
		self:setActive(ClientConst.MODEL_VISIBLE_KEY.DESTROYED, false)
	else
		self:setActive(ClientConst.MODEL_VISIBLE_KEY.DESTROYED, true)
	end
end

function ClientEnvObject:breakDestroy(reason, delay)
	self:setVisible(ClientConst.MODEL_VISIBLE_KEY.DESTROYING, false, false)
	pg.game.envObj:destroyEnvObject(self, delay or 0, reason)
end

function ClientEnvObject:destroyEntity(reason, delay)
	self:setVisible(ClientConst.MODEL_VISIBLE_KEY.DESTROYING, true, false)
	pg.game.envObj:destroyEnvObject(self, delay or 0, reason)
end

function ClientEnvObject:destroyEntityByAI(delaySecond)
	if EnvObjData[self.templateId].canDestroyByAI == 1 then
		pg.game.envObj:destroyEnvObject(self, delaySecond)

		return true
	end

	return false
end

function ClientEnvObject:on_isDestroying_changed(oldVal, newVal)
	self:refreshEnvDestroyVisible()
end

function ClientEnvObject:applyEnvData(envData)
	self.envData = envData
end

function ClientEnvObject:_canCurrentPawnLiftByPetTemplateLimit()
	local liftPetTemplateIds = self.envData and self.envData.liftPetTemplateIds

	if type(liftPetTemplateIds) ~= "table" then
		return true
	end

	local hasLimit = false

	for _, _ in pairs(liftPetTemplateIds) do
		hasLimit = true

		break
	end

	if not hasLimit then
		return true
	end

	local pawnTemplateId = pg.pawn and pg.pawn.templateId or 0

	for _, templateId in pairs(liftPetTemplateIds) do
		if templateId == pawnTemplateId then
			return true
		end
	end

	return false
end

function ClientEnvObject:initInteraction()
	if self.eModel == nil then
		return
	end

	local configData = self:getConfigData()

	self.eModel.centerOffset = configData.centerOffset or 0.1

	local actionPrototypeIds = configData.actionPrototypeIds

	if actionPrototypeIds then
		self.interactionListData = {}

		for _, actionPrototypeId in ipairs(actionPrototypeIds) do
			self.interactionListData[#self.interactionListData + 1] = {
				globalId = self:getGlobalId(),
				actionPrototypeId = actionPrototypeId,
				name = configData.name or configData.entityName
			}
		end
	else
		self.interactionListData = nil
	end
end

function ClientEnvObject:getInteractionListData()
	return self.interactionListData
end

function ClientEnvObject:interact(interactUnit)
	pg.pawn:startInteract(Const.IACT_TP_ENVOBJ, self.id, interactUnit.actionPrototypeId, {}, function(ret, retArgs)
		if NoticeDef.SUCCESS == ret then
			-- block empty
		else
			self:onInteractFailed(interactUnit.actionPrototypeId)
		end
	end)
end

function ClientEnvObject:RPC_SC_OnUnlockStart()
	self:setAnimatorTrigger("SetOpen")
end

function ClientEnvObject:onInteractStart(fromEntId, targetType, actionPrototypeId, interactParams)
	local interactionType = (InteractData[actionPrototypeId] or EMPTY_TABLE).type

	if interactionType == InteractionConst.INTERACTION_TYPE_ENT_FUNC then
		local responseTime = self:getConfigData().responseTime or 0

		self.unlockChestTimer = self:addTimer(responseTime, function()
			self.unlockChestTimer = nil

			self:onUnlockStart()
		end)
	end
end

function ClientEnvObject:onInteractInterrupt(fromEntId, targetType, actionPrototypeId, interactParams)
	if not self.isModelLoaded or not self.eModel then
		return
	end

	local interactionType = (InteractData[actionPrototypeId] or EMPTY_TABLE).type

	if interactionType == InteractionConst.INTERACTION_TYPE_ENT_FUNC then
		if self.unlockChestTimer then
			self:removeTimer(self.unlockChestTimer)
		end

		self.unlockChestTimer = nil

		self:resetAnimator()
		self:refreshChestOpened()

		local unlockFailedAnim = self:getConfigData().unlockFailedAnim

		if unlockFailedAnim and self.eModel then
			self:animatorPlay(unlockFailedAnim)
		end
	end
end

function ClientEnvObject:onInteractResult(fromEnt, actionPrototypeId)
	local configData = self:getConfigData()

	if configData.effBeforeInteract then
		for _, key in ipairs(configData.effBeforeInteract) do
			self:stopEffect(key)
		end
	end

	if configData.effAfterInteract then
		for _, key in ipairs(configData.effAfterInteract) do
			self:stopEffect(key)
		end

		for _, key in ipairs(configData.effAfterInteract) do
			self:playEffect(key)
		end
	end

	local interactionType = (InteractData[actionPrototypeId] or EMPTY_TABLE).type

	if interactionType == InteractionConst.INTERACTION_TYPE_PICK_UP then
		-- block empty
	elseif interactionType == InteractionConst.INTERACTION_TYPE_LIFT then
		if fromEnt ~= pg.me then
			return
		end

		local liftAttachId = self:getConfigData().attachId or 0

		pg.pawn:callLiftEntity(self, liftAttachId)
	elseif interactionType == InteractionConst.INTERACTION_TYPE_PET_LIFT then
		if fromEnt ~= pg.pawn then
			return
		end

		if not self:_canCurrentPawnLiftByPetTemplateLimit() then
			return
		end

		local liftAttachId = self:getConfigData().attachId or 0

		pg.pawn:callLiftEntity(self, liftAttachId)
	elseif interactionType == InteractionConst.INTERACTION_TYPE_PUSH then
		if fromEnt:checkStatus(ConflictTypes.CT_PUSH, true) then
			fromEnt:pushEntity(self)
		end
	elseif interactionType == InteractionConst.INTERACTION_TYPE_THROW then
		if fromEnt ~= pg.pawn then
			return
		end

		if not pg.game.controller:isInControlMainPlayer() then
			pg.global.showBubbleMessageById(NoticeDef.CAN_NOT_THROW_ITEM)
		else
			self:detach()
			pg.me:throwEnvObj(self)
		end
	elseif interactionType == InteractionConst.INTERACTION_TYPE_ENT_FUNC then
		if self.active and self.visible then
			local openSound = self:getConfigData().openSound

			if openSound then
				self:playSoundEvent(openSound)
			end

			local openEffect = self:getConfigData().openEffect

			if openEffect then
				self:playEffect(openEffect)
			end
		end

		self:setAnimatorTrigger("SetOpen")
	end

	if self.staticId and self.staticId ~= 0 and fromEnt.authority == Const.AUTHORITY_MASTER then
		local eventData = {
			fromEnt = fromEnt,
			actionPrototypeId = actionPrototypeId
		}

		facade:sendLuaEvent(self.staticId .. ClientConst.LuaEventPostFix.EntityInteract, eventData)
	end
end

function ClientEnvObject:onInteractFailed(actionPrototypeId)
	local interactionType = (InteractData[actionPrototypeId] or EMPTY_TABLE).type

	if interactionType == InteractionConst.INTERACTION_TYPE_ENT_FUNC then
		local unlockFailedAnim = self:getConfigData().unlockFailedAnim

		if unlockFailedAnim and self.eModel then
			self:animatorPlay(unlockFailedAnim)
		end
	elseif interactionType == InteractionConst.INTERACTION_TYPE_THROW then
		pg.global.showBubbleMessageById(NoticeDef.CAN_NOT_THROW_ITEM)
	end
end

function ClientEnvObject:checkCanInteract(interactUnit)
	if not string.isNilOrEmpty(self.lifterId) then
		return false
	end

	local configData = self:getConfigData()

	if configData.actionDelay and (not self.createTime or self.createTime + configData.actionDelay > Time.realSecondCache) then
		return false
	end

	if interactUnit.interactionType == InteractionConst.INTERACTION_TYPE_ENT_FUNC then
		if self.status == Const.INTERACTOR_STATUS.ENVOBJ_OPENED then
			return false
		end
	elseif interactUnit.interactionType == InteractionConst.INTERACTION_TYPE_PICK_UP then
		-- block empty
	elseif interactUnit.interactionType == InteractionConst.INTERACTION_TYPE_LIFT then
		if not pg.game.controller:isInControlMainPlayer() then
			return false
		end

		if not pg.me.canLift or not pg.me:canLift() then
			return false
		end

		if not configData.attachId then
			return false
		end

		return self:canBeLift()
	elseif interactUnit.interactionType == InteractionConst.INTERACTION_TYPE_PET_LIFT then
		if pg.game.controller:isInControlMainPlayer() then
			return false
		end

		if not self:_canCurrentPawnLiftByPetTemplateLimit() then
			return false
		end

		if not pg.pawn.canLift or not pg.pawn:canLift() then
			return false
		end

		if not configData.attachId then
			return false
		end

		return self:canBeLift()
	elseif interactUnit.interactionType == InteractionConst.INTERACTION_TYPE_PUSH then
		if not pg.game.controller:isInControlMainPlayer() then
			return false
		end

		if not pg.me:canPushEntity(self) then
			return false
		end

		if not self.pushComponent then
			self.pushComponent = self.eModel:GetPushComponent()
		end

		if self.pushComponent then
			return self.pushComponent:CanPush()
		end

		return false
	elseif interactUnit.interactionType == InteractionConst.INTERACTION_TYPE_THROW then
		local exclude = {
			INTERACT_ST = true
		}

		if not pg.me:checkEnterCatchMode(nil, exclude) then
			return false
		end

		if self.isHolding then
			return false
		end

		if pg.me:isControllingPet() then
			local curPetEnt = pg.me:getCurPetEntity()

			if not curPetEnt:checkBeStopControlPet(exclude) or not pg.me:checkStopControlPet(exclude) or not pg.me:checkCanSwitchToTargetWithEnoughSpace(pg.me, curPetEnt) then
				return false
			end
		end
	end

	return true
end

function ClientEnvObject:onUnlockStart()
	if self.visible then
		local unlockEffect = self:getConfigData().unlockEffect

		if unlockEffect then
			self:playEffect(unlockEffect)
		end

		local unlockSound = self:getConfigData().unlockSound

		if unlockSound then
			self:playSoundEvent(unlockSound)
		end
	end

	self:setAnimatorTrigger("SetUnlock")
end

function ClientEnvObject:on_status_changed(oldVal, newVal)
	self:refreshChestOpened()
end

function ClientEnvObject:refreshChestOpened()
	if not self.isModelLoaded or not self.eModel then
		return
	end

	local isOpened = self.status == Const.INTERACTOR_STATUS.ENVOBJ_OPENED

	if isOpened then
		self:setAnimatorBool("IsOpen", true)
		self:setPerformRecorderState("open")
	else
		self:setAnimatorBool("IsOpen", false)
		self:setPerformRecorderState("close")
	end
end

function ClientEnvObject:setPerformRecorderState(archiveName)
	if not self.eModel or not self.eModel.itemModel then
		return
	end

	local performRecorder = self.eModel.itemModel:GetComponent("PerformRecorder")

	if archiveName and performRecorder then
		performRecorder:ApplyArchiveByName(archiveName)
	end
end

function ClientEnvObject:isIce()
	return self.EnvIceFeature ~= nil
end

function ClientEnvObject:isElectric()
	return self.EnvElectricFeature ~= nil
end

function ClientEnvObject:isExplosive()
	return self.EnvExplosiveFeature ~= nil
end

function ClientEnvObject:canBeLocked()
	if not self.isModelLoaded then
		return false
	end

	return self.camp ~= nil
end

function ClientEnvObject:isPartEnt()
	return false
end

function ClientEnvObject:getLockParts()
	local lockParts = {}

	return lockParts
end

function ClientEnvObject:getLockPartPosition(partId)
	return self:getPosition()
end

function ClientEnvObject:checkEnableVoxelUpdate()
	return self:getConfigData().enableVoxelCheck
end

function ClientEnvObject:getBodySize(partId)
	return self.bodySize
end

function ClientEnvObject:onTimePeriodChange()
	self:setNightShine()
end

function ClientEnvObject:setEnvObjDecalLayer()
	return
end

function ClientEnvObject:onPlayerHold(player, castItemId)
	self.throwPlayer = player

	self.eModel:BeHold()
	self:attachCastItem(player.id, castItemId)

	local heldScale = self:getConfigData().modelScaleInHand

	if heldScale and heldScale ~= 1 then
		self:setModelScale(ClientConst.MODEL_SCALE_KEY.HELD, heldScale)
	end
end

function ClientEnvObject:onPlayerFire(player, ballData)
	if player == self.throwPlayer then
		self.throwPlayer = nil

		self:detach()
		self.eModel:Throw(player.eModel, ballData.delayCancelIgnoreSelfCollision or 0.5, ballData.throwMaterial or 0)
		self:setModelScale(ClientConst.MODEL_SCALE_KEY.HELD, nil)
	end
end

function ClientEnvObject:onPlayerDrop(player, castItemId)
	if player == self.throwPlayer then
		self.throwPlayer = nil

		self.eModel:Drop(player.eModel)
		self:detach()
		self:setModelScale(ClientConst.MODEL_SCALE_KEY.HELD, nil)
	end
end

return ClientEnvObject
