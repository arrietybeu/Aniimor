-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketSellGoods\\TradeMarketSellGoodsView.lua

local logger = require("Core.Log.LoggerManager").getLogger("TradeMarketSellGoodsView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TradeMarketSellGoodsView = Class.LightClass("TradeMarketSellGoodsView", UIView)

function TradeMarketSellGoodsView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.titleUSDFText = objectReference:GetRefValue("titleUSDFText")
	self.listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")
	self.leftTitleUSDFText = objectReference:GetRefValue("leftTitleUSDFText")
	self.txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	self.listGoodsUList = objectReference:GetRefValue("listGoodsUList")
	self.searchUTMPInputField = objectReference:GetRefValue("searchUTMPInputField")
	self.listPropsUList = objectReference:GetRefValue("listPropsUList")
	self.btnHistoryUButton = objectReference:GetRefValue("btnHistoryUButton")

	local historyOC = self.btnHistoryUButton:GetComponent("ObjectReference")

	self.btnHistoryTxtNameUText = historyOC:GetRefValue("txtNameUText")

	local searchOC = self.searchUTMPInputField:GetComponent("ObjectReference")

	self.btnSearchUButton = searchOC:GetRefValue("btnSearchUButton")
	self.btnDeleteUButton = searchOC:GetRefValue("btnDeleteUButton")
	self.placeHolderUSDFText = searchOC:GetRefValue("placeHolderUSDFText")
end

function TradeMarketSellGoodsView:registerObjects()
	return
end

function TradeMarketSellGoodsView:initView()
	return
end

return TradeMarketSellGoodsView
