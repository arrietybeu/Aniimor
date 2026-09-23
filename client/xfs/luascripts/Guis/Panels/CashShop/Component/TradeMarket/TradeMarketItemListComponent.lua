-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashShop\\Component\\TradeMarket\\TradeMarketItemListComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TradeMarketUtils = require("Guis.Utils.TradeMarketUtils")
local TradeMarketSubPageComponent = require("Guis.Panels.CashShop.Component.TradeMarket.TradeMarketSubPageComponent")
local TradeMarketItemListComponent = Class.LightClass("TradeMarketItemListComponent", TradeMarketSubPageComponent)

TradeMarketItemListComponent.messages = {
	[MessageName.ON_GET_TRADE_OVERVIEW] = {
		"onGetTradeOverview",
		true
	},
	[MessageName.ON_TRADE_FOLLOW_CHANGED] = {
		"onTradeFollowChanged",
		true
	}
}

function TradeMarketItemListComponent:enterPage()
	TradeMarketSubPageComponent.enterPage(self)
	pg.me:reqGetTradeOverview(TradeMarketUtils.SubPageType.Goods, 0, function()
		return
	end)
end

function TradeMarketItemListComponent:onTradeFollowChanged()
	if self._entered and self._contentLoaded and self._currentSubTabData then
		self:refreshGoodsData(self._currentSubTabData)
	end
end

function TradeMarketItemListComponent:onGetTradeOverview(data)
	if not data or data.displayType ~= TradeMarketUtils.SubPageType.Goods or (data.displaySubType or 0) ~= 0 then
		return
	end

	self.tradeOverviewData = data.items or {}

	if self._entered and self._contentLoaded then
		self:refreshPage()
	end
end

function TradeMarketItemListComponent:_findObjectRef()
	local objectReference = self.refUContainer.content:GetComponent("ObjectReference")
	local searchObjectReference = objectReference:GetRefValue("searchObjectReference")

	self.btnSellUButton = objectReference:GetRefValue("btnSellUButton")
	self.listSubTabUList = objectReference:GetRefValue("listSubTabUList")
	self.listGoodsUList = objectReference:GetRefValue("listGoodsUList")
	self.searchUTMPInputField = objectReference:GetRefValue("searchUTMPInputField")
	self.btnSearchUButton = searchObjectReference:GetRefValue("btnSearchUButton")
	self.btnDeleteUButton = searchObjectReference:GetRefValue("btnDeleteUButton")
	self.placeHolderUSDFText = searchObjectReference:GetRefValue("placeHolderUSDFText")
	self.listGoodsUList.poolMode = 0

	local btnOC = self.btnSellUButton:GetComponent("ObjectReference")
	local btnSellTxtNameUText = btnOC:GetRefValue("txtNameUText")

	ClientTextUtils.setText(btnSellTxtNameUText, pg.getGameString("CONSIGNMENT"))
	ClientTextUtils.setText(self.placeHolderUSDFText, pg.getGameString("CHAT_TIP_INPUT_ITEM_NAME"))
	self:_refreshSearchState("")
end

function TradeMarketItemListComponent:_addObjectListener()
	function self.searchUTMPInputField.luaEndEdit(text)
		self:searchGoods(text)
	end

	function self.searchUTMPInputField.luaValueChanged(text)
		self:_refreshSearchState(text)
		self:searchGoods(text)
	end

	function self.btnSearchUButton.luaClick()
		self:searchGoods(self.searchUTMPInputField.text)
	end

	function self.btnDeleteUButton.luaClick()
		self.searchUTMPInputField:SetTextWithoutNotify("")
		self:_refreshSearchState("")
		self:searchGoods("")
	end

	function self.btnSellUButton.luaClick()
		self:openSellPage()
	end

	function self.listSubTabUList.luaRenderItem(button, index, data)
		self:onRenderSubTabItem(button, index, data)
	end

	function self.listSubTabUList.luaClick(button, data)
		self:switchSubTab(data)
	end

	function self.listGoodsUList.luaRenderItem(button, index, data)
		TradeMarketUtils.renderGoodsItem(button, index, data)
	end

	function self.listGoodsUList.luaClick(button, data)
		self:openGoodsDetailPage(data)
	end

	self.subTabData = self:_getSubTabData()

	self.listSubTabUList:SetList(self.subTabData)
