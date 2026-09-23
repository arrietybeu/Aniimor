-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\FuncListUIComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("FuncListUIComponent")
local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local ConflictTypes = require("Common.ConflictTypes")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local RedDotConst = require("Const.RedDotConst")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local Utils = require("Common.Utils.Utils")
local QuestConst = require("Common.Const.QuestConst")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local MessageName = require("Const.MessageName")
local RogueUtils = require("Utils.RogueUtils")
local RogueConst = require("Const.RogueConst")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local BossRushUtils = require("Utils.BossRushUtils")
local CashShopRedDotUtils = require("Utils.CashShopRedDotUtils")
local HomeBookRedDotUtils = require("Utils.HomeBookRedDotUtils")
local HomeSeasonUtils = require("Utils.HomeSeasonUtils")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local DownloadProgressComponent = require("Guis.Panels.ResourceDownload.Component.DownloadProgressComponent")
local MonthCardUtils = require("GameApp.MonthCard.MonthCardUtils")
local LotteryUtils = require("Utils.LotteryUtils")
local GachaEntryData = require("Data.gacha_entry_data")
local FuncListUIComponent = Class.LightClass("FuncListUIComponent", HudBaseComponent)
local FUNC_LIST_ITEM_HOTKEY_BIND_NAME = "funcListItemHotKey"
local ROGUE_FUNC_LIST_IDS = {
	[UIConst.UI_ID_TOWER_BUFF_DETAIL] = true,
	[UIConst.UI_ID_TOWER_STAGE_INFO] = true
}
local SEASON_ENTRY_FLY_DURATION = 0.5
local SEASON_ENTRY_FLY_EASE = CS.DG.Tweening.Ease.__CastFrom(6)
local SEASON_ENTRY_FLY_TWEEN_ID = LuaUIUtils.TweenId("seasonEntryFly")
local LOTTERY_TOOLTIP_EASE = CS.DG.Tweening.Ease.Linear
local LOTTERY_TOOLTIP_RECORD_KEY = "HUD_CASH_LOTTERY_TOOLTIP_%s_%s"

FuncListUIComponent.messages = {
	[MessageName.ON_SYSTEM_FUNCTION_UNLOCKED] = {
		"onSystemFunctionUnlocked"
	},
	[MessageName.ON_SYSTEM_FUNCTION_SHIELDED] = {
		"onSystemFunctionShielded"
	},
	[MessageName.ON_SYSTEM_FUNCTION_LOCKED] = {
		"onSystemFunctionLocked"
	},
	[MessageName.COMMON_SWITCH_STATE_CHANGED] = {
		"refreshFuncListBtnState",
		true
	},
	[MessageName.EVENT_REFRESH_REDDOT] = {
		"onEventRefreshRedDot",
		true
	},
	[MessageName.EVENT_REFRESH_TAB_LIST] = {
		"onEventRefreshRedDot",
		true
	},
	[MessageName.EVENT_TASK_STATE_CHANGE] = {
		"onEventRefreshRedDot",
		true
	},
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"onEventRefreshRedDot",
		true
	},
	[MessageName.NOTIFY_ACTIVITY_DAY_UPDATED] = {
		"onEventRefreshRedDot",
		true
	},
	[MessageName.CASH_SHOP_REWARD_CHANGED] = {
		"onCashShopRewardChanged",
		true
	},
	[MessageName.CURRENCY_CHANGE] = {
		"onCurrencyChanged",
		true
	},
	[MessageName.MONEY_COUNT_CHANGE] = {
		"onCurrencyChanged",
		true
	},
	[MessageName.MONEY_UNBOUND_CHANGE] = {
		"onCurrencyChanged",
		true
	},
	[MessageName.ROGUE_EQUIPMENT_CHANGE] = {
		"refreshEquipmentInfo",
		true
	},
	[MessageName.QUEST_ON_STATE_CHANGE] = {
		"onQuestStateChanged",
		true
	},
	[MessageName.RED_DOT_SPECIAL_TRAIN_TREE] = {
		"refreshSpecialTrainRedDot",
		true
	},
	[MessageName.MODULE_ENABLE_CHANGED] = {
		"onModuleEnableChanged",
		true
	},
	[MessageName.BOSS_TITLE_SHOWN_MESSAGE] = {
		"onBossTitleVisibleChanged",
		true
	},
	[MessageName.ON_PLAYER_START_RIFT] = {
		"refreshRiftMode",
		true
	},
	[MessageName.ON_PLAYER_END_RIFT] = {
		"refreshRiftMode",
		true
	},
	[MessageName.PLAYER_LEVEL_CHANGE] = {
		"refreshPlayerRedDot",
		true
	},
	[MessageName.RED_DOT_PLAYER_SKILL_TREE] = {
		"refreshPlayerRedDot",
		true
	},
	[MessageName.PLAYER_STAR_CHANGE] = {
		"refreshPlayerRedDot",
		true
	},
	[MessageName.MAIN_PLAYER_PET_ADD] = {
		"refreshPlayerRedDot",
		true
	},
	[MessageName.PET_NEW_RED_DOT_RECORD_UPDATE] = {
		"refreshPlayerRedDot",
		true
	},
	[MessageName.RED_DOT_PLAYER_REWARD] = {
		"refreshPlayerRedDot",
		true
	},
	[MessageName.RED_DOT_PLAYER_LEVEL_CHANGED] = {
		"refreshPlayerRedDot",
		true
	},
	[MessageName.RECV_MAIL] = {
		"refreshPlayerRedDot",
		true
	},
	[MessageName.PET_AREA_REWARD_CHANGE] = {
		"refreshPlayerRedDot",
		true
	},
	[MessageName.ON_HOME_BOOK_DATA_CHANGED] = {
		"onHomeBookDataChanged",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	},
	[MessageName.INPUT_GAMEPAD_CONTROL_MODE_CHANGE] = {
		"refreshDownloadGamepadKeyDisplay",
		true
	},
	[MessageName.SCENE_LOADED] = {
		"onSceneLoaded",
		true
	},
	[MessageName.HOME_SEASON_CHANGE] = {
		"onHomeSeasonChanged",
		true
	},
	[MessageName.HOME_SEASON_PROGRESS_CHANGE] = {
		"onHomeSeasonRedDotChanged",
		true
	},
	[MessageName.HOME_SEASON_STAGE_CHANGE] = {
		"onHomeSeasonRedDotChanged",
		true
	},
	[MessageName.HOME_SEASON_TASK_CHANGED] = {
		"onHomeSeasonRedDotChanged",
		true
	},
	[MessageName.HOME_SEASON_MUTATION_COLLECTION_CHANGE] = {
		"onHomeSeasonRedDotChanged",
		true
	},
	[MessageName.HOMELAND_ITEM_MAP_CHANGED] = {
		"onHomeSeasonRedDotChanged",
		true
	},
	[MessageName.HOME_CAR_CAMP_DISPATCH_STATE_CHANGED] = {
		"onHomeCampDispatchStateChanged",
		true
	},
	[MessageName.RESOURCE_DOWNLOAD_STATE_CHANGED] = {
		"onResourceDownloadStateChanged",
		true
	},
	[MessageName.UI_ON_HIDE] = {
		"onLotteryLoadingPanelHide",
		true
	},
	[MessageName.SEASON_ACTIVITY_POP_PENDING_CHANGED] = {
		"onSeasonActivityPopPendingChanged",
		true
	},
	[MessageName.SEASON_ACTIVITY_POP_FLY] = {
		"onSeasonActivityPopFly",
		true
	}
}

function FuncListUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootPanel = objectReference:GetRefValue("rootPanel")
	self.funcMenuBtnUButton = objectReference:GetRefValue("funcMenuBtnUButton")
	self.gMBtnUButton = objectReference:GetRefValue("gMBtnUButton")
	self.listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")
	self.listFuncBtnUList = objectReference:GetRefValue("listFuncBtnUList")
	self.towerKeyHotKeyContent = objectReference:GetRefValue("towerKeyHotKeyContent"):GetComponent("HotKeyContent")
	self.towerKeyUButton = objectReference:GetRefValue("towerKeyUButton")
	self.btnRiftInfoUButton = objectReference:GetRefValue("btnRiftInfoUButton")
	self.seasonBtnUButton = objectReference:GetRefValue("seasonBtnUButton")

	if self.seasonBtnUButton then
		local seasonObjectReference = self.seasonBtnUButton:GetComponent("ObjectReference")

		self.seasonAnimationUWidget = seasonObjectReference and seasonObjectReference:GetRefValue("animationUWidget")

		if self.seasonAnimationUWidget then
			local animationTransform = self.seasonAnimationUWidget.transform

			self.seasonAnimationOriginalParent = animationTransform.parent
			self.seasonAnimationOriginalSiblingIndex = animationTransform:GetSiblingIndex()
			self.seasonAnimationOriginalAnchoredPosition = animationTransform.anchoredPosition3D
			self.seasonAnimationOriginalRotation = animationTransform.localRotation
			self.seasonAnimationOriginalScale = animationTransform.localScale

			self:resetSeasonEntryFlyVisual()
		end
	end

	self.towerProgressPressContainerUContainer = objectReference:GetRefValue("towerProgressPressContainerUContainer")

	if self.towerProgressPressContainerUContainer then
		self.towerProgressPressContainerUContainer:SetActive(true)
		self.towerProgressPressContainerUContainer:LoadDefaultUrlManually(function(content)
			self.gamepadMenuKeyProgressPress = content

			self.gamepadMenuKeyProgressPress:ProgressToValue(0, nil)
		end)
	end

	self.downloadBtnUContainer = objectReference:GetRefValue("downloadBtnUContainer")
	self.downloadKeyGameObject = nil
	self.downloadKeyHotKeyContent = nil
	self.downloadKeyProgressPress = nil

	if self.downloadBtnUContainer and self.downloadBtnUContainer.transform then
		local downloadBtnParent = self.downloadBtnUContainer.transform.parent
		local downloadKeyTransform = downloadBtnParent and downloadBtnParent:Find("Key")

		if downloadKeyTransform then
			self.downloadKeyGameObject = downloadKeyTransform.gameObject
			self.downloadKeyHotKeyContent = downloadKeyTransform:GetComponent("HotKeyContent")

			self.downloadKeyHotKeyContent:SetHotKeyPaths(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadDPadDown)
			LuaUIUtils.waitHotKeyContentObjectReference(self, self.downloadKeyHotKeyContent, function(keyObjectReference)
				local progressPressContainer = keyObjectReference:GetRefValue("progressPressContainerUContainer")

				if not progressPressContainer then
					return
				end

				progressPressContainer:SetActive(true)
				progressPressContainer:LoadDefaultUrlManually(function(progress)
					self.downloadKeyProgressPress = progress

					self.downloadKeyProgressPress:ProgressToValue(0, nil, 0)
					self:initDownloadGamepadKey()
					self:setDownloadKeyVisible(self.downloadVisible)
				end)
			end)
		end
	end

	self.equipmentUContainer = objectReference:GetRefValue("equipmentUContainer")
	self.btnSwitchUButton = objectReference:GetRefValue("btnSwitchUButton")
	self.layoutBoxListCurrency = objectReference:GetRefValue("layoutBoxListCurrency")
	self.innerListCurrencyUList = objectReference:GetRefValue("innerListCurrencyUList")
	self.innerLayoutBoxListCurrency = objectReference:GetRefValue("innerLayoutBoxListCurrency")
	self.layoutBoxAllTransform = objectReference:GetRefValue("layoutBoxAllTransform")
	self.funcButton = {}
	self.currencySlotMap = {}
end

function FuncListUIComponent:onModuleEnableChanged(changeInfo)
	local moduleKey = changeInfo.moduleKey or ""

	if moduleKey == ClientConst.ModuleKey.Esc then
		self:refreshESCBtnState()
	end
end

function FuncListUIComponent:refreshESCBtnState()
	local escBtnVisible = self:getEscBtnVisible()
	local showFuncMenu, showESC = pg.global.ui.funMenuExit.model:checkShowFunc()

	self.funcMenuBtnUButton:SetActive(showFuncMenu)

	self.canOpenFuncMenu = showFuncMenu and escBtnVisible
end

