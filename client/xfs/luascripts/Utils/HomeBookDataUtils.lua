-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\HomeBookDataUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local FirstTabData = require("Data.home_handbook_category_lv1_data")
local SecondTabData = require("Data.home_handbook_category_lv2_data")
local ThirdTabData = require("Data.home_handbook_category_lv3_data")
local FurnitureData = require("Data.home_handbook_homeland_data")
local ItemData = require("Data.home_handbook_product_data")
local ComposeData = require("Data.home_handbook_ornament_set_data")
local ComposeFurnitureData = require("Data.compose_furniture_data")
local GeneralItemData = require("Data.item_data")
local HomeObjectData = require("Data.home_object_data")
local CategoryDetailData = require("Data.home_handbook_category_detail")
local SeasonData = require("Data.home_handbook_season_data")
local ScoreRewardData = require("Data.home_handbook_grade_reward_data")
local ProgressRewardData = require("Data.home_category_lv1_progress_data")
local HomeSeasonData = require("Data.home_season_data")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local HomeBookDataUtils = {}

HomeBookDataUtils._indexes = nil
HomeBookDataUtils._indexServerArea = nil

function HomeBookDataUtils.isEntryAvailable(id, sourceType)
	if sourceType == "furniture" or sourceType == "compose" then
		local ClientHomelandUtils = require("Utils.ClientHomelandUtils")

		if sourceType == "furniture" then
			return GeneralItemData[id] ~= nil and HomeObjectData[id] ~= nil and ClientHomelandUtils.isFurnitureAvailableInArea(id)
		end

		local composeConfig = ComposeFurnitureData[id]

		for _, furnitureId in ipairs(composeConfig and composeConfig.furnitures or EMPTY_TABLE) do
			if not ClientHomelandUtils.isFurnitureAvailableInArea(furnitureId) then
				return false
			end
		end
	end

	if sourceType == "item" then
		return GeneralItemData[id] ~= nil
	end

	return true
end

function HomeBookDataUtils._sortedConfigList(data)
	local result = {}

	for id, config in pairs(data or EMPTY_TABLE) do
		result[#result + 1] = {
			id = id,
			config = config
		}
	end

	table.sort(result, function(left, right)
		local leftSort = left.config.sortId or left.id
		local rightSort = right.config.sortId or right.id

		return leftSort == rightSort and left.id < right.id or leftSort < rightSort
	end)

	return result
end

