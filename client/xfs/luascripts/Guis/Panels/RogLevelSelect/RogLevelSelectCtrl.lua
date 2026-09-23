-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RogLevelSelect\\RogLevelSelectCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local RogueUtils = require("Utils.RogueUtils")
local UIConst = require("Const.UIConst")
local HotkeyConst = require("Const.HotkeyConst")
local MessageName = require("Const.MessageName")
local RogueTalentData = require("Data.rogue_talent_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local RedDotConst = require("Const.RedDotConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local ClientConst = require("Const.ClientConst")
local SysConfigData = require("Data.sys_config_data")
local RoguelikeData = require("Data.roguelike_data")
local RogueTalentConditionData = require("Data.rogue_talent_condition_data")
local RogueDifficultyData = require("Data.rogue_difficulty_data")
local RogueWeekBossRewardData = require("Data.rogue_week_boss_reward_data")
local Const = require("Common.Const.Const")
local AudioConst = require("Const.AudioConst")
local RogueMultiLevelTalentData = require("Data.rogue_multi_level_talent_data")
local RogueTalentLevelData = require("Data.rogue_talent_level_data")
local RougeSeasonData = require("Data.rogue_season_data")
local ClientUtils = require("Utils.ClientUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local RogLevelSelectCtrl = Class.LightClass("RogLevelSelectCtrl", UICtrl)
local GAMEPAD_SCROLL_SPEED = 150

RogLevelSelectCtrl.messages = {
	[MessageName.ROGUE_LEVEL_CHANGE] = {
		"refreshList",
		true
	},
	[MessageName.ROGUE_LEVEL_NEW_CHANGE] = {
		"refreshList",
		true
	},
	[MessageName.CURRENCY_CHANGE] = {
		"refreshCurrency",
		true
	},
	[MessageName.ROGUE_TALENT_EXP_UPDATE] = {
		"refreshCurrency",
		true
	},
	[MessageName.ROGUE_SEASON_WEEKLY_REWARD_UPDATE] = {
		"refreshSeasonWeeklyRewardRedDot",
		true
	},
	[MessageName.ROGUE_SEASON_CHANGE] = {
		"onRogueSeasonChanged",
		true
	}
}
RogLevelSelectCtrl.TalentState = {
	UNLOCKABLE = 2,
	LOCKED = 1,
	UPGRADEABLE = 4,
	UNLOCKED = 0,
	LOCKED_BY_CURRENCY = 3
}

function RogLevelSelectCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	if pg.space:isRogueEnv() then
		pg.global.ui.tips:showTextTip(pg.getGameString("ROGUE_TIP_IN_ROGUE"))
		self:close()

		return
	end

	if not RogueUtils.checkInReason() then
		pg.global.ui.tips:showTextTip(pg.getGameString("NOTIFY_SERVER_SWITCH"))
		self:close()

		return
	end

	self.switchBtnRedDotPath = RedDotConst.RedDotPath.TOWER_LEVEL_ITEM .. ".switchLevel"
	self.selectedList = nil
	self.showCurrencyId = {
		5001,
		5000
	}
	self.resetCurrencyId = 5000

	pg.game.audio:playBgm(AudioConst.BGM_ROGUE_ENTER_UI, AudioConst.BgmPriority.RogueUI)
	self:refreshUI()
end

function RogLevelSelectCtrl:addListener()
	function self.view.btnClose.luaClick()
		self:close()
	end

	self:bindHotKey(HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel, function()
		self:close()
	end)

	function self.view.weeklyUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_TOWER_WEEKLY_REWARD)
	end

	function self.view.btnInfoUButton.luaClick()
		local isUp, _, _ = ClientActivityUtils.isRogueRewardUpWithRemainTimes()
		local _, tab = self.view.rootComponent:TryGetCurrentPage("Tab")

		if tab == 0 then
			local id = isUp and Const.COMMON_POPUP_TIP_ID.ROGUE_MAIN_UP or Const.COMMON_POPUP_TIP_ID.ROGUE_MAIN

			pg.global.ui.tips:openRogPopTips(id)
		else
			pg.global.ui.tips:openRogPopTips(Const.COMMON_POPUP_TIP_ID.ROGUE_TALENT_TREE)
		end
	end

	function self.view.btnActiveUButton.luaClick()
		local state = self:getTalentState(self.curSelectedTalentData)

		if state == RogLevelSelectCtrl.TalentState.UPGRADEABLE then
			if self.curSelectedTalentBtn then
				self.curSelectedTalentBtn:TryChangePage("Unlock", 0)
			end

			pg.me:upgradeTalent(self.curSelectedTalentData.id)
		else
			pg.me:unlockTalent(self.curSelectedTalentData.id)
		end

		if self.curSelectedTalentBtn then
			self.curSelectedTalentBtn:TryChangePage("Unlock", 2)
			table.insert(self.unlockTalentBtns, self.curSelectedTalentBtn)

			self.isUnlocking = true

			self:startTimer(function()
				self.isUnlocking = false
			end, 0.5)
		end

		pg.me:setRedDotRecord(Const.CLIENT_KEY.ROGUE, "talentSelectedId", self.curSelectedTalentData.id)
	end

	function self.view.btnNextTipUButton.luaRenderTooltip(button, panel)
		local nextLevel = self:getTalentNodeLevel(self.curSelectedTalentData.id) + 1
		local nextLevelInfo = self:getTalentLevelInfo(self.curSelectedTalentData.id, nextLevel)
		local objectReference = panel:GetComponent("ObjectReference")
		local txtTitle = objectReference:GetRefValue("txtTitle")
		local txtDesc = objectReference:GetRefValue("txtDesc")

		ClientTextUtils.setText(txtTitle, pg.getLocalizationText(nextLevelInfo.title))
		ClientTextUtils.setText(txtDesc, pg.getLocalizationText(nextLevelInfo.desc))
	end

	function self.view.btnNextTipUButton.luaTooltipPopup(button, isOpen)
		if isOpen then
			ClientTextUtils.setText(self.view.nextTipUBaseText, pg.getGameString("ROGUE_TALENT_BACK_TIP"))
			self.view.btnNextTipUButton:TryChangePage("button", 5)
		else
			ClientTextUtils.setText(self.view.nextTipUBaseText, pg.getGameString("ROGUE_TALENT_NEXT_LEVEL_TIP"))
			self.view.btnNextTipUButton:TryChangePage("button", 0)
		end
	end

	function self.view.btnResetUButton.luaClick()
		local tip = string.gsub(pg.getGameString("TALENT_TREE_RESET_TIP"), "{0}", LuaUIUtils.getItemCountConsumeShowText(self.resetCurrencyId, SysConfigData.RogueTalentResetCost))

		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), tip, function()
			local itemCount = ClientUtils.getItemCountById(self.resetCurrencyId, true)

			if itemCount < SysConfigData.RogueTalentResetCost then
				pg.global.ui.tips:showTextTip(pg.getGameString("APPEARANCE_PAY_FAIL"))

				return
			end

			pg.me:resetRogueTalent()

			self.unlockTalentBtns = {}

			pg.me:setRedDotRecord(Const.CLIENT_KEY.ROGUE, "talentSelectedId", 1)
		end, nil)
	end

	function self.view.rewardsUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_TOWER_SEASON_WEEKLY_REWARD)
	end

	function self.view.countDownUCountDown.luaFinished()
		self:initSeasonWeeklyReward()
	end
