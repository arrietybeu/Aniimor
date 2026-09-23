-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandMarket\\HomelandMarketCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandMarketCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local HotkeyConst = require("Const.HotkeyConst")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local UICtrl = require("Guis.UICtrl")
local HomelandInventoryComponent = require("Guis.Panels.HomelandMarket.Component.HomelandInventoryComponent")
local HomelandSaleComponent = require("Guis.Panels.HomelandMarket.Component.HomelandSaleComponent")
local HomelandSpecialOrderComponent = require("Guis.Panels.HomelandMarket.Component.HomelandSpecialOrderComponent")
local HomelandItemToMaterialData = require("Data.homeland_item_to_material_data")
local HomelandMaterialConfigData = require("Data.homeland_material_config_data")
local HomelandConfigData = require("Data.homeland_config_data")
local Const = require("Common.Const.Const")
local FlyFeedbackConst = require("Common.Const.FlyFeedbackConst")
local HomelandMarketCtrl = Class.LightClass("HomelandMarketCtrl", UICtrl)

HomelandMarketCtrl.messages = {
	[MessageName.MONEY_UNBOUND_CHANGE] = {
		"refreshCurrencyList",
		true
	},
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"refreshCurrencyList",
		true
	},
	[MessageName.HOMELAND_ON_SELL_MATERIAL] = {
		"onSellMaterial",
		true
	},
	[MessageName.ITEM_GEN_COUNT_CHANGE] = {
		"onInventoryItemChanged",
		true
	},
	[MessageName.HOMELAND_ITEM_MAP_CHANGED] = {
		"onInventoryItemChanged",
		true
	}
}

function HomelandMarketCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.shopId = info.shopId or 1
	self.shopName = info.shopName or pg.getGameString("HOMELAND_GROCERY")
	self.initOpenTab = info.initOpenTab or 1
	self.inventoryComponent = HomelandInventoryComponent.new(self, nil, {
		currencyItemFilter = Const.HomeCoinItemId
	})
	self.inventory2Component = HomelandInventoryComponent.new(self, nil, {
		currencyItemFilter = Const.HomeDecCoinItemId
	})
	self.saleComponent = HomelandSaleComponent.new(self)
	self.specialOrderComponent = HomelandSpecialOrderComponent.new(self)

	self:refreshPage(self.initOpenTab - 1)
end

function HomelandMarketCtrl:addListener()
	LuaUIUtils.bindHotKey(self.view.backUButton.gameObject, HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel, function()
		self.view.backUButton.luaClick()
	end)

	function self.view.backUButton.luaClick()
		self:dismiss()
	end

	function self.view.listTabIconUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local textUBaseText = objectReference:GetRefValue("textUBaseText")
		local hasIcon = not string.isNilOrEmpty(data.icon)

		if iconUImage then
			iconUImage:SetActive(hasIcon)

			if hasIcon then
				iconUImage.url = data.icon
			end
		end

		if textUBaseText then
			ClientTextUtils.setText(textUBaseText, pg.getGameString(data.text))
		end

		button.visualInteractable = data.isOpen
	end

	function self.view.listTabIconUList.luaClick(button, data)
		if data.func then
			self[data.func](self)
		end
	end
end

function HomelandMarketCtrl:onDestroy()
	self.itemDetailRenderToken = (self.itemDetailRenderToken or 0) + 1

	self.view.coinGeneral:StopCoin()

	self.currencySlotMap = nil
	self.currencyIconMap = nil
	self.materialId = nil
	self.purchaseModuleWidget = nil

	UICtrl.onDestroy(self)
end

function HomelandMarketCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function HomelandMarketCtrl:onShow()
	return
end

function HomelandMarketCtrl:onHide()
	return
end

function HomelandMarketCtrl:getTabList()
	local res = {}
	local inventoryIcon = HomelandConfigData.homeMarketInventoryTabIcon or "$ui_item_1010.png"
	local inventorySpecialIcon = HomelandConfigData.homeMarketInventorySpecialTabIcon or "$ui_item_1011.png"

	table.insert(res, {
		func = "onInventoryClick",
		isOpen = true,
		text = "HOMELAND_MARKET_INVENTORY",
		icon = inventoryIcon,
		component = self.inventoryComponent
	})
	table.insert(res, {
		func = "onInventory2Click",
		isOpen = true,
		text = "HOMELAND_MARKET_INVENTORY_SPECIAL",
		icon = inventorySpecialIcon,
		component = self.inventory2Component
	})

	return res
end

function HomelandMarketCtrl:refreshPage(index)
	ClientTextUtils.setText(self.view.titleUBaseText, pg.getLocalizationText(self.shopName))
	ClientTextUtils.setText(self.view.marketInfoUBaseText, pg.getGameString("HOMELAND_MARKET_INFO"))

	local highPriceStore = pg.me.homelandOrderInfo.highPriceStore[self.shopId]

	if highPriceStore then
		ClientTextUtils.setText(self.view.rateUBaseText, highPriceStore.priceMultiple)
	else
		ClientTextUtils.setText(self.view.rateUBaseText, 1)
	end

	self:refreshCurrencyList()

	local tabList = self:getTabList()

	self.view.listTabIconUList:SetList(tabList)

	if index then
		local res, button = self.view.listTabIconUList:TryGetChildAt(index)

		if not res then
			index = 0
		end
	end

	local res, button = self.view.listTabIconUList:TryGetChildAt(index)

	if res then
		button:OnClickSimulate()
	end
