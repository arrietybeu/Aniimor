-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LotteryShop\\LotteryShopCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("LotteryShopCtrl")
local Class = require("Core.Framework.Class")
local ShopCtrl = require("Guis.Panels.Shop.ShopCtrl")
local LotteryShopModel = require("Guis.Panels.LotteryShop.LotteryShopModel")
local GachaEntryData = require("Data.gacha_entry_data")
local Utils = require("Common.Utils.Utils")
local LotteryUtils = require("Utils.LotteryUtils")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local Time = require("Core.Common.Time")
local LotteryShopCtrl = Class.LightClass("LotteryShopCtrl", ShopCtrl)

LotteryShopCtrl.modelClz = LotteryShopModel
LotteryShopCtrl.messages = ShopCtrl.messages

function LotteryShopCtrl:checkOpenExtra(info)
	return LotteryUtils.isOpen(Utils.isTable(info) and info.drawId or nil)
end

function LotteryShopCtrl:buildShopOpenInfo(info)
	local drawId = Utils.isTable(info) and tonumber(info.drawId) or nil
	local entryConfig = drawId and GachaEntryData[drawId] or nil

	if not Utils.isTable(entryConfig) then
		logger:error("抽奖商店入口配置不存在, drawId=%s", tostring(drawId))

		return nil
	end

	local shopId = tonumber(entryConfig.shopId)
	local specialShopTagId = tonumber(entryConfig.shopItemId)

	if not shopId or not specialShopTagId then
		logger:error("抽奖商店配置缺少 shopId 或 shopItemId, drawId=%s, shopId=%s, shopItemId=%s", tostring(drawId), tostring(entryConfig.shopId), tostring(entryConfig.shopItemId))

		return nil
	end

	local shopInfo = {}

	for key, value in pairs(info) do
		shopInfo[key] = value
	end

	shopInfo.shopTags = {
		shopId
	}
	shopInfo.shopTag = nil
	shopInfo.shopItemId = tonumber(info.commodityId)
	shopInfo.specialShopTagId = specialShopTagId

	return shopInfo
end

function LotteryShopCtrl:open(info, cb, closeCb, sceneParams, onSceneLoadedCb, forceNoBlack)
	local shopInfo = self:buildShopOpenInfo(info)

	if not shopInfo then
		if closeCb then
			closeCb()
		end

		return
	end

	LotteryShopCtrl.super.open(self, shopInfo, cb, closeCb, sceneParams, onSceneLoadedCb, forceNoBlack)
end

function LotteryShopCtrl:_rebuildShopContext(info)
	LotteryShopCtrl.super._rebuildShopContext(self, info)

	self.specialShopTagId = Utils.isTable(info) and tonumber(info.specialShopTagId) or nil
	self.drawId = Utils.isTable(info) and tonumber(info.drawId) or nil
	self.entryConfig = self.drawId and GachaEntryData[self.drawId] or nil
end

function LotteryShopCtrl:onOpen(info)
	local previousSpecialShopTagId = self.specialShopTagId

	self.specialShopTagId = Utils.isTable(info) and tonumber(info.specialShopTagId) or nil
	self.drawId = Utils.isTable(info) and tonumber(info.drawId) or nil
	self.entryConfig = self.drawId and GachaEntryData[self.drawId] or nil

	LotteryShopCtrl.super.onOpen(self, info)

	if previousSpecialShopTagId ~= self.specialShopTagId then
		self:refreshVisibleShopList()
	end
end

function LotteryShopCtrl:getNavigationListenerName()
	return "LotteryShop"
end

function LotteryShopCtrl:addListener()
	LotteryShopCtrl.super.addListener(self)

	function self.view.listLottery.luaRenderItem(button, index, data)
		self:renderLotteryShopItem(button, index, data)
	end
end

function LotteryShopCtrl:partitionBuyShopListItems(shopTagType, shopItems)
	if tonumber(shopTagType) == self.specialShopTagId then
		return {}, shopItems
	end

	return shopItems, {}
end

function LotteryShopCtrl:onBuyShopListRefreshed(shopTagType, extensionItems, selectedExtensionIndex)
	local isLotteryList = tonumber(shopTagType) == self.specialShopTagId

	self.view.listLottery.gameObject:SetActiveEx(isLotteryList)
	self.view.listLottery:SetList(isLotteryList and extensionItems or {})

	if isLotteryList and selectedExtensionIndex ~= nil then
		self.view.listLottery:SelectItem(selectedExtensionIndex)
	end
end

function LotteryShopCtrl:refreshLotteryShopList()
	if self.view and self.view.listLottery then
		self.view.listLottery:RefreshList()
	end
end

function LotteryShopCtrl:onBuyItemsCallback(data)
	LotteryShopCtrl.super.onBuyItemsCallback(self, data)
	self:refreshLotteryShopList()
end

function LotteryShopCtrl:onMoneyChanged(data)
	LotteryShopCtrl.super.onMoneyChanged(self, data)
	self:refreshLotteryShopList()
end

function LotteryShopCtrl:onHomelandWarehouseItemChanged(data)
	LotteryShopCtrl.super.onHomelandWarehouseItemChanged(self, data)
	self:refreshLotteryShopList()
end

function LotteryShopCtrl:onRefreshList()
	LotteryShopCtrl.super.onRefreshList(self)
	self:refreshLotteryShopList()
