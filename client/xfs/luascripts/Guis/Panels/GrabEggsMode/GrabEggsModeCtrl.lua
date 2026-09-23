-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsMode\\GrabEggsModeCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("GrabEggsModeCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local GrabEggsModeCtrl = Class.LightClass("GrabEggsModeCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ShopCommodityData = require("Data.shop_commodity_data")
local ItemShopData = require("Data.item_shop_data")
local RedDotConst = require("Const.RedDotConst")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local ItemConst = require("Common.Const.ItemConst")
local RobEggConst = require("Common.Const.RobEggConst")
local HotkeyConst = require("Const.HotkeyConst")
local ClientConst = require("Const.ClientConst")
local TimeUtils = require("Common.Utils.TimeUtils")
local SeasonInfoComp = require("Guis.Panels.GrabEggsMode.Component.GrabEggsSeasonInfoComponent")
local GrabEggsRankUtils = require("Guis.Utils.GrabEggsRankUtils")
local GameStringConfig = require("Data.gamestring_config_data")
local GRAB_EGG_SHOP_CLASSIFY_ID = 35
local MODE_STATE_CHAOS_LOCKED = 0
local MODE_STATE_LOCKED = 1
local MODE_STATE_CHAOS_UNLOCKED = 2
local MODE_STATE_CHAOS_SELECTED = 3
local MODE_CHAOS = 0
local MODE_PVP = 1
local MODE_PVE = 2
local CHAOS_TICKET_LACK_COLOR = CS.UnityEngine.Color(0.996, 0.463, 0.463, 1)
local PVP_MODE_LOCKED_TIP_KEY = "UP_COMING"
local NOVICE_PROTECTION_MAIN_TEXT_KEY = "GRAB_EGG_NOVICEPROTECTION_MAIN"
local NOVICE_PROTECTION_TIPS_TEXT_KEY = "GRAB_EGG_NOVICEPROTECTION_TIPS"
local RANK_SCORE_DOUBLE_TIPS_TEXT_KEY = "GRAB_EGG_RANK_SCORE_DOUBLE_TIPS"
local NOVICE_AND_RANK_SCORE_DOUBLE_TIPS_TEXT_KEY = "GRAB_EGG_NOVICEPROTECTION_AND_RANK_SCORE_DOUBLE_TIPS"
local RANK_SCORE_DOUBLE_DAILY_REMINDER_TEXT_KEY = "GRAB_EGG_RANK_SCORE_DOUBLE_DAILY_REMINDER"
local RANK_SCORE_DOUBLE_REMINDER_PROGRESS_DURATION = 3
local RANK_SCORE_DOUBLE_REMINDER_DURATION = 3.46
local RANK_SCORE_DOUBLE_REMINDER_CACHE_KEY = "GrabEggRankScoreDoubleReminderLastServerDayBegin"
local DIFFICULT_DESC_TEXT = {
	nil,
	nil,
	"GRAB_EGG_dungeon_difficulty_1",
	"GRAB_EGG_dungeon_difficulty_2",
	"GRAB_EGG_dungeon_difficulty_3",
	"GRAB_EGG_dungeon_difficulty_4"
}

local function getChaosTicketConfig()
	local ticketConfig = require("Common.Const.ItemConst").ROBEGG_TICKET_CHAOS

	if not ticketConfig then
		return nil, 0
	end

	return next(ticketConfig)
end

local function getFirstAsset(asset)
	if asset and type(asset) ~= "string" then
		return asset[1]
	end

	return asset
end

GrabEggsModeCtrl.messages = {
	[MessageName.TEAM_MATCHED_STATUS_CHANGE] = {
		"onTeamMatchedStatusChange",
		true
	},
	[MessageName.SYNC_TEAM_INFO] = {
		"refreshGoToButtonState",
		true
	},
	[MessageName.GRAB_EGG_GAME_SUCCESS_TIMES_CHANGED] = {
		"onEggGameSuccessTimesChanged",
		true
	},
	[MessageName.GRAB_EGG_NOVICE_PROTECTION_CHANGED] = {
		"refreshNoviceProtectionView",
		true
	},
	[MessageName.MONEY_COUNT_CHANGE] = {
		"refreshTalentEntryRedDot",
		true
	},
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"onItemCountMapChanged",
		true
	},
	[MessageName.ITEM_GEN_COUNT_CHANGE] = {
		"onCalcinationInventoryChanged",
		true
	},
	[MessageName.GRAB_EGG_EQUIP_PROP] = {
		"onCalcinationInventoryChanged",
		true
	},
	[MessageName.COMMON_SWITCH_STATE_CHANGED] = {
		"onCommonSwitchStateChanged",
		true
	}
}

function GrabEggsModeCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.selectDifIndex = 1
	self.SeasonInfoComp = SeasonInfoComp.new(self, self.view.seasonInfoUContainer)
	self.chaosTicketNormalColor = self.view.chaosCostCurTicket.color

	self.view.protectUSDFText:SetActive(false)
	self.view.btnInfoUButton:SetActive(false)
	self.view.iconUp3UButton:SetActive(false)
	self.view.upTipUContainer:SetActive(false)
	self.view.dropHintUContainer:SetActive(false)

	self._isRankScoreDoubleViewShown = false

	ClientTextUtils.setText(self.view.iconUp3USDFText, pg.getGameString(NOVICE_PROTECTION_TIPS_TEXT_KEY))
end

function GrabEggsModeCtrl:blackClose()
	if self._openInfo and self._openInfo.backgroundOpen then
		self._blackFadeOutDuration = nil

		return
	end

	UICtrl.blackClose(self)
end

function GrabEggsModeCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	self:bindCloseButton()

	function self.view.btnGoToUButton.luaClick()
		self:onBtnConfirmClick()
	end

	self.view.btnInfoUButton.enabledTooltip = false

	function self.view.btnInfoUButton.luaClick()
		pg.global.ui.tips:openCommonPopUpTipById(Const.COMMON_POPUP_TIP_ID.GRAB_EGG_PROTECT_INFO)
	end

	self.view.iconUp3UButton.enabledTooltip = false

	function self.view.iconUp3UButton.luaClick()
		pg.global.ui.tips:openCommonPopUpTipById(Const.COMMON_POPUP_TIP_ID.GRAB_EGG_PROTECT_INFO)
	end

	function self.view.rewardList.luaRenderItem(button, _, data)
		self:renderRewardItem(button, data)
	end

	function self.view.selectorUSelector.luaSelectedChanged(uSelector)
		self:onOptionChanged(uSelector)
	end

	function self.view.selectorUSelector.luaRenderPopup(_, uList)
		function uList.luaRenderItem(uButton, idx, data)
			local optionState = self.model:redDot_GetSelectorOptionState(data.difficultLv)
			local path = string.format(RedDotConst.RedDotPath.GRAB_EGG_MODE_SELECTOR_OPTION, data.difficultLv)

			pg.global.setRedDot(path, uButton, optionState, RedDotConst.RedDotStyle.NEW)

			local page = math.clamp(data.difficultLv - 3, 0, 2)

			uButton:TryChangePage("difficulty", page)

			local canEnter, result = self.model:checkRobEggCanEnter(self.modeData.sceneId, data.difficultLv)

			uButton.visualInteractable = not result.lackRank
			data._lockResult = result
		end

		function uList.luaClick(uButton, data)
			self.model:redDot_SetSelectorOptionState(data.difficultLv)

			local path = string.format(RedDotConst.RedDotPath.GRAB_EGG_MODE_SELECTOR_OPTION, data.difficultLv)

			pg.global.setRedDot(path, uButton, false, RedDotConst.RedDotStyle.NONE)

			if not self.model:checkGrabEggLv(data) then
				for i, d in ipairs(self.modeData.difficultLvs) do
					if d.difficultLv == data.difficultLv then
						self.view.selectorUSelector:ForceSelect(i - 1)

						self.selectDifIndex = i

						self.model:setSelectionDifLv(data.difficultLv)
						self:refreshSelectedDifficult()

						break
					end
				end
			end
		end
	end

	function self.view.btnTeam1UButton.luaClick()
		self:onBtnMainPveModeClick()
	end

	self:setModeBtnName(self.view.btnTeam1UButton, "GRAB_EGG_MODE_NAME_SINGLE")

	function self.view.btnTeam3UButton.luaClick()
		self:onBtnSecondaryPveModeClick()
	end

	ClientTextUtils.setText(self.view.chaosName2, pg.getGameString("GRAB_EGG_ChaosDifficulty_1"))

	function self.view.btnTeam2UButton.luaClick()
		if self:isMultiModeLocked() then
			pg.global.showBubbleMessageRaw(pg.getGameString(PVP_MODE_LOCKED_TIP_KEY), 3)

			return
		end

		self.model:setSelectedMode(2)
		self:refreshSelectedMode()
		self.model:redDot_SetMultiModeState()
		pg.global.refreshRedDotState(RedDotConst.RedDotPath.GRAB_EGG_MODE_MULTI)
	end

	self:setModeBtnName(self.view.btnTeam2UButton, "GRAB_EGG_MODE_NAME_MULTIPLE")

	function self.view.btnStoreUButton.luaClick()
		self:openGrabEggStore()
	end

	function self.view.btnEquipUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_BAG, {
			bagType = UIConst.GRAB_EGG_BAG_TYPE.INVENTORY
		})
	end

	function self.view.btnTalentUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_TALENT)
	end

	if RobEggConst.CALCINATION_ENTRY_ENABLED then
		function self.view.btnForgingUButton.luaClick()
			pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_CALCINATION)
		end
	end

	function self.view.btnCollectionUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_COLLECTION)
	end
end

function GrabEggsModeCtrl:openGrabEggStore(locateItemId)
	if LuaUIUtils.checkFuncTemporaryDisable(UIConst.UI_ID_SHOP_MAIN) then
		return
	end

	local params = {
		shopTags = {
			GRAB_EGG_SHOP_CLASSIFY_ID
		}
	}

	if locateItemId then
		params.itemId = locateItemId

		local shopItemIds = ItemShopData[locateItemId]

		params.commodityId = shopItemIds and shopItemIds[1]

		local shopItemConfig = params.commodityId and ShopCommodityData[params.commodityId]

		params.groupId = shopItemConfig and shopItemConfig.paginationId
	end

	pg.global.ui:open(UIConst.UI_ID_SHOP_MAIN, params)
end

function GrabEggsModeCtrl:getChaosEntranceUnlockResult()
	return self.model:checkRobEggCanEnter(Const.ROB_EGG_SCENE_CLIP_ID, Const.DungeonDifficultLevel.NIGHTMARE)
end

function GrabEggsModeCtrl:getNormalPveUnlockResult()
	local minDifficultLv = self.model:getModeMinHardLv(Const.ROB_EGG_SCENE_CLIP_ID)

	if not minDifficultLv then
		return false
	end

	return self.model:checkRobEggCanEnter(Const.ROB_EGG_SCENE_CLIP_ID, minDifficultLv)
end

function GrabEggsModeCtrl:isMultiModeLocked()
	return not RobEggConst.PVP_MODE_ENTRY_ENABLED or self.model:checkIsFirstTimePlay() or not self.model:checkModeUnlock()
end