end

function HomelandMarketCtrl:onSaleClick()
	self.view.rootUComponent:TryChangePage("Tab", 0)
	self.saleComponent:onEnterPage()
end

function HomelandMarketCtrl:onInventoryClick()
	self.view.rootUComponent:TryChangePage("Tab", 1)
	self.inventoryComponent:onEnterPage()
end

function HomelandMarketCtrl:onInventory2Click()
	self.view.rootUComponent:TryChangePage("Tab", 1)
	self.inventory2Component:onEnterPage()
end

function HomelandMarketCtrl:onSpecialOrderClick()
	pg.global.showBubbleMessageRaw(pg.getGameString("FUNC_NOT_AVAILABLE"), 3)
	self.specialOrderComponent:onEnterPage()
end

function HomelandMarketCtrl:refreshCurrencyList()
	self.currencySlotMap = self.currencySlotMap or {}
	self.currencyIconMap = self.currencyIconMap or {}

	function self.view.currencyUList.luaRenderItem(button, index, data)
		LuaUIUtils.setTopCurrencyItem(button, data.itemId)

		self.currencySlotMap[data.itemId] = button

		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")

		self.currencyIconMap[data.itemId] = iconUImage.transform
	end

	self.view.currencyUList:SetList({
		{
			itemId = Const.HomeCoinItemId
		},
		{
			itemId = Const.HomeDecCoinItemId
		}
	})
end

function HomelandMarketCtrl:setItemInfoEmpty()
	self.itemDetailRenderToken = (self.itemDetailRenderToken or 0) + 1
	self.materialId = nil
	self.purchaseModuleWidget = nil

	self.view.panelPropInfoUContainer:SetActive(false)
end

function HomelandMarketCtrl:showItemDetail(data, itemCount, availableNum)
	self.itemDetailRenderToken = (self.itemDetailRenderToken or 0) + 1

	local renderToken = self.itemDetailRenderToken

	self.currencyItemId = data.currencyItemId
	self.currencyNum = data.currencyNum
	self.materialId = data.materialId
	self.maxSellCount = math.max(availableNum or 0, 0)
	self.sellCount = self.maxSellCount > 0 and 1 or 0
	self.purchaseModuleWidget = nil

	self.view.panelPropInfoUContainer:SetActive(true)
	LuaUIUtils.renderShopItemInfo(self.view.panelPropInfoUContainer, {
		skipFoldHotkey = true,
		inheritSellPrice = true,
		fromParamCount = true,
		itemId = data.itemId,
		itemCount = itemCount,
		uiStyle = UIConst.ITEM_INFO_STATE.SHOP,
		validate = function()
			return self.model ~= nil and self.itemDetailRenderToken == renderToken
		end
	}, function()
		return self:getSellModuleData(renderToken)
	end)
end

function HomelandMarketCtrl:getSellModuleData(renderToken)
	if not self.materialId or renderToken and self.itemDetailRenderToken ~= renderToken then
		return nil
	end

	local materialId = self.materialId
	local maxSellCount = self.maxSellCount or 0
	local coinCost = {}

	if self.currencyItemId then
		coinCost[1] = {
			self.currencyItemId,
			self:calculateSumPrice()
		}
	end

	return {
		coinIsIncome = true,
		validate = function()
			return self.model ~= nil and self.materialId == materialId and (not renderToken or self.itemDetailRenderToken == renderToken)
		end,
		buyCount = self.sellCount,
		maxCount = maxSellCount,
		minCount = maxSellCount > 0 and 1 or 0,
		coinCost = coinCost,
		itemCost = {},
		isSellOut = maxSellCount <= 0,
		confirmButtonText = pg.getGameString("TITLE_SELL_PROPS"),
		confirmInteractable = maxSellCount > 0,
		onCountChanged = function(value)
			self.sellCount = value

			self:refreshSellStatePanel()
		end,
		onConfirm = function()
			self:onConfirmSell()
		end,
		onRendered = function(content, sellCount)
			self.purchaseModuleWidget = content
			self.sellCount = sellCount
		end
	}
end

function HomelandMarketCtrl:refreshSellStatePanel()
	if IsNil(self.purchaseModuleWidget) then
		return
	end

	ClientCashShopUtils.renderItemInfoPurchase(self.purchaseModuleWidget, self:getSellModuleData(self.itemDetailRenderToken))
end

