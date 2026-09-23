-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GameDungeonInfo\\Component\\GameDungeonInfoContentComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local LevelData = require("Data.level_data")
local AbilityParamData = require("Data.ability_param_data")
local PetData = require("Data.pet_data")
local Const = require("Common.Const.Const")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TargetConfigData = require("Data.gameplay_target_data")
local GameSceneRevert = require("Data.gameplaytarget_scene_revert_data")
local ElementAgainstData = require("Data.element_against_data")
local GameDungeonInfoContentComponent = Class.LightClass("GameDungeonInfoContentComponent", UIComponent)

function GameDungeonInfoContentComponent:onCtor(info)
	self.dungeonId = info and info.dungeonId
	self.showCurrencyId = info and info.showCurrencyId
end

function GameDungeonInfoContentComponent:registerObjects()
	function self.view.recommendEleList.luaRenderItem(button, index, data)
		self:renderRecommendElement(button, data)
	end

	function self.view.skillListUList.luaRenderItem(button, index, data)
		self:renderSkillLimit(button, data)
	end

	function self.view.petLimitListUList.luaRenderItem(button, index, data)
		self:renderPetLimit(button, data)
	end
end

function GameDungeonInfoContentComponent:initView()
	if self.dungeonId then
		self:refreshByDungeonId(self.dungeonId)
	end
end

function GameDungeonInfoContentComponent:refreshByDungeonId(dungeonId)
	local dungeonConfig = self:getDungeonConfig(dungeonId)

	self.dungeonId = dungeonId
	self.dungeonConfig = dungeonConfig
	self.canChallenge = true
	self.isSingle = false

	if not dungeonConfig then
		return nil, self.canChallenge, self.isSingle
	end

	self:refreshBaseInfo()
	self:refreshChallengeFeature()
	self:refreshPetLimit()
	self:refreshElementRecommend()
	self:refreshSkillRecommend()
	self:refreshChestInfo()
	self:refreshDungeonMode()
	self:refreshRewardInfo()

	return self.dungeonConfig, self.canChallenge, self.isSingle
end

function GameDungeonInfoContentComponent:getDungeonConfig(dungeonId)
	if not dungeonId then
		return nil
	end

	return LevelData[dungeonId]
end

function GameDungeonInfoContentComponent:refreshBaseInfo()
	LuaUIUtils.setTopCurrencyItem(self.view.currencyItemUButton, self.showCurrencyId)
	ClientTextUtils.setText(self.view.dungeonNameUText, pg.getLocalizationText(self.dungeonConfig.name))
	ClientTextUtils.setText(self.view.txtDetailsUScrollRect.content:GetComponent("UBaseText"), pg.getLocalizationText(self.dungeonConfig.describe))
	ClientTextUtils.setText(self.view.challengeUText, pg.getGameString("TEAM_START_CHALLENGE"))
	ClientTextUtils.setText(self.view.peopleNumUBaseText, self:getPeopleNumText())

	if self.dungeonConfig.pic then
		self.view.picUImage.url = self.dungeonConfig.pic
	end
end

function GameDungeonInfoContentComponent:getPeopleNumText()
	local playerNumMin = self.dungeonConfig.playerNumMin or 1
	local playerNumMax = self.dungeonConfig.playerNumMax or playerNumMin

	return playerNumMax == 1 and 1 or playerNumMin .. "~" .. playerNumMax
end

function GameDungeonInfoContentComponent:refreshChallengeFeature()
	if not self.view.textPanelUWidget then
		return
	end

	local title = self.dungeonConfig.buffName or self.dungeonConfig.challengeFeatureName or self.dungeonConfig.textPanelName
	local desc = self.dungeonConfig.buffDesc or self.dungeonConfig.challengeFeatureDesc or self.dungeonConfig.textPanelDesc
	local showFeature = title ~= nil or desc ~= nil

	self.view.textPanelUWidget:SetActive(showFeature)

	if not showFeature then
		return
	end

	ClientTextUtils.setText(self.view.textPanelTxtName, pg.getLocalizationText(title or ""))
	ClientTextUtils.setText(self.view.textPanelDesc, pg.getLocalizationText(desc or ""))
end

