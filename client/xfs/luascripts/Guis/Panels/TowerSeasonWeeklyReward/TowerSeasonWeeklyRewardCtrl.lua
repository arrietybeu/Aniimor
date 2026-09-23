-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerSeasonWeeklyReward\\TowerSeasonWeeklyRewardCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("TowerSeasonWeeklyRewardCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local RedDotConst = require("Const.RedDotConst")
local RogueUtils = require("Utils.RogueUtils")
local TowerSeasonWeeklyRewardCtrl = Class.LightClass("TowerSeasonWeeklyRewardCtrl", UICtrl)
local UIConst = require("Const.UIConst")

TowerSeasonWeeklyRewardCtrl.messages = {
	[MessageName.ROGUE_SEASON_WEEKLY_REWARD_UPDATE] = {
		"refreshReward",
		true
	}
}

function TowerSeasonWeeklyRewardCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:initUI()

	self.isClose = false
end

function TowerSeasonWeeklyRewardCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	function self.view.listTabUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local rootComponent = objectReference:GetRefValue("rootComponent")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		if index == 1 then
			rootComponent:TryChangePage("State", 2)
		elseif index == 2 then
			rootComponent:TryChangePage("State", 1)
		else
			rootComponent:TryChangePage("State", index)
		end

		rootComponent:TryChangePage("Selected", data.selected and 1 or 0)

		local levelInfo = data.levels and data.levels[1] and data.levels[1].info

		ClientTextUtils.setText(txtNameUSDFText, levelInfo and pg.getLocalizationText(levelInfo.levelName) or "")

		local tabPath = self:getTabRedDotPath(data)

		button:ClearRedDot()
		pg.global.setPreViewRedDot(tabPath, button, function()
			return self:canGetTabReward(data) and RedDotConst.RedDotStyle.REWARD or RedDotConst.RedDotStyle.NONE
		end)
	end

	function self.view.listTabUList.luaClick(button, data)
		for index, tabData in ipairs(self.levelData or EMPTY_TABLE) do
			if tabData == data then
				self:setSelectedTab(index)

				break
			end
		end
	end

	function self.view.listRewardUList.luaRenderItem(button, index, levelData)
		local objectReference = button:GetComponent("ObjectReference")
		local rootComponent = objectReference:GetRefValue("rootComponent")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local txtName1USDFText = objectReference:GetRefValue("txtName1USDFText")
		local listUList = objectReference:GetRefValue("listUList")
		local levelInfo = levelData.info
		local hasGot = self.model:isRewardReceived(levelData.levelId)
		local canGet = self:canGetLevelReward(levelData)
		local isUnlock = self.model:canGetReward(levelData.levelId) or hasGot

		rootComponent:TryChangePage("State", isUnlock and 0 or 1)
		rootComponent:TryChangePage("LevelNum", index)
		ClientTextUtils.setText(txtNameUSDFText, levelInfo and string.format(pg.getGameString("Rogue_Week_Difficult"), levelInfo.difficultyLabel + 1) or "")
		ClientTextUtils.setText(txtName1USDFText, levelInfo and pg.getLocalizationText(levelInfo.difficulty) or "")
		LuaUIUtils.setRewardListByDropIdWithoutClick(listUList, levelInfo.WeeklyRewardClient, 6, hasGot, nil, nil, nil, function(button, index, rewardData)
			self:setRewardItemRedDot(button, rewardData, levelData)
		end)

		function listUList.luaClick(button, data, navItem)
			if canGet then
				if navItem then
					return
				end

				self:onClickReward(levelData)
			else
				if data.tIndex == 1 then
					return
				end

				LuaUIUtils.onRewardItemClick(button, data, nil, navItem)
			end
		end
	end

	function self.view.btnReceiveUButton.luaClick()
		self:onClickAllReward()
	end
end

function TowerSeasonWeeklyRewardCtrl:initUI()
	self.levelData = self.model:getLevelData()

	self.view.listTabUList:SetList(self.levelData)
	self.view.btnReceiveUButton:ClearRedDot()
	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.TOWER_SEASON_WEEKLY_REWARD, self.view.btnReceiveUButton, function()
		return self:canGetAnyReward() and RedDotConst.RedDotStyle.REWARD or RedDotConst.RedDotStyle.NONE
	end)
	self:refreshButton()
end

function TowerSeasonWeeklyRewardCtrl:getTabRedDotPath(tabData)
	return string.format(RedDotConst.RedDotPath.TOWER_SEASON_WEEKLY_REWARD_TAB, tabData.elementType)
end

function TowerSeasonWeeklyRewardCtrl:getLevelRedDotPath(levelData)
	return string.format(RedDotConst.RedDotPath.TOWER_SEASON_WEEKLY_REWARD_ITEM, levelData.info.elementType, levelData.levelId)
end

