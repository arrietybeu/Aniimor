-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientChest.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local ClientModelEntity = require("Entities.ClientModelEntity")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local EventConst = require("Const.EventConst")
local chestData = require("Data.chest_data")
local MessageName = require("Const.MessageName")
local SceneUtils = require("Common.Utils.SceneUtils")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local ClientInteractor = require("Entities.SpaceEntities.ClientInteractor")
local ClientAttachComponent = require("Entities.SpaceEntities.CommonComponent.ClientAttachComponent")
local AddressDataConst = require("Const.AddressDataConst")
local EModelUtils = require("Entities.Utils.EModelUtils")
local InteractionConst = require("Common.Const.InteractionConst")
local ecs_editor_export_chem_material_data = require("Data.ecs_editor_export_chem_material_data")
local ecs_module_data = require("Data.ecs_module_data")
local Utils = require("Common.Utils.Utils")
local Vector3 = Vector3
local ClientUtils = require("Utils.ClientUtils")
local EffectConst = require("Const.EffectConst")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientSwitch = require("Common.ClientSwitch")
local HomeSeasonCelebrationTestConst = require("Common.Const.HomeSeasonCelebrationTestConst")
local ID_CHEST_MOVE = "chestMove"
local CHEST_INTERACT_INTERVAL = 0.5
local NoticeDef = require("Common.NoticeDef")
local ClientPhysicsComponent = require("Entities.SpaceEntities.CommonComponent.ClientPhysicsComponent")
local ClientEcologyComponent = require("Entities.SpaceEntities.CommonComponent.ClientEcologyComponent")
local ClientResPointComponent = require("Entities.SpaceEntities.CommonComponent.ClientResPointComponent")
local ClientGhostEyeDetectedComponent = require("Entities.SpaceEntities.PlayerComponent.ClientGhostEyeDetectedComponent")
local ClientVoxelComponent = require("Entities.SpaceEntities.CommonComponent.ClientVoxelComponent")
local ClientMagneticComponent = require("Entities.SpaceEntities.CommonComponent.ClientMagneticComponent")
local ClientPrefabModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientPrefabModelComponent")
local ClientVehicleOpComponent = require("Entities.SpaceEntities.CommonComponent.ClientVehicleOpComponent")
local ClientChestRewardAttractCtrl = require("GameApp.Sandbox.ClientChestRewardAttractCtrl")
local ClientChest = class.Class("ClientChest", ClientInteractor)
local ChestComponents = {
	ClientPhysicsComponent,
	ClientAttachComponent,
	ClientEcologyComponent,
	ClientResPointComponent,
	ClientGhostEyeDetectedComponent,
	ClientVoxelComponent,
	ClientMagneticComponent,
	ClientPrefabModelComponent,
	ClientVehicleOpComponent
}

if EnableBotTest then
	ChestComponents = {
		ClientPhysicsComponent,
		ClientEcologyComponent,
		ClientResPointComponent,
		ClientGhostEyeDetectedComponent
	}
end

class.AddComponents(ClientChest, ChestComponents)

local WIRE_DISSOLVE_PRESET = "CharacterWireFrameDissolve"

function ClientChest:ctor(entityId)
	ClientChest.super.ctor(self, entityId)

	self.isChest = true
	self.chestValid = true
	self.isClientEnt = false
end

function ClientChest:init(bdict)
	ClientChest.super.init(self, bdict)

	local cdd = self:getConfigData()

	self.actionPrototypeId = cdd.actionPrototypeId
	self.effect = cdd.effect
	self.beforeOpenEffect = cdd.effectBeforeOpen
	self.unlockFailedAnim = cdd.unlockFailedAnim
	self.needItem = cdd.needItem
	self.showDetail = cdd.showDetail
	self.unlockSound = cdd.unlockSound
	self.unlockPawnSound = cdd.unlockPawnSound
	self.modelScale = cdd.modelScale or 1
	self.chestType = bdict.chestType or Const.ChestType.OwnerOpenAndOwnerGet
	self.chestVisibleType = bdict.chestVisibleType or Const.ChestVisibleType.All
	self.entityCanMove = cdd.nonKinematic and true or false
	self.enableVirtualChest = bdict.enableVirtualChest
	self.virtualChestPos = Vector3(unpack(bdict.virtualChestPos))
	self.isFirstCreate = bdict.firstEnterSpace
	self.homeSeasonCelebrationClaimed = false

	return true
