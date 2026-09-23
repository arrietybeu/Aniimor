-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashCart\\CashCartCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local CashCartModel = require("Guis.Panels.CashCart.CashCartModel")
local CashCartView = require("Guis.Panels.CashCart.CashCartView")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local NoticeDef = require("Common.NoticeDef")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local CashShopConst = require("Const.CashShopConst")
local ShopmallTabGroupData = require("Data.shopmall_tab_group_data")
local ItemData = require("Data.item_data")
local CashCartCtrl = Class.LightClass("CashCartCtrl", UICtrl)

CashCartCtrl.modelClz = CashCartModel
CashCartCtrl.viewClz = CashCartView
CashCartCtrl.messages = {
	[MessageName.COMMON_SWITCH_STATE_CHANGED] = {
		"onCommonSwitchStateChanged",
		true
	}
}

function CashCartCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self._isManagementMode = false
	self._deleteRequestToken = 0
	self._buyRequestToken = 0
	self._deleteRequestPending = false
	self._buyRequestPending = false
	self._requestLifecycleToken = 0
	self._countRequestTokenByCommodityId = {}
	self._syncingAllSelectButton = false
	self._syncingCommoditySelectButton = false

	self.view:initView()
	self:addListener()
end

function CashCartCtrl:addListener()
	function self.view.listUList.luaRenderItem(button, _, data)
		if data.tIndex == 0 then
			self:renderCommodityItem(button, data)
		elseif data.tIndex == 1 then
			self:renderGroupTitle(button, data)
		end
	end

	if self.view.listCoinsUList then
		function self.view.listCoinsUList.luaRenderItem(button, _, data)
			self:renderCostCurrencyItem(button, data.itemId, data.itemCount)
		end
	end

	if self.view.allSelectBtn then
		self.view.allSelectBtn.luaClick = nil

		function self.view.allSelectBtn.luaSelectChanged(isSelected)
			if self._syncingAllSelectButton then
				return
			end

			self:setAllCommoditySelected(isSelected)
			self:refreshList()
		end
	end

	if self.view.editUBtn then
		function self.view.editUBtn.luaClick()
			self:enterManagementMode()
		end
	end

	if self.view.btnOutUButton then
		function self.view.btnOutUButton.luaClick()
			self:exitManagementMode()
		end
	end

	if self.view.btnDeleteUButton then
		function self.view.btnDeleteUButton.luaClick()
			self:deleteSelectedCommodities()
		end
	end

	if self.view.confirmBtn then
		function self.view.confirmBtn.luaClick()
			self:buySelectedCommodities()
		end
	end

	if self.view.closeBtn then
		function self.view.closeBtn.luaClick()
			self:dismiss()
		end
	end
end

function CashCartCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function CashCartCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self._requestLifecycleToken = self._requestLifecycleToken + 1

	self.model:setCommodityList(CashCartModel.getPlayerCartCommodityList())
	self.model:setAllSelected(false)
	self:setManagementMode(false)
	self:refreshList()
end

function CashCartCtrl:onShow()
	self:setManagementMode(self._isManagementMode)
	self:refreshActionButtonState()
end

function CashCartCtrl:setManagementMode(isManagementMode)
	self._isManagementMode = isManagementMode == true

	if self.view.rootUComponent then
		self.view.rootUComponent:TryChangePage("State", self._isManagementMode and 1 or 0)
	end
end

function CashCartCtrl:enterManagementMode()
	self._requestLifecycleToken = self._requestLifecycleToken + 1

	self:setManagementMode(true)
	self.model:cancelCommodityCountEditing()
	self:refreshList()
end

function CashCartCtrl:exitManagementMode()
	self:setManagementMode(false)
	self:refreshList()
end

function CashCartCtrl:isDeleteRequestValid(requestToken)
	return requestToken == self._deleteRequestToken and self:checkUIOpen() and not self:checkUIClosing()
end

function CashCartCtrl:isBuyRequestValid(requestToken)
	return requestToken == self._buyRequestToken and self:checkUIOpen() and not self:checkUIClosing()
end

function CashCartCtrl:showRequestError(noticeId)
	if noticeId then
		pg.global.showBubbleMessageById(noticeId)
	end
end

