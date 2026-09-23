-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\ItemBag\\ItemFactory.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local IDManager = require("Core.Common.IDManager")
local logger = LoggerManager.getLogger("ItemFactory")
local ItemUtils = require("Common.Utils.ItemUtils")
local Utils = require("Common.Utils.Utils")
local ItemConst = require("Common.Const.ItemConst")
local LootBoxItem = require("CustomTypes.LootBoxItem")
local HatchItemSnapshot = require("CustomTypes.HatchItemSnapshot")
local ItemData = require("Data.item_data")
local ServerUtils = require("GameServer.ServerUtils")
local lume = require("Core.Common.lume")
local Time = require("Core.Common.Time")
local ItemTTLUtils = require("Common.Utils.ItemTTLUtils")
local ItemFactory = class.Class("ItemFactory", nil, true)

ItemFactory.HATCH_ITEM_SNAPSHOT_SCHEMA_VERSION = 2
ItemFactory.HatchItemSnapshotError = {
	INVALID_INPUT = "invalid_input",
	PROJECTION_MISMATCH = "projection_mismatch",
	DECODE_FAILED = "decode_failed",
	UNSUPPORTED_VERSION = "unsupported_version",
	INVALID_ITEM = "invalid_item"
}

function ItemFactory:_normalizeItemPropsForCompare(props)
	local normalizedProps = {}

	for key, value in pairs(props) do
		if type(value) == "table" and next(value) == nil then
			normalizedProps[key] = {
				ORIGIN_MAP_KEY = "{}"
			}
		else
			normalizedProps[key] = value
		end
	end

	return normalizedProps
end

function ItemFactory:_isItemPropsEqual(actualProps, expectedProps)
	if Utils.isTableEqual(actualProps, expectedProps) then
		return true
	end

	return Utils.isTableEqual(self:_normalizeItemPropsForCompare(actualProps), self:_normalizeItemPropsForCompare(expectedProps))
end

function ItemFactory:_createExactSnapshot(item, removalCount, invId)
	if type(removalCount) ~= "number" or removalCount <= 0 or item.count ~= removalCount then
		return nil, self.HatchItemSnapshotError.INVALID_INPUT
	end

	local itemCfg = ItemData[item.id]
	local stackCount = itemCfg and ItemUtils.getItemStackCount(item.id)
	local configuredInvId = itemCfg and ItemUtils.getInvIdByItemId(item.id)
	local Item = invId and ItemUtils.requireTypedItemClassByInvId(invId)

	if not itemCfg or type(stackCount) ~= "number" or stackCount <= 0 or configuredInvId ~= invId then
		return nil, self.HatchItemSnapshotError.INVALID_ITEM
	end

	if not ItemUtils.isSupportedTypedInvId(invId) or not Item then
		return nil, self.HatchItemSnapshotError.INVALID_ITEM
	end

	local extraProp = item:getExtraProp()

	if extraProp == nil then
		if stackCount > 1 or item:stackable() then
			return nil, self.HatchItemSnapshotError.INVALID_ITEM
		end
	elseif type(extraProp) ~= "table" then
		return nil, self.HatchItemSnapshotError.INVALID_ITEM
	end

	local rawOk, rawItem = pcall(function()
		return item:getRawTable()
	end)

	if not rawOk or type(rawItem) ~= "table" then
		return nil, self.HatchItemSnapshotError.INVALID_ITEM
	end

	local encodeOk, payload = pcall(Utils.encodeToStr, rawItem)

	if not encodeOk or string.isNilOrEmpty(payload) then
		return nil, self.HatchItemSnapshotError.DECODE_FAILED
	end

	local decodeOk, decodedRaw = pcall(Utils.decodeFromStr, payload)

	if not decodeOk or type(decodedRaw) ~= "table" then
		return nil, self.HatchItemSnapshotError.DECODE_FAILED
	end

	if not Utils.isTableEqual(rawItem, decodedRaw) then
		return nil, self.HatchItemSnapshotError.PROJECTION_MISMATCH
	end

	local props = {}

	if ItemUtils.invTypeHasProps(invId) then
		props = Utils.deepCopyTable(rawItem.props or {})
	elseif rawItem.props ~= nil then
		return nil, self.HatchItemSnapshotError.PROJECTION_MISMATCH
	end

	local snapshot = HatchItemSnapshot()
	local initOk = pcall(snapshot.init, snapshot, {
		schemaVersion = self.HATCH_ITEM_SNAPSHOT_SCHEMA_VERSION,
		invId = invId,
		payload = payload,
		genID = rawItem.genID,
		objID = item:getObjID(),
		id = rawItem.id,
		count = rawItem.count,
		status = item:getStatus(),
		useTimes = item:getUseTimes(),
		extraProp = rawItem.extraProp or "",
		props = props,
		owner = item:getOwnerUid()
	})

	if not initOk then
		return nil, self.HatchItemSnapshotError.INVALID_ITEM
	end

	local snapshotProps = snapshot.props and snapshot.props:getRawTable() or {}

	if snapshot.genID ~= decodedRaw.genID or snapshot.objID ~= (decodedRaw.objID or "") or snapshot.id ~= decodedRaw.id or snapshot.count ~= decodedRaw.count or snapshot.status ~= (decodedRaw.status or 0) or snapshot.useTimes ~= (decodedRaw.useTimes or 0) or snapshot.extraProp ~= (decodedRaw.extraProp or "") or snapshot.owner ~= (decodedRaw.owner or "") or not self:_isItemPropsEqual(snapshotProps, decodedRaw.props or {}) then
		return nil, self.HatchItemSnapshotError.PROJECTION_MISMATCH
	end

	return snapshot
