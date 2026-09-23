-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashShop\\Component\\TradeMarket\\TradeMarketComponent.lua

local Class = require("Core.Framework.Class")
local CashShopContainerComponent = require("Guis.Panels.CashShop.Component.CashShopContainerComponent")
local TradeMarketPetListComponent = require("Guis.Panels.CashShop.Component.TradeMarket.TradeMarketPetListComponent")
local TradeMarketItemListComponent = require("Guis.Panels.CashShop.Component.TradeMarket.TradeMarketItemListComponent")
local TradeMarketUtils = require("Guis.Utils.TradeMarketUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TradeMarketComponent = Class.LightClass("TradeMarketComponent", CashShopContainerComponent)

function TradeMarketComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	local objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")

	self.listTabUList = objectReference:GetRefValue("listTabUList")
	self.tabAppearanceUContainer = objectReference:GetRefValue("tabAppearanceUContainer")
	self.tabPetUContainer = objectReference:GetRefValue("tabPetUContainer")
end

function TradeMarketComponent:addListener()
	self._tabListData = TradeMarketUtils.getSubTabData()

	function self.listTabUList.luaRenderItem(button, index, data)
		TradeMarketUtils.renderSubTabItem(button, index, data)
		button:SetSelected(data.subPageType == self._currentSubPageType)
	end

	function self.listTabUList.luaClick(button, data)
		self:switchSubPage(data.subPageType)
	end

	self.listTabUList:SetList(self._tabListData)

	function self.view.btnInfoUButton.luaClick()
		pg.global.ui.tips:openCommonPopUpTipById(43)
	end
end

function TradeMarketComponent:onEnterPage(tabId)
	self.categoryId = tabId

	self.refUContainer:SetActive(true)
	self:_refreshTitleLayout(true)

	if not self._contentLoaded then
		if self.refUContainer:CheckURLLoaded() then
			self:_onContentLoaded()
		else
			self.refUContainer:LoadDefaultUrlManually(function()
				self:_onContentLoaded()
			end)
		end
	else
		self:refreshPage()
	end
end

function TradeMarketComponent:_onContentLoaded()
	self._contentLoaded = true

	self:findObjects()
	self:addListener()
	self:refreshPage()
end

function TradeMarketComponent:refreshPage()
	if not self:checkContentLoaded() then
		return
	end

	self._showingModel = false

	self:_syncBackground()
	self:_ensureSubPages()
	self:switchSubPage(self._currentSubPageType or TradeMarketUtils.SubPageType.Goods)
end

function TradeMarketComponent:onBeforeExitPage()
	self:_refreshTitleLayout(false)
	self:_exitCurrentSubPage()
	CashShopContainerComponent.onBeforeExitPage(self)
end

function TradeMarketComponent:onDestroy()
	CashShopContainerComponent.onDestroy(self)

	self._subPages = nil
	self._curSubPage = nil
end

function TradeMarketComponent:_refreshTitleLayout(isShow)
	self.view.btnInfoUButton:SetActive(isShow)

	self.view.btnInfoUButton.enabledTooltip = false
end

function TradeMarketComponent:_ensureSubPages()
	if self._subPages then
		return
	end

	self._subPages = {}

	self:_createSubPage(TradeMarketUtils.SubPageType.Pet, TradeMarketPetListComponent, self.tabPetUContainer)
	self:_createSubPage(TradeMarketUtils.SubPageType.Goods, TradeMarketItemListComponent, self.tabAppearanceUContainer)
end

function TradeMarketComponent:_createSubPage(pageType, cls, uComponent)
	if not uComponent then
		return
	end

	local component = cls.new(self, uComponent)

	self._subPages[pageType] = component
end

function TradeMarketComponent:switchSubPage(pageType)
	if self._currentSubPageType == pageType and self._curSubPage then
		self._curSubPage:refreshPage()

		return
	end

	self:_exitCurrentSubPage()

	self._currentSubPageType = pageType
	self._curSubPage = self._subPages and self._subPages[pageType] or nil

	if self._curSubPage then
		self._curSubPage:enterPage()
	end

	self:_selectSubTab(pageType)
end

function TradeMarketComponent:_exitCurrentSubPage()
	if self._curSubPage then
		self._curSubPage:exitPage()
	end

	self._curSubPage = nil
end

function TradeMarketComponent:_selectSubTab(pageType)
	if not self.listTabUList or not self._tabListData then
		return
	end

	for i, data in ipairs(self._tabListData) do
		if data.subPageType == pageType then
			self.listTabUList:SelectItem(i - 1, false)

			return
		end
	end
end

return TradeMarketComponent
