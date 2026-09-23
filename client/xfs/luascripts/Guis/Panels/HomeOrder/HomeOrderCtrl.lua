-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeOrder\\HomeOrderCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("HomeOrderCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemData = require("Data.item_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local NoticeDef = require("Common.NoticeDef")
local ItemConst = require("Common.Const.ItemConst")
local HomeOrderConst = require("Common.Const.HomeOrderConst")
local FlyFeedbackConst = require("Common.Const.FlyFeedbackConst")
local UIConst = require("Const.UIConst")
local EventConst = require("Common.Const.EventConst")
local HomelandConfigData = require("Data.homeland_config_data")
local HomelandFormulaData = require("Data.homeland_formula_data")
local HomelandFacilityData = require("Data.homeland_facility_data")
local HomelandFacilityDataReverse = require("Data.homeland_facility_data_reverse")
local RevertHomeUpgradeData = require("Data.revert_home_upgrade_data")
local RedDotConst = require("Const.RedDotConst")
local HomeOrderRedDotUtils = require("Utils.HomeOrderRedDotUtils")
local ClientHomelandUtils = require("Utils.ClientHomelandUtils")
local HomeOrderCtrl = Class.LightClass("HomeOrderCtrl", UICtrl)
local AI_ENTER_ANIM = "UI_Node_AiAssistant_Grin_In"
local AI_LOOP_ANIM = "VX_Node_AiAssistant_Peaceful_Loop"
local AI_ENTER_ANIM_DURATION = 0.717

HomeOrderCtrl.messages = {
	[MessageName.ON_HOME_ORDER_LIST_CHANGED] = {
		"onHomeOrderChanged",
		true
	},
	[MessageName.ON_HOME_ORDER_USED_COUNT_CHANGED] = {
		"onHomeOrderUserCntChanged",
		true
	},
	[MessageName.ON_HOME_ORDER_REFRESH_TIME_CHANGED] = {
		"onHomeOrderTimeChanged",
		true
	},
	[MessageName.ON_HOME_ORDER_REFRESH] = {
		"onHomeOrderRefresh",
		true
	},
	[MessageName.CURRENCY_CHANGE] = {
		"onItemCountChanged",
		true
	},
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"onOrderItemCountChanged",
		true
	},
	[MessageName.HOMELAND_ITEM_MAP_CHANGED] = {
		"onOrderItemCountChanged",
		true
	},
	[MessageName.HOMELAND_STAT_HOMELAND_ORNAMENT_CHANGED] = {
		"onOrderNeedUnlockChanged",
		true
	},
	[MessageName.HOMELAND_DRAWING_UNLOCK_CHANGED] = {
		"onOrderNeedUnlockChanged",
		true
	}
}

function HomeOrderCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function HomeOrderCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:dismiss()
	end

	function self.view.btnInfoUButton.luaRenderTooltip(button, toolTip)
		local objectReference = toolTip:GetComponent("ObjectReference")
		local txtTitle = objectReference:GetRefValue("txtTitle")
		local txtDesc = objectReference:GetRefValue("txtDesc")

		ClientTextUtils.setText(txtTitle, pg.getGameString("HOME_ORDER_HELP_TIP_TITLE"))
		ClientTextUtils.setText(txtDesc, pg.getGameString("HOME_ORDER_HELP_TIP"))
	end

	self:bindHotKeyPerform("Raw/GamepadStart", function()
		if self.view.btnInfoUButton.isTooltipOpen then
			self.view.btnInfoUButton:CloseTooltip()
		else
			self.view.btnInfoUButton:OpenTooltip()
		end
	end)

	function self.view.listOrderUList.luaRenderItem(button, index, data)
		self:renderOneOrder(button, index, data)
	end

	function self.view.listCurrencyUList.luaRenderItem(button, index, data)
		LuaUIUtils.setTopCurrencyItem(button, data.id)

		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")

		self.currencyIconMap = self.currencyIconMap or {}
		self.currencyIconMap[data.id] = iconUImage.transform
	end

	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:AddLuaFocusCursorMovedListener("HomeOrder", function()
			self:refreshConsoleBarState()
		end)
	end
end

function HomeOrderCtrl:refreshConsoleBarState()
	if CS.XGUI.Navigation.NavManager.Instance then
		local groupName = CS.XGUI.Navigation.NavManager.Instance.CurrentFocusedGroupName
		local isInListOrder = groupName == "ListOrder"

		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("isInListOrder", isInListOrder, true)
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canShowInfo", true, true)
	end
end

function HomeOrderCtrl:onDestroy()
	HomeOrderRedDotUtils.clearWhenLeave()
	self:_stopAIAssistantAnimationTimer()

	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:RemoveLuaFocusCursorMovedListener("HomeOrder")
	end

	self:_cancelObtainWatch()

	if self.view.coinGeneral then
		self.view.coinGeneral:StopCoin()
	end

	self.currencyIconMap = nil
	self.orderNeedItemMap = nil
	self.orderDataMap = nil
	self.orderIndexMap = nil
	self.renderedOrderItemMap = nil
	self.renderedButtonInsIdMap = nil
	self._manualRefreshOrderIndexMap = nil
	self._aiAssistantShown = nil
	self.ownedFacilityLevelMap = nil
	self.ownedSingleLevelFacilityMap = nil

	UICtrl.onDestroy(self)

	self.curOrderDic = nil
