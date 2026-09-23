-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientArkChest.lua

local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local EventConst = require("Const.EventConst")
local chestData = require("Data.chest_data")
local TimerManager = require("Core.Timer.TimerManager")
local ClientInteractor = require("Entities.SpaceEntities.ClientInteractor")
local ClientAttachComponent = require("Entities.SpaceEntities.CommonComponent.ClientAttachComponent")
local InteractionConst = require("Common.Const.InteractionConst")
local ecs_editor_export_chem_material_data = require("Data.ecs_editor_export_chem_material_data")
local ecs_module_data = require("Data.ecs_module_data")
local Utils = require("Common.Utils.Utils")
local Vector3 = Vector3
local EffectConst = require("Const.EffectConst")
local NoticeDef = require("Common.NoticeDef")
local ClientPhysicsComponent = require("Entities.SpaceEntities.CommonComponent.ClientPhysicsComponent")
local ClientEcologyComponent = require("Entities.SpaceEntities.CommonComponent.ClientEcologyComponent")
local ClientResPointComponent = require("Entities.SpaceEntities.CommonComponent.ClientResPointComponent")
local ClientGhostEyeDetectedComponent = require("Entities.SpaceEntities.PlayerComponent.ClientGhostEyeDetectedComponent")
local ClientPrefabModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientPrefabModelComponent")
local ClientArkChest = class.Class("ClientArkChest", ClientInteractor)
local ChestComponents = {
	ClientPhysicsComponent,
	ClientAttachComponent,
	ClientEcologyComponent,
	ClientResPointComponent,
	ClientGhostEyeDetectedComponent,
	ClientPrefabModelComponent
}

if EnableBotTest then
	ChestComponents = {
		ClientPhysicsComponent,
		ClientEcologyComponent,
		ClientResPointComponent,
		ClientGhostEyeDetectedComponent
	}
end

class.AddComponents(ClientArkChest, ChestComponents)

function ClientArkChest:ctor(entityId)
	ClientArkChest.super.ctor(self, entityId)

	self.isChest = true
	self.chestValid = true
end

function ClientArkChest:init(bdict)
	ClientArkChest.super.init(self, bdict)

	local cdd = self:getConfigData()

	self.actionPrototypeId = cdd.actionPrototypeId
	self.effect = cdd.effect
	self.beforeOpenEffect = cdd.effectBeforeOpen
	self.unlockFailedAnim = cdd.unlockFailedAnim
	self.needItem = cdd.needItem
	self.unlockSound = cdd.unlockSound
	self.modelScale = cdd.modelScale or 1
	self.chestType = cdd.chestType or 0
	self.entityCanMove = false

	return true
end

function ClientArkChest:postInitializeComponents()
	ClientArkChest.super.postInitializeComponents(self)
end

function ClientArkChest:start()
	ClientArkChest.super.start(self)
end

function ClientArkChest:getConfigData()
	if not self.templateId then
		return {}
	end

	return chestData[self.templateId] or {}
end

function ClientArkChest:getChestType()
	local cdd = chestData[self.templateId]

	return cdd and cdd.chestType or Const.ChestType.OwnerOpenAndOwnerGet
end

function ClientArkChest:isConfigKinematic()
	local configData = self:getConfigData()

	return not configData.nonKinematic
end

function ClientArkChest:refreshAppearance()
	ClientArkChest.super.refreshAppearance(self)

	local cdd = self:getConfigData()

	if cdd.model then
		self:loadPrefabModel(cdd.model)
	end
end

function ClientArkChest:onPrefabModelLoaded()
	self:refreshChestOpened()
	self:setPositionAgentScale(self.modelScale)
	self:onModelRefreshed()
	self:refreshChestValid()
end

function ClientArkChest:belongsToPlayer(player)
	return player.arkChestActived[self.staticId]
end

function ClientArkChest:checkCanInteract(unit)
	if not self:belongsToPlayer(pg.me) then
		return false
	end

	if self.levelCondition == Const.LEVEL_CONDITION_OFF then
		return false
	end

	if self:attaching() then
		return false
	end

	return not self:isChestOpened()
end

function ClientArkChest:isChestOpened()
	return false
end

