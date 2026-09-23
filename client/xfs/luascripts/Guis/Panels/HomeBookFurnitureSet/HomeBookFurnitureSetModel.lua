-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeBookFurnitureSet\\HomeBookFurnitureSetModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local HomeBookDataUtils = require("Utils.HomeBookDataUtils")
local HomeBookRedDotUtils = require("Utils.HomeBookRedDotUtils")
local ItemData = require("Data.item_data")
local ComposeFurnitureData = require("Data.compose_furniture_data")
local HomeBookFurnitureSetModel = Class.LightClass("HomeBookFurnitureSetModel", UIModel)

function HomeBookFurnitureSetModel:getLocalizedText(textId)
	return textId and pg.getLocalizationText(textId) or ""
end

function HomeBookFurnitureSetModel:setEntranceInfo(info)
	self.categoryId = info.categoryId
	self.title = info.title or ""
end

function HomeBookFurnitureSetModel:getTitle()
	return self.title
end

function HomeBookFurnitureSetModel:getSecondTabs()
	local result = {}

	for _, secondType in ipairs(HomeBookDataUtils.getSecondTypesByFirstType(self.categoryId)) do
		local config = HomeBookDataUtils.getSecondType(secondType)

		result[#result + 1] = {
			id = secondType,
			name = self:getLocalizedText(config and config.name),
			isNew = HomeBookRedDotUtils.hasSecondNew(secondType),
			newRedDotPath = HomeBookRedDotUtils.getSecondNewPath(self.categoryId, secondType)
		}
	end

	for index, tab in ipairs(result) do
		tab.tIndex = index == 1 and 0 or index == #result and 2 or 1
	end

	return result
end

function HomeBookFurnitureSetModel:getThirdTabs(secondType)
	local result = {}

	for _, thirdType in ipairs(HomeBookDataUtils.getThirdTypesBySecondType(secondType)) do
		local config = HomeBookDataUtils.getThirdType(thirdType)

		result[#result + 1] = {
			tIndex = 0,
			id = thirdType,
			name = self:getLocalizedText(config and config.name),
			icon = config and config.icon,
			isNew = HomeBookRedDotUtils.hasThirdNew(thirdType),
			newRedDotPath = HomeBookRedDotUtils.getThirdNewPath(self.categoryId, secondType, thirdType)
		}
	end

	return result
end

function HomeBookFurnitureSetModel:doesEntryAffectThirdType(entryId, thirdType)
	if not thirdType then
		return false
	end

	local entry = HomeBookDataUtils.getEntity(entryId)

	if entry and entry.thirdType == thirdType then
		return true
	end

	for _, composeEntry in ipairs(HomeBookDataUtils.getComposeEntriesByFurnitureId(entryId)) do
		if composeEntry.thirdType == thirdType then
			return true
		end
	end

	return false
end

function HomeBookFurnitureSetModel:getComposeProgress(furnitureIds)
	local requirements = {}

	for _, furnitureId in ipairs(furnitureIds or EMPTY_TABLE) do
		requirements[furnitureId] = (requirements[furnitureId] or 0) + 1
	end

	local collectedCount = 0

	for furnitureId, needCount in pairs(requirements) do
		local itemInfo = pg.me:getHomeHandbookItemInfo(furnitureId)

		collectedCount = collectedCount + math.min(itemInfo and itemInfo.count or 0, needCount)
	end

	return collectedCount, #(furnitureIds or {})
end

function HomeBookFurnitureSetModel:getItemPresentation(entry)
	local itemConfig = ItemData[entry.id]
	local nameId = itemConfig and itemConfig.itemName
	local icon = entry.config.icon or itemConfig and itemConfig.icon

	return self:getLocalizedText(nameId), icon, itemConfig and itemConfig.quality or 1
end

function HomeBookFurnitureSetModel:getComposePresentation(entry)
	local composeConfig = ComposeFurnitureData[entry.id] or {}
	local collectedCount, totalCount = self:getComposeProgress(entry.composeFurnitureData)

	return self:getLocalizedText(composeConfig.name), composeConfig.icon or "", collectedCount, totalCount
end

function HomeBookFurnitureSetModel:buildContentData(entry, redData)
	if entry.sourceType == "compose" then
		local name, icon, collectedCount, totalCount = self:getComposePresentation(entry)

		return {
			quality = 1,
			id = entry.id,
			sourceType = entry.sourceType,
			name = name,
			icon = icon,
			addGrade = entry.addGrade or 0,
			isCollected = totalCount > 0 and totalCount <= collectedCount,
			collectedCount = collectedCount,
			totalCount = totalCount,
			progressText = string.format("%d/%d", collectedCount, totalCount),
			isNew = redData and redData[entry.id] == true or false,
			newRedDotPath = HomeBookRedDotUtils.getContentNewPath(entry),
			sortId = HomeBookDataUtils.getEntrySortId(entry.id)
		}
	end

	local name, icon, quality = self:getItemPresentation(entry)

	return {
		progressText = "",
		collectedCount = 0,
		totalCount = 0,
		id = entry.id,
		sourceType = entry.sourceType,
		name = name,
		icon = icon,
		quality = quality,
		addGrade = entry.addGrade or 0,
		isCollected = pg.me:isHomeHandbookItemCollected(entry.id),
		isNew = redData and redData[entry.id] == true or false,
		newRedDotPath = HomeBookRedDotUtils.getContentNewPath(entry),
		sortId = HomeBookDataUtils.getEntrySortId(entry.id)
	}
end

function HomeBookFurnitureSetModel:sortContentData(left, right)
	if left.isCollected ~= right.isCollected then
		return left.isCollected
	end

	if left.sortId ~= right.sortId then
		return left.sortId < right.sortId
	end

	return left.id < right.id
end

function HomeBookFurnitureSetModel:getContentLists(thirdType)
	local composeList = {}
	local normalList = {}
	local redData = HomeBookRedDotUtils.getUnreadSnapshot()

	for _, entry in ipairs(HomeBookDataUtils.getEntriesByThirdType(thirdType)) do
		local data = self:buildContentData(entry, redData)

		if entry.sourceType == "compose" then
			composeList[#composeList + 1] = data
		else
			normalList[#normalList + 1] = data
		end
	end

	table.sort(composeList, function(left, right)
		return self:sortContentData(left, right)
	end)
	table.sort(normalList, function(left, right)
		return self:sortContentData(left, right)
	end)

	return composeList, normalList
end

function HomeBookFurnitureSetModel:getCategoryProgress()
	local current = pg.me:getHomeHandbookCategoryCount(self.categoryId)
	local receivedCount = pg.me:getHomeHandbookReceivedCategoryCount(self.categoryId)
	local rewards = {}
	local previousNum = 0

	for _, reward in ipairs(HomeBookDataUtils.getProgressRewards(self.categoryId)) do
		local numMax = reward.config.stageNum or 0

		rewards[#rewards + 1] = {
			stage = reward.stage,
			numMin = previousNum,
			numMax = numMax,
			rewardId = reward.config.reward,
			isReceived = numMax <= receivedCount,
			isClaimable = HomeBookRedDotUtils.isCategoryRewardClaimable(self.categoryId, reward),
			redDotPath = HomeBookRedDotUtils.getCategoryRewardPath(self.categoryId, reward.stage)
		}
		previousNum = numMax
	end

	return {
		current = current,
		total = HomeBookDataUtils.getFirstCategoryTotal(self.categoryId),
		rewards = rewards
	}
end

return HomeBookFurnitureSetModel
