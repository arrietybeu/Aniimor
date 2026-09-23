-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketGoodsDetail\\TradeMarketGoodsDetailView.lua

local logger = require("Core.Log.LoggerManager").getLogger("TradeMarketGoodsDetailView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TradeMarketGoodsDetailView = Class.LightClass("TradeMarketGoodsDetailView", UIView)

function TradeMarketGoodsDetailView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.titleUSDFText = objectReference:GetRefValue("titleUSDFText")
	self.listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")
	self.listTabUList = objectReference:GetRefValue("listTabUList")
	self.btnRefreshUButton = objectReference:GetRefValue("btnRefreshUButton")
	self.txtTipsUSDFText = objectReference:GetRefValue("txtTipsUSDFText")
	self.listGoodsUList = objectReference:GetRefValue("listGoodsUList")
	self.btnEllipsesUButton = objectReference:GetRefValue("btnEllipsesUButton")
	self.propsUContainer = objectReference:GetRefValue("propsUContainer")
	self.appearanceUContainer = objectReference:GetRefValue("appearanceUContainer")
	self.iconPropUImage = objectReference:GetRefValue("iconPropUImage")
	self.btnClickShowUButton = objectReference:GetRefValue("btnClickShowUButton")
	self.btnSortUButton = objectReference:GetRefValue("btnSortUButton")
	self.txtRefreshUSDFText = objectReference:GetRefValue("txtRefreshUSDFText")
	self.txtSortUSDFText = objectReference:GetRefValue("txtSortUSDFText")
	self.emptyUWidget = objectReference:GetRefValue("emptyUWidget")
	self.txtEmptyUSDFText = objectReference:GetRefValue("txtEmptyUSDFText")
end

function TradeMarketGoodsDetailView:registerObjects()
	return
end

function TradeMarketGoodsDetailView:initView()
	return
end

return TradeMarketGoodsDetailView
