-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientCollectItem.lua

local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local TimerManager = require("Core.Timer.TimerManager")
local ClientInteractor = require("Entities.SpaceEntities.ClientInteractor")
local ClientAttachComponent = require("Entities.SpaceEntities.CommonComponent.ClientAttachComponent")
local Vector3 = Vector3
local Time = require("Core.Common.Time")
local NoticeDef = require("Common.NoticeDef")
local ClientEcologyComponent = require("Entities.SpaceEntities.CommonComponent.ClientEcologyComponent")
local ClientResPointComponent = require("Entities.SpaceEntities.CommonComponent.ClientResPointComponent")
local ClientGhostEyeDetectedComponent = require("Entities.SpaceEntities.PlayerComponent.ClientGhostEyeDetectedComponent")
local ClientVoxelComponent = require("Entities.SpaceEntities.CommonComponent.ClientVoxelComponent")
local ClientMagneticComponent = require("Entities.SpaceEntities.CommonComponent.ClientMagneticComponent")
local CollectItemData = require("Data.collect_item_data")
local InteractionConst = require("Common.Const.InteractionConst")
local DropUtils = require("Common.Utils.DropUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local EffectConst = require("Const.EffectConst")
local ItemProperties = require("CustomTypes.ItemProperties")
local ClientPrefabModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientPrefabModelComponent")
local ClientCollectItem = class.Class("ClientCollectItem", ClientInteractor)
local CollectItemComponents = {
	ClientAttachComponent,
	ClientEcologyComponent,
	ClientResPointComponent,
	ClientGhostEyeDetectedComponent,
	ClientVoxelComponent,
	ClientMagneticComponent,
	ClientPrefabModelComponent
}

if EnableBotTest then
	CollectItemComponents = {
		ClientEcologyComponent,
		ClientResPointComponent,
		ClientGhostEyeDetectedComponent
	}
end

class.AddComponents(ClientCollectItem, CollectItemComponents)

local WIRE_DISSOLVE_PRESET = "CharacterWireFrameDissolve"
local COLLECT_INTERACT_INTERVAL = 0.5

function ClientCollectItem:ctor(entityId)
	ClientCollectItem.super.ctor(self, entityId)
end

function ClientCollectItem:init(bdict)
	ClientCollectItem.super.init(self, bdict)

	local cdd = self:getConfigData()

	self.collectItemType = bdict.collectItemType or Const.CollectItemType.WhoOpenAndWhoGet
	self.collectItemVisibleType = bdict.collectItemVisibleType or Const.CollectItemVisibleType.All
	self.isMultiple = bdict.isMultiple or false
	self.quality = cdd.quality
	self.actionPrototypeId = cdd.actionPrototypeId
	self.reward = cdd.reward
	self.effect = cdd.effect
	self.modelScale = cdd.modelScale or 1
	self.isCollectItem = true
	self.bloomItem = bdict.bloomItem
	self.props = ItemProperties(bdict.props)

	if pg.space:isGrabEgg() then
		self:parseItemQuality()
	end

	return true
end

function ClientCollectItem:parseItemQuality()
	local dropId = self:getConfigData().reward or 0
	local itemDict = DropUtils.genDropDisplayInfo(dropId)
	local itemId = table.firstOrDefault(itemDict)
	local itemInfo = LuaUIUtils.getItemInfoById(itemId)
	local quality = self.quality or UIConst.QUALITY.WHITE

	if itemInfo then
		quality = itemInfo.quality
	end

	self.quality = quality
end

function ClientCollectItem:postInitializeComponents()
	ClientCollectItem.super.postInitializeComponents(self)
end

function ClientCollectItem:start()
	ClientCollectItem.super.start(self)
end

function ClientCollectItem:getConfigData()
	if not self.templateId then
		return {}
	end

	return CollectItemData[self.templateId] or {}
end

function ClientCollectItem:getCollectItemType()
	if self.collectItemType then
		return self.collectItemType
	end

	local cdd = CollectItemData[self.templateId]

	return cdd and cdd.collectItemType or Const.CollectItemType.WhoOpenAndWhoGet
end

function ClientCollectItem:refreshAppearance()
	ClientCollectItem.super.refreshAppearance(self)

	local cdd = self:getConfigData()

	if cdd.model then
		self:loadPrefabModel(cdd.model)
	end
end

function ClientCollectItem:onPrefabModelLoaded()
	self:refreshCollectItemOpened()
	self:setPositionAgentScale(self.modelScale)
	self:onModelRefreshed()

	if self.bloomItem then
		self:setVisible(ClientConst.MODEL_VISIBLE_KEY.COLLECT_ITEM_CREATE, false)
		self:addTimer(1, function()
			self:setVisible(ClientConst.MODEL_VISIBLE_KEY.COLLECT_ITEM_CREATE, true)
		end)
	end

	if pg.space:isGrabEgg() then
		local effectKey = EffectConst.QUALITY_EFFECT[self.quality]

		self:playEffect(effectKey)
	end
end

function ClientCollectItem:playBloomEffect(startPos)
	local delay = math.random(0, 80) / 100

	self:addTimer(delay, function()
		local effectKey = EffectConst.BLOOM_QUALITY_EFFECT[self.quality]

		self:playEffectAt(effectKey, startPos, Vector3.zero, {
			endCallback = function()
				self:setVisible(ClientConst.MODEL_VISIBLE_KEY.COLLECT_ITEM_CREATE, true)
			end
		})
	end)
end

function ClientCollectItem:refreshCollectItemOpened()
	if not self.isModelLoaded or not self.eModel then
		return
	end

	local isOpened = self:isCollectItemOpened()

	if isOpened then
		self:setVisible(ClientConst.MODEL_VISIBLE_KEY.COLLECT_ITEM_OPENED, false, false)

		if self.effectId then
			self:stopEffectById(self.effectId)

			self.effectId = nil
		end
	elseif not self.effectId and self.effect then
		self.effectId = self:playEffect(self.effect)
	end
end

function ClientCollectItem:checkCanInteract(unit)
	if self.levelCondition == Const.LEVEL_CONDITION_OFF then
		return false
	end

	if self:attaching() then
		return false
	end

	return not self:isCollectItemOpened()
end

function ClientCollectItem:isCollectItemOpened()
	return self.status == Const.INTERACTOR_STATUS.COLLECT_ITEM_OPENED
end

function ClientCollectItem:getInteractionListData()
	return self:getDefaultInteractionListData()
end

function ClientCollectItem:getDefaultInteractionListData()
	return {
		{
			interactionType = InteractionConst.INTERACTION_TYPE_ENT_FUNC,
			actionPrototypeId = self.actionPrototypeId,
			globalId = self:getGlobalId(),
			needItem = self.needItem,
			name = self:getConfigData().name or "",
			interactFunc = function()
				if pg.space:isGrabEgg() and not pg.me:hasEquipBag() then
					pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_FULL_2"))

					return
				end

				if pg.space:isGrabEgg() and pg.me:isGrabEggBagFull() then
					pg.me:openNearbyItemInBag()

					return
				end

				self:interact()
			end
		}
	}
end

function ClientCollectItem:interact(interactUnit)
	if self:isCollectItemOpened() then
		return
	end

	local now = Time.realtimeSinceStartup

	if self.lastCollectInteractTime and now - self.lastCollectInteractTime < COLLECT_INTERACT_INTERVAL then
		return
	end

	self.lastCollectInteractTime = now

	self:doInteract()
end

function ClientCollectItem:doInteract()
	pg.me:startInteract(Const.IACT_IP_COLLECT_ITEM, self.id, self.actionPrototypeId, {}, function(ret, retArgs)
		if NoticeDef.SUCCESS == ret then
			self:refreshCollectItemOpened()
		else
			pg.global.showBubbleMessage(ret)
		end
	end)
end

function ClientCollectItem:onInteractStart(fromEntId, targetType, actionPrototypeId, interactParams)
	return
end

function ClientCollectItem:onInteractInterrupt(fromEntId, targetType, actionPrototypeId, interactParams)
	if not self.isModelLoaded or not self.eModel then
		return
	end

	self:refreshChestOpened()
end

function ClientCollectItem:onInteractResult(fromEnt, actionPrototypeId)
	if fromEnt ~= pg.me then
		return
	end

	local destroyPreset = self:getConfigData().destroyPreset

	if destroyPreset then
		local presetDuration = self:getConfigData().destroyPresetDuration
		local delayTime = self:getConfigData().destroyPresetTime

		if self.destroyPresetTimer then
			TimerManager.removeTimer(self.destroyPresetTimer)

			self.destroyPresetTimer = nil
		end

		self.destroyPresetTimer = TimerManager.addTimer(delayTime, function()
			self.destroyPresetTimer = nil

			self:setCollideEnable(ClientConst.MODEL_VISIBLE_KEY.DESTROYING, false)
			self:playPreset(destroyPreset, presetDuration, false)
		end)
	end

	pg.me:postComponentMethod("OnPetProud")
end

function ClientCollectItem:destroy()
	ClientCollectItem.super.destroy(self)
end

function ClientCollectItem:preDestroy()
	if self.effectId then
		self:stopEffectById(self.effectId)

		self.effectId = nil
	end

	local destroyPreset = self:getConfigData().destroyPreset

	if destroyPreset and self.eModel then
		ClientEffectUtils.StopPreset(self, destroyPreset)
	end

	if self.destroyPresetTimer then
		TimerManager.removeTimer(self.destroyPresetTimer)

		self.destroyPresetTimer = nil
	end

	ClientCollectItem.super.preDestroy(self)
end

return ClientCollectItem
