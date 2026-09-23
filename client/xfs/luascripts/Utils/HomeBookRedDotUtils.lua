-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\HomeBookRedDotUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Const = require("Common.Const.Const")
local RedDotConst = require("Const.RedDotConst")
local MessageName = require("Const.MessageName")
local HomeBookDataUtils = require("Utils.HomeBookDataUtils")
local HomeBookRedDotUtils = {}
local UNREAD_SNAPSHOT_KEY = "unread_snapshot"
local SNAPSHOT_VERSION_KEY = "snapshot_version"
local SNAPSHOT_VERSION = 1

local function getPlayer()
	return pg and pg.me
end

local function getLegacyContentReadKey(entry)
	return string.format("content_%s_%d", entry.sourceType, entry.id)
end

local function getContentProgress(entry, player)
	if entry.sourceType ~= "compose" then
		if player:isHomeHandbookItemCollected(entry.id) then
			return 1
		end

		return 0
	end

	local requirements = {}

	for _, furnitureId in ipairs(entry.composeFurnitureData or EMPTY_TABLE) do
		local needCount = requirements[furnitureId] or 0

		requirements[furnitureId] = needCount + 1
	end

	local progress = 0

	for furnitureId, needCount in pairs(requirements) do
		local itemInfo = player:getHomeHandbookItemInfo(furnitureId)
		local ownedCount = 0

		if itemInfo then
			ownedCount = itemInfo.count or 0
		end

		progress = progress + math.min(ownedCount, needCount)
	end

	return progress
end

local function migrateUnreadSnapshot(player)
	local snapshot = {}

	for _, entry in pairs(HomeBookDataUtils.getAllEntity()) do
		local progress = getContentProgress(entry, player)
		local viewedProgress = player:getRedDotRecord(Const.CLIENT_KEY.HOME_BOOK_RED_DOT, getLegacyContentReadKey(entry), 0)

		if viewedProgress < progress then
			snapshot[entry.id] = true
		end
	end

	player:replaceClientInfo(Const.CLIENT_KEY.HOME_BOOK_RED_DOT, {
		[UNREAD_SNAPSHOT_KEY] = snapshot,
		[SNAPSHOT_VERSION_KEY] = SNAPSHOT_VERSION
	})

	return snapshot
end

local function getUnreadSnapshot(player)
	local version = player:getClientInfo(Const.CLIENT_KEY.HOME_BOOK_RED_DOT, SNAPSHOT_VERSION_KEY)

	if version ~= SNAPSHOT_VERSION then
		return migrateUnreadSnapshot(player)
	end

	return player:getClientInfo(Const.CLIENT_KEY.HOME_BOOK_RED_DOT, UNREAD_SNAPSHOT_KEY)
end

local function notifyReadChanged()
	facade:sendMsgToUI(MessageName.ON_HOME_BOOK_RED_DOT_CHANGED)
end

local function markUnread(snapshot, entryId)
	if snapshot[entryId] then
		return false
	end

	snapshot[entryId] = true

	return true
end

local function markComposeUnread(snapshot, furnitureId)
	local changed = false

	for _, entry in ipairs(HomeBookDataUtils.getComposeEntriesByFurnitureId(furnitureId)) do
		if markUnread(snapshot, entry.id) then
			changed = true
		end
	end

	return changed
end

local function markComposeProgressUnread(snapshot, furnitureId, oldCount, newCount)
	local changed = false

	for _, entry in ipairs(HomeBookDataUtils.getComposeEntriesByFurnitureId(furnitureId)) do
		local needCount = 0

		for _, requiredFurnitureId in ipairs(entry.composeFurnitureData) do
			if requiredFurnitureId == furnitureId then
				needCount = needCount + 1
			end
		end

		if math.min(newCount, needCount) > math.min(oldCount, needCount) and markUnread(snapshot, entry.id) then
			changed = true
		end
	end

	return changed
end

function HomeBookRedDotUtils.recordNewUnlock(itemId)
	local player = getPlayer()

	if not player then
		return
	end

	local snapshot = getUnreadSnapshot(player)
	local changed = markUnread(snapshot, itemId)

	changed = markComposeUnread(snapshot, itemId) or changed

	if changed then
		player:setClientInfo(Const.CLIENT_KEY.HOME_BOOK_RED_DOT, UNREAD_SNAPSHOT_KEY, snapshot)
	end
end

function HomeBookRedDotUtils.recordComposeProgress(itemId, oldCount, newCount)
	local player = getPlayer()

	if not player then
		return
	end

	local snapshot = getUnreadSnapshot(player)

	if markComposeProgressUnread(snapshot, itemId, oldCount, newCount) then
		player:setClientInfo(Const.CLIENT_KEY.HOME_BOOK_RED_DOT, UNREAD_SNAPSHOT_KEY, snapshot)
	end
end

function HomeBookRedDotUtils.getUnreadSnapshot()
	local player = getPlayer()

	if not player then
		return false
	end

	return getUnreadSnapshot(player)
end

function HomeBookRedDotUtils.hasThirdNew(thirdType)
	local data = HomeBookRedDotUtils.getUnreadSnapshot()

	if not data or next(data) == nil then
		return false
	end

	for _, entry in ipairs(HomeBookDataUtils.getEntriesByThirdType(thirdType)) do
		if data[entry.id] == true then
			return true
		end
	end

	return false
end

function HomeBookRedDotUtils.hasSecondNew(secondType)
	local data = HomeBookRedDotUtils.getUnreadSnapshot()

	if not data or next(data) == nil then
		return false
	end

	for _, entry in ipairs(HomeBookDataUtils.getEntriesBySecondType(secondType)) do
		if data[entry.id] == true then
			return true
		end
	end

	return false