end

function HomeOrderCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self._carLevel = pg.me.homeBasicInfo.level
	self._totalRefreshCnt = self.model.getFreeRefreshCnt()
	self.curOrderDic = {}
	self.renderedOrderItemMap = {}
	self.renderedButtonInsIdMap = {}
	self._manualRefreshOrderIndexMap = {}
	self._aiAssistantShown = false

	self.view.listOrderUList:SetEnableCustomInterval(true)
	HomeOrderRedDotUtils.reconcileNewOrderSet()

	local data = self.model:getOrderData()

	self:setOrderList(data)
	self.view.listOrderUList:SetEnableCustomInterval(false)
	ClientTextUtils.setText(self.view.txtContentUSDFText, pg.getGameString("HOME_ORDER_LIMIT_CONTENT"))
	self:refreshCount()
	self:refreshCountdown()
	self:refreshOrderNum()
	self:refreshHomeMoney()
end

function HomeOrderCtrl:setOrderList(data)
	self:_refreshOwnedFacilityLevelMap()
	self:_setOrderDataCache(data)

	local normalOrderCount = 0

	for _, orderData in ipairs(data) do
		if not orderData.isSeasonOrder then
			normalOrderCount = normalOrderCount + 1
		end
	end

	self.curOrderCount = normalOrderCount
	self.renderedOrderItemMap = {}
	self.renderedButtonInsIdMap = {}

	if self.view.txtCompletedUSDFText then
		ClientTextUtils.setText(self.view.txtCompletedUSDFText, pg.getGameString("HOME_ORDER_EMPTY"))
	end

	if #data == 0 then
		self.view.widget:TryChangePage("Completed", 1)
	else
		self.view.widget:TryChangePage("Completed", 0)
	end

	self.view.widget:TryChangePage("UnLockRefresh", 1)
	self.view.listOrderUList:SetList(data)

	local showAIAssistant = normalOrderCount >= self.model.getMaxOrderNum()

	self.view.aITipsRectTransform.gameObject:SetActiveEx(showAIAssistant)

	if showAIAssistant ~= self._aiAssistantShown then
		self._aiAssistantShown = showAIAssistant

		if showAIAssistant then
			self:_playAIAssistantAnimation()
		else
			self:_stopAIAssistantAnimationTimer()
		end
	end

	self.view.refreshUComponent:SetActive(self.model:isFlushFuncUnlocked())
	self:refreshOrderNum()
end

function HomeOrderCtrl:_stopAIAssistantAnimationTimer()
	if not self._aiAssistantLoopTimerId then
		return
	end

	self:killTimer(self._aiAssistantLoopTimerId)

	self._aiAssistantLoopTimerId = nil
end

function HomeOrderCtrl:_playAIAssistantAnimation()
	self:_stopAIAssistantAnimationTimer()

	local container = self.view.aIUContainer

	if not container then
		return
	end

	local function playAnimation(content)
		if IsNil(content) then
			return
		end

		local animation = content:GetComponent("Animation")

		if IsNil(animation) or IsNil(animation:GetClip(AI_LOOP_ANIM)) then
			return
		end

		local enterClip = animation:GetClip(AI_ENTER_ANIM)
		local enterDuration = IsNil(enterClip) and AI_ENTER_ANIM_DURATION or enterClip.length

		if not IsNil(enterClip) then
			animation:Play(AI_ENTER_ANIM)
		end

		self._aiAssistantLoopTimerId = self:startTimer(function()
			self._aiAssistantLoopTimerId = nil

			if not self._aiAssistantShown or IsNil(animation) then
				return
			end

			animation:Play(AI_LOOP_ANIM)
		end, enterDuration)
	end

	if container:CheckURLLoaded() then
		playAnimation(container.content)
	else
		container:LoadDefaultUrlManually(playAnimation)
	end
end

function HomeOrderCtrl:onShow()
	return
end

function HomeOrderCtrl:onHide()
	return
end

function HomeOrderCtrl:refreshHomeMoney()
	self.view.listCurrencyUList:SetList({
		{
			id = ItemConst.ITEM_SPECIAL_MONEY_HOME
		},
		{
			id = ItemConst.ITEM_SPECIAL_MONEY_HOME_VOUCHER
		}
	})
end