end

function ClientChest:postInitializeComponents()
	ClientChest.super.postInitializeComponents(self)
end

function ClientChest:start()
	ClientChest.super.start(self)
end

function ClientChest:getConfigData()
	if not self.templateId then
		return {}
	end

	return chestData[self.templateId] or {}
end

function ClientChest:getChestType()
	if self.chestType then
		return self.chestType
	end

	local cdd = chestData[self.templateId]

	return cdd and cdd.chestType or Const.ChestType.OwnerOpenAndOwnerGet
end

function ClientChest:isConfigKinematic()
	local configData = self:getConfigData()

	return not configData.nonKinematic
end

function ClientChest:refreshAppearance()
	ClientChest.super.refreshAppearance(self)

	local cdd = self:getConfigData()

	if cdd.model then
		self:loadPrefabModel(cdd.model)
	end
end

function ClientChest:onPrefabModelLoaded()
	self:refreshChestOpened()

	if self:isChestOpened() then
		self:setPerformRecorderState("open")
	else
		self:setPerformRecorderState("close")
	end

	if self.eModel then
		self:setPositionAgentScale(self.modelScale)
	end

	self:onModelRefreshed()

	if self.enableVirtualChest then
		ClientUtils.createVirtualChest(self, self.virtualChestPos)
	end

	self:refreshChestValid()

	local bornPreset = self:getConfigData().bornPreset
	local presetDuration = self:getConfigData().bornPresetDuration

	self:playPreset(bornPreset, presetDuration, false, true)

	local sceneEntityData = self.space and SceneUtils.getSceneEntityData(self.space.sceneId, self.space.id) or {}
	local sceneEntityInfo = sceneEntityData[self.staticId] or {}

	if sceneEntityInfo.fixedScale and sceneEntityInfo.fixedScale ~= 0 and self.eModel then
		local s = sceneEntityInfo.fixedScale

		self:setPositionAgentScale(s)
	end

	local enableBornTween = sceneEntityInfo.enableBornTween

	if self.isFirstCreate and enableBornTween then
		local tpx, tpy, tpz = self.eModel:GetPositionAgentPosEx()
		local targetPos = Vector3.New(tpx, tpy, tpz)

		EModelUtils.setAgentPosition(self, targetPos + sceneEntityInfo.bornTweenStartPos)
		DoTweenAnimMgr.Move(self.eModel.transform:GetChild(0), LuaUIUtils.TweenId(ID_CHEST_MOVE), targetPos, sceneEntityInfo.bornTweenTime, 0, CS.DG.Tweening.Ease.__CastFrom(sceneEntityInfo.bornTweenEaseType), function()
			return
		end)
	end

	if ClientSwitch.EnableHideChest then
		self:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.GM, false)
	end
end

function ClientChest:belongsToPlayer(player)
	local chestType = self:getChestType()

	if chestType == Const.ChestType.OwnerOpenAndOwnerGet then
		return self.ownerId == player.id
	elseif chestType == Const.ChestType.HomeGift then
		return self.space and not string.isNilOrEmpty(self.space.giftEventInsId) and self.space:isSelfHomeland(player)
	elseif chestType == Const.ChestType.HomeTillGift then
		return self.space and not string.isNilOrEmpty(self.space.tillGiftEventInsId) and not self.space.tillGiftOpened and self.space:isSelfHomeland(player)
	end

	return true
end

function ClientChest:checkCanInteract(unit)
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

function ClientChest:isChestOpened()
	return self.status == Const.INTERACTOR_STATUS.CHEST_OPENED
end

