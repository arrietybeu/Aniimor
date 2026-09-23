-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashShop\\CashShopView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local RedDotConst = require("Const.RedDotConst")
local CashShopRedDotUtils = require("Utils.CashShopRedDotUtils")
local CashShopView = Class.LightClass("CashShopView", UIView)

function CashShopView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.btnBack = objectReference:GetRefValue("btnBack")
	self.btnShoppingCart = objectReference:GetRefValue("btnShoppingCart")
	self.btnSearch = objectReference:GetRefValue("btnSearch")
	self.listCurrency = objectReference:GetRefValue("listCurrency")
	self.listTab = objectReference:GetRefValue("listTab")
	self.txtCashName = objectReference:GetRefValue("txtCashName")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.moneyListUButton = objectReference:GetRefValue("moneyListUButton")
	self.minusBtn = objectReference:GetRefValue("minusBtn")
	self.recommendationUContainer = objectReference:GetRefValue("recommendationUContainer")
	self.appearanceUContainer = objectReference:GetRefValue("appearanceUContainer")
	self.monthCardUContainer = objectReference:GetRefValue("monthlyBattlePassUContainer")
	self.itemUContainer = objectReference:GetRefValue("itemUContainer")
	self.paymentUContainer = objectReference:GetRefValue("paymentUContainer")
	self.exchangeShopsUContainer = objectReference:GetRefValue("exchangeShopsUContainer")
	self.giftPackUContainer = objectReference:GetRefValue("giftPackUContainer")
	self.tradeMarketUContainer = objectReference:GetRefValue("auctionHouseUContainer")
	self.friendNewUComponent = objectReference:GetRefValue("friendNewComponent")
	self.adjustUComponent = objectReference:GetRefValue("adjustUComponent")
	self.maskRayBoxTrans = objectReference:GetRefValue("maskRayBoxTrans")
	self.uWidgetShoppingCartNum = objectReference:GetRefValue("uWidgetShoppingCartNum")
	self.txtShoppingCartNum = objectReference:GetRefValue("txtShoppingCartNum")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	self.vXBlackScreenAnimation = objectReference:GetRefValue("vXBlackScreenAnimation")
	self.vXBlackScreenUWidget = NotNil(self.vXBlackScreenAnimation) and self.vXBlackScreenAnimation.transform:GetComponent("UWidget") or nil
	self._specialSceneBlackScreenToken = 0

	if NotNil(self.vXBlackScreenUWidget) then
		self.vXBlackScreenUWidget:SetActive(false)
	end

	self.friendNewUComponent:SetActive(false)
	self.btnShoppingCart:SetActive(true)
end

function CashShopView:setUIInfo()
	ClientTextUtils.setText(self.txtCashName, pg.getGameString("SHOP_NAME"))
end

function CashShopView:setShoppingCartCommodityCount(commodityCount)
	local count = math.max(0, tonumber(commodityCount) or 0)

	if self.uWidgetShoppingCartNum then
		self.uWidgetShoppingCartNum:SetActive(count > 0)
	end

	if self.txtShoppingCartNum then
		ClientTextUtils.setText(self.txtShoppingCartNum, count)
	end
end

function CashShopView:setFirstTabList(tabList, currentTabId, onTabClick)
	self._tabList = tabList

	function self.listTab.luaRenderItem(button, index, data)
		self:renderFirstTabItem(button, data)
	end

	function self.listTab.luaClick(button, data)
		if onTabClick then
			onTabClick(data.id)
		end
	end

	function self.listTab.luaFinishRender(_)
		self:_syncTabSwitchIndex()
	end

	self.listTab:SetList(tabList)
	self:_selectTabById(currentTabId)
end

function CashShopView:refreshFirstTabSelected(currentTabId)
	self:_selectTabById(currentTabId)
end

function CashShopView:_selectTabById(currentTabId)
	local tabList = self._tabList

	if not tabList then
		return
	end

	for i, tab in ipairs(tabList) do
		if tab.id == currentTabId then
			self.listTab:SelectItem(i - 1, false)
			self.listTab:SetUListSwitchCurrentIndex(i - 1)

			return
		end
	end

	self.listTab:SelectItem(-1, false)
end

function CashShopView:_syncTabSwitchIndex()
	local btns = self.listTab:GetAllButtons()

	if not btns then
		return
	end

	for i = 0, btns.Length - 1 do
		if btns[i].isSelected then
			self.listTab:SetUListSwitchCurrentIndex(i)

			break
		end
	end
end

function CashShopView:renderFirstTabItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtName = objectReference:GetRefValue("txtName")
	local redRoot = objectReference:GetRefValue("redRoot")

	ClientTextUtils.setText(txtName, pg.getLocalizationText(data.name))

	local treePath = string.format(RedDotConst.RedDotPath.CASH_SHOP_TAB_LIST_ITEM, data.id)

	pg.global.setPreViewRedDot(treePath, redRoot, function()
		return CashShopRedDotUtils.getCashShopTabRedDotStyle(data.id)
	end)
end

function CashShopView:refreshCurrencyList(currencyList, currencyClickCb)
	function self.listCurrency.luaRenderItem(button, index, data)
		LuaUIUtils.setTopCurrencyItem(button, data.itemId, nil, nil, nil, {
			enableLongPressTips = true
		})

		if currencyClickCb then
			local defaultClick = button.luaClick

			function button.luaClick()
				if currencyClickCb(data.itemId) then
					return
				end

				if defaultClick then
					defaultClick()
				end
			end
		end
	end

	self.listCurrency:SetList(currencyList or {})
end

function CashShopView:setCurrencyPenaltyVisible(visible)
	if not self.minusBtn then
		return
	end

	self.minusBtn:SetActive(visible)

	if not visible then
		self.minusBtn:CloseTooltip()
	end
end

function CashShopView:setSpecialSceneBlackScreenVisible(visible)
	if IsNil(self.vXBlackScreenUWidget) then
		return
	end

	self._specialSceneBlackScreenToken = self._specialSceneBlackScreenToken + 1

	local requestToken = self._specialSceneBlackScreenToken

	if visible then
		self.vXBlackScreenUWidget:SetActive(true)
		self.vXBlackScreenUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Show)

		return
	end

	if self.vXBlackScreenUWidget:CheckHasEvent(CS.XGUI.EInvokeTime.Hide) then
		self.vXBlackScreenUWidget:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.Hide, function()
			if self._specialSceneBlackScreenToken ~= requestToken or IsNil(self.vXBlackScreenUWidget) then
				return
			end

			self.vXBlackScreenUWidget:SetActive(false)
		end)
	else
		self.vXBlackScreenUWidget:SetActive(false)
	end
end

function CashShopView:setLoadingVisible(visible)
	return
end

return CashShopView