function HomeOrderCtrl:refreshCount()
	local remainCnt = self._totalRefreshCnt - pg.me.orderRefreshCount

	if remainCnt <= 0 then
		self.view.refreshUComponent:TryChangePage("Type", 1)

		local payCost = self:_getCurPayCost()

		ClientTextUtils.setText(self.view.txtCostUSDFText, payCost)
	else
		self.view.refreshUComponent:TryChangePage("Type", 0)
		ClientTextUtils.setText(self.view.refreshCountUSDFText, string.format("%d/%d", remainCnt, self._totalRefreshCnt))
	end
end

function HomeOrderCtrl:refreshCountdown(nextRefreshTime)
	local seconds = (nextRefreshTime or pg.me.nextRefreshTime) - Time.secondCache

	if seconds <= 0 then
		self.view.countownUSDFText.text = string.format("%s", "")

		return
	end

	local parts = {}
	local days = math.floor(seconds / 86400)

	if days > 0 then
		table.insert(parts, days .. ClientTextUtils.getGameString("DAY"))

		seconds = seconds - days * 24 * 3600
	end

	local hours = math.floor(seconds / 3600)

	table.insert(parts, hours .. ClientTextUtils.getGameString("HOUR"))

	seconds = seconds - hours * 3600

	local minutes = math.floor(seconds / 60)

	if days == 0 then
		table.insert(parts, minutes .. ClientTextUtils.getGameString("MINUTE"))

		seconds = seconds - minutes * 60
	end

	self.view.countownUSDFText.text = string.format("%s", table.concat(parts))
end

function HomeOrderCtrl:refreshOrderNum()
	local nowOrderCount = self.curOrderCount or 0

	ClientTextUtils.setText(self.view.textUSDFText, pg.getGameString("HOME_ORDER_TODAY_FREE_REFRESH_COUNT"))
	ClientTextUtils.setText(self.view.txtTitleUSDFText, pg.getGameString("HOME_ORDER_REFRESH_COUNTDOWN"))
	ClientTextUtils.setText(self.view.textAmountUSDFText, pg.getFormatText(pg.getGameString("HOME_ORDER_NUM"), nowOrderCount, self.model.getMaxOrderNum()))
	ClientTextUtils.setText(self.view.textNumberUSDFText, pg.getFormatText(pg.getGameString("HOME_ORDER_REFRESH_NUM"), self.model.getOrderRefreshNum()))
end

function HomeOrderCtrl:setImage(img, url)
	if url == nil or url == "" then
		return
	end

	if not img then
		return
	end

	if string.startsWith(url, "http") then
		img:SetTextureByUrl(url)
	else
		img.url = url
	end
end