end

function TradeMarketItemListComponent:refreshPage()
	local initIndex = self._currentSubTabIndex or 1

	self:switchSubTab(self.subTabData[initIndex])
end

function TradeMarketItemListComponent:openSellPage()
	pg.global.ui:open(UIConst.UI_ID_TRADE_MARKET_SELL_GOODS)
end

function TradeMarketItemListComponent:onRenderSubTabItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
	local imgAddUImage = objectReference:GetRefValue("imgAddUImage")

	ClientTextUtils.setText(txtNameUBaseText, pg.getGameString(data.name))
	button:SetSelected(data.subIndex == self._currentSubTabIndex)
end

function TradeMarketItemListComponent:switchSubTab(data)
	self._currentSubTabData = data

	if self._currentSubTabIndex == data.subIndex then
		self:refreshGoodsData(data)

		return
	end

	self._currentSubTabIndex = data.subIndex

	self:_selectSubTab(data.subIndex)
	self:refreshGoodsData(data)
end

function TradeMarketItemListComponent:refreshGoodsData(data)
	if data.isFollow then
		self.curGoodsData = self:getFollowGoodsData()
	else
		self.curGoodsData = TradeMarketUtils.getGoodsData(data.subIndex)
	end

	for _, goodsData in ipairs(self.curGoodsData) do
		local tradeItemKey = string.format("%d:%d", TradeMarketUtils.SubPageType.Goods, goodsData.id)
		local overviewData = self.tradeOverviewData and self.tradeOverviewData[tradeItemKey]

		goodsData.count = overviewData and overviewData.count or 0
		goodsData.minPrice = overviewData and overviewData.minPrice or 0
		goodsData.maxPrice = overviewData and overviewData.maxPrice or 0
		goodsData.isFollow = pg.me:isTradeItemFollow(tradeItemKey)
	end

	self:searchGoods(self.searchUTMPInputField.text)
end

function TradeMarketItemListComponent:getFollowGoodsData()
	local ret = {}

	for _, subTabData in ipairs(self.subTabData or EMPTY_TABLE) do
		if not subTabData.isFollow then
			for _, goodsData in ipairs(TradeMarketUtils.getGoodsData(subTabData.subIndex)) do
				local tradeItemKey = string.format("%d:%d", TradeMarketUtils.SubPageType.Goods, goodsData.id)

				if pg.me:isTradeItemFollow(tradeItemKey) then
					ret[#ret + 1] = goodsData
				end
			end
		end
	end

	return ret
end

function TradeMarketItemListComponent:_selectSubTab(subTabIndex)
	for index, data in ipairs(self.subTabData) do
		if data.subIndex == subTabIndex then
			self.listSubTabUList:SelectItem(index - 1, false)

			return
		end
	end
end

function TradeMarketItemListComponent:searchGoods(keyword)
	if string.isNilOrEmpty(keyword) then
		self.listGoodsUList:SetList(self.curGoodsData or {})

		return
	end

	local lowerKeyword = string.lower(keyword)
	local ret = {}

	for _, data in ipairs(self.curGoodsData or EMPTY_TABLE) do
		if data.itemName and string.find(data.itemName, lowerKeyword, 1, true) then
			ret[#ret + 1] = data
		end
	end

	self.listGoodsUList:SetList(ret)
end

function TradeMarketItemListComponent:_refreshSearchState(text)
	self.btnDeleteUButton:SetActive(not string.isNilOrEmpty(text))
end

function TradeMarketItemListComponent:openGoodsDetailPage(data)
	TradeMarketUtils.openGoodsDetailBuyUI(data.id)
end

function TradeMarketItemListComponent:_getSubTabData()
	return TradeMarketUtils.getInnerTabDat(TradeMarketUtils.SubPageType.Goods)
end

return TradeMarketItemListComponent
