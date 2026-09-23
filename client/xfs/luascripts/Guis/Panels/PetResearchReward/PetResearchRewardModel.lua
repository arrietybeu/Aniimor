-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchReward\\PetResearchRewardModel.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local logger = LoggerManager.getLogger("PetResearchRewardModel")
local UIModel = require("Guis.UIModel")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local RewardUtils = require("Common.Utils.RewardUtils")
local PetResearchUtils = require("Common.Utils.PetResearchUtils")
local ItemData = require("Data.item_data")
local PetData = require("Data.pet_data")
local PetResearchLevelData = require("Data.pet_research_level_data")
local PetResearchRewardData = require("Data.pet_research_reward_data")
local PetResearchContentData = require("Data.pet_research_content_data")
local PetResearchRewardModel = Class.LightClass("PetResearchRewardModel", UIModel)

function PetResearchRewardModel:ctor()
	self.petHandbookMap = pg.me.petHandbookMap
end

function PetResearchRewardModel:getProgressLevelInfoList()
	local infoList = {}

	infoList[1] = {
		level = 0,
		title = PetResearchLevelData[0].title
	}

	local min = Const.PET_RESEARCH_REWARD_LEVEL_MIN
	local max = Const.PET_RESEARCH_REWARD_LEVEL_MAX

	for lv = min, max do
		local index = lv + 1

		infoList[index] = {}

		local levelData = PetResearchLevelData[lv]

		if levelData ~= nil then
			infoList[index].level = lv
			infoList[index].title = levelData.title
		end
	end

	return infoList
end

function PetResearchRewardModel:getPetName(petTemplateId)
	local petData = PetData[petTemplateId]

	return pg.getLocalizationText(petData.name or "")
end

function PetResearchRewardModel:getRewardStatus(petTemplateId, level)
	local petHandbookInfo = self.petHandbookMap[petTemplateId] or {}

	if Utils.isEmptyTable(petHandbookInfo) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("PetResearchRewardModel:petHandbookInfo is empty, templateId" .. petTemplateId)
		end

		return nil
	end

	return petHandbookInfo:getLevelRewardStatus(level)
end

function PetResearchRewardModel:getPetRewardInfo(petTemplateId)
	local petHandbookInfo = self.petHandbookMap[petTemplateId] or {}

	if Utils.isEmptyTable(petHandbookInfo) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("PetResearchRewardModel:petHandbookInfo is empty, templateId" .. petTemplateId)
		end

		return nil
	end

	self.level = petHandbookInfo.level or 0
	self.exp = petHandbookInfo.exp or 0

	local totalRewardData = PetResearchRewardData[petTemplateId] or {}
	local petRewardInfo = {}
	local min = Const.PET_RESEARCH_REWARD_LEVEL_MIN
	local max = Const.PET_RESEARCH_REWARD_LEVEL_MAX
	local needExpTable = PetResearchContentData[petTemplateId].needResearchPoint
	local needSumExpTable = PetResearchUtils.getSumNeededExpForUpgrade(petTemplateId)

	for lv = min, max do
		local rewardData = totalRewardData[lv] or {}
		local rewardDisplayData = rewardData.rewardDisplay or {}

		petRewardInfo[#petRewardInfo + 1] = {
			status = petHandbookInfo:getLevelRewardStatus(lv),
			needSumExp = needSumExpTable[lv],
			needExp = needExpTable[lv],
			sumExp = needSumExpTable[self.level] + self.exp,
			exp = self.exp,
			itemList = RewardUtils.refactorDisplayReward(rewardDisplayData)
		}
	end

	return petRewardInfo
end

return PetResearchRewardModel
