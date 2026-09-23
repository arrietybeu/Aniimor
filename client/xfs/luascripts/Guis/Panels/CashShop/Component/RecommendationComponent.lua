-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashShop\\Component\\RecommendationComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("RecommendationComponent")
local Class = require("Core.Framework.Class")
local CashShopContainerComponent = require("Guis.Panels.CashShop.Component.CashShopContainerComponent")
local TimerManager = require("Core.Timer.TimerManager")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local LotteryUtils = require("Utils.LotteryUtils")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local Utils = require("Common.Utils.Utils")
local ActivityConst = require("Common.Const.ActivityConst")
local BattlePassData = require("Data.event_battlepass_data")
local GachaEntryData = require("Data.gacha_entry_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local CashShopConst = require("Const.CashShopConst")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local RedDotConst = require("Const.RedDotConst")
local MessageName = require("Const.MessageName")
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local FirstTopupCardRenderer = require("Guis.Panels.Event.Component.FirstTopupCardRenderer")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local ClientUtils = require("Utils.ClientUtils")
local CashShopRedDotUtils = require("Utils.CashShopRedDotUtils")
local SysConfigData = require("Data.sys_config_data")
local Time = require("Core.Common.Time")
local TimeUtils = require("Common.Utils.TimeUtils")
local RecommendationComponent = Class.LightClass("RecommendationComponent", CashShopContainerComponent)

RecommendationComponent.messages = {
	[MessageName.MONTH_CARD_ACTIVATE] = {
		"setMonthEventState",
		true
	},
	[MessageName.CASH_SHOP_REWARD_CHANGED] = {
		"refreshCommodChangeInfo",
		true
	},
	[MessageName.EVENT_REFRESH_REDDOT] = {
		"onEventRedDotRefresh",
		true
	}
}
RecommendationComponent.BANNER_AUTO_SCROLL_INTERVAL = 5

function RecommendationComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	CashShopContainerComponent.findObjects(self)

	local objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")

	self.listUList = objectReference:GetRefValue("listUList")
	self.imgBG = objectReference:GetRefValue("imgBG")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.txtBPName = objectReference:GetRefValue("txtBPName")
	self.txtBPPetName = objectReference:GetRefValue("txtBPPetName")
	self.txtBPPetIcon = objectReference:GetRefValue("txtBPPetIcon")
	self.petQualityUComponent = objectReference:GetRefValue("petQualityUComponent")
	self.petItemListUList = objectReference:GetRefValue("petItemListUList")
	self.txtBPBuff = objectReference:GetRefValue("txtBPBuff")
	self.btnGoBP = objectReference:GetRefValue("btnGoBP")
	self.txtBtnGoBP = objectReference:GetRefValue("txtBtnGoBP")
	self.btnBPEgg = objectReference:GetRefValue("btnBPEgg")
	self.firstTopupComponent = objectReference:GetRefValue("firstTopupComponent")
end

function RecommendationComponent:addListener()
	if not self:checkContentLoaded() then
		return
	end

	CashShopContainerComponent.addListener(self)

	function self.listUList.luaRenderItem(button, index, data)
		if data.tIndex == 0 then
			self:renderRecommendLoop(button, index, data)
		else
			self:renderItem(button, index, data)
		end
	end

	if self.btnGoBP then
		function self.btnGoBP.luaClick()
			if not ClientCashShopUtils.canOpenBattlePass() then
				return
			end

			if pg.global.platform:isPS() and RechargeUtils.isEmptyStore() then
				PlatformBridgeLuaFacade.ShowCommonMessageDialogEmptyStore()

				return
			end

			pg.global.ui:open(UIConst.UI_ID_BP_PURCHASE)
		end
	end

	if self.btnBPEgg then
		function self.btnBPEgg.luaClick()
			local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)

			if not actData then
				return
			end

			local phase = actData.activityBase and actData.activityBase.activityPhase
			local bpData = phase and BattlePassData[phase]

			if not bpData then
				return
			end

			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
				id = bpData.passPetEggId,
				targetRect = self.btnBPEgg,
				originData = {
					hideCount = true
				}
			})
		end
	end
end

function RecommendationComponent:_shouldShowProductTabWidget(data, commodityInfo)
	return false
end

function RecommendationComponent:isSpecialSceneData(data)
	return data and data.bgType == CashShopConst.BgType.SPECIAL_SCENE or false
end

function RecommendationComponent:_getSpecialSceneRes(data)
	if not self:isSpecialSceneData(data) then
		return nil
	end

	local sceneRes = data.exScene or data.showPic

	if not sceneRes then
		logger:error("推荐配置 bgType=3 但未配置特殊场景资源, id=%s", tostring(data.id))
	end

	return sceneRes
end

function RecommendationComponent:_getSpecialSceneTimelineRes(data)
	if not self:isSpecialSceneData(data) then
		return nil
	end

	local timelineRes = data.sceneTimeLine

	if type(timelineRes) == "string" then
		timelineRes = timelineRes:match("^%s*(.-)%s*$")

		if timelineRes ~= "" and timelineRes ~= "0" then
			return timelineRes
		end
	end

	return CashShopConst.DEFAULT_SPECIAL_SCENE_TIMELINE
end

function RecommendationComponent:getInitialSpecialSceneRes()
	local entries = self:_sortRecommendationListByCommodityState(self.model:getRecommendationLists())
	local firstEntry = entries and entries[1]

	if firstEntry and firstEntry.tIndex == 0 then
		firstEntry = firstEntry.bannerList and firstEntry.bannerList[1]
	end

	return self:_getSpecialSceneRes(firstEntry)
end

