-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandInventory\\HomelandInventoryView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandInventoryView = Class.LightClass("HomelandInventoryView", UIView)

function HomelandInventoryView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.listBag = self.objectReference:GetRefValue("listBag")
	self.selectorBag = self.objectReference:GetRefValue("selectorBag")
	self.btnSortBag = self.objectReference:GetRefValue("btnSortBag")
	self.btnCancelBag = self.objectReference:GetRefValue("btnCancelBag")
	self.btnPutInBag = self.objectReference:GetRefValue("btnPutInBag")
	self.listInventory = self.objectReference:GetRefValue("listInventory")
	self.selectorInventory = self.objectReference:GetRefValue("selectorInventory")
	self.btnSortInventory = self.objectReference:GetRefValue("btnSortInventory")
	self.btnTakeOutInventory = self.objectReference:GetRefValue("btnTakeOutInventory")
	self.btnCancelInventory = self.objectReference:GetRefValue("btnCancelInventory")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.listCurrencyUList = self.objectReference:GetRefValue("listCurrencyUList")
	self.panelBagRectTransform = self.objectReference:GetRefValue("panelBagRectTransform")
	self.panelWareHouseRectTransform = self.objectReference:GetRefValue("panelWareHouseRectTransform")
	self.uIPbHomeWareHouse = self.objectReference:GetRefValue("uIPbHomeWareHouse")
	self.panelBagTopRectTransform = self.objectReference:GetRefValue("panelBagTopRectTransform")
	self.panelWareHouseTopRectTransform = self.objectReference:GetRefValue("panelWareHouseTopRectTransform")
	self.panelWareHouseBottomRectTransform = self.objectReference:GetRefValue("panelWareHouseBottomRectTransform")
	self.panelBagBottomRectTransform = self.objectReference:GetRefValue("panelBagBottomRectTransform")
	self.txtNameTakeOut = self.objectReference:GetRefValue("txtNameTakeOut")
	self.txtNamePutIn = self.objectReference:GetRefValue("txtNamePutIn")
	self.maskRectTransform = self.objectReference:GetRefValue("maskRectTransform")
	self.txtDragTipsUSDFText = self.objectReference:GetRefValue("txtDragTipsUSDFText")
	self.keyHotKeyPutInBag = self.btnPutInBag:GetComponent("ObjectReference"):GetRefValue("keyHotKeyContent")
	self.keyHotKeyTakeOutInventory = self.btnTakeOutInventory:GetComponent("ObjectReference"):GetRefValue("keyHotKeyContent")
end

function HomelandInventoryView:registerObjects()
	return
end

function HomelandInventoryView:initView()
	return
end

return HomelandInventoryView