function FuncListUIComponent:initView()
	function self.listFuncBtnUList.luaRenderItem(button, index, data)
		self:renderFuncList(button, index, data)
	end

	if self.btnSwitchUButton then
		function self.btnSwitchUButton.luaClick()
			self:onFuncSwitchBtnClick()
		end
	end

	function self.funcMenuBtnUButton.luaClick()
		self:openFuncMenu()
	end

	self:bindFuncBtnHotKey(self.funcMenuBtnUButton.gameObject, "openSetupBind", HotkeyConst.INPUT_MAP_ACTION_KEY.OpenSetup)

	function self.gMBtnUButton.luaClick()
		if Utils.enableClientUseGm(pg.me) then
			pg.global.ui.config:open()
		end
	end

	self.gMBtnUButton:SetActive(Utils.enableClientUseGm(pg.me))

	function self.listCurrencyUList.luaRenderItem(button, index, data)
		LuaUIUtils.setTopCurrencyItem(button, data.itemId, nil, nil, data.useSpecialStyle)

		self.currencySlotMap[data.itemId] = button
	end

	function self.innerListCurrencyUList.luaRenderItem(button, index, data)
		LuaUIUtils.setTopCurrencyItem(button, data.itemId, nil, nil, data.useSpecialStyle)

		self.currencySlotMap[data.itemId] = button
	end

	if self.btnRiftInfoUButton then
		function self.btnRiftInfoUButton.luaClick()
			pg.global.ui:open(UIConst.UI_ID_FISSURE_INFO)
		end

		self:bindFuncBtnHotKey(self.btnRiftInfoUButton.gameObject, "riftInfoBind", "Hud/RiftBuffInfo")
	end

	if self.seasonBtnUButton then
		function self.seasonBtnUButton.luaClick()
			if not self:isSeasonEntryVisible() then
				return
			end

			pg.global.ui:open(UIConst.UI_ID_SEASON_LOBBY)
		end

		self:bindSeasonLobbyRedDot()
		self:bindFuncBtnHotKey(self.seasonBtnUButton.gameObject, "seasonLobbyBind", "Hud/SeasonLobby")
	end

	self.seasonActivityPopPending = self.model:isSeasonActivityPopPending() == true
	self.seasonEntryFlyPlaying = false

	self:refreshESCBtnState()
	self:refreshFuncListBtn()
	self:refreshSeasonBtnState()
	self:refreshTowerBtnState()
	self:refreshCurrency()
	self:refreshGamepadMenuKey()

	if pg.me.space and pg.me.space:isRogueEnv() then
		self:refreshEquipmentInfo()
	end

	if pg.me and pg.me.isInRiftMode and pg.me:isInRiftMode() then
		self:refreshRiftMode()
	end

	self:initDownloadProgressComponent()
end

function FuncListUIComponent:initDownloadProgressComponent()
	if not self.downloadBtnUContainer then
		return
	end

	if not pg.game.resourceDownload or not pg.game.resourceDownload:isXPartEnabled() then
		self:stopDownloadProgressComponent()

		return
	end

	self:stopDownloadProgressInitRetry()
	self:refreshDownloadLayout()
	self:setDownloadRootVisible(true)

	if self.downloadProgressComponent then
		if self.downloadBtnUContainer then
			self.downloadBtnUContainer:SetActive(true)
		end

		self:initDownloadGamepadKey()
		self.downloadProgressComponent:startRefresh()
		self.downloadProgressComponent:refreshDownloadProgress()

		return
	end

	if self.downloadProgressLoading then
		return
	end

	self.downloadProgressLoading = true

	self.downloadBtnUContainer:SetActive(true)
	self.downloadBtnUContainer:LoadDefaultUrlManually(function(content)
		self.downloadProgressLoading = false

		if not self.downloadBtnUContainer or not pg.game.resourceDownload or not pg.game.resourceDownload:isXPartEnabled() then
			self:stopDownloadProgressComponent()

			return
		end

		self.downloadProgressComponent = DownloadProgressComponent.new(self, content, {
			visibleChanged = function(visible)
				self:setDownloadRootVisible(visible)
				self:setDownloadKeyVisible(visible)
			end
		})

		self:initDownloadGamepadKey()
		self.downloadProgressComponent:startRefresh()
		self.downloadProgressComponent:refreshDownloadProgress()
	end)
end

function FuncListUIComponent:stopDownloadProgressInitRetry()
	if self.downloadProgressInitRetryTimer then
		self:killTimer(self.downloadProgressInitRetryTimer)

		self.downloadProgressInitRetryTimer = nil
	end

	self.downloadProgressInitRetryCount = nil
end

function FuncListUIComponent:initDownloadGamepadKey()
	local downloadButton = self.downloadProgressComponent and self.downloadProgressComponent.downloadBtnUButton
	local hudCtrl = self.ctrl and self.ctrl.ctrl

	if not downloadButton or not self.downloadKeyHotKeyContent or not self.downloadKeyProgressPress or not hudCtrl then
		return
	end

	local actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadDPadDown
	local progress = self.downloadKeyProgressPress

	self.downloadKeyHotKeyContent:SetHotKeyPaths(actionPath)
	hudCtrl:bindHotKeyWithProgress(actionPath, function()
		self:openResourceDownloadSetting()
		progress:ProgressToValue(0, nil, 0)
	end, downloadButton.gameObject, progress, function()
		progress:ProgressToValue(0, nil, 0)
	end, {
		passThrough = true
	})
end

function FuncListUIComponent:refreshDownloadGamepadKeyDisplay()
	if self.downloadKeyHotKeyContent then
		self.downloadKeyHotKeyContent:SetHotKeyPaths(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadDPadDown)
	end
end

function FuncListUIComponent:refreshDownloadLayout()
	if not self.downloadBtnUContainer or not self.downloadBtnUContainer.transform then
		return
	end

	local rectTransform = self.downloadBtnUContainer.transform
	local sizeDelta = rectTransform.sizeDelta

	if sizeDelta.y ~= 160 then
		rectTransform.sizeDelta = CS.UnityEngine.Vector2(sizeDelta.x, 160)
	end
end

function FuncListUIComponent:setDownloadRootVisible(visible)
	if not self.downloadBtnUContainer or not self.downloadBtnUContainer.transform then
		return
	end

	local parentTransform = self.downloadBtnUContainer.transform.parent

	if parentTransform and parentTransform.name == "DownloadBtn" then
		parentTransform.gameObject:SetActiveEx(visible == true)
	end
end

function FuncListUIComponent:setDownloadKeyVisible(visible)
	self.downloadVisible = visible == true

	if not self.downloadKeyGameObject and self.downloadBtnUContainer and self.downloadBtnUContainer.transform then
		local downloadBtnParent = self.downloadBtnUContainer.transform.parent
		local downloadKeyTransform = downloadBtnParent and downloadBtnParent:Find("Key")

		if downloadKeyTransform then
			self.downloadKeyGameObject = downloadKeyTransform.gameObject
		end
	end

	if self.downloadKeyGameObject then
		self.downloadKeyGameObject:SetActiveEx(self.downloadVisible and self:isGamepadInteraction())
	end
