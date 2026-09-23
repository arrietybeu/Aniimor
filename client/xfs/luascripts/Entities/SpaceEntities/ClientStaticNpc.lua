-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientStaticNpc.lua

local class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local EventConst = require("Const.EventConst")
local Bitset = require("Common.Bitset")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientEntity = require("Core.Client.ClientEntity")
local PuppetData = require("Data.puppet_data")
local NpcAvatarData = require("Data.npc_avatar_data")
local InteractionConst = require("Common.Const.InteractionConst")
local SceneUtils = require("Common.Utils.SceneUtils")
local UIConst = require("Const.UIConst")
local CommonConst = require("Common.Const.Const")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local AddressDataConst = require("Const.AddressDataConst")
local MessageName = require("Const.MessageName")
local AiConst = require("Common.Const.AiConst")
local Utils = require("Utils.Utils")
local EModelUtils = require("Entities.Utils.EModelUtils")
local ClientStaticNpc = class.Class("ClientStaticNpc", ClientEntity)
local ClientEModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientEModelComponent")
local ClientEffectComponent = require("Entities.SpaceEntities.PlayerComponent.ClientEffectComponent")
local ClientDebugComponent = require("Entities.SpaceEntities.PlayerComponent.ClientDebugComponent")
local ClientAudioComponent = require("Entities.SpaceEntities.CommonComponent.ClientAudioComponent")
local ClientVisibleComponent = require("Entities.SpaceEntities.CommonComponent.ClientVisibleComponent")
local ClientAnimationComponent = require("Entities.SpaceEntities.CommonComponent.ClientAnimationComponent")
local ClientTimeControlComponent = require("Entities.SpaceEntities.CommonComponent.ClientTimeControlComponent")
local ClientModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelComponent")
local ClientRVOComponent = require("Entities.SpaceEntities.CommonComponent.ClientRVOComponent")
local ClientActorComponent = require("Entities.SpaceEntities.CommonComponent.ClientActorComponent")
local ClientAuthorityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAuthorityComponent")
local ClientTopLogoComponent = require("Entities.SpaceEntities.CommonComponent.ClientTopLogoComponent")
local ClientNpcInteractComponent = require("Entities.SpaceEntities.CommonComponent.ClientNpcInteractComponent")
local ClientSpecialStateRecoverComponent = require("Entities.SpaceEntities.CommonComponent.ClientSpecialStateRecoverComponent")
local ClientTrapEventComponent = require("Entities.SpaceEntities.CommonComponent.ClientTrapEventComponent")
local ClientDynamicFeatureComponent = require("Entities.SpaceEntities.CommonComponent.ClientDynamicFeatureComponent")
local ClientHatchBoxComponent = require("Entities.SpaceEntities.CommonComponent.ClientHatchBoxComponent")
local ClientSimpleLookAtComponent = require("Entities.SpaceEntities.CommonComponent.ClientSimpleLookAtComponent")
local ClientNpcAIReactionComponent = require("Entities.SpaceEntities.CommonComponent.ClientNpcAIReactionComponent")
local ClientAnimatorComponent = require("Entities.SpaceEntities.CommonComponent.ClientAnimatorComponent")
local ClientNpcComponent = require("Entities.SpaceEntities.CommonComponent.ClientNpcComponent")
local ClientPosRotComponent = require("Entities.SpaceEntities.CommonComponent.ClientPosRotComponent")
local ClientLODComponent = require("Entities.SpaceEntities.CommonComponent.ClientLODComponent")
local ClientNpcComponents = {
	ClientPosRotComponent,
	ClientLODComponent,
	ClientEModelComponent,
	ClientVisibleComponent,
	ClientEffectComponent,
	ClientAnimationComponent,
	ClientAudioComponent,
	ClientDebugComponent,
	ClientNpcComponent,
	ClientModelComponent,
	ClientActorComponent,
	ClientRVOComponent,
	ClientAuthorityComponent,
	ClientTrapEventComponent,
	ClientTopLogoComponent,
	ClientSpecialStateRecoverComponent,
	ClientNpcInteractComponent,
	ClientDynamicFeatureComponent,
	ClientHatchBoxComponent,
	ClientSimpleLookAtComponent,
	ClientNpcAIReactionComponent,
	ClientAnimatorComponent,
	ClientTimeControlComponent
}

if EnableBotTest then
	ClientNpcComponents = {
		ClientPosRotComponent,
		ClientLODComponent,
		ClientEModelComponent,
		ClientVisibleComponent,
		ClientEffectComponent,
		ClientAnimationComponent,
		ClientAudioComponent,
		ClientDebugComponent,
		ClientNpcComponent,
		ClientModelComponent,
		ClientActorComponent,
		ClientRVOComponent,
		ClientAuthorityComponent,
		ClientSpecialStateRecoverComponent,
		ClientNpcInteractComponent,
		ClientDynamicFeatureComponent,
		ClientHatchBoxComponent
	}