end

function RogLevelSelectCtrl:refreshUI()
	ClientTextUtils.setText(self.view.shopUBaseText, pg.getGameString("ROGUE_TRAINING_SHOP"))
	self:initTitleTab()
	self:initRogueRewardUp()
	self:initLevelSelect()
	self:initSeasonWeeklyReward()
end

function RogLevelSelectCtrl:initSeasonWeeklyReward()
	local season = RogueUtils.getCurrentSeasonStage(pg.me.rogueSeasonId)

	LuaUIUtils.setCountDownTime(self.view.seasonUCountDown, season.endDayTime, UIConst.TimeType.Short)
	LuaUIUtils.setCountDownTime(self.view.countDownUCountDown, RogueUtils.getWeeklyTime() + 1, UIConst.TimeType.Short)
	self.view.rewardsUButton:ClearRedDot()
	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.TOWER_SEASON_WEEKLY_REWARD, self.view.rewardsUButton, function()
		return RogueUtils.getRedDotSeasonWeeklyRewardState()
	end)
end

function RogLevelSelectCtrl:refreshSeasonWeeklyRewardRedDot()
	RogueUtils.refreshSeasonWeeklyRewardRedDot()
end

function RogLevelSelectCtrl:onRogueSeasonChanged()
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_TOWER_SELECT_STYLE) then
		pg.global.ui:closeImmediately(UIConst.UI_ID_TOWER_SELECT_STYLE)
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_TOWER_LEVEL_DETAIL) then
		pg.global.ui:closeImmediately(UIConst.UI_ID_TOWER_LEVEL_DETAIL)
	end

	if pg.me.rogueSeasonId == nil or pg.me.rogueSeasonId == 0 then
		self:close()

		return
	end

	self:refreshUI()
end

RogLevelSelectCtrl.TitleTab = {
	Level = 0,
	Talent = 1
}

function RogLevelSelectCtrl:initTitleTab()
	local titleData = {
		{
			selected = true,
			tIndex = 0,
			label = pg.getGameString("ROGUE_LEVEL_LIST"),
			tab = self.TitleTab.Level
		},
		{
			tIndex = 2,
			label = pg.getGameString("ROGUE_TALENT"),
			tab = self.TitleTab.Talent
		}
	}

	function self.view.titleTabUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderTitleTab(button, index, data)

		if data.tab == self.TitleTab.Talent then
			self.talentTabUButton = button
		end
	end

	function self.view.titleTabUList.luaClick(button, data)
		self.view.rootComponent:TryChangePage("Tab", data.tab)

		if data.tab == self.TitleTab.Talent then
			self:refreshTalentRedDot(false)
		end

		for _, button in ipairs(self.unlockTalentBtns) do
			button:TryChangePage("Unlock", 0)
		end

		self.unlockTalentBtns = {}

		self:refreshConsoleBarState()
	end

	self.view.titleTabUList:SetList(titleData)
	self:refreshConsoleBarState()
end

function RogLevelSelectCtrl:initWeeklyReward()
	LuaUIUtils.setCountDownTime(self.view.cycleUCountDown, RogueUtils.getWeeklyTime(), UIConst.TimeType.Short)

	local killCount = pg.me.rogueWeeklyBossKillCount or 0
	local allCount = #RogueWeekBossRewardData

	killCount = math.min(killCount, allCount)

	local isFull = allCount <= killCount

	self.view.weeklyUButton:TryChangePage("status", isFull and 1 or 0)

	local killText = isFull and string.format("<color=#e19c17><b>%d</b></color>/%d", killCount, allCount) or string.format("<b>%d</b>/%d", killCount, allCount)

	ClientTextUtils.setText(self.view.progressUBaseText, killText)
	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.TOWER_WEEKLY_REWARD, self.view.weeklyUButton, function()
		return RogueUtils.getRedDotWeeklyState()
	end)
