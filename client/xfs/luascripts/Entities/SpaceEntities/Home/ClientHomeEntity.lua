-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientHomeEntity.lua

local Class = require("Core.Framework.Class")
local ClientHomeEntityBase = require("Entities.SpaceEntities.Home.ClientHomeEntityBase")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local ClientAoiComponent = require("Entities.SpaceEntities.CommonComponent.ClientAoiComponent")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local HomeObjectData = require("Data.home_object_data")
local ClientInteractionComponent = require("Entities.SpaceEntities.CommonComponent.ClientInteractionComponent")
local ClientHomeEditorComponent = require("Entities.SpaceEntities.Home.ClientHomeEditorComponent")
local ClientHomeEditorTopLogoComponent = require("Entities.SpaceEntities.Home.ClientHomeEditorTopLogoComponent")
local Utils = require("Common.Utils.Utils")
local ClientEntityEditorComponent = require("Entities.SpaceEntities.Home.ClientEntityEditorComponent")
local ClientUtils = require("Utils.ClientUtils")
local ClientModelBatchComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelBatchComponent")
local ClientTopLogoComponent = require("Entities.SpaceEntities.CommonComponent.ClientTopLogoComponent")
local InteractData = require("Data.interact_data")
local InteractionConst = require("Common.Const.InteractionConst")
local HomelandConfigData = require("Data.homeland_config_data")
local ClientAnimatorComponent = require("Entities.SpaceEntities.CommonComponent.ClientAnimatorComponent")
local ClientHomeStateInteractComponent = require("Entities.SpaceEntities.Home.ClientHomeStateInteractComponent")
local ClientEffectComponent = require("Entities.SpaceEntities.PlayerComponent.ClientEffectComponent")
local ClientAudioComponent = require("Entities.SpaceEntities.CommonComponent.ClientAudioComponent")
local ClientHomeAttachSoundComponent = require("Entities.SpaceEntities.Home.ClientHomeAttachSoundComponent")
local CallbackHandler = require("Core.Common.CallbackHandler")
local HOME_GASHAPON_IDLE_ANIM = "Ani_LVH_Props_FurnitureTable_001_Ball"
local HOME_GASHAPON_START_ANIM = "Ani_LVH_Props_FurnitureTable_001_Start"
local HOME_GASHAPON_REWARD_ANIM = "Ani_LVH_Props_FurnitureTable_001_Turntable"
local HOME_GASHAPON_REWARD_SOUND = "SFX_SceneObject_Home_Ball"
local HOME_GASHAPON_OPEN_BOX_EFFECT = "Eff_Env_Home_UI_Vitality_contest"
local ClientHomeEntity = Class.Class("ClientHomeEntity", ClientHomeEntityBase)
local ClientHomeEntityComponents = {
	ClientEffectComponent,
	ClientAudioComponent,
	ClientHomeAttachSoundComponent,
	ClientAoiComponent,
	ClientInteractionComponent,
	ClientModelBatchComponent,
	ClientEntityEditorComponent,
	ClientHomeEditorComponent,
	ClientHomeEditorTopLogoComponent,
	ClientTopLogoComponent,
	ClientAnimatorComponent,
	ClientHomeStateInteractComponent
}

Class.AddComponents(ClientHomeEntity, ClientHomeEntityComponents)

function ClientHomeEntity:ctor(entityId)
	ClientHomeEntity.super.ctor(self, entityId)

	self.homeGashaponAnimTimer = nil
	self.homeGashaponOpenBoxEffectId = nil
	self.homeGashaponRewardSoundPlaying = false
end

function ClientHomeEntity:init(dict)
	if self.isClientEnt then
		self.actorId = VirtualEntUtils.getNewVirtualEntActorId()
		self.clenUsrType = Const.CLEN_USE_TYPE_HOME
	end

	ClientHomeEntity.super.init(self, dict)

	local configData = self:getConfigData()

	if configData and configData.actionPrototypeIds and configData.needIndicatorIcon == 1 then
		self.forbiddenTopLogo = false
		self.topLogoType = ClientConst.TopLogoType.InteractableObject
		self.overrideTopLogoEnterDistance = HomelandConfigData.IndicatorIconDisplayArea or 10
		self.indicatorIconHeight = configData.IndicatorIconHeight
	end

	return true
end

function ClientHomeEntity:needCreateAnimatorComponent()
	if HomeLandUtils.isHomeGashapon(self.homeTemplateId) then
		return true
	end

	return HomeLandUtils.homeOrnamentHasAnim(self:getConfigData())
end

function ClientHomeEntity:needCreateEffectComponent()
	return true
end

function ClientHomeEntity:needCreateAudioComponent()
	return HomeLandUtils.isHomeGashapon(self.homeTemplateId) or HomeLandUtils.homeOrnamentHasAudio(self:getConfigData())
end

function ClientHomeEntity:start()
	ClientHomeEntity.super.start(self)
	self:initInteraction()
end