end

class.AddComponents(ClientStaticNpc, ClientNpcComponents)

function ClientStaticNpc:ctor(entityId)
	ClientStaticNpc.super.ctor(self, entityId)

	self.actorType = Const.ACTOR_TYPE_PUPPET
	self.isInited = false
	self.isClientEnt = false
end

function ClientStaticNpc:init(bdict)
	ClientStaticNpc.super.init(self, bdict)

	self.trapEventId = bdict.trapEventId
	self.isInited = true

	local pdd = PuppetData[self.templateId] or AiConst.DefaultNullTable

	self:setConfigData(pdd)

	self.forbiddenTopLogo = pdd.forbidTopLogo or false
	self.spriteIdAfterCatch = pdd.spriteIdAfterCatch
	self.useHitBox = false
	self.bodyMass = pdd.mass
	self.bodyWeight = pdd.weight
	self.isWild = pdd.isWild and pdd.isWild > 0

	self:_setTopLogoType()

	self.effs = pdd.effs
	self.ownerSpawnerId = bdict.spawnerId
	self.entityCanMove = false
	self.useSimpleTimeScale = true

	return true
end

function ClientStaticNpc:postInit(dict)
	ClientStaticNpc.super.postInit(self, dict)
	self:createEModel()
end

function ClientStaticNpc:_setTopLogoType()
	if self.templateId == ClientConst.HATCH_BOX_ID then
		self.topLogoType = ClientConst.TopLogoType.PetFertility
	else
		local configData = self:getConfigData()
		local overrideNameState = configData and configData.overrideNameState

		if overrideNameState and overrideNameState == UIConst.NAME_STATE.COMBAT then
			self.topLogoType = ClientConst.TopLogoType.Pet
		else
			self.topLogoType = ClientConst.TopLogoType.NPC
		end
	end
end

function ClientStaticNpc:initializeComponents()
	if self.eModel == nil then
		return
	end

	self:postComponentMethod("EVENT_AddEComponent")
	self:addEModelComponent(CommonConst.COMPONENT_INDEX_MODEL)
	self:addEModelComponent(CommonConst.COMPONENT_INDEX_EFFECT)
	self:addEModelComponent(CommonConst.COMPONENT_IDX_PLAYABLE)
	self:addEModelComponent(Const.COMPONENT_INDEX_IK)
end

function ClientStaticNpc:postInitializeComponents()
	self:onNPCPostInitializeComponents()
end

function ClientStaticNpc:start()
	ClientStaticNpc.super.start(self)

	self.bornPosition = self:transferBornPosition()
end

function ClientStaticNpc:getCsEntityType()
	return ClientConst.ENTITY_CS_TYPE.ENTITY
end

function ClientStaticNpc:getEModelResId()
	return AddressDataConst.Ent_Entity
end

function ClientStaticNpc:getHeight()
	return self:getConfigData().modelHeight or 1.65
end

function ClientStaticNpc:onTriggerEnter(userData)
	self:postComponentMethod("onTriggerEnter", userData)
end

function ClientStaticNpc:onTriggerExit(userData)
	self:postComponentMethod("onTriggerExit", userData)
end

function ClientStaticNpc:transferBornPosition()
	return Vector3(self.bornPosition_x, self.bornPosition_y, self.bornPosition_z)
end

function ClientStaticNpc:setConfigData(configData)
	self.configData = configData
end

function ClientStaticNpc:getConfigData()
	return self.configData or AiConst.DefaultNullTable
end

function ClientStaticNpc:preDestroy()
	if self:isDead() then
		self:playDestroyEffect()
	end

	ClientStaticNpc.super.preDestroy(self)
end

function ClientStaticNpc:repr()
	return string.format("ClientStaticNpc(entityId=%s, uid=%d)", self.id, self.uid or 0)
end

function ClientStaticNpc:canBeLocked()
	if self.isTransparent then
		return false
	end

	if self:isDead() then
		return false
	end

	if self.visible == false then
		return false
	end

	local configData = self:getConfigData()

	if configData.canNotSelect then
		return false
	end

	return true
end

function ClientStaticNpc:inBreak()
	return false
end

function ClientStaticNpc:isDead()
	return false
end

function ClientStaticNpc:getInteractPriority()
	return InteractionConst.EntInteractPriority.StaticNpc
end

return ClientStaticNpc