end

function FuncListUIComponent:openResourceDownloadSetting()
	local packId = pg.game.resourceDownload and pg.game.resourceDownload:getCurrentDownloadingPackId()

	pg.global.ui:open(UIConst.UI_ID_SETTING, {
		selectedTabName = "resource",
		selectedPackId = packId
	})
end

function FuncListUIComponent:stopDownloadProgressComponent()
	if self.downloadProgressComponent then
		self.downloadProgressComponent:stopRefresh()
	end

	if self.downloadBtnUContainer then
		self.downloadBtnUContainer:SetActive(false)
	end

	self:setDownloadRootVisible(false)
	self:setDownloadKeyVisible(false)
end

function FuncListUIComponent:onResourceDownloadStateChanged()
	self:initDownloadProgressComponent()
end

function FuncListUIComponent:setEquipmentVisible(visible)
	if not self.equipmentUContainer then
		return
	end

	self.equipmentVisible = visible

	if not visible then
		self.equipmentLoading = false
		self.equipmentLoadVersion = (self.equipmentLoadVersion or 0) + 1
		self.equipmentUList = nil
		self.equipmentUWidget = nil

		self.equipmentUContainer:DestroyContent()
		self.equipmentUContainer:SetActive(false)

		return
	end

	self.equipmentUContainer:SetActive(true)

	if self.equipmentUList then
		self:refreshEquipmentInfo()

		return
	end

	if self.equipmentLoading then
		return
	end

	self.equipmentLoading = true
	self.equipmentLoadVersion = (self.equipmentLoadVersion or 0) + 1

	local loadVersion = self.equipmentLoadVersion

	self.equipmentUContainer:LoadDefaultUrlManually(function(content)
		if loadVersion ~= self.equipmentLoadVersion then
			return
		end

		self.equipmentLoading = false

		if not self.equipmentVisible or not content then
			if self.equipmentUContainer then
				self.equipmentUContainer:DestroyContent()
			end

			return
		end

		self.equipmentUWidget = content

		local objectReference = content:GetComponent("ObjectReference")

		self.equipmentUList = objectReference:GetRefValue("listUList")

		function self.equipmentUList.luaRenderItem(button, index, data)
			self:renderEquipmentItem(button, index, data)
		end

		self:refreshEquipmentInfo()
	end)
end

function FuncListUIComponent:refreshGamepadMenuKey()
	self.towerKeyHotKeyContent:SetHotKeyPaths("Hud/GamepadMenu")

	local towerKey = self.towerKeyUButton and self.towerKeyUButton.gameObject

	if towerKey then
		pg.global.ui.tips:redirectShortCutKey(towerKey, "Hud/GamepadMenu")
	end
end

function FuncListUIComponent:openFuncMenu(selectedFuncID, cb)
	if not self:getEscBtnVisible() then
		return
	end

	if not pg.me or not pg.me.space or not pg.pawn then
		return
	end

	if pg.me.space and pg.me.space:isPvpEnv() then
		return
	end

	pg.me:forceExitCaptureMode()

	if not pg.pawn:checkStatus(ConflictTypes.CT_FUNC_MENU) then
		pg.global.ui.tips:showTextTip(pg.getGameString("FUNCTION_CANT_STATE"))

		return
	end

	pg.global.ui:open(UIConst.UI_ID_FUNC_MENU, {
		selectedFuncID = selectedFuncID
	}, function()
		if cb then
			cb()
		end
	end)
end

function FuncListUIComponent:renderFuncList(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local icon = objectReference:GetRefValue("iconUImage")
	local txtName = objectReference:GetRefValue("txtNameUBaseText")

	self.funcButton[data.id] = button
	button.gameObject.name = data.functionType or tostring(data.id)
	icon.url = data.icon

	ClientTextUtils.setText(txtName, data.name)

	if data.id == Const.FUNCTION_IDS.CASHSHOP then
		function button.luaRenderTooltip(_, popup)
			self:renderLotteryCashTooltip(popup)
		end
	else
		button.luaRenderTooltip = nil
	end

	function button.luaClick()
		if data.btnClickFunc then
			if data.id == 184 then
				local surveyRedDot = pg.global.ui.Survey.model:getSurveyItemNum()

				if surveyRedDot then
					data.btnClickFunc()
				else
					pg.global.ui.tips:showTextTip(pg.getGameString("NO_SURVEY"))
				end
			else
				data.btnClickFunc()
			end
		end
	end

	if data.id == Const.FUNCTION_IDS.ACTIVITYCENTER then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.FUNC_MENU_EVENT, button, function()
			return ClientActivityUtils.getEventRedDotStyle()
		end)
	elseif data.id == Const.FUNCTION_IDS.SCHOOLGUIDE then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.SCHOOL_GUIDE, button, function()
			return LuaUIUtils.getSchoolGuideRedDotStyle()
		end)
	elseif data.id == Const.FUNCTION_IDS.CASHSHOP then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.FUNC_MENU_CASH_SHOP, button, function()
			return CashShopRedDotUtils.getCashShopEntryRedDotStyle()
		end)
	elseif data.id == Const.FUNCTION_IDS.BATTLEPASS then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.FUNC_MENU_BATTLEPASS, button, function()
			return CashShopRedDotUtils.getBattlePassHudRedDotStyle()
		end)
	elseif data.id == Const.FUNCTION_IDS.SPECIALTRAIN then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.SPECIAL_TRAIN_BTN, button, function()
			return pg.global.ui.SpecialTrainNew.model:redDot_GetSpecialTrainState()
		end)
	elseif data.id == Const.FUNCTION_IDS.HOME_BOOK then
		HomeBookRedDotUtils.bindHud(button)
	elseif data.functionType == "homelandSeason" then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.HOME_SEASON, button, function()
			return HomeSeasonUtils.getProgressRewardRedDotStyle(pg.me)
		end)
	elseif data.functionType == "petTravel" then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.HOME_CAMP_DISPATCH_REWARD, button, function()
			return self:getHomeCampDispatchRewardRedDotStyle()
		end)
		pg.global.refreshRedDotState(RedDotConst.RedDotPath.HOME_CAMP_DISPATCH_REWARD)
	else
		button:ClearRedDot()
	end

	pg.global.ui.funcMenu:bind_RedDotForMenuItem(button, data, true)

	if data.actionPath then
		self:bindFuncBtnHotKey(button.gameObject, FUNC_LIST_ITEM_HOTKEY_BIND_NAME, data.actionPath)
	else
		local existingBind = KeyBindingPro.GetKeyBindingByName(button.gameObject, FUNC_LIST_ITEM_HOTKEY_BIND_NAME)

		if existingBind then
			existingBind.actionPath = ""
		end
	end

	self:refreshFuncBtnState(button, data.id)
