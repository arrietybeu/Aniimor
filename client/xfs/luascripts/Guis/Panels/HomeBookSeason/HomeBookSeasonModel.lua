-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeBookSeason\\HomeBookSeasonModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local HomeBookDataUtils = require("Utils.HomeBookDataUtils")
local ComposeFurnitureData = require("Data.compose_furniture_data")
local HomeBookSeasonModel = Class.LightClass("HomeBookSeasonModel", UIModel)
local GROUP_TEMPLATE_SUIT = 0
local GROUP_TEMPLATE_NORMAL = 1

function HomeBookSeasonModel:getLocalizedText(textId)
	return textId and pg.getLocalizationText(textId) or ""
end

function HomeBookSeasonModel:getComposeProgress(furnitureIds)
	local requirements = {}

	for _, furnitureId in ipairs(furnitureIds or EMPTY_TABLE) do
		requirements[furnitureId] = (requirements[furnitureId] or 0) + 1
	end

	local collectedCount = 0

	for furnitureId, needCount in pairs(requirements) do
		local itemInfo = pg.me and pg.me:getHomeHandbookItemInfo(furnitureId)

		collectedCount = collectedCount + math.min(itemInfo and itemInfo.count or 0, needCount)
	end

	return collectedCount, #(furnitureIds or {})
end

function HomeBookSeasonModel:buildItemData(entry)
	local displayData = HomeBookDataUtils.getEntryDisplayData(entry.id)

	if not displayData then
		return nil
	end

	local collectedCount = 0
	local totalCount = 0
	local isCollected = false
	local progressText = ""
	local name = displayData.name
	local icon = displayData.icon

	if entry.sourceType == "compose" then
		local composeConfig = ComposeFurnitureData[entry.id]

		name = self:getLocalizedText(composeConfig.name)
		icon = composeConfig.icon
		collectedCount, totalCount = self:getComposeProgress(entry.composeFurnitureData)
		isCollected = totalCount > 0 and totalCount <= collectedCount
		progressText = string.format("%d/%d", collectedCount, totalCount)
	else
		isCollected = pg.me and pg.me:isHomeHandbookItemCollected(entry.id) or false
	end

	return {
		id = entry.id,
		sourceType = entry.sourceType,
		name = name,
		icon = icon,
		quality = displayData.quality or 1,
		addGrade = displayData.addGrade or 0,
		isCollected = isCollected,
		collectedCount = collectedCount,
		totalCount = totalCount,
		progressText = progressText
	}
end

function HomeBookSeasonModel:setSeasonInfo(info)
	info = info or {}
	self.categoryId = info.categoryId
	self.seasonId = info.seasonId or HomeBookDataUtils.getDisplaySeasonId()
	self.fallbackTitle = info.title or ""
end

function HomeBookSeasonModel:getTitle()
	local seasonConfig = self.seasonId and HomeBookDataUtils.getHomeSeasonConfig(self.seasonId)
	local title = seasonConfig and self:getLocalizedText(seasonConfig.name) or ""

	return title ~= "" and title or self.fallbackTitle
end

function HomeBookSeasonModel:getGroups()
	local groups = {}

	if not self.seasonId then
		return groups
	end

	for _, module in ipairs(HomeBookDataUtils.getCategorySeason(self.seasonId)) do
		local items = {}
		local entryIds = {}
		local collectedCount = 0
		local isSuitGroup = false

		for _, entry in ipairs(module.entities or EMPTY_TABLE) do
			if entry then
				local item = self:buildItemData(entry)

				if item then
					items[#items + 1] = item
					entryIds[#entryIds + 1] = item.id
					collectedCount = collectedCount + (item.isCollected and 1 or 0)
					isSuitGroup = isSuitGroup or entry.sourceType == "compose"
				end
			end
		end

		local moduleType = module.config.moduleType
		local categoryConfig = HomeBookDataUtils.getThirdType(moduleType)
		local categoryName = categoryConfig and self:getLocalizedText(categoryConfig.name) or self:getLocalizedText(module.config.name)

		groups[#groups + 1] = {
			id = module.id,
			moduleType = moduleType,
			title = categoryName,
			collectedCount = collectedCount,
			totalCount = #items,
			items = items,
			entryIds = entryIds,
			tIndex = isSuitGroup and GROUP_TEMPLATE_SUIT or GROUP_TEMPLATE_NORMAL
		}
	end

	return groups
end

function HomeBookSeasonModel:getCollectedCount()
	if not pg.me or not self.seasonId then
		return 0
	end

	return pg.me:getHomeHandbookSeasonCount(self.seasonId)
end

return HomeBookSeasonModel
