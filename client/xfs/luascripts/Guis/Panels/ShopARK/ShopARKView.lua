-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ShopARK\\ShopARKView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ShopARKView = Class.LightClass("ShopARKView", UIView)
local LuaUIUtils = require("Utils.LuaUIUtils")

function ShopARKView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listCoins = objectReference:GetRefValue("listCoins")
	self.pbBuyListTag = objectReference:GetRefValue("pbBuyListTag")
	self.pbBuyListProp = objectReference:GetRefValue("pbBuyListProp")
	self.btnExit = objectReference:GetRefValue("btnExit")
	self.uIPrefabShopPanelUComponent = objectReference:GetRefValue("uIPrefabShopPanelUComponent")
	self.txtShopName = objectReference:GetRefValue("txtShopName")
	self.tabUWidget = objectReference:GetRefValue("tabUWidget")
	self.txtShopName2 = objectReference:GetRefValue("txtShopName2")
	self.propInfoUContainer = objectReference:GetRefValue("propInfoUContainer")
end

function ShopARKView:initView()
	return
end

function ShopARKView:getShopTagPage()
	local ret, page = self.pbBuy:TryGetCurrentPage("switcher")

	return page
end

local buyShopTagItemComs = {}

function ShopARKView:getBuyShopTagItemComs(btn)
	if buyShopTagItemComs[btn] == nil then
		buyShopTagItemComs[btn] = {}

		local objectReference = btn.transform:GetComponent("ObjectReference")

		buyShopTagItemComs[btn].nameTxt = objectReference:GetRefValue("txtNameUText")
		buyShopTagItemComs[btn].consoleSelected = objectReference:GetRefValue("consoleSelected")
	end

	return buyShopTagItemComs[btn]
end

local buyPropItemsComs = {}

function ShopARKView:getBuyPropItemComs(btn)
	if buyPropItemsComs[btn] == nil then
		buyPropItemsComs[btn] = {}

		local objectReference = btn.transform:GetComponent("ObjectReference")

		buyPropItemsComs[btn].icon = objectReference:GetRefValue("itemIcon")
		buyPropItemsComs[btn].txtName = objectReference:GetRefValue("nameTxt")
		buyPropItemsComs[btn].txtInfo = objectReference:GetRefValue("infoTxt")
		buyPropItemsComs[btn].numCoinUSDFText = objectReference:GetRefValue("numCoinUSDFText")
		buyPropItemsComs[btn].imgLockTxtName = objectReference:GetRefValue("lockTxt")
		buyPropItemsComs[btn].imgRedTxtName = objectReference:GetRefValue("redTxt")
		buyPropItemsComs[btn].imgYellowTxtName = objectReference:GetRefValue("yellowTxt")
		buyPropItemsComs[btn].imgGreenTxtName = objectReference:GetRefValue("greenTxt")
		buyPropItemsComs[btn].imgSellOut = objectReference:GetRefValue("sellOutImg")
		buyPropItemsComs[btn].imgLock = objectReference:GetRefValue("lockImg")
		buyPropItemsComs[btn].txtLock = objectReference:GetRefValue("lockNameTxt")
		buyPropItemsComs[btn].countDown = objectReference:GetRefValue("cdCountDown")
		buyPropItemsComs[btn].cDTxtName = objectReference:GetRefValue("cdNameTxt")
		buyPropItemsComs[btn].buffIconUImage = objectReference:GetRefValue("buffIconUImage")
		buyPropItemsComs[btn].buffTagIconUImage = objectReference:GetRefValue("buffTagIconUImage")
		buyPropItemsComs[btn].buffTagIconUWidget = objectReference:GetRefValue("buffTagIconUWidget")
		buyPropItemsComs[btn].itemLevelUWidget = objectReference:GetRefValue("itemLevelUWidget")
		buyPropItemsComs[btn].exclusiveUContainer = objectReference:GetRefValue("exclusiveUContainer")
		buyPropItemsComs[btn].itemLevelSubItems = {}
		buyPropItemsComs[btn].itemLevelSubItems[1] = objectReference:GetRefValue("lv1UWidget")
		buyPropItemsComs[btn].itemLevelSubItems[2] = objectReference:GetRefValue("lv2UWidget")
		buyPropItemsComs[btn].itemLevelSubItems[3] = objectReference:GetRefValue("lv3UWidget")
	end

	return buyPropItemsComs[btn]
end

local buyPropPriceRuleComs = {}

function ShopARKView:getBuyPropPriceRuleComs(btn)
	if buyPropPriceRuleComs[btn] == nil then
		buyPropPriceRuleComs[btn] = {}
		buyPropPriceRuleComs[btn].nameTxt = btn:Find("TxtName"):GetComponent("UBaseText")
		buyPropPriceRuleComs[btn].numberTxt = btn:Find("TxtNumber"):GetComponent("UBaseText")
		buyPropPriceRuleComs[btn].icon = btn:Find("TxtNumber/Icon"):GetComponent("UImage")
	end

	return buyPropPriceRuleComs[btn]
end

local currencyItemsComs = {}

function ShopARKView:getCurrencyItemComs(btn)
	if currencyItemsComs[btn] == nil then
		currencyItemsComs[btn] = {}

		local objectReference = btn.transform:GetComponent("ObjectReference")

		currencyItemsComs[btn].icon = objectReference:GetRefValue("iconUImage")
		currencyItemsComs[btn].countTxt = objectReference:GetRefValue("countUText")
	end

	return currencyItemsComs[btn]
end

function ShopARKView:onDestroy()
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

return ShopARKView
