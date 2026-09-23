-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Shop\\ShopCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ShopBaseCtrl = require("Guis.Panels.Shop.ShopBaseCtrl")
local GrabEggShopComponent = require("Guis.Panels.Shop.Component.GrabEggShopComponent")
local ShopEventData = require("Data.shop_event_data")
local HomelandConfigData = require("Data.homeland_config_data")
local HomeSeasonData = require("Data.home_season_data")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local ShopCtrl = Class.LightClass("ShopCtrl", ShopBaseCtrl)
local GRAB_EGG_SHOP_CLASSIFY_ID = 35

ShopCtrl.messages = {
	[MessageName.SHOP_ON_BUY_ITEMS] = {
		"onBuyItemsCallback",
		true
	},
	[MessageName.SHOP_ON_SELL_ITEMS_BY_GENID] = {
		"onSellItemsCallback",
		true
	},
	[MessageName.MONEY_UNBOUND_CHANGE] = {
		"onMoneyChanged",
		true
	},
	[MessageName.MONEY_COUNT_CHANGE] = {
		"onMoneyChanged",
		true
	},
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"onMoneyChanged",
		true
	},
	[MessageName.HOMELAND_ITEM_MAP_CHANGED] = {
		"onHomelandWarehouseItemChanged",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	},
	[MessageName.GRAB_EGG_TALENT_UNLOCKED] = {
		"onRefreshList",
		true
	},
	[MessageName.EVENT_MYSTERIOUS_MERCHANT_REFRESH] = {
		"onMysteriousMerchantRefresh",
		true
	}
}

function ShopCtrl:onCreate(info)
	ShopCtrl.super.onCreate(self, info)

	if info ~= nil then
		self.sourcePanel = info.sourcePanel
	end

	self:Init()
end

function ShopCtrl:addListener()
	ShopCtrl.super.addListener(self)

	if self.view.minusBtn then
		self.view.minusBtn.enabledTooltip = false
		self.view.minusBtn.luaRenderTooltip = nil

		function self.view.minusBtn.luaClick()
			pg.global.ui:open(UIConst.UI_ID_CASH_SHOP_PENALTY_TIP)
		end
	end
end

function ShopCtrl:onShow()
	ShopCtrl.super.onShow(self)
	self:_refreshCurrencyPenalty()
end

function ShopCtrl:onMoneyChanged(data)
	ShopCtrl.super.onMoneyChanged(self, data)
	self:_refreshCurrencyPenalty()
end

function ShopCtrl:refreshCurrency(shopTagType)
	local currencyItems = ShopCtrl.super.refreshCurrency(self, shopTagType)

	self._displayCurrencyIdSet = {}

	for _, currency in ipairs(currencyItems) do
		self._displayCurrencyIdSet[currency.id] = true
	end

	self:_refreshCurrencyPenalty()
end

function ShopCtrl:_refreshCurrencyPenalty()
	if self.view.minusBtn then
		local hasNegativeCurrencyInBar = false

		for _, currency in ipairs(ItemUtils.getNegativeMoneyList(pg.me)) do
			if self._displayCurrencyIdSet and self._displayCurrencyIdSet[currency.itemId] then
				hasNegativeCurrencyInBar = true

				break
			end
		end

		local shouldShowMinusBtn = self.view.listCoins and self.view.listCoins.gameObject.activeInHierarchy and hasNegativeCurrencyInBar

		self.view.minusBtn:SetActive(shouldShowMinusBtn)
	end
end

function ShopCtrl:_rebuildShopContext(info)
	ShopCtrl.super._rebuildShopContext(self, info)

	local isRogue = info ~= nil and info.shopTags and table.contains(info.shopTags, self.model.RogueBuffClassifyId)
	local isHomelandShop = self.shopId == HomelandConfigData.homelandShopId

	if not isHomelandShop then
		for _, seasonInfo in pairs(HomeSeasonData) do
			if self.shopId == seasonInfo.exchangeShopId or self.shopId == seasonInfo.homePlantShopId then
				isHomelandShop = true

				break
			end
		end
	end

	self.isHomelandShop = isHomelandShop

	if isRogue then
		self.isRogue = true

		self.view.uIPrefabShopPanelUComponent:TryChangePage("ShopType", 1)

		function self.view.btnBuffListUButton.luaClick()
			pg.global.ui:open(UIConst.UI_ID_TOWER_BUFF_DETAIL)
		end

		self:bindHotKey("Hud/RogueBuffDetail", function()
			self.view.btnBuffListUButton.luaClick()
		end, nil, self.view.btnBuffListUButton.gameObject)
		ClientTextUtils.setText(self.view.rogueBuffUBaseText, pg.getGameString("ROGUE_BUFF_LIST"))
	elseif isHomelandShop then
		self.view.uIPrefabShopPanelUComponent:TryChangePage("ShopType", 2)
	else
		self.view.uIPrefabShopPanelUComponent:TryChangePage("ShopType", 0)
	end
end

function ShopCtrl:onOpen(info)
	ShopCtrl.super.onOpen(self, info)
	self:refreshGrabEggShopComponent()

	if Utils.isPlayerInSpaceCatchRogueDungeon(pg.me) then
		self.view.listTabIconUList:SetActiveFastest(false)
	end
end

function ShopCtrl:refreshGrabEggShopComponent()
	local isGrabEggShop = self.shopId == GRAB_EGG_SHOP_CLASSIFY_ID

	if isGrabEggShop and not self.grabEggShopComponent then
		self.grabEggShopComponent = GrabEggShopComponent.new(self, self.view.btnJumpUWidget)
	end

	if self.grabEggShopComponent then
		if isGrabEggShop then
			self.grabEggShopComponent:show()
		else
			self.grabEggShopComponent:hide()
		end
	else
		self.view.btnJumpUWidget:SetActive(false)
	end
end

function ShopCtrl:onDestroy()
	if self.isAFKShop then
		local shopEventCfg = ShopEventData[self.shopId]
		local leaveCfg = shopEventCfg[4]

		if leaveCfg and leaveCfg.sound then
			pg.game.audio:triggerEvent(leaveCfg.sound)
		end

		self:clearAFKShopTimers()
	end

	self:removeNavigationListener()

	if self.sourcePanel == UIConst.UI_ID_TOWER_FAST_TRAIN then
		if pg.global.ui:checkUIOpen(UIConst.UI_ID_TOWER_LEVEL_DETAIL) then
			pg.global.ui.towerLevelDetail:show()
		end

		if pg.global.ui:checkUIOpen(UIConst.UI_ID_TOWER_FAST_TRAIN) then
			pg.global.ui.towerFastTrain:show()
		end
	end

	ShopCtrl.super.onDestroy(self)
end

function ShopCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function ShopCtrl:onVisibleChange(visible)
	if visible then
		self:refreshVisibleShopList()
	end
end

function ShopCtrl:onMysteriousMerchantRefresh(messageBody)
	if self.shopBuyComponent and messageBody then
		self.shopBuyComponent:onMysteriousMerchantRefresh(messageBody.err, messageBody.idList)
	end
end

return ShopCtrl
