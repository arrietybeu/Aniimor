-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeBookFurnitureDetail\\HomeBookFurnitureDetailModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local HomeBookDataUtils = require("Utils.HomeBookDataUtils")
local ClientHomelandUtils = require("Utils.ClientHomelandUtils")
local ComposeFurnitureData = require("Data.compose_furniture_data")
local HomeObjectData = require("Data.home_object_data")
local ItemData = require("Data.item_data")
local ItemSourceData = require("Data.item_source_data")
local HomeBookFurnitureDetailModel = Class.LightClass("HomeBookFurnitureDetailModel", UIModel)

function HomeBookFurnitureDetailModel:getLocalizedText(textId)
	return textId and pg.getLocalizationText(textId) or ""
end

function HomeBookFurnitureDetailModel:getThirdTypeTitle(entryId)
	local entry = HomeBookDataUtils.getEntity(entryId)

	if not entry and self.navigationParentSuitId then
		entry = HomeBookDataUtils.getEntity(self.navigationParentSuitId)
	end

	local thirdTypeConfig = entry and HomeBookDataUtils.getThirdType(entry.thirdType)

	return self:getLocalizedText(thirdTypeConfig and thirdTypeConfig.name)
end

function HomeBookFurnitureDetailModel:getCollectedCount(furnitureId)
	local itemInfo = pg.me and pg.me:getHomeHandbookItemInfo(furnitureId)

	return itemInfo and itemInfo.count or 0
end

function HomeBookFurnitureDetailModel:isFurnitureCollected(furnitureId)
	if pg.me and pg.me:isHomeHandbookItemCollected(furnitureId) then
		return true
	end

	return self:getCollectedCount(furnitureId) > 0
end

