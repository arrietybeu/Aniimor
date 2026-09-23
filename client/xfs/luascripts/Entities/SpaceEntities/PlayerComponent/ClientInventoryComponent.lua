-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientInventoryComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local InventoryData = require("Data.inventory_data")
local messageName = require("Const.MessageName")
local ItemCdMap = require("Data.item_cd_map")
local ItemConstSourceData = require("Data.item_const_source_data")
local ItemBatchNotifySideData = require("Data.item_batch_notify_side_data")
local ItemData = require("Data.item_data")
local Utils = require("Common.Utils.Utils")
local QuickUseUtils = require("Utils.QuickUseUtils")
local bit = require("Common.Bitset")
local logger = LoggerManager.getLogger("ClientInventoryComponent")
local SysConfigData = require("Data.sys_config_data")
local ClientInventoryComponent = class.Component("ClientInventoryComponent")
local SOCIAL_PARTY_VOXEL_ITEM_ID = 700034
local SOCIAL_PARTY_REWARD_SOURCE_ID = ItemConstSourceData.ITEM_SOURCE_SOCIAL_PARTY_REWARD
local SOCIAL_PARTY_PET_REWARD_SOURCE_ID = ItemConstSourceData.ITEM_SOURCE_SOCIAL_PARTY_PET_REWARD

function ClientInventoryComponent:isSocialPartyRewardSource(source)
	return source == SOCIAL_PARTY_REWARD_SOURCE_ID or source == SOCIAL_PARTY_PET_REWARD_SOURCE_ID
end

function ClientInventoryComponent:hasSideNotifyConfig(source)
	if source == nil then
		return false
	end

	return ItemBatchNotifySideData[source] ~= nil
end

function ClientInventoryComponent:getSocialPartyPetRewardItemId()
	if SysConfigData == nil then
		return SOCIAL_PARTY_VOXEL_ITEM_ID
	end

	local cfg = SysConfigData.SOCIAL_PARTY_PET_AI_SINGLE_ITEM_NUM
	local cfgType = type(cfg)

	if cfgType ~= "table" and cfgType ~= "userdata" then
		return SOCIAL_PARTY_VOXEL_ITEM_ID
	end

	local itemId = tonumber(cfg[1])

	if itemId == nil then
		return SOCIAL_PARTY_VOXEL_ITEM_ID
	end

	return itemId
end