function ClientChest:interact(interactUnit)
	if self:isChestOpened() then
		return
	end

	local cData = self:getConfigData()

	if cData and cData.showDetail then
		local costId = cData.needItem[1] or 0
		local costNum = cData.needItem and cData.needItem[2] or 0
		local costInfo = LuaUIUtils.getItemInfoById(costId)
		local name = pg.getLocalizationText(cData.name)
		local costNumText = LuaUIUtils.getItemCountConsumeShowText(costId, costNum)

		pg.global.ui:open(UIConst.UI_ID_COMMON_USE_CONFIRM, {
			type = 3,
			title = pg.getFormatText(pg.getGameString("OPEN_CHEST"), name),
			tipTop = pg.getFormatText(pg.getGameString("OPEN_CHEST_COST_TIP"), name, costInfo.name, "", costNumText),
			dropId = cData.reward,
			confirmCb = function()
				local hasNum = ClientUtils.getItemCountById(costId)

				if hasNum < costNum then
					if InteractionConst.ChestInteractShowSpecialItemId[costId] and costId == Const.CommonEnergyType_Stamina then
						LuaUIUtils.openVitalityGot(Const.CommonEnergyType_Stamina)
					end
				else
					self:doInteract()
				end
			end
		})
	else
		self:doInteract()
	end
end

function ClientChest:doInteract()
	local now = Time.realtimeSinceStartup

	if self.lastChestInteractTime and now - self.lastChestInteractTime < CHEST_INTERACT_INTERVAL then
		return
	end

	self.lastChestInteractTime = now

	pg.global.ui:close(UIConst.UI_ID_COMMON_USE_CONFIRM)
	pg.me:startInteract(Const.IACT_TP_CHEST, self.id, self.actionPrototypeId, {}, function(ret, retArgs)
		if NoticeDef.SUCCESS == ret then
			facade:sendLuaEvent(self.staticId .. "chestOpen")
			pg.me:executePetAdditiveAIEvent("MasterOpenChestTrigger", {
				chestId = self.id
			})
		end
	end)
end

function ClientChest:refreshChestValid()
	local chestValid = Utils.isChestVisible(pg.me, self)

	if self.chestValid ~= chestValid then
		self.chestValid = chestValid

		self:setActive(ClientConst.MODEL_VISIBLE_KEY.CHEST_VALID, chestValid)
	end
end

function ClientChest:RPC_SC_OnUnlockStart()
	self:onUnlockStart()
	self:setAnimatorTrigger("SetOpen")
end

function ClientChest:setPerformRecorderState(archiveName)
	if not self.eModel or not self.eModel.itemModel then
		return
	end

	local performRecorder = self.eModel.itemModel:GetComponent("PerformRecorder")

	if archiveName and performRecorder then
		performRecorder:ApplyArchiveByName(archiveName)
	end
end

function ClientChest:onUnlockStart(fromEntId)
	self.eventEmitter:emit(EventConst.VIRTUAL_CHEST_UNLOCKSTART)

	local unlockEffect = self:getConfigData().unlockEffect

	if unlockEffect then
		self:playEffect(unlockEffect, {}, true)
	end

	local unlockPreset = self:getConfigData().unlockPreset
	local presetDuration = self:getConfigData().unlockPresetDuration

	self:playPreset(unlockPreset, presetDuration, false)

	if self.active and self.visible then
		if pg.me and pg.me:isControllingPet() then
			if self.unlockPawnSound then
				self:playSoundAtSelfPos(self.unlockPawnSound)
			end
		elseif self.unlockSound then
			self:playSoundAtSelfPos(self.unlockSound)
		end
	end

	self:playChestTrailEffect(fromEntId)
	self:setAnimatorTrigger("SetUnlock")
end

function ClientChest:playChestTrailEffect(fromEntId)
	if not fromEntId then
		return
	end

	local fromEnt = pg.getEntity(fromEntId)

	if not fromEnt then
		return
	end

	local trailEffect = self:getConfigData().trailEffect

	if trailEffect then
		local cpx, cpy, cpz = self.eModel:GetPositionAgentPosEx()
		local extraInfo = {
			position = Vector3.New(cpx, cpy, cpz),
			rotation = self:getRotation():ToEulerAngles(),
			followType = EffectConst.FollowType.Global,
			mountType = EffectConst.MountType.Motor,
			targetTransActorId = fromEnt.actorId,
			targetTransOffset = Vector3(0, fromEnt:getHeight() * 0.5, 0)
		}

		fromEnt:playEffect(trailEffect, extraInfo)
	end
