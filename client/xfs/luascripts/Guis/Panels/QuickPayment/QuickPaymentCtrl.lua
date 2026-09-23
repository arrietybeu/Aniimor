-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\QuickPayment\\QuickPaymentCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("QuickPaymentCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemData = require("Data.item_data")
local CashShopConst = require("Const.CashShopConst")
local RechargeConst = require("GameApp.Recharge.RechargeConst")
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local QuickPaymentCtrl = Class.LightClass("QuickPaymentCtrl", UICtrl)
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade

QuickPaymentCtrl.messages = {}

function QuickPaymentCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function QuickPaymentCtrl:addListener()
	if self.view.btnClose then
		function self.view.btnClose.luaClick()
			self:dismiss()
		end
	end

	if self.view.btnMask then
		function self.view.btnMask.luaClick()
			self:dismiss()
		end
	end

	if self.view.btnGotoRecharge then
		function self.view.btnGotoRecharge.luaClick()
			self:onClickGotoRecharge()
		end
	end

	if self.view.btnPay then
		function self.view.btnPay.luaClick()
			self:onClickPay()
		end
	end
end

function QuickPaymentCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function QuickPaymentCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.productInfo = info.productInfo
	self.shopItemInfo = info.shopItemInfo
	self.categoryType = info.categoryType
	self.buyCallBack = info.buyCallBack

	self:initTitle()
	self:refreshView()
end

function QuickPaymentCtrl:onShow()
	if PlatformBridgeLuaFacade:supportsCommerce() then
		PlatformBridgeLuaFacade.DisplayStoreIcon(1)
	end
end

function QuickPaymentCtrl:onHide()
	if PlatformBridgeLuaFacade:supportsCommerce() then
		PlatformBridgeLuaFacade.HideStoreIcon()
	end
end

function QuickPaymentCtrl:initTitle()
	ClientTextUtils.setText(self.view.txtTitle, pg.getGameString("CHARGE_QUICK"))
	ClientTextUtils.setText(self.view.txtSlot, pg.getGameString("CHARGE_RECOMMEND"))
	ClientTextUtils.setText(self.view.txtFirst, pg.getGameString("CHARGE_EXTRA"))
	ClientTextUtils.setText(self.view.txtTips, pg.getGameString("CHARGE_GET_AND_BUY"))
	ClientTextUtils.setText(self.view.txtBtnGotoRecharge, pg.getGameString("CHARGE_GO"))
end

function QuickPaymentCtrl:refreshView()
	if not self.productInfo then
		return
	end

	if self.shopItemInfo then
		local shopItemInfo = LuaUIUtils.getItemInfoById(self.shopItemInfo.needCurrencyID)

		if shopItemInfo then
			local itemDes = LuaUIUtils.getItemShowText(self.shopItemInfo.needCurrencyID)
			local shopItemDes = pg.getFormatText("{0}{1}{2}", pg.getGameString("CHARGE_GET_NEED_NUM"), itemDes, pg.getLocalizationText(self.shopItemInfo.needBuyCnt))

			ClientTextUtils.setText(self.view.txtDesc, shopItemDes)
		end

		if self.shopItemInfo.itemId and self.shopItemInfo.itemId > 0 and ItemData[self.shopItemInfo.itemId] then
			local displayGender = self.shopItemInfo.displayGender or ClientCashShopUtils.getPlayerGender()
			local displayItemId = ClientCashShopUtils.getGenderConvertedItemId(self.shopItemInfo.itemId, displayGender) or self.shopItemInfo.itemId

			self.view.itemShow:SetActive(true)
			LuaUIUtils.renderRewardItem(self.view.itemShow, {
				num = self.shopItemInfo.itemNum,
				id = displayItemId
			})
		else
			self.view.itemShow:SetActive(false)
		end
	end

	local cfg = self.productInfo.cfgInfo

	if not cfg then
		return
	end

	if self.productInfo.isFirst and cfg.firstTmieGift then
		self.view.txtFirst:SetActive(true)

		if self.view.firstBgUImage then
			self.view.firstBgUImage:SetActive(true)
		end

		if self.productInfo.isFirst then
			local itemDes = LuaUIUtils.getItemShowText(cfg.firstTmieGift[1])
			local shopItemDes = pg.getFormatText("{0}{1}{2}", pg.getGameString("CHARGE_EXTRA"), itemDes, pg.getLocalizationText(cfg.firstTmieGift[2]))

			ClientTextUtils.setText(self.view.txtFirst, shopItemDes)
		end
	else
		self.view.txtFirst:SetActive(false)

		if self.view.firstBgUImage then
			self.view.firstBgUImage:SetActive(false)
		end
	end

	if cfg and cfg.iconBuy then
		self.view.iconMainReward.url = cfg.iconBuy
	end

	if cfg.getCurrency then
		local itemInfo = LuaUIUtils.getItemInfoById(cfg.getCurrency[1])

		if itemInfo then
			ClientTextUtils.setText(self.view.txtRewardName, itemInfo.name)

			local strNum = pg.getFormatText("×{0}", pg.getLocalizationText(cfg.getCurrency[2]))

			ClientTextUtils.setText(self.view.txtRewardNum, strNum)
		end
	end

	if cfg.extraGift then
		local extrItemInfo = LuaUIUtils.getItemInfoById(cfg.extraGift[1])

		if extrItemInfo then
			local strExtr = pg.getFormatText(pg.getGameString("CHARGE_EXTRA_NUM"), pg.getLocalizationText(cfg.extraGift[2]), extrItemInfo.name)

			ClientTextUtils.setText(self.view.txtExtra, strExtr)
			self.view.txtExtra:SetActive(true)
		end
	else
		self.view.txtExtra:SetActive(false)
	end

	local skdInfo = self.productInfo.sdkInfo

	if not skdInfo then
		return
	end

	local strPrice = RechargeUtils.getProductsPrice(self.productInfo)

	ClientTextUtils.setText(self.view.txtPrice, strPrice)
end

function QuickPaymentCtrl:onClickGotoRecharge()
	if not ClientCashShopUtils.canOpenCashShop() then
		return
	end

	self:dismiss()

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_CASH_SHOP) then
		pg.global.ui.cashShop:navigateTo(CashShopConst.CategoryType.RECHARGE)
	elseif pg.global.platform:isPS() and RechargeUtils.isEmptyStore() then
		PlatformBridgeLuaFacade.ShowCommonMessageDialogEmptyStore()
	else
		pg.global.ui:open(UIConst.UI_ID_CASH_SHOP, {
			tabId = CashShopConst.CategoryType.RECHARGE
		})
	end
end

function QuickPaymentCtrl:onClickPay()
	if not self.productInfo or not self.productInfo.productId then
		return
	end

	pg.game.recharge:requestBuy(self.productInfo.packageId, self.productInfo.productId, self.productInfo.cfgInfo.des, self.categoryType, self.buyCallBack)
end

return QuickPaymentCtrl