end

function ItemFactory:_createStackableSnapshot(itemId, sourceCount, removalCount, extraProp, owner, props, invId)
	if type(removalCount) ~= "number" or removalCount <= 0 or type(sourceCount) ~= "number" or sourceCount < removalCount then
		return nil, self.HatchItemSnapshotError.INVALID_INPUT
	end

	local itemCfg = ItemData[itemId]
	local stackCount = itemCfg and ItemUtils.getItemStackCount(itemId)
	local configuredInvId = itemCfg and ItemUtils.getInvIdByItemId(itemId)
	local Item = invId and ItemUtils.requireTypedItemClassByInvId(invId)

	if not itemCfg or type(stackCount) ~= "number" or stackCount <= 1 or configuredInvId ~= invId or extraProp ~= nil or not ItemUtils.isSupportedTypedInvId(invId) or not Item then
		return nil, self.HatchItemSnapshotError.INVALID_ITEM
	end

	local candidate = self:createItemIgnorePile(itemId, removalCount, extraProp, invId)

	if not candidate then
		return nil, self.HatchItemSnapshotError.INVALID_ITEM
	end

	candidate:setOwnerUid(owner)
	candidate:setProps(Utils.deepCopyTable(props or {}))

	local rawOk, rawCandidate = pcall(candidate.getRawTable, candidate)

	if not rawOk or type(rawCandidate) ~= "table" then
		return nil, self.HatchItemSnapshotError.INVALID_ITEM
	end

	local encodeOk, payload = pcall(Utils.encodeToStr, rawCandidate)

	if not encodeOk or string.isNilOrEmpty(payload) then
		return nil, self.HatchItemSnapshotError.DECODE_FAILED
	end

	local decodeOk, decodedRaw = pcall(Utils.decodeFromStr, payload)

	if not decodeOk or type(decodedRaw) ~= "table" then
		return nil, self.HatchItemSnapshotError.DECODE_FAILED
	end

	if not Utils.isTableEqual(rawCandidate, decodedRaw) then
		return nil, self.HatchItemSnapshotError.PROJECTION_MISMATCH
	end

	local props = {}

	if ItemUtils.invTypeHasProps(invId) then
		props = Utils.deepCopyTable(rawCandidate.props or {})
	elseif rawCandidate.props ~= nil then
		return nil, self.HatchItemSnapshotError.PROJECTION_MISMATCH
	end

	local snapshot = HatchItemSnapshot()
	local initOk = pcall(snapshot.init, snapshot, {
		schemaVersion = self.HATCH_ITEM_SNAPSHOT_SCHEMA_VERSION,
		invId = invId,
		payload = payload,
		genID = rawCandidate.genID,
		objID = candidate:getObjID(),
		id = rawCandidate.id,
		count = rawCandidate.count,
		status = candidate:getStatus(),
		useTimes = candidate:getUseTimes(),
		extraProp = rawCandidate.extraProp or "",
		props = props,
		owner = candidate:getOwnerUid()
	})

	if not initOk then
		return nil, self.HatchItemSnapshotError.INVALID_ITEM
	end

	local snapshotProps = snapshot.props and snapshot.props:getRawTable() or {}

	if snapshot.genID ~= decodedRaw.genID or snapshot.objID ~= (decodedRaw.objID or "") or snapshot.id ~= decodedRaw.id or snapshot.count ~= decodedRaw.count or snapshot.status ~= (decodedRaw.status or 0) or snapshot.useTimes ~= (decodedRaw.useTimes or 0) or snapshot.extraProp ~= (decodedRaw.extraProp or "") or snapshot.owner ~= (decodedRaw.owner or "") or not self:_isItemPropsEqual(snapshotProps, decodedRaw.props or {}) then
		return nil, self.HatchItemSnapshotError.PROJECTION_MISMATCH
	end

	return snapshot
