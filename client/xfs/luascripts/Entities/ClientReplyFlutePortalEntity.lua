-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\ClientReplyFlutePortalEntity.lua

local CommonConst = require("Common.Const.Const")
local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local ClientModelEntity = require("Entities.ClientModelEntity")
local ClientActorComponent = require("Entities.SpaceEntities.CommonComponent.ClientActorComponent")
local AddressDataConst = require("Const.AddressDataConst")
local InteractionConst = require("Common.Const.InteractionConst")
local EnterPortalActionPrototypeId = 409
local ClientReplyFlutePortalEntity = Class.Class("ClientReplyFlutePortalEntity", ClientModelEntity)
local ClientInteractionComponent = require("Entities.SpaceEntities.CommonComponent.ClientInteractionComponent")
local EModelUtils = require("Entities.Utils.EModelUtils")
local Components = {
	ClientActorComponent,
	ClientInteractionComponent
}

Class.AddComponents(ClientReplyFlutePortalEntity, Components)

function ClientReplyFlutePortalEntity:ctor(entityId)
	ClientReplyFlutePortalEntity.super.ctor(self, entityId)

	self.isInited = false
end

function ClientReplyFlutePortalEntity:init(bdict)
	ClientReplyFlutePortalEntity.super.init(self, bdict)

	self.modelPosition = bdict.position
	self.modelRotation = bdict.rotation
	self.modelScale = bdict.scale
	self.isInited = true
	self.inviteInfo = bdict.inviteInfo

	return true
end

function ClientReplyFlutePortalEntity:start()
	ClientReplyFlutePortalEntity.super.start(self)
end

function ClientReplyFlutePortalEntity:initializeComponents()
	self:postComponentMethod("EVENT_AddEComponent")
	self:addEModelComponent(CommonConst.COMPONENT_INDEX_EFFECT)
	self:addEModelComponent(CommonConst.COMPONENT_IDX_ITEM)
end

function ClientReplyFlutePortalEntity:postInitializeComponents()
	ClientReplyFlutePortalEntity.super.postInitializeComponents(self)
end

function ClientReplyFlutePortalEntity:refreshAppearance()
	ClientReplyFlutePortalEntity.super.refreshAppearance(self)
	self:setModelLayer(ClientConst.LayerDefine.LAYER_DEFAULT)

	if not self.eModel then
		return
	end

	self.eModel:SetModelResId(CommonConst.COMPONENT_IDX_ITEM, AddressDataConst.REPLY_FLUTE_PORTAL)
end

function ClientReplyFlutePortalEntity:onItemModelLoaded()
	self.isModelLoaded = true

	EModelUtils.setAgentPositionAndRotation(self, self.modelPosition, self.modelRotation)
	self:setPositionAgentScale(self.modelScale)
	self:onModelRefreshed()
	self:postComponentMethod("EVENT_onModelLoaded")
	self:setModelLoaded(true)
end

function ClientReplyFlutePortalEntity:onModelRefreshed()
	return
end

function ClientReplyFlutePortalEntity:initInteraction()
	if self.eModel == nil then
		return
	end

	self.interactionListData = {}

	table.insert(self.interactionListData, {
		globalId = self:getGlobalId(),
		actionPrototypeId = EnterPortalActionPrototypeId
	})
	self:postComponentMethod("EVENT_InitInteractionList")
end

function ClientReplyFlutePortalEntity:getInteractionListData()
	return nil
end

function ClientReplyFlutePortalEntity:checkCanInteract(interactUnit)
	return false
end

function ClientReplyFlutePortalEntity:interact(interactUnit)
	return
end

return ClientReplyFlutePortalEntity
