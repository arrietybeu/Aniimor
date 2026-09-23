-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\ClientSimpleMoveNpc.lua

local CommonConst = require("Common.Const.Const")
local Class = require("Core.Framework.Class")
local ClientEntity = require("Core.Client.ClientEntity")
local ClientConst = require("Const.ClientConst")
local AiConst = require("Common.Const.AiConst")
local MessageName = require("Const.MessageName")
local ClientModelUtils = require("Utils.ClientModelUtils")
local PuppetData = require("Data.puppet_data")
local NpcAvatarData = require("Data.npc_avatar_data")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local Const = require("Const.Const")
local AddressDataConst = require("Const.AddressDataConst")
local LoggerManager = require("Core.Log.LoggerManager")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local LoggerConst = require("Core.Log.LoggerConst")
local ClientUtils = require("Utils.ClientUtils")
local SceneUtils = require("Common.Utils.SceneUtils")
local Bitset = require("Common.Bitset")
local EModelUtils = require("Entities.Utils.EModelUtils")
local ClientSimpleMoveNpc = Class.Class("ClientSimpleMoveNpc", ClientEntity)
local ClientEffectComponent = require("Entities.SpaceEntities.PlayerComponent.ClientEffectComponent")
local ClientDebugComponent = require("Entities.SpaceEntities.PlayerComponent.ClientDebugComponent")
local ClientAudioComponent = require("Entities.SpaceEntities.CommonComponent.ClientAudioComponent")
local ClientVisibleComponent = require("Entities.SpaceEntities.CommonComponent.ClientVisibleComponent")
local ClientAnimationComponent = require("Entities.SpaceEntities.CommonComponent.ClientAnimationComponent")
local ClientTimeControlComponent = require("Entities.SpaceEntities.CommonComponent.ClientTimeControlComponent")
local ClientModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelComponent")
local ClientTrapEventComponent = require("Entities.SpaceEntities.CommonComponent.ClientTrapEventComponent")
local ClientTopLogoComponent = require("Entities.SpaceEntities.CommonComponent.ClientTopLogoComponent")
local ClientActorComponent = require("Entities.SpaceEntities.CommonComponent.ClientActorComponent")
local ClientAuthorityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAuthorityComponent")
local ClientSimpleMoveComponent = require("Entities.SpaceEntities.SimpleMoveComponent.ClientSimpleMoveComponent")
local ClientNpcInteractComponent = require("Entities.SpaceEntities.CommonComponent.ClientNpcInteractComponent")
local ClientRVOComponent = require("Entities.SpaceEntities.CommonComponent.ClientRVOComponent")
local ClientSpecialStateRecoverComponent = require("Entities.SpaceEntities.CommonComponent.ClientSpecialStateRecoverComponent")
local ClientSimpleLookAtComponent = require("Entities.SpaceEntities.CommonComponent.ClientSimpleLookAtComponent")
local ClientPosRotComponent = require("Entities.SpaceEntities.CommonComponent.ClientPosRotComponent")
local ClientEModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientEModelComponent")
local ClientLODComponent = require("Entities.SpaceEntities.CommonComponent.ClientLODComponent")
local ClientNpcComponent = require("Entities.SpaceEntities.CommonComponent.ClientNpcComponent")
local Utils = require("Utils.Utils")
local Vector3 = Vector3
local ClientSimpleMoveNpcEntityComponents = {
	ClientPosRotComponent,
	ClientLODComponent,
	ClientEModelComponent,
	ClientVisibleComponent,
	ClientEffectComponent,
	ClientAnimationComponent,
	ClientAudioComponent,
	ClientTimeControlComponent,
	ClientDebugComponent,
	ClientNpcComponent,
	ClientModelComponent,
	ClientTrapEventComponent,
	ClientTopLogoComponent,
	ClientActorComponent,
	ClientAuthorityComponent,
	ClientSimpleMoveComponent,
	ClientRVOComponent,
	ClientNpcInteractComponent,
	ClientSpecialStateRecoverComponent,
	ClientSimpleLookAtComponent
}

Class.AddComponents(ClientSimpleMoveNpc, ClientSimpleMoveNpcEntityComponents)

function ClientSimpleMoveNpc:ctor(entityId)
	ClientSimpleMoveNpc.super.ctor(self, entityId)

	self.actorType = Const.ACTOR_TYPE_PUPPET
	self.isInited = false
	self.useSimpleTimeScale = true
	self.isClientEnt = false
end

function ClientSimpleMoveNpc:init(dict)
	ClientSimpleMoveNpc.super.init(self, dict)

	self.isInited = true
	self.forbiddenTopLogo = false
	self.dic = dict
	self.syncLoad = dict.syncLoad

	local pData = PuppetData[self.templateId]

	self:setConfigData(pData)

	self.entityCanMove = true
	self.topLogoType = ClientConst.TopLogoType.NPC
end

function ClientSimpleMoveNpc:postInit(dict)
	ClientSimpleMoveNpc.super.postInit(self, dict)
	self:createEModel()
end

function ClientSimpleMoveNpc:initializeComponents()
	self:postComponentMethod("EVENT_AddEComponent")
	self:addEModelComponent(CommonConst.COMPONENT_INDEX_MODEL)
	self:addEModelComponent(CommonConst.COMPONENT_INDEX_EFFECT)
	self:addEModelComponent(CommonConst.COMPONENT_IDX_PLAYABLE)
end

function ClientSimpleMoveNpc:setConfigData(configData)
	self.configData = configData
end

function ClientSimpleMoveNpc:getConfigData()
	return self.configData or AiConst.DefaultNullTable
end

function ClientSimpleMoveNpc:getHeight()
	return self:getConfigData().modelHeight or 1.65
end

function ClientSimpleMoveNpc:postInitializeComponents()
	self:onNPCPostInitializeComponents()
end

function ClientSimpleMoveNpc:getCsEntityType()
	return ClientConst.ENTITY_CS_TYPE.VIRTUAL
end

function ClientSimpleMoveNpc:getEModelResId()
	return AddressDataConst.Ent_Entity
end

function ClientSimpleMoveNpc:onTriggerEnter(userData)
	self:postComponentMethod("onTriggerEnter", userData)
end

function ClientSimpleMoveNpc:onTriggerExit(userData)
	self:postComponentMethod("onTriggerExit", userData)
end

function ClientSimpleMoveNpc:destroy()
	self.isDestroyed = true

	ClientSimpleMoveNpc.super.destroy(self)
end

return ClientSimpleMoveNpc