function GrabEggsModeCtrl:validateRememberedMode()
	local selectedMode = self.model:getSelectedMode()

	if selectedMode == 2 and self:isMultiModeLocked() then
		self.model:selectNormalMode()

		selectedMode = self.model:getSelectedMode()
	end

	if self.model:isChaosModeStateSelected() then
		local chaosEntranceUnlocked = self:getChaosEntranceUnlockResult()

		if chaosEntranceUnlocked and selectedMode == 1 then
			return
		end

		if not chaosEntranceUnlocked then
			self.model:clearChaosModeSelection()
		end
	end

	if selectedMode ~= 1 then
		return
	end

	local normalModeUnlocked = self:getNormalPveUnlockResult()

	if normalModeUnlocked then
		return
	end

	local multiModeUnlocked = not self:isMultiModeLocked()

	if multiModeUnlocked then
		self.model:setSelectedMode(2)
	end
end

function GrabEggsModeCtrl:selectNormalPveMode()
	self.model:selectNormalMode()
	self:refreshSelectedMode()
end

function GrabEggsModeCtrl:trySelectChaosMode()
	local entranceUnlocked, lockResult = self:getChaosEntranceUnlockResult()

	if not entranceUnlocked then
		pg.global.showBubbleMessageRaw(self.model:getEnterBubbleText(lockResult, Const.ROB_EGG_SCENE_CLIP_ID), 3)

		return
	end

	self.model:selectChaosMode()
	self:refreshSelectedMode()
end

function GrabEggsModeCtrl:onBtnMainPveModeClick()
	if self.model:isChaosModeStateSelected() then
		self:trySelectChaosMode()
	else
		self:selectNormalPveMode()
	end
end

function GrabEggsModeCtrl:onBtnSecondaryPveModeClick()
	if self.model:isChaosModeStateSelected() then
		self:selectNormalPveMode()
	else
		self:trySelectChaosMode()
	end
end

function GrabEggsModeCtrl:onDestroy()
	self._isRankScoreDoubleViewShown = false

	self:hideRankScoreDoubleReminder(false)

	if self.timeLimitTimer then
		self:killTimer(self.timeLimitTimer)

		self.timeLimitTimer = nil
	end

	if self._ensureSelectedTimer then
		self:killTimer(self._ensureSelectedTimer)

		self._ensureSelectedTimer = nil
	end

	pg.global.ui:close(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP)
	UICtrl.onDestroy(self)
end

function GrabEggsModeCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function GrabEggsModeCtrl:tickTimeLimit()
	if not self.modeData then
		return
	end

	local difData = self:getSelectedDifficultData()

	if not difData then
		return
	end

	local canEnter = self.model:checkRobEggCanEnter(self.modeData.sceneId, difData.difficultLv)

	if self._lastCanEnter == nil or self._lastCanEnter ~= canEnter then
		self._lastCanEnter = canEnter

		self:refreshSelectedMode()
	end
end

function GrabEggsModeCtrl:onCommonSwitchStateChanged()
	if not self.modeData then
		return
	end

	self._lastCanEnter = nil

	self:refreshSelectedMode()
end

function GrabEggsModeCtrl:onEggGameSuccessTimesChanged()
	self.view.btnTalentUButton:SetActive(self.model:isTalentEntryUnlocked())
	self:refreshNoviceProtectionView()
	self:refreshRankScoreDoubleView(false)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.GRAB_EGG_MODE_TALENT_BTN)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.GRAB_EGG_MODE)
end

function GrabEggsModeCtrl:onShow()
	self._isRankScoreDoubleViewShown = true
	self._lastModeButtonSelectedMode = nil
	self.needPlayModeEnterAnimation = true

	self:validateRememberedMode()
	self.view.btnTalentUButton:SetActive(self.model:isTalentEntryUnlocked())
	self.view.btnForgingUButton:SetActive(RobEggConst.CALCINATION_ENTRY_ENABLED)

	local multiModeState = self.model:redDot_GetMultiModeState()

	pg.global.setRedDot(RedDotConst.RedDotPath.GRAB_EGG_MODE_MULTI, self.view.btnTeam2UButton, multiModeState, RedDotConst.RedDotStyle.NEW)
	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.GRAB_EGG_MODE_SELECTOR, self.view.selectorUSelector, function()
		if self.model:getSelectedMode() == 2 then
			return RedDotConst.RedDotStyle.NONE
		end

		if self.model:redDot_GetSelectorState() then
			return RedDotConst.RedDotStyle.NEW
		end

		return RedDotConst.RedDotStyle.NONE
	end)
	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.GRAB_EGG_MODE_TALENT_BTN, self.view.btnTalentUButton, function()
		if self.model:redDot_GetTalentBtnState() then
			return RedDotConst.RedDotStyle.UP_HIGH
		end

		return RedDotConst.RedDotStyle.NONE
	end)
	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.GRAB_EGG_COLLECTION, self.view.btnCollectionUButton, function()
		return self.model:redDot_GetCollectionState()
	end)

	if RobEggConst.CALCINATION_ENTRY_ENABLED then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.GRAB_EGG_MODE_CALCINATION, self.view.btnForgingUButton, function()
			return self.model:redDot_GetCalcinationState()
		end)
		pg.global.refreshRedDotState(RedDotConst.RedDotPath.GRAB_EGG_MODE_CALCINATION)
	end

	pg.global.refreshRedDotState(RedDotConst.RedDotPath.GRAB_EGG_COLLECTION)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.GRAB_EGG_MODE)
	self:refreshSelectedMode()
	self.SeasonInfoComp:refresh()
	self:refreshRankScoreDoubleView(true)

	if self.timeLimitTimer then
		self:killTimer(self.timeLimitTimer)
	end

	self.timeLimitTimer = self:startTimer(function()
		self:tickTimeLimit()
	end, 1, true)
end

function GrabEggsModeCtrl:refreshTalentEntryRedDot()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.GRAB_EGG_MODE_TALENT_BTN)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.GRAB_EGG_COLLECTION)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.GRAB_EGG_MODE)
end

