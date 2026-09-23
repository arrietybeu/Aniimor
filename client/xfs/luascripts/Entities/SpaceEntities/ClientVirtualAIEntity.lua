-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientVirtualAIEntity.lua

local Class = require("Core.Framework.Class")
local ClientModelEntity = require("Entities.ClientModelEntity")
local ClientConst = require("Const.ClientConst")
local Utils = require("Common.Utils.Utils")
local PuppetData = require("Data.puppet_data")
local PetData = require("Data.pet_data")
local Const = require("Common.Const.Const")
local ClientModelUtils = require("Utils.ClientModelUtils")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local AttributeConst = require("Common.Const.AttributeConst")
local ClientVirtualAIEntity = Class.Class("ClientVirtualAIEntity", ClientModelEntity)
local ClientAoiComponent = require("Entities.SpaceEntities.CommonComponent.ClientAoiComponent")
local AutoPathFindComponent = require("Common.Components.AutoPathFindComponent")
local AIComponent = require("Common.Components.AIComponent")
local AIPlanComponent = require("Common.Components.AIPlanComponent")
local ClientModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelComponent")
local ClientPhysicsComponent = require("Entities.SpaceEntities.CommonComponent.ClientPhysicsComponent")
local ClientEffectComponent = require("Entities.SpaceEntities.PlayerComponent.ClientEffectComponent")
local ClientAnimationComponent = require("Entities.SpaceEntities.CommonComponent.ClientAnimationComponent")
local ClientAudioComponent = require("Entities.SpaceEntities.CommonComponent.ClientAudioComponent")
local ClientTimeControlComponent = require("Entities.SpaceEntities.CommonComponent.ClientTimeControlComponent")
local ClientMotionComponent = require("Entities.SpaceEntities.CommonComponent.ClientMotionComponent")
local ClientAbilityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAbilityComponent")
local AIGroupBehaviorComponent = require("Common.Components.AIGroupBehaviorComponent")
local ClientVoxelComponent = require("Entities.SpaceEntities.CommonComponent.ClientVoxelComponent")
local AIPlanDynamicComponent = require("Common.Components.AIPlanDynamicComponent")
local AdditiveAIComponent = require("Common.Components.AdditiveAIComponent")
local ClientRVOComponent = require("Entities.SpaceEntities.CommonComponent.ClientRVOComponent")
local ClientTopLogoComponent = require("Entities.SpaceEntities.CommonComponent.ClientTopLogoComponent")
local ClientVirtualAIEntityComponents = {
	ClientEffectComponent,
	ClientAnimationComponent,
	ClientAudioComponent,
	ClientTimeControlComponent,
	ClientAoiComponent,
	ClientModelComponent,
	ClientPhysicsComponent,
	ClientMotionComponent,
	ClientAbilityComponent,
	ClientVoxelComponent,
	AIComponent,
	AIPlanComponent,
	AutoPathFindComponent,
	AdditiveAIComponent,
	AIPlanDynamicComponent,
	AIGroupBehaviorComponent,
	ClientRVOComponent,
	ClientTopLogoComponent
}

Class.AddComponents(ClientVirtualAIEntity, ClientVirtualAIEntityComponents)

function ClientVirtualAIEntity:ctor(entityId)
	ClientVirtualAIEntity.super.ctor(self, entityId)

	self.actorType = Const.ACTOR_TYPE_VIRTUAL
end

function ClientVirtualAIEntity:init(dict)
	ClientVirtualAIEntity.super.init(self, dict)

	self.actorId = VirtualEntUtils.getNewVirtualEntActorId()
	self.templateId = dict.virtualTemplateId
	self.virtualTemplateClass = dict.virtualTemplateClassName
	self.virtualTemplateActorType = dict.virtualTemplateActorType

	local configData = self:getConfigData()

	self.virtualModelLayer = dict.virtualModelLayer
	self.bornPosition = dict.bornPosition
	self.visible = true
	self.label = dict.label
	self.curModelScale = dict.curModelScale or 1

	self:setBtName(self:getVirtualBt())

	self.forbiddenTopLogo = false
	self.authority = Const.AUTHORITY_MASTER
	self.bodySize = configData.bodySize or 0.2
	self.bodyHeight = configData.bodySize or 0.5
	self.useSimpleTimeScale = true

	return true
