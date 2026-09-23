-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientResourceBox.lua

local class = require("Core.Framework.Class")
local ClientInteractor = require("Entities.SpaceEntities.ClientInteractor")
local GrabEggData = require("Data.rob_egg_chest_data")
local QtePhaseEffectData = require("Data.qte_phase_effect_data")
local SysConfigData = require("Data.sys_config_data")
local Const = require("Common.Const.Const")
local ItemConst = require("Common.Const.ItemConst")
local ClientConst = require("Const.ClientConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local EffectConst = require("Const.EffectConst")
local Utils = require("Common.Utils.Utils")
local lume = require("Core.Common.lume")
local TimerManager = require("Core.Timer.TimerManager")
local MessageName = require("Const.MessageName")
local NoticeDef = require("Common.NoticeDef")
local ClientPrefabModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientPrefabModelComponent")
local ClientPhysicsComponent = require("Entities.SpaceEntities.CommonComponent.ClientPhysicsComponent")
local ClientResourceBox = class.Class("ClientResourceBox", ClientInteractor)
local Components = {
	ClientPrefabModelComponent
}

class.AddComponents(ClientResourceBox, Components)

local UIConst = require("Const.UIConst")
local InteractionConst = require("Common.Const.InteractionConst")
local ToBool = ToBool

function ClientResourceBox:ctor(entityId)
	ClientResourceBox.super.ctor(self, entityId)

	self.isResourceBox = true
end

function ClientResourceBox:init(bdict)
	ClientResourceBox.super.init(self, bdict)

	self.subType = bdict.subType
	self.interactList = {
		{
			actionPrototypeId = ItemConst.ROB_EGG_INTERACT_TYPE.EQUIP,
			interactionType = InteractionConst.INTERACTION_TYPE_ENT_FUNC,
			globalId = self:getGlobalId(),
			name = self:getConfigData().name or "",
			interactFunc = function()
				self:pick(pg.me)
			end
		},
		{
			actionPrototypeId = ItemConst.ROB_EGG_INTERACT_TYPE.SWITCH,
			interactionType = InteractionConst.INTERACTION_TYPE_ENT_FUNC,
			globalId = self:getGlobalId(),
			name = self:getConfigData().name or "",
			interactFunc = function()
				self:pick(pg.me)
			end
		},
		{
			actionPrototypeId = ItemConst.ROB_EGG_INTERACT_TYPE.OPEN,
			interactionType = InteractionConst.INTERACTION_TYPE_ENT_FUNC,
			globalId = self:getGlobalId(),
			name = self:getConfigData().name or "",
			interactFunc = function()
				self:open(pg.me)
			end
		},
		{
			actionPrototypeId = ItemConst.ROB_EGG_INTERACT_TYPE.OPEN_NEST,
			interactionType = InteractionConst.INTERACTION_TYPE_ENT_FUNC,
			globalId = self:getGlobalId(),
			name = self:getConfigData().name or "",
			interactFunc = function()
				self:openEggNest(pg.me)
			end
		}
	}
	self.templateId = bdict.templateId
	self.entityCanMove = self:getConfigData().nonKinematic and true or false

	if self.entityCanMove then
		self.isClientEnt = false
	end

	self.waitServerOpenMark = false

	return true
end

function ClientResourceBox:postInitializeComponents()
	ClientResourceBox.super.postInitializeComponents(self)
end

function ClientResourceBox:on_isOpened_changed(oldValue, newValue)
	self:refreshChestOpened()

	if newValue then
		local unlockSound = self:getConfigData().unlockSound

		if unlockSound then
			self:playSoundAtSelfPos(unlockSound)
		end
	end
end

function ClientResourceBox:checkCanActualInteract()
	if pg.me and (pg.me:isControllingEgg() or pg.me:CARRY_EGG_ST()) then
		pg.global.showBubbleMessageById(NoticeDef.ROB_EGG_FORBID_CUR_ACTION)

		return false
	end

	return true
end

function ClientResourceBox:getConfigData()
	if not self.templateId then
		return {}
	end

	return GrabEggData[self.templateId] or {}
end

function ClientResourceBox:canBeLocked()
	if not self.isModelLoaded then
		return false
	end

	return self.subType == Const.ROB_EGG_LOOT_TYPE.BREAKABLE
end

function ClientResourceBox:getBodySize(partId)
	if not self.isModelLoaded then
		return 0
	end

	return self.eModel:GetMeshSize(Const.COMPONENT_IDX_ITEM, 0)
end

function ClientResourceBox:getLockPartPosition(partId)
	if not self.isModelLoaded then
		return self:getPosition()
	end

	local height = self.eModel:GetMeshSize(Const.COMPONENT_IDX_ITEM, 1) * 0.5

	return self:getPosition() + Vector3(0, 1, 0) * height
end

function ClientResourceBox:refreshAppearance()
	ClientResourceBox.super.refreshAppearance(self)

	local cdd = self:getConfigData()

	if cdd.model then
		self:loadPrefabModel(cdd.model)
	end
end

function ClientResourceBox:isConfigKinematic()
	local configData = self:getConfigData()

	return not configData.nonKinematic
end

function ClientResourceBox:onPrefabModelLoaded()
	if self.eModel then
		self.eModel:SetDisableLockRaycast()
	end

	self:postComponentMethod("EVENT_OnModelRefreshed")
	self:refreshChestOpened()

	if self:isSemanticallyEggNest() then
		self:initEggNestEffect()
	end
end

function ClientResourceBox:refreshChestOpened()
	if self.isOpened then
		self:setAnimatorBool("IsOpen", true)
		self:setAnimatorTrigger("SetOpen")
	end

	if self.subType == Const.ROB_EGG_LOOT_TYPE.PLAYER_BAG then
		local itemInfo = LuaUIUtils.getItemInfoById(self.templateId)

		if itemInfo then
			local effectKey = EffectConst.QUALITY_EFFECT[itemInfo.quality]

			self:playEffect(effectKey)
		end
	end

	self:setCustomEffect(self.isOpened)
end

function ClientResourceBox:checkCanInteract(unit)
	if pg.me:isControllingEgg() then
		return false
	end

	if self:isSemanticallyEggNest() then
		if ToBool(self.openingUid) then
			return false
		end

		if self.openProgress >= 100 then
			return false
		end
	end

	return true
end

function ClientResourceBox:getInteractionListData()
	if self.subType == Const.ROB_EGG_LOOT_TYPE.RESOURCE_BOX or self.subType == Const.ROB_EGG_LOOT_TYPE.DEATH_BOX then
		return {
			self.interactList[3]
		}
	elseif self:isSemanticallyEggNest() then
		return {
			self.interactList[4]
		}
	elseif self.subType == Const.ROB_EGG_LOOT_TYPE.PLAYER_BAG then
		if pg.me:hasEquipBag() then
			return {
				self.interactList[3]
			}
		else
			return {
				self.interactList[1],
				self.interactList[3]
			}
		end
	else
		return nil
	end
end

function ClientResourceBox:pick(entity)
	if not self:checkCanActualInteract() then
		return
	end

	if self.subType == Const.ROB_EGG_LOOT_TYPE.PLAYER_BAG then
		entity:serverMsg("RPC_CS_InteractRegEggEntity", self.id, ItemConst.ROB_EGG_TOUCH_TYPE.PICK)
	end
end

function ClientResourceBox:open(entity)
	if not self:checkCanActualInteract() then
		return
	end

	local openingBox = pg.me.openingBox

	if ToBool(openingBox) then
		pg.me:serverMsg("RPC_CS_InteractRegEggEntity", openingBox, ItemConst.ROB_EGG_TOUCH_TYPE.CLOSE)
	end

	entity:serverMsg("RPC_CS_InteractRegEggEntity", self.id, ItemConst.ROB_EGG_TOUCH_TYPE.OPEN)
end

function ClientResourceBox:openEggNest(entity)
	if self.openProgress >= 100 then
		return
	end

	if ToBool(self.openingUid) then
		return
	end

	if not self:checkCanActualInteract() then
		return
	end

	local openingBox = pg.me.openingBox

	if ToBool(openingBox) then
		if openingBox == self.id then
			return
		end

		local openingBoxEnt = pg.getEntity(openingBox)

		if openingBoxEnt and openingBoxEnt.isSemanticallyEggNest and openingBoxEnt:isSemanticallyEggNest() then
			pg.me:tryCancelDigEgg()
		else
			pg.me:serverMsg("RPC_CS_InteractRegEggEntity", openingBox, ItemConst.ROB_EGG_TOUCH_TYPE.CLOSE)
		end
	end

	if entity:isControllingPet() then
		entity:requestSwitchToPlayer(Const.CLIENT_SWITCH_REASON.ManualSwitch)
	end

	if self.waitServerOpenMark then
		self.logger:error("[EggNest]: @hyj on open EggNest multiTimes, selfActorId, selfId, openingBox", self.actorId, self.id, openingBox)

		return
	end

	self.waitServerOpenMark = true

	entity:serverMsg("RPC_CS_InteractRegEggEntity", self.id, ItemConst.ROB_EGG_TOUCH_TYPE.OPEN, function()
		self.waitServerOpenMark = false

		pg.me:startDigEgg(self.actorId)

		self.delayStopEffectTimer = self:addTimer(1, function()
			self:triggerEggNestTopBloom()

			self.delayStopEffectTimer = nil
		end)
		self.delayStartQteTimer = self:addTimer(SysConfigData.digEggDelayQteTime or 2.5, function()
			self:startDigEggQte()

			self.delayStartQteTimer = nil
		end)
	end)
end

function ClientResourceBox:opened(items)
	local boxType

	if self.subType == Const.ROB_EGG_LOOT_TYPE.DEATH_BOX then
		if self.isPlayer then
			boxType = UIConst.GRAB_EGG_BAG_TYPE.DEATH_BOX_PLAYER
		else
			boxType = UIConst.GRAB_EGG_BAG_TYPE.DEATH_BOX_MONSTER
		end
	elseif self.subType == Const.ROB_EGG_LOOT_TYPE.RESOURCE_BOX then
		boxType = UIConst.GRAB_EGG_BAG_TYPE.RESOURCE_BOX
	elseif self.subType == Const.ROB_EGG_LOOT_TYPE.PLAYER_BAG then
		boxType = UIConst.GRAB_EGG_BAG_TYPE.PLAYER_BAG
	else
		return
	end

	local lootDelayTime = self:getConfigData().lootDelayTime or 0
	local info = {
		id = self.id,
		items = items,
		bagType = boxType,
		closeFunc = function()
			self:close()
		end,
		name = self:getConfigData().name
	}

	if self.isOpening then
		return
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_GRAB_EGGS_BAG) then
		local ctrl = pg.global.ui:tryGetCtrlByUid(UIConst.UI_ID_GRAB_EGGS_BAG)

		if ctrl and ctrl.model and ctrl.model:getBoxEntityId() == self.id then
			return
		end

		info.reOpen = true

		pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_BAG, info)

		return
	end

	if self.openBagTimer then
		return
	end

	self.openBagTimer = TimerManager.addTimer(lootDelayTime, function()
		self.openBagTimer = nil
		self.isOpening = true

		pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_BAG, info, function()
			self.isOpening = false
		end)
	end)