function GrabEggsModeCtrl:onItemCountMapChanged()
	self:refreshTalentEntryRedDot()
	self:refreshChaosTicketView()
end

function GrabEggsModeCtrl:onCalcinationInventoryChanged(param)
	if not RobEggConst.CALCINATION_ENTRY_ENABLED then
		return
	end

	local invId = param and (param.invId or param[1])

	if invId ~= ItemConst.INV_TYPE_ROB_EGG_WAREHOUSE then
		return
	end

	pg.global.refreshRedDotState(RedDotConst.RedDotPath.GRAB_EGG_MODE_CALCINATION)
end

function GrabEggsModeCtrl:refreshSelectedMode()
	self._lastCanEnter = nil

	local selectedMode = self.model:getSelectedMode()
	local isChaosMode = self.model:isChaosModeSelected()
	local isChaosModeStateSelected = self.model:isChaosModeStateSelected()
	local isFirstTimeMode = self.model:checkIsFirstTimePlay()
	local isMultiModeLocked = self:isMultiModeLocked()

	ClientTextUtils.setText(self.view.btnTalenttxtNameUBaseText, pg.getGameString("GRAB_EGG_TALENT_TITLE"))
	ClientTextUtils.setText(self.view.txtLimitNameUSDFText, pg.getGameString("GRAB_EGG_RANKLIMIT"))
	ClientTextUtils.setText(self.view.btnEquiptxtNameUBaseText, pg.getGameString("GRAB_EGG_BTN_EQUIP"))
	ClientTextUtils.setText(self.view.btnStoretxtNameUBaseText, pg.getGameString("GRAB_EGG_BTN_STORE"))
	ClientTextUtils.setText(self.view.btnForgingtxtNameUBaseText, pg.getGameString("GRAB_EGG_BTN_FORGING"))
	ClientTextUtils.setText(self.view.btnCollectionNameUBaseText, pg.getGameString("GRAB_EGG_Collection_Entrance"))
	ClientTextUtils.setText(self.view.chaosName, pg.getGameString(isChaosModeStateSelected and "GRAB_EGG_ChaosDifficulty_2" or "GRAB_EGG_ChaosDifficulty_3"))
	self.view.btnGoToUButton:SetActive(true)
	self.view.textWarningTip:SetActive(false)

	self.modeData, self.selectDifIndex = self.model:getDungeonModeInfo()

	self.view.selectorUSelector:SetOptions(self.modeData.difficultLvs)

	if not isChaosMode then
		self.view.selectorUSelector:ForceSelect(self.selectDifIndex - 1)
	end

	self.view.btnTeam2UButton:TryChangePage("state", isMultiModeLocked and 1 or 0)
	self.view.selectorUSelector:SetActive(selectedMode == 1 and not isChaosMode and not isFirstTimeMode)
	self.view.currencyItem:SetActive(isChaosMode)
	self.view.chaosCost:SetActive(isChaosMode)

	local normalModeUnlocked = self:getNormalPveUnlockResult()
	local chaosEntranceUnlocked = self:getChaosEntranceUnlockResult()
	local modeState

	if not normalModeUnlocked then
		modeState = MODE_STATE_LOCKED
	elseif not chaosEntranceUnlocked then
		modeState = MODE_STATE_CHAOS_LOCKED
	elseif isChaosModeStateSelected then
		modeState = MODE_STATE_CHAOS_SELECTED
	else
		modeState = MODE_STATE_CHAOS_UNLOCKED
	end

	self.view.rootUWidget:TryChangePage("state", modeState)
	self.view.btnTeam3UButton:SetActive(chaosEntranceUnlocked)
	self:refreshModeButtonState(selectedMode)
	self:refreshSelectedDifficult()

	local selectedDifficult = self:getSelectedDifficultData()

	if selectedDifficult then
		self._lastCanEnter = self.model:checkRobEggCanEnter(self.modeData.sceneId, selectedDifficult.difficultLv)
	end

	pg.global.refreshRedDotState(RedDotConst.RedDotPath.GRAB_EGG_MODE_SELECTOR)
end

function GrabEggsModeCtrl:refreshModeButtonState(selectedMode)
	if selectedMode == 1 then
		self.view.btnTeam2UButton.interactable = true
	else
		self.view.btnTeam2UButton.interactable = false
	end

	if self._lastModeButtonSelectedMode == selectedMode then
		return
	end

	self._lastModeButtonSelectedMode = selectedMode

	local selectedBtn

	if selectedMode == 1 then
		self.view.btnTeam1UButton.interactable = false

		self.view.btnTeam1UButton:TryChangePage("button", 5)
		self.view.btnTeam2UButton:TryChangePage("button", 0)

		selectedBtn = self.view.btnTeam1UButton
	else
		self.view.btnTeam2UButton.interactable = false

		self.view.btnTeam2UButton:TryChangePage("button", 5)

		self.view.btnTeam1UButton.interactable = true

		self.view.btnTeam1UButton:TryChangePage("button", 0)

		selectedBtn = self.view.btnTeam2UButton
	end

	self:ensureSelectedBtnPage(selectedBtn)
end

function GrabEggsModeCtrl:ensureSelectedBtnPage(btn)
	if self._ensureSelectedTimer then
		self:killTimer(self._ensureSelectedTimer)

		self._ensureSelectedTimer = nil
	end

	if btn.bStart then
		btn:TryChangePage("button", 5)

		return
	end

	self._ensureSelectedTimer = self:startTimer(function()
		if IsNil(btn) or not btn.bStart then
			return
		end

		btn:TryChangePage("button", 5)
		self:killTimer(self._ensureSelectedTimer)

		self._ensureSelectedTimer = nil
	end, 0, true)
end

function GrabEggsModeCtrl:setModeBtnName(btn, name)
	local oc = btn:GetComponent("ObjectReference")
	local tName = oc:GetRefValue("txtName")

	ClientTextUtils.setText(tName, pg.getGameString(name))
