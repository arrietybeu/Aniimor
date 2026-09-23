-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandMarket\\HomelandMarketModel.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("HomelandMarketModel")
local Class = require("Core.Framework.Class")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemConst = require("Common.Const.ItemConst")
local UIModel = require("Guis.UIModel")
local HomelandItemToMaterialData = require("Data.homeland_item_to_material_data")
local HomelandMaterialConfigData = require("Data.homeland_material_config_data")
local HomelandMaterialShopData = require("Data.homeland_material_shop_data")
local ItemData = require("Data.item_data")
local HomelandMarketModel = Class.LightClass("HomelandMarketModel", UIModel)

function HomelandMarketModel:isHighPrice(shopId, materialId)
	local highPriceStore = pg.me.homelandOrderInfo.highPriceStore[shopId]

	if not highPriceStore then
		return false
	end

	for _, highMaterialId in ipairs(highPriceStore.materials) do
		if materialId == highMaterialId then
			return true
		end
	end

	return false
end

function HomelandMarketModel:getHighPriceCountLeft(shopId, materialId)
	if not shopId or not materialId then
		return
	end

	local highPriceStore = pg.me.homelandOrderInfo.highPriceStore[shopId] or {}
	local soldMaterialToNum = highPriceStore.highPriceCountToday or {}
	local soldNum = soldMaterialToNum[materialId] or 0
	local materialInfo = HomelandMaterialConfigData[materialId] or {}

	return materialInfo.goodPriceLimit - soldNum
end

function HomelandMarketModel:getOwnCount(itemId)
	local ownCount = ItemUtils.getItemCountById(pg.me, itemId)

	if pg.me.space.itemMap[itemId] then
		ownCount = ownCount + pg.me.space.itemMap[itemId]
	end

	return ownCount
end

function HomelandMarketModel:getMarketList(shopId)
	local res = {}
	local highPriceStore = pg.me.homelandOrderInfo.highPriceStore[shopId] or {}
	local rate = highPriceStore.priceMultiple or 1
	local shopData = HomelandMaterialShopData[shopId] or {}

	for _, materialId in ipairs(shopData) do
		local materialInfo = HomelandMaterialConfigData[materialId] or {}
		local itemId = materialInfo.itemId

		if itemId then
			local itemInfo = ItemData[itemId]

			if itemInfo then
				local isHighPrice = self:isHighPrice(shopId, materialId)

				if isHighPrice then
					local highPriceCountLeft = self:getHighPriceCountLeft(shopId, materialId)
					local ownCount = self:getOwnCount(itemId)

					table.insert(res, {
						itemId = itemId,
						materialId = materialId,
						currencyItemId = materialInfo.price[1],
						currencyNum = math.ceil(materialInfo.price[2] * rate),
						icon = itemInfo.icon,
						count = highPriceCountLeft,
						ownCount = ownCount,
						selectorCount = math.min(ownCount, highPriceCountLeft),
						quality = itemInfo.quality
					})
				end
			end
		end
	end

	return res
end

function HomelandMarketModel:isMaterialInShop(shopId, materialId)
	local shopData = HomelandMaterialShopData[shopId] or {}

	for _, matIdForSell in ipairs(shopData) do
		if matIdForSell == materialId then
			return true
		end
	end

	return false
end

function HomelandMarketModel:getShopItemInfo(shopId, itemId, itemCount, currencyItemFilter)
	if not shopId or not itemId then
		return
	end

	local itemData = ItemData[itemId]
	local materialId = HomelandItemToMaterialData[itemId]

	if itemData and materialId then
		local materialInfo = HomelandMaterialConfigData[materialId]

		if materialInfo and self:isMaterialInShop(shopId, materialId) then
			local price = materialInfo.price or {}

			if currencyItemFilter and price[1] ~= currencyItemFilter then
				return
			end

			local highPriceStore = pg.me.homelandOrderInfo.highPriceStore[shopId] or {}
			local priceMultiple = highPriceStore.priceMultiple or 1
			local rate = self:isHighPrice(shopId, materialId) and priceMultiple or 1

			return {
				itemId = itemId,
				materialId = materialId,
				icon = itemData.icon,
				quality = itemData.quality,
				count = itemCount,
				currencyItemId = price[1],
				currencyNum = math.ceil(price[2] * rate),
				rate = rate
			}
		end
	end