end

function ItemFactory:_validateExactDeletion(snapshot, deletedItem)
	if snapshot.schemaVersion ~= self.HATCH_ITEM_SNAPSHOT_SCHEMA_VERSION or type(snapshot.invId) ~= "number" or string.isNilOrEmpty(snapshot.payload) then
		return nil, self.HatchItemSnapshotError.INVALID_ITEM
	end

	local itemCfg = ItemData[snapshot.id]
	local stackCount = itemCfg and ItemUtils.getItemStackCount(snapshot.id)
	local configuredInvId = itemCfg and ItemUtils.getInvIdByItemId(snapshot.id)

	if not itemCfg or type(stackCount) ~= "number" or stackCount <= 0 or configuredInvId ~= snapshot.invId or not ItemUtils.isSupportedTypedInvId(snapshot.invId) then
		return nil, self.HatchItemSnapshotError.INVALID_ITEM
	end

	local decodeOk, decodedRaw = pcall(Utils.decodeFromStr, snapshot.payload)

	if not decodeOk or type(decodedRaw) ~= "table" then
		return nil, self.HatchItemSnapshotError.DECODE_FAILED
	end

	return true
end

function ItemFactory:_validateStackableDeletion(snapshot, deletedItem)
	if snapshot.schemaVersion ~= self.HATCH_ITEM_SNAPSHOT_SCHEMA_VERSION or type(snapshot.invId) ~= "number" or string.isNilOrEmpty(snapshot.payload) then
		return nil, self.HatchItemSnapshotError.INVALID_ITEM
	end

	local itemCfg = ItemData[snapshot.id]
	local stackCount = itemCfg and ItemUtils.getItemStackCount(snapshot.id)
	local configuredInvId = itemCfg and ItemUtils.getInvIdByItemId(snapshot.id)

	if not itemCfg or type(stackCount) ~= "number" or stackCount <= 1 or configuredInvId ~= snapshot.invId or not ItemUtils.isSupportedTypedInvId(snapshot.invId) then
		return nil, self.HatchItemSnapshotError.INVALID_ITEM
	end

	assert(type(deletedItem) == "table" and deletedItem.id == snapshot.id and deletedItem.count == snapshot.count and deletedItem:getExtraProp() == nil and deletedItem:getOwnerUid() == snapshot.owner, "stackable deleted Item does not match snapshot")

	return true
end