end

function ClientVirtualAIEntity:start()
	ClientVirtualAIEntity.super.start(self)
	self:setModelScale(ClientConst.MODEL_SCALE_KEY.DEFAULT, self.curModelScale)
	self:modifyVirtualAttribute()
end

function ClientVirtualAIEntity:destroy()
	ClientVirtualAIEntity.super.destroy(self)
end

function ClientVirtualAIEntity:tick(deltaTime)
	self:postComponentMethod("tick", deltaTime)
end

function ClientVirtualAIEntity:startVirtualEntity(position, rotation, enableCollision)
	self:forceSetPosRot(position, rotation)

	enableCollision = enableCollision or false

	self.eModel:SetColliderEnable(enableCollision)
end

function ClientVirtualAIEntity:initializeComponents()
	ClientVirtualAIEntity.super.initializeComponents(self)
	self:addEModelComponent(Const.COMPONENT_INDEX_MODEL)
	self:addEModelComponent(Const.COMPONENT_INDEX_EFFECT)
	self:addEModelComponent(Const.COMPONENT_IDX_PLAYABLE)
	self:addEModelComponent(Const.COMPONENT_MOTION)
	self:addEModelComponent(Const.COMPONENT_AUTO_PATH_FIND)
	self:addEModelComponent(Const.COMPONENT_AI_CONTROLLER)
end

function ClientVirtualAIEntity:postInitializeComponents()
	ClientVirtualAIEntity.super.postInitializeComponents(self)
	self:applyMotionProp()
end

function ClientVirtualAIEntity:getCsEntityType()
	return ClientConst.ENTITY_CS_TYPE.VIRTUAL
end

function ClientVirtualAIEntity:refreshAppearance()
	ClientVirtualAIEntity.super.refreshAppearance(self)

	if not self.eModel then
		return
	end

	local configData = self:getConfigData()
	local modelView = self.eModel.modelModelView
	local extraData = ClientModelUtils.getModelExtraInfo(configData, self.label or 0, self.gender)

	ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraData)
	modelView:RefreshModels()
	ClientModelUtils.applyIndividuation(self, self.individuationIds)
	self:attachBaseEffects(extraData.attachEffects)
	self:setModelLayer(self.virtualModelLayer or configData.layer)
end

function ClientVirtualAIEntity:getConfigData()
	if Utils.isVirtualPuppet(self) then
		return PuppetData[self.templateId]
	else
		assert(Utils.isVirtualPet(self))

		return PetData[self.templateId]
	end
end

function ClientVirtualAIEntity:getVirtualTemplateClass()
	return self.virtualTemplateClass
end

function ClientVirtualAIEntity:checkVirtualAIEnable()
	return true
end

function ClientVirtualAIEntity:modifyVirtualAttribute()
	local rawData

	if Utils.isVirtualPuppet(self) then
		rawData = PuppetData[self.templateId]
	else
		assert(Utils.isVirtualPet(self))

		rawData = PetData[self.templateId]
	end

	local actorAttributeModifier = pg.global.abilityMgr.actorAttributeModifier

	for attributeId = AttributeConst.GROUP_BEGIN, AttributeConst.GROUP_END do
		local name = AttributeConst.ID2NAME[attributeId]

		if rawData[name] then
			actorAttributeModifier:modifyAttrib(self.actorCombatAttribute, attributeId, rawData[name])
		end
	end
end

function ClientVirtualAIEntity:getVirtualBt()
	return self:getConfigData().bTree
end

function ClientVirtualAIEntity:getVirtualAIAgentName()
	return string.gsub(self:getVirtualTemplateClass(), "Client", "") .. "Agent"
end

function ClientVirtualAIEntity:serverMsg()
	return
end

return ClientVirtualAIEntity