function TowerSeasonWeeklyRewardCtrl:canGetLevelReward(levelData)
	return levelData ~= nil and RogueUtils.canGetSeasonWeeklyReward(levelData.levelId)
end

function TowerSeasonWeeklyRewardCtrl:canGetTabReward(tabData)
	return tabData ~= nil and RogueUtils.canGetSeasonWeeklyRewardByElement(tabData.elementType)
end

function TowerSeasonWeeklyRewardCtrl:canGetAnyReward()
	for _, tabData in ipairs(self.levelData or EMPTY_TABLE) do
		if self:canGetTabReward(tabData) then
			return true
		end
	end

	return false
end

function TowerSeasonWeeklyRewardCtrl:setRewardItemRedDot(button, rewardData, levelData)
	button:ClearRedDot()

	if rewardData.tIndex == 1 then
		return
	end

	pg.global.setRedDot(self:getLevelRedDotPath(levelData), button, self:canGetLevelReward(levelData), RedDotConst.RedDotStyle.REWARD)
end

function TowerSeasonWeeklyRewardCtrl:refreshRewardRedDot()
	for _, tabData in ipairs(self.levelData or EMPTY_TABLE) do
		pg.global.refreshRedDotState(self:getTabRedDotPath(tabData))
	end

	RogueUtils.refreshSeasonWeeklyRewardRedDot()
	self:refreshButton()
end

function TowerSeasonWeeklyRewardCtrl:refreshButton()
	local canGet = self:canGetAnyReward()

	self.view.btnReceiveUButton.interactable = canGet

	self.view.btnReceiveUButton:TryChangePage("button", canGet and 0 or 4)

	local key = canGet and "Rogue_Week_Get_Reward" or "Rogue_Week_Get_Reward_Tips"

	ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getGameString(key))
end

function TowerSeasonWeeklyRewardCtrl:setSelectedTab(tabIndex)
	local selectedTabData = self.levelData and self.levelData[tabIndex]

	if selectedTabData == nil then
		return false
	end

	for index, tabData in ipairs(self.levelData) do
		tabData.selected = index == tabIndex
	end

	self.selectedTabIndex = tabIndex

	self.view.listTabUList:RefreshList()
	self:refreshLevelList(selectedTabData)

	return true
end

function TowerSeasonWeeklyRewardCtrl:hasPassedAllLevels()
	local hasLevel = false

	for _, tabData in ipairs(self.levelData or EMPTY_TABLE) do
		for _, levelData in ipairs(tabData.levels or EMPTY_TABLE) do
			hasLevel = true

			if not self.model:canGetReward(levelData.levelId) and not self.model:isRewardReceived(levelData.levelId) then
				return false
			end
		end
	end

	return hasLevel
end

function TowerSeasonWeeklyRewardCtrl:refreshLevelList(tabData)
	self.curTabData = tabData

	self.view.listRewardUList:SetList(tabData.levels)

	local passAll = self:hasPassedAllLevels()

	ClientTextUtils.setText(self.view.textUSDFText, passAll and pg.getGameString("Rogue_Week_Reward_Pass_Tips") or pg.getGameString("Rogue_Week_Reward_Un_Pass_Tips"))
end

function TowerSeasonWeeklyRewardCtrl:refreshReward()
	self.view.listRewardUList:RefreshList()
	self:refreshRewardRedDot()
end

function TowerSeasonWeeklyRewardCtrl:onClickReward(levelData)
	local elementType = levelData and levelData.info and levelData.info.elementType

	if not RogueUtils.canGetSeasonWeeklyRewardByElement(elementType) then
		return
	end

	pg.me:getAllRogueSeasonWeeklyReward(elementType)
end

function TowerSeasonWeeklyRewardCtrl:onClickAllReward()
	local canGet = self:canGetAnyReward()

	if not canGet then
		pg.global.ui.tips:showTextTip(pg.getGameString("Rogue_Week_Get_Reward_Tips"))

		return
	end

	pg.me:getAllRogueSeasonWeeklyReward(0)
end

function TowerSeasonWeeklyRewardCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function TowerSeasonWeeklyRewardCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self.view.adaptationRectTransform.gameObject:SetActiveEx(ToBool(info and info.showBgMask))
	self:setSelectedTab(1)
end

function TowerSeasonWeeklyRewardCtrl:getWhiteList()
	return {
		[UIConst.UI_ID_ROG_LEVEL_SELECT] = true,
		[UIConst.UI_ID_EVENT] = true
	}
end

function TowerSeasonWeeklyRewardCtrl:onShow()
	return
end

function TowerSeasonWeeklyRewardCtrl:onHide()
	return
end

function TowerSeasonWeeklyRewardCtrl:closePanel()
	if self.isClose then
		return
	end

	self.isClose = true

	self:close()
end

return TowerSeasonWeeklyRewardCtrl
