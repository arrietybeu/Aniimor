-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Shop\\ShopView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ShopView = Class.LightClass("ShopView", UIView)

function ShopView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.listCoins = self.objectReference:GetRefValue("listCoins")
	self.pbBuyUComponent = self.objectReference:GetRefValue("pbBuyUComponent")
	self.pbBuyListProp = self.objectReference:GetRefValue("pbBuyListProp")
	self.pbBuyListRogue = self.objectReference:GetRefValue("pbBuyListRogue")
	self.btnExit = self.objectReference:GetRefValue("btnExit")
	self.minusBtn = self.objectReference:GetRefValue("minusBtn")
	self.btnJumpUWidget = self.objectReference:GetRefValue("btnJumpUWidget")
	self.jumpUButton = self.objectReference:GetRefValue("jumpUButton")
	self.uIPrefabShopPanelUComponent = self.objectReference:GetRefValue("uIPrefabShopPanelUComponent")
	self.btnBuffListUButton = self.objectReference:GetRefValue("btnBuffListUButton")
	self.consoleKeyUList = self.objectReference:GetRefValue("consoleKeyUList")
	self.listTabIconUList = self.objectReference:GetRefValue("listTabIconUList")
	self.panelPropInfoUContainer = self.objectReference:GetRefValue("panelPropInfoUContainer")
	self.shopName = self.objectReference:GetRefValue("txtShopName")
	self.listTabSubUList = self.objectReference:GetRefValue("listTabSubUList")
	self.rogueBuffUBaseText = self.objectReference:GetRefValue("rogueBuffUBaseText")
	self.backgroundUImage = self.objectReference:GetRefValue("backgroundUImage")
end

function ShopView:initView()
	return
end

function ShopView:getShopTagPage()
	local ret, page = self.pbBuy:TryGetCurrentPage("switcher")

	return page
end

local buyShopTagItemComs = {}

function ShopView:getBuyShopTagItemComs(btn)
	if buyShopTagItemComs[btn] == nil then
		buyShopTagItemComs[btn] = {}

		local objectReference = btn.transform:GetComponent("ObjectReference")

		buyShopTagItemComs[btn].nameTxt = objectReference:GetRefValue("txtNameUText")
		buyShopTagItemComs[btn].consoleSelected = objectReference:GetRefValue("consoleSelected")
	end

	return buyShopTagItemComs[btn]
end

local buyPropItemsComs = {}