end

function GrabEggsModeCtrl:getSelectedDifficultData()
	if not self.modeData then
		return nil
	end

	if self.model:isChaosModeSelected() then
		return self.modeData.chaosDifficult
	end

	return self.modeData.difficultLvs[self.selectDifIndex]
end

function GrabEggsModeCtrl:refreshNoviceProtectionView()
	if not self.view or not self.modeData then
		return
	end

	local difData = self:getSelectedDifficultData()
	local player = pg.me
	local info = difData and player and player.grabEgg_getNoviceProtectionInfo and player:grabEgg_getNoviceProtectionInfo(self.modeData.sceneId, difData.difficultLv)
	local hasNoviceProtection = info ~= nil
	local protectionActive = hasNoviceProtection and info.isNextRoundProtected
	local rankScoreDoubleAvailable = GrabEggsRankUtils.isRankScoreDoubleAvailable()
	local showStatusTip = protectionActive or rankScoreDoubleAvailable

	self.view.protectUSDFText:SetActive(protectionActive)
	self.view.btnInfoUButton:SetActive(hasNoviceProtection)
	self.view.iconUp3UButton:SetActive(showStatusTip)

	if showStatusTip then
		local statusText

		if protectionActive and rankScoreDoubleAvailable then
			statusText = pg.getGameString(NOVICE_AND_RANK_SCORE_DOUBLE_TIPS_TEXT_KEY)
		elseif protectionActive then
			statusText = pg.getGameString(NOVICE_PROTECTION_TIPS_TEXT_KEY)
		else
			statusText = pg.getGameString(RANK_SCORE_DOUBLE_TIPS_TEXT_KEY)
		end

		ClientTextUtils.setText(self.view.iconUp3USDFText, statusText)
	end

	if not protectionActive then
		return
	end

	ClientTextUtils.setText(self.view.protectUSDFText, pg.getFormatText(pg.getGameString(NOVICE_PROTECTION_MAIN_TEXT_KEY), info.remainingTimes, info.totalTimes))
end

function GrabEggsModeCtrl:consumeRankScoreDoubleReminderDailyFlag()
	local player = pg.me
	local prefsCacheUtils = pg.global and pg.global.prefsCacheUtils
	local serverDayBegin = TimeUtils.getServerDayBegin()

	if not player or not player.uid or not prefsCacheUtils or not serverDayBegin or serverDayBegin <= 0 then
		return false
	end

	local cacheKey = RANK_SCORE_DOUBLE_REMINDER_CACHE_KEY .. tostring(player.uid)
	local cacheType = ClientConst.CACHE_TYPE_FLAG.USER
	local lastServerDayBegin = prefsCacheUtils:getInt(cacheKey, 0, cacheType)

	if lastServerDayBegin == serverDayBegin then
		return false
	end

	prefsCacheUtils:setIntImmediately(cacheKey, serverDayBegin, cacheType)

	return true
end

function GrabEggsModeCtrl:refreshRankScoreDoubleView(showReminder)
	if not self.view then
		return
	end

	local upTipUContainer = self.view.upTipUContainer

	if IsNil(upTipUContainer) then
		return
	end

	local info = GrabEggsRankUtils.getRankScoreDoubleInfo()

	upTipUContainer:SetActive(info.available)

	if not info.available then
		self:hideRankScoreDoubleReminder(false)

		return
	end

	local function renderTag()
		if not self.view or IsNil(upTipUContainer) or not self._isRankScoreDoubleViewShown or not GrabEggsRankUtils.isRankScoreDoubleAvailable() then
			return
		end

		local content = upTipUContainer.content

		if IsNil(content) then
			return
		end

		local objectReference = content:GetComponent("ObjectReference")

		if IsNil(objectReference) then
			return
		end

		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		if NotNil(txtNameUSDFText) then
			ClientTextUtils.setTextWithId(txtNameUSDFText, GameStringConfig.GRAB_EGG_RANK_SCORE_DOUBLE_TAG.desc)
		end

		local upTipUButton = content:GetComponent("UButton")

		if NotNil(upTipUButton) then
			upTipUButton.enabledTooltip = false

			function upTipUButton.luaClick()
				pg.global.ui.tips:openCommonPopUpTipById(Const.COMMON_POPUP_TIP_ID.GRAB_EGG_PROTECT_INFO)
			end
		end
	end

	if upTipUContainer:CheckURLLoaded() then
		renderTag()
	else
		upTipUContainer:LoadDefaultUrlManually(renderTag)
	end

	if showReminder and self:consumeRankScoreDoubleReminderDailyFlag() then
		self:showRankScoreDoubleReminder()
	end
end

function GrabEggsModeCtrl:showRankScoreDoubleReminder()
	local container = self.view and self.view.dropHintUContainer

	if IsNil(container) then
		return
	end

	self:hideRankScoreDoubleReminder(false)
	container:SetActive(true)

	local function renderReminder()
		if not self.view or IsNil(container) or not self._isRankScoreDoubleViewShown or not GrabEggsRankUtils.isRankScoreDoubleAvailable() then
			self:hideRankScoreDoubleReminder(false)

			return
		end

		local content = container.content

		if IsNil(content) then
			return
		end

		local objectReference = content:GetComponent("ObjectReference")

		if IsNil(objectReference) then
			return
		end

		local progressUProgress = objectReference:GetRefValue("progressUProgress")
		local progressRightUProgress = objectReference:GetRefValue("progressRightUProgress")
		local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

		if IsNil(progressUProgress) or IsNil(progressRightUProgress) or IsNil(txtNameUBaseText) then
			return
		end

		ClientTextUtils.setText(txtNameUBaseText, pg.getFormatText(pg.getGameString(RANK_SCORE_DOUBLE_DAILY_REMINDER_TEXT_KEY), GrabEggsRankUtils.getRankScoreDoubleInfo().totalTimes))

		progressUProgress.value = 1
		progressRightUProgress.value = 1

		progressUProgress:ProgressToValue(0, nil, RANK_SCORE_DOUBLE_REMINDER_PROGRESS_DURATION)
		progressRightUProgress:ProgressToValue(0, nil, RANK_SCORE_DOUBLE_REMINDER_PROGRESS_DURATION)

		self._rankScoreDoubleReminderTimer = self:startTimer(function()
			self._rankScoreDoubleReminderTimer = nil

			self:hideRankScoreDoubleReminder(true)
		end, RANK_SCORE_DOUBLE_REMINDER_DURATION)
	end

	if container:CheckURLLoaded() then
		renderReminder()
	else
		container:LoadDefaultUrlManually(renderReminder)
	end