function ClientArkChest:interact(interactUnit)
	if self:isChestOpened() then
		return
	end

	pg.me:startInteract(Const.IACT_TP_CHEST, self.id, self.actionPrototypeId, {}, function(ret, retArgs)
		if NoticeDef.SUCCESS == ret then
			facade:sendLuaEvent(self.staticId .. "chestOpen")
			pg.me:executePetAdditiveAIEvent("MasterOpenChestTrigger", {
				chestId = self.id
			})
		end
	end)
end

function ClientArkChest:refreshChestValid()
	local chestValid = true

	if Utils.openChestLimit(pg.me, self) then
		chestValid = false
	elseif not pg.me.arkChestActived[self.staticId] then
		chestValid = false
	end

	if self.chestValid ~= chestValid then
		self.chestValid = chestValid

		self:setActive(ClientConst.MODEL_VISIBLE_KEY.CHEST_VALID, chestValid)
	end
end

function ClientArkChest:RPC_SC_OnUnlockStart()
	self:onUnlockStart()
	self:setAnimatorTrigger("SetOpen")
end

function ClientArkChest:onUnlockStart(fromEntId)
	self.eventEmitter:emit(EventConst.VIRTUAL_CHEST_UNLOCKSTART)

	local unlockEffect = self:getConfigData().unlockEffect

	if unlockEffect then
		self:playEffect(unlockEffect, {}, true)
	end

	local unlockPreset = self:getConfigData().unlockPreset

	if unlockPreset then
		local presetDuration = self:getConfigData().unlockPresetDuration

		ClientEffectUtils.PlayPreset(self, unlockPreset, presetDuration, false)
	end

	if self.active and self.visible and self.unlockSound then
		self:playSoundAtSelfPos(self.unlockSound)
	end

	self:playChestTrailEffect(fromEntId)
	self:setAnimatorTrigger("SetUnlock")
end

function ClientArkChest:playChestTrailEffect(fromEntId)
	if not fromEntId then
		return
	end

	local fromEnt = pg.getEntity(fromEntId)

	if not fromEnt then
		return
	end

	local trailEffect = self:getConfigData().trailEffect

	if trailEffect then
		local extraInfo = {
			position = self:getPosition(),
			rotation = self:getRotation():ToEulerAngles(),
			followType = EffectConst.FollowType.Global,
			mountType = EffectConst.MountType.Motor,
			targetTransActorId = fromEnt.actorId,
			targetTransOffset = Vector3(0, fromEnt:getHeight() * 0.5, 0)
		}

		fromEnt:playEffect(trailEffect, extraInfo)
	end
end

function ClientArkChest:onInteractStart(fromEntId, targetType, actionPrototypeId, interactParams)
	local responseTime = self:getConfigData().responseTime or 0

	if responseTime > 0 then
		self.unlockChestTimer = self:addTimer(responseTime, function()
			self.unlockChestTimer = nil

			self:onUnlockStart(fromEntId)
		end)
	else
		self:onUnlockStart(fromEntId)
	end

	local cfgData = self:getConfigData()

	if cfgData.rumble and fromEntId == pg.me.id then
		local rumbleTime = cfgData.rumbleTime or 0

		self.rumbleChestTimer = TimerManager.addTimer(rumbleTime, function()
			self.rumbleChestTimer = nil

			pg.game.input:playRumbleByName(ClientConst.RumbleLayer.DEFAULT, cfgData.rumble)
		end)
	end

	if self.beforeOpenEffectId then
		self:stopEffectById(self.beforeOpenEffectId)

		self.beforeOpenEffectId = nil
	end
end

function ClientArkChest:onInteractInterrupt(fromEntId, targetType, actionPrototypeId, interactParams)
	self.eventEmitter:emit(EventConst.VIRTUAL_CHEST_INTERACTINTERRUPT)

	if not self.isModelLoaded or not self.eModel then
		return
	end

	if self.unlockChestTimer then
		self:removeTimer(self.unlockChestTimer)
	end

	if self.rumbleChestTimer then
		TimerManager.removeTimer(self.rumbleChestTimer)
	end

	self.unlockChestTimer = nil
	self.rumbleChestTimer = nil

	self:resetAnimator()
	self:refreshChestOpened()

	if self.unlockFailedAnim and self.eModel then
		self:animatorPlay(self.unlockFailedAnim)
	end
end

