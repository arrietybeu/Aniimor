-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\VitalityPetChoice\\VitalityPetChoiceModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local UIConst = require("Const.UIConst")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local EnergyMatchThemeData = require("Data.energy_match_theme_data")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local VitalityPetChoiceModel = Class.LightClass("VitalityPetChoiceModel", UIModel)
local VITALITY_SORT_ID = 8
local DEFAULT_FILTER = {
	isSup = false,
	isDPS = false,
	isUnFavorite = false,
	isFavorite = false,
	isRainbow = false,
	isDark = false,
	isBoss = false,
	isShiny = false,
	isNormal = false,
	keyword = "",
	isNotRareFeature = false,
	isRareFeature = false,
	isInHomeland = false,
	isInExplore = false,
	isNotInBattle = false,
	isInBattle = false,
	isNone = false,
	isSwim = false,
	isGlide = false,
	isClimb = false,
	isRating4 = false,
	isRating3 = false,
	isRating2 = false,
	isRating1 = false,
	isEnergy = false,
	isBreak = false,
	isHeal = false,
	filterType = UIConst.PET_SLOT_DISPLAY_TYPE.Normal,
	elements = {}
}

local function cloneDefaultFilter()
	local filter = {}

	for key, value in pairs(DEFAULT_FILTER) do
		if type(value) == "table" then
			local list = {}

			for index, item in pairs(value) do
				list[index] = item
			end

			filter[key] = list
		else
			filter[key] = value
		end
	end

	return filter
end

function VitalityPetChoiceModel:getPetData(phase, themeId)
	self.phase = phase
	self.themeId = themeId
	self.themeData = self:getThemeData()
	PetManagementDataHelper.selectSortId = self:getSelectSortId()
	PetManagementDataHelper.isDescending = self:getSortSwitchStatus()

	PetManagementDataHelper.setFilter(self:getFilter())

	local petsInfo = {}

	for _, petInfo in ipairs(PetManagementDataHelper.getFilteredPetsInfo()) do
		if not petInfo.isEmpty then
			petsInfo[#petsInfo + 1] = petInfo
		end
	end

	for _, petInfo in pairs(petsInfo) do
		local scoreData = self:getScore(petInfo)

		petInfo.scoreData = scoreData
		petInfo.vitalityScore = scoreData.totalScore
	end

	if self.useVitalitySort then
		if self.isDescending then
			table.sort(petsInfo, function(a, b)
				return a.vitalityScore > b.vitalityScore
			end)
		else
			table.sort(petsInfo, function(a, b)
				return a.vitalityScore < b.vitalityScore
			end)
		end
	end

	return petsInfo
end

function VitalityPetChoiceModel:getThemeData()
	return EnergyMatchThemeData[self.phase] and EnergyMatchThemeData[self.phase][self.themeId] or {}
end

function VitalityPetChoiceModel:getScore(petInfo)
	local themeData = self.themeData or self:getThemeData()
	local detailScores = {}
	local scoreData = {
		baseScore = ActivityUtils.getEnergyMatchPetBaseScore(petInfo, themeData, detailScores),
		formBonusScore = ActivityUtils.getEnergyMatchPetFormBonusScore(petInfo, themeData),
		newStarScore = ActivityUtils.getEnergyMatchPetNewStarScore(petInfo, themeData)
	}

	scoreData.totalScore = scoreData.baseScore + scoreData.formBonusScore + scoreData.newStarScore
	scoreData.sumScore = scoreData.baseScore
	scoreData.formScore = scoreData.formBonusScore
	scoreData.newScore = scoreData.newStarScore

	self:fillOldScoreListData(scoreData, themeData, detailScores)

	return scoreData
end

function VitalityPetChoiceModel:fillOldScoreListData(scoreData, themeData, detailScores)
	local baseScore = themeData and themeData.baseScore or 0

	detailScores = detailScores or {}
	scoreData.ability = detailScores.ability or baseScore
	scoreData.attribute = detailScores.attribute or baseScore
	scoreData.position = detailScores.position or baseScore
	scoreData.form = detailScores.form or baseScore
	scoreData.personality = detailScores.personality or baseScore
	scoreData.evolution = detailScores.evolution or baseScore
	scoreData.abilityName = pg.getGameString("VITALITY_PET_SCORE_EXPLORE")
	scoreData.attributeName = pg.getGameString("VITALITY_PET_SCORE_ELEMENT")
	scoreData.positionName = pg.getGameString("VITALITY_PET_SCORE_ORIENTATION")
	scoreData.formName = pg.getGameString("VITALITY_PET_SCORE_FORM")
	scoreData.personalityName = pg.getGameString("VITALITY_PET_SCORE_PERSONALITY")
	scoreData.evolutionName = pg.getGameString("VITALITY_PET_SCORE_STAGE")
end

function VitalityPetChoiceModel:getSelectSortId()
	if self.useVitalitySort then
		return VITALITY_SORT_ID
	end

	if not self.selectSortId then
		self.selectSortId = 0
	end

	return self.selectSortId
end

function VitalityPetChoiceModel:getSortSwitchStatus()
	if self.isDescending == nil then
		self.isDescending = true
	end

	return self.isDescending
end

function VitalityPetChoiceModel:getFilter()
	if self.filter == nil then
		self.filter = cloneDefaultFilter()
	end

	return self.filter
end

function VitalityPetChoiceModel:setFilter(data)
	data = data or {}

	local filter = cloneDefaultFilter()

	for key in pairs(DEFAULT_FILTER) do
		if data[key] ~= nil then
			filter[key] = data[key]
		end
	end

	self.filter = filter
end

function VitalityPetChoiceModel:isDefaultFilter()
	local filter = self:getFilter()

	for key, defaultValue in pairs(DEFAULT_FILTER) do
		local value = filter[key]

		if type(defaultValue) == "table" then
			if type(value) ~= "table" or next(value) ~= nil then
				return false
			end
		elseif value ~= defaultValue then
			return false
		end
	end

	return true
end

return VitalityPetChoiceModel
