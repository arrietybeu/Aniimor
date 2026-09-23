-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashShop\\Component\\PaymentShopsComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("PaymentShopsComponent")
local Class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local CashShopConst = require("Const.CashShopConst")
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local CommonSwitch = require("Common.CommonSwitch")
local CashShopContainerComponent = require("Guis.Panels.CashShop.Component.CashShopContainerComponent")
local PaymentShopsComponent = Class.LightClass("PaymentShopsComponent", CashShopContainerComponent)
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade

function PaymentShopsComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	CashShopContainerComponent.findObjects(self)

	local objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")

	self.listProducts = objectReference:GetRefValue("listProducts")
	self.btnWebPay = objectReference:GetRefValue("btnWebPay")
	self.txtRatingTip = objectReference:GetRefValue("txtRatingTip")
	self.textBtnWebPay = objectReference:GetRefValue("textBtnWebPay")
end

function PaymentShopsComponent:addListener()
	CashShopContainerComponent.addListener(self)

	if self.listProducts then
		function self.listProducts.luaRenderItem(button, index, data)
			self:renderProductItem(button, data)
		end

		function self.listProducts.luaFinishRender()
			self:onProductListEntranceFinished()
		end
	end

	if self.btnWebPay then
		function self.btnWebPay.luaClick()
			self:onClickWebPay()
		end
	end
end

function PaymentShopsComponent:refreshPage()
	self:initTitle()
	self:refreshProductList()
	self:refreshWebPayBtn()
end

function PaymentShopsComponent:refreshWebPayBtn()
	if self.btnWebPay then
		local isVisible = CommonSwitch.CHANNEL_SWITCH
		local _h = self.ctrl and self.ctrl._platformHooks

		if _h and _h.shouldShowWebPayButton then
			local hookVisible = _h.shouldShowWebPayButton(self.ctrl)

			isVisible = (hookVisible == nil or hookVisible) and isVisible
		end

		self.btnWebPay.gameObject:SetActiveEx(isVisible)
	end
end

function PaymentShopsComponent:initTitle()
	ClientTextUtils.setText(self.textBtnWebPay, pg.getGameString("CHARGE_THRIDPARTY"))
	ClientTextUtils.setText(self.txtRatingTip, pg.getGameString("CHARGE_TIP"))
end

function PaymentShopsComponent:refreshProductList()
	local productList = RechargeUtils.getAllProductRechargeDisplayInfo()

	if self.listProducts then
		self.listProducts.navGroupForceNonInteractable = true

		self.listProducts:SetList(productList)
	end
end

function PaymentShopsComponent:onProductListEntranceFinished()
	if not self.listProducts then
		return
	end

	self.listProducts.navGroupForceNonInteractable = false

	if pg.game.input:isUsingGamepad() and pg.global.navMgr then
		pg.global.navMgr:FocusItemInThis(self.listProducts)
	end
end

function PaymentShopsComponent:renderProductItem(button, data)
	if not button or not data then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local txtAwardName = objectReference:GetRefValue("txtAwardName")
	local txtNum = objectReference:GetRefValue("txtNum")
	local txtExtra = objectReference:GetRefValue("txtExtra")
	local txtPrice = objectReference:GetRefValue("txtPrice")
	local firstCashUWidget = objectReference:GetRefValue("firstCashUWidget")
	local txtFirstNum = objectReference:GetRefValue("txtFirstNum")
	local txtFirstTips = objectReference:GetRefValue("txtFirstTips")
	local bonusIcon = objectReference:GetRefValue("bonusIcon")
	local cfg = data.cfgInfo

	if not cfg then
		return
	end

	iconUImage.url = cfg.icon

	button:TryChangePage("level", cfg.effectLevel or 0)

	if data.isFirst and cfg.firstTmieGift then
		firstCashUWidget.gameObject:SetActiveEx(data.isFirst)

		local str = pg.getFormatText(pg.getGameString("SHOP_FRIST_BUY"), pg.getLocalizationText(cfg.firstTmieGift[2]))

		ClientTextUtils.setText(txtFirstNum, str)

		local firstItemInfo = LuaUIUtils.getItemInfoById(cfg.firstTmieGift[1])

		if firstItemInfo then
			local strfirst = pg.getFormatText(pg.getGameString("SHOP_FRIST_BUY"), firstItemInfo.name)

			ClientTextUtils.setText(txtFirstTips, strfirst)
		end
	else
		firstCashUWidget.gameObject:SetActiveEx(false)
	end

	if cfg.getCurrency then
		local itemInfo = LuaUIUtils.getItemInfoById(cfg.getCurrency[1])

		if itemInfo then
			ClientTextUtils.setText(txtAwardName, itemInfo.name)

			local strNum = pg.getFormatText("×{0}", pg.getLocalizationText(cfg.getCurrency[2]))

			ClientTextUtils.setText(txtNum, strNum)
		end
	end

	if cfg.extraGift then
		local extrItemInfo = LuaUIUtils.getItemInfoById(cfg.extraGift[1])

		if extrItemInfo then
			local strExtr = pg.getFormatText(pg.getGameString("CHARGE_EXTRA_NUM"), pg.getLocalizationText(cfg.extraGift[2]), extrItemInfo.name)

			ClientTextUtils.setText(txtExtra, strExtr)
			txtExtra:SetActive(true)

			if bonusIcon then
				bonusIcon.url = extrItemInfo.icon
			end
		end
	else
		txtExtra:SetActive(false)
	end

	local skdInfo = data.sdkInfo

	if not skdInfo then
		return
	end

	local strPrice = RechargeUtils.getProductsPrice(data)

	ClientTextUtils.setText(txtPrice, strPrice)

	function button.luaClick()
		self:onClickBuy(data.packageId, data.productId, cfg.des)
	end
end

function PaymentShopsComponent:onClickBuy(packageId, productId, productDes)
	if not packageId and not productId then
		return
	end

	pg.game.recharge:requestBuy(packageId, productId, productDes, CashShopConst.CategoryType.RECHARGE)
end

function PaymentShopsComponent:onClickWebPay()
	RechargeUtils.openThirdPartyPay()
end

function PaymentShopsComponent:onExitPage()
	CashShopContainerComponent.onExitPage(self)

	self.entered = false

	self:HideStoreIcon()
end

function PaymentShopsComponent:onEnterPage(tabId)
	CashShopContainerComponent.onEnterPage(self, tabId)

	self.entered = true

	self:DisplayStoreIcon()
end

function PaymentShopsComponent:onDestroy()
	CashShopContainerComponent.onDestroy(self)
	self:HideStoreIcon()
end

function PaymentShopsComponent:DisplayStoreIcon()
	pg.setPSIconUIVisiable("PaymentShopsComponent", true)

	if PlatformBridgeLuaFacade:supportsCommerce() then
		PlatformBridgeLuaFacade.DisplayStoreIcon(3)
	end
end

function PaymentShopsComponent:HideStoreIcon()
	if pg.setPSIconUIVisiable("PaymentShopsComponent", false) == false and PlatformBridgeLuaFacade:supportsCommerce() then
		PlatformBridgeLuaFacade.HideStoreIcon()
	end
end

function PaymentShopsComponent:onVisibleChange(visible)
	CashShopContainerComponent.onVisibleChange(self, visible)

	if visible and self.entered then
		self:DisplayStoreIcon()
	else
		self:HideStoreIcon()
	end
end

return PaymentShopsComponent
