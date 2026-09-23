-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandSeasonParty\\HomelandSeasonPartyModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local HomeSeasonUtils = require("Utils.HomeSeasonUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HomeSeasonConfigData = require("Data.home_season_config_data")
local HomeSeasonModuleData = require("Data.home_season_module_data")
local HomeSeasonCelebrationData = require("Data.home_season_celebration_data")
local HomeSeasonCelebrationChestData = require("Data.home_season_celebration_chest_data")
local HomeSeasonCelebrationTestConst = require("Common.Const.HomeSeasonCelebrationTestConst")
local ChestData = require("Data.chest_data")
local HomelandSeasonPartyModel = Class.LightClass("HomelandSeasonPartyModel", UIModel)

function HomelandSeasonPartyModel:ctor()
	UIModel.ctor(self)

	self.moduleId = nil
	self.seasonId = nil
	self.stageId = nil
	self.moduleConfig = nil
	self.celebrationConfig = nil
end

local function containsStage(configuredStageIds, stageId)
	for _, configuredStageId in ipairs(configuredStageIds) do
		if configuredStageId == stageId then
			return true
		end
	end

	return false
end

local function findCelebrationConfig(seasonId, stageId)
	local matchedFestivalId, matchedConfig

	for festivalId, celebrationConfig in pairs(HomeSeasonCelebrationData) do
		if celebrationConfig.seasonId == seasonId and containsStage(celebrationConfig.stageId, stageId) and (not matchedFestivalId or festivalId < matchedFestivalId) then
			matchedFestivalId = festivalId
			matchedConfig = celebrationConfig
		end
	end

	return matchedFestivalId, matchedConfig
end

local function getCelebrationChestRows(seasonId, festivalId)
	local testRow = HomeSeasonCelebrationTestConst.CHEST_ROW

	if HomeSeasonCelebrationTestConst.ENABLED and testRow.seasonId == seasonId and testRow.festivalId == festivalId then
		return {
			testRow
		}
	end

	local rows = {}

	for rowId, chestConfig in pairs(HomeSeasonCelebrationChestData) do
		if chestConfig.seasonId == seasonId and chestConfig.festivalId == festivalId then
			rows[#rows + 1] = {
				id = rowId,
				config = chestConfig
			}
		end
	end

	table.sort(rows, function(a, b)
		return a.id < b.id
	end)

	local result = {}

	for _, row in ipairs(rows) do
		result[#result + 1] = row.config
	end

	return result
end

local function buildRewardViewData(seasonId, festivalId)
	local rewards = {}
	local addedItemIds = {}

	for _, celebrationChestConfig in ipairs(getCelebrationChestRows(seasonId, festivalId)) do
		local chestConfig = ChestData[celebrationChestConfig.chestConfigId]

		if chestConfig and chestConfig.reward then
			for _, rewardData in ipairs(LuaUIUtils.getRewardItemByDropId(chestConfig.reward) or EMPTY_TABLE) do
				local rewardKey = tostring(rewardData.type) .. ":" .. tostring(rewardData.id or rewardData.petId)

				if not addedItemIds[rewardKey] then
					addedItemIds[rewardKey] = true
					rewards[#rewards + 1] = rewardData
				end
			end
		end
	end

	return rewards
end

function HomelandSeasonPartyModel:resetData()
	self.moduleId = nil
	self.seasonId = nil
	self.stageId = nil
	self.moduleConfig = nil
	self.celebrationConfig = nil
end

function HomelandSeasonPartyModel:refreshData(moduleId)
	self:resetData()

	local player = pg.me

	if not HomeSeasonUtils.isSeasonAvailable(player) then
		return nil
	end

	local seasonId = player.homeSeasonId
	local stageId = HomeSeasonUtils.getCurrentStageId(seasonId)
	local moduleConfig = HomeSeasonModuleData[moduleId]

	if not moduleConfig or moduleConfig.type ~= Const.HOMELAND_SEASON_MODULE_TYPE.PARTY or not HomeSeasonUtils.isModuleOpen(seasonId, moduleId) then
		return nil
	end

	local festivalId, celebrationConfig = findCelebrationConfig(seasonId, stageId)

	if not celebrationConfig then
		return nil
	end

	local celebrationTargetPoint = HomeSeasonConfigData.SeasonCelebrationTargetPoint

	self.moduleId = moduleId
	self.seasonId = seasonId
	self.stageId = stageId
	self.moduleConfig = moduleConfig
	self.celebrationConfig = celebrationConfig

	return {
		title = pg.getLocalizationText(moduleConfig.name),
		details = pg.getLocalizationText(moduleConfig.des),
		startTime = Utils.getConfigTimeOfAreaByData(moduleConfig.startDayTime, moduleConfig.startDayTimeRefId),
		endTime = Utils.getConfigTimeOfAreaByData(moduleConfig.endDayTime, moduleConfig.endDayTimeRefId),
		targetSceneId = celebrationTargetPoint and celebrationTargetPoint[1] or nil,
		targetPositionId = celebrationTargetPoint and celebrationTargetPoint[2] or nil,
		rewards = buildRewardViewData(seasonId, festivalId)
	}
end

return HomelandSeasonPartyModel
