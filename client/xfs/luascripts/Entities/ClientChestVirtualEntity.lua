-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\ClientChestVirtualEntity.lua

local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local EventConst = require("Const.EventConst")
local InteractionConst = require("Common.Const.InteractionConst")
local TimerManager = require("Core.Timer.TimerManager")
local ClientVirtualEntity = require("Entities.ClientVirtualEntity")
local ClientChest = require("Entities.SpaceEntities.ClientChest")
local EModelUtils = require("Entities.Utils.EModelUtils")
local ClientUtils = require("Utils.ClientUtils")
local ClientChestVirtualEntity = Class.Class("ClientChestVirtualEntity", ClientVirtualEntity)
local chestData = require("Data.chest_data")
local ClientAttachComponent = require("Entities.SpaceEntities.CommonComponent.ClientAttachComponent")
local ClientPhysicsComponent = require("Entities.SpaceEntities.CommonComponent.ClientPhysicsComponent")
local ClientActorComponent = require("Entities.SpaceEntities.CommonComponent.ClientActorComponent")
local ClientAuthorityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAuthorityComponent")
local ClientInteractionComponent = require("Entities.SpaceEntities.CommonComponent.ClientInteractionComponent")
local ClientAnimatorComponent = require("Entities.SpaceEntities.CommonComponent.ClientAnimatorComponent")
local VirtualChestComponents = {
	ClientAttachComponent,
	ClientPhysicsComponent,
	ClientAnimatorComponent,
	ClientInteractionComponent
}

if EnableBotTest then
	VirtualChestComponents = {}
end

Class.AddComponents(ClientChestVirtualEntity, VirtualChestComponents)

function ClientChestVirtualEntity:ctor(entityId)
	ClientChestVirtualEntity.super.ctor(self, entityId)

	self.isInited = false
end

function ClientChestVirtualEntity:init(bdict)
	ClientChestVirtualEntity.super.init(self, bdict)

	self.mainChest = bdict.mainChest
	self.modelPosition = bdict.position

	self:InitByMainChest(self.mainChest)

	self.isInited = true
	self.ownerId = ""
	self.status = 0

	self:RegisterVirtualChestEvent()

	return true
end

function ClientChestVirtualEntity:InitByMainChest(mainChest)
	local cdd = mainChest:getConfigData()

	self.actionPrototypeId = cdd.actionPrototypeId
	self.effect = cdd.effect
	self.openEffect = cdd.openEffect
	self.unlockEffect = cdd.unlockEffect
	self.unlockPreset = cdd.unlockPreset
	self.unlockPresetDur = cdd.unlockPresetDur
	self.unlockFailedAnim = cdd.unlockFailedAnim
	self.needItem = cdd.needItem
	self.openSound = cdd.openSound
	self.unlockSound = cdd.unlockSound
	self.modelScale = cdd.modelScale or 1
	self.entityCanMove = true
end

function ClientChestVirtualEntity:start()
	ClientChestVirtualEntity.super.start(self)
end

function ClientChestVirtualEntity:preDestroy()
	if self.mainChest and self.mainChest.eventEmitter then
		self:UnRegisterVirtualChestEvent()
	end

	if self.effectId then
		if self.eModel then
			self:stopEffectById(self.effectId)
		end

		self.effectId = nil
	end

	ClientChestVirtualEntity.super.preDestroy(self)
end

function ClientChestVirtualEntity:destroy()
	if self.space then
		self.space:onEntityLeave(self)
	end

	ClientChestVirtualEntity.super.destroy(self)

	self.mainChest = nil
	self.onMainChestDestroyed = nil
end

function ClientChestVirtualEntity:initializeComponents()
	self:postComponentMethod("EVENT_AddEComponent")
	self:addEModelComponent(Const.COMPONENT_INDEX_EFFECT)
	self:addEModelComponent(Const.COMPONENT_IDX_ITEM)
end

function ClientChestVirtualEntity:postInitializeComponents()
	ClientChestVirtualEntity.super.postInitializeComponents(self)
	pg.me.space:onEntityJoin(self)
end

function ClientChestVirtualEntity:refreshAppearance()
	ClientChestVirtualEntity.super.refreshAppearance(self)
	self:setModelLayer(ClientConst.LayerDefine.LAYER_DEFAULT)

	if not self.eModel then
		return
	end

	local cdd = chestData[self.mainChest.templateId]

	if cdd.model then
		self.eModel:SetModelResId(Const.COMPONENT_IDX_ITEM, cdd.model)
	end
end

function ClientChestVirtualEntity:getInteractionListData()
	return ClientChest.getInteractionListData(self)
end

function ClientChestVirtualEntity:onItemModelLoaded()
	self.isModelLoaded = true

	self.refreshChestOpened()

	if self.eModel then
		EModelUtils.setAgentPositionAndRotation(self, self.modelPosition, self.mainChest:getRotation())
		self:setPositionAgentScale(self.modelScale)
	end

	self:onModelRefreshed()
	self:postComponentMethod("EVENT_onModelLoaded")
	self:setModelLoaded(true)