end

function RogLevelSelectCtrl:initDailyReward()
	self.view.dailyRewardUButton.visualInteractable = pg.me.rogueHarvestUnlocked == 1

	self.view.dailyRewardUButton:TryChangePage("button", pg.me.rogueHarvestUnlocked == 1 and 0 or 4)

	function self.view.dailyRewardUButton.luaClick()
		if pg.me.rogueHarvestUnlocked == 1 then
			pg.global.ui:open(UIConst.UI_ID_TOWER_DAILY_REWARD)
		else
			pg.global.ui.tips:showTextTip(pg.getGameString("ROGUE_DAILY_REWARD_LOCK_TIP"))
		end
	end

	ClientTextUtils.setText(self.view.dailyRewardUBaseText, pg.getGameString("ROGUE_DAILY_REWARD_TITLE"))
	ClientTextUtils.setText(self.view.dailyReward1UBaseText, pg.getGameString("ROGUE_DAILY_REWARD_DESC"))
	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.TOWER_DAILY_REWARD, self.view.dailyRewardUButton, function()
		return RogueUtils.getRedDotDailyState()
	end)
end

function RogLevelSelectCtrl:refreshDailyReward()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.TOWER_DAILY_REWARD)
end

function RogLevelSelectCtrl:_getCurrentScrollUList()
	local success, tab = self.view.rootComponent:TryGetCurrentPage("Tab")

	if success and tab == self.TitleTab.Talent then
		return self.view.talentUList
	end

	if self.showList then
		return self.showList
	end

	return self.isHighLevel and self.view.highLevelUList or self.view.normalLevelUList
end

function RogLevelSelectCtrl:_bindGamepadScroll(uList, bindName)
	if not uList or IsNil(uList.gameObject) then
		return
	end

	local bind = KeyBindingPro.GetOrAddKeyBindingByName(uList.gameObject, bindName)

	bind.actionPath = "Raw/GamepadRightStickMove"
	bind.isVirtual = true
	bind.priority = -1

	function bind.luaTrigger(inputInfo)
		self._scrollGamepadDelta = inputInfo.valueVec2 * GAMEPAD_SCROLL_SPEED
		self._scrollGamepadDelta.y = 0

		if inputInfo.phase == "Performed" then
			self._scrollTargetList = uList

			if self._scrollTimer == nil then
				self._scrollTimer = self:startTimer(function()
					local targetList = self._scrollTargetList

					if targetList == nil or IsNil(targetList.gameObject) then
						if self._scrollTimer then
							self:killTimer(self._scrollTimer)

							self._scrollTimer = nil
						end

						return
					end

					if targetList ~= self:_getCurrentScrollUList() then
						return
					end

					local cur = targetList.currentScrollPosition

					targetList:GoToPos(cur - self._scrollGamepadDelta, false)
				end, 0, true)
			end
		elseif inputInfo.phase == "Canceled" and self._scrollTimer then
			self:killTimer(self._scrollTimer)

			self._scrollTimer = nil
		end
	end
end

function RogLevelSelectCtrl:checkHighLevelLock()
	return RogueUtils.checkLevelUnlock(self.highLevelData[1].levelIds[1])
end

function RogLevelSelectCtrl:initRogueRewardUp()
	local isUp, isNew, activityId = ClientActivityUtils.isRogueRewardUpWithRemainTimes()

	if isUp then
		if isNew then
			pg.global.ui.tips:showDropHint("MOCKBATTLE_UP_TIP", self.view.iconUp3UContainer.position)

			local key = ClientConst.PrefKey.EventIconUpNew .. activityId .. pg.me.uid

			pg.global.prefsCacheUtils:setBool(key, false)
			self.view.iconUp3UContainer:SetActive(false)
			self:startTimer(function()
				self.view.iconUp3UContainer:SetActive(true)
			end, 3.33)
		else
			self.view.iconUp3UContainer:SetActive(true)
		end
	else
		self.view.iconUp3UContainer:SetActive(false)
	end
end

function RogLevelSelectCtrl:initLevelSelect()
	local normalLevelData, highLevelData, lastSelectLevelId = self:getLevelData()

	self.normalLevelData = normalLevelData

	function self.view.normalLevelUList.luaRenderItem(button, index, data)
		RogueUtils.renderLevelItem(button, index, data)
	end

	function self.listClickHandler(button, data)
		self.showList:GoToItem(button)
	end

	self.view.normalLevelUList.luaClick = self.listClickHandler

	self.view.normalLevelUList:SetList(normalLevelData)

	if not self.scrollEndCallback then
		function self.scrollEndCallback()
			local success, button = self.showList:TryGetSnappingItem()

			if success then
				local index = self.showList:GetChildIndex(button)

				if index ~= -1 then
					self.showList:SelectItem(index)
				end
			end
		end

		self.view.normalLevelUList:RegisterToScrollEndEvent(self.scrollEndCallback)
	end

	self.isHighLevel = false

	if self.isHighLevel then
		-- block empty
	else
		self.showList = self.view.normalLevelUList

		self:startTimer(function()
			self.view.normalLevelUList:GoToIndex(math.max(0, self.view.normalLevelUList.selectedIndex))
		end, 0.2)
		self.view.highLevelUList:GoToIndex(0)
		self.view.highLevelUList:SelectItem(0)
	end