function ClientHomeEntity:initializeComponents()
	ClientHomeEntity.super.initializeComponents(self)
	self:addEModelMonoComponent(Const.COMPONENT_IDX_PHYSX)
	self:addEModelComponent(Const.COMPONENT_IDX_ITEM)
end

function ClientHomeEntity:destroy()
	ClientHomeEntity.super.destroy(self)
end

function ClientHomeEntity:preDestroy()
	self:clearHomeGashaponAnimTimer()
	self:clearHomeGashaponOpenBoxEffect()
	ClientHomeEntity.super.preDestroy(self)
end

function ClientHomeEntity:refreshAppearance()
	ClientHomeEntity.super.refreshAppearance(self)

	if self:hasEModelComponent(Const.COMPONENT_IDX_ITEM) then
		self:setEnableRendererBatch(self:checkEnableRendererBatch())

		local resId = self:getConfigData().prefabResID
		local modelScale = self:getConfigData().prefabScale or 1

		if resId then
			self:setScaleNumber(modelScale)
			self.eModel:SetModelResId(Const.COMPONENT_IDX_ITEM, resId, ClientConst.InstantiatePriority.Low, ClientConst.AsyncLoadPriority.Low)
		end
	end
end

function ClientHomeEntity:checkEnableRendererBatch()
	return ClientUtils.checkEnableRendererBatch() and not self:getConfigData().disableRendererBatch and not HomeLandUtils.isHomeGashapon(self.homeTemplateId)
end

function ClientHomeEntity:onItemModelLoaded()
	self.isModelLoaded = true

	self.eModel:SetHomeObjectCollider(Const.COMPONENT_IDX_PHYSX)
	self.eModel:SetTag(Const.COMPONENT_IDX_PHYSX, Const.TAG_ACTOR, self.actorId, 0)

	local modelText = self:getConfigData().modelText

	if modelText then
		local showText = pg.getLocalizationText(modelText)

		self.eModel.modelView:SetModelText(showText, ClientConst.ModelTextType.Default)
	end

	self:postComponentMethod("EVENT_onModelLoaded")
	self:setModelLoaded(true)

	local itemModel = self.eModel and self.eModel.itemModel

	if itemModel and HomeLandUtils.isHomeMusicPlayer(self.homeTemplateId) then
		local ballContainer = itemModel.transform:Find("GameObject")
		local ball = ballContainer and ballContainer:GetChild(0)
		local simpleRotate = ball and ball:GetComponent("SimpleRotate")

		if simpleRotate then
			simpleRotate.enabled = true
		end
	end

	if HomeLandUtils.isHomeGashapon(self.homeTemplateId) then
		self:playHomeGashaponIdleAnim()
	end
end

function ClientHomeEntity:initInteraction()
	if self.eModel == nil then
		return
	end

	local configData = self:getConfigData()
	local actionPrototypeIds = configData.actionPrototypeIds

	if HomeLandUtils.isHomeMusicPlayer(self.homeTemplateId) then
		local actionPrototypeId = actionPrototypeIds and actionPrototypeIds[1]

		if actionPrototypeId then
			self.interactionListData = {
				{
					globalId = self:getGlobalId(),
					interactionType = InteractionConst.INTERACTION_TYPE_ENT_FUNC,
					actionPrototypeId = actionPrototypeId,
					overrideInteractDis = configData.interactDistance,
					interactFunc = CallbackHandler(self, "openHomeMusicPlayer")
				}
			}
		else
			self.interactionListData = nil
		end
	elseif HomeLandUtils.isHomeGashapon(self.homeTemplateId) then
		local actionPrototypeId = actionPrototypeIds and actionPrototypeIds[1]

		if actionPrototypeId then
			self.interactionListData = {
				{
					globalId = self:getGlobalId(),
					interactionType = InteractionConst.INTERACTION_TYPE_ENT_FUNC,
					actionPrototypeId = actionPrototypeId,
					overrideInteractDis = configData.interactDistance,
					interactFunc = CallbackHandler(self, "openHomeGashapon")
				}
			}
		else
			self.interactionListData = nil
		end
	elseif actionPrototypeIds and configData.needStateInteraction ~= 1 then
		self.interactionListData = {}

		for _, actionPrototypeId in ipairs(actionPrototypeIds) do
			self.interactionListData[#self.interactionListData + 1] = {
				globalId = self:getGlobalId(),
				actionPrototypeId = actionPrototypeId,
				overrideInteractDis = configData.interactDistance,
				name = configData.name or configData.entityName
			}
		end
	elseif not actionPrototypeIds then
		self.interactionListData = nil
	end

	self:postComponentMethod("EVENT_InitInteractionList")
end

function ClientHomeEntity:openHomeMusicPlayer()
	if not self.space or not self.space:isHomeland() or not self.space:isSelfHomeland() then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_HOME_MUSIC_PLAYER, {
		ornamentId = self.ornamentId
	})
end

function ClientHomeEntity:openHomeGashapon()
	if not self.space or not self.space:isHomeland() or not self.space:isSelfHomeland() then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_HOME_GASHAPON, {
		ornamentId = self.ornamentId
	})
