-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Inventory\\InventoryView.lua

local UIView = require("Guis.UIView")
local Class = require("Core.Framework.Class")
local InventoryView = Class.LightClass("InventoryView", UIView)

function InventoryView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnBack = self.objectReference:GetRefValue("btnBack")
	self.txtTitle = self.objectReference:GetRefValue("txtTitle")
	self.txtCapacity = self.objectReference:GetRefValue("txtCapacity")
	self.listTabIconUList = self.objectReference:GetRefValue("listTabIconUList")
	self.listProp = self.objectReference:GetRefValue("listProp")
	self.listCurrency = self.objectReference:GetRefValue("listCurrency")
	self.btnUse1 = self.objectReference:GetRefValue("btnUse1")
	self.layoutBoxUse = self.objectReference:GetRefValue("layoutBoxUse")
	self.btnUse2 = self.objectReference:GetRefValue("btnUse2")
	self.btnCompound = self.objectReference:GetRefValue("btnCompound")
	self.sortSelector = self.objectReference:GetRefValue("sortSelector")
	self.btnSort = self.objectReference:GetRefValue("btnSort")
	self.btnRecycle = self.objectReference:GetRefValue("btnRecycle")
	self.recyclePanel = self.objectReference:GetRefValue("recyclePanel")
	self.ballPanel = self.objectReference:GetRefValue("ballPanel")
	self.rootComponent = self.objectReference:GetRefValue("rootComponent")
	self.propDetail = self.objectReference:GetRefValue("propDetail")
	self.listTabThird = self.objectReference:GetRefValue("listTabThird")
	self.btnShowUButton = self.objectReference:GetRefValue("btnShowUButton")
	self.consoleBarTransform = self.objectReference:GetRefValue("consoleBarTransform")
	self.ballDragUWidget = self.objectReference:GetRefValue("ballDragUWidget")
	self.textDragUBaseText = self.objectReference:GetRefValue("textDragUBaseText")
	self.propInfoUContainer = self.objectReference:GetRefValue("propInfoUContainer")
end

function InventoryView:registerObjects()
	return
end

return InventoryView