function ShopView:getBuyPropItemComs(btn)
	if buyPropItemsComs[btn] == nil then
		buyPropItemsComs[btn] = {}

		local objectReference = btn.transform:GetComponent("ObjectReference")

		buyPropItemsComs[btn].icon = objectReference:GetRefValue("itemIcon")
		buyPropItemsComs[btn].txtName = objectReference:GetRefValue("nameTxt")
		buyPropItemsComs[btn].txtInfo = objectReference:GetRefValue("infoTxt")
		buyPropItemsComs[btn].txtCoinNumber_1 = objectReference:GetRefValue("coinNumberTxt_1")
		buyPropItemsComs[btn].imgCoinIcon_1 = objectReference:GetRefValue("coinIcon_1")
		buyPropItemsComs[btn].txtCoinNumber_2 = objectReference:GetRefValue("coinNumberTxt_2")
		buyPropItemsComs[btn].imgCoinIcon_2 = objectReference:GetRefValue("coinIcon_2")
		buyPropItemsComs[btn].numCoinUSDFText = objectReference:GetRefValue("numCoinUSDFText")
		buyPropItemsComs[btn].imgLockTxtName = objectReference:GetRefValue("lockTxt")
		buyPropItemsComs[btn].imgRedTxtName = objectReference:GetRefValue("redTxt")
		buyPropItemsComs[btn].imgYellowTxtName = objectReference:GetRefValue("yellowTxt")
		buyPropItemsComs[btn].imgGreenTxtName = objectReference:GetRefValue("greenTxt")
		buyPropItemsComs[btn].imgSellOut = objectReference:GetRefValue("sellOutImg")
		buyPropItemsComs[btn].imgLock = objectReference:GetRefValue("lockImg")
		buyPropItemsComs[btn].txtLock = objectReference:GetRefValue("lockNameTxt")
		buyPropItemsComs[btn].originalPriceTxt = objectReference:GetRefValue("originalPriceTxt")
		buyPropItemsComs[btn].countDown = objectReference:GetRefValue("cdCountDown")
		buyPropItemsComs[btn].cDTxtName = objectReference:GetRefValue("cdNameTxt")
		buyPropItemsComs[btn].buffIconUImage = objectReference:GetRefValue("buffIconUImage")
		buyPropItemsComs[btn].buffTagIconUImage = objectReference:GetRefValue("buffTagIconUImage")
		buyPropItemsComs[btn].buffTagIconUWidget = objectReference:GetRefValue("buffTagIconUWidget")
		buyPropItemsComs[btn].itemLevelUWidget = objectReference:GetRefValue("itemLevelUWidget")
		buyPropItemsComs[btn].exclusiveUContainer = objectReference:GetRefValue("exclusiveUContainer")
		buyPropItemsComs[btn].seasonTagUWidget = objectReference:GetRefValue("seasonTagUWidget")

		if buyPropItemsComs[btn].seasonTagUWidget then
			local seasonTagObjectReference = buyPropItemsComs[btn].seasonTagUWidget.transform:GetComponent("ObjectReference")

			buyPropItemsComs[btn].seasonTagUImage = seasonTagObjectReference:GetRefValue("seasonTagUImage")
			buyPropItemsComs[btn].seasonTagTitleUSDFText = seasonTagObjectReference:GetRefValue("titleUSDFText")
		end

		buyPropItemsComs[btn].itemLevelSubItems = {}
		buyPropItemsComs[btn].itemLevelSubItems[1] = objectReference:GetRefValue("lv1UWidget")
		buyPropItemsComs[btn].itemLevelSubItems[2] = objectReference:GetRefValue("lv2UWidget")
		buyPropItemsComs[btn].itemLevelSubItems[3] = objectReference:GetRefValue("lv3UWidget")
		buyPropItemsComs[btn].txtNew = objectReference:GetRefValue("txtNew")
	end

	return buyPropItemsComs[btn]
end

local buyPropPriceRuleComs = {}

function ShopView:getBuyPropPriceRuleComs(btn)
	if buyPropPriceRuleComs[btn] == nil then
		buyPropPriceRuleComs[btn] = {}
		buyPropPriceRuleComs[btn].nameTxt = btn:Find("TxtName"):GetComponent("UBaseText")
		buyPropPriceRuleComs[btn].numberTxt = btn:Find("TxtNumber"):GetComponent("UBaseText")
		buyPropPriceRuleComs[btn].icon = btn:Find("TxtNumber/Icon"):GetComponent("UImage")
	end

	return buyPropPriceRuleComs[btn]
end

local currencyItemsComs = {}

function ShopView:getCurrencyItemComs(btn)
	if currencyItemsComs[btn] == nil then
		currencyItemsComs[btn] = {}

		local objectReference = btn.transform:GetComponent("ObjectReference")

		currencyItemsComs[btn].icon = objectReference:GetRefValue("iconUImage")
		currencyItemsComs[btn].countTxt = objectReference:GetRefValue("countUText")
	end

	return currencyItemsComs[btn]
end

function ShopView:onDestroy()
	for k in next, currencyItemsComs do
		currencyItemsComs[k] = nil
	end

	for k in next, buyPropPriceRuleComs do
		buyPropPriceRuleComs[k] = nil
	end

	for k in next, buyShopTagItemComs do
		buyShopTagItemComs[k] = nil
	end

	for k in next, buyPropItemsComs do
		buyPropItemsComs[k] = nil
	end
end

return ShopView