function GameDungeonInfoContentComponent:refreshPetLimit()
	local petTypeLimit = self.dungeonConfig.petTypeLimit or {}

	self.view.petLimitUWidget:SetActive(#petTypeLimit > 0)
	self.view.petLimitListUList:SetList(self:getPetLimitData(petTypeLimit))
end

function GameDungeonInfoContentComponent:getPetLimitData(petTypeLimit)
	local data = {}

	for index, petPrototypeId in ipairs(petTypeLimit) do
		local equiped = LuaUIUtils.checkCatched(petPrototypeId)

		self.canChallenge = self.canChallenge and equiped
		data[#data + 1] = {
			tIndex = 0,
			petPrototypeId = petPrototypeId,
			equiped = equiped
		}
	end

	return data
end

function GameDungeonInfoContentComponent:renderPetLimit(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local cfgData = PetData[data.petPrototypeId]

	if cfgData then
		iconUImage.url = LuaUIUtils.getPetIcon(cfgData.iconName, LuaUIUtils.PET_ICON, Const.PET_LABEL_MASK.NORMAL)
	end

	button:TryChangePage("state", data.equiped and 0 or 1)
end

function GameDungeonInfoContentComponent:refreshElementRecommend()
	local recommendElements = self:getRecommendElements()

	self.view.elementRecommendUWidget:SetActive(#recommendElements > 0)

	if self.view.txtNameUSDFText then
		ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getGameString("BOSS_CHALLENGE_TEXT2"))
	end

	if self.view.elementTxtDetails then
		self.view.elementTxtDetails:SetActive(false)
	end

	self.view.recommendEleList:SetList(self:getRecommendElementData(recommendElements))
end

function GameDungeonInfoContentComponent:getRecommendElements()
	local recommendElements = self.dungeonConfig.recommendType or self.dungeonConfig.elementRecmmend

	if recommendElements then
		return recommendElements
	end

	if not self.dungeonConfig.BossElement then
		return {}
	end

	local data = {}

	for elementName, info in pairs(ElementAgainstData) do
		if info[self.dungeonConfig.BossElement] and info[self.dungeonConfig.BossElement] > 1 then
			data[#data + 1] = elementName
		end
	end

	return data
end

function GameDungeonInfoContentComponent:getRecommendElementData(recommendElements)
	local data = {}

	for _, element in ipairs(recommendElements) do
		data[#data + 1] = {
			element = element
		}
	end

	return data
end

function GameDungeonInfoContentComponent:renderRecommendElement(button, data)
	LuaUIUtils.setElementButtonNew(button, data.element)
end

function GameDungeonInfoContentComponent:refreshSkillRecommend()
	local skillLimit = self.dungeonConfig.skillLimit or {}

	self.view.skillRecommendUWidget:SetActive(#skillLimit > 0)
	self.view.skillListUList:SetList(self:getSkillLimitData(skillLimit))
end

function GameDungeonInfoContentComponent:getSkillLimitData(skillLimit)
	local data = {}

	for _, abilityId in ipairs(skillLimit) do
		local equiped = LuaUIUtils.hasUnlockAbility(abilityId)

		self.canChallenge = self.canChallenge and equiped
		data[#data + 1] = {
			tIndex = 0,
			abilityId = abilityId,
			equiped = equiped
		}
	end

	return data
end

function GameDungeonInfoContentComponent:renderSkillLimit(button, data)
	local config = AbilityParamData[data.abilityId]

	if config then
		button:GetChild("IconSkill"):GetComponent("UImage").url = config.icon
	end

	button:TryChangePage("Equiped", data.equiped and 0 or 1)
end

function GameDungeonInfoContentComponent:refreshChestInfo()
	local dungeonCratesInfo = self:getDungeonCratesInfo()

	self.view.chestUWidget:SetActive(dungeonCratesInfo ~= nil)

	local chestInfo = dungeonCratesInfo or {}
	local chestCount = #chestInfo
	local finishCount = 0

	for _, chestId in ipairs(chestInfo) do
		if pg.me.interactRecord[chestId] then
			finishCount = finishCount + 1
		end
	end

	ClientTextUtils.setText(self.view.chestNumUBaseText, finishCount .. "/" .. chestCount)
end

function GameDungeonInfoContentComponent:getDungeonCratesInfo()
	local sceneTarget = GameSceneRevert[self.dungeonId]

	if sceneTarget ~= nil then
		local targetId = sceneTarget.targetId

		return TargetConfigData[targetId] and TargetConfigData[targetId].chest or nil
	end

	return nil
end

function GameDungeonInfoContentComponent:refreshDungeonMode()
	local playerNumMin = self.dungeonConfig.playerNumMin or 1

	if playerNumMin > 1 then
		self.view.widget:TryChangePage("DungType", 1)
	else
		self.isSingle = true

		self.view.widget:TryChangePage("DungType", 0)
	end
end

function GameDungeonInfoContentComponent:refreshRewardInfo()
	if self.view.rewardUWidget then
		self.view.rewardUWidget:SetActive(self:hasRewardInfo())
	end

	local rewardList = self.view.rewardUList or self.view.rewardList

	if not rewardList then
		return
	end

	if self.dungeonConfig.rewardId then
		LuaUIUtils.setRewardListByDropId(rewardList, self.dungeonConfig.rewardId)
	elseif self.dungeonConfig.rewardList and #self.dungeonConfig.rewardList > 0 then
		function rewardList.luaRenderItem(button, index, data)
			LuaUIUtils.renderRewards(button, index, data)
		end

		rewardList:SetList(self:getPreviewRewardData())
	else
		rewardList:SetList({})
	end

	ClientTextUtils.setText(self.view.rewardTitleUSDFText, pg.getGameString("DUNGEON_FIRST_SUCCESS_REWARD"))
end

function GameDungeonInfoContentComponent:hasRewardInfo()
	return self.dungeonConfig.rewardId ~= nil or self.dungeonConfig.rewardList ~= nil and #self.dungeonConfig.rewardList > 0
end

function GameDungeonInfoContentComponent:getPreviewRewardData()
	local data = {}

	for _, reward in ipairs(self.dungeonConfig.rewardList or EMPTY_TABLE) do
		if type(reward) == "table" then
			data[#data + 1] = {
				tIndex = 0,
				type = 0,
				id = reward.id or reward[1],
				num = reward.num or reward[2] or 1
			}
		else
			data[#data + 1] = {
				tIndex = 0,
				type = 0,
				num = 1,
				id = reward
			}
		end
	end

	return data
end

return GameDungeonInfoContentComponent