end

function FuncListUIComponent:onSystemFunctionUnlocked()
	self:refreshFuncListBtnState()
end

function FuncListUIComponent:onSystemFunctionShielded()
	self:refreshFuncListBtnState()
end

function FuncListUIComponent:onSystemFunctionLocked()
	self:refreshFuncListBtnState()
end

function FuncListUIComponent:onEventRefreshRedDot()
	self:refreshFuncListBtn()
	self:refreshSeasonBtnState()
	self:refreshSeasonLobbyRedDot()
end

function FuncListUIComponent:onShow()
	self:scheduleLotteryCashTooltipCheck()
end

function FuncListUIComponent:onHide()
	self:closeLotteryCashTooltip()
end

function FuncListUIComponent:onHomeSeasonChanged()
	self:refreshFuncListBtn()
end

function FuncListUIComponent:onHomeSeasonRedDotChanged()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.HOME_SEASON)
end

function FuncListUIComponent:getHomeCampDispatchState()
	local uid = pg.me and pg.me.uid
	local campCarEnt = uid and HomeLandUtils.getCampCarEntity(uid)
	local dispatchInfo = campCarEnt and campCarEnt:getPetsDispatchInfo()

	if not dispatchInfo then
		return UIConst.HOME_CAMP_DISPATCH_STATE.UnDispatch
	end

	return campCarEnt:getCampPetDispatchState()
end

function FuncListUIComponent:getHomeCampDispatchRewardRedDotStyle()
	if self:getHomeCampDispatchState() == UIConst.HOME_CAMP_DISPATCH_STATE.Finished then
		return RedDotConst.RedDotStyle.REWARD
	end

	return RedDotConst.RedDotStyle.NONE
end

function FuncListUIComponent:onHomeCampDispatchStateChanged()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.HOME_CAMP_DISPATCH_REWARD)
end

function FuncListUIComponent:onSceneLoaded()
	self:refreshFuncListBtn(true)
	self:scheduleLotteryCashTooltipCheck()
	self:refreshSeasonBtnState()
	self:refreshSeasonLobbyRedDot()
	self:refreshCurrency()
end

function FuncListUIComponent:onLotteryLoadingPanelHide(uid)
	if uid == UIConst.UI_ID_LOADING then
		self:scheduleLotteryCashTooltipCheck()
	end
end

function FuncListUIComponent:onFuncSwitchBtnClick()
	if not self.hasSpecialFunc then
		return
	end

	self.useSpecialFunc = not self.useSpecialFunc

	self:refreshFuncListBtn()
	self:refreshCurrencyLayoutState()
end

function FuncListUIComponent:onInputDeviceChanged()
	self:refreshDownloadGamepadKeyDisplay()

	if self:isGamepadInteraction() and self.hasSpecialFunc and not self.useSpecialFunc then
		self.useSpecialFunc = true

		self:refreshFuncListBtn()
		self:refreshCurrencyLayoutState()
		self:setDownloadKeyVisible(self.downloadVisible)

		return
	end

	self:refreshFuncSwitchBtnState()
	self:setDownloadKeyVisible(self.downloadVisible)
end

function FuncListUIComponent:onCashShopRewardChanged()
	CashShopRedDotUtils.refreshRedDot()
	self:refreshSeasonLobbyRedDot()
end

function FuncListUIComponent:bindSeasonLobbyRedDot()
	self.seasonBtnUButton:ClearRedDot()
	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.FUNC_MENU_SEASON_LOBBY, self.seasonBtnUButton, function()
		return pg.global.ui.SeasonLobby.model:getEntryRedDotStyle()
	end)
end

function FuncListUIComponent:refreshSeasonLobbyRedDot()
	if not self.seasonBtnUButton then
		return
	end

	pg.global.refreshRedDotState(RedDotConst.RedDotPath.FUNC_MENU_SEASON_LOBBY)
end

function FuncListUIComponent:onHomeBookDataChanged()
	local button = self.funcButton[Const.FUNCTION_IDS.HOME_BOOK]

	if button then
		HomeBookRedDotUtils.bindHud(button)
	end
end

function FuncListUIComponent:changeGmBtnVisible(visible)
	self.gMBtnUButton:SetActive(visible)
end

function FuncListUIComponent:onBossTitleVisibleChanged(info)
	if pg.me and pg.me.space and pg.me.space:isRogueEnv() then
		return
	end

	local bossTitleVisible = info and info.visible
	local isUIVisible = LuaUIUtils.isUIViewVisible(self.listFuncBtnUList)

	if isUIVisible ~= bossTitleVisible then
		return
	end

	if bossTitleVisible then
		self.rootPanel:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.User2, function()
			LuaUIUtils.setUIViewVisible(self.listFuncBtnUList, false)

			if self.seasonBtnUButton then
				LuaUIUtils.setUIViewVisible(self.seasonBtnUButton, false)
			end
		end)
	else
		LuaUIUtils.setUIViewVisible(self.listFuncBtnUList, true)

		if self.seasonBtnUButton then
			LuaUIUtils.setUIViewVisible(self.seasonBtnUButton, true)
		end

		self.rootPanel:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	end
end

function FuncListUIComponent:refreshTowerBtnState()
	if not pg.me or not pg.me.space then
		return
	end

	local isRogueEnv = pg.me.space:isRogueEnv()

	self:setEquipmentVisible(isRogueEnv)

	if not isRogueEnv then
		pg.game.weather:setTodTime(Const.TOD_TIME_KEY.ROGUE, false, 0, 0, 1)
	end
end

function FuncListUIComponent:refreshCurrency()
	table.clear(self.currencySlotMap)

	local outerCurrencyData = {}
	local innerCurrencyData = {}

	if pg.me and pg.me.space then
		local isRogueEnv = pg.me.space:isRogueEnv()

		if isRogueEnv then
			table.insert(outerCurrencyData, {
				itemId = RogueConst.CURRENCY_ITEM_ID
			})
		elseif pg.me.space.isSelfHomeland and pg.me.space:isSelfHomeland(pg.me) then
			table.insert(innerCurrencyData, {
				itemId = Const.HomeCoinItemId
			})
			table.insert(innerCurrencyData, {
				itemId = Const.HomeDecCoinItemId
			})
		end
	end

	self.listCurrencyUList:SetList(outerCurrencyData)
	self.innerListCurrencyUList:SetList(innerCurrencyData)

	self.hasOuterCurrency = #outerCurrencyData > 0
	self.hasInnerCurrency = #innerCurrencyData > 0

	self:refreshCurrencyLayoutState()