end

function ClientResourceBox:startDigEggQte()
	local mainQteGroupId = "QTE_DIGEGG02"

	local function qteMainCb(eventName, info)
		if eventName == "qtePartHit" then
			local hitPercent = info.clipHitPercent

			self:triggerDigEggEffect(hitPercent)

			local controllerComponent = pg.me:getEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER)

			if NotNil(controllerComponent) then
				controllerComponent.abilityCharacterStateInfo.abilityQteInput = true
			end

			pg.game.camera:playCameraShakeById(pg.me, ItemConst.DIG_EGG_CAMERA_SHAKE_ID)
			self:playEffect("Eff_Env_Avatar_GrabEgg_NestOpenLoop")
		elseif eventName == "qteDigEggGood" then
			pg.me:serverMsg("RPC_CS_OpenResourceBoxWithQTE", self.id, 100)
			self:close()
			pg.me:finishDigEgg()

			local vanishEffectKey = ItemConst.ROB_EGG_NEST_QUALITY_TO_VANISH_EFFECT_KEY[self.eggQuality]

			if vanishEffectKey then
				self:playEffect(vanishEffectKey)
			end

			self:playEffect("Eff_Env_Avatar_GrabEgg_SBreakNest")
		end
	end

	pg.game.qte:startQte(pg.me.actorId, mainQteGroupId, {
		src = Const.QTE_SRC.DigEgg,
		triggerCallback = qteMainCb,
		exitFunc = function()
			pg.me:tryCancelDigEgg()
		end
	})