function ClientInventoryComponent:start()
	self.inventoryIds = {}

	for idx, _ in pairs(InventoryData) do
		if ItemUtils.isSupportedTypedInvId(idx) then
			self.inventoryIds[#self.inventoryIds + 1] = idx
		end
	end
end

local function handleInventoryBagChanged(self, oldVal, newVal)
	facade:SendMessageCommand(messageName.ON_BACKPACK_INFO_CHANGE)
end

function ClientInventoryComponent:on_invQuickSlot_changed(oldVal, newVal, k)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("zyl on_invQuickSlot_changed")
	end

	facade:SendMessageCommand(messageName.ON_BACKPACK_QUICK_BALL_CHANGE, {
		itemId = oldVal == 0 and newVal or oldVal
	})
end

function ClientInventoryComponent:on_invQuickSlot_itemInserted(index, id)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("xtf on_invQuickSlot_itemInserted")
	end

	facade:SendMessageCommand(messageName.ON_BACKPACK_QUICK_BALL_CHANGE, {
		itemId = id
	})
end

function ClientInventoryComponent:on_invQuickSlot_itemRemoved(index, id)
	facade:SendMessageCommand(messageName.ON_BACKPACK_QUICK_BALL_CHANGE, {
		itemId = id
	})
end

function ClientInventoryComponent:on_invEliteSlot_changed(oldVal, newVal, k)
	facade:SendMessageCommand(messageName.ON_BACKPACK_QUICK_BALL_CHANGE, {
		itemId = oldVal == 0 and newVal or oldVal
	})
end

function ClientInventoryComponent:on_invEliteSlot_itemInserted(index, id)
	facade:SendMessageCommand(messageName.ON_BACKPACK_QUICK_BALL_CHANGE, {
		itemId = id
	})
end

function ClientInventoryComponent:on_invEliteSlot_itemRemoved(index, id)
	facade:SendMessageCommand(messageName.ON_BACKPACK_QUICK_BALL_CHANGE, {
		itemId = id
	})
end

function ClientInventoryComponent:on_invConsumeSlot_changed(oldVal, newVal)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("zyl on_invConsumeItem_changed")
	end

	facade:SendMessageCommand(messageName.ON_BACKPACK_QUICK_PLAYER_ITEM_CHANGE)
end

local function handleInventoryItemStatusChanged(self, ov, nv, invId, genId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("mk handleInventoryItemStatusChanged")
	end

	local change = bit.bxor(ov, nv)
	local value = bit.lshift(1, ItemConst.ITEM_STATUS_LOCKED)

	if bit.band(change, value) == value then
		facade:SendMessageCommand(messageName.ITEM_GEN_STATUS_LOCKED, {
			invId = invId,
			genId = genId
		})
	end
end

function ClientInventoryComponent:on_commonMoneyNums_changed(ov, nv, id)
	facade:sendMsgToUI(messageName.MONEY_COUNT_CHANGE, {
		id = id,
		oldNum = ov,
		newNum = nv
	})
	facade:SendMessageCommand(messageName.GRAB_EGG_RED_DOT_CHANGED)
end

function ClientInventoryComponent:on_moneyNegativeNums_changed(ov, nv, id)
	local newNum = self:getMoneyNum(id)
	local oldNum = newNum + (nv or 0) - (ov or 0)

	facade:sendMsgToUI(messageName.MONEY_COUNT_CHANGE, {
		id = id,
		oldNum = oldNum,
		newNum = newNum
	})
	facade:SendMessageCommand(messageName.GRAB_EGG_RED_DOT_CHANGED)
end

function ClientInventoryComponent:on_commonEnergyNums_changed(ov, nv, id)
	facade:sendMsgToUI(messageName.MONEY_COUNT_CHANGE, {
		id = id,
		oldNum = ov,
		newNum = nv
	})
	facade:SendMessageCommand(messageName.GRAB_EGG_RED_DOT_CHANGED)
end

local function notifyUseLimitMapChanged(limitId)
	facade:sendMsgToUI(messageName.USE_LIMIT_MAP_CHANGE, {
		limitId = limitId
	})
end

function ClientInventoryComponent:on_useLimitMap_changed(ov, nv, limitId)
	notifyUseLimitMapChanged(limitId)
end

function ClientInventoryComponent:on_useLimitMap_added(limitId, info)
	notifyUseLimitMapChanged(limitId)
end

function ClientInventoryComponent:on_useLimitMap_deleted(limitId, info)
	notifyUseLimitMapChanged(limitId)
end

function ClientInventoryComponent:on_useLimitMap_nextRefreshTs_changed()
	notifyUseLimitMapChanged()
end

local function handleInventoryItemCountChanged(self, ov, nv, invId, genId)
	facade:sendMsgToUI(messageName.ITEM_GEN_COUNT_CHANGE, {
		invId = invId,
		genId = genId,
		changeType = ItemConst.INV_GEN_CHANGE,
		oldNum = ov,
		newNum = nv
	})
end

local function handleInventoryItemPropsChanged(self, ov, nv, invId, genId)
	facade:SendMessageCommand(messageName.GRAB_EGG_EQUIP_PROP, {
		invId,
		genId
	})
end

local function handleInventoryItemAdded(self, genId, item, invId)
	facade:sendMsgToUI(messageName.ITEM_GEN_COUNT_CHANGE, {
		invId = invId,
		genId = genId,
		changeType = ItemConst.INV_GEN_ADD
	})
end

local function handleInventoryItemDeleted(self, genId, item, invId)
	facade:sendMsgToUI(messageName.ITEM_GEN_COUNT_CHANGE, {
		invId = invId,
		genId = genId,
		changeType = ItemConst.INV_GEN_DEL
	})
end

function ClientInventoryComponent:onPlayerItemBagChanged(ov, nv)
	handleInventoryBagChanged(self, ov, nv)
end

function ClientInventoryComponent:onPlayerItemStatusChanged(ov, nv, genId)
	handleInventoryItemStatusChanged(self, ov, nv, ItemConst.INV_TYPE_PLAYER, genId)
end

function ClientInventoryComponent:onPlayerItemCountChanged(ov, nv, genId)
	handleInventoryItemCountChanged(self, ov, nv, ItemConst.INV_TYPE_PLAYER, genId)
end

function ClientInventoryComponent:onPlayerItemPropsChanged(ov, nv, genId)
	handleInventoryItemPropsChanged(self, ov, nv, ItemConst.INV_TYPE_PLAYER, genId)
end

function ClientInventoryComponent:onPlayerItemAdded(genId, item)
	handleInventoryItemAdded(self, genId, item, ItemConst.INV_TYPE_PLAYER)
end

function ClientInventoryComponent:onPlayerItemDeleted(genId, item)
	handleInventoryItemDeleted(self, genId, item, ItemConst.INV_TYPE_PLAYER)
end

function ClientInventoryComponent:onPetItemBagChanged(ov, nv)
	handleInventoryBagChanged(self, ov, nv)
end

function ClientInventoryComponent:onPetItemStatusChanged(ov, nv, genId)
	handleInventoryItemStatusChanged(self, ov, nv, ItemConst.INV_TYPE_PET, genId)
end

function ClientInventoryComponent:onPetItemCountChanged(ov, nv, genId)
	handleInventoryItemCountChanged(self, ov, nv, ItemConst.INV_TYPE_PET, genId)
end

function ClientInventoryComponent:onPetItemPropsChanged(ov, nv, genId)
	handleInventoryItemPropsChanged(self, ov, nv, ItemConst.INV_TYPE_PET, genId)
end

function ClientInventoryComponent:onPetItemAdded(genId, item)
	handleInventoryItemAdded(self, genId, item, ItemConst.INV_TYPE_PET)
end

function ClientInventoryComponent:onPetItemDeleted(genId, item)
	handleInventoryItemDeleted(self, genId, item, ItemConst.INV_TYPE_PET)
end

function ClientInventoryComponent:onBallItemBagChanged(ov, nv)
	handleInventoryBagChanged(self, ov, nv)
end

function ClientInventoryComponent:onBallItemStatusChanged(ov, nv, genId)
	handleInventoryItemStatusChanged(self, ov, nv, ItemConst.INV_TYPE_BALL, genId)
end

function ClientInventoryComponent:onBallItemCountChanged(ov, nv, genId)
	handleInventoryItemCountChanged(self, ov, nv, ItemConst.INV_TYPE_BALL, genId)
end

function ClientInventoryComponent:onBallItemPropsChanged(ov, nv, genId)
	handleInventoryItemPropsChanged(self, ov, nv, ItemConst.INV_TYPE_BALL, genId)
end

function ClientInventoryComponent:onBallItemAdded(genId, item)
	handleInventoryItemAdded(self, genId, item, ItemConst.INV_TYPE_BALL)
end

function ClientInventoryComponent:onBallItemDeleted(genId, item)
	handleInventoryItemDeleted(self, genId, item, ItemConst.INV_TYPE_BALL)
end

function ClientInventoryComponent:onCommonItemBagChanged(ov, nv)
	handleInventoryBagChanged(self, ov, nv)
end

function ClientInventoryComponent:onCommonItemStatusChanged(ov, nv, genId)
	handleInventoryItemStatusChanged(self, ov, nv, ItemConst.INV_TYPE_COMMON, genId)
end

function ClientInventoryComponent:onCommonItemCountChanged(ov, nv, genId)
	handleInventoryItemCountChanged(self, ov, nv, ItemConst.INV_TYPE_COMMON, genId)
end

function ClientInventoryComponent:onCommonItemPropsChanged(ov, nv, genId)
	handleInventoryItemPropsChanged(self, ov, nv, ItemConst.INV_TYPE_COMMON, genId)
end

function ClientInventoryComponent:onCommonItemAdded(genId, item)
	handleInventoryItemAdded(self, genId, item, ItemConst.INV_TYPE_COMMON)
end

function ClientInventoryComponent:onCommonItemDeleted(genId, item)
	handleInventoryItemDeleted(self, genId, item, ItemConst.INV_TYPE_COMMON)
end

function ClientInventoryComponent:onTaskItemBagChanged(ov, nv)
	handleInventoryBagChanged(self, ov, nv)
end

function ClientInventoryComponent:onTaskItemStatusChanged(ov, nv, genId)
	handleInventoryItemStatusChanged(self, ov, nv, ItemConst.INV_TYPE_TASK, genId)
end

function ClientInventoryComponent:onTaskItemCountChanged(ov, nv, genId)
	handleInventoryItemCountChanged(self, ov, nv, ItemConst.INV_TYPE_TASK, genId)
end

function ClientInventoryComponent:onTaskItemPropsChanged(ov, nv, genId)
	handleInventoryItemPropsChanged(self, ov, nv, ItemConst.INV_TYPE_TASK, genId)
end

function ClientInventoryComponent:onTaskItemAdded(genId, item)
	handleInventoryItemAdded(self, genId, item, ItemConst.INV_TYPE_TASK)
end

function ClientInventoryComponent:onTaskItemDeleted(genId, item)
	handleInventoryItemDeleted(self, genId, item, ItemConst.INV_TYPE_TASK)
end

function ClientInventoryComponent:onPetJewelryItemBagChanged(ov, nv)
	handleInventoryBagChanged(self, ov, nv)
end

function ClientInventoryComponent:onPetJewelryItemStatusChanged(ov, nv, genId)
	handleInventoryItemStatusChanged(self, ov, nv, ItemConst.INV_TYPE_PET_JEWELRY, genId)
end

function ClientInventoryComponent:onPetJewelryItemCountChanged(ov, nv, genId)
	handleInventoryItemCountChanged(self, ov, nv, ItemConst.INV_TYPE_PET_JEWELRY, genId)
end

function ClientInventoryComponent:onPetJewelryItemPropsChanged(ov, nv, genId)
	handleInventoryItemPropsChanged(self, ov, nv, ItemConst.INV_TYPE_PET_JEWELRY, genId)
end

function ClientInventoryComponent:onPetJewelryItemAdded(genId, item)
	handleInventoryItemAdded(self, genId, item, ItemConst.INV_TYPE_PET_JEWELRY)
end

function ClientInventoryComponent:onPetJewelryItemDeleted(genId, item)
	handleInventoryItemDeleted(self, genId, item, ItemConst.INV_TYPE_PET_JEWELRY)
end

function ClientInventoryComponent:onHomelandItemBagChanged(ov, nv)
	handleInventoryBagChanged(self, ov, nv)
end

function ClientInventoryComponent:onHomelandItemStatusChanged(ov, nv, genId)
	handleInventoryItemStatusChanged(self, ov, nv, ItemConst.INV_TYPE_HOMELAND, genId)
end

function ClientInventoryComponent:onHomelandItemCountChanged(ov, nv, genId)
	handleInventoryItemCountChanged(self, ov, nv, ItemConst.INV_TYPE_HOMELAND, genId)
end

function ClientInventoryComponent:onHomelandItemPropsChanged(ov, nv, genId)
	handleInventoryItemPropsChanged(self, ov, nv, ItemConst.INV_TYPE_HOMELAND, genId)
end

function ClientInventoryComponent:onHomelandItemAdded(genId, item)
	handleInventoryItemAdded(self, genId, item, ItemConst.INV_TYPE_HOMELAND)
end

function ClientInventoryComponent:onHomelandItemDeleted(genId, item)
	handleInventoryItemDeleted(self, genId, item, ItemConst.INV_TYPE_HOMELAND)
end

function ClientInventoryComponent:onHomelandFurnitureItemBagChanged(ov, nv)
	handleInventoryBagChanged(self, ov, nv)
end

function ClientInventoryComponent:onHomelandFurnitureItemStatusChanged(ov, nv, genId)
	handleInventoryItemStatusChanged(self, ov, nv, ItemConst.INV_TYPE_HOMELAND_FURNITURE, genId)
end

function ClientInventoryComponent:onHomelandFurnitureItemCountChanged(ov, nv, genId)
	handleInventoryItemCountChanged(self, ov, nv, ItemConst.INV_TYPE_HOMELAND_FURNITURE, genId)
end

function ClientInventoryComponent:onHomelandFurnitureItemPropsChanged(ov, nv, genId)
	handleInventoryItemPropsChanged(self, ov, nv, ItemConst.INV_TYPE_HOMELAND_FURNITURE, genId)
end

function ClientInventoryComponent:onHomelandFurnitureItemAdded(genId, item)
	handleInventoryItemAdded(self, genId, item, ItemConst.INV_TYPE_HOMELAND_FURNITURE)
end

function ClientInventoryComponent:onHomelandFurnitureItemDeleted(genId, item)
	handleInventoryItemDeleted(self, genId, item, ItemConst.INV_TYPE_HOMELAND_FURNITURE)
end

function ClientInventoryComponent:onRobEggItemBagChanged(ov, nv)
	handleInventoryBagChanged(self, ov, nv)
end

function ClientInventoryComponent:onRobEggItemStatusChanged(ov, nv, genId)
	handleInventoryItemStatusChanged(self, ov, nv, ItemConst.INV_TYPE_ROB_EGG, genId)
end

function ClientInventoryComponent:onRobEggItemCountChanged(ov, nv, genId)
	handleInventoryItemCountChanged(self, ov, nv, ItemConst.INV_TYPE_ROB_EGG, genId)
end

function ClientInventoryComponent:onRobEggItemPropsChanged(ov, nv, genId)
	handleInventoryItemPropsChanged(self, ov, nv, ItemConst.INV_TYPE_ROB_EGG, genId)
end

function ClientInventoryComponent:onRobEggItemAdded(genId, item)
	handleInventoryItemAdded(self, genId, item, ItemConst.INV_TYPE_ROB_EGG)
end

function ClientInventoryComponent:onRobEggItemDeleted(genId, item)
	handleInventoryItemDeleted(self, genId, item, ItemConst.INV_TYPE_ROB_EGG)
end

function ClientInventoryComponent:onRobEggWarehouseItemBagChanged(ov, nv)
	handleInventoryBagChanged(self, ov, nv)
end

function ClientInventoryComponent:onRobEggWarehouseItemStatusChanged(ov, nv, genId)
	handleInventoryItemStatusChanged(self, ov, nv, ItemConst.INV_TYPE_ROB_EGG_WAREHOUSE, genId)
end

function ClientInventoryComponent:onRobEggWarehouseItemCountChanged(ov, nv, genId)
	handleInventoryItemCountChanged(self, ov, nv, ItemConst.INV_TYPE_ROB_EGG_WAREHOUSE, genId)
end

function ClientInventoryComponent:onRobEggWarehouseItemPropsChanged(ov, nv, genId)
	handleInventoryItemPropsChanged(self, ov, nv, ItemConst.INV_TYPE_ROB_EGG_WAREHOUSE, genId)
end

function ClientInventoryComponent:onRobEggWarehouseItemAdded(genId, item)
	handleInventoryItemAdded(self, genId, item, ItemConst.INV_TYPE_ROB_EGG_WAREHOUSE)
end

function ClientInventoryComponent:onRobEggWarehouseItemDeleted(genId, item)
	handleInventoryItemDeleted(self, genId, item, ItemConst.INV_TYPE_ROB_EGG_WAREHOUSE)
end

function ClientInventoryComponent:onEquipSlotsItemBagChanged(ov, nv)
	handleInventoryBagChanged(self, ov, nv)
end

function ClientInventoryComponent:onEquipSlotsItemStatusChanged(ov, nv, genId)
	handleInventoryItemStatusChanged(self, ov, nv, ItemConst.INV_TYPE_EQUIP_SLOTS, genId)
end

function ClientInventoryComponent:onEquipSlotsItemCountChanged(ov, nv, genId)
	handleInventoryItemCountChanged(self, ov, nv, ItemConst.INV_TYPE_EQUIP_SLOTS, genId)
end

function ClientInventoryComponent:onEquipSlotsItemPropsChanged(ov, nv, genId)
	handleInventoryItemPropsChanged(self, ov, nv, ItemConst.INV_TYPE_EQUIP_SLOTS, genId)
end

function ClientInventoryComponent:onEquipSlotsItemAdded(genId, item)
	handleInventoryItemAdded(self, genId, item, ItemConst.INV_TYPE_EQUIP_SLOTS)
end

function ClientInventoryComponent:onEquipSlotsItemDeleted(genId, item)
	handleInventoryItemDeleted(self, genId, item, ItemConst.INV_TYPE_EQUIP_SLOTS)
end

function ClientInventoryComponent:onReservedItemBagChanged(ov, nv)
	handleInventoryBagChanged(self, ov, nv)
end

function ClientInventoryComponent:onReservedItemStatusChanged(ov, nv, genId)
	handleInventoryItemStatusChanged(self, ov, nv, ItemConst.INV_TYPE_RESERVED, genId)
end

function ClientInventoryComponent:onReservedItemCountChanged(ov, nv, genId)
	handleInventoryItemCountChanged(self, ov, nv, ItemConst.INV_TYPE_RESERVED, genId)
end

function ClientInventoryComponent:onReservedItemPropsChanged(ov, nv, genId)
	handleInventoryItemPropsChanged(self, ov, nv, ItemConst.INV_TYPE_RESERVED, genId)
end

function ClientInventoryComponent:onReservedItemAdded(genId, item)
	handleInventoryItemAdded(self, genId, item, ItemConst.INV_TYPE_RESERVED)
end

function ClientInventoryComponent:onReservedItemDeleted(genId, item)
	handleInventoryItemDeleted(self, genId, item, ItemConst.INV_TYPE_RESERVED)
end

function ClientInventoryComponent:onFragmentItemBagChanged(ov, nv)
	handleInventoryBagChanged(self, ov, nv)
end

function ClientInventoryComponent:onFragmentItemStatusChanged(ov, nv, genId)
	handleInventoryItemStatusChanged(self, ov, nv, ItemConst.INV_TYPE_FRAGMENT, genId)
end

function ClientInventoryComponent:onFragmentItemCountChanged(ov, nv, genId)
	handleInventoryItemCountChanged(self, ov, nv, ItemConst.INV_TYPE_FRAGMENT, genId)
end

function ClientInventoryComponent:onFragmentItemPropsChanged(ov, nv, genId)
	handleInventoryItemPropsChanged(self, ov, nv, ItemConst.INV_TYPE_FRAGMENT, genId)
end

function ClientInventoryComponent:onFragmentItemAdded(genId, item)
	handleInventoryItemAdded(self, genId, item, ItemConst.INV_TYPE_FRAGMENT)
end

function ClientInventoryComponent:onFragmentItemDeleted(genId, item)
	handleInventoryItemDeleted(self, genId, item, ItemConst.INV_TYPE_FRAGMENT)
end

function ClientInventoryComponent:on_unboundMoney_changed(oldVal, newVal)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("on_unboundMoney_changed old %d new %d", oldVal, newVal)
	end

	facade:SendMessageCommand(messageName.MONEY_UNBOUND_CHANGE, {
		value = newVal,
		oldVlue = oldVal,
		itemId = ItemConst.ITEM_SPECIAL_MONEY_COIN
	})
end

function ClientInventoryComponent:RPC_SC_OnUpdateItemCanUseTime(cdId, nextTs)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_OnUpdateItemCanUseTime", cdId, nextTs)
	end

	for _, itemId in pairs(ItemCdMap[cdId] or EMPTY_TABLE) do
		facade:sendMsgToUI(messageName.ITEM_USE_TIME_CHANGE, {
			itemId = itemId,
			nextTs = nextTs
		})

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("RPC_SC_OnUpdateItemCanUseTime update itemId:%d, next_timestamp:%d", itemId, nextTs)
		end
	end
end

function ClientInventoryComponent:_pushSocialPartyRewardItemTip(itemId, itemCount, items)
	local itemIdNum = tonumber(itemId)
	local count = tonumber(itemCount) or 0

	if itemIdNum == nil or count <= 0 then
		return
	end

	if ItemData[itemIdNum] == nil then
		return
	end

	if QuickUseUtils.isQuickUse(itemIdNum) then
		return
	end

	local data = {
		id = itemIdNum,
		num = count
	}

	if items then
		items[#items + 1] = data
	else
		pg.global.ui.tips:pushPropItem(data)
	end
end

function ClientInventoryComponent:_collectSocialPartyRewardItemTips(items, idNumDict, source)
	if self.isMainPlayer ~= true then
		return
	end

	if self:isSocialPartyRewardSource(source) ~= true then
		return
	end

	if self:hasSideNotifyConfig(source) == true then
		return
	end

	if type(idNumDict) ~= "table" then
		return
	end

	for itemId, numInfo in pairs(idNumDict) do
		local itemCount = ItemUtils.getItemCountFromNumInfo(numInfo)

		self:_pushSocialPartyRewardItemTip(itemId, itemCount, items)
	end
end

function ClientInventoryComponent:_tryShowSocialPartyRewardTips(idNumDict, source)
	local items = {}

	self:_collectSocialPartyRewardItemTips(items, idNumDict, source)

	if #items > 0 then
		pg.global.ui.tips:pushPropItemGroup({
			source = source,
			items = items
		})
	end
end

function ClientInventoryComponent:_tryNotifyCafePetCoinDrop(idNumDict, source)
	if self.isMainPlayer ~= true then
		return
	end

	if source ~= SOCIAL_PARTY_PET_REWARD_SOURCE_ID then
		return
	end

	if type(idNumDict) ~= "table" then
		return
	end

	local targetItemId = self:getSocialPartyPetRewardItemId()
	local coinNum = 0

	for itemId, numInfo in pairs(idNumDict) do
		local itemIdNum = tonumber(itemId)

		if itemIdNum == targetItemId then
			local itemCount = ItemUtils.getItemCountFromNumInfo(numInfo)

			if itemCount > 0 then
				coinNum = coinNum + itemCount
			end
		end
	end

	if coinNum <= 0 then
		return
	end

	pg.game.social:onCafePetCoinDrop(coinNum)
end

function ClientInventoryComponent:_tryHandleSocialPartyRewardNotify(idNumDict, source)
	self:_tryShowSocialPartyRewardTips(idNumDict, source)
	self:_tryNotifyCafePetCoinDrop(idNumDict, source)
end

function ClientInventoryComponent:_tryHandleSocialPartyRewardNotifyList(notifyList)
	if type(notifyList) ~= "table" then
		return
	end

	local sourceGroups = {}
	local sourceGroupMap = {}

	for _, notifyInfo in ipairs(notifyList) do
		if type(notifyInfo) == "table" then
			local idNumDict = notifyInfo[1]
			local source = notifyInfo[2]
			local sourceKey = source == nil and "__nil_source__" or source
			local sourceGroup = sourceGroupMap[sourceKey]

			if sourceGroup == nil then
				sourceGroup = {
					source = source,
					items = {}
				}
				sourceGroupMap[sourceKey] = sourceGroup
				sourceGroups[#sourceGroups + 1] = sourceGroup
			end

			self:_collectSocialPartyRewardItemTips(sourceGroup.items, idNumDict, source)
			self:_tryNotifyCafePetCoinDrop(idNumDict, source)
		end
	end

	for _, sourceGroup in ipairs(sourceGroups) do
		if #sourceGroup.items > 0 then
			pg.global.ui.tips:pushPropItemGroup({
				source = sourceGroup.source,
				items = sourceGroup.items
			})
		end
	end
end

function ClientInventoryComponent:RPC_SC_OnChangeMoney(moneyType, oldValue, newValue, sourceId, subSourceId)
	self.logger:info("RPC_SC_onChangeMoney moneyType:%d, old:%d, new:%d, sourceId:%d, subSourceId:%d", moneyType, oldValue, newValue, sourceId, subSourceId)
	facade:sendMsgToUI(messageName.CURRENCY_CHANGE)
	self:postComponentMethod("EVNET_OnMoneyChange", moneyType, oldValue, newValue)
end

function ClientInventoryComponent:RPC_SC_OnNotifyItems(idNumDict, source, context)
	self:_tryHandleSocialPartyRewardNotify(idNumDict, source)
	facade:sendMsgToUI(messageName.ON_NOTIFY_ITEM, {
		idNumDict,
		source,
		context
	})
end

function ClientInventoryComponent:RPC_SC_OnNotifyItemsBatch(notifyList, notifySource)
	self:_tryHandleSocialPartyRewardNotifyList(notifyList)
	facade:sendMsgToUI(messageName.ON_NOTIFY_ITEM_BATCH, {
		notifyList,
		notifySource
	})
end

function ClientInventoryComponent:RPC_SC_OnItemCompound(result)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("onItemCompound", result)
	end

	facade:sendMsgToUI(messageName.ITEM_COMPOUND_REFRESH, {
		result
	})
end

function ClientInventoryComponent:on_itemCountMap_change(oldVal, newVal, itemId)
	facade:sendMsgToUI(messageName.ITEM_COUNT_MAP_CHANGE, {
		itemId = itemId
	})
	facade:SendMessageCommand(messageName.GRAB_EGG_RED_DOT_CHANGED)
end

function ClientInventoryComponent:setQuickSlotBall(slotType, index, itemId, mode)
	self:serverMsg("RPC_CS_SetQuickSlotBall", slotType, index, itemId, mode or ItemConst.QUICK_SLOT_SET_MODE_SWAP)
end

function ClientInventoryComponent:setQuickSlotItem(index, itemId)
	self:serverMsg("RPC_CS_SetQuickSlotItem", index, itemId)
end

function ClientInventoryComponent:getMoneyNum(moneyType)
	return ItemUtils.getItemCountById(self, moneyType)
end

function ClientInventoryComponent:getItemCountById(itemId, includeLocked)
	return ItemUtils.getItemCountById(self, itemId, includeLocked)
end

function ClientInventoryComponent:getItemCountByIdWithBind(itemId, isBind, includeLocked)
	return ItemUtils.getItemCountByIdWithBind(self, itemId, isBind, includeLocked)
end

return ClientInventoryComponent
