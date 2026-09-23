-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\ClientOwnClientNpc.lua

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
local puppetData = require("Data.puppet_data")
local Const = require("Common.Const.Const")
local ClientOwnClientNpc = Class.Class("ClientOwnClientNpc", ClientModelEntity)
local ClientModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelComponent")
local ClientAoiComponent = require("Entities.SpaceEntities.CommonComponent.ClientAoiComponent")
local ClientEffectComponent = require("Entities.SpaceEntities.PlayerComponent.ClientEffectComponent")
local ClientAnimationComponent = require("Entities.SpaceEntities.CommonComponent.ClientAnimationComponent")
local ClientAudioComponent = require("Entities.SpaceEntities.CommonComponent.ClientAudioComponent")
local ClientTimeControlComponent = require("Entities.SpaceEntities.CommonComponent.ClientTimeControlComponent")
local ClientOwnClientNpcComponents = {
	ClientAoiComponent,
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

Class.AddComponents(ClientOwnClientNpc, ClientOwnClientNpcComponents)

function ClientOwnClientNpc:init(dict)
	self.actorId = VirtualEntUtils.getNewVirtualEntActorId()
	self.actorType = Const.ACTOR_TYPE_VIRTUAL
	self.clenUsrType = Const.CLEN_USR_TYPE_VIRTUAL_AI

	ClientOwnClientNpc.super.init(self, dict)

	self.templateId = dict.templateId
	self.topLogoType = ClientConst.TopLogoType.Pet
	self.virtualTemplateActorType = Const.ACTOR_TYPE_PUPPET
	self.forbiddenTopLogo = false
	self.eventEmitter = Events.new()
	self.useSimpleTimeScale = true

	return true
end

function ClientOwnClientNpc:start()
	ClientOwnClientNpc.super.start(self)
	self:initInteraction()
end

function ClientOwnClientNpc:destroy()
	ClientOwnClientNpc.super.destroy(self)
end

function ClientOwnClientNpc:onModelRefreshed()
	ClientOwnClientNpc.super.onModelRefreshed(self)
	facade:SendMessageCommand(MessageName.ON_MODEL_REFRESHED, self.id)
end

function ClientOwnClientNpc:initializeComponents()
	ClientOwnClientNpc.super.initializeComponents(self)
end

function ClientOwnClientNpc:getTemplateData()
	return puppetData[self.templateId] or {}
end

function ClientOwnClientNpc:getConfigData()
	return self:getTemplateData()
end

function ClientOwnClientNpc:initInteraction()
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

function ClientOwnClientNpc:getInteractionListData()
	return self.interactionListData
end

function ClientOwnClientNpc:checkNpcCanInteract(interactUnit)
	if self.checkCanInteractFunc and not self.checkCanInteractFunc(self, interactUnit) then
		return false
	end

	return true
end

function ClientOwnClientNpc:npcInteract(interactUnit)
	if self.interactFunc then
		self.interactFunc(self, interactUnit)
	end
end

function ClientOwnClientNpc:npcFuncInteract(funcMenuId, index)
	if self.npcInteractFunc then
		self.npcInteractFunc(self, funcMenuId, index)
	end
end

function ClientOwnClientNpc:faceToTarget(target, partId)
	local configData = self:getConfigData()

	if configData.lockDirection then
		return
	end

	ClientOwnClientNpc.super.faceToTarget(self, target, partId)
end

function ClientOwnClientNpc:refreshAppearance()
	ClientOwnClientNpc.super.refreshAppearance(self)

	if not self.eModel then
		return
	end

	local configData = self:getConfigData()
	local modelView = self.eModel.modelModelView
	local extraData = ClientModelUtils.getModelExtraInfo(configData, 0)

	ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraData)
	modelView:RefreshModels()
end

function ClientOwnClientNpc:getTopLogoFollowStrategy()
	return ClientUtils.getEntityTopLogoFollowStrategy(self)
end

function ClientOwnClientNpc:getTopLogoHeight(strategy, entry)
	return ClientUtils.getEntityTopLogoHeight(self, strategy, entry)
end

return ClientOwnClientNpc
