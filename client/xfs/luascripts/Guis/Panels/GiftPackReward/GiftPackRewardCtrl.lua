-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GiftPackReward\\GiftPackRewardCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("GiftPackRewardCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local MessageName = require("Const.MessageName")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local NoticeDef = require("Common.NoticeDef")
local ItemData = require("Data.item_data")
local CashShopConst = require("Const.CashShopConst")
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local CashGiftModel = require("Guis.Panels.CashGift.CashGiftModel")
local CashGiftView = require("Guis.Panels.CashGift.CashGiftView")
local ShopMallCommodityData = require("Data.shopmall_commodity_data")
local ShopmallGiftData = require("Data.shopmall_gift_data")
local Utils = require("Common.Utils.Utils")
local TimeUtils = require("Common.Utils.TimeUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local CashShopRedDotUtils = require("Utils.CashShopRedDotUtils")
local UIConst = require("Const.UIConst")
local GiftPackRewardCtrl = Class.LightClass("GiftPackRewardCtrl", UICtrl)

function GiftPackRewardCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function GiftPackRewardCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.commodityId = info and info.commodityId

	if self.commodityId then
		local commodityData = ShopMallCommodityData[self.commodityId]
		local giftData = ShopmallGiftData[commodityData.itemId]
		local showLimitTag = giftData.limitType == 1

		self.view.tagUWidget.gameObject:SetActiveEx(showLimitTag)
		ClientTextUtils.setText(self.view.tagTxt, showLimitTag and pg.getGameString("CASH_LIMIT_TITLE") or "")

		self.limitItems = giftData.limitItems
		self.view.giftUImage.url = giftData.giftPackIcon

		self.view.root:TryChangePage("Quality", giftData.giftQuality - 1)

		local specialStartTime = Utils.getConfigTimeOfArea(commodityData, "specialStartTime")
		local specialEndTime = Utils.getConfigTimeOfArea(commodityData, "specialEndTime")
		local isInDiscount = specialStartTime and specialEndTime and TimeUtils.isInRangeTimestamp(specialStartTime, specialEndTime)

		if self.view.timeUCountDown then
			local endTime = Utils.getConfigTimeOfArea(commodityData, "endTime")

			if endTime then
				LuaUIUtils.setCountDownTime(self.view.timeUCountDown, endTime, UIConst.TimeType.Short)
			end
		end

		if commodityData.limitNum and commodityData.limitNum > 0 then
			local leftLimit = ClientCashShopUtils.getCommodityLeftLimit(self.commodityId)
			local limitText = string.format("：%d/%d", leftLimit, commodityData.limitNum)
			local limitTypeText = LuaUIUtils.getLimitTitleString(commodityData.limitType)

			ClientTextUtils.setText(self.view.textLimitUBaseText, limitTypeText .. limitText)
		end

		ClientTextUtils.setText(self.view.txtTltleUBaseText, pg.getLocalizationText(giftData.giftPackName))

		local cost = ClientCashShopUtils.getCommodityPrimaryCost(self.commodityId, 1, {
			isInDiscount = isInDiscount
		})
		local costItemId = cost and cost[1] or commodityData.cost[1][1]
		local costItemCount = cost and cost[2] or commodityData.cost[1][2]

		self.commodityCost = cost
		self.view.costIconUImage.url = ItemData[costItemId].icon

		ClientTextUtils.setText(self.view.costTextUBaseText, costItemCount)
		ClientTextUtils.setText(self.view.btnBuyTxtNameUText, pg.getGameString("SHOP_BUY"))
		ClientTextUtils.setText(self.view.textContentBaseText, pg.getGameString("SHOPMALL_GOODS_TEXT"))

		local itemList = {}

		for _, item in ipairs(giftData.FixItems) do
			table.insert(itemList, {
				id = item[1],
				num = item[2]
			})
		end

		self.rewardData = itemList

		self.view.listItemUList:SetList(itemList)
		CashShopRedDotUtils.markSeasonGiftPackRead(self.commodityId)
	end
end

function GiftPackRewardCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function GiftPackRewardCtrl:onShow()
	return
end

function GiftPackRewardCtrl:onHide()
	return
end

function GiftPackRewardCtrl:requestBuyItem(commodityId, cost, count, giftSelectItemIds, rewardData, callback)
	ClientCashShopUtils.openBuyConfirm(commodityId, cost, count, giftSelectItemIds, rewardData, callback)
end

function GiftPackRewardCtrl:addListener()
	function self.view.listItemUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderItem(button, data)

		local objectReference = button:GetComponent("ObjectReference")
		local tagUWidget = objectReference:GetRefValue("tagUWidget")
		local tagTxt = objectReference:GetRefValue("tagTxt")
		local showLimitTag = Utils.isTable(self.limitItems) and table.contains(self.limitItems, data.id)

		if tagUWidget then
			tagUWidget.gameObject:SetActiveEx(showLimitTag)
		end

		if tagTxt then
			ClientTextUtils.setText(tagTxt, showLimitTag and pg.getGameString("CASH_LIMIT_TITLE") or "")
		end
	end

	function self.view.btnBuyUButton.luaClick()
		self:requestBuyItem(self.commodityId, self.commodityCost, 1, {}, self.rewardData, function(retStatus)
			if retStatus == 0 then
				pg.global.ui:close(UIConst.UI_ID_GIFT_PACK_REWARD)
			end
		end)
	end

	function self.view.btnCloseUButton.luaClick()
		pg.global.ui:close(UIConst.UI_ID_GIFT_PACK_REWARD)
	end

	function self.view.btnCloseBGUButton.luaClick()
		pg.global.ui:close(UIConst.UI_ID_GIFT_PACK_REWARD)
	end
end

return GiftPackRewardCtrl