function HomeBookFurnitureDetailModel:getSuitProgress(suitId)
	local suitConfig = ComposeFurnitureData[suitId] or {}
	local requirements = {}
	local orderedIds = {}

	for _, furnitureId in ipairs(suitConfig.furnitures or EMPTY_TABLE) do
		if requirements[furnitureId] == nil then
			orderedIds[#orderedIds + 1] = furnitureId
			requirements[furnitureId] = 0
		end

		requirements[furnitureId] = requirements[furnitureId] + 1
	end

	local collectedCount = 0
	local totalCount = 0
	local items = {}

	for _, furnitureId in ipairs(orderedIds) do
		local requiredCount = requirements[furnitureId]
		local ownedCount = self:getCollectedCount(furnitureId)
		local effectiveCount = math.min(ownedCount, requiredCount)
		local itemConfig = ItemData[furnitureId] or {}

		collectedCount = collectedCount + effectiveCount
		totalCount = totalCount + requiredCount
		items[#items + 1] = {
			id = furnitureId,
			name = self:getLocalizedText(itemConfig.itemName),
			icon = itemConfig.icon,
			quality = itemConfig.quality or 1,
			ownedCount = ownedCount,
			requiredCount = requiredCount,
			progressText = string.format("%d/%d", effectiveCount, requiredCount),
			isCollected = requiredCount <= effectiveCount
		}
	end

	return collectedCount, totalCount, items
end

function HomeBookFurnitureDetailModel:isSuitCollected(suitId)
	local collectedCount, totalCount = self:getSuitProgress(suitId)

	return totalCount > 0 and totalCount <= collectedCount
end

function HomeBookFurnitureDetailModel:isEntryCollected(entryId)
	if ComposeFurnitureData[entryId] then
		return self:isSuitCollected(entryId)
	end

	return self:isFurnitureCollected(entryId)
end

function HomeBookFurnitureDetailModel:sortEntryIds(leftEntryId, rightEntryId)
	local leftCollected = self:isEntryCollected(leftEntryId)
	local rightCollected = self:isEntryCollected(rightEntryId)

	if leftCollected ~= rightCollected then
		return leftCollected
	end

	return HomeBookDataUtils.compareEntrySort(leftEntryId, rightEntryId)
end

function HomeBookFurnitureDetailModel:getCategoryEntryIds(entry)
	local entryIds = {}

	for _, sibling in ipairs(HomeBookDataUtils.getEntriesByThirdType(entry.thirdType)) do
		if sibling.sourceType == entry.sourceType and (sibling.sourceType == "compose" or sibling.sourceType == "furniture") then
			entryIds[#entryIds + 1] = sibling.id
		end
	end

	table.sort(entryIds, function(leftEntryId, rightEntryId)
		return self:sortEntryIds(leftEntryId, rightEntryId)
	end)

	return entryIds
end

function HomeBookFurnitureDetailModel:getSuitFurnitureIds(suitId)
	local result = {}
	local added = {}

	for _, furnitureId in ipairs((ComposeFurnitureData[suitId] or EMPTY_TABLE).furnitures or EMPTY_TABLE) do
		if not added[furnitureId] then
			added[furnitureId] = true
			result[#result + 1] = furnitureId
		end
	end

	return result
end

function HomeBookFurnitureDetailModel:selectEntry(entryId, parentSuitId, navigationEntryIds)
	if not entryId or not ComposeFurnitureData[entryId] and not HomeObjectData[entryId] then
		return false
	end

	local sourceType = ComposeFurnitureData[entryId] and "compose" or "furniture"

	if not HomeBookDataUtils.isEntryAvailable(entryId, sourceType) then
		return false
	end

	local entry = HomeBookDataUtils.getEntity(entryId)
	local entryIds

	self.navigationParentSuitId = nil

	if navigationEntryIds then
		entryIds = {}

		for _, siblingId in ipairs(navigationEntryIds) do
			local sibling = HomeBookDataUtils.getEntity(siblingId)

			if sibling and sibling.sourceType == entry.sourceType then
				entryIds[#entryIds + 1] = siblingId
			end
		end
	elseif entry and (entry.sourceType == "compose" or entry.sourceType == "furniture") then
		entryIds = self:getCategoryEntryIds(entry)
	elseif parentSuitId and ComposeFurnitureData[parentSuitId] and HomeBookDataUtils.isEntryAvailable(parentSuitId, "compose") then
		entryIds = self:getSuitFurnitureIds(parentSuitId)
		self.navigationParentSuitId = parentSuitId
	else
		entryIds = {
			entryId
		}
	end

	local currentIndex = 1

	for index, siblingId in ipairs(entryIds) do
		if siblingId == entryId then
			currentIndex = index

			break
		end
	end

	self.entryIds = entryIds
	self.currentIndex = currentIndex

	return #entryIds > 0
end

function HomeBookFurnitureDetailModel:setDetailInfo(info)
	info = info or {}
	self.entryIds = {}
	self.currentIndex = 1
	self.navigationParentSuitId = nil

	self:selectEntry(info.entryId or info.id, info.parentSuitId, info.entryIds)
end

function HomeBookFurnitureDetailModel:move(offset)
	local count = #(self.entryIds or {})

	if count <= 1 then
		return false
	end

	self.currentIndex = (self.currentIndex - 1 + offset) % count + 1

	return true
end

function HomeBookFurnitureDetailModel:getCurrentEntryId()
	return self.entryIds and self.entryIds[self.currentIndex]
end

function HomeBookFurnitureDetailModel:findParentSuitId(furnitureId)
	local suitIds = {}

	for suitId, suitConfig in pairs(ComposeFurnitureData) do
		for _, childId in ipairs(suitConfig.furnitures or EMPTY_TABLE) do
			if childId == furnitureId and HomeBookDataUtils.isEntryAvailable(suitId, "compose") then
				suitIds[#suitIds + 1] = suitId

				break
			end
		end
	end

	table.sort(suitIds, function(leftSuitId, rightSuitId)
		local leftConfig = ComposeFurnitureData[leftSuitId] or {}
		local rightConfig = ComposeFurnitureData[rightSuitId] or {}
		local leftSortId = leftConfig.sortId or leftSuitId
		local rightSortId = rightConfig.sortId or rightSuitId

		return leftSortId == rightSortId and leftSuitId < rightSuitId or leftSortId < rightSortId
	end)

	return suitIds[1]
end

function HomeBookFurnitureDetailModel:buildConfiguredSources(sourceIds)
	if type(sourceIds) == "number" then
		sourceIds = {
			sourceIds
		}
	end

	local result = {}

	for _, sourceId in ipairs(sourceIds or EMPTY_TABLE) do
		local sourceConfig = ItemSourceData[sourceId]

		if sourceConfig then
			result[#result + 1] = {
				isFurnitureStore = false,
				sourceId = sourceId,
				sourceConfig = sourceConfig,
				name = self:getLocalizedText(sourceConfig.buttonTxt)
			}
		end
	end

	return result
end

function HomeBookFurnitureDetailModel:buildComposeSources(furnitureId, sourceIds)
	if type(sourceIds) == "number" then
		sourceIds = {
			sourceIds
		}
	end

	local result = {}

	for _, sourceId in ipairs(sourceIds or EMPTY_TABLE) do
		if sourceId == 1 or sourceId == 2 then
			result[#result + 1] = {
				isFurnitureStore = true,
				name = pg.getGameString("HOMELAND_FURNITURE_STORE_TIPS"),
				itemId = furnitureId
			}
		else
			local sourceConfig = ItemSourceData[sourceId]

			if sourceConfig then
				result[#result + 1] = {
					isFurnitureStore = false,
					sourceId = sourceId,
					sourceConfig = sourceConfig,
					name = self:getLocalizedText(sourceConfig.buttonTxt)
				}
			end
		end
	end

	return result
end

function HomeBookFurnitureDetailModel:buildFurnitureSources(furnitureId, itemConfig, objectConfig)
	local sourceIds = {}
	local added = {}

	if itemConfig then
		for _, sourceId in ipairs(itemConfig.source or EMPTY_TABLE) do
			if not added[sourceId] then
				added[sourceId] = true
				sourceIds[#sourceIds + 1] = sourceId
			end
		end
	end

	if objectConfig then
		for _, sourceId in ipairs(objectConfig.buySource or EMPTY_TABLE) do
			if not added[sourceId] then
				added[sourceId] = true
				sourceIds[#sourceIds + 1] = sourceId
			end
		end
	end

	local result = self:buildConfiguredSources(sourceIds)

	if #result == 0 and (objectConfig.getWay == 1 or objectConfig.getWay == 2) then
		result[#result + 1] = {
			isFurnitureStore = true,
			name = pg.getGameString("HOMELAND_FURNITURE_STORE_TIPS"),
			itemId = furnitureId
		}
	end

	return result
end

function HomeBookFurnitureDetailModel:buildParentSuitData(suitId)
	local suitConfig = ComposeFurnitureData[suitId]

	if not suitConfig or not HomeBookDataUtils.isEntryAvailable(suitId, "compose") then
		return nil
	end

	local collectedCount, totalCount = self:getSuitProgress(suitId)

	return {
		id = suitId,
		icon = suitConfig.icon,
		progressText = string.format("%d/%d", collectedCount, totalCount)
	}
end

function HomeBookFurnitureDetailModel:buildSuitDetailData(suitId)
	local suitConfig = ComposeFurnitureData[suitId]

	if not suitConfig then
		return nil
	end

	local entry = HomeBookDataUtils.getEntity(suitId)
	local collectedCount, totalCount, suitItems = self:getSuitProgress(suitId)
	local comfortValue = 0
	local loadValue = 0

	for _, furnitureId in ipairs(suitConfig.furnitures or EMPTY_TABLE) do
		comfortValue = comfortValue + ClientHomelandUtils.getComfortValueById(furnitureId)
		loadValue = loadValue + ClientHomelandUtils.getLoadValueById(furnitureId)
	end

	local isCollected = totalCount > 0 and totalCount <= collectedCount

	return {
		isSuit = true,
		id = suitId,
		name = self:getLocalizedText(suitConfig.name),
		tag = isCollected and pg.getGameString("HOMELAND_PLOT_UNLOCKED") or pg.getGameString("HOMELAND_ITEM_LOCKED"),
		desc = self:getLocalizedText(suitConfig.des),
		comfortValue = comfortValue,
		loadValue = loadValue,
		addGrade = entry and entry.addGrade or 0,
		isCollected = isCollected,
		progressText = string.format("%d/%d", collectedCount, totalCount),
		infoTitle = pg.getGameString("HOME_BOOK_SET_INFO"),
		getTitle = pg.getGameString("HOME_BOOK_GET_METHOD"),
		suitItems = suitItems,
		sources = self:buildComposeSources(suitId, suitConfig.sources),
		modelData = ClientHomelandUtils.getHomeBookFurniturePreviewDataById(suitId, true),
		canCycle = #(self.entryIds or {}) > 1
	}
end

function HomeBookFurnitureDetailModel:buildFurnitureDetailData(furnitureId)
	local itemConfig = ItemData[furnitureId]
	local objectConfig = HomeObjectData[furnitureId]

	if not itemConfig or not objectConfig then
		return nil
	end

	local parentSuitId = self.navigationParentSuitId or self:findParentSuitId(furnitureId)
	local parentSuit = self:buildParentSuitData(parentSuitId)
	local isCollected = self:isFurnitureCollected(furnitureId)
	local entry = HomeBookDataUtils.getEntity(furnitureId)

	return {
		isSuit = false,
		id = furnitureId,
		name = self:getLocalizedText(itemConfig.itemName or objectConfig.name),
		tag = isCollected and pg.getGameString("HOMELAND_PLOT_UNLOCKED") or pg.getGameString("HOMELAND_ITEM_LOCKED"),
		desc = self:getLocalizedText(objectConfig.desc or itemConfig.itemDes),
		comfortValue = ClientHomelandUtils.getComfortValueById(furnitureId),
		loadValue = ClientHomelandUtils.getLoadValueById(furnitureId),
		addGrade = entry and entry.addGrade or 0,
		isCollected = isCollected,
		progressText = parentSuit and parentSuit.progressText or "",
		infoTitle = pg.getGameString("HOME_BOOK_SET_INFO"),
		getTitle = pg.getGameString("HOME_BOOK_GET_METHOD"),
		suitItems = {},
		parentSuit = parentSuit,
		sources = self:buildFurnitureSources(furnitureId, itemConfig, objectConfig),
		modelData = ClientHomelandUtils.getHomeBookFurniturePreviewDataById(furnitureId, false),
		canCycle = #(self.entryIds or {}) > 1
	}
end

function HomeBookFurnitureDetailModel:getDetailData()
	local entryId = self:getCurrentEntryId()

	if not entryId then
		return nil
	end

	local sourceType = ComposeFurnitureData[entryId] and "compose" or "furniture"

	if not HomeBookDataUtils.isEntryAvailable(entryId, sourceType) then
		return nil
	end

	local data

	if ComposeFurnitureData[entryId] then
		data = self:buildSuitDetailData(entryId)
	else
		data = self:buildFurnitureDetailData(entryId)
	end

	if data then
		data.title = self:getThirdTypeTitle(entryId)
	end

	return data
end

return HomeBookFurnitureDetailModel