end

function GrabEggsModeCtrl:hideRankScoreDoubleReminder(playAnimation)
	if self._rankScoreDoubleReminderTimer then
		self:killTimer(self._rankScoreDoubleReminderTimer)

		self._rankScoreDoubleReminderTimer = nil
	end

	local container = self.view and self.view.dropHintUContainer

	if IsNil(container) then
		return
	end

	local content = container.content

	if playAnimation and NotNil(content) and content:CheckHasEvent(CS.XGUI.EInvokeTime.Hide) then
		content:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.Hide, function()
			if NotNil(container) then
				container:SetActive(false)
			end
		end)
	else
		container:SetActive(false)
	end
end

function GrabEggsModeCtrl:onOptionChanged(uSelector)
	self.selectDifIndex = uSelector.selectedIndex + 1

	local difData = self.modeData.difficultLvs[self.selectDifIndex]

	if not difData then
		return
	end

	self.model:setSelectionDifLv(difData.difficultLv)

	self._lastCanEnter = nil

	self:refreshSelectedDifficult()
end

function GrabEggsModeCtrl:getVisualMode(difData)
	if self.modeData.sceneId == Const.ROB_EGG_SCENE_ID then
		return MODE_PVP
	end

	if difData.difficultLv == self.model:getChaosDifficultLv() then
		return MODE_CHAOS
	end

	return MODE_PVE
end

function GrabEggsModeCtrl:refreshModeVisual(difData)
	local bgUrl = getFirstAsset(difData.gameUIAsset)
	local peopleUrl = getFirstAsset(difData.gameUINpcAsset)
	local visualMode = self:getVisualMode(difData)
	local needPlayEnterAnimation = self.needPlayModeEnterAnimation

	if needPlayEnterAnimation then
		if bgUrl then
			self.view.oldBg.url = bgUrl
		end

		if peopleUrl then
			self.view.oldPeopleImg.url = peopleUrl
		end
	elseif self.visualMode ~= nil and self.visualMode ~= visualMode then
		if self.currentBgUrl then
			self.view.oldBg.url = self.currentBgUrl
		end

		if self.currentPeopleUrl then
			self.view.oldPeopleImg.url = self.currentPeopleUrl
		end
	end

	if bgUrl then
		self.view.bg.url = bgUrl
	end

	if peopleUrl then
		self.view.peopleImg.url = peopleUrl
	end

	if needPlayEnterAnimation then
		local resetMode = visualMode == MODE_PVE and MODE_CHAOS or MODE_PVE

		self.view.rootUWidget:TryChangePage("Mode", resetMode, true)
		self.view.rootUWidget:TryChangePage("Mode", visualMode)

		self.needPlayModeEnterAnimation = false
	elseif self.visualMode ~= visualMode then
		self.view.rootUWidget:TryChangePage("Mode", visualMode)
	end

	self.visualMode = visualMode
	self.currentBgUrl = bgUrl
	self.currentPeopleUrl = peopleUrl
end

function GrabEggsModeCtrl:refreshSelectedDifficult()
	local difData = self:getSelectedDifficultData()

	if not difData then
		return
	end

	self:refreshModeVisual(difData)
	ClientTextUtils.setText(self.view.peopleNumUBaseText, "1-3")
	self.view.dangerousTip:TryChangePage("Grade", difData.dangerLv)

	local difficultDescKey

	difficultDescKey = self.modeData.sceneId == Const.ROB_EGG_SCENE_ID and "GRAB_EGG_dungeon_difficulty_3" or DIFFICULT_DESC_TEXT[difData.difficultLv]

	ClientTextUtils.setText(self.view.gradTxt, difficultDescKey and pg.getGameString(difficultDescKey) or "")
	ClientTextUtils.setText(self.view.dungeonNameUText, difData.sceneName)

	if difData.openTimeRange then
		ClientTextUtils.setText(self.view.dungeonScrollRect.content, pg.getFormatText(difData.describe, difData.openTimeRange, difData.endTimeRange))
	else
		ClientTextUtils.setText(self.view.dungeonScrollRect.content, difData.describe)
	end

	ClientTextUtils.setText(self.view.textTimeLimit, difData.openTime)
	ClientTextUtils.setText(self.view.textTeamNum, difData.teamNumDesc)

	if difData.rankLimit then
		ClientTextUtils.setText(self.view.textLvLimit, self.model:getRankDisplayInfoByLv(difData.rankLimit[1], difData.rankLimit[2]).name)
	else
		ClientTextUtils.setText(self.view.textLvLimit, pg.getGameString("GRAB_EGG_RANK_NOLIMIT"))
	end

	ClientTextUtils.setText(self.view.textPetLvLimit, difData.enemyLevel)
	ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getGameString("GRAB_EGG_MODE_FIRSTREWARD"))
	self.view.rewardList:SetList(difData.rewards)

	local modeCanEnter, modeResult, TimeLimit = self.model:getModeLockResult(self.modeData.sceneId, difData.difficultLv)

	self.view.rootUWidget:TryChangePage("TimeLimit", TimeLimit)

	if TimeLimit == 1 then
		ClientTextUtils.setText(self.view.textTimeTips, self.model:getLockTipFinalText(modeResult, self.modeData.sceneId))
	else
		local canEnter, _ = self.model:checkRobEggCanEnter(self.modeData.sceneId, difData.difficultLv)

		self.view.btnGoToUButton:TryChangePage("LockState", canEnter and 0 or 1)
	end

	self:refreshChaosTicketView()
	self:refreshGoToButtonState()
	self:refreshNoviceProtectionView()