end

function ClientChest:onInteractStart(fromEntId, targetType, actionPrototypeId, interactParams)
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

		self.rumbleChestTimer = self:addTimer(rumbleTime, function()
			self.rumbleChestTimer = nil

			pg.game.input:playRumbleByName(ClientConst.RumbleLayer.DEFAULT, cfgData.rumble)
		end)
	end

	if self.beforeOpenEffectId then
		self:stopEffectById(self.beforeOpenEffectId)

		self.beforeOpenEffectId = nil
	end
end

function ClientChest:onInteractInterrupt(fromEntId, targetType, actionPrototypeId, interactParams)
	self.eventEmitter:emit(EventConst.VIRTUAL_CHEST_INTERACTINTERRUPT)

	if not self.isModelLoaded or not self.eModel then
		return
	end

	if self.unlockChestTimer then
		self:removeTimer(self.unlockChestTimer)
	end

	if self.rumbleChestTimer then
		self:removeTimer(self.rumbleChestTimer)
	end

	self.unlockChestTimer = nil
	self.rumbleChestTimer = nil

	self:resetAnimator()
	self:refreshChestOpened()

	if self.unlockFailedAnim and self.eModel then
		self:animatorPlay(self.unlockFailedAnim)
	end
end

function ClientChest:onHomeSeasonCelebrationClaimed()
	self.homeSeasonCelebrationClaimed = true

	self:setAnimatorBool("IsOpen", true)

	if self.effectId then
		self:stopEffectById(self.effectId)

		self.effectId = nil
	end

	if self.beforeOpenEffectId then
		self:stopEffectById(self.beforeOpenEffectId)

		self.beforeOpenEffectId = nil
	end

	self:refreshInteractTriggerEvent()
end

function ClientChest:onInteractResult(fromEnt, actionPrototypeId)
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

	local isHomeSeasonCelebrationChest = self.chestType == Const.ChestType.HomeSeasonCelebration

	if isHomeSeasonCelebrationChest then
		self:onHomeSeasonCelebrationClaimed()
	end

	local chestCfg = chestData[self.templateId] or {}
	local mode = chestCfg.rewardAttractMode or Const.RewardAttractMode.Disabled

	if mode > 0 then
		ClientChestRewardAttractCtrl.register(self)
	end

	local destroyPreset = self:getConfigData().destroyPreset

	if destroyPreset then
		local presetDuration = self:getConfigData().destroyPresetDuration
		local delayTime = self:getConfigData().destroyPresetTime

		if self.destroyPresetTimer then
			self:removeTimer(self.destroyPresetTimer)

			self.destroyPresetTimer = nil
		end

		self.destroyPresetTimer = self:addTimer(delayTime, function()
			self.destroyPresetTimer = nil

			self:setCollideEnable(ClientConst.MODEL_VISIBLE_KEY.DESTROYING, false)
			self:playPreset(destroyPreset, presetDuration, false)

			if isHomeSeasonCelebrationChest then
				self.homeSeasonCelebrationHideTimer = self:addTimer(presetDuration, function()
					self.homeSeasonCelebrationHideTimer = nil

					self:setVisible(ClientConst.MODEL_VISIBLE_KEY.CHEST_OPENED, false, false)
				end)
			end
		end)
	end

	pg.me:postComponentMethod("OnPetProud")
end

function ClientChest:refreshChestOpened()
	self.eventEmitter:emit(EventConst.VIRTUAL_CHEST_REFRESHMODEL)

	if not self.isModelLoaded or not self.eModel then
		return
	end

	if self.homeSeasonCelebrationClaimed then
		self:setAnimatorBool("IsOpen", true)

		if self.effectId then
			self:stopEffectById(self.effectId)

			self.effectId = nil
		end

		if self.beforeOpenEffectId then
			self:stopEffectById(self.beforeOpenEffectId)

			self.beforeOpenEffectId = nil
		end

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