end

function RogLevelSelectCtrl:getLevelData()
	local normalLevelData = {}
	local levelData = normalLevelData
	local levelTypeList = {}
	local lastSelectLevelId = 1
	local selectedLevelId = RogueUtils.getSelectedRogueLevel()

	if pg.me.curRogueLevel > 0 then
		lastSelectLevelId = pg.me.curRogueLevel
	elseif selectedLevelId > 0 then
		lastSelectLevelId = selectedLevelId
	elseif pg.me.lastRogueLevel and pg.me.lastRogueLevel > 0 then
		lastSelectLevelId = pg.me.lastRogueLevel
	end

	for index, levelInfo in ipairs(RogueDifficultyData) do
		local key = levelInfo.elementType

		if levelTypeList[key] == nil then
			levelTypeList[key] = #levelData + 1

			table.insert(levelData, {
				selected = false,
				levelIds = {},
				infos = {}
			})
		end

		table.insert(levelData[levelTypeList[key]].levelIds, index)
		table.insert(levelData[levelTypeList[key]].infos, levelInfo)

		levelData[levelTypeList[key]].selected = levelData[levelTypeList[key]].selected or index == lastSelectLevelId
	end

	return normalLevelData, nil, lastSelectLevelId
end

function RogLevelSelectCtrl:refreshList()
	self.view.normalLevelUList:RefreshList()
	self.view.highLevelUList:RefreshList()
	self:refreshSwitchBtnRedDot()
	self.view.btnResetUButton:SetActive(pg.me.rogueTalentLevelUnlock[1] and RogueUtils.getCurRogueLevel() == 0)
end

function RogLevelSelectCtrl:checkLevelListHasNewRedDot(levelListData)
	for _, levelGroup in ipairs(levelListData or EMPTY_TABLE) do
		for _, levelId in ipairs(levelGroup.levelIds or EMPTY_TABLE) do
			if RogueUtils.checkLevelIsNew(levelId) then
				return true
			end
		end
	end

	return false
end

function RogLevelSelectCtrl:refreshSwitchBtnRedDot()
	local showSwitchRedDot = false

	if self.isHighLevel then
		showSwitchRedDot = self:checkLevelListHasNewRedDot(self.normalLevelData)
	else
		showSwitchRedDot = self:checkLevelListHasNewRedDot(self.highLevelData)
	end

	pg.global.setRedDot(self.switchBtnRedDotPath, self.view.btnSwitchUButton, showSwitchRedDot, RedDotConst.RedDotStyle.NEW)
end

function RogLevelSelectCtrl:setLineState(lineButton, node, preNode, extraLine)
	local unlock = false

	if node and node.id and pg.me.rogueTalentLevelUnlock[node.id] then
		unlock = true
	end

	if preNode and preNode.id and not pg.me.rogueTalentLevelUnlock[preNode.id] then
		unlock = false
	end

	lineButton:TryChangePage("Unlock", unlock and 0 or 1)

	if extraLine and unlock then
		extraLine:TryChangePage("Unlock", 0)
	end
end

