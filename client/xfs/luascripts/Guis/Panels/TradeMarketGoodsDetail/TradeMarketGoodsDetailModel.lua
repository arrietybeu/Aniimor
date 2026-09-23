-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketGoodsDetail\\TradeMarketGoodsDetailModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("TradeMarketGoodsDetailModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ShopConstantData = require("Data.shopmall_constant_data")
local TradeMarketGoodsDetailModel = Class.LightClass("TradeMarketGoodsDetailModel", UIModel)

TradeMarketGoodsDetailModel.EllipsesType = {
	HideUI = 2,
	SwitchGender = 1
}

function TradeMarketGoodsDetailModel:initData()
	self.boyEllipses = {
		name = "SHOP_MAN",
		icon = ShopConstantData.boy_icon and ShopConstantData.boy_icon.number,
		clickType = TradeMarketGoodsDetailModel.EllipsesType.SwitchGender
	}
	self.girlEllipses = {
		name = "SHOP_WOMAN",
		icon = ShopConstantData.girl_icon and ShopConstantData.girl_icon.number,
		clickType = TradeMarketGoodsDetailModel.EllipsesType.SwitchGender
	}
	self.hideUIEllipses = {
		name = "SHOP_HIDE_UI",
		icon = ShopConstantData.hide_icon and ShopConstantData.hide_icon.number,
		clickType = TradeMarketGoodsDetailModel.EllipsesType.HideUI
	}
end

return TradeMarketGoodsDetailModel