function ClientArkChest:onInteractResult(fromEnt, actionPrototypeId)
	self.eventEmitter:emit(EventConst.VIRTUAL_CHEST_INTERACTRESULT)

	if fromEnt then
		local playerOpenEffect = self:getConfigData().playerOpenEffect

		if playerOpenEffect then
			fromEnt:playEffect(playerOpenEffect)
		end
	end

	self:setAnimatorTrigger("SetOpen")

	if self.staticId and self.staticId ~= 0 and fromEnt.authority == Const.AUTHORITY_MASTER then
		local eventData = {
			fromEnt = fromEnt,
			actionPrototypeId = actionPrototypeId
		}

		facade:sendLuaEvent(self.staticId .. ClientConst.LuaEventPostFix.EntityInteract, eventData)
	end

	if fromEnt ~= pg.me then
		return
	end

	pg.me:postComponentMethod("OnPetProud")
end

function ClientArkChest:refreshChestOpened()
	self.eventEmitter:emit(EventConst.VIRTUAL_CHEST_REFRESHMODEL)

	if not self.isModelLoaded or not self.eModel then
		return
	end

	local isOpened = self:isChestOpened()
	local hideWhenOpened = self:getConfigData().hideWhenOpened

	if isOpened then
		self:setAnimatorBool("IsOpen", true)

		if hideWhenOpened then
			self:setVisible(ClientConst.MODEL_VISIBLE_KEY.CHEST_OPENED, false, false)
		end

		if self.effectId then
			self:stopEffectById(self.effectId)

			self.effectId = nil
		end
	else
		if hideWhenOpened then
			self:setVisible(ClientConst.MODEL_VISIBLE_KEY.CHEST_OPENED, true, true)
		end

		self:setAnimatorBool("IsOpen", false)

		if not self.effectId and self.effect then
			self.effectId = self:playEffect(self.effect)
		end
	end

	local openCount = pg.me.interactRecord[self.staticId] or 0

	if openCount >= 1 then
		if self.beforeOpenEffectId then
			self:stopEffectById(self.beforeOpenEffectId)

			self.beforeOpenEffectId = nil
		end
	elseif not self.beforeOpenEffectId and self.beforeOpenEffect then
		self.beforeOpenEffectId = self:playEffect(self.beforeOpenEffect)
	end
end

function ClientArkChest:getInteractionListData()
	if not self.actionPrototypeId then
		return nil
	end

	return {
		{
			actionPrototypeId = self.actionPrototypeId,
			interactionType = InteractionConst.INTERACTION_TYPE_ENT_FUNC,
			globalId = self:getGlobalId(),
			needItem = self.needItem,
			name = self:getConfigData().name or ""
		}
	}
end

function ClientArkChest:on_status_changed(oldVal, newVal)
	self:refreshChestOpened()

	local isOpened = self:isChestOpened()

	if self.active and self.visible then
		local openSound = self:getConfigData().openSound

		if openSound then
			self:playSoundAtSelfPos(openSound)
		end
	end

	if isOpened then
		local openEffect = self:getConfigData().openEffect

		if openEffect then
			self:playEffect(openEffect)
		end
	end
end

function ClientArkChest:preDestroy()
	if self.effectId then
		self:stopEffectById(self.effectId)

		self.effectId = nil
	end

	if self.beforeOpenEffectId then
		self:stopEffectById(self.beforeOpenEffectId)

		self.beforeOpenEffectId = nil
	end

	self:playDestroyEffect()
	ClientArkChest.super.preDestroy(self)
end

function ClientArkChest:destroy()
	self.eventEmitter:emit(EventConst.VIRTUAL_CHEST_DESTROY)
	ClientArkChest.super.destroy(self)
end

function ClientArkChest:getPetGuideLevel()
	return self:getConfigData().petGuideLevel or 0
end

function ClientArkChest:getPetDetectiveViewLevel()
	return self:getConfigData().petDetectiveViewLevel or 0
end

function ClientArkChest:getPreloadEffects()
	local preloadEffects = {}
	local configData = self:getConfigData()

	if configData.unlockEffect then
		table.insert(preloadEffects, configData.unlockEffect)
	end

	if configData.trailEffect then
		table.insert(preloadEffects, configData.trailEffect)
	end

	if configData.playerOpenEffect then
		table.insert(preloadEffects, configData.playerOpenEffect)
	end

	return preloadEffects
end

return ClientArkChest