end

function ClientResourceBox:onCancelDigEgg()
	self.waitServerOpenMark = false

	self:stopEffect("Eff_Env_Avatar_GrabEgg_NestOpenLoop")

	if self.effectOnNotInteraction == nil and self.openProgress < 100 then
		self.effectOnNotInteraction = self:playEffect("Eff_Env_Avatar_GrabEgg_Sstack_KeyItem_Whole")
	end

	if self.delayStartQteTimer ~= nil then
		self:removeTimer(self.delayStartQteTimer)

		self.delayStartQteTimer = nil
	end

	if self.delayStopEffectTimer ~= nil then
		self:removeTimer(self.delayStopEffectTimer)

		self.delayStopEffectTimer = nil
	end

	self:close()
end

function ClientResourceBox:triggerDigEggEffect(percent)
	local progressInfo = self:getQteProgressInfo()
	local curPhase = self:getQteEffectPhaseByProgress(progressInfo, percent)
	local realServerPhase = self:getQteEffectPhaseByProgress(progressInfo, self.openProgress / 100)

	if realServerPhase < curPhase then
		pg.me:serverMsg("RPC_CS_OpenResourceBoxWithQTE", self.id, percent * 100 - self.openProgress)
	end
end

function ClientResourceBox:playInitDigEggEffect()
	if self.qteEffectId > 0 then
		if self.curPhaseEffect ~= nil then
			self:stopEffectById(self.curPhaseEffect)

			self.curPhaseEffect = nil
		end

		local phaseEffectData = QtePhaseEffectData[self.qteEffectId]

		if phaseEffectData then
			local progressInfo = phaseEffectData.stageInfo
			local realServerProgress = self.openProgress / 100
			local realServerPhase = 0

			for i = #progressInfo, 1, -1 do
				if realServerProgress >= progressInfo[i][1] then
					realServerPhase = i

					break
				end
			end

			local qteEffectKey = progressInfo[realServerPhase][2]

			if qteEffectKey then
				self.curPhaseEffect = self:playEffect(qteEffectKey)
			end
		end
	end
