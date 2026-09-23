-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsCollection\\GrabEggsCollectionModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local GrabEggsCollectionModel = Class.LightClass("GrabEggsCollectionModel", UIModel)
local EggBookCollectionData = require("Data.egg_book_Collection_data")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")

function GrabEggsCollectionModel:init(ctrl)
	UIModel.init(self, ctrl)

	self.slotItemDataCache = {}
end

function GrabEggsCollectionModel:getSeason()
	return {
		{
			seasonName = "S1",
			seasonId = 1
		},
		{
			seasonName = "S2",
			seasonId = 2
		},
		{
			seasonName = "S3",
			seasonId = 3
		}
	}
end

function GrabEggsCollectionModel:refreshSlotItemData()
	self.slotItemDataCache = {}

	local itemIdToSlotMap = {}

	for collectionId, collectionConfig in pairs(EggBookCollectionData) do
		if collectionConfig.itemId then
			for _, itemId in ipairs(collectionConfig.itemId) do
				itemIdToSlotMap[itemId] = collectionId
			end
		end
	end

	local grabEggBag = ItemUtils.getTypedBag(pg.me, ItemConst.INV_TYPE_ROB_EGG_WAREHOUSE)

	for genId, item in grabEggBag:items() do
		local collectionId = itemIdToSlotMap[item.id]

		if collectionId then
			if not self.slotItemDataCache[collectionId] then
				self.slotItemDataCache[collectionId] = {}
			end

			table.insert(self.slotItemDataCache[collectionId], {
				genId = genId,
				item = item
			})
		end
	end
end

function GrabEggsCollectionModel:getSlotItemData(collectionId)
	if not collectionId then
		return self.slotItemDataCache
	end

	return self.slotItemDataCache[collectionId] or self.slotItemDataCache[tonumber(collectionId)] or self.slotItemDataCache[tostring(collectionId)]
end

return GrabEggsCollectionModel