end

function HomelandMarketModel:logInvalidInventoryItemCount(shopId, currencyItemFilter, invId, packSlot, packSlotCount, currentLogKeys)
	if not LoggerManager.checkLogger(LoggerConst.ERROR) then
		return
	end

	local itemId = packSlot.id
	local genID = packSlot.genID
	local countType = type(packSlotCount)
	local countValue

	if countType == "nil" or countType == "number" or countType == "string" or countType == "boolean" then
		countValue = tostring(packSlotCount)
	else
		countValue = "<" .. countType .. ">"
	end

	local logKey = string.format("%s:%s:%s:%s:%s", tostring(invId), tostring(itemId), tostring(genID), countType, countValue)
	local loggedInCurrentScan = currentLogKeys[logKey]

	currentLogKeys[logKey] = true

	if loggedInCurrentScan or self.invalidInventoryItemLogKeys and self.invalidInventoryItemLogKeys[logKey] then
		return
	end

	local classType = packSlot.__ClassType
	local className = type(classType) == "table" and classType.typeName

	logger:error("HomelandMarketInvalidItemCount playerUid=%s shopId=%s currencyItemFilter=%s" .. " invId=%s itemId=%s genID=%s count=%s countType=%s" .. " slotType=%s className=%s propertyId=%s propertiesType=%s", tostring(pg.me and pg.me.uid), tostring(shopId), tostring(currencyItemFilter), tostring(invId), tostring(itemId), tostring(genID), countValue, countType, type(packSlot), tostring(className), tostring(packSlot._id), type(packSlot._properties))
end

function HomelandMarketModel:getInventoryList(shopId, currencyItemFilter)
	local itemDic = {}
	local invalidInventoryItemLogKeys = {}
	local homelandInvIds = {
		ItemConst.INV_TYPE_HOMELAND,
		ItemConst.INV_TYPE_HOMELAND_FURNITURE
	}

	for _, invId in ipairs(homelandInvIds) do
		local itemBag = ItemUtils.getTypedBag(pg.me, invId)

		if itemBag then
			for _, packSlot in itemBag:items() do
				local packSlotCount = packSlot.count

				if type(packSlotCount) == "number" and packSlotCount > 0 then
					local itemId = packSlot.id
					local itemInfo = self:getShopItemInfo(shopId, itemId, packSlotCount, currencyItemFilter)

					if itemInfo then
						if itemDic[itemId] then
							itemDic[itemId].count = itemDic[itemId].count + itemInfo.count
						else
							itemDic[itemId] = itemInfo
						end
					end
				elseif type(packSlotCount) ~= "number" then
					self:logInvalidInventoryItemCount(shopId, currencyItemFilter, invId, packSlot, packSlotCount, invalidInventoryItemLogKeys)
				end
			end
		end
	end

	self.invalidInventoryItemLogKeys = invalidInventoryItemLogKeys

	for itemId, itemCount in pairs(pg.me.space.itemMap) do
		if itemCount > 0 then
			local itemInfo = self:getShopItemInfo(shopId, itemId, itemCount, currencyItemFilter)

			if itemDic[itemId] then
				itemDic[itemId].count = itemDic[itemId].count + itemInfo.count
			else
				itemDic[itemId] = itemInfo
			end
		end
	end

	local res = {}

	for _, itemInfo in pairs(itemDic) do
		table.insert(res, itemInfo)
	end

	itemDic = nil

	table.sort(res, function(a, b)
		if a.rate ~= b.rate then
			return a.rate > b.rate
		elseif a.quality ~= b.quality then
			return a.quality > b.quality
		elseif a.currencyNum ~= b.currencyNum then
			return a.currencyNum > b.currencyNum
		elseif a.count ~= b.count then
			return a.count > b.count
		else
			return a.itemId < b.itemId
		end
	end)

	return res
end

return HomelandMarketModel