function HomeBookDataUtils._addToIndex(index, key, value)
	if key == nil then
		return
	end

	index[key] = index[key] or {}
	index[key][#index[key] + 1] = value
end

function HomeBookDataUtils._createEntry(id, config, sourceType)
	if not HomeBookDataUtils.isEntryAvailable(id, sourceType) then
		return nil
	end

	local composeFurnitureData
	local addGrade = config.addGrade or 0

	if sourceType == "compose" then
		local composeConfig = ComposeFurnitureData[id]

		composeFurnitureData = composeConfig and composeConfig.furnitures
		addGrade = 0
	end

	local thirdType = config.thirdType
	local thirdTypeConfig = thirdType and ThirdTabData[thirdType]
	local secondType = config.secondType or thirdTypeConfig and thirdTypeConfig.secondType
	local secondTypeConfig = secondType and SecondTabData[secondType]
	local firstType = config.firstType or secondTypeConfig and secondTypeConfig.firstType

	return {
		id = id,
		sourceType = sourceType,
		config = config,
		firstType = firstType,
		secondType = secondType,
		thirdType = thirdType,
		addGrade = addGrade,
		formulaId = config.fomulaId,
		composeFurnitureData = composeFurnitureData,
		sortId = config.sortId or 0
	}
end

function HomeBookDataUtils._addEntriesToIndexes(targetIndexes, data, sourceType)
	for id, config in pairs(data or EMPTY_TABLE) do
		local entry = HomeBookDataUtils._createEntry(id, config, sourceType)

		if entry then
			targetIndexes.entityById[id] = entry

			HomeBookDataUtils._addToIndex(targetIndexes.entriesByFirstType, entry.firstType, entry)
			HomeBookDataUtils._addToIndex(targetIndexes.entriesBySecondType, entry.secondType, entry)
			HomeBookDataUtils._addToIndex(targetIndexes.entriesByThirdType, entry.thirdType, entry)
		end
	end
end

function HomeBookDataUtils._ensureIndexes()
	local serverArea = Utils.getServerArea()

	if HomeBookDataUtils._indexes and HomeBookDataUtils._indexServerArea == serverArea then
		return
	end

	local indexes = {
		entityById = {},
		entriesByFirstType = {},
		entriesBySecondType = {},
		entriesByThirdType = {},
		composeEntriesByFurnitureId = {},
		secondTypesByFirstType = {},
		thirdTypesBySecondType = {}
	}

	HomeBookDataUtils._addEntriesToIndexes(indexes, FurnitureData, "furniture")
	HomeBookDataUtils._addEntriesToIndexes(indexes, ItemData, "item")
	HomeBookDataUtils._addEntriesToIndexes(indexes, ComposeData, "compose")

	for id, config in pairs(ThirdTabData) do
		if indexes.entriesByThirdType[id] then
			HomeBookDataUtils._addToIndex(indexes.thirdTypesBySecondType, config.secondType, id)
		end
	end

	for id, config in pairs(SecondTabData) do
		if indexes.thirdTypesBySecondType[id] then
			HomeBookDataUtils._addToIndex(indexes.secondTypesByFirstType, config.firstType, id)
		end
	end

	for id in pairs(ComposeData) do
		local entry = indexes.entityById[id]

		if entry then
			local furnitureSet = {}

			for _, furnitureId in ipairs(entry.composeFurnitureData or EMPTY_TABLE) do
				if not furnitureSet[furnitureId] then
					furnitureSet[furnitureId] = true

					HomeBookDataUtils._addToIndex(indexes.composeEntriesByFurnitureId, furnitureId, entry)
				end
			end
		end
	end

	for _, entryList in pairs(indexes.entriesByFirstType) do
		table.sort(entryList, function(left, right)
			return left.id < right.id
		end)
	end

	for _, entryList in pairs(indexes.entriesBySecondType) do
		table.sort(entryList, function(left, right)
			return left.id < right.id
		end)
	end

	for _, entryList in pairs(indexes.entriesByThirdType) do
		table.sort(entryList, function(left, right)
			return left.id < right.id
		end)
	end

	for _, typeList in pairs(indexes.secondTypesByFirstType) do
		table.sort(typeList, function(left, right)
			local leftConfig = SecondTabData[left] or {}
			local rightConfig = SecondTabData[right] or {}

			return (leftConfig.sortId or left) < (rightConfig.sortId or right)
		end)
	end

	for _, typeList in pairs(indexes.thirdTypesBySecondType) do
		table.sort(typeList, function(left, right)
			local leftConfig = ThirdTabData[left] or {}
			local rightConfig = ThirdTabData[right] or {}

			return (leftConfig.sortId or left) < (rightConfig.sortId or right)
		end)
	end

	HomeBookDataUtils._indexes = indexes
	HomeBookDataUtils._indexServerArea = serverArea
end

function HomeBookDataUtils.getFirstCategories()
	return HomeBookDataUtils._sortedConfigList(FirstTabData)
end

function HomeBookDataUtils.getFirstType(firstType)
	return FirstTabData[firstType]
end

function HomeBookDataUtils.getSecondType(secondType)
	return SecondTabData[secondType]
end

function HomeBookDataUtils.getThirdType(thirdType)
	return ThirdTabData[thirdType]
end

function HomeBookDataUtils.getEntriesByFirstType(firstType)
	HomeBookDataUtils._ensureIndexes()

	return HomeBookDataUtils._indexes.entriesByFirstType[firstType] or {}
end

function HomeBookDataUtils.getEntriesBySecondType(secondType)
	HomeBookDataUtils._ensureIndexes()

	return HomeBookDataUtils._indexes.entriesBySecondType[secondType] or {}
end

function HomeBookDataUtils.getEntriesByThirdType(thirdType)
	HomeBookDataUtils._ensureIndexes()

	return HomeBookDataUtils._indexes.entriesByThirdType[thirdType] or {}
end

function HomeBookDataUtils.getComposeEntriesByFurnitureId(furnitureId)
	HomeBookDataUtils._ensureIndexes()

	return HomeBookDataUtils._indexes.composeEntriesByFurnitureId[furnitureId] or {}
end

function HomeBookDataUtils.getSecondTypesByFirstType(firstType)
	HomeBookDataUtils._ensureIndexes()

	return HomeBookDataUtils._indexes.secondTypesByFirstType[firstType] or {}
end

function HomeBookDataUtils.getThirdTypesBySecondType(secondType)
	HomeBookDataUtils._ensureIndexes()

	return HomeBookDataUtils._indexes.thirdTypesBySecondType[secondType] or {}
end

function HomeBookDataUtils.getEntity(id)
	HomeBookDataUtils._ensureIndexes()

	return HomeBookDataUtils._indexes.entityById[id]
end

function HomeBookDataUtils.getAllEntity()
	HomeBookDataUtils._ensureIndexes()

	return HomeBookDataUtils._indexes.entityById
end

function HomeBookDataUtils.getEntrySortId(entryId)
	local entry = HomeBookDataUtils.getEntity(entryId)

	if entry.sourceType == "compose" then
		local composeConfig = ComposeFurnitureData[entryId] or EMPTY_TABLE

		return composeConfig.sortId or entry.sortId or entryId
	end

	return entry.sortId or entryId
end

function HomeBookDataUtils.compareEntrySort(leftEntryId, rightEntryId)
	local leftSortId = HomeBookDataUtils.getEntrySortId(leftEntryId)
	local rightSortId = HomeBookDataUtils.getEntrySortId(rightEntryId)

	if leftSortId ~= rightSortId then
		return leftSortId < rightSortId
	end

	return leftEntryId < rightEntryId
end

function HomeBookDataUtils.getCategoryDetail(level, categoryId)
	local levelData = CategoryDetailData[level]

	return levelData and levelData[categoryId]
end

function HomeBookDataUtils.getFirstCategoryTotal(firstType)
	return #HomeBookDataUtils.getEntriesByFirstType(firstType)
end

function HomeBookDataUtils.getSeasonIds()
	local seasonIds = {}

	for seasonId in pairs(SeasonData) do
		seasonIds[#seasonIds + 1] = seasonId
	end

	table.sort(seasonIds)

	return seasonIds
end

function HomeBookDataUtils.getCategorySeason(seasonId)
	local modules = {}

	for moduleId, config in pairs(SeasonData[seasonId] or EMPTY_TABLE) do
		local entities = {}

		for _, itemId in ipairs(config.moduleData or EMPTY_TABLE) do
			entities[#entities + 1] = HomeBookDataUtils.getEntity(itemId)
		end

		modules[#modules + 1] = {
			id = moduleId,
			config = config,
			entities = entities
		}
	end

	table.sort(modules, function(left, right)
		return left.id < right.id
	end)

	return modules
end

function HomeBookDataUtils.getSeasonEntryIds(seasonId)
	local entryIds = {}
	local idSet = {}

	for _, module in ipairs(HomeBookDataUtils.getCategorySeason(seasonId)) do
		for _, itemId in ipairs(module.config.moduleData or EMPTY_TABLE) do
			if not idSet[itemId] and HomeBookDataUtils.getEntity(itemId) then
				idSet[itemId] = true
				entryIds[#entryIds + 1] = itemId
			end
		end
	end

	table.sort(entryIds)

	return entryIds
end

function HomeBookDataUtils.isSeasonOpen(seasonId, now)
	local seasonConfig = HomeSeasonData[seasonId]

	if not seasonConfig or seasonConfig.seasonalPlotsEnable == 0 then
		return false
	end

	local startTime = Utils.getConfigTimeOfAreaByData(seasonConfig.startDayTime, seasonConfig.startDayTimeRefId)
	local endTime = Utils.getConfigTimeOfAreaByData(seasonConfig.endDayTime, seasonConfig.endDayTimeRefId)

	if not startTime or not endTime then
		return true
	end

	now = now or Time.getSecond()

	return startTime <= now and now <= endTime
end

function HomeBookDataUtils.getDisplaySeasonId()
	local seasonIds = HomeBookDataUtils.getSeasonIds()

	for _, seasonId in ipairs(seasonIds) do
		if HomeBookDataUtils.isSeasonOpen(seasonId) then
			return seasonId
		end
	end

	return seasonIds[1]
end

function HomeBookDataUtils.getHomeSeasonConfig(seasonId)
	return HomeSeasonData[seasonId]
end

function HomeBookDataUtils.getProgressRewards(firstType)
	local rewards = {}

	for stage, config in pairs(ProgressRewardData[firstType] or EMPTY_TABLE) do
		rewards[#rewards + 1] = {
			stage = stage,
			config = config
		}
	end

	table.sort(rewards, function(left, right)
		return left.stage < right.stage
	end)

	return rewards
end

function HomeBookDataUtils.getScoreRewards()
	return HomeBookDataUtils._sortedConfigList(ScoreRewardData)
end

function HomeBookDataUtils.getCurGradeConfig(score)
	if type(score) ~= "number" then
		return nil
	end

	local firstConfig, firstGrade, currentConfig, currentGrade

	for _, config in pairs(ScoreRewardData or EMPTY_TABLE) do
		local grade = config and config.grade

		if type(grade) == "number" then
			if firstGrade == nil or grade < firstGrade then
				firstGrade = grade
				firstConfig = config
			end

			if grade <= score and (currentGrade == nil or currentGrade < grade) then
				currentGrade = grade
				currentConfig = config
			end
		end
	end

	return currentConfig or firstConfig
end

function HomeBookDataUtils.getTotalGrade(entryIds)
	local totalGrade = 0

	for _, entryId in ipairs(entryIds or EMPTY_TABLE) do
		local entry = HomeBookDataUtils.getEntity(entryId)

		totalGrade = totalGrade + (entry and entry.addGrade or 0)
	end

	return totalGrade
end

function HomeBookDataUtils.getEntryDisplayData(entryId)
	local entry = HomeBookDataUtils.getEntity(entryId)

	if not entry then
		return nil
	end

	local name = ""
	local icon = entry.config.icon
	local quality = 1
	local itemConfig = GeneralItemData[entryId]

	if itemConfig then
		name = itemConfig.itemName and pg.getLocalizationText(itemConfig.itemName) or ""
		icon = icon or itemConfig.icon
		quality = itemConfig.quality or quality
	end

	return {
		id = entryId,
		name = name,
		icon = icon,
		quality = quality,
		addGrade = entry.addGrade or 0
	}
end

function HomeBookDataUtils.getNewCollectedEntries(oldScore, newScore)
	local result = {}

	if not pg.me or not pg.me.homeHandbookMap or newScore <= oldScore then
		return result
	end

	local candidates = {}

	for entryId, itemInfo in pairs(pg.me.homeHandbookMap or EMPTY_TABLE) do
		if type(entryId) == "number" then
			local entry = HomeBookDataUtils.getEntity(entryId)

			if entry then
				candidates[#candidates + 1] = {
					id = entryId,
					firstTime = itemInfo.firstTime or 0,
					addGrade = entry.addGrade or 0
				}
			end
		end
	end

	table.sort(candidates, function(left, right)
		if left.firstTime == right.firstTime then
			return left.id > right.id
		end

		return left.firstTime > right.firstTime
	end)

	local needGrade = newScore - oldScore
	local collectedGrade = 0
	local selected = {}

	for _, candidate in ipairs(candidates) do
		if needGrade <= collectedGrade then
			break
		end

		selected[#selected + 1] = candidate
		collectedGrade = collectedGrade + candidate.addGrade
	end

	table.sort(selected, function(left, right)
		if left.firstTime == right.firstTime then
			return left.id < right.id
		end

		return left.firstTime < right.firstTime
	end)

	for _, candidate in ipairs(selected) do
		local data = HomeBookDataUtils.getEntryDisplayData(candidate.id)

		if data then
			result[#result + 1] = data
		end
	end

	return result
end

function HomeBookDataUtils.clearCache()
	HomeBookDataUtils._indexes = nil
	HomeBookDataUtils._indexServerArea = nil
end

return HomeBookDataUtils