function RecommendationComponent:refreshCommodInfo(data)
	local specialSceneRes = self:_getSpecialSceneRes(data)
	local specialSceneTimelineRes = self:_getSpecialSceneTimelineRes(data)

	if self.ctrl and self.ctrl.tryAutoHideInitialLotteryRecommendation then
		self.ctrl:tryAutoHideInitialLotteryRecommendation(data)
	end

	local targetSceneRes = self.ctrl and self.ctrl:_normalizeCashShopExSceneRes(specialSceneRes)

	if targetSceneRes and self.ctrl._cashShopExSceneRes ~= targetSceneRes then
		self.ctrl:_setCashShopExSceneBlackScreenVisible(true)
	end

	if specialSceneRes then
		CashShopContainerComponent.refreshCommodInfo(self, data, function()
			if self._currentData ~= data or not self.ctrl or not self.ctrl.switchCashShopExScene then
				return
			end

			self.ctrl:switchCashShopExScene(specialSceneRes, specialSceneTimelineRes)
		end)
	else
		CashShopContainerComponent.refreshCommodInfo(self, data)
	end

	if not specialSceneRes and self.ctrl and self.ctrl.switchCashShopExScene then
		self.ctrl:switchCashShopExScene(nil, nil)
	end

	local showModle = data and data.showModle

	if self.productInformation then
		self.productInformation:setRecommendationBtnState(showModle)
	end

	if self.firstTopupComponent then
		self.firstTopupComponent.gameObject:SetActiveEx(data.showModle == CashShopConst.ShowModle.FirstTopup)
	end

	self._showingBP = showModle == CashShopConst.ShowModle.BattlePass
	self.haveCommerce = false

	if showModle == CashShopConst.ShowModle.BattlePass then
		if self.rootUComponent then
			self.rootUComponent:TryChangePage("Type", 2)
		end

		self:_refreshBPInfo()

		self.haveCommerce = false
	elseif showModle == CashShopConst.ShowModle.MonthCard then
		if self.rootUComponent then
			self.rootUComponent:TryChangePage("Type", 1)
		end

		local productInfo = RechargeUtils.getProductsInfo()

		LuaUIUtils.renderMonthCard(self.monthlyCard, function()
			self.ctrl:showFriendList(30023, productInfo)
		end)

		self.haveCommerce = true
	elseif showModle == CashShopConst.ShowModle.FirstTopup then
		self.haveCommerce = false

		if self.rootUComponent then
			self.rootUComponent:TryChangePage("Type", 0)
		end

		local isSpecialMode = data.showModle == CashShopConst.ShowModle.MonthCard or data.showModle == CashShopConst.ShowModle.BattlePass or data.showModle == CashShopConst.ShowModle.FirstTopup

		self.btnEllipsesUButton:SetActive(false)
		self.productInformationUComponent:SetActive(not isSpecialMode)

		if self.firstTopupComponent then
			self:_initFirstTopupRenderer()
			self:_refreshFirstTopupCards()
		end

		if CashShopRedDotUtils.markFirstTopupRead() then
			CashShopRedDotUtils.refreshFirstTopupRedDots()
		end
	else
		if self.rootUComponent then
			self.rootUComponent:TryChangePage("Type", 0)
		end

		self.haveCommerce = false
	end

	if PlatformBridgeLuaFacade.supportsCommerce() then
		if self.haveCommerce then
			self:ShowStoreIcon()
		else
			self:HideStoreIcon()
		end
	end

	if self.ctrl._refreshBPRotateConsoleBar then
		self.ctrl:_refreshBPRotateConsoleBar()
	end
end

function RecommendationComponent:onProductInformationDirectPurchase()
	if not self._currentData or self._currentData.showModle ~= CashShopConst.ShowModle.Lottery then
		return
	end

	local drawId = self._currentData.drawId

	if not drawId then
		logger:error("抽奖推荐配置缺少 drawId, recommendationId=%s", tostring(self._currentData.id))

		return
	end

	local entryConfig = GachaEntryData[tonumber(drawId)]

	if not entryConfig then
		logger:error("抽奖入口配置不存在, drawId=%s", tostring(drawId))

		return
	end

	if not LotteryUtils.isOpen(drawId) then
		pg.global.ui.tips:showTextTip(pg.getGameString("FUNCTION_NOT_OPEN"))

		return
	end

	if string.isNilOrEmpty(entryConfig.scene) then
		logger:error("抽奖入口配置缺少场景资源, drawId=%s", tostring(drawId))

		return
	end

	if self.ctrl and self.ctrl.prepareLotteryReturnPreview then
		self.ctrl:prepareLotteryReturnPreview()
	end

	pg.global.ui:changeUIScene(UIConst.UI_ID_LOTTERY, entryConfig.scene)
	pg.global.ui:open(UIConst.UI_ID_LOTTERY, {
		drawId = drawId,
		commodityId = self._currentData.commodityId
	})
end

function RecommendationComponent:isShowingBP()
	return self._showingBP == true
end

function RecommendationComponent:_initFirstTopupRenderer()
	if self._firstTopupCardRenderer then
		return
	end

	if not self.firstTopupComponent then
		logger:warn("_initFirstTopupRenderer: firstTopupComponent not found")

		return
	end

	local objectReference = self.firstTopupComponent:GetComponent("ObjectReference")

	if not objectReference then
		logger:warn("_initFirstTopupRenderer: ObjectReference not found")

		return
	end

	local contentUComponent = objectReference:GetRefValue("contentUComponent")

	if not contentUComponent then
		logger:warn("_initFirstTopupRenderer: contentUComponent not found")

		return
	end

	self._firstTopupCardRenderer = FirstTopupCardRenderer(contentUComponent, {
		onGotoShop = function()
			if self.ctrl then
				self.ctrl:navigateTo(CashShopConst.CategoryType.RECHARGE)
			end
		end,
		onItemClick = function(reward, button)
			self:_showFirstTopupItemInfo(reward, button)
		end
	})

	self._firstTopupCardRenderer:bindListeners(function(cardIndex)
		self:_onFirstTopupCardClick(cardIndex)
	end, function(reward, button)
		self:_showFirstTopupItemInfo(reward, button)
	end)
end

