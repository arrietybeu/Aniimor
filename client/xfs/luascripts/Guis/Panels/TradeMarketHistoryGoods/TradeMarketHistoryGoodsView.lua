-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketHistoryGoods\\TradeMarketHistoryGoodsView.lua

local logger = require("Core.Log.LoggerManager").getLogger("TradeMarketHistoryGoodsView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TradeMarketHistoryGoodsView = Class.LightClass("TradeMarketHistoryGoodsView", UIView)

function TradeMarketHistoryGoodsView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.titleUSDFText = objectReference:GetRefValue("titleUSDFText")
	self.listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")
	self.propsUContainer = objectReference:GetRefValue("propsUContainer")
	self.appearanceUContainer = objectReference:GetRefValue("appearanceUContainer")
	self.iconPropUImage = objectReference:GetRefValue("iconPropUImage")
	self.coinObjectReference = objectReference:GetRefValue("coinObjectReference")
	self.txtDetailsUSDFText = objectReference:GetRefValue("txtDetailsUSDFText")
	self.reviewUWidget = objectReference:GetRefValue("reviewUWidget")
	self.countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")
	self.imgIcon = self.coinObjectReference:GetRefValue("imgIcon")
	self.txtNum = self.coinObjectReference:GetRefValue("txtNum")
	self.btnClick = self.coinObjectReference:GetRefValue("btnClick")
end

function TradeMarketHistoryGoodsView:registerObjects()
	return
end

function TradeMarketHistoryGoodsView:initView()
	return
end

return TradeMarketHistoryGoodsView