function ItemFactory:_restoreExactItem(snapshot)
	if snapshot.schemaVersion ~= self.HATCH_ITEM_SNAPSHOT_SCHEMA_VERSION then
		return nil, self.HatchItemSnapshotError.UNSUPPORTED_VERSION
	end

	if type(snapshot.invId) ~= "number" or string.isNilOrEmpty(snapshot.payload) then
		return nil, self.HatchItemSnapshotError.INVALID_INPUT
	end

	local decodeOk, rawItem = pcall(Utils.decodeFromStr, snapshot.payload)

	if not decodeOk or type(rawItem) ~= "table" then
		return nil, self.HatchItemSnapshotError.DECODE_FAILED
	end

	local itemCfg = ItemData[rawItem.id]
	local stackCount = itemCfg and ItemUtils.getItemStackCount(rawItem.id)
	local configuredInvId = itemCfg and ItemUtils.getInvIdByItemId(rawItem.id)
	local Item = configuredInvId and ItemUtils.requireTypedItemClassByInvId(configuredInvId)

	if not itemCfg or type(stackCount) ~= "number" or stackCount <= 0 or configuredInvId ~= snapshot.invId or not ItemUtils.isSupportedTypedInvId(snapshot.invId) or not Item then
		return nil, self.HatchItemSnapshotError.INVALID_ITEM
	end

	local snapshotProps = snapshot.props and snapshot.props:getRawTable() or {}
	local expectedProps = ItemUtils.invTypeHasProps(snapshot.invId) and (rawItem.props or {}) or {}

	if snapshot.genID ~= rawItem.genID or snapshot.objID ~= (rawItem.objID or "") or snapshot.id ~= rawItem.id or snapshot.count ~= rawItem.count or snapshot.status ~= (rawItem.status or 0) or snapshot.useTimes ~= (rawItem.useTimes or 0) or snapshot.extraProp ~= (rawItem.extraProp or "") or snapshot.owner ~= (rawItem.owner or "") or not self:_isItemPropsEqual(snapshotProps, expectedProps) then
		return nil, self.HatchItemSnapshotError.PROJECTION_MISMATCH
	end

	rawItem.props = ItemUtils.invTypeHasProps(snapshot.invId) and (rawItem.props or {}) or nil

	local item = Item()

	if not pcall(item.init, item, rawItem) then
		return nil, self.HatchItemSnapshotError.INVALID_ITEM
	end

	if not ItemTTLUtils.restoreFromProps(item, itemCfg, Time.secondCache, snapshot.invId) then
		return nil, self.HatchItemSnapshotError.INVALID_ITEM
	end

	return item
end

function ItemFactory:_restoreStackableItem(snapshot)
	if snapshot.schemaVersion ~= self.HATCH_ITEM_SNAPSHOT_SCHEMA_VERSION then
		return nil, self.HatchItemSnapshotError.UNSUPPORTED_VERSION
	end

	if type(snapshot.invId) ~= "number" or string.isNilOrEmpty(snapshot.payload) then
		return nil, self.HatchItemSnapshotError.INVALID_INPUT
	end

	local decodeOk, rawCandidate = pcall(Utils.decodeFromStr, snapshot.payload)

	if not decodeOk or type(rawCandidate) ~= "table" then
		return nil, self.HatchItemSnapshotError.DECODE_FAILED
	end

	local itemCfg = ItemData[rawCandidate.id]
	local stackCount = itemCfg and ItemUtils.getItemStackCount(rawCandidate.id)
	local configuredInvId = itemCfg and ItemUtils.getInvIdByItemId(rawCandidate.id)
	local Item = configuredInvId and ItemUtils.requireTypedItemClassByInvId(configuredInvId)

	if not itemCfg or type(stackCount) ~= "number" or stackCount <= 1 or configuredInvId ~= snapshot.invId or not ItemUtils.isSupportedTypedInvId(snapshot.invId) or not Item or not string.isNilOrEmpty(rawCandidate.extraProp) then
		return nil, self.HatchItemSnapshotError.INVALID_ITEM
	end

	local snapshotProps = snapshot.props and snapshot.props:getRawTable() or {}
	local expectedProps = ItemUtils.invTypeHasProps(snapshot.invId) and (rawCandidate.props or {}) or {}

	if snapshot.genID ~= rawCandidate.genID or snapshot.objID ~= (rawCandidate.objID or "") or snapshot.id ~= rawCandidate.id or snapshot.count ~= rawCandidate.count or snapshot.status ~= (rawCandidate.status or 0) or snapshot.useTimes ~= (rawCandidate.useTimes or 0) or snapshot.extraProp ~= (rawCandidate.extraProp or "") or snapshot.owner ~= (rawCandidate.owner or "") or not self:_isItemPropsEqual(snapshotProps, expectedProps) then
		return nil, self.HatchItemSnapshotError.PROJECTION_MISMATCH
	end

	local item = self:createItemIgnorePile(rawCandidate.id, rawCandidate.count, nil, snapshot.invId)

	if not item then
		return nil, self.HatchItemSnapshotError.INVALID_ITEM
	end

	item:setOwnerUid(rawCandidate.owner or "")
	item:setProps(Utils.deepCopyTable(rawCandidate.props or {}))

	if not ItemTTLUtils.restoreFromProps(item, itemCfg, Time.secondCache, snapshot.invId) then
		return nil, self.HatchItemSnapshotError.INVALID_ITEM
	end

	return item