function ClientChest:getInteractionListData()
	if not self.actionPrototypeId or self.homeSeasonCelebrationClaimed then
		return nil
	end

	local interactionActionPrototypeId = self.actionPrototypeId

	if HomeSeasonCelebrationTestConst.ENABLED and self.chestType == Const.ChestType.HomeSeasonCelebration then
		interactionActionPrototypeId = HomeSeasonCelebrationTestConst.INTERACTION_ACTION_PROTOTYPE_ID
	end

	return {
		{
			actionPrototypeId = interactionActionPrototypeId,
			interactionType = InteractionConst.INTERACTION_TYPE_ENT_FUNC,
			globalId = self:getGlobalId(),
			needItem = self.needItem,
			showDetail = self.showDetail,
			name = self:getConfigData().name or ""
		}
	}
end

function ClientChest:on_status_changed(oldVal, newVal)
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

		self:setPerformRecorderState("open")
	else
		self:setPerformRecorderState("close")
	end
end

function ClientChest:preDestroy()
	if self.effectId then
		self:stopEffectById(self.effectId)

		self.effectId = nil
	end

	if self.beforeOpenEffectId then
		self:stopEffectById(self.beforeOpenEffectId)

		self.beforeOpenEffectId = nil
	end

	if self.homeSeasonCelebrationHideTimer then
		self:removeTimer(self.homeSeasonCelebrationHideTimer)

		self.homeSeasonCelebrationHideTimer = nil
	end

	local destroyPreset = self:getConfigData().destroyPreset

	if destroyPreset and self.eModel then
		local shaderView = self.eModel.shaderView

		if shaderView then
			ClientEffectUtils.StopPreset(self, destroyPreset)
		end

		if self.destroyPresetTimer then
			self:removeTimer(self.destroyPresetTimer)

			self.destroyPresetTimer = nil
		end
	end

	self:playDestroyEffect()
	ClientChest.super.preDestroy(self)
end

function ClientChest:destroy()
	self.eventEmitter:emit(EventConst.VIRTUAL_CHEST_DESTROY)
	ClientChestRewardAttractCtrl.onChestDestroyed(self.id)
	ClientChest.super.destroy(self)
end

function ClientChest:getPetGuideLevel()
	return self:getConfigData().petGuideLevel or 0
end

function ClientChest:getPetDetectiveViewLevel()
	return self:getConfigData().petDetectiveViewLevel or 0
end

function ClientChest:getPreloadEffects()
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

function ClientChest:playPreset(presetName, duration, disableWhenFinished, isBorn)
	if not presetName or not duration then
		return
	end

	if presetName == WIRE_DISSOLVE_PRESET then
		self:playWireFrameDissolveEffect(duration, nil, nil, isBorn)
	else
		ClientEffectUtils.PlayPreset(self, presetName, duration, false)
	end
end

function ClientChest:playWireFrameDissolveEffect(duration, endCallBack, offsetY, isBorn)
	duration = duration or 1
	offsetY = offsetY or 0

	local globalOffsetY = 0

	if self.eModel then
		local dissolveStartPosition = Vector3(0, 0, 0)
		local playerHeight = self:getHeight() + offsetY

		dissolveStartPosition.y = dissolveStartPosition.y + playerHeight + globalOffsetY

		local border = playerHeight * 1
		local startValue = isBorn and playerHeight - 0.1 + globalOffsetY or globalOffsetY
		local endValue = isBorn and globalOffsetY or playerHeight - 0.1 + globalOffsetY
		local disableWhenFinished = isBorn == true

		self.eModel.shaderView:PlayDissolveSurfaceEffectPreset("Eff_Character_Voxel_Dissolve", dissolveStartPosition, startValue, endValue, border, duration, nil, endCallBack, false, disableWhenFinished)
	end
end

function ClientChest:getDetectionMode()
	return 3
end

return ClientChest