function RogLevelSelectCtrl:initTalentPanel()
	self.hasInitTalent = false
	self.unlockTalentBtns = {}
	self.talentId2Btn = {}
	self.curSelectedTalentBtn = nil
	self.selectedId = pg.me:getRedDotRecord(Const.CLIENT_KEY.ROGUE, "talentSelectedId", 1)
	self.needGoToIndex = 0

	function self.view.talentUList.luaRenderItem(button, index, data)
		local list = button:GetChild("List"):GetComponent("UList")

		function list.luaRenderItem(button2, index2, data2)
			button2:SetActiveFastest(not data2.empty)

			if data2.tIndex == 2 or data2.tIndex == 3 then
				button2:TryChangePage("Type", data2.subType)

				local objectReference = button2:GetComponent("ObjectReference")
				local line1UButton = objectReference:GetRefValue("line1UButton")
				local line2UButton = objectReference:GetRefValue("line2UButton")
				local line3UButton = objectReference:GetRefValue("line3UButton")
				local lineM23UButton = objectReference:GetRefValue("lineM23UButton")
				local linkNodes = data2.linkNode or {}
				local preLinkNodes = data2.preLinkNode or {}
				local forceCheckNode = data2.forceCheckNode

				lineM23UButton:TryChangePage("Unlock", 1)

				if data2.subType == 2 or data2.subType == 3 then
					self:setLineState(line1UButton, forceCheckNode or linkNodes[1], preLinkNodes[1], lineM23UButton)
					self:setLineState(line2UButton, forceCheckNode or linkNodes[2], preLinkNodes[2], lineM23UButton)
					self:setLineState(line3UButton, forceCheckNode or linkNodes[3], preLinkNodes[3], lineM23UButton)
				elseif data2.subType == 1 or data2.subType == 4 then
					self:setLineState(line1UButton, forceCheckNode or linkNodes[1], preLinkNodes[1], lineM23UButton)
					self:setLineState(line3UButton, forceCheckNode or linkNodes[3], preLinkNodes[3], lineM23UButton)
				else
					local node = linkNodes[index2 + 1] or linkNodes[1]

					self:setLineState(line2UButton, node, lineM23UButton)
				end
			elseif data2.tIndex == 0 or data2.tIndex == 1 then
				if self.selectedId == data2.id and not self.hasInitTalent then
					self.selectedList = list
					self.curSelectedTalentBtn = button2
					self.hasInitTalent = true
				end

				if data2.selected then
					button2:InvokeCallback(CS.XGUI.EInvokeTime.User1)

					self.selectedList = list
					self.curSelectedTalentData = data2
					self.curSelectedTalentBtn = button2
				end

				self.talentId2Btn[data2.id] = {
					button = button2,
					index = index,
					data = data2
				}

				local objectReference = button2:GetComponent("ObjectReference")
				local iconUImage = objectReference:GetRefValue("iconUImage")
				local layoutTagUWidget = objectReference:GetRefValue("layoutTagUWidget")
				local conditionUBaseText = objectReference:GetRefValue("conditionUBaseText")
				local panelLevelUWidget = objectReference:GetRefValue("panelLevelUWidget")
				local levelUBaseText = objectReference:GetRefValue("levelUBaseText")
				local talentInfo = data2.talentInfo or {}
				local needRefreshUnlock = true

				if layoutTagUWidget and conditionUBaseText then
					local isActive = self:checkTalentNodeActive(data2)

					layoutTagUWidget:SetActiveFastest(not isActive)

					if not isActive then
						ClientTextUtils.setText(conditionUBaseText, pg.getLocalizationText(talentInfo.conditionText or ""))
					end

					if self:checkNeedPlayActiveFx(data2) then
						pg.me:setRedDotRecord(Const.CLIENT_KEY.ROGUE, RedDotConst.RedDotPath.TOWER_TALENT_LEVEL .. data2.id, true)
						button2:TryChangePage("Unlock", 3)
						self:startTimer(function()
							button2:TryChangePage("Unlock", pg.me.rogueTalentLevelUnlock[data2.id] and 0 or 1)
						end, 0.75)

						needRefreshUnlock = false

						if self.needGoToIndex < index then
							self.needGoToIndex = index
						end
					end
				end

				iconUImage.url = talentInfo.icon or ""

				if panelLevelUWidget and levelUBaseText then
					local maxLevel = talentInfo.maxLv or 1
					local isActive = pg.me.rogueTalentLevelUnlock[data2.id]
					local showLevel = isActive and maxLevel > 1

					panelLevelUWidget:SetActive(showLevel)

					if showLevel then
						local curLevel = self:getTalentNodeLevel(data2.id)

						ClientTextUtils.setText(levelUBaseText, curLevel .. "/" .. maxLevel)
					end
				end

				local _, pageIndex = button2:TryGetCurrentPage("Unlock")

				needRefreshUnlock = needRefreshUnlock and (pageIndex ~= 2 or not self.isUnlocking)

				if pg.me.rogueTalentLevelUnlock[data2.id] then
					if needRefreshUnlock then
						button2:TryChangePage("Unlock", 0)
					end
				else
					button2:TryChangePage("Unlock", 1)
				end

				local canUnlock = not pg.me.rogueTalentLevelUnlock[data2.id] and self:canUnlockTalent(talentInfo)
				local canUpgrade = self:canUpgradeTalent(data2.id, self:getTalentNodeLevel(data2.id))
				local showRedDot = canUnlock or canUpgrade

				pg.global.setRedDot(RedDotConst.RedDotPath.TOWER_TALENT_LEVEL .. data2.id, button2, showRedDot, RedDotConst.RedDotStyle.UP_SIGN)

				function button2.luaClick()
					if self.selectedList then
						self.selectedList:DeselectAll()
					end

					if self.curSelectedTalentData then
						self.curSelectedTalentData.selected = false
					end

					if self.curSelectedTalentBtn then
						self.curSelectedTalentBtn:TryChangePage("button", 0)
					end

					self.selectedList = list
					self.curSelectedTalentData = data2
					self.curSelectedTalentBtn = button2

					self:refreshTalentInfo(data2)
				end
			end
		end

		list:SetList(data)
	end

	function self.view.talentUList.luaDynamicRenderItem(button, index, data)
		local width = 248

		if data[1] and data[1].width then
			width = data[1].width
		end

		button:SetSizeDelta(Vector2(width, button.sizeDelta.y))
	end

	self.hasInitRefresh = false

	function self.view.talentUList.luaVirtualListRefreshCb()
		self.view.talentUList:SetTopSortingOrder(self.topIndexs)

		if self.focusTalentId then
			return
		end

		self:goToSelectedTalent()

		if self.curSelectedTalentBtn and not self.hasInitRefresh then
			self.hasInitRefresh = true

			self.curSelectedTalentBtn:InvokeCallback(CS.XGUI.EInvokeTime.User1)
		end
	end

	local data, topIndexs = self:getTalentData2()

	self.topIndexs = topIndexs

	self.view.talentUList:SetViewExtend(Vector2(200, 0))
	self.view.talentUList:SetList(data)
	self:refreshTalentRedDot()
	self:initCurrency()
	self.view.btnResetUButton:SetActive(pg.me.rogueTalentLevelUnlock[1] and RogueUtils.getCurRogueLevel() == 0)
end

function RogLevelSelectCtrl:goToSelectedTalent()
	if self.needGoToIndex >= 0 then
		local adjustIndex = math.max(0, self.needGoToIndex - 5)

		self.view.talentUList:GoToIndex(adjustIndex, true)

		self.needGoToIndex = -1
	end