function RecommendationComponent:_refreshFirstTopupCards()
	if not self._firstTopupCardRenderer then
		logger:warn("_refreshFirstTopupCards: renderer not initialized")

		return
	end

	local hasTopup = self:_checkHasFirstTopup()

	self._firstTopupCardRenderer:setPageState(false, hasTopup)
	self:_refreshFirstTopupTitle()
	self._firstTopupCardRenderer:refreshStaticTexts()

	local rewardTasks = self:_getFirstTopupRewardTasks()
	local rewardTaskCount = rewardTasks and #rewardTasks or 0

	if rewardTaskCount < 3 then
		logger:warn("_refreshFirstTopupCards: insufficient reward tasks, count=" .. rewardTaskCount)

		return
	end

	self._firstTopupRewardTasks = rewardTasks

	local card1State = self._firstTopupCardRenderer:refreshCard1(rewardTasks[1])
	local card2State = self._firstTopupCardRenderer:refreshCard2Or3(rewardTasks[2], 2, card1State)

	self._firstTopupCardRenderer:refreshCard2Or3(rewardTasks[3], 3, card2State)
	self._firstTopupCardRenderer:refreshRewardRedDots(rewardTasks, function(index)
		return string.format(RedDotConst.RedDotPath.CASH_SHOP_FIRST_TOPUP_REWARD_ITEM, CashShopConst.CategoryType.RECOMMEND, index)
	end)
end

function RecommendationComponent:onEventRedDotRefresh()
	CashShopRedDotUtils.refreshFirstTopupRedDots()

	if self._currentData and self._currentData.showModle == CashShopConst.ShowModle.FirstTopup and self._firstTopupCardRenderer then
		self:_refreshFirstTopupCards()
	end
end

function RecommendationComponent:_refreshFirstTopupTitle()
	if not self.firstTopupComponent then
		return
	end

	local activityId = self:_getFirstTopupEventId()

	if not activityId then
		logger:warn("_refreshFirstTopupTitle: activity data not found")

		return
	end

	local GameEventData = require("Data.game_event_data")
	local eventConfig = GameEventData[activityId]

	if not eventConfig then
		logger:warn("_refreshFirstTopupTitle: event config not found for activityId=" .. activityId)

		return
	end

	local objectReference = self.firstTopupComponent:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local txtTitleUBaseText = objectReference:GetRefValue("txtTitleUBaseText")
	local txtTimeTitleText = objectReference:GetRefValue("txtTimeTitleText")
	local countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")
	local btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	local txtDetailsUSDFText = objectReference:GetRefValue("txtDetailsUSDFText")

	if txtTitleUBaseText and eventConfig.name then
		ClientTextUtils.setText(txtTitleUBaseText, pg.getLocalizationText(eventConfig.name))
	end

	if txtTimeTitleText then
		local timeTitle = pg.getGameString("EVENT_TIME_TIP_5")

		ClientTextUtils.setText(txtTimeTitleText, timeTitle)
	end

	if countDownUCountDown then
		local eventTimeConfig = Utils.getEventTimeConfig(activityId)
		local endTime = eventTimeConfig and eventTimeConfig.tabEndDayTime
		local currentTime = Time.secondCache or Time.getSecond()
		local remainTime = endTime and endTime - currentTime or 0

		if remainTime > 0 then
			countDownUCountDown:SetActive(true)
			LuaUIUtils.setCountDownTime(countDownUCountDown, endTime, UIConst.TimeType.Short)
		else
			countDownUCountDown:Stop()
			countDownUCountDown:SetActive(false)
		end
	end

	if btnInfoUButton and eventConfig.rule then
		local ruleText = pg.getLocalizationText(eventConfig.rule)

		if ruleText and ruleText ~= "" then
			function btnInfoUButton.luaClick()
				pg.global.ui.tips:openEventRuleDesc(ruleText)
			end

			btnInfoUButton:SetActive(true)
		else
			btnInfoUButton:SetActive(false)
		end
	elseif btnInfoUButton then
		btnInfoUButton:SetActive(false)
	end

	if txtDetailsUSDFText and eventConfig.eventDesc then
		ClientTextUtils.setText(txtDetailsUSDFText, pg.getLocalizationText(eventConfig.eventDesc))
	end
end

function RecommendationComponent:_getFirstTopupRewardTasks()
	local taskList = ClientActivityUtils.getTaskInfoByTaskType(ActivityConst.EventType.FirstTopup, ActivityConst.ActivityTaskType.Active_AchievementTask) or {}

	table.sort(taskList, function(a, b)
		if a.sort ~= b.sort then
			return a.sort < b.sort
		else
			return a.taskId < b.taskId
		end
	end)

	return taskList
end

function RecommendationComponent:_checkHasFirstTopup()
	local conditionId = SysConfigData.ACT_FIRST_CHARGE_QUALIFY_COND_ID

	if not conditionId or conditionId <= 0 then
		return false
	end

	return ClientUtils.checkCondition(conditionId)
end

function RecommendationComponent:_onFirstTopupCardClick(cardIndex)
	if not self._firstTopupRewardTasks or not self._firstTopupRewardTasks[cardIndex] then
		logger:warn("_onFirstTopupCardClick: invalid card index=" .. cardIndex)

		return
	end

	local taskData = self._firstTopupRewardTasks[cardIndex]
	local taskState = taskData.taskState
	local canReceive = taskState == ActivityConst.TaskState.Finihed_CanRecv

	if canReceive then
		local eventId = self:_getFirstTopupEventId()

		if eventId then
			pg.me:reqActReceiveTaskReward(taskData.taskId, eventId)
		else
			logger:warn("_onFirstTopupCardClick: eventId not found")
		end
	end
end

function RecommendationComponent:_getFirstTopupEventId()
	local isOpen, activityId = ActivityUtils.isOprActivityOpenByType(ActivityConst.EventType.FirstTopup, pg.me)

	if isOpen and activityId and activityId > 0 then
		return activityId
	end

	return nil
end

function RecommendationComponent:_showFirstTopupItemInfo(reward, button)
	if reward.petId then
		pg.global.ui:open(UIConst.UI_ID_PET_DETAIL, {
			templateId = reward.petId
		})
	else
		pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
			id = reward.id,
			targetRect = button,
			originData = {
				hideCount = true
			}
		})
	end
end