function HomeOrderCtrl:renderOneOrder(button, index, data)
	self:_unregisterRenderedOrderButton(button)

	local objectReference = button:GetComponent("ObjectReference")
	local btnRefreshUButton = objectReference:GetRefValue("btnRefreshUButton")
	local listLevelUList = objectReference:GetRefValue("listLevelUList")
	local textTitleUSDFText = objectReference:GetRefValue("textTitleUSDFText")
	local listNeedUList = objectReference:GetRefValue("listNeedUList")
	local textDescriptionUSDFText = objectReference:GetRefValue("textDescriptionUSDFText")
	local urgencyUWidget = objectReference:GetRefValue("urgencyUWidget")
	local textNumUSDFText = objectReference:GetRefValue("textNumUSDFText")
	local listAwardUList = objectReference:GetRefValue("listAwardUList")
	local btnSubmitUButton = objectReference:GetRefValue("btnSubmitUButton")
	local bgUImage = objectReference:GetRefValue("bgUImage")
	local severalfoldUWidget = objectReference:GetRefValue("severalfoldUWidget")
	local textLevelUSDFText = objectReference:GetRefValue("textLevelUSDFText")
	local btnUnlockUButton = objectReference:GetRefValue("btnUnlockUButton")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local seasonUWidget = objectReference:GetRefValue("seasonUWidget")
	local txtSeasonUSDFText = objectReference:GetRefValue("txtSeasonUSDFText")
	local treePath = string.format(RedDotConst.RedDotPath.HOME_ORDER_ITEM, data.orderRedKey or data.insId or index)

	pg.global.setRedDot(treePath, button, data.isNewOrder == true, RedDotConst.RedDotStyle.NEW)
	btnUnlockUButton:SetActive(false)

	local isSeasonOrder = data.isSeasonOrder == true

	seasonUWidget:SetActive(isSeasonOrder)

	if isSeasonOrder then
		ClientTextUtils.setText(txtSeasonUSDFText, pg.getGameString("HOME_SEASON_ORDER_DESC"))
	end

	button:TryChangePage("OrderState", data.state)

	if data.state == self.model.ORDER_STATE.OPEN then
		button:TryChangePage("Quality", data.quality)

		if data.needShowRefreshVX == true then
			button:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)

			data.needShowRefreshVX = nil
		end

		self:setImage(bgUImage, data.bgImgPath)
		urgencyUWidget:SetActive(data.isUrgent)
		severalfoldUWidget:SetActive(data.isUrgent)

		if data.isUrgent == true then
			ClientTextUtils.setText(textNumUSDFText, string.format("x%d%%", data.urgentMultiple))
		end

		local isPayRefresh = pg.me.orderRefreshCount >= self._totalRefreshCnt
		local isPayRefreshUnLock = self.model:isPayFlushUnlocked()
		local isRefreshUnLock = self.model:isFlushFuncUnlocked()

		if isRefreshUnLock then
			if isPayRefresh then
				if isPayRefreshUnLock then
					btnRefreshUButton:SetActive(data.canRefresh)
				else
					btnRefreshUButton:SetActive(false)
				end
			else
				btnRefreshUButton:SetActive(data.canRefresh)
			end
		else
			btnRefreshUButton:SetActive(false)
		end

		function btnRefreshUButton.luaClick()
			if data.isUrgent == true then
				ClientUtils.showConfirmRaw(ClientTextUtils.getGameString("HOME_ORDER_URGENT_TITLE"), ClientTextUtils.getGameString("HOME_ORDER_URGENT_DESC"), function()
					self:reqRefreshOrder(data.insId)
				end)
			else
				self:reqRefreshOrder(data.insId)
			end
		end

		listLevelUList:SetList(data.starData)
		ClientTextUtils.setText(textTitleUSDFText, ClientTextUtils.getLocalizationText(data.title))

		function listNeedUList.luaRenderItem(needBtn, idx, needData)
			local needRef = needBtn:GetComponent("ObjectReference")
			local iconUImage = needRef:GetRefValue("iconUImage")
			local textUSDFText = needRef:GetRefValue("textUSDFText")

			self:_refreshNeedText(textUSDFText, needData)

			local item = ItemData[needData[1]]

			if item and item.icon ~= nil and item.icon ~= "" then
				if string.startsWith(item.icon, "http") then
					iconUImage:SetTextureByUrl(item.icon)
				else
					iconUImage.url = item.icon
				end
			end

			function needBtn.luaClick()
				self:_openNeedItemTip(needData[1], needBtn)
			end
		end

		listNeedUList:SetList(data.needItemData)

		local hasLockedNeedItem = self:_hasLockedNeedItem(data.needItemData)

		btnUnlockUButton:SetActive(hasLockedNeedItem)

		if hasLockedNeedItem then
			ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("HOMELAND_ITEM_LOCKED"))
		end

		ClientTextUtils.setText(textDescriptionUSDFText, ClientTextUtils.getLocalizationText(data.desc))

		local multiNum = 1

		if data.isUrgent == true then
			multiNum = data.urgentMultiple / 100
		end

		LuaUIUtils.setRewardListByDropIdsBatch(listAwardUList, data.rewardData, multiNum, true)
		self:_registerRenderedOrderItem(button, data, listNeedUList, btnSubmitUButton)

		if self:_checkCanSubmit(data.needItemData) then
			btnSubmitUButton.visualInteractable = true
		else
			btnSubmitUButton.visualInteractable = false
		end

		function btnSubmitUButton.luaClick()
			if self:_checkCanSubmit(data.needItemData) then
				local flyCurrencies = self:_collectRewardCurrencies(data)

				if data.isSeasonOrder then
					pg.me:reqSubmitHomeSeasonOrder(data.insId, function()
						self:flyCoinAfterObtainClose(flyCurrencies)
					end)
				else
					pg.me:reqSubmitHomeOrder(data.insId, function()
						self:flyCoinAfterObtainClose(flyCurrencies)
					end)
				end
			else
				btnSubmitUButton.visualInteractable = false

				listNeedUList:SetList(data.needItemData)
				pg.global.showBubbleMessage(NoticeDef.ITEM_COUNT_LACK)
			end
		end
	elseif data.state == self.model.ORDER_STATE.LOCK then
		ClientTextUtils.setText(textLevelUSDFText, string.format(pg.getGameString("HOME_ORDER_LOCK"), data.lockLevel))
	end
end

function HomeOrderCtrl:_getOwnedFacilityCount(homeTemplateId)
	local placedCount = pg.me.statHomelandOrnament[homeTemplateId] or 0
	local bagCount = ClientUtils.getItemCountById(homeTemplateId)
	local warehouseCount = ClientUtils.getHomelandItemCountById(homeTemplateId)

	return placedCount + bagCount + warehouseCount
end

function HomeOrderCtrl:_refreshOwnedFacilityLevelMap()
	local ownedFacilityLevelMap = {}

	for homeTemplateId, upgradeInfo in pairs(RevertHomeUpgradeData) do
		if self:_getOwnedFacilityCount(homeTemplateId) > 0 then
			local facilityType = upgradeInfo[1]
			local facilityLevel = upgradeInfo[2]
			local ownedLevel = ownedFacilityLevelMap[facilityType] or 0

			if ownedLevel < facilityLevel then
				ownedFacilityLevelMap[facilityType] = facilityLevel
			end
		end
	end

	self.ownedFacilityLevelMap = ownedFacilityLevelMap

	local ownedSingleLevelFacilityMap = {}

	for _, requiredFacilityList in pairs(HomelandFacilityDataReverse) do
		for _, homeTemplateId in ipairs(requiredFacilityList) do
			local isSingleLevelFacility = not RevertHomeUpgradeData[homeTemplateId]

			if isSingleLevelFacility and ownedSingleLevelFacilityMap[homeTemplateId] == nil then
				ownedSingleLevelFacilityMap[homeTemplateId] = self:_getOwnedFacilityCount(homeTemplateId) > 0
			end
		end
	end

	self.ownedSingleLevelFacilityMap = ownedSingleLevelFacilityMap