function CashCartCtrl:requestModifyCommodityNum(commodityId, buyCount, callback)
	if not pg.me then
		if callback then
			callback(false)
		end

		return
	end

	pg.me:serverMsg("RPC_CS_ShopMallCartModifyCommodityNum", commodityId, buyCount, function(noticeId)
		if noticeId == NoticeDef.SUCCESS then
			facade:sendMsgToUI(MessageName.CASH_SHOP_CART_CHANGED)
		end

		if callback then
			callback(noticeId == NoticeDef.SUCCESS, noticeId)
		end
	end)
end

function CashCartCtrl:requestDeleteCommodities(commodityIds, callback)
	if not pg.me then
		if callback then
			callback(false)
		end

		return
	end

	pg.me:serverMsg("RPC_CS_ShopMallCartDelCommodity", commodityIds, function(noticeId)
		if noticeId == NoticeDef.SUCCESS then
			facade:sendMsgToUI(MessageName.CASH_SHOP_CART_CHANGED)
		end

		if callback then
			callback(noticeId == NoticeDef.SUCCESS, noticeId)
		end
	end)
end

function CashCartCtrl:requestBuyCommodities(commodityIds, callback)
	if not pg.me then
		if callback then
			callback(false)
		end

		return
	end

	pg.me:serverMsg("RPC_CS_ShopMallCartBuyCommodity", commodityIds, function(noticeId)
		if noticeId == NoticeDef.SUCCESS then
			facade:sendMsgToUI(MessageName.CASH_SHOP_CART_CHANGED)
		end

		if callback then
			callback(noticeId == NoticeDef.SUCCESS, noticeId)
		end
	end)
end

function CashCartCtrl:reloadCommodityList()
	self.model:setCommodityList(CashCartModel.getPlayerCartCommodityList())
	self.model:setAllSelected(false)
	self:refreshList()
end

function CashCartCtrl:deleteSelectedCommodities()
	if not self._isManagementMode or self._deleteRequestPending then
		return
	end

	local commodityIds = self.model:getSelectedCommodityIds()

	self:deleteCommodities(commodityIds)
end

function CashCartCtrl:deleteCommodities(commodityIds)
	if self._deleteRequestPending then
		return
	end

	if #commodityIds == 0 then
		return
	end

	self._deleteRequestToken = self._deleteRequestToken + 1

	local requestToken = self._deleteRequestToken

	self._deleteRequestPending = true

	self:requestDeleteCommodities(commodityIds, function(success, noticeId)
		if requestToken == self._deleteRequestToken then
			self._deleteRequestPending = false
		end

		if not self:isDeleteRequestValid(requestToken) then
			return
		end

		if not success then
			self:showRequestError(noticeId)

			return
		end

		self:reloadCommodityList()
	end)
end

function CashCartCtrl:deleteUnavailableCommodities()
	self:deleteCommodities(self.model:getUnavailableCommodityIds())
end

function CashCartCtrl:buySelectedCommodities()
	if self._isManagementMode or self._buyRequestPending then
		return
	end

	local commodityIds = self.model:getSelectedCommodityIds(true)

	if #commodityIds == 0 then
		return
	end

	self._buyRequestToken = self._buyRequestToken + 1

	local requestToken = self._buyRequestToken

	self._buyRequestPending = true

	self:requestBuyCommodities(commodityIds, function(success, noticeId)
		if requestToken == self._buyRequestToken then
			self._buyRequestPending = false
		end

		if not self:isBuyRequestValid(requestToken) then
			return
		end

		if not success then
			self:showRequestError(noticeId)

			return
		end

		self:reloadCommodityList()
	end)
end

function CashCartCtrl:refreshList()
	local listData = self.model:getListData()
	local hasCommodity = false

	for _, data in ipairs(listData) do
		if data.tIndex == 0 then
			hasCommodity = true

			break
		end
	end

	if self.view.rootUComponent then
		self.view.rootUComponent:TryChangePage("Empty", hasCommodity and 0 or 1)
	end

	self.view.listUList:SetList(listData)
	self:refreshAllSelectButton()
	self:refreshActionButtonState()
	self:_refreshSelectedCostList()
end