end

function RogLevelSelectCtrl:refreshTalentRedDot(forceOverrideShow)
	if self.talentTabUButton then
		if forceOverrideShow ~= nil then
			pg.global.setRedDot(RedDotConst.RedDotPath.TOWER_TALENT_LEVEL, self.talentTabUButton, forceOverrideShow, RedDotConst.RedDotStyle.UP_SIGN)
		else
			pg.global.setRedDot(RedDotConst.RedDotPath.TOWER_TALENT_LEVEL, self.talentTabUButton, self:checkShowTalentRedDot(), RedDotConst.RedDotStyle.UP_SIGN)
		end
	end
end

function RogLevelSelectCtrl:checkShowTalentRedDot()
	local needCheck = pg.me:getRedDotRecord(Const.CLIENT_KEY.ROGUE, RedDotConst.RedDotPath.TOWER_TALENT_LEVEL .. "needCheck", 1)

	if needCheck ~= 1 then
		return false
	end

	pg.me:setRedDotRecord(Const.CLIENT_KEY.ROGUE, RedDotConst.RedDotPath.TOWER_TALENT_LEVEL .. "needCheck", 0)

	for id, talentInfo in ipairs(RogueTalentData) do
		local treeInfo = talentInfo.talentTreeNode

		if treeInfo and not pg.me.rogueTalentLevelUnlock[id] and self:canUnlockTalent(talentInfo) then
			return true
		end
	end

	return false
end

function RogLevelSelectCtrl:initCurrency()
	LuaUIUtils.setTopCurrencyItemList(self.view.currencyUList, nil, self.showCurrencyId)
end

function RogLevelSelectCtrl:refreshTalent()
	self.view.talentUList:RefreshList()
	self.view.currencyUList:RefreshList()
	self:refreshTalentInfo(self.curSelectedTalentData)
	self.view.btnResetUButton:SetActive(pg.me.rogueTalentLevelUnlock[1] and RogueUtils.getCurRogueLevel() == 0)
end

function RogLevelSelectCtrl:refreshCurrency()
	self.view.currencyUList:RefreshList()
end

function RogLevelSelectCtrl:refreshTalentInfo(data)
	local talentInfo = data.talentInfo

	if not talentInfo then
		return
	end

	local state = self:getTalentState(data)

	if state == RogLevelSelectCtrl.TalentState.LOCKED and self:checkUnlockCondition(data.talentInfo) then
		state = RogLevelSelectCtrl.TalentState.LOCKED_BY_CURRENCY
	end

	self.view.talentInfoUComponent:TryChangePage("State", state)

	local btnText = state == RogLevelSelectCtrl.TalentState.UPGRADEABLE and pg.getGameString("ROGUE_TALENT_UPGRADE") or pg.getGameString("ROGUE_TALENT_UNLOCK")

	ClientTextUtils.setText(self.view.btnActiveUText, btnText)

	local curNodeLevel = self:getTalentNodeLevel(data.id)
	local curLevelInfo = self:getTalentLevelInfo(data.id, curNodeLevel)
	local nextLevelInfo = self:getTalentLevelInfo(data.id, curNodeLevel + 1)
	local maxLevel = talentInfo.maxLv or 1
	local hasNextLevel = state == RogLevelSelectCtrl.TalentState.UPGRADEABLE and curNodeLevel < maxLevel

	if self.view.btnNextTipUButton then
		self.view.btnNextTipUButton:SetActive(hasNextLevel)
	end

	ClientTextUtils.setText(self.view.nextTipUBaseText, pg.getGameString("ROGUE_TALENT_NEXT_LEVEL_TIP"))

	self.view.btnActiveUButton.interactable = state == RogLevelSelectCtrl.TalentState.UNLOCKABLE or state == RogLevelSelectCtrl.TalentState.UPGRADEABLE and self:canUpgradeTalent(data.id, curNodeLevel)
	self.view.talentIconUImage.url = talentInfo.icon or ""

	local title = curLevelInfo and pg.getLocalizationText(curLevelInfo.title) or pg.getLocalizationText(talentInfo.title) or ""

	ClientTextUtils.setText(self.view.talentNameUBaseText, title)

	local desc = curLevelInfo and pg.getLocalizationText(curLevelInfo.desc) or pg.getLocalizationText(talentInfo.desc) or ""

	ClientTextUtils.setText(self.view.talentDescUBaseText, desc)

	self.view.talentDescUBaseText.enabledHyperlink = true

	function self.view.talentDescUBaseText.luaOnHyperlinkClick(action, content, contentRect)
		LuaUIUtils.clickHyperText(action, content, contentRect)
	end

	local ownerExpCount = pg.me.rogueTalentExp or 0
	local lvExp = nextLevelInfo and nextLevelInfo.lvExp or talentInfo.lvExp or 0
	local ownerExpText = lvExp <= ownerExpCount and ownerExpCount or string.format("<style=Item_Lack>%d</style>", ownerExpCount)

	self.view.talentOwnUBaseText.text = ownerExpText

	ClientTextUtils.setText(self.view.talentConsumeUBaseText, "/", lvExp)

	local conditionData = {}

	for index, value in ipairs(talentInfo.condition or EMPTY_TABLE) do
		local cfg = RogueTalentConditionData[value]

		if cfg then
			table.insert(conditionData, {
				label = pg.getLocalizationText(cfg.displayDesc) or ""
			})
		end
	end

	self.view.talentTipsUList:SetList(conditionData)