end

function ClientHomeEntity:clearHomeGashaponAnimTimer()
	if self.homeGashaponAnimTimer then
		self:removeTimer(self.homeGashaponAnimTimer)

		self.homeGashaponAnimTimer = nil
	end

	self:stopHomeGashaponRewardSound()
end

function ClientHomeEntity:playHomeGashaponRewardSound(duration)
	self:stopHomeGashaponRewardSound()
	self:triggerSoundEvent(HOME_GASHAPON_REWARD_SOUND, nil, duration)

	self.homeGashaponRewardSoundPlaying = true
end

function ClientHomeEntity:stopHomeGashaponRewardSound()
	if not self.homeGashaponRewardSoundPlaying then
		return
	end

	self.homeGashaponRewardSoundPlaying = false

	self:stopSoundEvent(HOME_GASHAPON_REWARD_SOUND, 0)
end

function ClientHomeEntity:playHomeGashaponIdleAnim()
	self:clearHomeGashaponAnimTimer()

	if self.playAnimancerAnim then
		self:playAnimancerAnim(HOME_GASHAPON_IDLE_ANIM, nil, true)
	end
end

function ClientHomeEntity:clearHomeGashaponOpenBoxEffect()
	if self.homeGashaponOpenBoxEffectId then
		self:stopEffectById(self.homeGashaponOpenBoxEffectId, false, true)

		self.homeGashaponOpenBoxEffectId = nil
	end
end

function ClientHomeEntity:playHomeGashaponOpenBoxEffect()
	self:clearHomeGashaponOpenBoxEffect()

	local itemModel = self.eModel and self.eModel.itemModel

	if itemModel and self.playEffectOn then
		self.homeGashaponOpenBoxEffectId = self:playEffectOn(HOME_GASHAPON_OPEN_BOX_EFFECT, nil, itemModel.transform)
	end
end

function ClientHomeEntity:playHomeGashaponAnimSequence(animSteps, index, onComplete)
	local animStep = animSteps[index]

	if not animStep then
		self:playHomeGashaponIdleAnim()

		if onComplete then
			onComplete()
		end

		return
	end

	local anim = self:playAnimancerAnim(animStep.animName, nil, true)

	if not anim then
		self:playHomeGashaponIdleAnim()

		if onComplete then
			onComplete()
		end

		return
	end

	if animStep.animName == HOME_GASHAPON_REWARD_ANIM then
		self:playHomeGashaponRewardSound(anim.Length)
	end

	self.homeGashaponAnimTimer = self:addTimer(anim.Length + 0.3, function()
		self.homeGashaponAnimTimer = nil

		self:playHomeGashaponAnimSequence(animSteps, index + 1, onComplete)
	end)
end

function ClientHomeEntity:playHomeGashaponDraw(onComplete)
	if not HomeLandUtils.isHomeGashapon(self.homeTemplateId) then
		return false
	end

	self:clearHomeGashaponAnimTimer()

	if self.playAnimancerAnim then
		self:playHomeGashaponAnimSequence({
			{
				animName = HOME_GASHAPON_START_ANIM
			},
			{
				animName = HOME_GASHAPON_REWARD_ANIM
			}
		}, 1, onComplete)

		return true
	end

	return false
end

function ClientHomeEntity:getInteractionListData()
	return self.interactionListData
end

function ClientHomeEntity:getInteractName()
	return pg.getLocalizationText(self:getConfigData().name)
end

function ClientHomeEntity:checkCanInteract(interactUnit)
	if not ClientHomeEntity.super.checkCanInteract(self, interactUnit) then
		return false
	end

	if not self.space then
		return false
	end

	if interactUnit.info and interactUnit.info.skipHomelandCheck then
		-- block empty
	elseif not self.space:isSelfHomeland() then
		return false
	end

	return true
end

function ClientHomeEntity:interact(interactUnit)
	if interactUnit.interactionType == InteractionConst.INTERACTION_TYPE_MARKET then
		local configData = self:getConfigData()

		if configData.shopId then
			pg.global.ui:open(UIConst.UI_ID_HOMELAND_MARKET, {
				shopId = configData.shopId,
				shopName = configData.name
			})
		else
			pg.global.showBubbleMessageRaw(pg.getGameString("FUNC_NOT_AVAILABLE"), 3)
		end
	end

	if interactUnit.interactionType == InteractionConst.INTERACTION_TYPE_HOME_INVENTORY then
		pg.global.ui:open(UIConst.UI_ID_HOME_INVENTORY, {})
	end
end

function ClientHomeEntity:setScale(scale)
	self:setPositionAgentScale(scale.x, scale.y, scale.z)
	self:postComponentMethod("EVENT_onEntityScaleChanged")
end

function ClientHomeEntity:getScale()
	return self:getPositionAgentScale()
end

function ClientHomeEntity:onEntityPositionChanged()
	self:postComponentMethod("EVENT_onEntityPositionChanged")
	self:flushBatchRenderer()
end

return ClientHomeEntity