function HomelandMarketCtrl:onConfirmSell()
	if not self.materialId or (self.sellCount or 0) <= 0 then
		return
	end

	local shopId = self.shopId
	local materialId = self.materialId

	if self:isSelectorCountReachLimit(shopId, materialId) then
		local title = pg.getGameString("HOMELAND_MARKET_REACH_LIMIT_TITLE")
		local desc = pg.getGameString("HOMELAND_MARKET_REACH_LIMIT_DESC")

		ClientUtils.showConfirmRaw(title, desc, function()
			self:requestSellMaterial(shopId, materialId)
		end)
	else
		self:requestSellMaterial(shopId, materialId)
	end
end

function HomelandMarketCtrl:calculateSumPrice()
	local selectorNum = self.sellCount or 0

	if self:isSelectorCountReachLimit(self.shopId, self.materialId) then
		local highPriceCountLeft = self.model:getHighPriceCountLeft(self.shopId, self.materialId)
		local highPriceStore = pg.me.homelandOrderInfo.highPriceStore[self.shopId] or {}
		local rate = highPriceStore.priceMultiple or 1

		return self.currencyNum * highPriceCountLeft + self.currencyNum / rate * (selectorNum - highPriceCountLeft)
	else
		return self.currencyNum * selectorNum
	end
end

function HomelandMarketCtrl:isSelectorCountReachLimit(shopId, materialId)
	if not shopId or not materialId then
		return
	end

	local isHighPrice = self.model:isHighPrice(shopId, materialId)

	if isHighPrice then
		local highPriceCountLeft = self.model:getHighPriceCountLeft(shopId, materialId)

		return highPriceCountLeft < (self.sellCount or 0)
	else
		return false
	end
end

function HomelandMarketCtrl:requestSellMaterial(shopId, materialId)
	local saleFeedback = {
		id = self.currencyItemId,
		count = self:calculateSumPrice()
	}

	pg.me:homelandSellMaterial(pg.me.homelandOrderInfo.updateTs, shopId, materialId, self.sellCount, saleFeedback)
end

function HomelandMarketCtrl:onSellMaterial(saleFeedback)
	ClientUtils.showBubbleMessageRaw(pg.getGameString("HOMELAND_MARKET_SUCCESS"), 3)

	if saleFeedback then
		self:playSellCoinFly(saleFeedback)
	end

	self:refreshCurrencyList()

	local selectedTab = self.view.listTabIconUList.selectedItem

	if selectedTab and selectedTab.component and selectedTab.component.refreshSelectElement then
		selectedTab.component:refreshSelectElement()
	end
end

function HomelandMarketCtrl:playSellCoinFly(saleFeedback)
	local targetIcon = self.currencyIconMap and self.currencyIconMap[saleFeedback.id]

	if not targetIcon then
		return
	end

	local coinGeneral = self.view.coinGeneral

	coinGeneral.subParent = coinGeneral.transform.parent
	coinGeneral.coinIconUrl = LuaUIUtils.getIconByItemId(saleFeedback.id, LuaUIUtils.ITEM_ICON_TYPE.ICON_SMALL)
	coinGeneral.sourcePosition = coinGeneral.transform.position
	coinGeneral.targetPosition = targetIcon.position

	function coinGeneral.luaGeneralCoin()
		pg.game.audio:playEvent(FlyFeedbackConst.SFX_GENERAL)
	end

	function coinGeneral.luaStartFly()
		pg.game.audio:playEvent(FlyFeedbackConst.SFX_START_FLY)
	end

	function coinGeneral.luaEndFly()
		pg.game.audio:playEvent(FlyFeedbackConst.SFX_END_FLY)
	end

	local count = math.ceil(saleFeedback.count / FlyFeedbackConst.ORDER.ICON_COUNT_RATIO)

	count = math.clamp(count, 1, FlyFeedbackConst.ORDER.MAX_ICON_COUNT)

	coinGeneral:PlayCoin(count)
end

function HomelandMarketCtrl:onInventoryItemChanged(info)
	local selectedTab = self.view.listTabIconUList.selectedItem

	if not selectedTab then
		return
	end

	if selectedTab.component == self.saleComponent then
		self.saleComponent:refreshSelectElement()
	elseif selectedTab.component == self.inventoryComponent then
		local index = self.inventoryComponent:tryGetIndexByItemId(info.genId)
		local canSale = self:inventoryCanSale(info.genId, Const.HomeCoinItemId)

		if canSale then
			self.inventoryComponent:refreshElementByIndex(index)
		end
	elseif selectedTab.component == self.inventory2Component then
		local index = self.inventory2Component:tryGetIndexByItemId(info.genId)
		local canSale = self:inventoryCanSale(info.genId, Const.HomeDecCoinItemId)

		if canSale then
			self.inventory2Component:refreshElementByIndex(index)
		end
	elseif selectedTab.component == self.specialOrderComponent then
		-- block empty
	end
end

function HomelandMarketCtrl:inventoryCanSale(itemId, currencyItemFilter)
	local materialId = HomelandItemToMaterialData[itemId]
	local materialInfo = HomelandMaterialConfigData[materialId]

	if materialInfo and self.model:isMaterialInShop(self.shopId, materialId) then
		local price = materialInfo.price or {}

		if currencyItemFilter and price[1] == currencyItemFilter then
			return true
		end
	end

	return false
end

return HomelandMarketCtrl