end

function ClientResourceBox:initEggNestEffect()
	if self.openProgress >= 100 then
		local archiveName = self:getConfigData().performRecorderPresetName or "Archive_2"

		self:setPerformRecorderState(archiveName)
	else
		self.effectOnNotInteraction = self:playEffect("Eff_Env_Avatar_GrabEgg_Sstack_KeyItem_Whole")
	end
end

function ClientResourceBox:triggerEggNestTopBloom()
	if self.effectOnNotInteraction then
		self:stopEffectById(self.effectOnNotInteraction, false)

		self.effectOnNotInteraction = nil

		self:playSoundEvent("GrabEgg_QTENest_TopBloom")
	end
end

function ClientResourceBox:getQteEffectPhaseByProgress(progressInfo, progress)
	if not progressInfo then
		return 0
	end

	local maxPhase = #progressInfo
	local curPhase = 0

	for i = maxPhase, 1, -1 do
		if progress >= progressInfo[i][1] then
			curPhase = i

			break
		end
	end

	return curPhase
end

function ClientResourceBox:getQteProgressInfo()
	if not self.qteEffectId or self.qteEffectId <= 0 then
		return nil
	end

	local phaseEffectData = QtePhaseEffectData[self.qteEffectId]

	if not phaseEffectData then
		return nil
	end

	return phaseEffectData.stageInfo
end