end

function GrabEggsModeCtrl:getGoToDisabledText(difData)
	if self.model:isTeamMemberCountOverDungeonMax() then
		return pg.getGameString("NUMBER_NOT_READY")
	end

	if pg.me:isInTeam() and not pg.me:isTeamLeader() then
		return pg.getGameString("ONLY_CAPTAIN_BOOT")
	end

	local sceneId = self.model:getDungeonSceneId()
	local canEnter, result = self.model:checkRobEggCanEnter(sceneId, difData.difficultLv)

	if not canEnter and result.lackTime then
		return result.requiredTimeRange or self.model:getLockTipFinalText(result, sceneId)
	end
end

function GrabEggsModeCtrl:refreshGoToButtonState()
	if not self.view or not self.model or not self.modeData then
		return
	end

	local difData = self:getSelectedDifficultData()

	if not difData then
		return
	end

	local disabledText = self:getGoToDisabledText(difData)
	local canGoTo = disabledText == nil

	self.view.btnGoToUButton.interactable = canGoTo
	self.view.btnGoToUButton.visualInteractable = canGoTo

	self.view.textWarningTip:SetActive(not canGoTo)

	if not canGoTo then
		ClientTextUtils.setText(self.view.textWarningTip, disabledText)
	end
end

function GrabEggsModeCtrl:getChaosTicketCount(ticketItemId)
	ticketItemId = ticketItemId or getChaosTicketConfig()

	if not ticketItemId or not pg.me then
		return 0
	end

	return pg.me:getItemCountById(ticketItemId) or 0
end

function GrabEggsModeCtrl:hasEnoughChaosTicket()
	local ticketItemId, ticketCost = getChaosTicketConfig()

	if not ticketItemId then
		return true
	end

	return self:getChaosTicketCount(ticketItemId) >= (ticketCost or 0)
end

function GrabEggsModeCtrl:refreshChaosTicketView()
	if not self.view then
		return
	end

	local isChaosMode = self.model:isChaosModeSelected()

	self.view.currencyItem:SetActive(isChaosMode)
	self.view.chaosCost:SetActive(isChaosMode)

	local ticketItemId, ticketCost = getChaosTicketConfig()

	if not isChaosMode or not ticketItemId then
		return
	end

	LuaUIUtils.setTopCurrencyItem(self.view.currencyItem, ticketItemId)

	self.view.chaosCostIcon.url = LuaUIUtils.getIconByItemId(ticketItemId)

	local ticketCount = self:getChaosTicketCount(ticketItemId)

	ticketCost = ticketCost or 0

	if ticketCount < ticketCost then
		self.view.chaosCostCurTicket.color = CHAOS_TICKET_LACK_COLOR
	else
		self.view.chaosCostCurTicket.color = self.chaosTicketNormalColor
	end

	ClientTextUtils.setText(self.view.chaosCostCurTicket, string.format("x%d", ticketCost))

	local canEnter = self.model:checkRobEggCanEnter(Const.ROB_EGG_SCENE_CLIP_ID, self.model:getChaosDifficultLv())

	self.view.btnGoToUButton:TryChangePage("LockState", canEnter and self:hasEnoughChaosTicket() and 0 or 1)
end

function GrabEggsModeCtrl:showChaosTicketLackConfirm()
	local ticketItemId = getChaosTicketConfig()

	pg.global.showConfirmMsgRaw(pg.getGameString("GRAB_EGG_ChaosDifficulty_ticket"), pg.getGameString("GRAB_EGG_ChaosDifficulty_ticket_insufficient_tip"), function()
		self:openGrabEggStore(ticketItemId)
	end)
end

function GrabEggsModeCtrl:renderRewardItem(item, data)
	LuaUIUtils.renderRewardItem(item, data)
end

function GrabEggsModeCtrl:refreshTalentView()
	return
end

function GrabEggsModeCtrl:refreshRankView()
	return
end