function CashCartCtrl:hasSelectedCommodity()
	for _, data in ipairs(self.model:getListData()) do
		if data.tIndex == 0 and data.selected and (self._isManagementMode or self.model:isCommodityPurchasable(data)) then
			return true
		end
	end

	return false
end

function CashCartCtrl:setActionButtonSelectedState(button, hasSelectedCommodity)
	if not button then
		return
	end

	button.visualInteractable = hasSelectedCommodity

	button:TryChangePage("button", hasSelectedCommodity and 0 or 4)
end

function CashCartCtrl:refreshActionButtonState()
	local hasSelectedCommodity = self:hasSelectedCommodity()

	self:setActionButtonSelectedState(self.view.confirmBtn, hasSelectedCommodity)
	self:setActionButtonSelectedState(self.view.btnDeleteUButton, hasSelectedCommodity)
end

function CashCartCtrl:refreshAllSelectButton()
	if not self.view.allSelectBtn then
		return
	end

	local isAllSelected = self:isAllCommoditySelected()

	self._syncingAllSelectButton = true

	self.view.allSelectBtn:SetSelected(isAllSelected)
	self.view.allSelectBtn:TryChangePage("button", isAllSelected and 5 or 0)

	self._syncingAllSelectButton = false
end

function CashCartCtrl:isCommoditySelectable(data)
	return self._isManagementMode or self.model:isCommodityPurchasable(data)
end

function CashCartCtrl:setAllCommoditySelected(selected)
	local targetSelected = selected == true

	for _, data in ipairs(self.model:getListData()) do
		if data.tIndex == 0 then
			local itemSelected = targetSelected and self:isCommoditySelectable(data)

			data.selected = itemSelected

			self.model:setCommoditySelected(data.commodityId, itemSelected)
		end
	end
end

function CashCartCtrl:isAllCommoditySelected()
	local hasSelectableCommodity = false

	for _, data in ipairs(self.model:getListData()) do
		if data.tIndex == 0 and self:isCommoditySelectable(data) then
			hasSelectableCommodity = true

			if not data.selected then
				return false
			end
		end
	end

	return hasSelectableCommodity
end

function CashCartCtrl:_refreshSelectedCostList()
	if self.view.listCoinsUList then
		self.view.listCoinsUList:SetList(self.model:getSelectedCostList())
	end
end

function CashCartCtrl:renderCostCurrencyItem(content, itemId, itemCount)
	local objectReference = content:GetComponent("ObjectReference")
	local imgIcon = objectReference:GetRefValue("imgIcon")
	local txtNum = objectReference:GetRefValue("txtNum")
	local btnClick = objectReference:GetRefValue("btnClick")

	if imgIcon then
		imgIcon.url = LuaUIUtils.getIconByItemId(itemId)
	end

	if txtNum then
		local hasCount = ClientUtils.getItemCountById(itemId)
		local countText = itemCount

		if hasCount < itemCount then
			countText = pg.getFormatText("<style=Debuff>{0}</style>", itemCount)
		end

		ClientTextUtils.setText(txtNum, countText)
	end

	if btnClick then
		function btnClick.luaClick()
			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
				id = itemId,
				num = itemCount,
				targetRect = btnClick
			})
		end
	end
end

