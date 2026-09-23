-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearch\\PetResearchModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local RedDotConst = require("Const.RedDotConst")
local MapConfigData = require("Data.map_area_config_data")
local PetResearchModel = Class.LightClass("PetResearchModel", UIModel)

PetResearchModel.ORDER_TYPE_NO = 1
PetResearchModel.ORDER_TYPE_LEVEL = 2

function PetResearchModel:ctor()
	self.areaId = PetResearchUtils.DEFAULT_AREA_ID
	self.isCollection = false
	self.petNumInfo = {}
end

function PetResearchModel:initData(info)
	self.areaId = PetResearchUtils.resolvePetResearchAreaId(info)
	self.showTab = info and info.showTab or PetResearchUtils.getLastPetShowTab()

	local countryData = MapConfigData[self.areaId]

	self.isCollection = countryData.belongNation >= PetResearchUtils.COLLECTION_NATION
	self.specialNation = countryData.specialNation == 1

	self:setPetNumInfo(PetResearchUtils.PET_SHOW_TAB.SPECIES)
	self:setPetNumInfo(PetResearchUtils.PET_SHOW_TAB.FORM)
end

function PetResearchModel:tryGetPetInfos(orderType, isAscendingOrder, focusTemplateId, countryId, showTab)
	local ret = PetResearchUtils.tryGetPetInfos(orderType, isAscendingOrder, nil, countryId, showTab)
	local focusIdx

	for idx, data in ipairs(ret) do
		local isFocusPet = false

		if focusTemplateId then
			if showTab == PetResearchUtils.PET_SHOW_TAB.SPECIES then
				isFocusPet = Utils.getBasePetPrototypeId(focusTemplateId) == Utils.getBasePetPrototypeId(data.templateId)
			else
				isFocusPet = focusTemplateId == data.templateId
			end
		end

		if isFocusPet and data.state ~= PetResearchUtils.PET_STATE_IS_EMPTY then
			focusIdx = idx
		end

		data.hasShow = false
	end

	return ret, focusIdx
end

function PetResearchModel:setPetNumInfo(showTab)
	local numInfo = PetResearchUtils.getAreaPetCollectInfo(self.areaId, showTab)

	self.petNumInfo[showTab] = numInfo
end

function PetResearchModel:redDot_GetPetResearchState(hideReportRedDot)
	if not LuaUIUtils.checkFuncUnlock(Const.FUNCTION_IDS.PETRESEARCH) then
		return RedDotConst.RedDotStyle.NONE
	end

	if hideReportRedDot ~= true and PetResearchUtils.checkHasStarRaiseInReport(self.areaId) then
		return RedDotConst.RedDotStyle.STAR_RAISE
	end

	if PetResearchUtils.checkHasPetRedDotInCountry(self.areaId) == RedDotConst.RedDotStyle.REWARD then
		return RedDotConst.RedDotStyle.REWARD
	end

	if PetResearchUtils.checkCountryReward(self.areaId, PetResearchUtils.PET_SHOW_TAB.SPECIES) then
		return RedDotConst.RedDotStyle.REWARD
	end

	if PetResearchUtils.checkCountryReward(self.areaId, PetResearchUtils.PET_SHOW_TAB.FORM) then
		return RedDotConst.RedDotStyle.REWARD
	end

	if PetResearchUtils.checkHasPetTopicRewardByCountryId(self.areaId) then
		return RedDotConst.RedDotStyle.REWARD
	end

	return RedDotConst.RedDotStyle.NONE
end

PetResearchModel.REWARD_COLLECT = PetResearchUtils.REWARD_COLLECT
PetResearchModel.REWARD_LEVEL = PetResearchUtils.REWARD_LEVEL

function PetResearchModel:checkCountryReward(countryId, rewardType)
	return PetResearchUtils.checkCountryReward(countryId, self.showTab, rewardType)
end

return PetResearchModel