end

function ClientChestVirtualEntity:onModelRefreshed()
	ClientChest.onModelRefreshed(self)
end

function ClientChestVirtualEntity:getLockPartPosition(partId)
	return self:getPosition()
end

function ClientChestVirtualEntity:belongsToPlayer(player)
	return self.mainChest:belongsToPlayer(player)
end

function ClientChestVirtualEntity:checkCanInteract(unit)
	return ClientChest.checkCanInteract(self, unit)
end

function ClientChestVirtualEntity:interact(interactUnit)
	self.mainChest:interact(interactUnit)
end

function ClientChestVirtualEntity:RegisterVirtualChestEvent()
	function self.onUnlockStart()
		if self.unlockEffect then
			self:playEffect(self.unlockEffect)
		end

		if self.unlockPreset then
			ClientEffectUtils.PlayPreset(self, self.unlockPreset, self.unlockPresetDur, false)
		end

		if self.unlockSound then
			self:playSoundAtSelfPos(self.unlockSound)
		end

		self:setAnimatorTrigger("SetUnlock")

		self.status = 1
	end

	function self.onInteractResult()
		if self.openSound then
			self:playSoundAtSelfPos(self.openSound)
		end

		if self.openEffect then
			self:playEffect(self.openEffect)
		end

		self:setAnimatorTrigger("SetOpen")
	end

	function self.refreshChestOpened()
		if not self.isModelLoaded or not self.eModel then
			return
		end

		local isOpened = self.status == Const.INTERACTOR_STATUS.CHEST_OPENED

		if isOpened then
			self:setAnimatorBool("IsOpen", true)

			if self.effectId then
				self:stopEffectById(self.effectId)

				self.effectId = nil
			end
		else
			self:setAnimatorBool("IsOpen", false)

			if not self.effectId and self.effect then
				self.effectId = self:playEffect(self.effect)
			end
		end
	end

	function self.onInteractInterrupt()
		if not self.isModelLoaded or not self.eModel then
			return
		end

		self:resetAnimator()
		self.refreshChestOpened()

		if self.unlockFailedAnim and self.eModel then
			self:animatorPlay(self.unlockFailedAnim)
		end
	end

	function self.onMainChestDestroyed()
		ClientUtils.safeDestroy(self)
	end

	function self.onChestVisibleActiveChanged()
		local visible = self.mainChest.visible
		local enableCollide = visible

		self:setVisible(self, ClientConst.MODEL_VISIBLE_KEY.CHEST_LIMIT, visible, enableCollide)
	end

	self.mainChest.eventEmitter:addEventListener(EventConst.VIRTUAL_CHEST_UNLOCKSTART, self.onUnlockStart)
	self.mainChest.eventEmitter:addEventListener(EventConst.VIRTUAL_CHEST_INTERACTRESULT, self.onInteractResult)
	self.mainChest.eventEmitter:addEventListener(EventConst.VIRTUAL_CHEST_REFRESHMODEL, self.refreshChestOpened)
	self.mainChest.eventEmitter:addEventListener(EventConst.VIRTUAL_CHEST_INTERACTINTERRUPT, self.onInteractInterrupt)
	self.mainChest.eventEmitter:addEventListener(EventConst.VIRTUAL_CHEST_DESTROY, self.onMainChestDestroyed)
	self.mainChest.eventEmitter:addEventListener(EventConst.ENTITY_ACTIVE_CHANGED, self.onChestVisibleActiveChanged)
	self.mainChest.eventEmitter:addEventListener(EventConst.ENTITY_VISIBLE_CHANGED, self.onChestVisibleActiveChanged)
end

function ClientChestVirtualEntity:UnRegisterVirtualChestEvent()
	self.mainChest.eventEmitter:removeEventListener(EventConst.VIRTUAL_CHEST_UNLOCKSTART, self.onUnlockStart)
	self.mainChest.eventEmitter:removeEventListener(EventConst.VIRTUAL_CHEST_INTERACTRESULT, self.onInteractResult)
	self.mainChest.eventEmitter:removeEventListener(EventConst.VIRTUAL_CHEST_REFRESHMODEL, self.refreshChestOpened)
	self.mainChest.eventEmitter:removeEventListener(EventConst.VIRTUAL_CHEST_INTERACTINTERRUPT, self.onInteractInterrupt)
	self.mainChest.eventEmitter:removeEventListener(EventConst.VIRTUAL_CHEST_DESTROY, self.onMainChestDestroyed)
	self.mainChest.eventEmitter:removeEventListener(EventConst.ENTITY_ACTIVE_CHANGED, self.onChestVisibleActiveChanged)
	self.mainChest.eventEmitter:removeEventListener(EventConst.ENTITY_VISIBLE_CHANGED, self.onChestVisibleActiveChanged)
end

return ClientChestVirtualEntity
