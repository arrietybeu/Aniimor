-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SeasonShop\\SeasonShopCtrl.lua

local MessageName = require("Const.MessageName")
local RedDotConst = require("Const.RedDotConst")
local UIConst = require("Const.UIConst")
local Class = require("Core.Framework.Class")
local ShopBaseCtrl = require("Guis.Panels.Shop.ShopBaseCtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local SeasonShopCtrl = Class.LightClass("SeasonShopCtrl", ShopBaseCtrl)
local SEASON_ITEM_STATE = {
	COUNT_DOWN_LOCKED = 2,
	TEXT_LOCKED = 1,
	CURRENCY_LOCKED = 0,
	NORMAL = 3
}
local SEASON_ITEM_SELECTED_STATE = {
	SELECTED = 1,
	UNSELECTED = 0
}

SeasonShopCtrl.messages = {
	[MessageName.SHOP_ON_BUY_ITEMS] = {
		"onBuyItemsCallback",
		true
	},
	[MessageName.MONEY_UNBOUND_CHANGE] = {
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
	}
}

function SeasonShopCtrl:onCreate(info)
	info = self:_resolveOpenInfo(info)

	SeasonShopCtrl.super.onCreate(self, info)
	self:Init()
end

function SeasonShopCtrl:onOpen(info)
	info = self:_resolveOpenInfo(info)

	SeasonShopCtrl.super.onOpen(self, info)
	self:refreshSeasonCountDown()
	self:refreshTitleInfo()
end

function SeasonShopCtrl:checkCanOpen(showNotice, info)
	info = self:_resolveOpenInfo(info)

	if not info or not info.shopTags or not info.shopTags[1] then
		if showNotice ~= false then
			pg.global.showBubbleMessageRaw(pg.getGameString("NO_SHOP_OPEN"), 1)
		end

		return false
	end

	return SeasonShopCtrl.super.checkCanOpen(self, showNotice, info)
end

function SeasonShopCtrl:_resolveOpenInfo(info)
	if info and info.shopTags and info.shopTags[1] then
		return info
	end

	local defaultOpenInfo = self.model:getSeasonShopOpenInfo()

	if not defaultOpenInfo then
		return info
	end

	local resolvedInfo = {}

	for key, value in pairs(info or {}) do
		resolvedInfo[key] = value
	end

	resolvedInfo.shopTags = defaultOpenInfo.shopTags

	return resolvedInfo
end

function SeasonShopCtrl:addListener()
	SeasonShopCtrl.super.addListener(self)

	function self.view.seasonItemUList.luaRenderItem(button, _, data)
		self:_renderSeasonExclusiveItem(button, data)
	end

	function self.view.seasonTimeUCountDown.luaFinished()
		self:refreshSeasonCountDown()
		self:refreshWeeklyShopTabRedDot()
	end
end

function SeasonShopCtrl:_rebuildShopContext(info)
	SeasonShopCtrl.super._rebuildShopContext(self, info)

	self.isAFKShop = false

	self.view.uIPrefabShopPanelUComponent:TryChangePage("Season", 0)
end

function SeasonShopCtrl:getNavigationListenerName()
	return "SeasonShop"
end

function SeasonShopCtrl:onVisibleChange(visible)
	if visible then
		self:refreshVisibleShopList()
		self:refreshSeasonCountDown()
	end
end

function SeasonShopCtrl:_getWeeklyShopTagType()
	local firstShopTag = self.shopBuyComponent and self.shopBuyComponent.shopTags and self.shopBuyComponent.shopTags[1]

	return firstShopTag and firstShopTag.id
end

function SeasonShopCtrl:_isWeeklyShopTag(shopTagType)
	local weeklyShopTagType = self:_getWeeklyShopTagType()

	return weeklyShopTagType ~= nil and shopTagType == weeklyShopTagType
end

function SeasonShopCtrl:_getSeasonShopTagType()
	local seasonShopTag = self.shopBuyComponent and self.shopBuyComponent.shopTags and self.shopBuyComponent.shopTags[2]

	return seasonShopTag and seasonShopTag.id
end

function SeasonShopCtrl:_isSeasonShopTag(shopTagType)
	local seasonShopTagType = self:_getSeasonShopTagType()

	return seasonShopTagType ~= nil and shopTagType == seasonShopTagType
end

function SeasonShopCtrl:refreshSeasonCountDown(shopTagType)
	local seasonTimeUCountDown = self.view.seasonTimeUCountDown
	local selectedShopTagType = shopTagType or self.shopBuyComponent and self.shopBuyComponent.curShopTagType
	local endTime = self:_isWeeklyShopTag(selectedShopTagType) and self.model:getWeeklyShopRefreshTime() or self.model:getSeasonShopActivityEndTime()

	if endTime then
		seasonTimeUCountDown:SetActive(true)
		LuaUIUtils.setCountDownTime(seasonTimeUCountDown, endTime, UIConst.TimeType.Short)
	else
		seasonTimeUCountDown:Stop()
		seasonTimeUCountDown:SetActive(false)
	end
end

function SeasonShopCtrl:onShopTagItemRendered(button, _, data)
	button:ClearRedDot()

	if self:_isWeeklyShopTag(data.id) then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.SEASON_SHOP_WEEKLY_TAB, button, function()
			return self.model:isWeeklyShopTabNew() and RedDotConst.RedDotStyle.NEW or RedDotConst.RedDotStyle.NONE
		end)

		return
	end

	if not self:_isSeasonShopTag(data.id) then
		return
	end

	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.SEASON_SHOP_SEASON_TAB, button, function()
		return self.model:hasNewSeasonExclusiveShopItem() and RedDotConst.RedDotStyle.NEW or RedDotConst.RedDotStyle.NONE
	end)
