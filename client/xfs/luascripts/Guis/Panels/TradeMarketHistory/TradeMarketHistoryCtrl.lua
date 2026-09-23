-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketHistory\\TradeMarketHistoryCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("TradeMarketHistoryCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TradeMarketUtils = require("Guis.Utils.TradeMarketUtils")
local NoticeDef = require("Common.NoticeDef")
local UIConst = require("Const.UIConst")
local TradeMarketHistoryCtrl = Class.LightClass("TradeMarketHistoryCtrl", UICtrl)

TradeMarketHistoryCtrl.messages = {
	[MessageName.ON_GET_TRADE_RECORDS] = {
		"onGetTradeRecords",
		true
	}
}

function TradeMarketHistoryCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function TradeMarketHistoryCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:dismiss()
	end

	function self.view.listTabUList.luaRenderItem(button, index, data)
		TradeMarketUtils.renderSubTabItem(button, index, data)
	end

	function self.view.listTabUList.luaClick(button, data)
		self:switchSubPageType(data.subPageType)
	end

	function self.view.listTab3thUList.luaRenderItem(button, index, data)
		self:renderHistoryTab(button, index, data)
	end

	function self.view.listTab3thUList.luaClick(button, data)
		self:switchHistoryType(data.historyType)
	end

	function self.view.listPetUList.luaRenderItem(button, index, data)
		TradeMarketUtils.renderPetItem_History(button, index, data)
	end

	function self.view.listPetUList.luaClick(button, data)
		pg.global.ui:open(UIConst.UI_ID_TRADE_MARKET_HISTORY_PET, data)
	end

	function self.view.listPropUList.luaRenderItem(button, index, data)
		TradeMarketUtils.renderGoodsItem_History(button, index, data)
	end

	function self.view.listPropUList.luaClick(button, data)
		pg.global.ui:open(UIConst.UI_ID_TRADE_MARKET_HISTORY_GOODS, data)
	end
end

function TradeMarketHistoryCtrl:onDestroy()
	self.tradeRecordRequests = nil
	self.curList = nil
	self.curSubPageType = nil
	self.curHistoryType = nil

	UICtrl.onDestroy(self)
end

function TradeMarketHistoryCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.tradeRecordRequests = {}

	self.model:clearHistoryData()
	self:initView()
end

function TradeMarketHistoryCtrl:onShow()
	return
end

function TradeMarketHistoryCtrl:onHide()
	return
end

function TradeMarketHistoryCtrl:initView()
	ClientTextUtils.setText(self.view.tMPUSDFText, pg.getGameString("TRADE_HISTORY"))
	ClientTextUtils.setText(self.view.txtEmptyUSDFText, pg.getGameString("NO_TRADE_HISTORY"))
	ClientTextUtils.setText(self.view.txtTipsUSDFText, string.format(pg.getGameString("TRADE_HISTORY_LIMIT_NUM"), TradeMarketUtils.getHistoryMaxCount()))

	self.subTabData = TradeMarketUtils.getSubTabData()
	self.historyData = self.model.getHistoryTabData()

	self.view.listTabUList:SetList(self.subTabData)
	self.view.listTab3thUList:SetList(self.historyData)

	self.curHistoryType = self.model.HistoryType.Buy

	self:switchSubPageType(TradeMarketUtils.SubPageType.Goods)
	self:_refreshHistoryTabView()
end

function TradeMarketHistoryCtrl:switchSubPageType(newSubPageType)
	if newSubPageType == self.curSubPageType then
		return
	end

	self.curSubPageType = newSubPageType

	if self.curList then
		self.curList:SetActive(false)
	end

	if self.curSubPageType == TradeMarketUtils.SubPageType.Goods then
		self.curList = self.view.listPropUList
	elseif self.curSubPageType == TradeMarketUtils.SubPageType.Pet then
		self.view.listPetUList:SetActive(true)

		self.curList = self.view.listPetUList
	end

	self:refreshCurrentList()
	self:requestTradeRecords(self.curSubPageType)
	self:_refreshSubTabView()
end

function TradeMarketHistoryCtrl:_refreshSubTabView()
	for i, data in ipairs(self.subTabData) do
		if data.subPageType == self.curSubPageType then
			self.view.listTabUList:SelectItem(i - 1, false)

			return
		end
	end
end

function TradeMarketHistoryCtrl:switchHistoryType(newHistoryType)
	if newHistoryType == self.curHistoryType then
		return
	end

	self.curHistoryType = newHistoryType

	self:refreshCurrentList()
	self:_refreshHistoryTabView()
end

function TradeMarketHistoryCtrl:refreshCurrentList()
	if not self.curList then
		return
	end

	local data

	if self.curHistoryType == self.model.HistoryType.Buy then
		data = self.model:getBuyHistoryData(self.curSubPageType)
	elseif self.curHistoryType == self.model.HistoryType.Sell then
		data = self.model:getSellHistoryData(self.curSubPageType)
	end

	self:setListData(self.curList, data)
end

function TradeMarketHistoryCtrl:requestTradeRecords(displayType)
	if not displayType or self.model:hasHistoryData(displayType) or self.tradeRecordRequests[displayType] then
		return
	end

	self.tradeRecordRequests[displayType] = true

	pg.me:reqGetTradeRecords(displayType, TradeMarketUtils.getHistoryMaxCount(), 0, function(noticeCode)
		if not self.tradeRecordRequests or not self.tradeRecordRequests[displayType] then
			return
		end

		if noticeCode == NoticeDef.SUCCESS then
			return
		end

		self.tradeRecordRequests[displayType] = nil

		if self.curSubPageType == displayType then
			self:refreshCurrentList()
		end
	end)
end

function TradeMarketHistoryCtrl:onGetTradeRecords(data)
	if not data or (data.offset or 0) ~= 0 or not self.tradeRecordRequests or not self.tradeRecordRequests[data.displayType] then
		return
	end

	local displayType = data.displayType

	self.tradeRecordRequests[displayType] = nil

	self.model:setHistoryData(displayType, data.records, data.total)

	if self.curSubPageType == displayType then
		self:refreshCurrentList()
	end
end

function TradeMarketHistoryCtrl:_refreshHistoryTabView()
	for i, data in ipairs(self.historyData) do
		if data.historyType == self.curHistoryType then
			self.view.listTab3thUList:SelectItem(i - 1, false)

			return
		end
	end
end

function TradeMarketHistoryCtrl:setListData(uList, data)
	data = data or {}

	uList:SetList(data)

	if #data == 0 then
		self.view.emptyUWidget:SetActive(true)
		uList:SetActive(false)
	else
		self.view.emptyUWidget:SetActive(false)
		uList:SetActive(true)
	end
end

function TradeMarketHistoryCtrl:renderHistoryTab(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
	local imgAddUImage = objectReference:GetRefValue("imgAddUImage")

	ClientTextUtils.setText(txtNameUBaseText, pg.getGameString(data.name))
	button:SetSelected(data.historyType == self.curHistoryType)
end

return TradeMarketHistoryCtrl