end

function RogLevelSelectCtrl:refreshConsoleBarState()
	if not self.view then
		return
	end

	local _, tab = self.view.rootComponent:TryGetCurrentPage("Tab")

	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ConsolrBar_RogLevel_IsInLevel", tab == self.TitleTab.Level)
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ConsolrBar_RogLevel_IsInTalent", tab == self.TitleTab.Talent)
	end
end

function RogLevelSelectCtrl:getTalentState(data)
	if pg.me.rogueTalentLevelUnlock[data.id] then
		local talentInfo = data.talentInfo
		local maxLevel = talentInfo and talentInfo.maxLv or 1

		if maxLevel > 1 then
			local curLevel = self:getTalentNodeLevel(data.id)

			if curLevel < maxLevel then
				return RogLevelSelectCtrl.TalentState.UPGRADEABLE
			end
		end

		return RogLevelSelectCtrl.TalentState.UNLOCKED
	elseif self:canUnlockTalent(data.talentInfo) then
		return RogLevelSelectCtrl.TalentState.UNLOCKABLE
	else
		return RogLevelSelectCtrl.TalentState.LOCKED
	end
end

function RogLevelSelectCtrl:getTalentNodeLevel(id)
	if not pg.me.rogueTalentLevelUnlock[id] then
		return 0
	end

	local levelMap = pg.me.rogueTalentNodeLvMap

	return levelMap and levelMap[id] or 1
end

function RogLevelSelectCtrl:getTalentLevelInfo(id, level)
	local talentLevelInfo = RogueTalentLevelData[id]

	if not talentLevelInfo then
		return
	end

	local levelId = talentLevelInfo[level]

	if not levelId then
		return
	end

	return RogueMultiLevelTalentData[levelId]
end

function RogLevelSelectCtrl:canUpgradeTalent(talentId, curLevel)
	local nextLevelInfo = self:getTalentLevelInfo(talentId, curLevel + 1)

	if not nextLevelInfo then
		return false
	end

	if pg.me.rogueTalentExp < (nextLevelInfo.lvExp or 0) then
		return false
	end

	return true
end

function RogLevelSelectCtrl:canUnlockTalent(talentInfo)
	if not talentInfo then
		return false
	end

	if pg.me.rogueTalentExp < talentInfo.lvExp then
		return false
	end

	return self:checkUnlockCondition(talentInfo)
end

function RogLevelSelectCtrl:checkUnlockCondition(talentInfo)
	if not talentInfo then
		return false
	end

	for index, value in ipairs(talentInfo.itemCondition or EMPTY_TABLE) do
		if pg.me:getItemCountById(value[1]) < value[2] then
			return false
		end
	end

	local preNode = talentInfo.preNode or {}

	for _, preId in ipairs(preNode) do
		if pg.me.rogueTalentLevelUnlock[preId] then
			return true
		end
	end

	return #preNode == 0
end

function RogLevelSelectCtrl:checkNeedPlayActiveFx(data)
	local talentInfo = data.talentInfo

	if not talentInfo or not talentInfo.itemCondition then
		return false
	end

	local isActive = self:checkTalentNodeActive(data)

	if not isActive then
		return false
	end

	local hasActive = pg.me:getRedDotRecord(Const.CLIENT_KEY.ROGUE, RedDotConst.RedDotPath.TOWER_TALENT_LEVEL .. data.id, false)

	return not hasActive
end

function RogLevelSelectCtrl:checkTalentNodeActive(data)
	local talentInfo = data.talentInfo

	if not talentInfo or talentInfo.nodeType ~= 1 then
		return false
	end

	for index, value in ipairs(talentInfo.itemCondition or EMPTY_TABLE) do
		if pg.me:getItemCountById(value[1]) < value[2] then
			return false
		end
	end

	return true
end

