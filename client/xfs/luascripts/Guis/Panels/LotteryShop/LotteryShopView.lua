-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LotteryShop\\LotteryShopView.lua

local Class = require("Core.Framework.Class")
local ShopView = require("Guis.Panels.Shop.ShopView")
local LotteryShopView = Class.LightClass("LotteryShopView", ShopView)
local lotteryShopItemComs = {}

function LotteryShopView:findObjects()
	LotteryShopView.super.findObjects(self)

	self.listLottery = self.objectReference:GetRefValue("listLottery")
end

function LotteryShopView:getLotteryShopItemComs(button)
	if not lotteryShopItemComs[button] then
		local objectReference = button:GetComponent("ObjectReference")

		lotteryShopItemComs[button] = {
			txtTitle = objectReference:GetRefValue("txtTitle"),
			txtTips = objectReference:GetRefValue("txtTips"),
			txtBaseCost = objectReference:GetRefValue("txtBaseCost"),
			textLocke = objectReference:GetRefValue("textLocke"),
			imgCost = objectReference:GetRefValue("imgCost"),
			iconUImage = objectReference:GetRefValue("iconUImage")
		}
	end

	return lotteryShopItemComs[button]
end

function LotteryShopView:onDestroy()
	for button in pairs(lotteryShopItemComs) do
		lotteryShopItemComs[button] = nil
	end

	LotteryShopView.super.onDestroy(self)
end

return LotteryShopView
