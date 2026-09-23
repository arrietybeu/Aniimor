-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientBreakableEntity.lua

local class = require("Core.Framework.Class")
local ClientInteractor = require("Entities.SpaceEntities.ClientInteractor")
local GrabEggData = require("Data.rob_egg_chest_data")
local Const = require("Common.Const.Const")
local ClientPrefabModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientPrefabModelComponent")
local ClientPhysicsComponent = require("Entities.SpaceEntities.CommonComponent.ClientPhysicsComponent")
local ClientBreakableEntity = class.Class("ClientBreakableEntity", ClientInteractor)
local Components = {
	ClientPrefabModelComponent
}

class.AddComponents(ClientBreakableEntity, Components)

function ClientBreakableEntity:ctor(entityId)
	ClientBreakableEntity.super.ctor(self, entityId)
end

function ClientBreakableEntity:init(bdict)
	ClientBreakableEntity.super.init(self, bdict)

	self.interactList = {}
	self.templateId = bdict.templateId
	self.actorType = Const.ACTOR_TYPE_ENVOBJ
	self.camp = Const.CAMP_MONSTER_DEFAULT
	self.isLockAsPuppet = true
	self.entityCanMove = self:getConfigData().nonKinematic and true or false

	return true
end

function ClientBreakableEntity:postInitializeComponents()
	ClientBreakableEntity.super.postInitializeComponents(self)
	self:addEModelMonoComponent(Const.COMPONENT_IDX_PHYSX)

	self.eModel.tagType = Const.TAG_INTERACT_ATTACK

	function self.eModel.onAttackHit(actorId, x, y, z)
		if not self.isDestroyed then
			self:serverMsg("RPC_CS_OnAbilityHitBreakableItem")
		end
	end
end

function ClientBreakableEntity:getConfigData()
	if not self.templateId then
		return {}
	end

	return GrabEggData[self.templateId] or {}
end

function ClientBreakableEntity:canBeLocked()
	if not self.isModelLoaded then
		return false
	end

	return true
end

function ClientBreakableEntity:getBodySize(partId)
	if not self.isModelLoaded then
		return 0
	end

	return self.eModel:GetMeshSize(Const.COMPONENT_IDX_ITEM, 0)
end

function ClientBreakableEntity:getLockPartPosition(partId)
	if not self.isModelLoaded then
		return self:getPosition()
	end

	local height = self.eModel:GetMeshSize(Const.COMPONENT_IDX_ITEM, 1) * 0.5

	return self:getPosition() + Vector3(0, 1, 0) * height
end

function ClientBreakableEntity:refreshAppearance()
	ClientBreakableEntity.super.refreshAppearance(self)

	local cdd = self:getConfigData()

	if cdd.model then
		self:loadPrefabModel(cdd.model)
	end
end

function ClientBreakableEntity:isConfigKinematic()
	return not self:getConfigData().nonKinematic
end

function ClientBreakableEntity:onPrefabModelLoaded()
	self:postComponentMethod("EVENT_OnModelRefreshed")
end

function ClientBreakableEntity:preDestroy()
	self:playDestroyEffect()

	local destroySound = self:getConfigData().destroySound

	if destroySound then
		self:playSoundAtSelfPos(destroySound)
	end

	ClientBreakableEntity.super.preDestroy(self)
end

function ClientBreakableEntity:getPreloadEffects()
	local preloadEffects = {}
	local configData = self:getConfigData()

	if configData.destroyEffect then
		table.insert(preloadEffects, configData.destroyEffect)
	end

	return preloadEffects
end

function ClientBreakableEntity:getInteractionListData()
	return nil
end

return ClientBreakableEntity