end

function ItemFactory:createItemSnapshot(item, removalCount)
	if not item or type(item.id) ~= "number" then
		return nil, self.HatchItemSnapshotError.INVALID_INPUT
	end

	local invId = item:getInvID()

	if invId == ItemConst.INV_TYPE_PET_JEWELRY then
		return nil, self.HatchItemSnapshotError.INVALID_ITEM
	end

	local itemCfg = ItemData[item.id]
	local stackCount = itemCfg and ItemUtils.getItemStackCount(item.id)
	local configuredInvId = itemCfg and ItemUtils.getInvIdByItemId(item.id)

	if not itemCfg or type(stackCount) ~= "number" or stackCount <= 0 or configuredInvId ~= invId or not ItemUtils.isSupportedTypedInvId(invId) then
		return nil, self.HatchItemSnapshotError.INVALID_ITEM
	end

	local extraProp = item:getExtraProp()

	if extraProp ~= nil or stackCount <= 1 then
		return self:_createExactSnapshot(item, removalCount, invId)
	end

	local props = item:getProps():getRawTable()

	return self:_createStackableSnapshot(item.id, item.count, removalCount, extraProp, item:getOwnerUid(), props, invId)
end

function ItemFactory:validateSnapshotDeletion(snapshot, deletedItem)
	if type(snapshot) ~= "table" or type(deletedItem) ~= "table" or type(snapshot.id) ~= "number" then
		return nil, self.HatchItemSnapshotError.INVALID_INPUT
	end

	local itemCfg = ItemData[snapshot.id]

	if itemCfg and ItemUtils.getInvIdByItemId(snapshot.id) == ItemConst.INV_TYPE_PET_JEWELRY then
		return nil, self.HatchItemSnapshotError.INVALID_ITEM
	end

	local stackCount = itemCfg and ItemUtils.getItemStackCount(snapshot.id)

	if not itemCfg or type(stackCount) ~= "number" or stackCount <= 0 then
		return nil, self.HatchItemSnapshotError.INVALID_ITEM
	end

	if not string.isNilOrEmpty(snapshot.extraProp) or stackCount <= 1 then
		return self:_validateExactDeletion(snapshot, deletedItem)
	end

	return self:_validateStackableDeletion(snapshot, deletedItem)
end

function ItemFactory:restoreItemFromSnapshot(snapshot)
	if type(snapshot) ~= "table" or type(snapshot.id) ~= "number" then
		return nil, self.HatchItemSnapshotError.INVALID_INPUT
	end

	local itemCfg = ItemData[snapshot.id]

	if itemCfg and ItemUtils.getInvIdByItemId(snapshot.id) == ItemConst.INV_TYPE_PET_JEWELRY then
		return nil, self.HatchItemSnapshotError.INVALID_ITEM
	end

	local stackCount = itemCfg and ItemUtils.getItemStackCount(snapshot.id)

	if not itemCfg or type(stackCount) ~= "number" or stackCount <= 0 then
		return nil, self.HatchItemSnapshotError.INVALID_ITEM
	end

	if not string.isNilOrEmpty(snapshot.extraProp) or stackCount <= 1 then
		return self:_restoreExactItem(snapshot)
	end

	return self:_restoreStackableItem(snapshot)
end