function ClientResourceBox:setCustomEffect(isOpen)
	local forbidDissolveEffect = self:isSemanticallyEggNest()

	if isOpen then
		if self.curHangUpEffectId then
			self:stopEffectById(self.curHangUpEffectId)

			self.curHangUpEffectId = nil
		end

		if not forbidDissolveEffect then
			local archiveName = self:getConfigData().performRecorderPresetName

			self:setPerformRecorderState(archiveName)
		end
	else
		local effectKey = self:getConfigData().effect

		if effectKey then
			self.curHangUpEffectId = self:playEffect(effectKey)
		end

		if not forbidDissolveEffect then
			local defaultArchiveName = "Archive_1"

			self:setPerformRecorderState(defaultArchiveName)
		end
	end
end

function ClientResourceBox:setPerformRecorderState(archiveName)
	if not self.eModel or not self.eModel.itemModel then
		return
	end

	local performRecorder = self.eModel.itemModel:GetComponent("PerformRecorder")

	if archiveName and performRecorder then
		performRecorder:ApplyArchiveByName(archiveName)
	end
end

function ClientResourceBox:isSemanticallyEggNest()
	return self.subType == Const.ROB_EGG_LOOT_TYPE.EGG_NEST or self.subType == Const.ROB_EGG_LOOT_TYPE.BOX_PUPPET
end

function ClientResourceBox:close()
	pg.me:serverMsg("RPC_CS_InteractRegEggEntity", self.id, ItemConst.ROB_EGG_TOUCH_TYPE.CLOSE)
end

function ClientResourceBox:preDestroy()
	if self.curPhaseEffect ~= nil then
		self:stopEffectById(self.curPhaseEffect)

		self.curPhaseEffect = nil
	end

	if self.effectOnNotInteraction ~= nil then
		self:stopEffectById(self.effectOnNotInteraction, false)

		self.effectOnNotInteraction = nil
	end

	if self.curHangUpEffectId then
		self:stopEffectById(self.curHangUpEffectId)

		self.curHangUpEffectId = nil
	end

	if self.delayStopEffectTimer ~= nil then
		self:removeTimer(self.delayStopEffectTimer)

		self.delayStopEffectTimer = nil
	end

	if self.delayStartQteTimer ~= nil then
		self:removeTimer(self.delayStartQteTimer)

		self.delayStartQteTimer = nil
	end

	self:playDestroyEffect()

	local destroySound = self:getConfigData().destroySound

	if destroySound then
		self:playSoundAtSelfPos(destroySound)
	end

	ClientResourceBox.super.preDestroy(self)
end

function ClientResourceBox:destroy()
	facade:SendMessageCommand(MessageName.GRAB_EGG_RESOURCE_BOX_DESTROYED, {
		id = self.id
	})
	ClientResourceBox.super.destroy(self)
end

function ClientResourceBox:onOpeningUidChange(old, new)
	self:refreshInteractTriggerEvent()

	if self:isSemanticallyEggNest() then
		if ToBool(new) then
			if new ~= pg.me.uid then
				self:triggerEggNestTopBloom()
			end
		elseif old ~= pg.me.uid and self.effectOnNotInteraction == nil and self.openProgress < 100 then
			self.effectOnNotInteraction = self:playEffect("Eff_Env_Avatar_GrabEgg_Sstack_KeyItem_Whole")
		end
	end
end

function ClientResourceBox:onOpenProgressChange(old, new)
	if self.curPhaseEffect ~= nil then
		self:stopEffectById(self.curPhaseEffect)

		self.curPhaseEffect = nil
	end

	if new >= 100 then
		local archiveName = self:getConfigData().performRecorderPresetName or "Archive_2"

		self:setPerformRecorderState(archiveName)
		self:playSoundEvent("GrabEgg_QTENest_AllBigBloom")

		return
	end

	local progressInfo = self:getQteProgressInfo()
	local curPhase = self:getQteEffectPhaseByProgress(progressInfo, self.openProgress / 100)

	if curPhase > 0 then
		local qteEffectKey = progressInfo[curPhase] and progressInfo[curPhase][2]

		if qteEffectKey then
			self.curPhaseEffect = self:playEffect(qteEffectKey)
		end
	end
end

function ClientResourceBox:getPreloadEffects()
	local preloadEffects = {}
	local configData = self:getConfigData()

	if configData.destroyEffect then
		table.insert(preloadEffects, configData.destroyEffect)
	end

	return preloadEffects
end

return ClientResourceBox