end

function HomeOrderCtrl:_getFormulaFacilityLockInfo(formulaId)
	local requiredFacilityList = HomelandFacilityDataReverse[formulaId]

	if not requiredFacilityList then
		return nil
	end

	local ownedFacilityLevelMap = self.ownedFacilityLevelMap
	local ownedSingleLevelFacilityMap = self.ownedSingleLevelFacilityMap
	local componentLockInfo, facilityLockInfo

	for _, homeTemplateId in ipairs(requiredFacilityList) do
		local upgradeInfo = RevertHomeUpgradeData[homeTemplateId]

		if upgradeInfo then
			local facilityType = upgradeInfo[1]
			local requiredLevel = upgradeInfo[2]

			if requiredLevel <= (ownedFacilityLevelMap[facilityType] or 0) then
				return nil
			end

			facilityLockInfo = facilityLockInfo or {
				isComponent = false,
				homeTemplateId = homeTemplateId,
				requiredLevel = requiredLevel
			}
		else
			if ownedSingleLevelFacilityMap[homeTemplateId] == true then
				return nil
			end

			componentLockInfo = componentLockInfo or {
				isComponent = true,
				homeTemplateId = homeTemplateId
			}
		end
	end

	return componentLockInfo or facilityLockInfo
end

function HomeOrderCtrl:_isFormulaFacilityLocked(formulaId)
	return self:_getFormulaFacilityLockInfo(formulaId) ~= nil
end

function HomeOrderCtrl:_openNeedItemTip(itemId, targetRect)
	local itemConfig = ItemData[itemId]
	local formulaId = itemConfig and itemConfig.fomulaId
	local formulaData = formulaId and HomelandFormulaData[formulaId]
	local hasHomeFormula = formulaData ~= nil
	local tipParam = {
		num = 1,
		autoHor = true,
		padding = 8,
		id = itemId,
		targetRect = targetRect,
		formulaTracking = hasHomeFormula
	}

	if formulaData then
		local unlockState = ClientHomelandUtils.getFormulaUnlockState(formulaId)
		local drawingLocked = unlockState.lockType == ClientHomelandUtils.HomelandUnlockType.Drawing
		local facilityLockInfo = self:_getFormulaFacilityLockInfo(formulaId)
		local defaultOutputItem = HomeLandUtils.getDisplayOutputItemId(formulaData)

		tipParam.countItemId = defaultOutputItem

		if unlockState.isLocked then
			tipParam.lockText = unlockState.lockText

			if drawingLocked then
				tipParam.sourceItemId = unlockState.unlockItemId
				tipParam.sourceTitle = ClientHomelandUtils.getDrawingSourceTitle(false)
			end
		elseif facilityLockInfo then
			if facilityLockInfo.isComponent then
				tipParam.showUnopen = true
			else
				tipParam.unlockTipType = 0

				local facilityConfig = HomelandFacilityData[facilityLockInfo.homeTemplateId]
				local facilityName = pg.getLocalizationText(facilityConfig.typeName)

				tipParam.lockText = pg.getFormatText(pg.getGameString("HOME_ORDER_FORMULA_UNLOCK"), facilityName, facilityLockInfo.requiredLevel)
			end
		end

		tipParam.formulaInfo = ClientHomelandUtils.getHomeFormulaData(formulaId)
		tipParam.price = Utils.getHomeItemPrice(defaultOutputItem)
	end

	pg.global.ui.commonItemTip:open(tipParam)
end

function HomeOrderCtrl:_isNeedItemLocked(itemId)
	local itemConfig = ItemData[itemId]
	local formulaId = itemConfig and itemConfig.fomulaId

	if not formulaId or not HomelandFormulaData[formulaId] then
		return false
	end

	if self:_isFormulaFacilityLocked(formulaId) then
		return true
	end

	return ClientHomelandUtils.getFormulaUnlockState(formulaId).isLocked
end

function HomeOrderCtrl:_hasLockedNeedItem(needItemData)
	for _, needData in ipairs(needItemData or EMPTY_TABLE) do
		if self:_isNeedItemLocked(needData[1]) then
			return true
		end
	end

	return false
end

function HomeOrderCtrl:_refreshNeedText(textUSDFText, needData)
	local curHasCnt = self._getItemCount(needData[1])
	local needCnt = needData[2]

	LuaUIUtils.renderConsumeText(textUSDFText, curHasCnt, needCnt, UIConst.ITEM_STATE.FULL)