end

function FuncListUIComponent:refreshCurrencyLayoutState()
	self.layoutBoxListCurrency:SetActive(self.hasOuterCurrency)
	self.innerLayoutBoxListCurrency:SetActive(self.hasInnerCurrency and self.useSpecialFunc)
end

function FuncListUIComponent:onCurrencyChanged()
	if self.listCurrencyUList then
		self.listCurrencyUList:RefreshList()
	end

	if self.innerListCurrencyUList then
		self.innerListCurrencyUList:RefreshList()
	end

	self:refreshSeasonLobbyRedDot()
end

function FuncListUIComponent:refreshEquipmentInfo()
	if not self.equipmentUList or not self.equipmentVisible then
		return
	end

	local equipmentMaxCount = RogueUtils.getCurRogueLevelMaxEquipmentCount()
	local equipmentBuffs = {}
	local buffs = pg.me:getRogueBuffs()

	for _, buff in ipairs(buffs) do
		if buff.buffQuality == Const.RogueBuffQuality.Equipment then
			table.insert(equipmentBuffs, buff)
		end
	end

	for i = 1, equipmentMaxCount do
		if equipmentBuffs[i] then
			equipmentBuffs[i].tIndex = 0
		else
			equipmentBuffs[i] = {
				tIndex = 1
			}
		end
	end

	self.equipmentUList:SetList(equipmentBuffs)
end

function FuncListUIComponent:renderEquipmentItem(button, index, data)
	if data.tIndex == 0 then
		local objectReference = button:GetComponent("ObjectReference")
		local rootUComponent = objectReference:GetRefValue("rootUComponent")
		local iconEquipmentUImage = objectReference:GetRefValue("iconEquipmentUImage")

		rootUComponent:TryChangePage("ProgressBar", data.buffCount)

		iconEquipmentUImage.url = data.buffIcon
	end
end

function FuncListUIComponent:refreshFuncListBtnState()
	self.listFuncBtnUList:RefreshList()
	self:refreshSeasonBtnState()
	self:scheduleLotteryCashTooltipCheck()
end

function FuncListUIComponent:isSeasonEntryAvailable()
	if not self.model or not self.model:isSeasonEntryConfiguredByScene(self.useSpecialFunc) then
		return false
	end

	return self.model:isSeasonLobbyAvailable()
end

function FuncListUIComponent:isSeasonEntryVisible()
	return self:isSeasonEntryAvailable() and not self.seasonActivityPopPending and not self.seasonEntryFlyPlaying
end

function FuncListUIComponent:refreshSeasonBtnState()
	if not self.seasonBtnUButton then
		return
	end

	local available = self:isSeasonEntryAvailable()

	if not available and self.seasonEntryFlyPlaying then
		self:stopSeasonEntryFly()
	end

	local visible = self:isSeasonEntryVisible()

	self.seasonBtnUButton:SetActive(available)

	self.seasonBtnUButton.renderOpacity = visible and 1 or 0
	self.seasonBtnUButton.interactable = visible
end

function FuncListUIComponent:onSeasonActivityPopPendingChanged(body)
	self.seasonActivityPopPending = body ~= nil and body.pending == true

	self:refreshSeasonBtnState()
end

function FuncListUIComponent:canPlaySeasonEntryFly(sourcePosition)
	if not sourcePosition or not self:isSeasonEntryVisible() or IsNil(self.seasonBtnUButton) then
		return false
	end

	if not self.seasonBtnUButton.gameObject.activeInHierarchy or self.seasonBtnUButton.renderOpacity <= 0 then
		return false
	end

	return NotNil(self.seasonAnimationUWidget) and NotNil(self.seasonAnimationOriginalParent) and NotNil(self.rootPanel)
end

function FuncListUIComponent:refreshSeasonBtnAndPlayShowAnimation()
	if not self.seasonBtnUButton then
		return
	end

	self:refreshSeasonBtnState()

	if self.seasonBtnUButton.gameObject.activeInHierarchy and self.seasonBtnUButton.renderOpacity > 0 then
		self.seasonBtnUButton:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end
end

function FuncListUIComponent:onSeasonActivityPopFly(body)
	self.seasonActivityPopPending = false

	self:stopSeasonEntryFly()

	local sourcePosition = body and body.sourcePosition

	if not self:canPlaySeasonEntryFly(sourcePosition) then
		self:refreshSeasonBtnAndPlayShowAnimation()

		return
	end

	self.seasonEntryFlyPlaying = true

	self:refreshSeasonBtnState()

	local animationTransform = self.seasonAnimationUWidget.transform
	local targetPosition = animationTransform.position

	animationTransform:SetParent(self.rootPanel.transform, true)
	animationTransform:SetAsLastSibling()

	animationTransform.position = sourcePosition

	self.seasonAnimationUWidget:SetActive(true)
	self:startSeasonEntryFlyNextFrame(animationTransform, targetPosition)
end

function FuncListUIComponent:startSeasonEntryFlyNextFrame(animationTransform, targetPosition)
	self.seasonEntryFlyFrameId = TimerManager.addNextFrameCb(function()
		self.seasonEntryFlyFrameId = nil

		if not self.ctrl then
			return
		end

		if IsNil(self.seasonAnimationUWidget) or IsNil(animationTransform) then
			self:onSeasonEntryFlyComplete()

			return
		end

		DoTweenAnimMgr.GlobalMove(animationTransform, SEASON_ENTRY_FLY_TWEEN_ID, targetPosition, SEASON_ENTRY_FLY_DURATION, 0, SEASON_ENTRY_FLY_EASE, nil, function()
			self:onSeasonEntryFlyComplete()
		end, false)
	end)
end

function FuncListUIComponent:onSeasonEntryFlyComplete()
	self.seasonEntryFlyPlaying = false

	self:resetSeasonEntryFlyVisual()
	self:refreshSeasonBtnAndPlayShowAnimation()
end