function GrabEggsModeCtrl:renderTalentItem(button, index, data)
	if data.isEmpty then
		button:TryChangePage("isEmpty", 1)

		return
	else
		button:TryChangePage("isEmpty", 0)
	end

	button.name = data.id

	local treePath = string.format(RedDotConst.RedDotPath.GRAB_EGG_MODE_TALENT_LIST_ITEM, data.id or 0)
	local showRedDot = pg.global.ui.playerEnhance.model:redDot_GetPlayerTreeTrListItemState(data)

	pg.global.setRedDot(treePath, button, showRedDot, RedDotConst.RedDotStyle.NEW)

	local oc = button:GetComponent("ObjectReference")
	local Anima = oc:GetRefValue("btnAnimation")

	function button.luaClick(navConfirm)
		if self.selectUButton then
			self.selectUButton.isSelected = false
		end

		button.isSelected = true
		self.selectUButton = button

		local openInfo = {
			autoHor = true,
			singleDisplay = true,
			targetRect = button,
			data = data,
			onCallback = function(isLearn)
				pg.global.ui:close(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP)
				Anima:InvokeCallback(CS.XGUI.EInvokeTime.User1)
			end,
			onCloseCallback = function()
				if self.selectUButton then
					self.selectUButton.isSelected = false
					self.selectUButton = nil
				end
			end
		}

		if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP) then
			pg.global.ui:close(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP)
		else
			pg.global.ui:open(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP, openInfo)
		end

		pg.global.ui.playerEnhance.model:redDot_SetPlayerTreeTrListItemState(data)
		pg.global.setRedDot(treePath, button, false)
	end

	local tLevel = oc:GetRefValue("txtLevel")
	local tName = oc:GetRefValue("txtName")
	local iIcon = oc:GetRefValue("icon")

	ClientTextUtils.setText(tName, data.name)

	local skillState = data.state

	if skillState == pg.global.ui.playerEnhance.model.SKILL_STATE.CAN_UPGRADE then
		button:TryChangePage("Update", 1)
	else
		button:TryChangePage("Update", 0)
	end

	if data.keyBoard then
		local iPbKey = oc:GetRefValue("keyHotKey")

		iPbKey:SetHotKeyPaths(data.keyBoard)
		button:TryChangePage("Equip", 1)
	else
		button:TryChangePage("Equip", 0)
	end

	if skillState == pg.global.ui.playerEnhance.model.SKILL_STATE.CANT_UNLOCK_LEVEL_INSUFFICIENT then
		button:TryChangePage("SkillStage", 0)
		ClientTextUtils.setText(tLevel, "")
	elseif skillState == pg.global.ui.playerEnhance.model.SKILL_STATE.CAN_UNLOCK or skillState == pg.global.ui.playerEnhance.model.SKILL_STATE.CANT_UNLOCK_CONDITION_NOT_MEET then
		button:TryChangePage("SkillStage", 1)
		ClientTextUtils.setText(tLevel, string.format("0/%d", data.maxLv))
	else
		button:TryChangePage("SkillStage", 2)
		ClientTextUtils.setText(tLevel, string.format("%d/%d", data.level, data.maxLv))
	end

	iIcon.url = data.icon

	button:TryChangePage("SkillType", data.isRare and 1 or 0)
end

function GrabEggsModeCtrl:checkModeUnlocked()
	return
end

function GrabEggsModeCtrl:onBtnConfirmClick()
	local difData = self:getSelectedDifficultData()

	if not difData then
		return
	end

	local disabledText = self:getGoToDisabledText(difData)

	if disabledText then
		pg.global.showBubbleMessageRaw(disabledText, 3)

		return
	end

	local sceneId = self.model:getDungeonSceneId()
	local difLvSel = self.model:getSelectedDifLv()
	local canEnter, lockResult = self.model:checkRobEggCanEnter(sceneId, difLvSel)

	if not canEnter then
		pg.global.showBubbleMessageRaw(self.model:getEnterBubbleText(lockResult, sceneId), 3)

		return
	end

	if self.model:isChaosModeSelected() and not self:hasEnoughChaosTicket() then
		self:showChaosTicketLackConfirm()

		return
	end

	if pg.me:isInMatching() then
		local dungeonSceneId = self.model:getDungeonSceneId()
		local difLv = self.model:getSelectedDifLv()
		local oldDungeonId = pg.me:getMatchDungeonId()
		local oldDungeonHardLv = pg.me:getDungeonHardLv()

		if oldDungeonId ~= dungeonSceneId or oldDungeonHardLv ~= difLv then
			if not pg.me:isInTeam() or pg.me:isTeamLeader() then
				local oldName = pg.me:getDungeonName(oldDungeonId)
				local newName = pg.me:getDungeonName(dungeonSceneId)

				if pg.me:isEggDungeon(oldDungeonId) then
					local oldDiffName = self.model:getDifficultName(oldDungeonHardLv)

					oldName = oldName .. oldDiffName
				end

				if pg.me:isEggDungeon(dungeonSceneId) then
					local newDiffName = self.model:getDifficultName(difLv)

					newName = newName .. newDiffName
				end

				pg.global.showConfirmMsgRaw(nil, pg.getFormatText(pg.getGameString("CHANGE_MATCH"), oldName, newName), function()
					local isInTeam = pg.me:isInTeam()
					local membersCount = pg.me:getTeamMemberCount()

					if isInTeam then
						if membersCount == 1 then
							pg.me:leaveTeam()
						elseif pg.me:isTeamLeader() then
							pg.me:cancelTeamMatching()
						end
					else
						pg.me:cancelTeamMatching()
					end
				end)
			else
				pg.global.showBubbleMessageRaw(pg.getGameString("ONLY_CAPTAIN_BOOT"))
			end

			return
		end
	end

	local state, reason = self.model:checkMemberLvMatch(difData)

	if not state then
		pg.global.showBubbleMessageRaw(reason, 3)

		return
	end

	local dungeonSceneId = self.model:getDungeonSceneId()

	if pg.me:isInTeam() and not pg.me:isUidTeamLeader(pg.me.uid) and pg.me:getCurTeamInfo().dungeonSceneId ~= dungeonSceneId then
		pg.global.showBubbleMessageRaw(pg.getGameString("ONLY_CAPTAIN_BOOT"))

		return
	end

	local difLv = self.model:getSelectedDifLv()

	pg.me:grabEgg_tryEnterPrepRoom(dungeonSceneId, difLv)
end

function GrabEggsModeCtrl:onTeamMatchedStatusChange()
	self:refreshGoToButtonState()

	if self.matchStatus and self.matchStatus == Const.DUNGEON_CHANGE_STATUS.WaitChange and not pg.me:isInTeam() then
		self:onBtnConfirmClick()

		self.matchStatus = nil
	end
end

function GrabEggsModeCtrl:onHide()
	self._isRankScoreDoubleViewShown = false

	self:hideRankScoreDoubleReminder(false)

	if pg.me:isInSingleTeam() and not pg.me:isInMatching() then
		pg.me:leaveTeam()
	end
end

return GrabEggsModeCtrl