end

function HomeOrderCtrl:_setOrderDataCache(orderData)
	self.orderNeedItemMap = {}
	self.orderDataMap = {}
	self.orderIndexMap = {}

	for index, data in ipairs(orderData or EMPTY_TABLE) do
		if data.insId then
			self.orderDataMap[data.insId] = data
			self.orderIndexMap[data.insId] = index

			for _, needData in ipairs(data.needItemData or EMPTY_TABLE) do
				local itemId = needData[1]
				local orderMap = self.orderNeedItemMap[itemId]

				if not orderMap then
					orderMap = {}
					self.orderNeedItemMap[itemId] = orderMap
				end

				orderMap[data.insId] = true
			end
		end
	end
end

function HomeOrderCtrl:_unregisterRenderedOrderButton(button)
	if not button or not self.renderedButtonInsIdMap then
		return
	end

	local oldInsId = self.renderedButtonInsIdMap[button]

	if oldInsId and self.renderedOrderItemMap then
		self.renderedOrderItemMap[oldInsId] = nil
	end

	self.renderedButtonInsIdMap[button] = nil
end

function HomeOrderCtrl:_registerRenderedOrderItem(button, data, listNeedUList, btnSubmitUButton)
	if not data or not data.insId then
		return
	end

	self.renderedOrderItemMap = self.renderedOrderItemMap or {}
	self.renderedButtonInsIdMap = self.renderedButtonInsIdMap or {}
	self.renderedOrderItemMap[data.insId] = {
		listNeedUList = listNeedUList,
		btnSubmitUButton = btnSubmitUButton
	}
	self.renderedButtonInsIdMap[button] = data.insId
end

function HomeOrderCtrl:_refreshRenderedOrderNeed(insId)
	local data = self.orderDataMap and self.orderDataMap[insId]
	local renderedInfo = self.renderedOrderItemMap and self.renderedOrderItemMap[insId]

	if not data or not renderedInfo then
		return
	end

	if renderedInfo.listNeedUList then
		renderedInfo.listNeedUList:SetList(data.needItemData)
	end

	if renderedInfo.btnSubmitUButton then
		renderedInfo.btnSubmitUButton.visualInteractable = self:_checkCanSubmit(data.needItemData)
	end
end

function HomeOrderCtrl:_refreshOrderNeedsByItemId(itemId)
	if not itemId then
		for insId in pairs(self.renderedOrderItemMap or EMPTY_TABLE) do
			self:_refreshRenderedOrderNeed(insId)
		end

		return
	end

	local orderMap = self.orderNeedItemMap and self.orderNeedItemMap[itemId]

	if not orderMap then
		return
	end

	for insId in pairs(orderMap) do
		self:_refreshRenderedOrderNeed(insId)
	end
end

function HomeOrderCtrl:_isPayRefreshLimitReached()
	local payRefreshLimit = HomeLandUtils.getHomePayOrderRefreshLimit(self._carLevel)

	if payRefreshLimit == nil then
		return true
	end

	local payRefreshCount = pg.me.orderRefreshCount - self._totalRefreshCnt

	return payRefreshLimit <= payRefreshCount
end

function HomeOrderCtrl:_requestManualRefreshOrder(insId, isPayRefresh)
	self._manualRefreshOrderIndexMap = self._manualRefreshOrderIndexMap or {}
	self._manualRefreshOrderIndexMap[insId] = self.orderIndexMap[insId]

	if isPayRefresh then
		pg.me:reqPayRefreshHomeOrder(insId)
	else
		pg.me:reqRefreshHomeOrder(insId)
	end
end

function HomeOrderCtrl:_keepManualRefreshOrderPositions(orderData)
	local fixedPositionMap = self._manualRefreshOrderIndexMap

	if not fixedPositionMap then
		return
	end

	local fixedOrderMap = {}
	local sortedOrderData = {}
	local orderCount = #orderData

	for _, data in ipairs(orderData) do
		local insId = data.insId
		local fixedIndex = fixedPositionMap[insId]

		if fixedIndex and fixedIndex <= orderCount then
			fixedOrderMap[insId] = true
			sortedOrderData[fixedIndex] = data
		end
	end

	local insertIndex = 1

	for _, data in ipairs(orderData) do
		local insId = data.insId

		if not fixedOrderMap[insId] then
			while sortedOrderData[insertIndex] do
				insertIndex = insertIndex + 1
			end

			sortedOrderData[insertIndex] = data
		end
	end

	for index = 1, orderCount do
		orderData[index] = sortedOrderData[index]
	end
end