function RogLevelSelectCtrl:getTalentData2()
	local data = {}

	for id, talentInfo in ipairs(RogueTalentData) do
		local treeInfo = talentInfo.talentTreeNode

		if treeInfo then
			if data[treeInfo[1]] == nil then
				data[treeInfo[1]] = {
					{
						empty = true,
						subType = 0,
						tIndex = 2
					},
					{
						empty = true,
						subType = 0,
						tIndex = 2
					},
					{
						empty = true,
						subType = 0,
						tIndex = 2
					}
				}
			end

			data[treeInfo[1]][treeInfo[2]] = {
				id = id,
				talentInfo = talentInfo,
				tIndex = talentInfo.nodeType == 1 and 0 or 1,
				selected = self.selectedId == id
			}

			if self.selectedId == id then
				self.curSelectedTalentData = data[treeInfo[1]][treeInfo[2]]

				self:refreshTalentInfo(data[treeInfo[1]][treeInfo[2]])

				data[treeInfo[1]].selected = true
			end
		end
	end

	for index, value in ipairs(data) do
		local realCount, realData = self:getRealNodeInfo(value)

		if realCount == 1 then
			local selected = data[index].selected

			data[index] = realData
			data[index].selected = selected
		end
	end

	local linkDatas = {}

	for i = #data - 1, 1, -1 do
		local nextNode = data[i + 1]
		local curNode = data[i]
		local nextCount = #nextNode
		local curCount = #curNode

		if nextCount == 1 and curCount == 1 then
			linkDatas[i] = {
				{
					subType = 0,
					tIndex = 2,
					linkNode = nextNode
				}
			}
		elseif nextCount == 1 and curCount == 3 then
			local width = nextNode[1].talentInfo.nodeType == 1 and 528 or 468
			local subType
			local preNodeCount = #nextNode[1].talentInfo.preNode

			if preNodeCount == 3 then
				subType = nextNode[1].talentInfo.nodeType == 1 and 3 or 2
			elseif preNodeCount == 2 then
				subType = nextNode[1].talentInfo.nodeType == 1 and 4 or 1
			else
				subType = 5
			end

			linkDatas[i] = {
				{
					tIndex = 3,
					subType = subType,
					width = width,
					linkNode = nextNode,
					forceCheckNode = nextNode[1],
					preLinkNode = curNode
				}
			}

			self:handleLink3to1(nextNode, curNode)
		elseif nextCount == 3 and curCount == 1 then
			local realCount, _ = self:getRealNodeInfo(nextNode)
			local width = curNode[1].talentInfo.nodeType == 1 and 528 or 468
			local subType = realCount == 3 and (curNode[1].talentInfo.nodeType == 1 and 3 or 2) or nextNode[1].talentInfo.nodeType == 1 and 4 or 1

			linkDatas[i] = {
				{
					tIndex = 2,
					subType = subType,
					width = width,
					linkNode = nextNode
				}
			}
		elseif nextCount == 3 and curCount == 3 then
			linkDatas[i] = self:handleLink3to3(nextNode, curNode)
		end
	end

	local res = {}
	local topIndexs = {}

	for index, talentList in ipairs(data) do
		table.insert(res, talentList)

		if talentList.selected then
			self.needGoToIndex = #res - 1
		end

		table.insert(topIndexs, #res - 1)

		if linkDatas[index] then
			table.insert(res, linkDatas[index])
		end
	end

	return res, topIndexs
end

function RogLevelSelectCtrl:handleLink3to3(nextNode, curNode)
	local linkData = {}

	for index, nextItem in ipairs(nextNode) do
		local preNodeList = nextItem.talentInfo and nextItem.talentInfo.preNode or {}

		if nextItem.pre or preNodeList[1] then
			linkData[index] = {
				subType = 0,
				tIndex = 2,
				linkNode = nextNode
			}

			if curNode[index].empty then
				curNode[index].empty = false
				curNode[index].pre = nextItem.pre or preNodeList[1]
			end
		else
			linkData[index] = {
				empty = true,
				subType = 0,
				tIndex = 2,
				linkNode = nextNode
			}
		end
	end

	return linkData
end

function RogLevelSelectCtrl:handleLink3to1(nextNode, curNode)
	local preNodeList = nextNode[1].talentInfo.preNode

	for _, preNodeId in ipairs(preNodeList) do
		local preTalentInfo = RogueTalentData[preNodeId]

		if preTalentInfo.talentTreeNode then
			local preTreeInfo = preTalentInfo.talentTreeNode

			if curNode[preTreeInfo[2]].empty then
				curNode[preTreeInfo[2]].empty = false
				curNode[preTreeInfo[2]].pre = preNodeId
			end
		end
	end
end

function RogLevelSelectCtrl:getRealNodeInfo(data)
	local count = 0
	local res = {}

	for _, itemInfo in ipairs(data) do
		if not itemInfo.empty then
			count = count + 1

			table.insert(res, itemInfo)
		end
	end

	return count, res
end

function RogLevelSelectCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.focusTalentId = nil

	if info and info.focusTalentId then
		self.focusTalentId = info.focusTalentId

		self:focusTalentNode(info.focusTalentId)
		self:refreshConsoleBarState()
	end
end

function RogLevelSelectCtrl:focusTalentNode(talentId)
	self.view.rootComponent:TryChangePage("Tab", self.TitleTab.Talent)
	self.view.titleTabUList:SelectItem(self.TitleTab.Talent)

	local nodeInfo = self.talentId2Btn[talentId]

	self.needGoToIndex = nodeInfo and nodeInfo.index or math.floor(talentId * 2 / 3)

	self:goToSelectedTalent()

	local nodeInfo = self.talentId2Btn[talentId]

	if nodeInfo then
		if self.selectedList then
			self.selectedList:DeselectAll()
		end

		nodeInfo.button:OnClickSimulate()
		nodeInfo.button:InvokeCallback(CS.XGUI.EInvokeTime.User1)

		self.curSelectedTalentData = nodeInfo.data
		self.curSelectedTalentBtn = nodeInfo.button

		self:refreshTalentInfo(nodeInfo.data)
	end
end

function RogLevelSelectCtrl:onShow()
	return
end

function RogLevelSelectCtrl:onHide()
	pg.global.ui.tips:hideDropHint()
	UICtrl.onHide(self)
end

function RogLevelSelectCtrl:onDestroy()
	pg.global.ui.tips:hideDropHint()
	pg.game.audio:playBgm(nil, AudioConst.BgmPriority.RogueUI)

	if self.scrollEndCallback then
		self.view.normalLevelUList:UnRegisterToScrollEndEvent(self.scrollEndCallback)

		self.scrollEndCallback = nil
	end

	UICtrl.onDestroy(self)

	if self.scrollCallback then
		self.view.listLevel:UnRegisterToScrollEvent(self.scrollCallback)

		self.scrollCallback = nil
	end

	if self._scrollTimer then
		self:killTimer(self._scrollTimer)

		self._scrollTimer = nil
	end
end

return RogLevelSelectCtrl