function FuncListUIComponent:resetSeasonEntryFlyVisual()
	if IsNil(self.seasonAnimationUWidget) then
		return
	end

	if NotNil(self.seasonAnimationOriginalParent) then
		local animationTransform = self.seasonAnimationUWidget.transform

		animationTransform:SetParent(self.seasonAnimationOriginalParent, false)
		animationTransform:SetSiblingIndex(self.seasonAnimationOriginalSiblingIndex)

		animationTransform.anchoredPosition3D = self.seasonAnimationOriginalAnchoredPosition
		animationTransform.localRotation = self.seasonAnimationOriginalRotation
		animationTransform.localScale = self.seasonAnimationOriginalScale
	end

	self.seasonAnimationUWidget:SetActive(false)
end

function FuncListUIComponent:stopSeasonEntryFly()
	self.seasonEntryFlyPlaying = false

	if self.seasonEntryFlyFrameId then
		TimerManager.delFrameCb(self.seasonEntryFlyFrameId)

		self.seasonEntryFlyFrameId = nil
	end

	if NotNil(self.seasonAnimationUWidget) then
		DoTweenAnimMgr.Kill(self.seasonAnimationUWidget.gameObject, SEASON_ENTRY_FLY_TWEEN_ID, false)
	end

	self:resetSeasonEntryFlyVisual()
end

function FuncListUIComponent:refreshFuncListBtn(resetToSpecial)
	if not self.listFuncBtnUList then
		return
	end

	local playerSpace = pg.me and pg.me.space
	local sceneId = playerSpace and playerSpace.sceneId or 0
	local hasSpecialFunc = self.model:hasSpecialFunctionButtonByScene()

	if resetToSpecial or self.funcListSceneId ~= sceneId then
		self.funcListSceneId = sceneId
		self.useSpecialFunc = hasSpecialFunc
	elseif not hasSpecialFunc then
		self.useSpecialFunc = false
	end

	self.hasSpecialFunc = hasSpecialFunc

	self.uWidget:TryChangePage("FunState", hasSpecialFunc and 1 or 0)

	local isNpcDuel = playerSpace and playerSpace:isNpcDuel()

	self.layoutBoxAllTransform.gameObject:SetActiveEx(not BossRushUtils.isInBossRushBattleLevel() and not isNpcDuel)
	self:refreshFuncSwitchBtnState()
	self:refreshSeasonBtnState()

	local btnList = self.model:getFunctionButtonByScene(nil, self.useSpecialFunc)

	if self:isFuncListUnchanged(btnList) then
		self:refreshFuncListBtnState()
		self:scheduleLotteryCashTooltipCheck()

		return
	end

	self.cachedFuncIds = self:extractFuncIds(btnList)

	self:closeLotteryCashTooltip()

	self.funcButton = {}

	self.listFuncBtnUList:SetActive(#btnList > 0)
	self.listFuncBtnUList:SetList(btnList)
	self:scheduleLotteryCashTooltipCheck()
end

function FuncListUIComponent:getNextLotteryCashTooltip()
	if not LotteryUtils.isEnabled() then
		return nil, nil
	end

	local latestEntry, latestOpenTime, latestDrawId, nextOpenTime
	local now = Time.getSecond()

	for drawId, entry in pairs(GachaEntryData) do
		if Utils.isTable(entry) and entry.tipsIcon and entry.tipsIcon ~= "" and (tonumber(entry.tipsTime) or 0) > 0 then
			local openTime = Utils.getConfigTimeOfArea(entry, "openTime")
			local closeTime = Utils.getConfigTimeOfArea(entry, "closeTime")

			if openTime and closeTime and openTime <= closeTime and now < openTime then
				if not nextOpenTime or openTime < nextOpenTime then
					nextOpenTime = openTime
				end
			elseif openTime and closeTime and openTime <= now and now <= closeTime then
				local numericDrawId = tonumber(drawId) or 0
				local recordKey = self:getLotteryCashTooltipRecordKey(drawId, openTime)

				if not pg.global.prefsCacheUtils:getBool(recordKey, false, ClientConst.CACHE_TYPE_FLAG.PUBLIC) and (not latestOpenTime or latestOpenTime < openTime or openTime == latestOpenTime and latestDrawId < numericDrawId) then
					latestEntry = {
						drawId = drawId,
						config = entry,
						openTime = openTime
					}
					latestOpenTime = openTime
					latestDrawId = numericDrawId
				end
			end
		end
	end

	return latestEntry, nextOpenTime
end

function FuncListUIComponent:getLotteryCashTooltipRecordKey(drawId, openTime)
	return string.format(LOTTERY_TOOLTIP_RECORD_KEY, tostring(drawId), tostring(openTime))
end

function FuncListUIComponent:scheduleLotteryCashTooltipCheck()
	if self._lotteryTooltipCheckFrameId then
		return
	end

	self._lotteryTooltipCheckFrameId = TimerManager.addNextFrameCb(function()
		self._lotteryTooltipCheckFrameId = nil

		self:checkLotteryCashTooltip()
	end)
end

function FuncListUIComponent:checkLotteryCashTooltip()
	if not self:checkUIShow() or self._lotteryTooltipEntry then
		return
	end

	if pg.game.loading and not pg.game.loading:isFinished() or pg.global.ui:checkUIShow(UIConst.UI_ID_LOADING) then
		return
	end

	local entry, nextOpenTime = self:getNextLotteryCashTooltip()

	if self._lotteryTooltipOpenTimer then
		self:killTimer(self._lotteryTooltipOpenTimer)

		self._lotteryTooltipOpenTimer = nil
	end

	if nextOpenTime then
		self._lotteryTooltipOpenTimer = self:startTimer(function()
			self._lotteryTooltipOpenTimer = nil

			self:scheduleLotteryCashTooltipCheck()
		end, math.max(0.1, nextOpenTime - Time.getSecond() + 1))
	end

	local button = self.funcButton[Const.FUNCTION_IDS.CASHSHOP]

	if not entry or not button or not button.gameObject.activeInHierarchy then
		return
	end

	if not entry.config.tipsIcon or entry.config.tipsIcon == "" or (tonumber(entry.config.tipsTime) or 0) <= 0 then
		return
	end

	self:openLotteryCashTooltip(entry)
end

function FuncListUIComponent:openLotteryCashTooltip(entry)
	local button = self.funcButton[Const.FUNCTION_IDS.CASHSHOP]

	if not button or not button.gameObject.activeInHierarchy or not self:checkUIShow() then
		return false
	end

	self:closeLotteryCashTooltip()

	self._lotteryTooltipEntry = entry
	self._lotteryTooltipButton = button

	button:OpenTooltip()

	return true
end

function FuncListUIComponent:renderLotteryCashTooltip(popup)
	local entry = self._lotteryTooltipEntry

	if not entry or not self:checkUIShow() then
		return
	end

	local objectReference = popup:GetComponent("ObjectReference")
	local progressUProgress = objectReference:GetRefValue("progressUProgress")
	local npcUImage = objectReference:GetRefValue("npcUImage")
	local duration = tonumber(entry.config.tipsTime) or 0

	if not progressUProgress or not npcUImage or duration <= 0 then
		self:closeLotteryCashTooltip()

		return
	end

	npcUImage.url = entry.config.tipsIcon
	progressUProgress.minValue = 0
	progressUProgress.maxValue = 1
	progressUProgress.value = 1

	progressUProgress:ProgressToValue(0, nil, duration, 0, LOTTERY_TOOLTIP_EASE)

	local recordKey = self:getLotteryCashTooltipRecordKey(entry.drawId, entry.openTime)

	pg.global.prefsCacheUtils:setBoolImmediately(recordKey, true, ClientConst.CACHE_TYPE_FLAG.PUBLIC)

	if self._lotteryTooltipHideTimer then
		self:killTimer(self._lotteryTooltipHideTimer)
	end

	self._lotteryTooltipHideTimer = self:startTimer(function()
		self._lotteryTooltipHideTimer = nil

		self:closeLotteryCashTooltip()
		self:scheduleLotteryCashTooltipCheck()
	end, duration)
end

function FuncListUIComponent:closeLotteryCashTooltip()
	if self._lotteryTooltipHideTimer then
		self:killTimer(self._lotteryTooltipHideTimer)

		self._lotteryTooltipHideTimer = nil
	end

	if self._lotteryTooltipButton then
		self._lotteryTooltipButton:CloseTooltip()

		self._lotteryTooltipButton = nil
	end

	self._lotteryTooltipEntry = nil
end

function FuncListUIComponent:isGamepadInteraction()
	return pg.global.ui:runPlatformByConsole() or pg.game.input:isUsingGamepad()
end

function FuncListUIComponent:refreshFuncSwitchBtnState()
	if not self.btnSwitchUButton then
		return
	end

	self.btnSwitchUButton:SetActive(self.hasSpecialFunc == true and not self:isGamepadInteraction())
end

function FuncListUIComponent:extractFuncIds(btnList)
	local ids = {}

	for i, v in ipairs(btnList) do
		ids[i] = v.id
	end

	return ids
end

function FuncListUIComponent:isFuncListUnchanged(btnList)
	local cached = self.cachedFuncIds

	if not cached then
		return false
	end

	if #cached ~= #btnList then
		return false
	end

	for i, v in ipairs(btnList) do
		if cached[i] ~= v.id then
			return false
		end
	end

	return true
end

function FuncListUIComponent:refreshFuncBtnState(button, id)
	if not pg.me or not pg.me.space then
		return
	end

	local visible = LuaUIUtils.checkFuncCanOpen(id)

	if pg.me.space:isRogueEnv() and not ROGUE_FUNC_LIST_IDS[id] then
		visible = false
	end

	if button ~= nil then
		button:SetActive(visible)
	end
end

function FuncListUIComponent:bindFuncBtnHotKey(gameObject, keyBindingName, actionPath)
	local keyBindingPro = KeyBindingPro.GetOrAddKeyBindingByName(gameObject, keyBindingName)

	if keyBindingPro.actionPath == actionPath then
		return
	end

	local objectReference = keyBindingPro:GetComponent("ObjectReference")
	local hotKeyContent = objectReference:GetRefValue("keyHotKeyContent")

	keyBindingPro.keyBoardContent = hotKeyContent
	keyBindingPro.actionPath = actionPath
end

function FuncListUIComponent:getEscBtnVisible()
	if not pg.game:checkModuleEnable(ClientConst.ModuleKey.Esc) then
		return false
	end

	return true
end

function FuncListUIComponent:onQuestStateChanged(info)
	if MonthCardUtils.isPreorderGuideTriggerMatched(info.questId, info.state) then
		self:refreshFuncListBtn()
	end

	local questConfig = QuestUtils.getQuestConfig(info.questId)

	if questConfig.questType == QuestConst.QUEST_TYPE.SPECIAL_TRAIN then
		self:refreshSpecialTrainRedDot()
	end
end

function FuncListUIComponent:refreshSpecialTrainRedDot()
	if self.view and self.funcButton[Const.FUNCTION_IDS.SPECIALTRAIN] and pg.me.isSpecialTrainOpen then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.SPECIAL_TRAIN_BTN, self.funcButton[Const.FUNCTION_IDS.SPECIALTRAIN], function()
			return pg.global.ui.SpecialTrainNew.model:redDot_GetSpecialTrainState()
		end)
	end