function HomeOrderCtrl:reqRefreshOrder(insId)
	if self._totalRefreshCnt <= pg.me.orderRefreshCount then
		if self:_isPayRefreshLimitReached() then
			pg.global.showBubbleMessage(NoticeDef.HOME_ORDER_PAY_REFRESH_LIMIT)

			return
		end

		if pg.game.home.curLoginShowOrderPayRefreshHint then
			local payCost = self:_getCurPayCost()
			local payCostStr = string.format("<color=#3F95D7>%d</color>", payCost)
			local payDesc = string.format(ClientTextUtils.getGameString("HOME_ORDER_PAY_REFRESH_DESC"), payCostStr)

			pg.global.ui.commonUseConfirm:open({
				showHint = true,
				type = 4,
				title = pg.getGameString("HOME_ORDER_PAY_REFRESH_TITLE"),
				tipTop = payDesc,
				data = {
					{
						ItemConst.ITEM_SPECIAL_MONEY_HOME,
						self._getItemCount(ItemConst.ITEM_SPECIAL_MONEY_HOME)
					}
				},
				notEnoughCallback = function(itemId, itemNum)
					local itemInfo = LuaUIUtils.getItemClientInfoById(itemId)
					local itemName = pg.getLocalizationText(itemInfo.name)

					pg.global.showBubbleMessage(NoticeDef.SHOP_ITEM_NOT_ENOUGH, itemName)
				end,
				confirmCb = function()
					self:_requestManualRefreshOrder(insId, true)
				end,
				cancelCb = function()
					pg.global.ui.commonUseConfirm:close()
				end,
				hintText = pg.getGameString("LOGIN_NOT_SHOW_HINT"),
				hintCb = function(isSelect)
					pg.game.home.curLoginShowOrderPayRefreshHint = not isSelect
				end
			})
		else
			self:_requestManualRefreshOrder(insId, true)
		end
	else
		self:_requestManualRefreshOrder(insId, false)
	end
end

function HomeOrderCtrl:_checkCanSubmit(itemData)
	for _, v in ipairs(itemData or EMPTY_TABLE) do
		local id, num = v[1], v[2]
		local hasCnt = self._getItemCount(id)

		if hasCnt < num then
			return false
		end
	end

	return true
end

function HomeOrderCtrl._getItemCount(itemId)
	local bagNum = ClientUtils.getItemCountById(itemId)
	local invNum = ClientUtils.getHomelandItemCountById(itemId)

	return bagNum + invNum
end

function HomeOrderCtrl:_getCurPayCost()
	local payRefreshCost = HomelandConfigData.homeOrderRefreshCost
	local payCost = HomelandConfigData.homeOrderRefreshMaxCost
	local count = pg.me.orderRefreshCount - self._totalRefreshCnt + 1

	for _, data in ipairs(payRefreshCost) do
		if count < data[1] then
			payCost = data[2]

			break
		end
	end

	return payCost
end

function HomeOrderCtrl:_collectRewardCurrencies(data)
	local res = {}

	if not data or not data.rewardData then
		return res
	end

	local multi = 1

	if data.isUrgent == true and data.urgentMultiple then
		multi = data.urgentMultiple / 100
	end

	local countMap = {}
	local order = {}

	for _, dropData in ipairs(data.rewardData) do
		local rewardMulti = dropData.multiNum or multi
		local rewardItems = LuaUIUtils.getRewardItemByDropId(dropData.dropId)

		for _, item in ipairs(rewardItems) do
			local itemCfg = item.type == 0 and item.id and ItemData[item.id]

			if itemCfg and itemCfg.commonMoney == 1 then
				if not countMap[item.id] then
					countMap[item.id] = 0

					table.insert(order, item.id)
				end

				countMap[item.id] = countMap[item.id] + math.floor((item.num or 0) * rewardMulti)
			end
		end
	end

	for _, id in ipairs(order) do
		table.insert(res, {
			id = id,
			count = countMap[id]
		})
	end

	return res
end

function HomeOrderCtrl:flyCoinAfterObtainClose(currencies)
	if not currencies then
		return
	end

	self:_cancelObtainWatch()

	self._pendingFlyCurrencies = currencies

	local WAIT_OPEN_TICKS = 15
	local elapsed = 0

	self._obtainWatchTimer = self:startTimer(function()
		if pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_OBTAIN) then
			self:killTimer(self._obtainWatchTimer)

			self._obtainWatchTimer = nil
			self._onObtainClose = self._onObtainClose or function()
				local pendingCurrencies = self._pendingFlyCurrencies

				self:_cancelObtainWatch()

				if pendingCurrencies then
					self:playSubmitCoinFly(pendingCurrencies)
				end
			end

			pg.global.eventEmitter:addEventListener(EventConst.ON_ITEM_OBTAIN_CLOSE_PANEL, self._onObtainClose)
		else
			elapsed = elapsed + 1

			if elapsed >= WAIT_OPEN_TICKS then
				local pendingCurrencies = self._pendingFlyCurrencies

				self:_cancelObtainWatch()

				if pendingCurrencies then
					self:playSubmitCoinFly(pendingCurrencies)
				end
			end
		end
	end, 0.1, true)
end