end

function SeasonShopCtrl:onShopTagSelected(shopTagType)
	if not self:_isWeeklyShopTag(shopTagType) or not self.model:markWeeklyShopTabRead() then
		return
	end

	self:refreshWeeklyShopTabRedDot()
end

function SeasonShopCtrl:refreshWeeklyShopTabRedDot()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.SEASON_SHOP_WEEKLY_TAB)
	self:refreshSeasonShopEntryRedDots()
end

function SeasonShopCtrl:refreshSeasonExclusiveItemRedDot(shopItemId)
	pg.global.refreshRedDotState(string.format(RedDotConst.RedDotPath.SEASON_SHOP_SPECIAL_ITEM, shopItemId))
	self:refreshSeasonShopTabRedDot()
end

function SeasonShopCtrl:refreshSeasonShopTabRedDot()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.SEASON_SHOP_SEASON_TAB)
	self:refreshSeasonShopEntryRedDots()
end

function SeasonShopCtrl:refreshSeasonShopEntryRedDots()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.SEASON_LOBBY_SHOP)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.FUNC_MENU_SEASON_LOBBY)
end

function SeasonShopCtrl:refreshTitleInfo()
	local headerInfo = self.model:getHeaderInfo()
	local seasonTagText = headerInfo.seasonTagTextId or ""

	if type(seasonTagText) == "number" then
		seasonTagText = pg.getLocalizationText(seasonTagText)
	end

	ClientTextUtils.setText(self.view.subTitleUSDFText, seasonTagText)

	if headerInfo.seasonTagIcon ~= "" then
		self.view.subTitleIconUImage.url = headerInfo.seasonTagIcon
	end
end

function SeasonShopCtrl:partitionBuyShopListItems(shopTagType, shopItems)
	return self.model:partitionShopItems(shopItems)
end

function SeasonShopCtrl:onBuyShopListRefreshed(shopTagType, exclusiveItems, selectedExclusiveIndex)
	self:refreshSeasonCountDown(shopTagType)

	local hasExclusiveItems = #exclusiveItems > 0

	self.view.uIPrefabShopPanelUComponent:TryChangePage("Season", hasExclusiveItems and 1 or 0)
	self.view.seasonItemUList:SetList(exclusiveItems)

	if selectedExclusiveIndex ~= nil then
		self.view.seasonItemUList:SelectItem(selectedExclusiveIndex)
	end
end

function SeasonShopCtrl:_clearShopListSelection(shopList)
	if shopList.selectedItem ~= nil then
		shopList:SelectItem(-1, false)

		return
	end

	local buttons = shopList:GetAllButtons()

	for index = 0, buttons.Length - 1 do
		buttons[index]:SetSelected(false)
	end
end

function SeasonShopCtrl:onBuyShopItemPreviewChanged(shopItemId)
	local isExclusiveItem = self.model:isSeasonExclusiveShopItem(shopItemId)

	if isExclusiveItem and self.model:markSeasonExclusiveShopItemRead(shopItemId) then
		self:refreshSeasonExclusiveItemRedDot(shopItemId)
	end

	local deselectedShopList = isExclusiveItem and self.shopBuyComponent.curBuyList or self.view.seasonItemUList

	self:_clearShopListSelection(deselectedShopList)
	self.view.seasonItemUList:RefreshList()