end

function HomeBookRedDotUtils.hasFirstNew(firstType)
	local data = HomeBookRedDotUtils.getUnreadSnapshot()

	if not data or next(data) == nil then
		return false
	end

	for _, entry in ipairs(HomeBookDataUtils.getEntriesByFirstType(firstType)) do
		if data[entry.id] == true then
			return true
		end
	end

	return false
end

function HomeBookRedDotUtils.markSecondRead(secondType)
	local player = getPlayer()

	if not player then
		return
	end

	local snapshot = getUnreadSnapshot(player)
	local changed = false
	local firstType

	for _, entry in ipairs(HomeBookDataUtils.getEntriesBySecondType(secondType)) do
		if snapshot[entry.id] then
			snapshot[entry.id] = nil
			changed = true
		end

		firstType = entry.firstType
	end

	if changed then
		player:setClientInfo(Const.CLIENT_KEY.HOME_BOOK_RED_DOT, UNREAD_SNAPSHOT_KEY, snapshot)
	end

	HomeBookRedDotUtils.refreshTree(firstType)
	notifyReadChanged()
end

function HomeBookRedDotUtils.isCategoryRewardClaimable(categoryId, reward)
	local player = getPlayer()

	if not player or not reward then
		return false
	end

	local collectedCount = player:getHomeHandbookCategoryCount(categoryId)
	local receivedCount = player:getHomeHandbookReceivedCategoryCount(categoryId)
	local needCount = reward.config.stageNum or 0

	if receivedCount < needCount and needCount <= collectedCount then
		return true
	end

	return false
end

function HomeBookRedDotUtils.canReceiveCategoryReward(categoryId, isUnlocked)
	if not isUnlocked then
		return false
	end

	for _, reward in ipairs(HomeBookDataUtils.getProgressRewards(categoryId)) do
		if HomeBookRedDotUtils.isCategoryRewardClaimable(categoryId, reward) then
			return true
		end
	end

	return false
end

function HomeBookRedDotUtils.isScoreRewardClaimable(reward)
	local player = getPlayer()

	if not player or not reward then
		return false
	end

	local score = player:getHomeHandbookScore()
	local receivedGrade = player:getHomeHandbookLastReceivedGrade()
	local needGrade = reward.config.grade or 0

	if receivedGrade < needGrade and needGrade <= score then
		return true
	end

	return false
end

function HomeBookRedDotUtils.canReceiveScoreReward()
	for _, reward in ipairs(HomeBookDataUtils.getScoreRewards()) do
		if HomeBookRedDotUtils.isScoreRewardClaimable(reward) then
			return true
		end
	end

	return false
end

function HomeBookRedDotUtils.getSecondNewPath(firstType, secondType)
	return string.format(RedDotConst.RedDotPath.HOME_BOOK_SECOND_NEW, firstType, secondType)
end

function HomeBookRedDotUtils.getThirdNewPath(firstType, secondType, thirdType)
	return string.format(RedDotConst.RedDotPath.HOME_BOOK_THIRD_NEW, firstType, secondType, thirdType)
end

function HomeBookRedDotUtils.getContentNewPath(entry)
	return string.format(RedDotConst.RedDotPath.HOME_BOOK_CONTENT_NEW, entry.firstType, entry.secondType, entry.thirdType, entry.sourceType, entry.id)
end

function HomeBookRedDotUtils.getCategoryRewardPath(categoryId, stage)
	return string.format(RedDotConst.RedDotPath.HOME_BOOK_CATEGORY_REWARD, categoryId, stage)
end

function HomeBookRedDotUtils.getScoreRewardPath(rewardId)
	return string.format(RedDotConst.RedDotPath.HOME_BOOK_SCORE_REWARD_ITEM, rewardId)
end

local function isConditionUnlocked(player, conditionId)
	if not conditionId or conditionId == 0 then
		return true
	end

	if player.triggerMap and player.triggerMap:isCompleteOrMeetCondition(conditionId) == true then
		return true
	end

	return false
end

function HomeBookRedDotUtils.getHudStyle()
	local player = getPlayer()

	if not player then
		return RedDotConst.RedDotStyle.NONE
	end

	if HomeBookRedDotUtils.canReceiveScoreReward() then
		return RedDotConst.RedDotStyle.REWARD
	end

	for _, category in ipairs(HomeBookDataUtils.getFirstCategories()) do
		local categoryId = category.id
		local isUnlocked = isConditionUnlocked(player, category.config.unlockCondition)

		if HomeBookRedDotUtils.canReceiveCategoryReward(categoryId, isUnlocked) then
			return RedDotConst.RedDotStyle.REWARD
		end
	end

	return RedDotConst.RedDotStyle.NONE
end

function HomeBookRedDotUtils.bindHud(widget)
	if not pg or not pg.global or not pg.global.setRedDot then
		return
	end

	local style = HomeBookRedDotUtils.getHudStyle()

	pg.global.setRedDot(RedDotConst.RedDotPath.HOME_BOOK_HUD_REWARD, widget, style ~= RedDotConst.RedDotStyle.NONE, style)
end

function HomeBookRedDotUtils.refreshTree(firstType)
	if firstType ~= nil and not HomeBookDataUtils.getFirstType(firstType) then
		return
	end

	if not pg or not pg.global or not pg.global.refreshRedDotState then
		return
	end

	if firstType then
		pg.global.refreshRedDotState(string.format(RedDotConst.RedDotPath.HOME_BOOK_ENTRY, firstType))
	end

	pg.global.refreshRedDotState(RedDotConst.RedDotPath.HOME_BOOK_SCORE)
end

return HomeBookRedDotUtils
