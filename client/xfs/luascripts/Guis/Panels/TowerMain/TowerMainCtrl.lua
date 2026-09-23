-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerMain\\TowerMainCtrl.lua

local MessageName = require("Const.MessageName")
local DungeonConst = require("Common.Const.DungeonConst")
local Class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local RoguelikeData = require("Data.roguelike_data")
local LevelDataMap = require("Data.level_data_mapping")
local UIConst = require("Const.UIConst")
local HotkeyConst = require("Const.HotkeyConst")
local SysConfigData = require("Data.sys_config_data")
local UICtrl = require("Guis.UICtrl")
local TowerMainCtrl = Class.LightClass("TowerMainCtrl", UICtrl)
local RogueDifficultyData = require("Data.rogue_difficulty_data")
local ClientConst = require("Const.ClientConst")
local RedDotConst = require("Const.RedDotConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")

TowerMainCtrl.messages = {
	[MessageName.ROGUE_LAYER_CHANGE] = {
		"refreshUI",
		true
	}
}

function TowerMainCtrl:onCreate(info)
	self.levelId = info.levelId

	UICtrl.onCreate(self, info)

	self.isCloseing = false

	local difficultyKey = ClientConst.PrefKey.TowerCurSelectedDifficulty .. pg.me.uid

	self.selectedDifficulty = pg.global.prefsCacheUtils:getInt(difficultyKey, 1)

	self:initUI()
end

function TowerMainCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	self:bindHotKey(HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel, function()
		self:close()
	end)

	function self.view.btnShopUButton.luaClick()
		if LuaUIUtils.checkFuncTemporaryDisable(UIConst.UI_ID_SHOP_MAIN) then
			return
		end

		pg.global.ui:open(UIConst.UI_ID_SHOP_MAIN, {
			shopTags = {
				11
			}
		})
	end

	function self.view.btnGoinUButton.luaClick()
		self.isCloseing = true

		local hasChallenge = pg.me.curRogueLayer > 0

		if hasChallenge then
			pg.me:startRogue(self.curDungeonId)
		else
			pg.global.ui:open(UIConst.UI_ID_PVP_PET_SET, {
				isRogue = true,
				rogueCb = function(selectMap)
					local petIds = {}

					for _, petInfo in pairs(selectMap) do
						if petInfo.data.id then
							table.insert(petIds, petInfo.data.id)
						end
					end

					pg.me:setRoguePets(petIds)
					pg.me:startRogue(RogueDifficultyData[self.levelId].roguelikeIDStart)
				end
			})
		end
	end

	function self.view.btnResetUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_TOWER_SETTLEMENT)
	end
end

function TowerMainCtrl:initUI()
	local petResearchLevel, _ = pg.me.petHandbookMap:getCountryTotalLevel(1)

	self.petResearchLevel = petResearchLevel

	function self.view.difficultyUSelector.luaOptionClick(optionButton, optionData)
		self.selectedDifficulty = optionData.value

		if not self:checkLock(optionData) then
			local difficultyKey = ClientConst.PrefKey.TowerCurSelectedDifficulty .. pg.me.uid

			pg.global.prefsCacheUtils:setInt(difficultyKey, self.selectedDifficulty)

			local newDifficultyKey = optionData.value .. ClientConst.PrefKey.TowerDifficultyNew .. pg.me.uid

			pg.global.prefsCacheUtils:setInt(newDifficultyKey, 1)
		end

		self.curDungeonId = RogueDifficultyData[self.selectedDifficulty].roguelikeIDStart

		self.view.difficultyUSelector:ClosePopup()
		self:refreshSelected(optionData)
	end

	function self.view.difficultyUSelector.luaRenderPopup(selector, uList)
		function uList.luaRenderItem(button, index, data)
			local objectReference = button:GetComponent("ObjectReference")
			local starnumUBaseText = objectReference:GetRefValue("starNumUBaseText")
			local condition = RogueDifficultyData[data.value].difficultyCondition or 0

			ClientTextUtils.setText(starnumUBaseText, condition)

			if self:checkLock(data) then
				button:TryChangePage("LockState", 0)
			else
				local newDifficultyKey = data.value .. ClientConst.PrefKey.TowerDifficultyNew .. pg.me.uid
				local isNew = pg.global.prefsCacheUtils:getInt(newDifficultyKey, 0) == 0 and data.value ~= 1

				button:TryChangePage("LockState", isNew and 1 or 2)
			end

			button:TryChangePage("select", data.value == self.selectedDifficulty and 1 or 0)
		end

		pg.global.setRedDot(RedDotConst.RedDotPath.TOWER_DIFFICULTY, self.view.difficultyUSelector, false, RedDotConst.RedDotStyle.NEW)
	end

	function self.view.difficultyUSelector.luaOnSelectorClose()
		pg.global.setRedDot(RedDotConst.RedDotPath.TOWER_DIFFICULTY, self.view.difficultyUSelector, self:checkHasNew(), RedDotConst.RedDotStyle.NEW)
	end

	self:refreshUI()