function HomeOrderCtrl:_cancelObtainWatch()
	if self._obtainWatchTimer then
		self:killTimer(self._obtainWatchTimer)

		self._obtainWatchTimer = nil
	end

	if self._onObtainClose then
		pg.global.eventEmitter:removeEventListener(EventConst.ON_ITEM_OBTAIN_CLOSE_PANEL, self._onObtainClose)
	end

	self._pendingFlyCurrencies = nil
end

function HomeOrderCtrl:playSubmitCoinFly(currencies)
	local coinGeneral = self.view.coinGeneral
	local flyNode = self.view.coinFlyNodeUWidget

	if not coinGeneral or not flyNode or not currencies then
		return
	end

	coinGeneral.subParent = flyNode.transform

	function coinGeneral.luaGeneralCoin()
		pg.game.audio:playEvent(FlyFeedbackConst.SFX_GENERAL)
	end

	function coinGeneral.luaStartFly()
		pg.game.audio:playEvent(FlyFeedbackConst.SFX_START_FLY)
	end

	function coinGeneral.luaEndFly()
		pg.game.audio:playEvent(FlyFeedbackConst.SFX_END_FLY)
	end

	local sourcePos = self:_getScreenCenterToFlyWorldPos()
	local iconMap = self.currencyIconMap
	local getIconByItemId = LuaUIUtils.getIconByItemId
	local iconType = LuaUIUtils.ITEM_ICON_TYPE.ICON_SMALL

	coinGeneral:StopCoin()

	for _, currency in ipairs(currencies) do
		local rewardCount = currency.count

		if rewardCount > 0 then
			local targetIcon = iconMap and iconMap[currency.id]

			if targetIcon then
				coinGeneral.coinIconUrl = getIconByItemId(currency.id, iconType)

				local count

				count = rewardCount <= 500 and 3 or rewardCount <= 2000 and 5 or rewardCount <= 4000 and 10 or 20
				coinGeneral.sourcePosition = sourcePos
				coinGeneral.targetPosition = targetIcon.position

				coinGeneral:AppendCoin(count)
			end
		end
	end
end

function HomeOrderCtrl:_getScreenCenterToFlyWorldPos()
	local flyTrans = self.view.coinFlyNodeUWidget.transform
	local uiMgr = pg.global.uiMgr
	local uiCamera = uiMgr.orthographicCamera
	local screenPos = CS.UnityEngine.Vector2(CS.UnityEngine.Screen.width * 0.5, CS.UnityEngine.Screen.height * 0.5)
	local localPos = uiMgr:ScreenPointToLocalPoint(flyTrans, screenPos, uiCamera)

	return flyTrans:TransformPoint(localPos)
end

function HomeOrderCtrl:onHomeOrderChanged()
	HomeOrderRedDotUtils.reconcileNewOrderSet()

	local orderData = self.model:getOrderData()

	self:_keepManualRefreshOrderPositions(orderData)
	self:setOrderList(orderData)
end

function HomeOrderCtrl:onHomeOrderRefresh(data)
	HomeOrderRedDotUtils.reconcileNewOrderSet()

	local refreshInsId = data[1]
	local orderData = self.model:getOrderData()

	for _, v in ipairs(orderData) do
		if v.insId == refreshInsId then
			v.needShowRefreshVX = true

			if v.isUrgent == true then
				pg.global.showBubbleMessage(NoticeDef.HOME_ORDER_URGENT_TIP)
			end
		end
	end

	self:_keepManualRefreshOrderPositions(orderData)
	self:setOrderList(orderData)
end

function HomeOrderCtrl:onHomeOrderUserCntChanged(data)
	self:refreshCount()
end

function HomeOrderCtrl:onHomeOrderTimeChanged(data)
	local hasManualRefreshPosition = next(self._manualRefreshOrderIndexMap or EMPTY_TABLE) ~= nil

	self._manualRefreshOrderIndexMap = nil

	if hasManualRefreshPosition then
		local orderData = self.model:getOrderData()

		self:setOrderList(orderData)
	end

	local nextRefreshTime = data and (data.nextRefreshTime or data.newV)

	self:refreshCountdown(nextRefreshTime)
	self:refreshOrderNum()
end

function HomeOrderCtrl:onItemCountChanged()
	self:refreshHomeMoney()
end

function HomeOrderCtrl:onOrderItemCountChanged(data)
	local itemId = data and (data.itemId or data.genId)
	local isSingleLevelFacility = itemId and self.ownedSingleLevelFacilityMap[itemId] ~= nil

	if not itemId or RevertHomeUpgradeData[itemId] or isSingleLevelFacility then
		self:_refreshOwnedFacilityLevelMap()
		self.view.listOrderUList:RefreshList()

		return
	end

	self:_refreshOrderNeedsByItemId(itemId)
end

function HomeOrderCtrl:onOrderNeedUnlockChanged()
	self:_refreshOwnedFacilityLevelMap()
	self.view.listOrderUList:RefreshList()
end

return HomeOrderCtrl