function RecommendationComponent:focusOnReward()
	local navMgr = pg.global.navMgr
	local focused = navMgr and navMgr.CurrentFocusedUContent

	if not focused or IsNil(focused) then
		return false
	end

	local components = focused.gameObject:GetComponentsInChildren(typeof(CS.XGUI.UComponent), false)

	for i = 0, components.Length - 1 do
		if components[i].name == "UI_Com_RedTag_Reward" then
			return true
		end
	end

	return false
end

function RecommendationComponent:registerFocusMove()
	if pg.global.navMgr then
		pg.global.navMgr:AddLuaFocusCursorMovedListener("RecommendationComponentFocusChange", function()
			if self.ctrl then
				self.ctrl:refreshConsoleBarState()
			end
		end)
	end
end

function RecommendationComponent:unRegisterFocusMove()
	if pg.global.navMgr then
		pg.global.navMgr:RemoveLuaFocusCursorMovedListener("RecommendationComponentFocusChange")
	end
end

function RecommendationComponent:_refreshBPInfo()
	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)

	if not actData then
		return
	end

	local phase = actData.activityBase and actData.activityBase.activityPhase
	local bpData = phase and BattlePassData[phase]

	if not bpData then
		return
	end

	if self.txtBPName then
		ClientTextUtils.setText(self.txtBPName, pg.getGameString("BATTLEPASS_MAIN_TITLE"))
	end

	if self.txtBPBuff then
		ClientTextUtils.setText(self.txtBPBuff, pg.getGameString("BATTLEPASS_POPUP_BUFF"))
	end

	if self.txtBtnGoBP then
		ClientTextUtils.setText(self.txtBtnGoBP, pg.getGameString("BATTLEPASS_POPUP_BOTTLE"))
	end

	if bpData.passPetEggId then
		if self.txtBPPetName then
			ClientTextUtils.setText(self.txtBPPetName, pg.getLocalizationText(bpData.passPetName))
		end

		if self.petQualityUComponent then
			local itemInfo = LuaUIUtils.getItemInfoById(bpData.passPetEggId)

			self.petQualityUComponent:TryChangePage("Quality", itemInfo and itemInfo.quality or 0)
		end
	end

	if self.petQualityUComponent then
		self.petQualityUComponent:TryChangePage("Quality", 3)

		local objectReference1 = self.petQualityUComponent:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference1:GetRefValue("txtNameUSDFText")

		if txtNameUSDFText then
			local ratingStr = Const.STAGE_TO_RATING_STR[4] or ""

			ClientTextUtils.setText(txtNameUSDFText, pg.getGameString(ratingStr))
		end
	end

	if self.petItemListUList and bpData.rewadPopup then
		local list = {}

		for _, entry in ipairs(bpData.rewadPopup) do
			list[#list + 1] = {
				id = entry[1],
				num = entry[2]
			}
		end

		function self.petItemListUList.luaRenderItem(btn, _, d)
			LuaUIUtils.renderRewardItem(btn, d)
		end

		self.petItemListUList:SetList(list)
	end

	local avatarComponent = self.ctrl and self.ctrl.avatarComponent

	if avatarComponent and bpData.passPetModelingId then
		local idx = CashShopConst.PetActionType.CashShop
		local movementIds = bpData.passPetMovementId
		local animKey = movementIds and movementIds[idx]
		local posXYZ = bpData.postionIndex and bpData.postionIndex[idx]
		local rotXYZ = bpData.rotationIndex and bpData.rotationIndex[idx]
		local scaleXYZ = bpData.scaleIndex and bpData.scaleIndex[idx]

		avatarComponent:showPetByModelingId(bpData.passPetModelingId, animKey, posXYZ, rotXYZ, scaleXYZ)
	end
end