function CashCartCtrl:renderGroupTitle(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textUBaseText = objectReference:GetRefValue("textUBaseText")
	local btnDeleteUButton = objectReference:GetRefValue("btnDeleteUButton")
	local isUnavailableGroup = data.isUnavailableGroup == true

	button:TryChangePage("Type", isUnavailableGroup and 1 or 0)

	if isUnavailableGroup then
		ClientTextUtils.setText(textUBaseText, pg.getGameString(data.gameStringKey or "SHOP_CART_LOCK"))
	else
		local groupData = ShopmallTabGroupData[data.groupId]
		local tabName = data.tabName or groupData and groupData.tabName

		ClientTextUtils.setText(textUBaseText, tabName and pg.getLocalizationText(tabName) or "")
	end

	if btnDeleteUButton then
		btnDeleteUButton:SetActive(isUnavailableGroup)

		btnDeleteUButton.luaClick = isUnavailableGroup and function()
			self:deleteUnavailableCommodities()
		end or nil
	end
end

function CashCartCtrl:_getMaxBuyCount(data)
	local leftLimit = ClientCashShopUtils.getCommodityLeftLimit(data.commodityId)

	if leftLimit == math.huge then
		return 99
	end

	return math.max(1, leftLimit)
end

function CashCartCtrl:_getCommodityStatus(data)
	if not ClientCashShopUtils.isCommodityOnShelf(data, data.commodityId) then
		return 4, "COMMODITY_STATE_TIME_OUT", true
	end

	local commodityState = ClientCashShopUtils.getCommodityState(data)
	local state = ClientCashShopUtils.COMMODITY_STATE

	if commodityState == state.POSSESS then
		return 4, "COMMODITY_STATE_POSSESS"
	elseif commodityState == state.LOCKED then
		return 4, "COMMODITY_STATE_LOCKED"
	elseif commodityState == state.SOLDOUT then
		return 4, "COMMODITY_STATE_SOLDOUT"
	end

	local groupData = ShopmallTabGroupData[data.tabGroupId]
	local avatarType = tonumber(data.avatarType)

	if ClientCashShopUtils.isSuitType(data.avatarType) or avatarType == CashShopConst.CommodityAvatarType.ACCESSORY_PACKAGE or groupData and groupData.tabId == CashShopConst.CategoryType.GIFTPACK then
		return 0
	end

	if self:_getMaxBuyCount(data) <= 1 then
		return 1
	end

	return 2
end

function CashCartCtrl:_refreshCommodityCount(data, moneyUContent, isInDiscount, count)
	local finalCount = math.max(1, tonumber(count) or 1)
	local cost = ClientCashShopUtils.getCommodityPrimaryCost(data.commodityId, finalCount, {
		isInDiscount = isInDiscount
	})

	if moneyUContent and cost and cost[1] then
		LuaUIUtils.setCostCurrencyItem(moneyUContent, cost[1], cost[2] or 0, false)
	end

	return finalCount
end

function CashCartCtrl:_refreshCommoditySelected(btnCheckUButton, data)
	local selected = data.selected == true

	if btnCheckUButton then
		self._syncingCommoditySelectButton = true

		btnCheckUButton:SetSelected(selected)
		btnCheckUButton:TryChangePage("button", selected and 5 or 0)

		self._syncingCommoditySelectButton = false
	end

	self:refreshAllSelectButton()
end

function CashCartCtrl:_setCommoditySelected(btnCheckUButton, data, selected)
	if not self:isCommoditySelectable(data) then
		self:_refreshCommoditySelected(btnCheckUButton, data)

		return
	end

	data.selected = selected == true

	self.model:setCommoditySelected(data.commodityId, data.selected)
	self:_refreshCommoditySelected(btnCheckUButton, data)
	self:refreshActionButtonState()
	self:_refreshSelectedCostList()
end

function CashCartCtrl:onCommonSwitchStateChanged()
	self:reloadCommodityList()
end

function CashCartCtrl:beginCommodityCountEditing(statusRoot, numSelector, data, maxCount)
	if self._isManagementMode or self:_getCommodityStatus(data) ~= 2 then
		return
	end

	data.pendingBuyCount = data.buyCount or 1
	data.isEditingCount = true

	if numSelector then
		numSelector:SetAllValue(data.pendingBuyCount, 1, maxCount, 1, false)
	end

	statusRoot:TryChangePage("Status", 3)
end

function CashCartCtrl:isCountRequestValid(commodityId, requestToken, lifecycleToken)
	return lifecycleToken == self._requestLifecycleToken and requestToken == self._countRequestTokenByCommodityId[commodityId] and self:checkUIOpen() and not self:checkUIClosing()
end

function CashCartCtrl:confirmCommodityCount(data, maxCount)
	if not data.isEditingCount then
		return
	end

	local commodityId = data.commodityId
	local buyCount = math.min(math.max(1, tonumber(data.pendingBuyCount) or data.buyCount or 1), maxCount)
	local requestToken = (self._countRequestTokenByCommodityId[commodityId] or 0) + 1
	local lifecycleToken = self._requestLifecycleToken

	self._countRequestTokenByCommodityId[commodityId] = requestToken

	self:requestModifyCommodityNum(commodityId, buyCount, function(success, noticeId)
		if not self:isCountRequestValid(commodityId, requestToken, lifecycleToken) then
			return
		end

		if not success then
			self:showRequestError(noticeId)

			return
		end

		data.buyCount = buyCount
		data.pendingBuyCount = nil
		data.isEditingCount = false

		self.model:setCommodityCount(commodityId, data.buyCount)
		self:refreshList()
	end)
end

function CashCartCtrl:renderSuitAppearanceItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
	local txtNumUText = objectReference:GetRefValue("txtNumUText")

	if itemIconUImage then
		itemIconUImage.url = data.icon or LuaUIUtils.getIconByItemId(data.id)
	end

	if txtNumUText then
		ClientTextUtils.setText(txtNumUText, data.num or 1)
	end

	local itemConfig = ItemData[data.id]

	button:TryChangePage("Quality", itemConfig and itemConfig.quality or 0)

	function button.luaClick()
		LuaUIUtils.onRewardItemClick(button, data)
	end
end

function CashCartCtrl:refreshSuitAppearanceList(listUList, data)
	if not listUList then
		return
	end

	function listUList.luaRenderItem(button, _, itemData)
		self:renderSuitAppearanceItem(button, itemData)
	end

	local suitItems = {}

	if ClientCashShopUtils.isSuitType(data.avatarType) then
		suitItems = ClientCashShopUtils.getSuitAppearanceItems(data.itemId) or {}
	elseif tonumber(data.avatarType) == CashShopConst.CommodityAvatarType.ACCESSORY_PACKAGE then
		suitItems = LuaUIUtils.getRewardFixedItemsByDropId(data.itemId) or {}
	end

	listUList:SetList(suitItems)
end

function CashCartCtrl:renderCommodityItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local cartItemUButton = objectReference:GetRefValue("CartItemUButton")
	local discountUWidget = objectReference:GetRefValue("discountUWidget")
	local discountCountCountDown = objectReference:GetRefValue("discountCountCountDown")
	local discountCountTxt = objectReference:GetRefValue("discountCountTxt")
	local discountCountNumTxt = objectReference:GetRefValue("discountCountNumTxt")
	local newTxt = objectReference:GetRefValue("newTxt")
	local pullUWidget = objectReference:GetRefValue("pullUWidget")
	local pullCountDown = objectReference:GetRefValue("pullCountDown")
	local btnCheckUButton = objectReference:GetRefValue("btnCheckUButton")
	local itemUButton = objectReference:GetRefValue("itemUButton")
	local nameTxt = objectReference:GetRefValue("nameTxt")
	local numberTxt = objectReference:GetRefValue("numberTxt")
	local numSelector = objectReference:GetRefValue("numSelector")
	local moneyUContent = objectReference:GetRefValue("moneyUContent")
	local btnNumberUButton = objectReference:GetRefValue("btnNumberUButton")
	local checkBtnUButton = objectReference:GetRefValue("checkBtnUButton")
	local listUList = objectReference:GetRefValue("listUList")
	local outTimeTxt = objectReference:GetRefValue("outTimeTxt")
	local btnNumberHotkeyWidget = objectReference:GetRefValue("btnNumberHotkeyWidget")
	local statusRoot = cartItemUButton or button
	local baseCommodityStatus, statusTextKey, isCommodityOffShelf = self:_getCommodityStatus(data)
	local commodityStatus = baseCommodityStatus == 2 and data.isEditingCount and 3 or baseCommodityStatus

	statusRoot:TryChangePage("Status", commodityStatus)

	if commodityStatus == 4 and outTimeTxt then
		ClientTextUtils.setText(outTimeTxt, pg.getGameString(statusTextKey or "CASH_CART_OUT"))
	end

	self:refreshSuitAppearanceList(listUList, data)

	local isInDiscount = ClientCashShopUtils.isCommodityInDiscount(data)

	if discountUWidget then
		discountUWidget.gameObject:SetActiveEx(isInDiscount)
	end

	ClientTextUtils.setText(discountCountTxt, pg.getGameString("CASH_CART_DISCOUNT"))

	if discountCountNumTxt then
		ClientTextUtils.setText(discountCountNumTxt, data.specialCostText and pg.getLocalizationText(data.specialCostText) or "")
	end

	local specialEndTime = Utils.getConfigTimeOfArea(data, "specialEndTime")

	if isInDiscount and discountCountCountDown and specialEndTime then
		LuaUIUtils.setCountDownTime(discountCountCountDown, specialEndTime, UIConst.TimeType.OneTime)
	end

	local isNew = data.isNew == 1 or data.tagText ~= nil

	if newTxt then
		newTxt.gameObject:SetActiveEx(isNew)
	end

	if isNew then
		ClientTextUtils.setText(newTxt, pg.getGameString("CASH_CART_NEW"))
	end

	local endTime = Utils.getConfigTimeOfArea(data, "endTime")
	local showEndTimeCountDown = endTime ~= nil and not isCommodityOffShelf

	if pullUWidget then
		pullUWidget.gameObject:SetActiveEx(showEndTimeCountDown)
	end

	if showEndTimeCountDown and pullCountDown then
		LuaUIUtils.setCountDownTime(pullCountDown, endTime, UIConst.TimeType.OneTime)
	end

	local displayItemId = data.itemId

	if displayItemId then
		local playerGender = ClientCashShopUtils.getPlayerGender()

		displayItemId = ClientCashShopUtils.getGenderConvertedItemId(displayItemId, playerGender) or displayItemId
	end

	if itemUButton and displayItemId then
		local displayItemConfig = ItemData[displayItemId]

		LuaUIUtils.renderRewardItem(itemUButton, {
			id = displayItemId,
			num = data.num or 1,
			iconUrl = displayItemConfig and displayItemConfig.icon or nil
		})
	end

	ClientTextUtils.setText(nameTxt, LuaUIUtils.getNameByItemId(data.itemId))

	local maxCount = self:_getMaxBuyCount(data)

	data.buyCount = math.min(math.max(1, data.buyCount or 1), maxCount)

	self.model:setCommodityCount(data.commodityId, data.buyCount)

	local displayCount = data.isEditingCount and data.pendingBuyCount or data.buyCount

	displayCount = math.min(math.max(1, tonumber(displayCount) or 1), maxCount)

	ClientTextUtils.setText(numberTxt, string.format("x%d", displayCount))
	self:_refreshCommodityCount(data, moneyUContent, isInDiscount, displayCount)

	if numSelector then
		numSelector:SetAllValue(displayCount, 1, maxCount, 1, false)

		function numSelector.luaValueChanged(value)
			local finalCount = self:_refreshCommodityCount(data, moneyUContent, isInDiscount, value)

			data.pendingBuyCount = finalCount

			ClientTextUtils.setText(numberTxt, string.format("x%d", finalCount))
		end
	end

	if btnCheckUButton then
		btnCheckUButton.luaClick = nil

		function btnCheckUButton.luaSelectChanged(isSelected)
			if self._syncingCommoditySelectButton then
				return
			end

			self:_setCommoditySelected(btnCheckUButton, data, isSelected)
		end
	end

	if cartItemUButton then
		cartItemUButton.luaClick = nil
	end

	if btnNumberUButton then
		btnNumberUButton.luaClick = baseCommodityStatus == 2 and function()
			self:beginCommodityCountEditing(statusRoot, numSelector, data, maxCount)

			self.selectNumber = true

			self:refreshConsoleBarState()
		end or nil

		if btnNumberHotkeyWidget then
			btnNumberHotkeyWidget:SetForceInactive(CS.XGUI.ForceInactiveSource.Business, commodityStatus ~= 2)
		end
	end

	if checkBtnUButton then
		checkBtnUButton.luaClick = baseCommodityStatus == 2 and function()
			self:confirmCommodityCount(data, maxCount)

			self.selectNumber = false

			self:refreshConsoleBarState()
		end or nil
	end

	self:_refreshCommoditySelected(btnCheckUButton, data)
end

function CashCartCtrl:refreshConsoleBarState()
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("PopManageCartSelect", self.selectNumber ~= true)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("PopManageCartConfirm", self.selectNumber == true)
end

function CashCartCtrl:onHide()
	self._deleteRequestToken = self._deleteRequestToken + 1
	self._buyRequestToken = self._buyRequestToken + 1
	self._deleteRequestPending = false
	self._buyRequestPending = false
	self._requestLifecycleToken = self._requestLifecycleToken + 1
end

return CashCartCtrl
