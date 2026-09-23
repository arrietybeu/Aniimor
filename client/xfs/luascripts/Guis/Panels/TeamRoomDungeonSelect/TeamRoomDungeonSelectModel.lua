-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TeamRoomDungeonSelect\\TeamRoomDungeonSelectModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local LevelData = require("Data.level_data")
local DungeonDifficultLevelData = require("Data.dungeon_difficult_level_data")
local TeamPlayData = require("Data.team_play_data")
local Time = require("Core.Common.Time")
local TimeUtils = require("Common.Utils.TimeUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local BossRushUtils = require("Utils.BossRushUtils")
local GrabEggsModeModel = require("Guis.Panels.GrabEggsMode.GrabEggsModeModel")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local TeamRoomDungeonSelectModel = Class.LightClass("TeamRoomDungeonSelectModel", UIModel)

TeamRoomDungeonSelectModel.SELECT_STATE_NONE = 0
TeamRoomDungeonSelectModel.SELECT_STATE_TIME_LOCK = 1
TeamRoomDungeonSelectModel.SELECT_STATE_CAN_CONFIRM = 2
TeamRoomDungeonSelectModel.SELECT_STATE_TITLE_LOCK = 3

function TeamRoomDungeonSelectModel:getDungeonList()
	local ret = {}

	for categoryId, _ in pairs(TeamPlayData) do
		local levelList = self:getCategoryLevelList(categoryId)

		if #levelList > 0 then
			local firstLevelData = levelList[1]

			ret[#ret + 1] = {
				categoryId = categoryId,
				dungeonId = firstLevelData.dungeonId,
				dungeonConfig = firstLevelData.dungeonConfig,
				levelList = levelList,
				pic_small = firstLevelData.teamPlayConfig.pic_small
			}
		end
	end

	table.sort(ret, function(a, b)
		return a.categoryId < b.categoryId
	end)

	return ret
end

function TeamRoomDungeonSelectModel:isTeamRoomDungeon(dungeonConfig)
	return dungeonConfig.name and dungeonConfig.playerNumMin and dungeonConfig.playerNumMax and dungeonConfig.playerNumMax > 1
end

function TeamRoomDungeonSelectModel:getCategoryLevelList(categoryId)
	local ret = {}
	local categoryData = TeamPlayData[categoryId]

	if not categoryData then
		return ret
	end

	for subId, teamPlayConfig in pairs(categoryData) do
		local levelData = self:getTeamPlayLevelData(categoryId, subId, teamPlayConfig)

		if levelData then
			ret[#ret + 1] = levelData
		end
	end

	table.sort(ret, function(a, b)
		return a.subId < b.subId
	end)

	return ret
end

function TeamRoomDungeonSelectModel:getTeamPlayLevelData(categoryId, subId, teamPlayConfig)
	local dungeonId = teamPlayConfig and teamPlayConfig.fbId
	local dungeonConfig = dungeonId and LevelData[dungeonId]

	if not self:isTeamRoomDungeon(dungeonConfig) then
		return nil
	end

	local difficultyID = self:getTeamPlayDifficultyID(dungeonId, teamPlayConfig)

	return {
		categoryId = categoryId,
		subId = subId,
		dungeonId = dungeonId,
		difficultyID = difficultyID,
		dungeonConfig = dungeonConfig,
		difficultyConfig = self:getDifficultyConfig(dungeonId, difficultyID),
		teamPlayConfig = teamPlayConfig
	}
end

function TeamRoomDungeonSelectModel:getTeamPlayDifficultyID(dungeonId, teamPlayConfig)
	if teamPlayConfig.difficultyID and teamPlayConfig.difficultyID > 0 then
		return teamPlayConfig.difficultyID
	end

	local difficultLevelData = DungeonDifficultLevelData[dungeonId]

	if not difficultLevelData then
		return 0
	end

	local defaultDifficultyID = 0

	for difficultyID, _ in pairs(difficultLevelData) do
		if defaultDifficultyID > 0 then
			return 0
		end

		defaultDifficultyID = difficultyID
	end

	return defaultDifficultyID
end

function TeamRoomDungeonSelectModel:getDungeonLevelList(dungeonId)
	local ret = {}

	for categoryId, categoryData in pairs(TeamPlayData) do
		for subId, teamPlayConfig in pairs(categoryData) do
			if teamPlayConfig.fbId == dungeonId then
				local levelData = self:getTeamPlayLevelData(categoryId, subId, teamPlayConfig)

				if levelData then
					ret[#ret + 1] = levelData
				end
			end
		end
	end

	table.sort(ret, function(a, b)
		if a.difficultyID ~= b.difficultyID then
			return a.difficultyID < b.difficultyID
		end

		return a.subId < b.subId
	end)

	return ret
end

function TeamRoomDungeonSelectModel:hasDifficultySelect(dungeonId)
	for _, levelData in ipairs(self:getDungeonLevelList(dungeonId)) do
		if levelData.difficultyID > 0 then
			return true
		end
	end

	return false
end

function TeamRoomDungeonSelectModel:getCategoryIdByDungeon(dungeonId, difficultyID)
	for categoryId, categoryData in pairs(TeamPlayData) do
		for _, teamPlayConfig in pairs(categoryData) do
			if teamPlayConfig.fbId == dungeonId and (not difficultyID or difficultyID <= 0 or self:getTeamPlayDifficultyID(dungeonId, teamPlayConfig) == difficultyID) then
				return categoryId
			end
		end
	end

	return 0
end

function TeamRoomDungeonSelectModel:getDefaultDifficultyID(dungeonId, hardLv)
	local levelList = self:getDungeonLevelList(dungeonId)

	if hardLv then
		for _, levelData in ipairs(levelList) do
			if levelData.difficultyID == hardLv then
				return hardLv
			end
		end
	end

	return levelList[1] and levelList[1].difficultyID or 0
end

function TeamRoomDungeonSelectModel:getDifficultyConfig(dungeonId, difficultyID)
	if not difficultyID or difficultyID <= 0 then
		return nil
	end

	local difficultLevelData = DungeonDifficultLevelData[dungeonId]

	return difficultLevelData and difficultLevelData[difficultyID]
end

function TeamRoomDungeonSelectModel:isDifficultyOpen(difficultyConfig)
	if not difficultyConfig or not difficultyConfig.timeRanges then
		return true
	end

	local dayCfg = difficultyConfig.timeRanges[tonumber(os.date("%w", Time.secondCache))]

	if not dayCfg or #dayCfg == 0 then
		return true
	end

	for _, timeCfg in ipairs(dayCfg) do
		if #timeCfg >= 2 and TimeUtils.isInRangeTimestamp(TimeUtils.stringToAreaTimestamp(timeCfg[1]), TimeUtils.stringToAreaTimestamp(timeCfg[2])) then
			return true
		end
	end

	return false
end

function TeamRoomDungeonSelectModel:getOpenTimeTip(difficultyConfig)
	local dayCfg = difficultyConfig and difficultyConfig.timeRanges and difficultyConfig.timeRanges[tonumber(os.date("%w", Time.secondCache))]
	local timeCfg = dayCfg and dayCfg[1]

	if not timeCfg or #timeCfg < 2 then
		return ""
	end

	return pg.getFormatText(pg.getGameString("GRAB_EGG_OPEN_LIMIT_TIME_TIP"), TimeUtils.timeStringToHM(timeCfg[1]), TimeUtils.timeStringToHM(timeCfg[2]))
end

function TeamRoomDungeonSelectModel:isTitleEnough(difficultyConfig)
	return not difficultyConfig or (pg.me.starTitle or 0) >= (difficultyConfig.serverLevel or 0)
end

function TeamRoomDungeonSelectModel:getTitleLockTip(difficultyConfig)
	local titleName = LuaUIUtils.getStarTitleName(difficultyConfig and difficultyConfig.serverLevel or 0, true)

	return pg.getFormatText(pg.getGameString("GRAB_EGG_MODE_CONDITION_TITLE"), titleName)
end

function TeamRoomDungeonSelectModel:getPlayModeSelectState(dungeonId, difficultyID)
	if Utils.isRobEggSceneId(dungeonId) then
		return self:getGrabEggSelectState(dungeonId, difficultyID)
	end

	if dungeonId == Const.BossRushSceneId then
		return self:getBossRushSelectState()
	end
end

function TeamRoomDungeonSelectModel:getGrabEggSelectState(dungeonId, difficultyID)
	local canEnter, lockResult = GrabEggsModeModel:checkRobEggCanEnter(dungeonId, difficultyID)

	if canEnter then
		return TeamRoomDungeonSelectModel.SELECT_STATE_CAN_CONFIRM, ""
	end

	return self:getGrabEggLockState(lockResult), GrabEggsModeModel:getLockTipFinalText(lockResult, dungeonId)
end

function TeamRoomDungeonSelectModel:getGrabEggLockState(lockResult)
	if lockResult.lackTime and #lockResult.lackConditions == 0 and not lockResult.lackRank then
		return TeamRoomDungeonSelectModel.SELECT_STATE_TIME_LOCK
	end

	return TeamRoomDungeonSelectModel.SELECT_STATE_TITLE_LOCK
end

function TeamRoomDungeonSelectModel:getBossRushSelectState()
	if not BossRushUtils.checkIsOpen() then
		return TeamRoomDungeonSelectModel.SELECT_STATE_TIME_LOCK, pg.getGameString("BOSS_RUSH_NEXT_START_TIME")
	end
end

function TeamRoomDungeonSelectModel:getSelectState(dungeonId, difficultyID)
	if not dungeonId or dungeonId <= 0 then
		return TeamRoomDungeonSelectModel.SELECT_STATE_NONE, pg.getGameString("TEAM_ROOM_DUNGEON_SELECT_TARGET_FIRST")
	end

	if (not difficultyID or difficultyID <= 0) and self:hasDifficultySelect(dungeonId) then
		return TeamRoomDungeonSelectModel.SELECT_STATE_NONE, pg.getGameString("TEAM_ROOM_DUNGEON_SELECT_DIFFICULTY_FIRST")
	end

	local playState, playTips = self:getPlayModeSelectState(dungeonId, difficultyID)

	if playState then
		return playState, playTips
	end

	local difficultyConfig = self:getDifficultyConfig(dungeonId, difficultyID)

	if not self:isDifficultyOpen(difficultyConfig) then
		return TeamRoomDungeonSelectModel.SELECT_STATE_TIME_LOCK, self:getOpenTimeTip(difficultyConfig)
	end

	if not self:isTitleEnough(difficultyConfig) then
		return TeamRoomDungeonSelectModel.SELECT_STATE_TITLE_LOCK, self:getTitleLockTip(difficultyConfig)
	end

	return TeamRoomDungeonSelectModel.SELECT_STATE_CAN_CONFIRM, ""
end

function TeamRoomDungeonSelectModel:isCanConfirmState(selectState)
	return selectState == TeamRoomDungeonSelectModel.SELECT_STATE_CAN_CONFIRM
end

return TeamRoomDungeonSelectModel
