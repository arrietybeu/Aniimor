-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeBook\\HomeBookModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local RedDotConst = require("Const.RedDotConst")
local HomeBookDataUtils = require("Utils.HomeBookDataUtils")
local HomeBookRedDotUtils = require("Utils.HomeBookRedDotUtils")
local HomeBookModel = Class.LightClass("HomeBookModel", UIModel)
local DEFAULT_SEASON_CATEGORY_ID = 3

function HomeBookModel:checkCondition(conditionId)
	if not conditionId or conditionId == 0 then
		return true
	end

	return pg.me and pg.me.triggerMap and pg.me.triggerMap:isCompleteOrMeetCondition(conditionId) == true
end

function HomeBookModel:getLocalizedText(textId)
	return textId and pg.getLocalizationText(textId) or ""
end

function HomeBookModel:isSeasonCategory(categoryId, config)
	if config.isSeason ~= nil then
		return config.isSeason == true or config.isSeason == 1
	end

	return categoryId == DEFAULT_SEASON_CATEGORY_ID
end

function HomeBookModel:buildEntranceData(categoryId, config)
	local isSeason = self:isSeasonCategory(categoryId, config)
	local seasonId = isSeason and (config.seasonId or HomeBookDataUtils.getDisplaySeasonId()) or nil
	local seasonConfig = seasonId and HomeBookDataUtils.getHomeSeasonConfig(seasonId)
	local unlockCondition = config.unlockCondition or seasonConfig and seasonConfig.seasonUnlock
	local isUnlockConditionMet = self:checkCondition(unlockCondition)
	local isSeasonOpen = false
	local isUnlocked = isUnlockConditionMet
	local collectedCount, totalCount

	if isSeason then
		collectedCount = seasonId and pg.me:getHomeHandbookSeasonCount(seasonId) or 0
		totalCount = seasonId and #HomeBookDataUtils.getSeasonEntryIds(seasonId) or 0
		isSeasonOpen = HomeBookDataUtils.isSeasonOpen(seasonId)
		isUnlocked = isUnlockConditionMet and seasonId ~= nil and isSeasonOpen
	else
		collectedCount = pg.me:getHomeHandbookCategoryCount(categoryId)
		totalCount = HomeBookDataUtils.getFirstCategoryTotal(categoryId)
	end

	local unlockDesc = self:getLocalizedText(config.unlockDesc or seasonConfig and seasonConfig.seasonalPlotsUnlockDes)

	if isSeason then
		if not isUnlockConditionMet then
			unlockDesc = pg.getGameString("SEASON_BOOK_LOCK_DESC")
		elseif not isSeasonOpen then
			unlockDesc = pg.getGameString("HOMELAND_SEASON_LOCK_TIP")
		end
	end

	local entry = {
		categoryId = categoryId,
		seasonId = seasonId,
		isSeason = isSeason,
		name = self:getLocalizedText(config.name),
		icon = config.icon,
		picture = config.pic,
		collectedCount = collectedCount,
		totalCount = totalCount,
		isUnlocked = isUnlocked,
		unlockDesc = unlockDesc,
		redDotPath = string.format(RedDotConst.RedDotPath.HOME_BOOK_ENTRY_DISPLAY, categoryId)
	}

	if isSeason then
		entry.isNew = false
	elseif isUnlocked then
		entry.isNew = HomeBookRedDotUtils.hasFirstNew(categoryId)
	else
		entry.isNew = false
	end

	entry.hasReward = HomeBookRedDotUtils.canReceiveCategoryReward(categoryId, isUnlocked)

	return entry
end

function HomeBookModel:getEntranceList()
	local entranceList = {}

	if not pg.me then
		return entranceList
	end

	for _, category in ipairs(HomeBookDataUtils.getFirstCategories()) do
		local entry = self:buildEntranceData(category.id, category.config)

		entry.slotIndex = #entranceList + 1

		if entry.collectedCount > 0 then
			entry.progressText = string.format("<color=#D18219>%d</color>/%d", entry.collectedCount, entry.totalCount)
		else
			entry.progressText = string.format("%d/%d", entry.collectedCount, entry.totalCount)
		end

		entranceList[#entranceList + 1] = entry
	end

	return entranceList
end

return HomeBookModel