end

function TowerMainCtrl:checkLock(data)
	local condition = RogueDifficultyData[data.value].difficultyCondition or 0

	return condition > self.petResearchLevel
end

function TowerMainCtrl:refreshSelected(data)
	local isLock = self:checkLock(data)

	self.view.lockBarUWidget:SetActive(isLock)

	if isLock then
		local star = RogueDifficultyData[data.value].difficultyCondition or 0

		ClientTextUtils.setText(self.view.selectedStarNumUBaseText, star)

		local tip = pg.getGameString("TOWER_ROGUE_OPEN_TIP")

		ClientTextUtils.setText(self.view.txtScoreUText, string.gsub(tip, "{starNum}", star))
	end

	self.view.btnGoinUButton.interactable = not isLock

	self.view.txtScoreUText:SetActive(isLock)
	self:refreshReward()
	pg.global.setRedDot(RedDotConst.RedDotPath.TOWER_DIFFICULTY, self.view.difficultyUSelector, self:checkHasNew(), RedDotConst.RedDotStyle.NEW)
end

function TowerMainCtrl:refreshUI()
	if self.isCloseing then
		return
	end

	local hasChallenge = pg.me.curRogueLayer > 0

	self.view.panelBtnUComponent:TryChangePage("State", hasChallenge and 1 or 0)

	if hasChallenge then
		self.curDungeonId = pg.me.curRogueLayer

		local levelCfg = RoguelikeData[pg.me.curRogueLayer]

		ClientTextUtils.setText(self.view.txtScoreUText, string.format("%s: %d%s", pg.getGameString("TOWER_ROGUE_LAST_ARRIVE"), levelCfg.floor, pg.getGameString("TOWER_ROGUE_FLOOR_NAME")))
		self.view.txtScoreUText:SetActive(true)
	else
		local optionData = {}

		for index, data in ipairs(RogueDifficultyData) do
			table.insert(optionData, {
				tIndex = 0,
				label = pg.getLocalizationText(data.difficultyName),
				value = index
			})
		end

		self.view.difficultyUSelector.options = optionData
		self.view.difficultyUSelector.selectedIndex = self.selectedDifficulty - 1
		self.curDungeonId = RogueDifficultyData[self.selectedDifficulty].roguelikeIDStart

		self.view.difficultyUSelector:RefreshOptions()
		self.view.difficultyUSelector:RefreshSelector()
		self:refreshSelected(optionData[self.selectedDifficulty])
	end

	self:refreshReward()
end

function TowerMainCtrl:refreshReward()
	local difficultyCfg = RogueDifficultyData[self.selectedDifficulty]
	local dropData = {}
	local hasGetFirst = pg.me.rogueSettlementCnt[difficultyCfg.roguelikeIDEnd] and pg.me.rogueSettlementCnt[difficultyCfg.roguelikeIDEnd] > 0

	if not hasGetFirst and difficultyCfg.firstClearReward then
		table.insert(dropData, {
			firstReward = true,
			dropId = difficultyCfg.firstClearReward
		})
	end

	if difficultyCfg.clearReward then
		table.insert(dropData, {
			dropId = difficultyCfg.clearReward
		})
	end

	LuaUIUtils.setRewardListByDropIds(self.view.rewardUList, dropData)
	self.view.rewardUWidget:InvokeCallback(CS.XGUI.EInvokeTime.User1)
end

function TowerMainCtrl:checkHasNew()
	for index, data in ipairs(RogueDifficultyData) do
		local condition = data.difficultyCondition or 0

		if condition <= self.petResearchLevel then
			local newDifficultyKey = index .. ClientConst.PrefKey.TowerDifficultyNew .. pg.me.uid
			local isNew = pg.global.prefsCacheUtils:getInt(newDifficultyKey, 0) == 0 and index ~= 1

			if isNew then
				return true
			end
		end
	end

	return false
end

function TowerMainCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function TowerMainCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function TowerMainCtrl:onShow()
	return
end

function TowerMainCtrl:onHide()
	return
end

return TowerMainCtrl
