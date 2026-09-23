-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\ClientVirtualNpc.lua

local Class = require("Core.Framework.Class")
local ClientVirtualEntity = require("Entities.ClientVirtualEntity")
local ClientConst = require("Const.ClientConst")
local MessageName = require("Const.MessageName")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientTopLogoComponent = require("Entities.SpaceEntities.CommonComponent.ClientTopLogoComponent")
local Events = require("Common.Container.Events")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local ClientUtils = require("Utils.ClientUtils")
local ClientInteractionComponent = require("Entities.SpaceEntities.CommonComponent.ClientInteractionComponent")
local ClientModelEntity = require("Entities.ClientModelEntity")
local ClientNpcInteractComponent = require("Entities.SpaceEntities.CommonComponent.ClientNpcInteractComponent")
local ClientTrapEventComponent = require("Entities.SpaceEntities.CommonComponent.ClientTrapEventComponent")
local ClientNpcAIReactionComponent = require("Entities.SpaceEntities.CommonComponent.ClientNpcAIReactionComponent")
local ActorManager = require("Core.Common.ActorManager")
local puppetData = require("Data.puppet_data")
local Const = require("Common.Const.Const")
local NpcAvatarData = require("Data.npc_avatar_data")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local ClientVirtualNpc = Class.Class("ClientVirtualNpc", ClientModelEntity)
local ClientModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelComponent")
local ClientEffectComponent = require("Entities.SpaceEntities.PlayerComponent.ClientEffectComponent")
local ClientAnimationComponent = require("Entities.SpaceEntities.CommonComponent.ClientAnimationComponent")
local ClientAudioComponent = require("Entities.SpaceEntities.CommonComponent.ClientAudioComponent")
local ClientTimeControlComponent = require("Entities.SpaceEntities.CommonComponent.ClientTimeControlComponent")
local ClientVirtualNpcComponents = {
	ClientModelComponent,
	ClientEffectComponent,
	ClientAnimationComponent,
	ClientAudioComponent,
	ClientTimeControlComponent,
	ClientTopLogoComponent,
	ClientTrapEventComponent,
	ClientNpcInteractComponent,
	ClientNpcAIReactionComponent
}

Class.AddComponents(ClientVirtualNpc, ClientVirtualNpcComponents)

function ClientVirtualNpc:init(dict)
	self.actorId = VirtualEntUtils.getNewVirtualEntActorId()
	self.actorType = Const.ACTOR_TYPE_VIRTUAL

	ClientVirtualNpc.super.init(self, dict)

	self.templateId = dict.templateId
	self.topLogoType = ClientConst.TopLogoType.Pet
	self.virtualTemplateActorType = Const.ACTOR_TYPE_PUPPET
	self.forbiddenTopLogo = false
	self.eventEmitter = Events.new()
	self.initPosition = dict.position
	self.initRotation = dict.rotation
	self.useSimpleTimeScale = true

	ActorManager.addEntity(self.actorId, self)

	return true
end

function ClientVirtualNpc:start()
	ClientVirtualNpc.super.start(self)
	self:initInteraction()
end

function ClientVirtualNpc:destroy()
	if self.space then
		self.space:onEntityLeave(self)
	end

	ClientVirtualNpc.super.destroy(self)
	ActorManager.removeEntity(self.actorId, self)
end

function ClientVirtualNpc:preDestroy()
	if self.space then
		self:onLeaveSpace()
	end

	ClientVirtualNpc.super.preDestroy(self)
end

function ClientVirtualNpc:onModelRefreshed()
	ClientVirtualNpc.super.onModelRefreshed(self)
	facade:SendMessageCommand(MessageName.ON_MODEL_REFRESHED, self.id)
end

function ClientVirtualNpc:initializeComponents()
	if self.initPosition then
		self:setPosition(self.initPosition)
		self:setRotation(self.initRotation)
	end

	ClientVirtualNpc.super.initializeComponents(self)
end

function ClientVirtualNpc:getTemplateData()
	return puppetData[self.templateId] or {}
end

function ClientVirtualNpc:getConfigData()
	return self:getTemplateData()
end

function ClientVirtualNpc:enterSpace(space)
	self.space = space

	self.space:onEntityJoin(self)
	self:onEnterSpace()
end

function ClientVirtualNpc:initInteraction()
	local configData = self:getConfigData()
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

	self:postComponentMethod("EVENT_InitInteractionList")
end

function ClientVirtualNpc:getInteractionListData()
	return self.interactionListData
end

function ClientVirtualNpc:checkNpcCanInteract(interactUnit)
	if self.checkCanInteractFunc and not self.checkCanInteractFunc(self, interactUnit) then
		return false
	end

	return true
end

function ClientVirtualNpc:npcInteract(interactUnit)
	if self.interactFunc then
		self.interactFunc(self, interactUnit)
	end
end

function ClientVirtualNpc:npcFuncInteract(funcMenuId, index)
	if self.npcInteractFunc then
		self.npcInteractFunc(self, funcMenuId, index)
	end
end

function ClientVirtualNpc:faceToTarget(target, partId)
	local configData = self:getConfigData()

	if configData.lockDirection then
		return
	end

	ClientVirtualNpc.super.faceToTarget(self, target, partId)
end

function ClientVirtualNpc:onTriggerEnter(userData)
	self:postComponentMethod("onTriggerEnter", userData)
end

function ClientVirtualNpc:onTriggerExit(userData)
	self:postComponentMethod("onTriggerExit", userData)
end

function ClientVirtualNpc:refreshAppearance()
	ClientVirtualNpc.super.refreshAppearance(self)

	if not self.eModel then
		return
	end

	local configData = self:getConfigData()
	local modelView = self.eModel.modelModelView
	local extraData = ClientModelUtils.getModelExtraInfo(configData, 0)

	ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraData)

	local result, realPrefabResID = AvatarUtils.refreshNPCModelData(configData)

	if not result then
		ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraData)

		if self.attachBaseEffects then
			self:attachBaseEffects(extraData.attachEffects)
		end

		if configData.appearanceResID then
			local npcAvatarData = NpcAvatarData[configData.appearanceResID] or {}
			local presetKey = npcAvatarData.avatarId

			if presetKey then
				modelView.modelInfo:ParseAvatarRuntimeData(presetKey)
				modelView.modelInfo:ParseToModelInfo()
			end
		end
	else
		extraData.prefabResID = realPrefabResID

		ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraData)
	end

	modelView:RefreshModels()
end

function ClientVirtualNpc:getTopLogoFollowStrategy()
	return ClientUtils.getEntityTopLogoFollowStrategy(self)
end

function ClientVirtualNpc:getTopLogoHeight(strategy, entry)
	return ClientUtils.getEntityTopLogoHeight(self, strategy, entry)
end

return ClientVirtualNpc