end

function SeasonShopCtrl:_renderSeasonExclusiveItem(button, data)
	button:ClearRedDot()

	local shopItemConfig = self.model:getShopItemConfig(data.id)
	local itemConfig = shopItemConfig and self.model:getDisplayItemConfig(shopItemConfig)

	if not shopItemConfig or not itemConfig then
		return
	end

	local itemComs = self.view:getSeasonExclusiveItemComs(button)

	itemComs.iconUImage.url = LuaUIUtils.getIconByIconId(itemConfig.icon)

	self.shopBuyComponent:refreshSeasonLimitedTag(itemComs, shopItemConfig)

	local itemName = pg.getLocalizationText(itemConfig.itemName)

	if shopItemConfig.itemNum and shopItemConfig.itemNum > 1 then
		itemName = string.format("%s ×%d", itemName, shopItemConfig.itemNum)
	end

	ClientTextUtils.setText(itemComs.itemNameUSDFText, itemName)
	self:_refreshSeasonExclusiveItemCost(itemComs, shopItemConfig, data.id)
	self:_refreshSeasonExclusiveItemState(button, itemComs, data.id, shopItemConfig)

	local selectedState = self.shopBuyComponent.curShopItemId == data.id and SEASON_ITEM_SELECTED_STATE.SELECTED or SEASON_ITEM_SELECTED_STATE.UNSELECTED

	button:TryChangePage("Selected", selectedState)
	pg.global.setPreViewRedDot(string.format(RedDotConst.RedDotPath.SEASON_SHOP_SPECIAL_ITEM, data.id), button, function()
		return self.model:isSeasonExclusiveShopItemNew(data.id) and RedDotConst.RedDotStyle.NEW or RedDotConst.RedDotStyle.NONE
	end)

	button.name = tostring(data.id)

	function button.luaClick()
		button.isSelected = true

		self.shopBuyComponent:onShowBuyShopItemDetail(data.id)
	end
end

function SeasonShopCtrl:_refreshSeasonExclusiveItemCost(itemComs, shopItemConfig, shopItemId)
	local hasCost = self.shopBuyComponent:refreshBuyItemCost(itemComs, shopItemConfig, shopItemId)

	itemComs.costIconUImage:SetActive(hasCost)

	if not hasCost then
		ClientTextUtils.setText(itemComs.costPriceUSDFText, "0")
	end
end

function SeasonShopCtrl:_refreshSeasonExclusiveItemState(button, itemComs, shopItemId, shopItemConfig)
	itemComs.lockUCountDown:Stop()

	if not self.model:isPropUnlock(shopItemId) then
		button:TryChangePage("State", SEASON_ITEM_STATE.TEXT_LOCKED)
		ClientTextUtils.setText(itemComs.lockConditionUSDFText, self.model:getPropUnlockDesc(shopItemConfig) or "")

		return
	end

	if self.model:isPropSellOut(shopItemId) then
		button:TryChangePage("State", SEASON_ITEM_STATE.TEXT_LOCKED)
		ClientTextUtils.setText(itemComs.lockConditionUSDFText, pg.getGameString("CASH_SHOP_SOLD_OUT"))

		return
	end

	button:TryChangePage("State", SEASON_ITEM_STATE.NORMAL)
end

function SeasonShopCtrl:onBuyItemsCallback(data)
	SeasonShopCtrl.super.onBuyItemsCallback(self, data)
	self.view.seasonItemUList:RefreshList()
	self:refreshSeasonShopTabRedDot()
end

function SeasonShopCtrl:onMoneyChanged(data)
	SeasonShopCtrl.super.onMoneyChanged(self, data)
	self.view.seasonItemUList:RefreshList()
	self:refreshSeasonShopTabRedDot()
end

function SeasonShopCtrl:onHomelandWarehouseItemChanged(data)
	SeasonShopCtrl.super.onHomelandWarehouseItemChanged(self, data)
	self.view.seasonItemUList:RefreshList()
	self:refreshSeasonShopTabRedDot()
end

function SeasonShopCtrl:onDestroy()
	self:removeNavigationListener()
	SeasonShopCtrl.super.onDestroy(self)
end

function SeasonShopCtrl:checkUIShowVirtualMouseCursor()
	return false
end

return SeasonShopCtrl