function ItemFactory:__createItem(itemId, count, extraPropDict, invId)
	local resolvedInvId = invId or ItemUtils.getInvIdByItemId(itemId)
	local Item = ItemUtils.requireTypedItemClassByInvId(resolvedInvId)

	if not Item then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("unsupported typed item invId, itemId=%d, invId=%s", itemId, tostring(invId))
		end

		return nil
	end

	local item = Item()

	if resolvedInvId == ItemConst.INV_TYPE_PET_JEWELRY then
		local initParams = {
			id = itemId
		}

		item:init(initParams)
		item:postInit(initParams)

		return item
	end

	local init_prams = {
		id = itemId,
		count = count
	}

	item:init(init_prams)
	item:setObjID(IDManager.genB64ID())

	local itemCfg = ItemData[itemId]

	if not ItemTTLUtils.initializeForNewItem(item, itemCfg, Time.secondCache, resolvedInvId) then
		return nil
	end

	if extraPropDict ~= nil then
		item:setExtraProp(extraPropDict)
	elseif ItemUtils.needGenPropertyOnInit(itemId) then
		assert(count == 1, string.format("itemId=%d, count=%d", itemId, count))
		item:setExtraProp(ItemUtils.genPropertyDictOnInit(itemId))
	elseif ItemUtils.isRobEgg(itemId) then
		item.props[ItemConst.ItemPropertyDef.EggData] = {}
	end

	item:postInit(init_prams)

	return item
end

function ItemFactory:createItems(itemId, count, extraPropDict, invId)
	count = count or 1

	local items = {}
	local resolvedInvId = invId or ItemUtils.getInvIdByItemId(itemId)

	if resolvedInvId == ItemConst.INV_TYPE_PET_JEWELRY then
		for _ = 1, count do
			local item = self:__createItem(itemId, 1, extraPropDict, resolvedInvId)

			if item then
				items[#items + 1] = item
			end
		end

		return items
	end

	local stackcount = extraPropDict ~= nil and 1 or ItemUtils.getItemStackCount(itemId)

	if stackcount <= 0 or count <= 0 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("invalid params, itemId=%d, stackcount=%d, count=%d", itemId, stackcount, count)
		end

		return items
	end

	local pileCount = math.modf(count / stackcount)

	for i = 1, pileCount do
		local item = self:__createItem(itemId, stackcount, extraPropDict, resolvedInvId)

		if item then
			items[#items + 1] = item
		end
	end

	local leftCount = count % stackcount

	if leftCount > 0 then
		local item = self:__createItem(itemId, leftCount, extraPropDict, resolvedInvId)

		if item then
			items[#items + 1] = item
		end
	end

	return items
end

function ItemFactory:createItemIgnorePile(itemId, count, extraPropDict, invId)
	local resolvedInvId = invId or ItemUtils.getInvIdByItemId(itemId)

	return self:__createItem(itemId, count, extraPropDict, resolvedInvId)
end

function ItemFactory:createLootItem(itemid, count, entityId)
	entityId = entityId or ""

	local itemCfg = ItemData[itemid]

	if not ToBool(itemCfg) then
		return
	end

	local lootItem = LootBoxItem({
		id = itemid,
		itemid = itemid,
		count = count,
		discoverys = {},
		tag = {},
		props = {}
	})

	lootItem.entityId = entityId

	if ItemUtils.isEquip(lootItem.itemid) then
		ServerUtils.initEquipProp(lootItem.itemid, lootItem)
	elseif ItemUtils.isRepairKit(lootItem.itemid) then
		ServerUtils.initRepairKit(lootItem.itemid, lootItem)
	elseif ItemUtils.isRefineable(lootItem.itemid) then
		ServerUtils.initAntique(lootItem.itemid, lootItem)
	end

	return lootItem
end

function ItemFactory:cloneLootItem(item)
	if item.className ~= "LootBoxItem" then
		return
	end

	local lootItem = LootBoxItem({
		id = item.itemid,
		itemid = item.itemid,
		count = item.count,
		discoverys = lume.clone(item.discoverys),
		tag = lume.clone(item.tag),
		props = lume.clone(item.props:getRawTable())
	})

	lootItem.entityId = item.entityId

	return lootItem
end

return ItemFactory