end

function FuncListUIComponent:refreshRiftMode()
	self:refreshESCBtnState()

	local riftVisible = false

	if pg.me and pg.me.isInRiftMode then
		riftVisible = pg.me:isInRiftMode()
	end

	if riftVisible and self.seasonEntryFlyPlaying then
		self:stopSeasonEntryFly()
	end

	if self.btnRiftInfoUButton then
		self.btnRiftInfoUButton:SetActive(riftVisible)
		self.listFuncBtnUList:SetActive(not riftVisible)
	end

	self:refreshSeasonBtnState()

	if not riftVisible then
		self:refreshFuncListBtnState()
	end
end

function FuncListUIComponent:onDestroy()
	self:closeLotteryCashTooltip()

	if self._lotteryTooltipCheckFrameId then
		TimerManager.delFrameCb(self._lotteryTooltipCheckFrameId)

		self._lotteryTooltipCheckFrameId = nil
	end

	if self._lotteryTooltipOpenTimer then
		self:killTimer(self._lotteryTooltipOpenTimer)

		self._lotteryTooltipOpenTimer = nil
	end

	self:stopSeasonEntryFly()

	self.seasonActivityPopPending = false

	self:setEquipmentVisible(false)

	self.gamepadMenuKeyProgressPress = nil
	self.downloadKeyProgressPress = nil

	self:stopDownloadProgressInitRetry()

	self.downloadProgressLoading = nil
	self.downloadProgressComponent = nil

	HudBaseComponent.onDestroy(self)
end

function FuncListUIComponent:refreshPlayerRedDot()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.FUNC_MENU)
end

function FuncListUIComponent:playShowAnim()
	if self.uWidget then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Show)
	end
end

function FuncListUIComponent:playHideAnim()
	if self.uWidget then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Hide)
	end
end

return FuncListUIComponent
