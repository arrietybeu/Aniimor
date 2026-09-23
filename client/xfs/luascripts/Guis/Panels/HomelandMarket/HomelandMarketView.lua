-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandMarket\\HomelandMarketView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandMarketView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandMarketView = Class.LightClass("HomelandMarketView", UIView)

function HomelandMarketView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.backUButton = self.objectReference:GetRefValue("backUButton")
	self.titleUBaseText = self.objectReference:GetRefValue("titleUBaseText")
	self.listTabIconUList = self.objectReference:GetRefValue("listTabIconUList")
	self.marketInfoUBaseText = self.objectReference:GetRefValue("marketInfoUBaseText")
	self.rateUBaseText = self.objectReference:GetRefValue("rateUBaseText")
	self.marketUList = self.objectReference:GetRefValue("marketUList")
	self.inventoryUList = self.objectReference:GetRefValue("inventoryUList")
	self.currencyUList = self.objectReference:GetRefValue("currencyUList")
	self.timeUCountDown = self.objectReference:GetRefValue("timeUCountDown")
	self.emptyTitleUBaseText = self.objectReference:GetRefValue("emptyTitleUBaseText")
	self.emptyInfoUBaseText = self.objectReference:GetRefValue("emptyInfoUBaseText")
	self.coinGeneral = self.objectReference:GetRefValue("coinGeneral")
	self.panelPropInfoUContainer = self.objectReference:GetRefValue("panelPropInfoUContainer")
end

function HomelandMarketView:initView()
	return
end

return HomelandMarketView