end

function LotteryShopCtrl:renderLotteryShopItem(button, index, data)
	local shopItemConfig = self.model:getShopItemConfig(data.id)

	if not Utils.isTable(shopItemConfig) then
		logger:error("抽奖商店商品配置不存在, shopItemId=%s", tostring(data.id))

		return
	end

	local itemConfig = self.model:getItemConfig(shopItemConfig.itemId)

	if not Utils.isTable(itemConfig) then
		logger:error("抽奖商店道具配置不存在, itemId=%s", tostring(shopItemConfig.itemId))

		return
	end

	local itemComs = self.view:getLotteryShopItemComs(button)
	local itemName = pg.getLocalizationText(itemConfig.itemName)

	if (tonumber(shopItemConfig.itemNum) or 1) > 1 then
		itemName = string.format("%s ×%d", itemName, shopItemConfig.itemNum)
	end

	ClientTextUtils.setText(itemComs.txtTitle, itemName)

	local hasLimit, limitTitle, limitHadBuyCount, limitTotalCount = self.model:getShopItemLimitInfo(shopItemConfig, data.id)
	local limitText = ""

	if hasLimit then
		local leftCount = math.max(0, (limitTotalCount or 0) - (limitHadBuyCount or 0))
		local limitCountText = string.format("%d/%d", leftCount, limitTotalCount or 0)

		limitText = limitTitle ~= "" and string.format("%s%s", limitTitle, limitCountText) or limitCountText
	end

	ClientTextUtils.setText(itemComs.txtTips, limitText)

	local cost = self.model:getBuyPriceInfo(data.id, 1)
	local firstCost = Utils.isTable(cost) and cost[1] or nil

	if Utils.isTable(firstCost) then
		local costNum = firstCost[2] or 0

		itemComs.imgCost.url = LuaUIUtils.getIconByItemId(firstCost[1], LuaUIUtils.ITEM_ICON_TYPE.ICON_SMALL)

		local costColor = costNum <= self.model:getCostItemOwnCount(firstCost[1]) and "" or "<color=#F67574>"

		ClientTextUtils.setText(itemComs.txtBaseCost, costColor, LuaUIUtils.formatShortItemNum(costNum))
	else
		ClientTextUtils.setText(itemComs.txtBaseCost, 0)
	end

	local commodityBanner = ClientCashShopUtils.getCommodityBannerByGender(shopItemConfig)

	if not string.isNilOrEmpty(commodityBanner) then
		itemComs.iconUImage.url = commodityBanner
	else
		itemComs.iconUImage.url = LuaUIUtils.getIconByIconId(itemConfig.icon)
	end

	local isLocked = not self.model:isPropUnlock(data.id)
	local isSellOut = self.model:isPropSellOut(data.id)
	local state = 0

	if isLocked then
		state = 1
	elseif isSellOut then
		state = 2
	end

	button:TryChangePage("State", state)

	if isLocked then
		ClientTextUtils.setText(itemComs.textLocke, self.model:getPropUnlockDesc(shopItemConfig))
	elseif isSellOut then
		ClientTextUtils.setText(itemComs.textLocke, pg.getGameString("CASH_SHOP_SOLD_OUT"))
	else
		ClientTextUtils.setText(itemComs.textLocke, "")
	end

	function button.luaClick()
		button.isSelected = true

		self.shopBuyComponent:onShowBuyShopItemDetail(data.id)
	end

	button.name = tostring(data.id)

	self:renderLotteryShopItemSpecial(button, index, data, itemComs, shopItemConfig, itemConfig)
end

function LotteryShopCtrl:renderLotteryShopItemSpecial(button, index, data, itemComs, shopItemConfig, itemConfig)
	local objectReference = button:GetComponent("ObjectReference")
	local layoutBoxUWidget = objectReference:GetRefValue("layoutBoxUWidget")
	local textDiscount = objectReference:GetRefValue("textDiscount")
	local discountCountdownUWidget = objectReference:GetRefValue("discountCountdownUWidget")
	local countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")
	local textDiscountTime = objectReference:GetRefValue("textDiscountTime")

	ClientTextUtils.setText(textDiscountTime, pg.getGameString("CASH_SHOP_DISCOUNT_TIME"))

	local _, originalCost = self.model:getBuyPriceInfo(data.id, 1)
	local hasDiscount = originalCost ~= nil
	local discountText = hasDiscount and shopItemConfig.tagName and pg.getLocalizationText(shopItemConfig.tagName) or ""

	layoutBoxUWidget:SetActive(hasDiscount)
	ClientTextUtils.setText(textDiscount, discountText)

	countDownUCountDown.luaFinished = nil

	countDownUCountDown:Stop()

	local closeTime = Utils.isTable(self.entryConfig) and Utils.getConfigTimeOfArea(self.entryConfig, "closeTime") or nil
	local showCountDown = closeTime ~= nil and closeTime > Time.getSecond()

	discountCountdownUWidget:SetActive(showCountDown)
	countDownUCountDown:SetActive(showCountDown)

	if showCountDown then
		function countDownUCountDown.luaFinished()
			discountCountdownUWidget:SetActive(false)
			countDownUCountDown:SetActive(false)
		end

		LuaUIUtils.setCountDownTime(countDownUCountDown, closeTime, UIConst.TimeType.Short)
	end
end

return LotteryShopCtrl