function RecommendationComponent:refreshPage()
	if not self.listUList then
		return
	end

	local filtered = self.model:getRecommendationLists()

	filtered = self:_sortRecommendationListByCommodityState(filtered)

	local currentEntryKey = self:_getRecommendEntryKey(self._currentData) or self._selectedCommodityId and "commodity:" .. tostring(self._selectedCommodityId) or self._selectedRecommendationKey
	local selectedBannerKey = self._selectedBannerKey
	local hasBanner = #filtered > 0 and filtered[1].tIndex == 0
	local selectedData, selectedBannerIndex, selectedBannerSelectionIndex, selectedListCommodityId, selectedListEntryKey

	if currentEntryKey then
		if hasBanner then
			local bannerList = filtered[1].bannerList or {}

			for index, item in ipairs(bannerList) do
				if self:_getRecommendEntryKey(item) == currentEntryKey then
					selectedData = item
					selectedBannerIndex = index

					break
				end
			end
		end

		if not selectedData then
			for _, item in ipairs(filtered) do
				if item.tIndex ~= 0 and self:_getRecommendEntryKey(item) == currentEntryKey then
					selectedData = item
					selectedListCommodityId = item.commodityId
					selectedListEntryKey = currentEntryKey

					break
				end
			end
		end
	end

	if hasBanner and selectedBannerKey then
		local bannerList = filtered[1].bannerList or {}

		for index, item in ipairs(bannerList) do
			if self:_getRecommendEntryKey(item) == selectedBannerKey then
				selectedBannerSelectionIndex = index

				break
			end
		end
	end

	if not selectedData then
		if hasBanner then
			selectedBannerIndex = 1
			selectedData = filtered[1].bannerList and filtered[1].bannerList[1] or nil
		else
			selectedData = filtered[1]
			selectedListCommodityId = selectedData and selectedData.commodityId or nil
			selectedListEntryKey = self:_getRecommendEntryKey(selectedData)
		end
	end

	if hasBanner then
		local bannerList = filtered[1].bannerList or {}
		local shouldSelectBanner = selectedListEntryKey == nil

		if selectedBannerSelectionIndex == nil and #bannerList > 0 then
			if shouldSelectBanner then
				selectedBannerSelectionIndex = selectedBannerIndex or 1
			else
				selectedBannerSelectionIndex = math.max(1, math.min(self._selectedBannerIndex or 1, #bannerList))
			end
		end

		self._isBannerSelected = shouldSelectBanner
		self._bannerCurrentIndex = selectedBannerIndex or 1
		self._selectedBannerIndex = selectedBannerSelectionIndex

		local selectedBannerItem = selectedBannerSelectionIndex and bannerList[selectedBannerSelectionIndex] or nil

		self._selectedBannerKey = self:_getRecommendEntryKey(selectedBannerItem)
		self._selectedCommodityId = selectedListCommodityId
		self._selectedRecommendationKey = selectedListEntryKey
		self._selectedListIndex = nil

		if selectedListEntryKey then
			for index, item in ipairs(filtered) do
				if item.tIndex ~= 0 and self:_getRecommendEntryKey(item) == selectedListEntryKey then
					self._selectedListIndex = index - 1

					break
				end
			end
		end
	else
		self._isBannerSelected = false
		self._selectedCommodityId = selectedListCommodityId
		self._selectedRecommendationKey = selectedListEntryKey
		self._selectedListIndex = nil

		if selectedListEntryKey then
			for index, item in ipairs(filtered) do
				if self:_getRecommendEntryKey(item) == selectedListEntryKey then
					self._selectedListIndex = index - 1

					break
				end
			end
		end
	end

	self.listUList:SetList(filtered)

	if #filtered == 0 then
		self:_stopBannerAutoScroll()
		self:_unbindBannerScrollEnd()
		self:_clearPreviewBeforeDisplaySwitch("all")

		local avatarComponent = self.ctrl.avatarComponent

		if avatarComponent then
			avatarComponent:hideAllEntities()
		end

		if self.productInformationUComponent then
			self.productInformationUComponent:SetActive(false)
		end

		self._showingBP = false

		if self.ctrl and self.ctrl.switchCashShopExScene then
			self.ctrl:switchCashShopExScene(nil)
		end

		if self.ctrl._refreshBPRotateConsoleBar then
			self.ctrl:_refreshBPRotateConsoleBar()
		end

		return
	end

	if not hasBanner then
		self:_stopBannerAutoScroll()
		self:_unbindBannerScrollEnd()

		if selectedData then
			self:refreshCommodInfo(selectedData)
		end
	elseif not self._isBannerSelected and selectedData then
		self:refreshCommodInfo(selectedData)
	end
end

function RecommendationComponent:_getRecommendEntryKey(entry)
	if not entry then
		return nil
	end

	if entry.commodityId then
		return "commodity:" .. tostring(entry.commodityId)
	end

	if entry.id then
		return "recommend:" .. tostring(entry.id)
	end

	return nil
end

function RecommendationComponent:_isCurrentRecommendEntry(entry)
	local entryKey = self:_getRecommendEntryKey(entry)

	if not entryKey or entryKey ~= self:_getRecommendEntryKey(self._currentData) then
		return false
	end

	if entry._bannerIndex then
		return self._isBannerSelected == true and self._selectedBannerIndex == entry._bannerIndex
	end

	return self._isBannerSelected ~= true and self._selectedRecommendationKey == entryKey
end

function RecommendationComponent:_isSpecialRecommendEntry(entry)
	if not entry then
		return false
	end

	return entry.showModle == CashShopConst.ShowModle.MonthCard or entry.showModle == CashShopConst.ShowModle.BattlePass
end

function RecommendationComponent:_isSortableRecommendCommodity(entry)
	if not entry or entry.tIndex == 0 then
		return false
	end

	if self:_isSpecialRecommendEntry(entry) then
		return false
	end

	return entry.commodityId ~= nil
end

function RecommendationComponent:_sortRecommendationListByCommodityState(list)
	if not list or #list <= 1 then
		return list
	end

	local sortableEntries = {}

	for _, entry in ipairs(list) do
		if self:_isSortableRecommendCommodity(entry) then
			sortableEntries[#sortableEntries + 1] = entry
		end
	end

	if #sortableEntries <= 1 then
		return list
	end

	sortableEntries = self:_sortSoldOutToEnd(sortableEntries)

	local result = {}
	local sortableIndex = 1

	for _, entry in ipairs(list) do
		if self:_isSortableRecommendCommodity(entry) then
			result[#result + 1] = sortableEntries[sortableIndex]
			sortableIndex = sortableIndex + 1
		else
			result[#result + 1] = entry
		end
	end

	return result
end

function RecommendationComponent:renderRecommendLoop(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local bannerRayBoxTransform = button.transform:Find("RayBox")

	if NotNil(bannerRayBoxTransform) then
		bannerRayBoxTransform.gameObject:SetActiveEx(false)
	end

	local listUList = objectReference and objectReference:GetRefValue("listUList") or nil
	local listPagePointUList = objectReference and objectReference:GetRefValue("listPagePointUList") or nil
	local txtName = objectReference and objectReference:GetRefValue("txtName") or nil
	local btnLeft = objectReference and objectReference:GetRefValue("btnLeftUButton") or nil
	local btnRight = objectReference and objectReference:GetRefValue("btnRightUButton") or nil

	if not listUList or not listPagePointUList then
		logger:error("推荐 Banner 节点缺少轮播列表或分页点")

		return
	end

	local bannerList = data.bannerList
	local hasMultipleBanners = #bannerList > 1

	self._bannerNode = button
	self._bannerNameText = txtName

	self:_bindBannerTagReferences(objectReference)

	self._bannerList = bannerList
	self._bannerCurrentIndex = math.max(1, math.min(self._bannerCurrentIndex or 1, #bannerList))
	self._bannerUList = listUList
	self._bannerPagePointUList = hasMultipleBanners and listPagePointUList or nil

	listUList:SetScrollDisabled(not hasMultipleBanners)
	button:TryChangePage("SwitchBtn", 0)

	if btnLeft then
		function btnLeft.luaClick()
			self:_changeBannerByButton(-1)
		end
	end

	if btnRight then
		function btnRight.luaClick()
			self:_changeBannerByButton(1)
		end
	end

	listPagePointUList.gameObject:SetActiveEx(hasMultipleBanners)

	if hasMultipleBanners then
		self:_bindBannerScrollEnd(listUList)
	else
		self:_stopBannerAutoScroll()
		self:_unbindBannerScrollEnd()

		if self._bannerPagePointFrameId then
			self:killFrameTimer(self._bannerPagePointFrameId)

			self._bannerPagePointFrameId = nil
		end
	end

	function listPagePointUList.luaRenderItem(pointBtn, pointIdx, _)
		self:_renderBannerPagePoint(pointBtn, pointIdx)
	end

	function listUList.luaRenderItem(bannerBtn, bannerIdx, bannerData)
		self:renderItem(bannerBtn, bannerIdx, bannerData)

		bannerBtn.navForceNonInteractable = true
	end

	listUList.luaSelectedChanged = hasMultipleBanners and function(uList)
		if self._isAutoBannerScrolling then
			return
		end

		self:_syncBannerSelectionFromList(uList, nil, true)
	end or nil

	function button.luaClick()
		self:_syncBannerSelectionFromList(listUList, self._bannerCurrentIndex, true, nil, true)
	end

	listUList:SetList(self:_buildIndexedBannerList(bannerList))
	self:_onBannerSelected(self._bannerCurrentIndex)

	if hasMultipleBanners then
		self:_scheduleInitialBannerPagePointRefresh()
	end

	local selectedBannerData = self._bannerList[self._bannerCurrentIndex]

	if selectedBannerData and self._isBannerSelected then
		self:refreshCommodInfo(selectedBannerData)
	end

	self:_startBannerAutoScroll()
end

function RecommendationComponent:_bindBannerTagReferences(objectReference)
	self._bannerTagLayoutBox = objectReference:GetRefValue("tagLayoutBox")

	local newTransform = objectReference:GetRefValue("newTagTransform")
	local discountTransform = objectReference:GetRefValue("discountTagTransform")
	local pullTransform = objectReference:GetRefValue("pullTagTransform")
	local discountCountdownTransform = objectReference:GetRefValue("discountCountdownTransform")

	self._bannerNewWidget = NotNil(newTransform) and newTransform:GetComponent("UWidget") or nil
	self._bannerDiscountWidget = NotNil(discountTransform) and discountTransform:GetComponent("UWidget") or nil
	self._bannerPullWidget = NotNil(pullTransform) and pullTransform:GetComponent("UWidget") or nil
	self._bannerDiscountCountdownWidget = NotNil(discountCountdownTransform) and discountCountdownTransform:GetComponent("ULayoutBox") or nil

	local newText = NotNil(newTransform) and newTransform:Find("Text") or nil
	local discountText = NotNil(discountTransform) and discountTransform:Find("Text") or nil
	local discountCountdownText = NotNil(discountCountdownTransform) and discountCountdownTransform:Find("Text") or nil
	local pullCountDown = NotNil(pullTransform) and pullTransform:Find("CountDown") or nil
	local discountCountDown = NotNil(discountCountdownTransform) and discountCountdownTransform:Find("CountDown") or nil

	self._bannerNewText = NotNil(newText) and newText:GetComponent("USDFText") or nil
	self._bannerDiscountText = NotNil(discountText) and discountText:GetComponent("USDFText") or nil
	self._bannerDiscountCountdownText = NotNil(discountCountdownText) and discountCountdownText:GetComponent("USDFText") or nil
	self._bannerPullCountDown = NotNil(pullCountDown) and pullCountDown:GetComponent("UCountDown") or nil
	self._bannerDiscountCountDown = NotNil(discountCountDown) and discountCountDown:GetComponent("UCountDown") or nil
end

function RecommendationComponent:_renderBannerTags(data)
	local specialStartTime = Utils.getConfigTimeOfArea(data, "specialStartTime")
	local specialEndTime = Utils.getConfigTimeOfArea(data, "specialEndTime")
	local endTime = Utils.getConfigTimeOfArea(data, "endTime")
	local isInDiscount = specialStartTime and specialEndTime and TimeUtils.isInRangeTimestamp(specialStartTime, specialEndTime) or false

	data.isInDiscount = isInDiscount

	local showNew = data.tagText and true or false

	if self._bannerNewWidget then
		self._bannerNewWidget:SetActive(showNew)
	end

	if self._bannerTagLayoutBox then
		self._bannerTagLayoutBox:SetActive(showNew or isInDiscount)
	end

	if data.tagText and self._bannerNewText then
		ClientTextUtils.setText(self._bannerNewText, pg.getLocalizationText(data.tagText))
	end

	if self._bannerDiscountWidget then
		self._bannerDiscountWidget:SetActive(isInDiscount)
	end

	if isInDiscount and self._bannerDiscountText then
		ClientTextUtils.setText(self._bannerDiscountText, pg.getLocalizationText(data.specialCostText))
	end

	if self._bannerDiscountCountdownWidget then
		self._bannerDiscountCountdownWidget:SetActive(isInDiscount)
	end

	if isInDiscount and self._bannerDiscountCountdownText then
		ClientTextUtils.setText(self._bannerDiscountCountdownText, pg.getGameString("SHOP_DISCOUNT"))
	end

	if isInDiscount and self._bannerDiscountCountDown then
		LuaUIUtils.setCountDownTime(self._bannerDiscountCountDown, specialEndTime, UIConst.TimeType.OneTime)
	end

	local showPull = not isInDiscount and endTime ~= nil

	if self._bannerPullWidget then
		self._bannerPullWidget:SetActive(showPull)
	end

	if showPull and self._bannerPullCountDown then
		LuaUIUtils.setCountDownTime(self._bannerPullCountDown, endTime, UIConst.TimeType.OneTime)
	end
end

function RecommendationComponent:_changeBannerByButton(offset)
	if not self._bannerList or not self._bannerUList or #self._bannerList <= 1 then
		return
	end

	local targetIndex = self._bannerCurrentIndex + offset

	if targetIndex < 1 or targetIndex > #self._bannerList then
		return
	end

	self:_stopBannerAutoScroll()
	self:_syncBannerSelectionFromList(self._bannerUList, targetIndex, true, false)
	self:_startBannerAutoScroll()
end

function RecommendationComponent:_renderBannerPagePoint(pointBtn, pointIdx)
	local showType = pointIdx + 1 == self._bannerCurrentIndex and 5 or 0

	pointBtn:TryChangePage("button", showType)
end

function RecommendationComponent:_scheduleInitialBannerPagePointRefresh()
	if self._bannerPagePointFrameId then
		self:killFrameTimer(self._bannerPagePointFrameId)

		self._bannerPagePointFrameId = nil
	end

	self._bannerPagePointFrameId = self:startFrameTimer(function()
		self._bannerPagePointFrameId = nil

		self:_refreshPagePoints()
	end, 2)
end

function RecommendationComponent:_bindBannerScrollEnd(listUList)
	if self._bannerScrollEndTarget == listUList then
		return
	end

	self:_unbindBannerScrollEnd()

	if not listUList then
		return
	end

	self._bannerScrollEndCallback = self._bannerScrollEndCallback or function()
		if self._isAutoBannerScrolling then
			self._isAutoBannerScrolling = false

			return
		end

		local _, snappingBannerIndex = self:_getBannerSnapIndex(self._bannerUList)

		self:_syncBannerSelectionFromList(self._bannerUList, snappingBannerIndex, true)
	end

	listUList:RegisterToScrollEndEvent(self._bannerScrollEndCallback)

	self._bannerScrollEndTarget = listUList
end

function RecommendationComponent:_unbindBannerScrollEnd()
	if self._bannerScrollEndTarget and self._bannerScrollEndCallback then
		self._bannerScrollEndTarget:UnRegisterToScrollEndEvent(self._bannerScrollEndCallback)
	end

	self._bannerScrollEndTarget = nil
end

function RecommendationComponent:_getBannerSnapIndex(uList)
	if not uList then
		return nil, nil
	end

	local childButtons = uList:GetAllChildrenButtons()

	if not childButtons or childButtons.Length <= 0 then
		return nil, nil
	end

	local centerPosX = uList.transform.position.x
	local nearestButton, nearestChildIndex, nearestDistance

	for i = 0, childButtons.Length - 1 do
		local childButton = childButtons[i]

		if childButton and not IsNil(childButton) then
			local distance = math.abs(childButton.transform.position.x - centerPosX)

			if not nearestDistance or distance < nearestDistance then
				nearestDistance = distance
				nearestButton = childButton
				nearestChildIndex = uList:GetChildIndex(childButton)
			end
		end
	end

	if not nearestButton or nearestChildIndex == nil or nearestChildIndex < 0 then
		return nil, nil
	end

	local bannerData = nearestButton.dataFromUList
	local bannerIndex = bannerData and bannerData._bannerIndex or nearestChildIndex + 1

	return nearestChildIndex, bannerIndex
end

function RecommendationComponent:_syncBannerSelectionFromList(uList, targetBannerIndex, shouldUpdateSelection, instant, forceRefresh)
	if not uList or not self._bannerList or #self._bannerList == 0 then
		return
	end

	local selectedBannerData = uList.selectedItem
	local newIndex = targetBannerIndex or selectedBannerData and selectedBannerData._bannerIndex or nil

	if not newIndex then
		local selectedIndex = uList.selectedIndex

		if type(selectedIndex) == "number" and selectedIndex >= 0 then
			newIndex = selectedIndex + 1
		end
	end

	if not newIndex then
		local _, snappingBannerIndex = self:_getBannerSnapIndex(uList)

		newIndex = snappingBannerIndex
	end

	if not newIndex then
		return
	end

	if newIndex < 1 or newIndex > #self._bannerList then
		return
	end

	local shouldRefreshSelection = shouldUpdateSelection and (not self._isBannerSelected or self._selectedBannerIndex ~= newIndex or self._selectedListIndex ~= nil or self._selectedRecommendationKey ~= nil)

	if newIndex == self._bannerCurrentIndex and not shouldRefreshSelection and not forceRefresh then
		return
	end

	local oldIndex = self._selectedListIndex

	if shouldUpdateSelection then
		self._isBannerSelected = true
		self._selectedBannerIndex = newIndex
		self._selectedBannerKey = self:_getRecommendEntryKey(self._bannerList[newIndex])
		self._selectedCommodityId = nil
		self._selectedRecommendationKey = nil
		self._selectedListIndex = nil
	end

	self:_onBannerSelected(newIndex, nil, instant)

	if shouldRefreshSelection then
		self:_refreshSelectionElements(oldIndex, nil)
	end

	selectedBannerData = self._bannerList[newIndex]

	if selectedBannerData then
		self:refreshCommodInfo(selectedBannerData)
	end
end

function RecommendationComponent:_buildIndexedBannerList(bannerList)
	local list = {}

	for i, item in ipairs(bannerList) do
		local entry = {}

		for k, v in pairs(item) do
			entry[k] = v
		end

		entry._bannerIndex = i
		list[i] = entry
	end

	return list
end

function RecommendationComponent:_onBannerSelected(bannerIndex, shouldRefreshBannerList, instant)
	if not self._bannerList then
		return
	end

	local count = #self._bannerList

	if count == 0 then
		return
	end

	local previousIndex = self._bannerCurrentIndex

	self._bannerCurrentIndex = (bannerIndex - 1) % count + 1

	self._bannerUList:GoToIndex(self._bannerCurrentIndex - 1, instant == true)
	self:_refreshPagePoints()

	local bannerData = self._bannerList[self._bannerCurrentIndex]

	if self._bannerNameText and bannerData then
		ClientTextUtils.setText(self._bannerNameText, bannerData.name and pg.getLocalizationText(bannerData.name) or LuaUIUtils.getNameByItemId(bannerData.itemId))
	end

	if bannerData then
		self:_renderBannerTags(bannerData)
	end

	if self._bannerNode then
		local switchPage = 0

		if count > 1 then
			switchPage = self._bannerCurrentIndex == 1 and 1 or self._bannerCurrentIndex == count and 2 or 3
		end

		self._bannerNode:TryChangePage("SwitchBtn", switchPage)

		if previousIndex ~= self._bannerCurrentIndex then
			self._bannerNode:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		end
	end

	if shouldRefreshBannerList ~= false then
		self._bannerUList:RefreshList()
	end
end

function RecommendationComponent:_refreshPagePoints()
	if not self._bannerPagePointUList or not self._bannerList then
		return
	end

	self._bannerPagePointUList:SetList(self._bannerList)

	local pointButtons = self._bannerPagePointUList:GetAllButtons()

	if pointButtons and pointButtons.Length > 0 then
		for i = 0, pointButtons.Length - 1 do
			self:_renderBannerPagePoint(pointButtons[i], i)
		end
	else
		self._bannerPagePointUList:RefreshList(true)
	end
end

function RecommendationComponent:_startBannerAutoScroll()
	self:_stopBannerAutoScroll()

	if not self._bannerList or #self._bannerList <= 1 then
		return
	end

	self._bannerTimer = TimerManager.addRepeatTimer(RecommendationComponent.BANNER_AUTO_SCROLL_INTERVAL, function()
		self._isAutoBannerScrolling = true

		self:_onBannerSelected(self._bannerCurrentIndex + 1, false)
	end)
end

function RecommendationComponent:_stopBannerAutoScroll()
	if self._bannerTimer then
		TimerManager.removeTimer(self._bannerTimer)

		self._bannerTimer = nil
	end

	self._isAutoBannerScrolling = false
end

function RecommendationComponent:onBeforeExitPage()
	self:_stopBannerAutoScroll()

	self._bannerNode = nil
	self._bannerNameText = nil
	self._bannerTagLayoutBox = nil
	self._bannerNewWidget = nil
	self._bannerDiscountWidget = nil
	self._bannerPullWidget = nil
	self._bannerDiscountCountdownWidget = nil
	self._bannerNewText = nil
	self._bannerDiscountText = nil
	self._bannerDiscountCountdownText = nil
	self._bannerPullCountDown = nil
	self._bannerDiscountCountDown = nil

	if self._bannerPagePointFrameId then
		self:killFrameTimer(self._bannerPagePointFrameId)

		self._bannerPagePointFrameId = nil
	end

	self:_unbindBannerScrollEnd()
	CashShopContainerComponent.onBeforeExitPage(self)
end

function RecommendationComponent:onEnterPage(tabId)
	CashShopContainerComponent.onEnterPage(self, tabId)
	logger:info("RecommendationComponent:onEnterPage")
	self:ShowStoreIcon()
	self:registerFocusMove()
end

function RecommendationComponent:onExitPage()
	CashShopContainerComponent.onExitPage(self)
	logger:info("RecommendationComponent:onExitPage")
	self:HideStoreIcon()
	self:unRegisterFocusMove()
end

function RecommendationComponent:onDestroy()
	self:_stopBannerAutoScroll()

	if self._bannerPagePointFrameId then
		self:killFrameTimer(self._bannerPagePointFrameId)

		self._bannerPagePointFrameId = nil
	end

	self:_unbindBannerScrollEnd()

	if self._firstTopupCardRenderer then
		self._firstTopupCardRenderer:dispose()

		self._firstTopupCardRenderer = nil
	end

	self._firstTopupRewardTasks = nil

	CashShopContainerComponent.onDestroy(self)
	self:HideStoreIcon()
end

function RecommendationComponent:HideStoreIcon()
	if pg.setPSIconUIVisiable("RecommendationComponent", false) == false and PlatformBridgeLuaFacade.supportsCommerce() then
		PlatformBridgeLuaFacade.HideStoreIcon()
	end
end

function RecommendationComponent:ShowStoreIcon()
	if PlatformBridgeLuaFacade.supportsCommerce() then
		PlatformBridgeLuaFacade.DisplayStoreIcon(1)
	end

	pg.setPSIconUIVisiable("RecommendationComponent", true)
end

function RecommendationComponent:renderItem(button, index, data)
	if data._bannerIndex then
		local objectReference = button:GetComponent("ObjectReference")
		local imgBanner = objectReference and objectReference:GetRefValue("imgBanner")

		if imgBanner and data.pic then
			imgBanner.url = data.pic
		end

		if objectReference and objectReference:GetRefValue("newUWidget") then
			CashShopContainerComponent.renderItem(self, button, index, data)
		end
	else
		CashShopContainerComponent.renderItem(self, button, index, data)
	end

	if data.showModle == CashShopConst.ShowModle.FirstTopup then
		local treePath = string.format(RedDotConst.RedDotPath.CASH_SHOP_FIRST_TOPUP_ITEM, CashShopConst.CategoryType.RECOMMEND)

		pg.global.setPreViewRedDot(treePath, button, function()
			return CashShopRedDotUtils.getFirstTopupRedDotStyle()
		end)
	end

	if data._bannerIndex then
		button:SetSelected(self._isBannerSelected and data._bannerIndex == self._selectedBannerIndex)

		function button.luaClick()
			if self:_isCurrentRecommendEntry(data) then
				button:SetSelected(true)
				self:refreshCommodInfo(data)

				return
			end

			local oldIndex = self._selectedListIndex

			self._isBannerSelected = true
			self._selectedBannerIndex = data._bannerIndex
			self._selectedBannerKey = self:_getRecommendEntryKey(data)
			self._selectedCommodityId = nil
			self._selectedRecommendationKey = nil
			self._selectedListIndex = nil

			self:_onBannerSelected(data._bannerIndex)
			self:_refreshSelectionElements(oldIndex, nil)
			self:refreshCommodInfo(data)
		end
	else
		button:SetSelected(not self._isBannerSelected and self._selectedRecommendationKey ~= nil and self:_getRecommendEntryKey(data) == self._selectedRecommendationKey)

		function button.luaClick()
			local oldIndex = self._selectedListIndex

			self._isBannerSelected = false
			self._selectedCommodityId = data.commodityId
			self._selectedRecommendationKey = self:_getRecommendEntryKey(data)
			self._selectedListIndex = index

			if self._bannerUList then
				self._bannerUList:RefreshList()
			end

			self:_refreshSelectionElements(oldIndex, index)
			self:refreshCommodInfo(data)
		end
	end
end

function RecommendationComponent:onBuyItemResult(result)
	if result.success then
		self.model:clearItemCache()
		self:refreshPage()
	end
end

function RecommendationComponent:onBattlePassChange()
	if not self.listUList then
		return
	end

	self:refreshPage()
end

return RecommendationComponent
